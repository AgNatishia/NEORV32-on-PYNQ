library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity neo_capture_harness is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 8
	);
	port (
		-- Users to add ports here
		-- CPU Control outputs
		control_ctrl			:	in std_logic_vector(73 downto 0);
		control_imm				:	in std_logic_vector(31 downto 0);
		control_fetch_PC	:	in std_logic_vector(31 downto 0);
		control_curr_PC		:	in std_logic_vector(31 downto 0);

		-- Reg outputs
		regfile_read_0		:	in std_logic_vector(31 downto 0);
		regfile_read_1		:	in std_logic_vector(31 downto 0);
		regfile_compare		:	in std_logic_vector(1 downto 0);

		-- ALU outputs
		alu_result		:	in std_logic_vector(31 downto 0);
		alu_addr			:	in std_logic_vector(31 downto 0);
		alu_cp_start	:	in std_logic_vector(7 downto 0);
		alu_cp_valid	:	in std_logic_vector(7 downto 0);

		-- Co Processors
		coprocessor_results       :	in std_logic_vector(8*32 -1 downto 0);

		-- Bus Control outputs
		bus_instr				:	in std_logic_vector(31 downto 0);
		bus_instr_wait	:	in std_logic;
		bus_instr_misaligned	:	in std_logic;
		bus_instr_bus_error		:	in std_logic;

		bus_data_addr		:	in std_logic_vector(31 downto 0);
		bus_read_data		:	in std_logic_vector(31 downto 0);
		bus_data_wait		:	in std_logic;
		bus_excl_state	:	in std_logic;
		bus_load_misaligned		:	in std_logic;
		bus_load_bus_error		:	in std_logic;
		bus_store_misaligned	:	in std_logic;
		bus_store_bus_error		:	in std_logic;

		-- Instruction fetch bus
		instr_bus_addr					:	in std_logic_vector(31 downto 0);
		instr_bus_read_enable		:	in std_logic;
		instr_bus_read_data			:	in std_logic_vector(31 downto 0);
		instr_bus_write_enable	:	in std_logic;
        instr_bus_write_data		: in std_logic_vector(31 downto 0);
		instr_bus_byte_enable		:	in std_logic_vector( 3 downto 0);
        instr_bus_lock	:	in std_logic;
        instr_bus_ack		:	in std_logic;
        instr_bus_err		:	in std_logic;
        instr_bus_fence	:	in std_logic;

		-- Data access bus
		data_bus_addr					:	in std_logic_vector(31 downto 0);
		data_bus_read_enable	:	in std_logic;
        data_bus_read_data		:	in std_logic_vector(31 downto 0);
		data_bus_write_enable	:	in std_logic;
        data_bus_write_data		:	in std_logic_vector(31 downto 0);
		data_bus_byte_enable	:	in std_logic_vector(3 downto 0);
        data_bus_lock		:	in std_logic;
        data_bus_ack		:	in std_logic;
        data_bus_err		:	in std_logic;
        data_bus_fence	:	in std_logic;

		-- Internal Bus keep
		keeper_bus_err	:	in std_logic;
		external_bus_err_in	:	in std_logic;
		external_bus_err_ored	:	in std_logic;

		-- Muxed External bus
		external_bus_addr	:	in std_logic_vector(31 downto 0);
		external_bus_read_enable	:	in std_logic;
		external_bus_read_data		:	in std_logic_vector(31 downto 0);
		external_bus_write_enable	:	in std_logic;
		external_bus_write_data		:	in std_logic_vector(31 downto 0);
		external_bus_byte_enable	:	in std_logic_vector( 3 downto 0);
		external_bus_src	:	in std_logic;
		external_bus_lock	:	in std_logic;
		external_bus_ack	:	in std_logic;

		-- Wishbone bus
		wishbone_addr				:	in std_logic_vector(31 downto 0);
		wishbone_read_write	:	in std_logic;
		wishbone_read_data	:	in std_logic_vector(31 downto 0);
		wishbone_write_data	:	in std_logic_vector(31 downto 0);
		wishbone_byte_sel		:	in std_logic_vector(3 downto 0);
		wishbone_tag				:	in std_logic_vector(2 downto 0);
		wishbone_strobe	:	in std_logic;
		wishbone_cycle	:	in std_logic;
		wishbone_lock		:	in std_logic;
		wishbone_ack		:	in std_logic;
		wishbone_err		:	in std_logic;

		-- NEORV axi
		NEORV_axi_araddr	:	in std_logic_vector(31 downto 0);
		NEORV_axi_arprot	:	in std_logic_vector(2 downto 0);
		NEORV_axi_arvalid	:	in std_logic;
		NEORV_axi_arready	:	in std_logic;

		NEORV_axi_rdata		:	in std_logic_vector(31 downto 0);
		NEORV_axi_rresp		:	in std_logic_vector(1 downto 0);
		NEORV_axi_rvalid	:	in std_logic;
		NEORV_axi_rready	:	in std_logic;

		NEORV_axi_awaddr	:	in std_logic_vector(31 downto 0);
		NEORV_axi_awprot	:	in std_logic_vector(2 downto 0);
		NEORV_axi_awvalid	:	in std_logic;
		NEORV_axi_awready	:	in std_logic;

		NEORV_axi_wdata		:	in std_logic_vector(31 downto 0);
		NEORV_axi_wstrb		:	in std_logic_vector(3 downto 0);
		NEORV_axi_wvalid	:	in std_logic;
		NEORV_axi_wready	:	in std_logic;

		NEORV_axi_bresp		:	in std_logic_vector(1 downto 0);
		NEORV_axi_bvalid	:	in std_logic;
		NEORV_axi_bready	:	in std_logic;

		-- BRAM axi
		BRAM_axi_araddr		:	in std_logic_vector(31 downto 0);
		BRAM_axi_arprot		:	in std_logic_vector( 2 downto 0);
		BRAM_axi_arvalid	:	in std_logic;
		BRAM_axi_arready	:	in std_logic;

		BRAM_axi_rdata	:	in std_logic_vector(31 downto 0);
		BRAM_axi_rresp	:	in std_logic_vector(1 downto 0);
		BRAM_axi_rvalid	:	in std_logic;
		BRAM_axi_rready	:	in std_logic;

		BRAM_axi_awaddr		:	in std_logic_vector(31 downto 0);
		BRAM_axi_awprot		:	in std_logic_vector( 2 downto 0);
		BRAM_axi_awvalid	:	in std_logic;
		BRAM_axi_awready	:	in std_logic;

		BRAM_axi_wdata	:	in std_logic_vector(31 downto 0);
		BRAM_axi_wstrb	:	in std_logic_vector( 3 downto 0);
		BRAM_axi_wvalid	:	in std_logic;
		BRAM_axi_wready	:	in std_logic;

		BRAM_axi_bresp	:	in std_logic_vector(1 downto 0);
		BRAM_axi_bvalid	:	in std_logic;
		BRAM_axi_bready	:	in std_logic;

		-- BRAM
		BRAM_addr					:	in std_logic_vector(31 downto 0);
		BRAM_enable				:	in std_logic;
		BRAM_read_data		:	in std_logic_vector(31 downto 0);
		BRAM_write_enable	:	in std_logic_vector(3 downto 0);
		BRAM_write_data		:	in std_logic_vector(31 downto 0);

		-- LED axi
		LEDs_axi_araddr		:	in std_logic_vector(31 downto 0);
		LEDs_axi_arprot		:	in std_logic_vector(2 downto 0);
		LEDs_axi_arvalid	:	in std_logic;
		LEDs_axi_arready	:	in std_logic;

		LEDs_axi_rdata		:	in std_logic_vector(31 downto 0);
		LEDs_axi_rresp		:	in std_logic_vector(1 downto 0);
		LEDs_axi_rvalid		:	in std_logic;
		LEDs_axi_rready		:	in std_logic;

		LEDs_axi_awaddr		:	in std_logic_vector(31 downto 0);
		LEDs_axi_awprot		:	in std_logic_vector(2 downto 0);
		LEDs_axi_awvalid	:	in std_logic;
		LEDs_axi_awready	:	in std_logic;

		LEDs_axi_wdata		:	in std_logic_vector(31 downto 0);
		LEDs_axi_wstrb		:	in std_logic_vector(3 downto 0);
		LEDs_axi_wvalid		:	in std_logic;
		LEDs_axi_wready		:	in std_logic;

		LEDs_axi_bresp		:	in std_logic_vector(1 downto 0);
		LEDs_axi_bvalid		:	in std_logic;
		LEDs_axi_bready		:	in std_logic;

		-- Button axi
		buttons_axi_araddr	:	in std_logic_vector(31 downto 0);
		buttons_axi_arprot	:	in std_logic_vector( 2 downto 0);
		buttons_axi_arvalid	:	in std_logic;
		buttons_axi_arready	:	in std_logic;

		buttons_axi_rdata		:	in std_logic_vector(31 downto 0);
		buttons_axi_rresp		:	in std_logic_vector(1 downto 0);
		buttons_axi_rvalid	:	in std_logic;
		buttons_axi_rready	:	in std_logic;

		buttons_axi_awaddr	:	in std_logic_vector(31 downto 0);
		buttons_axi_awprot	:	in std_logic_vector( 2 downto 0);
		buttons_axi_awvalid	:	in std_logic;
		buttons_axi_awready	:	in std_logic;

		buttons_axi_wdata		:	in std_logic_vector(31 downto 0);
		buttons_axi_wstrb		:	in std_logic_vector( 3 downto 0);
		buttons_axi_wvalid	:	in std_logic;
		buttons_axi_wready	:	in std_logic;

		buttons_axi_bresp		:	in std_logic_vector(1 downto 0);
		buttons_axi_bvalid	:	in std_logic;
		buttons_axi_bready	:	in std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk		: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata		: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb		: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp		: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata		: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp		: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end neo_capture_harness;

architecture arch_imp of neo_capture_harness is
	-- axi space signals
	signal slv_word_0,	slv_word_0_reg	: std_logic_vector(31 downto 0);
	signal slv_word_1,	slv_word_1_reg	: std_logic_vector(31 downto 0);
	signal slv_word_2,	slv_word_2_reg	: std_logic_vector(31 downto 0);
	signal slv_word_3,	slv_word_3_reg	: std_logic_vector(31 downto 0);
	signal slv_word_4,	slv_word_4_reg	: std_logic_vector(31 downto 0);
	signal slv_word_5,	slv_word_5_reg	: std_logic_vector(31 downto 0);
	signal slv_word_6,	slv_word_6_reg	: std_logic_vector(31 downto 0);
	signal slv_word_7,	slv_word_7_reg	: std_logic_vector(31 downto 0);
	signal slv_word_8,	slv_word_8_reg	: std_logic_vector(31 downto 0);
	signal slv_word_9,	slv_word_9_reg	: std_logic_vector(31 downto 0);
	signal slv_word_10,	slv_word_10_reg	: std_logic_vector(31 downto 0);
	signal slv_word_11,	slv_word_11_reg	: std_logic_vector(31 downto 0);
	signal slv_word_12,	slv_word_12_reg	: std_logic_vector(31 downto 0);
	signal slv_word_13,	slv_word_13_reg	: std_logic_vector(31 downto 0);
	signal slv_word_14,	slv_word_14_reg	: std_logic_vector(31 downto 0);
	signal slv_word_15,	slv_word_15_reg	: std_logic_vector(31 downto 0);
	signal slv_word_16,	slv_word_16_reg	: std_logic_vector(31 downto 0);
	signal slv_word_17,	slv_word_17_reg	: std_logic_vector(31 downto 0);
	signal slv_word_18,	slv_word_18_reg	: std_logic_vector(31 downto 0);
	signal slv_word_19,	slv_word_19_reg	: std_logic_vector(31 downto 0);
	signal slv_word_20,	slv_word_20_reg	: std_logic_vector(31 downto 0);
	signal slv_word_21,	slv_word_21_reg	: std_logic_vector(31 downto 0);
	signal slv_word_22,	slv_word_22_reg	: std_logic_vector(31 downto 0);
	signal slv_word_23,	slv_word_23_reg	: std_logic_vector(31 downto 0);
	signal slv_word_24,	slv_word_24_reg	: std_logic_vector(31 downto 0);
	signal slv_word_25,	slv_word_25_reg	: std_logic_vector(31 downto 0);
	signal slv_word_26,	slv_word_26_reg	: std_logic_vector(31 downto 0);
	signal slv_word_27,	slv_word_27_reg	: std_logic_vector(31 downto 0);
	signal slv_word_28,	slv_word_28_reg	: std_logic_vector(31 downto 0);
	signal slv_word_29,	slv_word_29_reg	: std_logic_vector(31 downto 0);
	signal slv_word_30,	slv_word_30_reg	: std_logic_vector(31 downto 0);
	signal slv_word_31,	slv_word_31_reg	: std_logic_vector(31 downto 0);
	signal slv_word_32,	slv_word_32_reg	: std_logic_vector(31 downto 0);
	signal slv_word_33,	slv_word_33_reg	: std_logic_vector(31 downto 0);
	signal slv_word_34,	slv_word_34_reg	: std_logic_vector(31 downto 0);
	signal slv_word_35,	slv_word_35_reg	: std_logic_vector(31 downto 0);
	signal slv_word_36,	slv_word_36_reg	: std_logic_vector(31 downto 0);
	signal slv_word_37,	slv_word_37_reg	: std_logic_vector(31 downto 0);
	signal slv_word_38,	slv_word_38_reg	: std_logic_vector(31 downto 0);
	signal slv_word_39,	slv_word_39_reg	: std_logic_vector(31 downto 0);
	signal slv_word_40,	slv_word_40_reg	: std_logic_vector(31 downto 0);
	signal slv_word_41,	slv_word_41_reg	: std_logic_vector(31 downto 0);
	signal slv_word_42,	slv_word_42_reg	: std_logic_vector(31 downto 0);
	signal slv_word_43,	slv_word_43_reg	: std_logic_vector(31 downto 0);
	signal slv_word_44,	slv_word_44_reg	: std_logic_vector(31 downto 0);
	signal slv_word_45,	slv_word_45_reg	: std_logic_vector(31 downto 0);
	signal slv_word_46,	slv_word_46_reg	: std_logic_vector(31 downto 0);
	signal slv_word_47,	slv_word_47_reg	: std_logic_vector(31 downto 0);
	signal slv_word_48,	slv_word_48_reg	: std_logic_vector(31 downto 0);
	signal slv_word_49,	slv_word_49_reg	: std_logic_vector(31 downto 0);
	signal slv_word_50,	slv_word_50_reg	: std_logic_vector(31 downto 0);
	signal slv_word_51,	slv_word_51_reg	: std_logic_vector(31 downto 0);
	signal slv_word_52,	slv_word_52_reg	: std_logic_vector(31 downto 0);
	signal slv_word_53,	slv_word_53_reg	: std_logic_vector(31 downto 0);
	signal slv_word_54,	slv_word_54_reg	: std_logic_vector(31 downto 0);
	signal slv_word_55,	slv_word_55_reg	: std_logic_vector(31 downto 0);
	signal slv_word_56,	slv_word_56_reg	: std_logic_vector(31 downto 0);
	signal slv_word_57,	slv_word_57_reg	: std_logic_vector(31 downto 0);
	signal slv_word_58,	slv_word_58_reg	: std_logic_vector(31 downto 0);
	signal slv_word_59,	slv_word_59_reg	: std_logic_vector(31 downto 0);
	signal slv_word_60,	slv_word_60_reg	: std_logic_vector(31 downto 0);
	signal slv_word_61,	slv_word_61_reg	: std_logic_vector(31 downto 0);
	signal slv_word_62,	slv_word_62_reg	: std_logic_vector(31 downto 0);
	signal slv_word_63,	slv_word_63_reg	: std_logic_vector(31 downto 0);

  signal coprocessor_0_result	: std_logic_vector(31 downto 0);
  signal coprocessor_1_result	: std_logic_vector(31 downto 0);
  signal coprocessor_2_result	: std_logic_vector(31 downto 0);
  signal coprocessor_3_result	: std_logic_vector(31 downto 0);
  signal coprocessor_4_result	: std_logic_vector(31 downto 0);
  signal coprocessor_5_result	: std_logic_vector(31 downto 0);
  signal coprocessor_6_result	: std_logic_vector(31 downto 0);
  signal coprocessor_7_result	: std_logic_vector(31 downto 0);


	-- component declaration
	component neo_capture_harness_AXI is
		generic (
			C_S_AXI_DATA_WIDTH	: integer	:= 32;
			C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (
			slv_word_0	: in std_logic_vector(31 downto 0);
			slv_word_1	: in std_logic_vector(31 downto 0);
			slv_word_2	: in std_logic_vector(31 downto 0);
			slv_word_3	: in std_logic_vector(31 downto 0);
			slv_word_4	: in std_logic_vector(31 downto 0);
			slv_word_5	: in std_logic_vector(31 downto 0);
			slv_word_6	: in std_logic_vector(31 downto 0);
			slv_word_7	: in std_logic_vector(31 downto 0);
			slv_word_8	: in std_logic_vector(31 downto 0);
			slv_word_9	: in std_logic_vector(31 downto 0);
			slv_word_10	: in std_logic_vector(31 downto 0);
			slv_word_11	: in std_logic_vector(31 downto 0);
			slv_word_12	: in std_logic_vector(31 downto 0);
			slv_word_13	: in std_logic_vector(31 downto 0);
			slv_word_14	: in std_logic_vector(31 downto 0);
			slv_word_15	: in std_logic_vector(31 downto 0);
			slv_word_16	: in std_logic_vector(31 downto 0);
			slv_word_17	: in std_logic_vector(31 downto 0);
			slv_word_18	: in std_logic_vector(31 downto 0);
			slv_word_19	: in std_logic_vector(31 downto 0);
			slv_word_20	: in std_logic_vector(31 downto 0);
			slv_word_21	: in std_logic_vector(31 downto 0);
			slv_word_22	: in std_logic_vector(31 downto 0);
			slv_word_23	: in std_logic_vector(31 downto 0);
			slv_word_24	: in std_logic_vector(31 downto 0);
			slv_word_25	: in std_logic_vector(31 downto 0);
			slv_word_26	: in std_logic_vector(31 downto 0);
			slv_word_27	: in std_logic_vector(31 downto 0);
			slv_word_28	: in std_logic_vector(31 downto 0);
			slv_word_29	: in std_logic_vector(31 downto 0);
			slv_word_30	: in std_logic_vector(31 downto 0);
			slv_word_31	: in std_logic_vector(31 downto 0);
			slv_word_32	: in std_logic_vector(31 downto 0);
			slv_word_33	: in std_logic_vector(31 downto 0);
			slv_word_34	: in std_logic_vector(31 downto 0);
			slv_word_35	: in std_logic_vector(31 downto 0);
			slv_word_36	: in std_logic_vector(31 downto 0);
			slv_word_37	: in std_logic_vector(31 downto 0);
			slv_word_38	: in std_logic_vector(31 downto 0);
			slv_word_39	: in std_logic_vector(31 downto 0);
			slv_word_40	: in std_logic_vector(31 downto 0);
			slv_word_41	: in std_logic_vector(31 downto 0);
			slv_word_42	: in std_logic_vector(31 downto 0);
			slv_word_43	: in std_logic_vector(31 downto 0);
			slv_word_44	: in std_logic_vector(31 downto 0);
			slv_word_45	: in std_logic_vector(31 downto 0);
			slv_word_46	: in std_logic_vector(31 downto 0);
			slv_word_47	: in std_logic_vector(31 downto 0);
			slv_word_48	: in std_logic_vector(31 downto 0);
			slv_word_49	: in std_logic_vector(31 downto 0);
			slv_word_50	: in std_logic_vector(31 downto 0);
			slv_word_51	: in std_logic_vector(31 downto 0);
			slv_word_52	: in std_logic_vector(31 downto 0);
			slv_word_53	: in std_logic_vector(31 downto 0);
			slv_word_54	: in std_logic_vector(31 downto 0);
			slv_word_55	: in std_logic_vector(31 downto 0);
			slv_word_56	: in std_logic_vector(31 downto 0);
			slv_word_57	: in std_logic_vector(31 downto 0);
			slv_word_58	: in std_logic_vector(31 downto 0);
			slv_word_59	: in std_logic_vector(31 downto 0);
			slv_word_60	: in std_logic_vector(31 downto 0);
			slv_word_61	: in std_logic_vector(31 downto 0);
			slv_word_62	: in std_logic_vector(31 downto 0);
			slv_word_63	: in std_logic_vector(31 downto 0);

			S_AXI_ACLK		: in std_logic;
			S_AXI_ARESETN	: in std_logic;
			S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
			S_AXI_AWVALID	: in std_logic;
			S_AXI_AWREADY	: out std_logic;
			S_AXI_WDATA		: in std_logic_vector(31 downto 0);
			S_AXI_WSTRB		: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID	: in std_logic;
			S_AXI_WREADY	: out std_logic;
			S_AXI_BRESP		: out std_logic_vector(1 downto 0);
			S_AXI_BVALID	: out std_logic;
			S_AXI_BREADY	: in std_logic;
			S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
			S_AXI_ARVALID	: in std_logic;
			S_AXI_ARREADY	: out std_logic;
			S_AXI_RDATA		: out std_logic_vector(31 downto 0);
			S_AXI_RRESP		: out std_logic_vector(1 downto 0);
			S_AXI_RVALID	: out std_logic;
			S_AXI_RREADY	: in std_logic
		);
	end component neo_capture_harness_AXI;

begin
    coprocessor_0_result <= coprocessor_results(0*32 + 31 downto 0*32);
    coprocessor_1_result <= coprocessor_results(1*32 + 31 downto 1*32);
    coprocessor_2_result <= coprocessor_results(2*32 + 31 downto 2*32);
    coprocessor_3_result <= coprocessor_results(3*32 + 31 downto 3*32);
    coprocessor_4_result <= coprocessor_results(4*32 + 31 downto 4*32);
    coprocessor_5_result <= coprocessor_results(5*32 + 31 downto 5*32);
    coprocessor_6_result <= coprocessor_results(6*32 + 31 downto 6*32);
    coprocessor_7_result <= coprocessor_results(7*32 + 31 downto 7*32);

	-- Instantiation of Axi Bus Interface S00_AXI
	neo_capture_harness_S00_AXI_inst : neo_capture_harness_AXI
		generic map (
			C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
		)
		port map (
			slv_word_0	=> slv_word_0_reg,
			slv_word_1	=> slv_word_1_reg,
			slv_word_2	=> slv_word_2_reg,
			slv_word_3	=> slv_word_3_reg,
			slv_word_4	=> slv_word_4_reg,
			slv_word_5	=> slv_word_5_reg,
			slv_word_6	=> slv_word_6_reg,
			slv_word_7	=> slv_word_7_reg,
			slv_word_8	=> slv_word_8_reg,
			slv_word_9	=> slv_word_9_reg,
			slv_word_10	=> slv_word_10_reg,
			slv_word_11	=> slv_word_11_reg,
			slv_word_12	=> slv_word_12_reg,
			slv_word_13	=> slv_word_13_reg,
			slv_word_14	=> slv_word_14_reg,
			slv_word_15	=> slv_word_15_reg,
			slv_word_16	=> slv_word_16_reg,
			slv_word_17	=> slv_word_17_reg,
			slv_word_18	=> slv_word_18_reg,
			slv_word_19	=> slv_word_19_reg,
			slv_word_20	=> slv_word_20_reg,
			slv_word_21	=> slv_word_21_reg,
			slv_word_22	=> slv_word_22_reg,
			slv_word_23	=> slv_word_23_reg,
			slv_word_24	=> slv_word_24_reg,
			slv_word_25	=> slv_word_25_reg,
			slv_word_26	=> slv_word_26_reg,
			slv_word_27	=> slv_word_27_reg,
			slv_word_28	=> slv_word_28_reg,
			slv_word_29	=> slv_word_29_reg,
			slv_word_30	=> slv_word_30_reg,
			slv_word_31	=> slv_word_31_reg,
			slv_word_32	=> slv_word_32_reg,
			slv_word_33	=> slv_word_33_reg,
			slv_word_34	=> slv_word_34_reg,
			slv_word_35	=> slv_word_35_reg,
			slv_word_36	=> slv_word_36_reg,
			slv_word_37	=> slv_word_37_reg,
			slv_word_38	=> slv_word_38_reg,
			slv_word_39	=> slv_word_39_reg,
			slv_word_40	=> slv_word_40_reg,
			slv_word_41	=> slv_word_41_reg,
			slv_word_42	=> slv_word_42_reg,
			slv_word_43	=> slv_word_43_reg,
			slv_word_44	=> slv_word_44_reg,
			slv_word_45	=> slv_word_45_reg,
			slv_word_46	=> slv_word_46_reg,
			slv_word_47	=> slv_word_47_reg,
			slv_word_48	=> slv_word_48_reg,
			slv_word_49	=> slv_word_49_reg,
			slv_word_50	=> slv_word_50_reg,
			slv_word_51	=> slv_word_51_reg,
			slv_word_52	=> slv_word_52_reg,
			slv_word_53	=> slv_word_53_reg,
			slv_word_54	=> slv_word_54_reg,
			slv_word_55	=> slv_word_55_reg,
			slv_word_56	=> slv_word_56_reg,
			slv_word_57	=> slv_word_57_reg,
			slv_word_58	=> slv_word_58_reg,
			slv_word_59	=> slv_word_59_reg,
			slv_word_60	=> slv_word_60_reg,
			slv_word_61	=> slv_word_61_reg,
			slv_word_62	=> slv_word_62_reg,
			slv_word_63	=> slv_word_63_reg,

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
	process (s00_axi_aclk)
	begin
		if rising_edge(s00_axi_aclk) then
			slv_word_0_reg	<= slv_word_0;
			slv_word_1_reg	<= slv_word_1;
			slv_word_2_reg	<= slv_word_2;
			slv_word_3_reg	<= slv_word_3;
			slv_word_4_reg	<= slv_word_4;
			slv_word_5_reg	<= slv_word_5;
			slv_word_6_reg	<= slv_word_6;
			slv_word_7_reg	<= slv_word_7;
			slv_word_8_reg	<= slv_word_8;
			slv_word_9_reg	<= slv_word_9;
			slv_word_10_reg	<= slv_word_10;
			slv_word_11_reg	<= slv_word_11;
			slv_word_12_reg	<= slv_word_12;
			slv_word_13_reg	<= slv_word_13;
			slv_word_14_reg	<= slv_word_14;
			slv_word_15_reg	<= slv_word_15;
			slv_word_16_reg	<= slv_word_16;
			slv_word_17_reg	<= slv_word_17;
			slv_word_18_reg	<= slv_word_18;
			slv_word_19_reg	<= slv_word_19;
			slv_word_20_reg	<= slv_word_20;
			slv_word_21_reg	<= slv_word_21;
			slv_word_22_reg	<= slv_word_22;
			slv_word_23_reg	<= slv_word_23;
			slv_word_24_reg	<= slv_word_24;
			slv_word_25_reg	<= slv_word_25;
			slv_word_26_reg	<= slv_word_26;
			slv_word_27_reg	<= slv_word_27;
			slv_word_28_reg	<= slv_word_28;
			slv_word_29_reg	<= slv_word_29;
			slv_word_30_reg	<= slv_word_30;
			slv_word_31_reg	<= slv_word_31;
			slv_word_32_reg	<= slv_word_32;
			slv_word_33_reg	<= slv_word_33;
			slv_word_34_reg	<= slv_word_34;
			slv_word_35_reg	<= slv_word_35;
			slv_word_36_reg	<= slv_word_36;
			slv_word_37_reg	<= slv_word_37;
			slv_word_38_reg	<= slv_word_38;
			slv_word_39_reg	<= slv_word_39;
			slv_word_40_reg	<= slv_word_40;
			slv_word_41_reg	<= slv_word_41;
			slv_word_42_reg	<= slv_word_42;
			slv_word_43_reg	<= slv_word_43;
			slv_word_44_reg	<= slv_word_44;
			slv_word_45_reg	<= slv_word_45;
			slv_word_46_reg	<= slv_word_46;
			slv_word_47_reg	<= slv_word_47;
			slv_word_48_reg	<= slv_word_48;
			slv_word_49_reg	<= slv_word_49;
			slv_word_50_reg	<= slv_word_50;
			slv_word_51_reg	<= slv_word_51;
			slv_word_52_reg	<= slv_word_52;
			slv_word_53_reg	<= slv_word_53;
			slv_word_54_reg	<= slv_word_54;
			slv_word_55_reg	<= slv_word_55;
			slv_word_56_reg	<= slv_word_56;
			slv_word_57_reg	<= slv_word_57;
			slv_word_58_reg	<= slv_word_58;
			slv_word_59_reg	<= slv_word_59;
			slv_word_60_reg	<= slv_word_60;
			slv_word_61_reg	<= slv_word_61;
			slv_word_62_reg	<= slv_word_62;
			slv_word_63_reg	<= slv_word_63;
		end if;
	end process;

	-- CPU ALU's and Co-processors' controls in words 0 and 1
	slv_word_0	<= (
			-- Co-processor valid in byte 3
	    31	=>	alu_cp_valid(7),
	    30	=>	alu_cp_valid(6),
	    29	=>	alu_cp_valid(5),
	    28	=>	alu_cp_valid(4),
	    27	=>	alu_cp_valid(3),
	    26	=>	alu_cp_valid(2),
	    25	=>	alu_cp_valid(1),
	    24	=>	alu_cp_valid(0),

			-- Co-processor start in byte 2
	    23	=>	alu_cp_start(7),
	    22	=>	alu_cp_start(6),
	    21	=>	alu_cp_start(5),
	    20	=>	alu_cp_start(4),
	    19	=>	alu_cp_start(3),
	    18	=>	alu_cp_start(2),
	    17	=>	alu_cp_start(1),
	    16	=>	alu_cp_start(0),

			-- ALU's controls in bytes 0 and 1
	    15	=>	'0',
	    14	=>	'0',
	    13	=>	'0',
	    12	=>	'0',
	    11	=>	'0',
			-- shift direction (0=left, 1=right)
	    10	=>	control_ctrl(27),
			-- is arithmetic shift
	    9		=>	control_ctrl(28),
			-- 0=ADD, 1=SUB
	    8		=>	control_ctrl(23),
			-- ALU function select command
	    7		=>	control_ctrl(22),
	    6		=>	control_ctrl(21),
			-- ALU logic command
	    5		=>	control_ctrl(20),
	    4		=>	control_ctrl(19),
			-- ALU arithmetic command
	    3		=>	control_ctrl(18),
			-- is unsigned ALU operation
	    2		=>	control_ctrl(26),
			-- operand B select (0=rs2, 1=IMM)
	    1		=>	control_ctrl(25),
			-- operand A select (0=rs1, 1=PC)
	    0		=>	control_ctrl(24)
	  );
	slv_word_1	<= (
	    -- Co-processor funct12 in bytes 2 and 3
			31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=>	'0',
	    27	=>	control_ctrl(61),
	    26	=>	control_ctrl(60),
	    25	=>	control_ctrl(59),
	    24	=>	control_ctrl(58),
	    23	=>	control_ctrl(57),
	    22	=>	control_ctrl(56),
	    21	=>	control_ctrl(55),
	    20	=>	control_ctrl(54),
	    19	=>	control_ctrl(53),
	    18	=>	control_ctrl(52),
	    17	=>	control_ctrl(51),
	    16	=>	control_ctrl(50),

				-- Co-processor funct7 in byte 1
	    15	=>	'0',
	    14	=>	control_ctrl(68),
	    13	=>	control_ctrl(67),
	    12	=>	control_ctrl(66),
	    11	=>	control_ctrl(65),
	    10	=>	control_ctrl(64),
	    9		=>	control_ctrl(63),
	    8		=>	control_ctrl(62),

			-- Co-processor funct3 in byte 0 upper nibble
	    7		=>	'0',
	    6		=>	control_ctrl(49),
	    5		=>	control_ctrl(48),
	    4		=>	control_ctrl(47),

			-- Co-processor id in byte 0 lower nibble
	    3		=>	'0',
	    2		=>	control_ctrl(46),
	    1		=>	control_ctrl(45),
	    0		=>	control_ctrl(44)
	  );

	-- CPU ALU's inputs in words 2 and 3
	slv_word_2	<= control_curr_PC;
	slv_word_3	<= control_imm;

	-- CPU Co-processors' outputs in words 4 to 11
	slv_word_4	<= coprocessor_0_result;
	slv_word_5	<= coprocessor_1_result;
	slv_word_6	<= coprocessor_2_result;
	slv_word_7	<= coprocessor_3_result;
	slv_word_8	<= coprocessor_4_result;
	slv_word_9	<= coprocessor_5_result;
	slv_word_10	<= coprocessor_6_result;
	slv_word_11	<= coprocessor_7_result;

	-- CPU ALU's outputs in words 12 and 13
	slv_word_12	<= alu_result;
	slv_word_13	<= alu_addr;

	-- CPU Regfile's output and controls in words 14 to 16
	slv_word_14	<= (
	    -- Regfile write back controls in byte 3 upper nibble
	    31	=>	'0',
			-- force write access and force rd=r0
	    30	=>	control_ctrl(17),
			-- write back enable
	    29	=>	control_ctrl(16),
			-- input source select lsb (0=MEM, 1=ALU)
	    28	=>	control_ctrl( 0),

	    -- Regfile comparism results in byte 3 lower nibble
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	regfile_compare( 1),
	    24	=>	regfile_compare( 0),

	    -- Destination Reg addr in byte 2
	    23	=>	'0',
	    22	=>	'0',
	    21	=>	'0',
	    20	=>	control_ctrl(15),
	    19	=>	control_ctrl(14),
	    18	=>	control_ctrl(13),
	    17	=>	control_ctrl(12),
	    16	=>	control_ctrl(11),

	    -- Source 2 Reg addr in byte 1
	    15	=>	'0',
	    14	=>	'0',
	    13	=>	'0',
	    12	=>	control_ctrl(10),
	    11	=>	control_ctrl( 9),
	    10	=>	control_ctrl( 8),
	    9		=>	control_ctrl( 7),
	    8		=>	control_ctrl( 6),

	    -- Source 1 Reg addr in byte 0
	    7 	=>	'0',
	    6 	=>	'0',
	    5 	=>	'0',
	    4		=>	control_ctrl( 5),
	    3		=>	control_ctrl( 4),
	    2		=>	control_ctrl( 3),
	    1		=>	control_ctrl( 2),
	    0		=>	control_ctrl( 1)
	  );
	slv_word_15	<= regfile_read_0;
	slv_word_16	<= regfile_read_1;

	-- CPU Bus control's outputs and controls in words 17 to 21
	slv_word_17	<= (
			-- Data bus outputs in byte 3
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	bus_store_misaligned,
	    28	=>	bus_store_bus_error,
	    27	=>	bus_load_misaligned,
	    26	=>	bus_load_bus_error,
	    25	=>	bus_excl_state,
	    24	=>	bus_data_wait,

			-- Data bus controls in bytes 1 to 2
	    23	=>	'0',
	    22	=>	'0',
	    21	=>	'0',
			-- evaluate atomic/exclusive lock (SC operation)
	    20	=>	control_ctrl(43),
			-- remove atomic/exclusive access
	    19	=>	control_ctrl(42),
			-- make atomic/exclusive access lock
	    18	=>	control_ctrl(41),
			-- executed fencei operation
	    17	=>	control_ctrl(40),
			-- executed fence operation
	    16	=>	control_ctrl(39),
			-- is unsigned load
	    15	=>	control_ctrl(36),
			-- memory data input register write enable
	    14	=>	control_ctrl(35),
			-- memory address and data output register write enable
	    13	=>	control_ctrl(34),
			-- transfer size
	    12	=>	control_ctrl(30),
	    11	=>	control_ctrl(29),
			-- acknowledge data access bus exceptions
	    10	=>	control_ctrl(38),
			-- write data request
	    9		=>	control_ctrl(32),
			-- read data request
	    8		=>	control_ctrl(31),

			-- Instruct bus outputs in byte 0 upper nibble
	    7		=>	'0',
	    6		=>	bus_instr_misaligned,
	    5		=>	bus_instr_bus_error,
			4		=>	bus_instr_wait,

			-- Instruct bus controls in byte 0 lower nibble
	    3		=>	'0',
	    2		=>	'0',
			-- acknowledge instruction fetch bus exceptions
	    1		=>	control_ctrl(37),
			-- instruction fetch request
	    0		=>	control_ctrl(33)
	  );
	slv_word_18	<= control_fetch_PC;
	slv_word_19	<= bus_instr;
	slv_word_20	<= bus_data_addr;
	slv_word_21	<= bus_read_data;

	-- Instruction Bus in words 22 to 31
	slv_word_22	<= (
		-- external_bus signals in bits 20 to 31
	    31	=>	keeper_bus_err,
	    30	=>	external_bus_err_in,
	    29	=>	external_bus_byte_enable(3),
	    28	=>	external_bus_byte_enable(2),
	    27	=>	external_bus_byte_enable(1),
	    26	=>	external_bus_byte_enable(0),
	    25	=>	'0',
	    24	=>	external_bus_err_ored,
	    23	=>	external_bus_ack,
	    22	=>	external_bus_lock,
	    21	=>	external_bus_write_enable,
	    20	=>	external_bus_read_enable,

			-- data_bus signals in bits 10 to 19
			19	=>	data_bus_byte_enable(3),
			18	=>	data_bus_byte_enable(2),
			17	=>	data_bus_byte_enable(1),
			16	=>	data_bus_byte_enable(0),
	    15	=>	data_bus_fence,
	    14	=>	data_bus_err,
	    13	=>	data_bus_ack,
	    12	=>	data_bus_lock,
			11	=>	data_bus_write_enable,
			10	=>	data_bus_read_enable,

			-- Instr_bus signals in bits 0 to 9
			9		=>	instr_bus_byte_enable(3),
	    8		=>	instr_bus_byte_enable(2),
			7		=>	instr_bus_byte_enable(1),
			6		=>	instr_bus_byte_enable(0),
	    5		=>	instr_bus_fence,
	    4		=>	instr_bus_err,
	    3		=>	instr_bus_ack,
	    2		=>	instr_bus_lock,
	    1		=>	instr_bus_write_enable,
	    0		=>	instr_bus_read_enable
	  );
	slv_word_23	<= instr_bus_addr;
	slv_word_24	<= instr_bus_read_data;
	slv_word_25	<= instr_bus_write_data;
	slv_word_26	<= data_bus_addr;
	slv_word_27	<= data_bus_read_data;
	slv_word_28	<= data_bus_write_data;
	slv_word_29	<= external_bus_addr;
	slv_word_30	<= external_bus_read_data;
	slv_word_31	<= external_bus_write_data;

	-- Wishbone Bus in words 32 to 35
	slv_word_32	<= (
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=>	'0',
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	'0',
	    24	=>	'0',

	    23	=>	'0',
	    22	=>	'0',
	    21	=>	'0',
	    20	=>	'0',
	    19	=>	'0',
	    18	=>	'0',
	    17	=>	'0',
	    16	=>	'0',

			-- wishbone byte_sel in byte 1 upper nibble
	    15	=>	wishbone_byte_sel(3),
	    14	=>	wishbone_byte_sel(2),
	    13	=>	wishbone_byte_sel(1),
	    12	=>	wishbone_byte_sel(0),

			-- wishbone tag in byte 1 upper nibble
	    11	=>	'0',
	    10	=>	wishbone_tag(2),
	    9		=>	wishbone_tag(1),
	    8		=>	wishbone_tag(0),

			-- wishbone signal bit signals in byte 0
	    7		=>	'0',
	    6		=>	'0',
	    5		=>	wishbone_err,
	    4		=>	wishbone_ack,
	    3		=>	wishbone_lock,
	    2		=>	wishbone_cycle,
	    1		=>	wishbone_strobe,
	    0		=>	wishbone_read_write
	  );
	slv_word_33	<= wishbone_addr;
	slv_word_34	<= wishbone_read_data;
	slv_word_35	<= wishbone_write_data;

	-- NEO axi4lite Bus in words 36 to 40
	slv_word_36	<= (
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=>	'0',
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	'0',
	    24	=>	'0',
	    23	=>	'0',

			-- Write responce channal signals bits 5 to 8
	    22	=>	NEORV_axi_bresp(0),
	    21	=>	NEORV_axi_bresp(0),
	    20	=>	NEORV_axi_bvalid,
	    19	=>	NEORV_axi_bready,

			-- Write data channal signals bits 5 to 8
	    18	=>	NEORV_axi_wstrb(2),
	    17	=>	NEORV_axi_wstrb(1),
	    16	=>	NEORV_axi_wstrb(0),
	    15	=>	NEORV_axi_wvalid,
	    14	=>	NEORV_axi_wready,

			-- Write Address channal signals bits 5 to 8
	    13	=>	NEORV_axi_awprot(2),
	    12	=>	NEORV_axi_awprot(1),
	    11	=>	NEORV_axi_awprot(0),
	    10	=>	NEORV_axi_awvalid,
	    9		=>	NEORV_axi_awready,

			-- Read data channal signals bits 5 to 8
	    8		=>	NEORV_axi_rresp(1),
	    7		=>	NEORV_axi_rresp(0),
	    6		=>	NEORV_axi_rvalid,
	    5		=>	NEORV_axi_rready,

			-- Read Address channal signals bits 0 to 4
	    4		=>	NEORV_axi_arprot(2),
	    3		=>	NEORV_axi_arprot(1),
	    2		=>	NEORV_axi_arprot(0),
	    1		=>	NEORV_axi_arvalid,
	    0		=>	NEORV_axi_arready
	  );
	slv_word_37	<= NEORV_axi_araddr;
	slv_word_38	<= NEORV_axi_rdata;
	slv_word_39	<= NEORV_axi_awaddr;
	slv_word_40	<= NEORV_axi_wdata;

	-- BRAM axi4lite Bus in words 41 to 45
	slv_word_41	<= (
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=>	'0',
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	'0',
	    24	=>	'0',
	    23	=>	'0',

			-- Write responce channal signals bits 5 to 8
	    22	=>	BRAM_axi_bresp(0),
	    21	=>	BRAM_axi_bresp(0),
	    20	=>	BRAM_axi_bvalid,
	    19	=>	BRAM_axi_bready,

			-- Write data channal signals bits 5 to 8
	    18	=>	BRAM_axi_wstrb(2),
	    17	=>	BRAM_axi_wstrb(1),
	    16	=>	BRAM_axi_wstrb(0),
	    15	=>	BRAM_axi_wvalid,
	    14	=>	BRAM_axi_wready,

			-- Write Address channal signals bits 5 to 8
	    13	=>	BRAM_axi_awprot(2),
	    12	=>	BRAM_axi_awprot(1),
	    11	=>	BRAM_axi_awprot(0),
	    10	=>	BRAM_axi_awvalid,
	    9		=>	BRAM_axi_awready,

			-- Read data channal signals bits 5 to 8
	    8		=>	BRAM_axi_rresp(1),
	    7		=>	BRAM_axi_rresp(0),
	    6		=>	BRAM_axi_rvalid,
	    5		=>	BRAM_axi_rready,

			-- Read Address channal signals bits 0 to 4
	    4		=>	BRAM_axi_arprot(2),
	    3		=>	BRAM_axi_arprot(1),
	    2		=>	BRAM_axi_arprot(0),
	    1		=>	BRAM_axi_arvalid,
	    0		=>	BRAM_axi_arready
	  );
	slv_word_42	<= BRAM_axi_araddr;
	slv_word_43	<= BRAM_axi_rdata;
	slv_word_44	<= BRAM_axi_awaddr;
	slv_word_45	<= BRAM_axi_wdata;

	-- BAM port in words 46 to 49
	slv_word_46	<= (
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=> 	'0',
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	'0',
	    24	=>	'0',

	    23	=>	'0',
	    22	=>	'0',
	    21	=>	'0',
	    20	=>	'0',
	    19	=>	'0',
	    18	=>	'0',
	    17	=>	'0',
	    16	=>	'0',

	    15	=>	'0',
	    14	=>	'0',
	    13	=>	'0',
	    12	=>	'0',
	    11	=>	'0',
	    10	=>	'0',
	    9		=>	'0',
	    8		=>	'0',

			-- BRAM Contorls
			7		=>	BRAM_write_enable(0),
			6		=>	BRAM_write_enable(0),
	    5		=>	BRAM_write_enable(0),
	    4		=>	BRAM_write_enable(0),
	    3		=>	'0',
	    2		=>	'0',
	    1		=>	'0',
	    0		=>	BRAM_enable
	  );
	slv_word_47	<= BRAM_addr;
	slv_word_48	<= BRAM_read_data;
	slv_word_49	<= BRAM_write_data;

	-- LED axi4lite Bus in words 50 to 54
	slv_word_50	<= (
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=>	'0',
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	'0',
	    24	=>	'0',
	    23	=>	'0',

			-- Write responce channal signals bits 5 to 8
	    22	=>	LEDs_axi_bresp(0),
	    21	=>	LEDs_axi_bresp(0),
	    20	=>	LEDs_axi_bvalid,
	    19	=>	LEDs_axi_bready,

			-- Write data channal signals bits 5 to 8
	    18	=>	LEDs_axi_wstrb(2),
	    17	=>	LEDs_axi_wstrb(1),
	    16	=>	LEDs_axi_wstrb(0),
	    15	=>	LEDs_axi_wvalid,
	    14	=>	LEDs_axi_wready,

			-- Write Address channal signals bits 5 to 8
	    13	=>	LEDs_axi_awprot(2),
	    12	=>	LEDs_axi_awprot(1),
	    11	=>	LEDs_axi_awprot(0),
	    10	=>	LEDs_axi_awvalid,
	    9		=>	LEDs_axi_awready,

			-- Read data channal signals bits 5 to 8
	    8		=>	LEDs_axi_rresp(1),
	    7		=>	LEDs_axi_rresp(0),
	    6		=>	LEDs_axi_rvalid,
	    5		=>	LEDs_axi_rready,

			-- Read Address channal signals bits 0 to 4
	    4		=>	LEDs_axi_arprot(2),
	    3		=>	LEDs_axi_arprot(1),
	    2		=>	LEDs_axi_arprot(0),
	    1		=>	LEDs_axi_arvalid,
	    0		=>	LEDs_axi_arready
	  );
	slv_word_51	<= LEDs_axi_araddr;
	slv_word_52	<= LEDs_axi_rdata;
	slv_word_53	<= LEDs_axi_awaddr;
	slv_word_54	<= LEDs_axi_wdata;

	-- buttons axi4lite Bus in words 55 to 59
	slv_word_55	<= (
	    31	=>	'0',
	    30	=>	'0',
	    29	=>	'0',
	    28	=>	'0',
	    27	=>	'0',
	    26	=>	'0',
	    25	=>	'0',
	    24	=>	'0',
	    23	=>	'0',

			-- Write responce channal signals bits 5 to 8
	    22	=>	buttons_axi_bresp(0),
	    21	=>	buttons_axi_bresp(0),
	    20	=>	buttons_axi_bvalid,
	    19	=>	buttons_axi_bready,

			-- Write data channal signals bits 5 to 8
	    18	=>	buttons_axi_wstrb(2),
	    17	=>	buttons_axi_wstrb(1),
	    16	=>	buttons_axi_wstrb(0),
	    15	=>	buttons_axi_wvalid,
	    14	=>	buttons_axi_wready,

			-- Write Address channal signals bits 5 to 8
	    13	=>	buttons_axi_awprot(2),
	    12	=>	buttons_axi_awprot(1),
	    11	=>	buttons_axi_awprot(0),
	    10	=>	buttons_axi_awvalid,
	    9		=>	buttons_axi_awready,

			-- Read data channal signals bits 5 to 8
	    8		=>	buttons_axi_rresp(1),
	    7		=>	buttons_axi_rresp(0),
	    6		=>	buttons_axi_rvalid,
	    5		=>	buttons_axi_rready,

			-- Read Address channal signals bits 0 to 4
	    4		=>	buttons_axi_arprot(2),
	    3		=>	buttons_axi_arprot(1),
	    2		=>	buttons_axi_arprot(0),
	    1		=>	buttons_axi_arvalid,
	    0		=>	buttons_axi_arready
	  );
	slv_word_56	<= buttons_axi_araddr;
	slv_word_57	<= buttons_axi_rdata;
	slv_word_58	<= buttons_axi_awaddr;
	slv_word_59	<= buttons_axi_wdata;

	slv_word_60	<= (others => '0');
	slv_word_61	<= (others => '0');
	slv_word_62	<= (others => '0');
	slv_word_63	<= (others => '0');

	-- User logic ends

end arch_imp;
