library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_stepper is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		gated_clock : out std_logic;
		curr_PC : in std_logic_vector(31 downto 0);

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end processor_stepper;

architecture arch_imp of processor_stepper is
	signal last_PC : std_logic_vector(31 downto 0);
	signal PC_delta : std_logic;

	signal control_reg_from_axi	: std_logic_vector(31 downto 0);
	signal control_reg_from_rtl	: std_logic_vector(31 downto 0);
	signal control_reg_to_axi		: std_logic_vector(31 downto 0);
	signal control_reg_axi_write	: std_logic;
	signal control_reg_stop_all		: std_logic;

	signal control_stop_on_first : std_logic;

	signal control_continous_run : std_logic;

	signal control_clock_single, control_clock_single_next : std_logic;
	signal control_clock_counter, control_clock_counter_next : std_logic;

	signal control_PC_single, control_PC_single_next : std_logic;
	signal control_PC_counter, control_PC_counter_next : std_logic;
	signal control_PC_target, control_PC_target_next : std_logic;

	signal clock_counter_from_axi	: std_logic_vector(31 downto 0);
	signal clock_counter_from_rtl	: std_logic_vector(31 downto 0);
	signal clock_counter_to_axi		: std_logic_vector(31 downto 0);
	signal clock_counter_axi_write	: std_logic;

	signal PC_counter_from_axi		: std_logic_vector(31 downto 0);
	signal PC_counter_from_rtl		: std_logic_vector(31 downto 0);
	signal PC_counter_to_axi			: std_logic_vector(31 downto 0);
	signal PC_counter_axi_write	: std_logic;

	signal PC_target_from_axi	: std_logic_vector(31 downto 0);
	signal PC_target_to_axi		: std_logic_vector(31 downto 0);
	signal PC_target_axi_write	: std_logic;

	-- component declaration
	component processor_stepper_AXI is
		generic (
		  C_S_AXI_DATA_WIDTH	: integer	:= 32;
		  C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
			control_reg_from_axi	: out	std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			control_reg_to_axi		: in	std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			control_reg_axi_write	: out std_logic;

			clock_counter_from_axi	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			clock_counter_to_axi		: in	std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			clock_counter_axi_write	: out std_logic;

			PC_counter_from_axi		: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			PC_counter_to_axi			: in	std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			PC_counter_axi_write	: out std_logic;

			PC_target_from_axi	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			PC_target_to_axi		: in	std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			PC_target_axi_write	: out std_logic;

			S_AXI_ACLK	: in std_logic;
			S_AXI_ARESETN	: in std_logic;
			S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
			S_AXI_AWVALID	: in std_logic;
			S_AXI_AWREADY	: out std_logic;
			S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID	: in std_logic;
			S_AXI_WREADY	: out std_logic;
			S_AXI_BRESP	: out std_logic_vector(1 downto 0);
			S_AXI_BVALID	: out std_logic;
			S_AXI_BREADY	: in std_logic;
			S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
			S_AXI_ARVALID	: in std_logic;
			S_AXI_ARREADY	: out std_logic;
			S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP	: out std_logic_vector(1 downto 0);
			S_AXI_RVALID	: out std_logic;
			S_AXI_RREADY	: in std_logic
		);
	end component processor_stepper_AXI;

begin

	-- Instantiation of Axi Bus Interface S00_AXI
	processor_stepper_AXI_inst : processor_stepper_AXI
		generic map (
			C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
		)
		port map (
			control_reg_from_axi 		=> control_reg_from_axi,
			control_reg_to_axi			=> control_reg_to_axi,
			control_reg_axi_write		=> control_reg_axi_write,
			clock_counter_from_axi	=> clock_counter_from_axi,
			clock_counter_to_axi		=> clock_counter_to_axi,
			clock_counter_axi_write	=> clock_counter_axi_write,
			PC_counter_from_axi			=> PC_counter_from_axi,
			PC_counter_to_axi				=> PC_counter_to_axi,
			PC_counter_axi_write		=> PC_counter_axi_write,
			PC_target_from_axi			=> PC_target_from_axi,
			PC_target_to_axi				=> PC_target_to_axi,
			PC_target_axi_write			=> PC_target_axi_write,
			S_AXI_ACLK	=> s00_axi_aclk,
			S_AXI_ARESETN	=> s00_axi_aresetn,
			S_AXI_AWADDR	=> s00_axi_awaddr,
			S_AXI_AWPROT	=> s00_axi_awprot,
			S_AXI_AWVALID	=> s00_axi_awvalid,
			S_AXI_AWREADY	=> s00_axi_awready,
			S_AXI_WDATA	=> s00_axi_wdata,
			S_AXI_WSTRB	=> s00_axi_wstrb,
			S_AXI_WVALID	=> s00_axi_wvalid,
			S_AXI_WREADY	=> s00_axi_wready,
			S_AXI_BRESP	=> s00_axi_bresp,
			S_AXI_BVALID	=> s00_axi_bvalid,
			S_AXI_BREADY	=> s00_axi_bready,
			S_AXI_ARADDR	=> s00_axi_araddr,
			S_AXI_ARPROT	=> s00_axi_arprot,
			S_AXI_ARVALID	=> s00_axi_arvalid,
			S_AXI_ARREADY	=> s00_axi_arready,
			S_AXI_RDATA	=> s00_axi_rdata,
			S_AXI_RRESP	=> s00_axi_rresp,
			S_AXI_RVALID	=> s00_axi_rvalid,
			S_AXI_RREADY	=> s00_axi_rready
		);

	-- Add user logic here

	-- Handle control_reg update
	process(s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
		    control_reg_to_axi <= control_reg_from_rtl;

			if control_reg_axi_write = '1' then
				control_reg_to_axi <= control_reg_from_axi;
			end if;

			if control_reg_stop_all = '1' then
					control_reg_to_axi <= ( others => '0' );
			end if;
		end if;
	end process;

	-- Handle clock_counter update
	process(s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
			if clock_counter_axi_write = '1' then
				clock_counter_to_axi <= clock_counter_from_axi;
			else
				clock_counter_to_axi <= clock_counter_from_rtl;
			end if;
		end if;
	end process;

	-- Handle PC_counter update
	process(s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
			if PC_counter_axi_write = '1' then
				PC_counter_to_axi <= PC_counter_from_axi;
			else
				PC_counter_to_axi <= PC_counter_from_rtl;
			end if;
		end if;
	end process;

	-- Handle control_reg update
	process(s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
			if PC_target_axi_write = '1' then
				PC_target_to_axi <= PC_target_from_axi;
			end if;
		end if;
	end process;

	-- Handle last_PC update
	process(s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
			last_PC <= curr_PC;
		end if;
	end process;

	-- Fan control_reg out to rule signals
	control_stop_on_first 	<= control_reg_to_axi( 0);
	control_continous_run		<= control_reg_to_axi( 8);
	control_clock_single		<= control_reg_to_axi(16);
	control_clock_counter		<= control_reg_to_axi(17);
	control_PC_single				<= control_reg_to_axi(24);
	control_PC_counter			<= control_reg_to_axi(25);
	control_PC_target				<= control_reg_to_axi(26);

	-- Collect rule signals nexts in control_reg nexts
	control_reg_from_rtl <= (
		26 => control_PC_target_next,
		25 => control_PC_counter_next,
		24 => control_PC_single_next,

		17 => control_clock_counter_next,
		16 => control_clock_single_next,

		8	 => control_continous_run,

		0	 => control_stop_on_first,

		others => '0'
	);

	-- Generate Gated clock
	gated_clock <= s00_axi_aclk when (
						-- continous_run active
						control_continous_run = '1'
						-- clock_single active
				or	control_clock_single = '1'
						-- clock_counter active
				or	(control_clock_counter = '1' and clock_counter_to_axi /= "00000000000000000000000000000000")
						-- PC_single active
				or	(control_PC_single = '1' and PC_delta /= '1')
						-- PC_counter active
				or	(control_PC_counter = '1' and (PC_counter_to_axi /= "00000000000000000000000000000000" or PC_delta /= '0'))
						-- PC_target active
				or	(control_PC_target = '1' and PC_target_to_axi /= curr_PC)
			)
		else '0';

	-- Generate control_reg_stop_all
	control_reg_stop_all <= '1' when (control_stop_on_first = '1' and control_reg_to_axi /= control_reg_from_rtl)
 		else '0';

	-- Handle clock_single
	control_clock_single_next <= '0';

	-- Handle counter_single
	control_clock_counter_next <= control_clock_counter when clock_counter_to_axi /= "00000000000000000000000000000000" else '0';
	clock_counter_from_rtl <= std_logic_vector(to_unsigned(to_integer(unsigned(clock_counter_to_axi)) - 1, 32))
			when control_clock_counter_next = '1'
		else clock_counter_to_axi;

	-- Handle PC_delta
	PC_delta <= '1' when curr_PC /= last_PC else '0';

	-- Handle PC_single control_PC_single
	control_PC_single_next <= control_PC_single when PC_delta = '0' else '0';

	-- Handle PC_counter control_PC_counter
	control_PC_counter_next <= control_PC_counter when PC_counter_to_axi /= "00000000000000000000000000000000" else '0';
	PC_counter_from_rtl <= std_logic_vector(to_unsigned(to_integer(unsigned(PC_counter_to_axi)) - 1, 32))
			when control_PC_counter_next = '1' and PC_delta = '1'
		else PC_counter_to_axi;

	-- Handle PC_target control_PC_target
	control_PC_target_next <= control_PC_target when curr_PC /= PC_target_to_axi else '0';


	-- User logic ends

end arch_imp;
