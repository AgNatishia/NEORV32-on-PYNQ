-- #################################################################################################
-- # << NEORV32 - Processor Top Entity with AXI4-Lite Compatible Master Interface >>               #
-- # ********************************************************************************************* #
-- # (c) "AXI", "AXI4" and "AXI4-Lite" are trademarks of Arm Holdings plc.                         #
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

entity BD_wishbon_axi4lite_bridge is
  port (
    -- ------------------------------------------------------------
    -- AXI4-Lite-Compatible Master Interface --
    -- ------------------------------------------------------------
    -- Clock and Reset --
    m_axi_aclk    : in  std_logic;
    m_axi_aresetn : in  std_logic;

    -- Write Address Channel --
    m_axi_awaddr  : out std_logic_vector(31 downto 0);
    m_axi_awprot  : out std_logic_vector(2 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in  std_logic;

    -- Write Data Channel --
    m_axi_wdata   : out std_logic_vector(31 downto 0);
    m_axi_wstrb   : out std_logic_vector(3 downto 0);
    m_axi_wvalid  : out std_logic;
    m_axi_wready  : in  std_logic;

    -- Read Address Channel --
    m_axi_araddr  : out std_logic_vector(31 downto 0);
    m_axi_arprot  : out std_logic_vector(2 downto 0);
    m_axi_arvalid : out std_logic;
    m_axi_arready : in  std_logic;

    -- Read Data Channel --
    m_axi_rdata   : in  std_logic_vector(31 downto 0);
    m_axi_rresp   : in  std_logic_vector(1 downto 0);
    m_axi_rvalid  : in  std_logic;
    m_axi_rready  : out std_logic;

    -- Write Response Channel --
    m_axi_bresp   : in  std_logic_vector(1 downto 0);
    m_axi_bvalid  : in  std_logic;
    m_axi_bready  : out std_logic;

    -- ------------------------------------------------------------
    -- Wishbone interface --
    -- ------------------------------------------------------------
    wb_addr       : in  std_logic_vector(31 downto 0); -- address
    wb_data_write : in  std_logic_vector(31 downto 0); -- processor output data
    wb_we         : in  std_logic; -- write enable
    wb_sel        : in  std_logic_vector(03 downto 0); -- byte enable
    wb_tag        : in  std_logic_vector(2 downto 0); -- tag
    wb_cyc        : in  std_logic; -- valid cycle
    wb_stb        : in  std_logic; -- strobe
    wb_lock       : in  std_logic; -- strobe
    wb_data_read  : out std_logic_vector(31 downto 0); -- processor input data
    wb_ack        : out std_logic; -- transfer acknowledge
    wb_err        : out std_logic -- transfer error
  );
end BD_wishbon_axi4lite_bridge;

architecture BD_wishbon_axi4lite_bridge_rtl of BD_wishbon_axi4lite_bridge is
  -- AXI bridge control --
  type ctrl_t is record
    radr_received : std_logic;
    wadr_received : std_logic;
    wdat_received : std_logic;
  end record;
  signal ctrl : ctrl_t;

  signal ack_read, ack_write : std_logic; -- normal transfer termination
  signal err_read, err_write : std_logic; -- error transfer termination

  signal clk_i_int       : std_logic;
  signal rstn_i_int      : std_logic;

  signal m_axi_rready_i  : std_logic;
  signal m_axi_bready_i : std_logic;
begin
  -- Wishbone to AXI4-Lite Bridge -----------------------------------------------------------
  -- -------------------------------------------------------------------------------------------

  -- access arbiter --
  axi_access_arbiter: process(rstn_i_int, clk_i_int)
  begin
    if (rstn_i_int = '0') then
      ctrl.radr_received <= '0';
      ctrl.wadr_received <= '0';
      ctrl.wdat_received <= '0';
    elsif rising_edge(clk_i_int) then
      if (wb_cyc = '0') then -- idle
        ctrl.radr_received <= '0';
        ctrl.wadr_received <= '0';
        ctrl.wdat_received <= '0';
      else -- busy
        -- "read address received" flag --
        if (wb_we = '0') then -- pending READ
          if (m_axi_arready = '1') then -- read address received by interconnect?
            ctrl.radr_received <= '1';
          end if;
        end if;
        -- "write address received" flag --
        if (wb_we = '1') then -- pending WRITE
          if (m_axi_awready = '1') then -- write address received by interconnect?
            ctrl.wadr_received <= '1';
          end if;
        end if;
        -- "write data received" flag --
        if (wb_we = '1') then -- pending WRITE
          if (m_axi_wready = '1') then -- write data received by interconnect?
            ctrl.wdat_received <= '1';
          end if;
        end if;
      end if;
    end if;
  end process axi_access_arbiter;


  -- AXI4-Lite Global Signals --
  clk_i_int     <= std_logic(m_axi_aclk);
  rstn_i_int    <= std_logic(m_axi_aresetn);


  -- AXI4-Lite Read Address Channel --
  m_axi_araddr  <= std_logic_vector(wb_addr);
  m_axi_arvalid <= std_logic((wb_cyc and (not wb_we)) and (not ctrl.radr_received));
--m_axi_arprot  <= "000"; -- recommended by Xilinx
  m_axi_arprot(0) <= wb_tag(0); -- 0:unprivileged access, 1:privileged access
  m_axi_arprot(1) <= wb_tag(1); -- 0:secure access, 1:non-secure access
  m_axi_arprot(2) <= wb_tag(2); -- 0:data access, 1:instruction access

  -- AXI4-Lite Read Data Channel --
  m_axi_rready_i  <= std_logic(wb_cyc and (not wb_we));
  wb_data_read    <= std_logic_vector(m_axi_rdata);
  ack_read      <= std_logic(m_axi_rvalid and m_axi_rready_i);
  err_read      <= '0' when (m_axi_rresp = "00") else '1'; -- read response = ok? check this signal only when m_axi_rvalid = '1'


  -- AXI4-Lite Write Address Channel --
  m_axi_awaddr  <= std_logic_vector(wb_addr);
  m_axi_awvalid <= std_logic((wb_cyc and wb_we) and (not ctrl.wadr_received));
--m_axi_awprot  <= "000"; -- recommended by Xilinx
  m_axi_awprot(0) <= wb_tag(0); -- 0:unprivileged access, 1:privileged access
  m_axi_awprot(1) <= wb_tag(1); -- 0:secure access, 1:non-secure access
  m_axi_awprot(2) <= wb_tag(2); -- 0:data access, 1:instruction access

  -- AXI4-Lite Write Data Channel --
  m_axi_wdata   <= std_logic_vector(wb_data_write);
  m_axi_wvalid  <= std_logic((wb_cyc and wb_we) and (not ctrl.wdat_received));
  m_axi_wstrb   <= std_logic_vector(wb_sel); -- byte-enable

  -- AXI4-Lite Write Response Channel --
  m_axi_bready_i  <= std_logic(wb_cyc and wb_we);
  ack_write     <= std_logic(m_axi_bvalid and m_axi_bready_i);
  err_write     <= '0' when (m_axi_bresp = "00") else '1'; -- write response = ok? check this signal only when m_axi_bvalid = '1'


  -- Wishbone transfer termination --
  wb_ack   <= ack_read or ack_write;
  wb_err   <= (ack_read and err_read) or (ack_write and err_write);

  m_axi_rready <= m_axi_rready_i;
  m_axi_bready <= m_axi_bready_i;

end BD_wishbon_axi4lite_bridge_rtl;
