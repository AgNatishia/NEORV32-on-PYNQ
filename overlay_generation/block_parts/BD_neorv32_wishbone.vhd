-- #################################################################################################
-- # << NEORV32 - External Bus Interface (WISHBONE) >>                                             #
-- # ********************************************************************************************* #
-- # All bus accesses from the CPU, which do not target the internal IO region / the internal      #
-- # bootloader / the internal instruction or data memories (if implemented), are delegated via    #
-- # this Wishbone gateway to the external bus interface. Accessed peripherals can have a response #
-- # latency of up to BUS_TIMEOUT - 1 cycles.                                                      #
-- #                                                                                               #
-- # Even when all processor-internal memories and IO devices are disabled, the EXTERNAL address   #
-- # space ENDS at address 0xffff0000 (begin of internal BOOTROM address space).                   #
-- #                                                                                               #
-- # The interface uses registers for ALL OUTGOING AND FOR ALL INCOMING signals. Hence, an access  #
-- # latency of (at least) 2 cycles is added.                                                      #
-- #                                                                                               #
-- # This interface supports classic/standard Wishbone transactions (pkg.wb_pipe_mode_c = false)   #
-- # and also pipelined transactions (pkg.wb_pipe_mode_c = true).                                  #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2021, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.BD_neorv32_package.all;

entity BD_neorv32_wishbone is
  generic (
    -- Internal instruction memory --
    MEM_INT_IMEM_EN   : boolean := true;   -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE : natural := 8*1024; -- size of processor-internal instruction memory in bytes
    -- Internal data memory --
    MEM_INT_DMEM_EN   : boolean := true;   -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE : natural := 4*1024; -- size of processor-internal data memory in bytes
    -- Bus Timeout --
    BUS_TIMEOUT       : natural := 63      -- cycles after an UNACKNOWLEDGED bus access triggers a bus fault exception
  );
  port (
    -- global control --
    clk_i     : in  std_logic; -- global clock line
    rstn_i    : in  std_logic; -- global reset line, low-active
    -- host access --
    src_i     : in  std_logic; -- access type (0: data, 1:instruction)
    addr_i    : in  std_logic_vector(31 downto 0); -- address
    rden_i    : in  std_logic; -- read enable
    wren_i    : in  std_logic; -- write enable
    ben_i     : in  std_logic_vector(03 downto 0); -- byte write enable
    data_i    : in  std_logic_vector(31 downto 0); -- data in
    data_o    : out std_logic_vector(31 downto 0); -- data out
    lock_i    : in  std_logic; -- exclusive access request
    ack_o     : out std_logic; -- transfer acknowledge
    err_o     : out std_logic; -- transfer error
    priv_i    : in  std_logic_vector(01 downto 0); -- current CPU privilege level
    -- wishbone interface --
    wb_tag_o  : out std_logic_vector(02 downto 0); -- request tag
    wb_adr_o  : out std_logic_vector(31 downto 0); -- address
    wb_dat_i  : in  std_logic_vector(31 downto 0); -- read data
    wb_dat_o  : out std_logic_vector(31 downto 0); -- write data
    wb_we_o   : out std_logic; -- read/write
    wb_sel_o  : out std_logic_vector(03 downto 0); -- byte enable
    wb_stb_o  : out std_logic; -- strobe
    wb_cyc_o  : out std_logic; -- valid cycle
    wb_lock_o : out std_logic; -- exclusive access request
    wb_ack_i  : in  std_logic; -- transfer acknowledge
    wb_err_i  : in  std_logic  -- transfer error
  );
end BD_neorv32_wishbone;

architecture BD_neorv32_wishbone_rtl of BD_neorv32_wishbone is

  -- timeout enable --
  constant timeout_en_c : boolean := boolean(BUS_TIMEOUT /= 0); -- timeout enabled if BUS_TIMEOUT > 0

  -- access control --
  signal int_imem_acc : std_logic;
  signal int_dmem_acc : std_logic;
  signal int_boot_acc : std_logic;
  signal xbus_access  : std_logic;

  -- bus arbiter
  type ctrl_state_t is (IDLE, BUSY);
  type ctrl_t is record
    state   : ctrl_state_t;
    we      : std_logic;
    adr     : std_logic_vector(31 downto 0);
    wdat    : std_logic_vector(31 downto 0);
    rdat    : std_logic_vector(31 downto 0);
    sel     : std_logic_vector(03 downto 0);
    ack     : std_logic;
    err     : std_logic;
    timeout : std_logic_vector(index_size_f(BUS_TIMEOUT)-1 downto 0);
    src     : std_logic;
    lock    : std_logic;
    priv    : std_logic_vector(01 downto 0);
  end record;
  signal ctrl    : ctrl_t;
  signal stb_int : std_logic;
  signal cyc_int : std_logic;
  signal rdata   : std_logic_vector(31 downto 0);

  -- async RX mode --
  signal ack_gated   : std_logic;
  signal rdata_gated : std_logic_vector(31 downto 0);

begin

  -- Sanity Checks --------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- protocol --
  assert not (wb_pipe_mode_c = false) report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing STANDARD Wishbone protocol." severity note;
  assert not (wb_pipe_mode_c = true) report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing PIEPLINED Wishbone protocol." severity note;

  -- bus timeout --
  assert not (BUS_TIMEOUT /= 0) report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing auto-timeout (" & integer'image(BUS_TIMEOUT) & " cycles)." severity note;
  assert not (BUS_TIMEOUT  = 0) report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing no auto-timeout (can cause permanent CPU stall!)." severity note;

  -- endianness --
  assert not (wb_big_endian_c = false) report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing LITTLE-endian byte order." severity note;
  assert not (wb_big_endian_c = true)  report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing BIG-endian byte." severity note;

  -- async RC --
  assert not (wb_rx_buffer_c = false) report "NEORV32 PROCESSOR CONFIG NOTE: External Bus Interface - Implementing ASYNC RX path." severity note;


  -- Access Control -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- access to processor-internal IMEM or DMEM? --
  int_imem_acc <= '1' when (addr_i(31 downto index_size_f(MEM_INT_IMEM_SIZE)) = imem_base_c(31 downto index_size_f(MEM_INT_IMEM_SIZE))) and (MEM_INT_IMEM_EN = true) else '0';
  int_dmem_acc <= '1' when (addr_i(31 downto index_size_f(MEM_INT_DMEM_SIZE)) = dmem_base_c(31 downto index_size_f(MEM_INT_DMEM_SIZE))) and (MEM_INT_DMEM_EN = true) else '0';
  -- access to processor-internal BOOTROM or IO devices? --
  int_boot_acc <= '1' when (addr_i(31 downto 16) = boot_rom_base_c(31 downto 16)) else '0'; -- hacky!
  -- actual external bus access? --
  xbus_access <= (not int_imem_acc) and (not int_dmem_acc) and (not int_boot_acc);


  -- Bus Arbiter -----------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  bus_arbiter: process(rstn_i, clk_i)
  begin
    if (rstn_i = '0') then
      ctrl.state   <= IDLE;
      ctrl.we      <= def_rst_val_c;
      ctrl.adr     <= (others => def_rst_val_c);
      ctrl.wdat    <= (others => def_rst_val_c);
      ctrl.rdat    <= (others => def_rst_val_c);
      ctrl.sel     <= (others => def_rst_val_c);
      ctrl.timeout <= (others => def_rst_val_c);
      ctrl.ack     <= def_rst_val_c;
      ctrl.err     <= def_rst_val_c;
      ctrl.src     <= def_rst_val_c;
      ctrl.lock    <= def_rst_val_c;
      ctrl.priv    <= (others => def_rst_val_c);
    elsif rising_edge(clk_i) then
      -- defaults --
      ctrl.rdat    <= (others => '0'); -- required for internal output gating
      ctrl.ack     <= '0';
      ctrl.err     <= '0';
      ctrl.timeout <= std_logic_vector(to_unsigned(BUS_TIMEOUT, index_size_f(BUS_TIMEOUT)));

      -- state machine --
      case ctrl.state is

        when IDLE => -- waiting for host request
        -- ------------------------------------------------------------
          -- buffer all outgoing signals --
          ctrl.we  <= wren_i;
          ctrl.adr <= addr_i;
          if (wb_big_endian_c = true) then -- big-endian
            ctrl.wdat <= bswap32_f(data_i);
            ctrl.sel  <= bit_rev_f(ben_i);
          else -- little-endian
            ctrl.wdat <= data_i;
            ctrl.sel  <= ben_i;
          end if;
          ctrl.src  <= src_i;
          ctrl.lock <= lock_i;
          ctrl.priv <= priv_i;
          -- valid new or buffered read/write request --
          if ((xbus_access and (wren_i or rden_i)) = '1') then
            ctrl.state <= BUSY;
          end if;

        when BUSY => -- transfer in progress
        -- ------------------------------------------------------------
          ctrl.rdat <= wb_dat_i;
          if (wb_err_i = '1') or -- abnormal bus termination
             ((timeout_en_c = true) and (or_reduce_f(ctrl.timeout) = '0')) then -- valid timeout
            ctrl.err   <= '1';
            ctrl.state <= IDLE;
          elsif (wb_ack_i = '1') then -- normal bus termination
            ctrl.ack   <= '1';
            ctrl.state <= IDLE;
          end if;
          -- timeout counter --
          if (timeout_en_c = true) then
            ctrl.timeout <= std_logic_vector(unsigned(ctrl.timeout) - 1); -- timeout counter
          end if;

        when others => -- undefined
        -- ------------------------------------------------------------
          ctrl.state <= IDLE;

      end case;
    end if;
  end process bus_arbiter;

  -- host access --
  ack_gated   <= wb_ack_i when (ctrl.state = BUSY) else '0'; -- CPU ack gate for "async" RX
  rdata_gated <= wb_dat_i when (ctrl.state = BUSY) else (others => '0'); -- CPU read data gate for "async" RX
  rdata       <= ctrl.rdat when (wb_rx_buffer_c = true) else rdata_gated;

  data_o <= rdata when (wb_big_endian_c = false) else bswap32_f(rdata); -- endianness conversion
  ack_o  <= ctrl.ack when (wb_rx_buffer_c = true) else ack_gated;
  err_o  <= ctrl.err;

  -- wishbone interface --
  wb_tag_o(0) <= '1' when (ctrl.priv = priv_mode_m_c) else '0'; -- privileged access when in machine mode
  wb_tag_o(1) <= '0'; -- 0 = secure, 1 = non-secure
  wb_tag_o(2) <= ctrl.src; -- 0 = data access, 1 = instruction access

  wb_lock_o <= ctrl.lock; -- 1 = exclusive access request

  wb_adr_o <= ctrl.adr;
  wb_dat_o <= ctrl.wdat;
  wb_we_o  <= ctrl.we;
  wb_sel_o <= ctrl.sel;
  wb_stb_o <= stb_int when (wb_pipe_mode_c = true) else cyc_int;
  wb_cyc_o <= cyc_int;

  stb_int <= '1' when (ctrl.state = BUSY) else '0';
  cyc_int <= '1' when (ctrl.state = BUSY) else '0';


end BD_neorv32_wishbone_rtl;
