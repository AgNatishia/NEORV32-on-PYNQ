from pynq import GPIO
from pynq.overlay import Overlay

import ipywidgets as widgets

import pandas as pd

import time
import os

_stepper_controls = {
    "first_all"     : 0x00000001,
    "continous"     : 0x00000100,
    "clock_tick"    : 0x00010000,
    "clock_counter" : 0x00020000,
    "instr_tick"    : 0x01000000,
    "instr_counter" : 0x02000000,
    "PC_target"     : 0x04000000,
}

_stepper_regmap = {
    "controls"      : 0x0,
    "clock_counter" : 0x4,
    "instr_counter" : 0x8,
    "PC_target"     : 0xC
}

class overlay():
    def __init__(this):
        this.overlay = Overlay("/usr/local/lib/python3.6/dist-packages/NeoRV32OnPynq/rv32i_overlay.bit")

        this.core_reset = GPIO(GPIO.get_gpio_pin(0), 'out')
        this.BRAM = this.overlay.pynq_BRAM_controller
        this.stepper = this.overlay.cpu_clock_stepper
        this.signal_capture =  this.overlay.neo_signal_capture

    # Reset functions
    def _start_reset(this):
        this.core_reset.write(0) # 0 as reset is negtive logic

    def _end_reset(this):
        this.core_reset.write(1) # 1 as reset is negtive logic

    def _pulse_reset(this, pulse_time=0.005):
        this._start_reset()
        time.sleep(pulse_time)
        this._end_reset()

    # BRAM functions
    def _bram_load_program(this, filename, swap_endianess=False):
        # Read bin file in memory
        BRAM_data = []
        if not filename.endswith(".bin"):
            filename += ".bin"
        with open(filename, "rb") as f:
            raw_bytes = raw_bytes = f.read(4)
            while raw_bytes != b"":
                if swap_endianess:
                    BRAM_data.append(
                        sum([
                            raw_bytes[0] << 3*8,
                            raw_bytes[1] << 2*8,
                            raw_bytes[2] << 1*8,
                            raw_bytes[3] << 0*8,
                        ])
                    )
                else:
                    BRAM_data.append(
                        sum([
                            raw_bytes[3] << 3*8,
                            raw_bytes[2] << 2*8,
                            raw_bytes[1] << 1*8,
                            raw_bytes[0] << 0*8,
                        ])
                    )
                raw_bytes = f.read(4)

        # Put NEO into reset to prevert it accesses BRAM while program is being overwriten
        this._start_reset()

        # Write Program
        for addr, word in enumerate(BRAM_data):
            this.BRAM.write(4*addr, word)

        # Let NEO out of teset to start running the now program
        this._end_reset()

    # Stepper functions
    def _stepper_write_registor(this, registor, value):
        this.stepper.write(registor, value)

    def _stepper_read_registor(this, registor):
        return this.stepper.read(registor)

    # Capture Harness functuons
    def _capharness_read_word(this, word):
        return this.signal_capture.read(4*word)

    # GUI functions
    def load_program(this, program_folder=None, folder_per_program = True):
        # Handle default program folder
        if program_folder == None:
            program_folder  = os.path.join(".", "programs")

        # Check program_folder is a valid path
        if not isinstance(program_folder, str):
            raise ValueError("program_folder must be a string")
        elif not os.path.isdir(program_folder):
            raise ValueError("program_folder, %s, doesn't point to a folder"%(program_folder, ))

        def scan_for_programs():
            # Find all programs within program folder
            programs = []
            if folder_per_program:
                for sub_name in os.listdir(program_folder):
                    sub_path = os.path.join(program_folder, sub_name)
                    program_name = sub_name + ".bin"
                    program_path = os.path.join(sub_path, program_name)
                    if os.path.isdir(sub_path) and program_name in os.listdir(sub_path) and os.path.isfile(program_path):
                        programs.append(sub_name)
            else:
                for sub_name in os.listdir(program_folder):
                    program_name = sub_name + ".bin"
                    if os.path.isfile(program_name):
                        programs.append(sub_name)
            return programs

        # Build GUI
        gui_scan_button = widgets.Button(
            description="Refresh programs",
            tooltip="Rescans the program folder for changed and updates the program select"
        )
        gui_program_dropdown = widgets.Dropdown(
            options=scan_for_programs(),
            tooltip="Selexts the program to be loaded the next turn the 'Load Program' button is pressed"
        )
        gui_write_button = widgets.Button(
            description="Load Program",
            tooltip="Loads the program selected in the dropdown into the overlay's BRAM"
        )
        gui_loaded_label = widgets.Label(
            value="Last Loaded: ",
            tooltip="Shows the last program loaded, ie the program currenlly running on the overlay"
        )

        gui_label = widgets.Label("Program Select:")
        gui_lower_row = widgets.HBox([gui_scan_button, gui_program_dropdown, gui_write_button, gui_loaded_label])
        gui = widgets.VBox([gui_label, gui_lower_row])

        # Functions to handle interacting with the widgets, to load a program into the overlay's BRAM
        def gui_write_button_click(_):
            # Get selected program
            program = gui_program_dropdown.value

            # Load selected program
            if folder_per_program:
                this._bram_load_program(os.path.join(program_folder, program, program))
            else:
                this._bram_load_program(os.path.join(program_folder, program))

            # Update last Loaded
            gui_loaded_label.value = "Last Loaded: %s.bin"%(program, )
        def gui_scan_button_click(_):
            programs = scan_for_programs()
            gui_program_dropdown.options=programs
            gui_program_dropdown.value=programs[0]


        # Bind gui_write_button_click to button's on_click hook
        gui_write_button.on_click(gui_write_button_click)
        gui_scan_button.on_click(gui_scan_button_click)

        return gui

    def execution_control(this):
        # Rules sections
        # Clock counter rule
        clock_counter_enable_label = widgets.Label(
            value="Clock Counter enable:",
            tooltip="The Clock Count Rule is fulfilled after the overlay has run for a given number of clock cycles."
        )
        clock_counter_enable = widgets.Checkbox(
            tooltip="Run the overlay for number of clock cyxles specisied by the 'Clock Count Rule Value' field",
            value=False
        )
        clock_counter_value_label = widgets.Label(
            value="Run for:",
            tooltip="The Clock Count Rule is fulfilled after the overlay has run for a given number of clock cycles."
        )
        clock_counter_value = widgets.Text(
            placeholder="Enter an unsigned number in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)",
            tooltip="The number of clock cyles the Clock Count Rule, if enabled by 'Clock Count Rule Enable' field, will be fulfilled after. The value can be any 32 bit unsigned number larger than 0, and can be entered in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)."
        )

        # Instr counter rule
        instr_counter_enable_label =  widgets.Label(
            value="instruction Count Enable:",
            tooltip="The instruction Count Rule is fulfilled after the overlay has executed a given number of inctructions."
        )
        instr_counter_enable = widgets.Checkbox(
            tooltip="Run the overlay for number of instructions specisied by the 'instr Count Rule Value' field",
            value=False
        )
        instr_counter_value_label = widgets.Label(
            value="Run For",
            tooltip="The instruction Count Rule is fulfilled after the overlay has executed a given number of inctructions."
        )
        instr_counter_value = widgets.Text(
            placeholder="Enter an unsigned number in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)",
            tooltip="The number of instructions the instr Count Rule, if enabled by 'instr Count Rule Enable' field, will be fulfilled after. The value can be any 32 bit unsigned number larger than 0, and can be entered in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)."
        )

        # PC target rule
        PC_targett_enable_label = widgets.Label(
            value="PC Target Enable:",
            tooltip="The PC Target Rule is fulfilled after the overlay reaches a given PC value."
        )
        PC_target_enable = widgets.Checkbox(
            tooltip="Run the overlay until the program counter matches the value specisied by the 'PC Target Rule Value' field",
            value=False,
        )
        PC_targett_value_label = widgets.Label(
            value="Target Value:",
            tooltip="The PC Target Rule is fulfilled after the overlay reaches a given PC value."
        )
        PC_target_value = widgets.Text(
            placeholder="Enter an unsigned number in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)",
            tooltip="The PC value the PC Target Rule, if enabled by 'PC Target Rule Enable' field, will be fulfilled on reaching. The value can be any 32 bit unsigned number larger than 0, and can be entered in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)."
        )

        # Pack Rules together
        rule_enable_labels = widgets.VBox([clock_counter_enable_label, instr_counter_enable_label, PC_targett_enable_label])
        rule_enables = widgets.VBox([clock_counter_enable, instr_counter_enable, PC_target_enable])
        rule_value_labels = widgets.VBox([clock_counter_value_label, instr_counter_value_label, PC_targett_value_label])
        rule_values = widgets.VBox([clock_counter_value, instr_counter_value, PC_target_value])
        gui_rules = widgets.HBox([rule_enable_labels, rule_enables, rule_value_labels, rule_values])

        # GUI Buttons
        step_clock_button = widgets.Button(
            description="Step Clock",
            tooltip="Run the overlay for one clock cycle"
        )
        def step_clock_button_click(_):
            this._stepper_write_registor(_stepper_regmap["controls"], _stepper_controls["clock_tick"])
        step_clock_button.on_click(step_clock_button_click)

        step_instruction_button = widgets.Button(
            description="Step Instruction",
            tooltip="Run the overlay until the next instruction"
        )
        def step_instruction_button_click(_):
            this._stepper_write_registor(_stepper_regmap["controls"], _stepper_controls["instr_tick"])
        step_instruction_button.on_click(step_instruction_button_click)

        run_stop_button  = widgets.Button(
            description="Run/Stop",
            tooltip="".join([
                "It any rules are enabled the overlay until the first enabled rule is fulfiled\n",
                "If no rule are enabled the pverlay will be run continousally; ",
                "this continous run can but stopped by clink once more, ",
                "or overwriten by running rules or one of the steps"
            ])
        )
        def run_stop_button_click(_):
            # IF any rule are enabled, run those rules
            if any([clock_counter_enable.value, instr_counter_enable.value, PC_target_enable.value]):
                # Stop the overlay in order to write counters and target
                this._stepper_write_registor(_stepper_regmap["controls"], 0)

                # Build controls and write registors
                controls = 0
                if clock_counter_enable.value == True:
                    reg_value = textboz_to_int(clock_counter_value.value)
                    if reg_value != 0:
                        controls |= _stepper_controls["clock_counter"]
                        this._stepper_write_registor(_stepper_regmap["clock_counter"], reg_value)
                if instr_counter_enable.value == True:
                    reg_value = textboz_to_int(instr_counter_value.value)
                    if reg_value != 0:
                        controls |= _stepper_controls["instr_counter"]
                        this._stepper_write_registor(_stepper_regmap["instr_counter"], reg_value)
                if PC_target_enable.value == True:
                    controls |= _stepper_controls["PC_target"]
                    reg_value = textboz_to_int(PC_target_value.value) + 0x40000000
                    this._stepper_write_registor(_stepper_regmap["PC_target"], reg_value)

                # Write controls to the stepper
                this._stepper_write_registor(_stepper_regmap["controls"], controls)
            # Else handle Run/Stop behavout
            else:
                # Read stepper controls to stop is run or stop
                stepper_state = this._stepper_read_registor(_stepper_regmap["controls"])

                # Run if stopped
                if stepper_state & _stepper_controls["continous"] == 0:
                    this._stepper_write_registor(_stepper_regmap["controls"], _stepper_controls["continous"])
                # Stop if running
                else:
                    this._stepper_write_registor(_stepper_regmap["controls"], 0)
        run_stop_button.on_click(run_stop_button_click)

        reset_button  = widgets.Button(
            description="Reset",
            tooltip="Resets the program back to the start"
        )
        def reset_button_click(_):
            this._stepper_write_registor(_stepper_regmap["controls"], 0)
            this._pulse_reset()
        reset_button.on_click(reset_button_click)

        # Pack buttons and gui
        gui_label = widgets.Label("Execution Control:")
        gui_buttons = widgets.HBox([step_clock_button, step_instruction_button, run_stop_button, reset_button])
        gui = widgets.VBox([gui_label, gui_rules, gui_buttons])

        return gui

    def show_internals(this):
        # Names of key capture words
        ALU_bundle      =  0
        funct_bundle    =  1
        curr_PC         =  2
        IMM             =  3
        co_pro_0_result =  4
        co_pro_1_result =  5
        co_pro_2_result =  6
        co_pro_3_result =  7
        co_pro_4_result =  8
        co_pro_5_result =  9
        co_pro_6_result = 10
        co_pro_7_result = 11
        ALU_result      = 12
        ALU_addr        = 13
        regfile_bundle  = 14
        regfile_rs1_out = 15
        regfile_rs2_out = 16
        bus_con_bundle  = 17
        fetch_PC        = 18
        bus_instr       = 19
        bus_data_addr   = 20
        bus_read_data   = 21
        buses_bundle    = 22
        wb_bundle       = 32
        wb_addr         = 33
        wb_read_data    = 34
        wb_write_data   = 35
        BRAM_bundle     = 50
        BRAM_addr       = 51
        BRAM_read_data  = 52
        BRAM_write_data = 53


        # Each *_bus_word is used to access 3 words
        # The expected order is addr, read data, and write data
        instr_bus_words = 22
        data_bus_words  = 25
        muxed_bus_words = 28

        # Each *_axi_words is used to access 5 words
        # The expected order is bundle, araddr, rdata, awaddr. and wdata
        # Bundle startinging at bit 0 (multibit signals width shown in brackets after name) :
        # arready. arvalid, arprot(3), rready, rvalid, rresp(2), awready, awvalid, awprot(3)
        # wready, wvalid, wstrb(3), bready, bvalid, and bresp(2)
        neo_axi_words    = 36
        BRAM_axi_words   = 31
        LED_axi_words    = 50
        button_axi_words = 55

        # Bundle offsets for internal buses
        instr_bundle_offset =  0
        data_bundle_offset  = 10
        muxed_bundle_offset = 20

        RISCV_reg_names = [
            "Zero",     "ra",   "sp",   "gp",   "tp",   "t0",   "t1",   "t1",
            "s0/fp",    "s1",   "a0",   "a1",   "a2",   "a3",   "a4",   "a5",
            "a6",       "a7",   "s2",   "s3",   "s4",   "s5",   "s6",   "s7",
            "s8",       "s9",   "s10",  "s11",  "t3",   "t4",   "t5",   "t6",
        ]

        # Reuse table generate functions
        def textboz_to_int(text):
            if len(text) != 0:
                if text.startswith(("0b", "0B")):
                    value = int(text, 2)
                elif text.startswith(("0x", "0X")):
                    value = int(text, 16)
                else:
                    value = int(text, 10)
            else:
                raise ValueError("No text given")

            return value

        def generate_internal_bus_table(capture_data, bundle_offset, bus_words):
            read    = (capture_data[buses_bundle] >> (bundle_offset + 0)) & 0x00000001
            write   = (capture_data[buses_bundle] >> (bundle_offset + 1)) & 0x00000001
            lock    = (capture_data[buses_bundle] >> (bundle_offset + 2)) & 0x00000001
            ack     = (capture_data[buses_bundle] >> (bundle_offset + 3)) & 0x00000001
            err     = (capture_data[buses_bundle] >> (bundle_offset + 4)) & 0x00000001
            fence   = (capture_data[buses_bundle] >> (bundle_offset + 5)) & 0x00000001
            bytes   = (capture_data[buses_bundle] >> (bundle_offset + 6)) & 0x0000000F

            return  pd.DataFrame({
                "Signal": [
                    "Addr",

                    "Read Enable",
                    "Read Data",

                    "Write Enable",
                    "Write Data",

                    "Ack",
                    "Error",
                    "Bytes",
                    "Lock",
                    "Fence",
                ],
                "Value": [
                    hex(capture_data[bus_words + 0])[2:].zfill(8),

                    hex(read)[2:].zfill(1),
                    hex(capture_data[bus_words + 2])[2:].zfill(8),

                    hex(write)[2:].zfill(1),
                    hex(capture_data[bus_words + 3])[2:].zfill(8),

                    hex(ack)[2:].zfill(1),
                    hex(err)[2:].zfill(1),
                    hex(bytes)[2:].zfill(1),
                    hex(lock)[2:].zfill(1),
                    hex(fence)[2:].zfill(1),
                ]
            })

        def generate_axi_table(capture_data, base_word):
            arready = (capture_data[base_word] >>  0) & 0x00000001
            arvalid = (capture_data[base_word] >>  1) & 0x00000001
            arprot  = (capture_data[base_word] >>  2) & 0x00000007

            rready  = (capture_data[base_word] >>  5) & 0x00000001
            rvalid  = (capture_data[base_word] >>  6) & 0x00000001
            rresp   = (capture_data[base_word] >>  7) & 0x00000003

            awready = (capture_data[base_word] >>  9) & 0x00000001
            awvalid = (capture_data[base_word] >> 10) & 0x00000001
            awprot  = (capture_data[base_word] >> 11) & 0x00000007

            wready  = (capture_data[base_word] >> 14) & 0x00000001
            wvalid  = (capture_data[base_word] >> 15) & 0x00000001
            wstrb   = (capture_data[base_word] >> 16) & 0x00000007

            bready  = (capture_data[base_word] >> 19) & 0x00000001
            bvalid  = (capture_data[base_word] >> 20) & 0x00000001
            bresp   = (capture_data[base_word] >> 21) & 0x00000003

            return  pd.DataFrame({
                "Signal": [
                    "araddr",
                    "arprot",
                    "arready",
                    "arvalid",

                    "rdata",
                    "rresp",
                    "rready",
                    "rvalid",

                    "awaddr",
                    "awprot",
                    "awready",
                    "awvalid",

                    "wdata",
                    "wstrb",
                    "wready",
                    "wvalid",

                    "bresp",
                    "bready",
                    "bvalid",
                ],
                "Value": [
                    hex(capture_data[base_word + 1])[2:].zfill(8),
                    hex(arprot)[2:].zfill(1),
                    hex(arready)[2:].zfill(1),
                    hex(arvalid)[2:].zfill(1),

                    hex(capture_data[base_word + 2])[2:].zfill(8),
                    hex(rresp)[2:].zfill(1),
                    hex(rready)[2:].zfill(1),
                    hex(rvalid)[2:].zfill(1),

                    hex(capture_data[base_word + 3])[2:].zfill(8),
                    hex(awprot)[2:].zfill(1),
                    hex(awready)[2:].zfill(1),
                    hex(awvalid)[2:].zfill(1),

                    hex(capture_data[base_word + 4])[2:].zfill(8),
                    hex(wstrb)[2:].zfill(1),
                    hex(wready)[2:].zfill(1),
                    hex(wvalid)[2:].zfill(1),

                    hex(bresp)[2:].zfill(1),
                    hex(bready)[2:].zfill(1),
                    hex(bvalid)[2:].zfill(1),
                ]
            })

        # regfile section
        # regfile rs1 section
        def generate_regfile_rs1_addr_table(capture_data):
            addr_value = (capture_data[regfile_bundle] >>  0) & 0x0000001F
            return  pd.DataFrame({
                "Signal": [
                    "Addr",
                    "Reg",
                    "Output"
                ],
                "Value": [
                    hex(addr_value)[2:].zfill(2),
                    RISCV_reg_names[addr_value],
                    hex(capture_data[regfile_rs1_out])[2:].zfill(8),
                ]
            })
        regfile_rs1_label = widgets.Label("Source Register 1")
        regfile_rs1_addr_table = widgets.Output()
        regfile_rs1 = widgets.VBox([regfile_rs1_label, regfile_rs1_addr_table])

        # regfile rs2 section
        def generate_regfile_rs2_addr_table(capture_data):
            addr_value = (capture_data[regfile_bundle] >>  8) & 0x0000001F
            return  pd.DataFrame({
                "Signal": [
                    "Addr",
                    "Reg",
                    "Output"
                ],
                "Value": [
                    hex(addr_value)[2:].zfill(2),
                    RISCV_reg_names[addr_value],
                    hex(capture_data[regfile_rs2_out])[2:].zfill(8),
                ]
            })
        regfile_rs2_label = widgets.Label("Source Register 2")
        regfile_rs2_addr_table = widgets.Output()
        regfile_rs2 = widgets.VBox([regfile_rs2_label, regfile_rs2_addr_table])

        # regfile rs compare section
        def generate_regfile_cmp_results_table(capture_data):
            compare_value = (capture_data[regfile_bundle] >> 24) & 0x00000003
            return  pd.DataFrame({
                "Signal": [
                    "Comparism",
                ],
                "Value": [
                    hex(compare_value)[2:].zfill(1),
                ]
            })
        regfile_cmp_label = widgets.Label("Source Register Compare")
        regfile_cmp_results_table = widgets.Output()
        regfile_cmp = widgets.VBox([regfile_cmp_label, regfile_cmp_results_table])

        # regfile rd section
        def generate_regfile_rd_addr_table(capture_data):
            addr_value = (capture_data[regfile_bundle] >> 16) & 0x0000001F
            return  pd.DataFrame({
                "Signal": [
                    "Addr",
                    "Reg",

                ],
                "Value": [
                    hex(addr_value)[2:].zfill(2),
                    RISCV_reg_names[addr_value],
                ]
            })
        def generate_regfile_rd_input_table(capture_data):
            input_sel = (capture_data[regfile_bundle] >> 28)  & 0x0000001
            return  pd.DataFrame({
                "Signal": [
                    "Mem in",
                    "ALU in",
                    "In Sel"
                ],
                "Value": [
                    hex(capture_data[bus_read_data])[2:].zfill(8),
                    hex(capture_data[ALU_result])[2:].zfill(8),
                    ["Mem", "ALU"][input_sel]
                ]
            })
        def generate_regfile_rd_control_table(capture_data):
            enable_bit = (capture_data[regfile_bundle] >> 29) & 0x0000001
            forse_bit  = (capture_data[regfile_bundle] >> 30) & 0x0000001
            return  pd.DataFrame({
                "Signal": [
                    "Enable",
                    "Force 0",
                ],
                "Value": [
                    hex(enable_bit)[2:],
                    hex(forse_bit)[2:],
                ]
            })
        regfile_rd_label = widgets.Label("Writeback")
        regfile_rd_addr_table = widgets.Output()
        regfile_rd_input_table = widgets.Output()
        regfile_rd_control_table = widgets.Output()
        regfile_rd_tables = widgets.HBox([regfile_rd_addr_table, regfile_rd_input_table, regfile_rd_control_table])
        regfile_rd = widgets.VBox([regfile_rd_label, regfile_rd_tables])

        regfile_section_label = widgets.Label("Regfile")
        regfile_sources = widgets.HBox([regfile_rs1, regfile_rs2, regfile_cmp])
        regfile_section = widgets.VBox([regfile_section_label, regfile_sources, regfile_rd])

        # ALU section
        # ALU operand A section
        def generate_ALU_opA_input_table(capture_data):
            input_sel = (capture_data[ALU_bundle] >>  0) & 0x0000001
            return  pd.DataFrame({
                "Signal": [
                    "RS1 in",
                    "PC in",
                    "OpA Sel"
                ],
                "Value": [
                    hex(capture_data[regfile_rs1_out])[2:].zfill(8),
                    hex(capture_data[curr_PC])[2:].zfill(8),
                    ["RS1", "PC"][input_sel]
                ]
            })
        ALU_opA_label = widgets.Label("Operand A")
        ALU_opA_input_table = widgets.Output()
        ALU_opA_input = widgets.VBox([ALU_opA_label, ALU_opA_input_table])

        # ALU operand B section
        def generate_ALU_opB_input_table(capture_data):
            input_sel = (capture_data[ALU_bundle] >> 1) & 0x0000001
            return  pd.DataFrame({
                "Signal": [
                    "RS2 in",
                    "IMM in",
                    "OpB Sel"
                ],
                "Value": [
                    hex(capture_data[regfile_rs2_out])[2:].zfill(8),
                    hex(capture_data[IMM])[2:].zfill(8),
                    ["RS2", "IMM"][input_sel]
                ]
            })
        ALU_opB_label = widgets.Label("Operand A")
        ALU_opB_input_table = widgets.Output()
        ALU_opB_input = widgets.VBox([ALU_opB_label, ALU_opB_input_table])

        # ALU Control section
        def generate_ALU_controls_table(capture_data):
            unsigned    = (capture_data[ALU_bundle] >>  2) & 0x00000001
            arithmetic  = (capture_data[ALU_bundle] >>  3) & 0x00000001
            Logic       = (capture_data[ALU_bundle] >>  4) & 0x00000003
            Function    = (capture_data[ALU_bundle] >>  6) & 0x00000003
            Add_Sub     = (capture_data[ALU_bundle] >>  8) & 0x00000001
            Shift       = (capture_data[ALU_bundle] >>  9) & 0x00000001
            left_right  = (capture_data[ALU_bundle] >> 10) & 0x00000001
            return  pd.DataFrame({
                "Signal": [
                    "Unsigned",
                    "Arithmetic",
                    "Logic",
                    "Function",
                    "Add/Sub",
                    "Shift",
                    "left/right",
                ],
                "Value": [
                    hex(unsigned)[2:].zfill(1),
                    hex(arithmetic)[2:].zfill(1),
                    hex(Logic)[2:].zfill(1),
                    hex(Function)[2:].zfill(1),
                    hex(Add_Sub)[2:].zfill(1),
                    hex(Shift)[2:].zfill(1),
                    hex(left_right)[2:].zfill(1),
                ]
            })
        ALU_controls_label = widgets.Label("Control Signals")
        ALU_controls_table = widgets.Output()
        ALU_controls = widgets.VBox([ALU_controls_label, ALU_controls_table])

        # ALU results section
        def generate_ALU_results_table(capture_data):
            return  pd.DataFrame({
                "Signal": [
                    "Result",
                    "Address",
                ],
                "Value": [
                    hex(capture_data[ALU_result])[2:].zfill(8),
                    hex(capture_data[ALU_addr])[2:].zfill(8),
                ]
            })
        ALU_results_label = widgets.Label("Results")
        ALU_results_table = widgets.Output()
        ALU_results = widgets.VBox([ALU_results_label, ALU_results_table])

        ALU_section_label = widgets.Label("ALU")
        ALU_signals = widgets.HBox([ALU_opA_input, ALU_opB_input, ALU_controls, ALU_results])
        ALU_section = widgets.VBox([ALU_section_label, ALU_signals])

        # Coprocessor section
        # Decoded funct section
        def generate_copro_funct_table(capture_data):
            funct3  = (capture_data[funct_bundle] >> 4) & 0x00000007
            funct7  = (capture_data[funct_bundle] >> 4) & 0x0000007F
            funct12 = (capture_data[funct_bundle] >> 4) & 0x00000FFF
            return  pd.DataFrame({
                "Signal": [
                    "funct3",
                    "funct7",
                    "funct12",
                ],
                "Value": [
                    hex(funct3)[2:].zfill(1),
                    hex(funct7)[2:].zfill(2),
                    hex(funct12)[2:].zfill(3),
                ]
            })
        copro_funct_label = widgets.Label("Funct bits")
        copro_funct_table = widgets.Output()
        copro_funct = widgets.VBox([copro_funct_label, copro_funct_table])

        # Coprocessor ALU interface section
        def generate_copro_ALU_interface_table(capture_data):
            addr  = (capture_data[funct_bundle] >> 0) & 0x00000007
            start = (capture_data[ALU_bundle] >> 16) & 0x000000FF
            valid = (capture_data[ALU_bundle] >> 24) & 0x000000FF
            return  pd.DataFrame({
                "Signal": [
                    "Addr",
                    "start",
                    "valid",
                ],
                "Value": [
                    hex(addr)[2:].zfill(1),
                    hex(start)[2:].zfill(2),
                    hex(valid)[2:].zfill(2),
                ]
            })
        copro_ALU_interface_label = widgets.Label("ALU Internface")
        copro_ALU_interface_table = widgets.Output()
        copro_ALU_interface = widgets.VBox([copro_ALU_interface_label, copro_ALU_interface_table])

        # Coprocessor results section
        def generate_copro_results_table(capture_data):
            return  pd.DataFrame({
                "Signal": [
                    "Cp 0",
                    "Cp 1",
                    "Cp 2",
                    "Cp 3",
                    "Cp 4",
                    "Cp 5",
                    "Cp 6",
                    "Cp 7",
                ],
                "Value": [
                    hex(capture_data[co_pro_0_result])[2:].zfill(8),
                    hex(capture_data[co_pro_1_result])[2:].zfill(8),
                    hex(capture_data[co_pro_2_result])[2:].zfill(8),
                    hex(capture_data[co_pro_3_result])[2:].zfill(8),
                    hex(capture_data[co_pro_4_result])[2:].zfill(8),
                    hex(capture_data[co_pro_5_result])[2:].zfill(8),
                    hex(capture_data[co_pro_6_result])[2:].zfill(8),
                    hex(capture_data[co_pro_7_result])[2:].zfill(8),
                ]
            })
        copro_results_label = widgets.Label("Results")
        copro_results_table = widgets.Output()
        copro_results = widgets.VBox([copro_results_label, copro_results_table])

        copro_section_label = widgets.Label("Coprocessors")
        copro_columes = widgets.HBox([copro_funct, copro_ALU_interface, copro_results])
        copro__section = widgets.VBox([copro_section_label, copro_columes])

        # Bus control section
        # Bus instr section
        def generate_bus_instr_table(capture_data):
            fetch    = (capture_data[bus_con_bundle] >> 0) & 0x00000001
            ack      = (capture_data[bus_con_bundle] >> 1) & 0x00000001
            wait     = (capture_data[bus_con_bundle] >> 4) & 0x00000001
            error    = (capture_data[bus_con_bundle] >> 5) & 0x00000001
            misalign = (capture_data[bus_con_bundle] >> 6) & 0x00000001
            return  pd.DataFrame({
                "Signal": [
                    "Fetch",
                    "Wait",
                    "Error",
                    "Misalign",
                    "Ack Error",
                ],
                "Value": [
                    hex(fetch)[2:].zfill(1),
                    hex(wait)[2:].zfill(1),
                    hex(error)[2:].zfill(1),
                    hex(misalign)[2:].zfill(1),
                    hex(ack)[2:].zfill(1),
                ]
            })
        bus_instr_label = widgets.Label("Instr Fetch")
        bus_instr_table = widgets.Output()
        bus_instr = widgets.VBox([bus_instr_label, bus_instr_table])

        # Bus data section
        def generate_bus_data_table(capture_data):
            load            = (capture_data[bus_con_bundle] >>  8) & 0x00000001
            store           = (capture_data[bus_con_bundle] >>  9) & 0x00000001
            wait            = (capture_data[bus_con_bundle] >> 24) & 0x00000001
            load_error      = (capture_data[bus_con_bundle] >> 26) & 0x00000001
            load_misalign   = (capture_data[bus_con_bundle] >> 27) & 0x00000001
            store_error     = (capture_data[bus_con_bundle] >> 28) & 0x00000001
            store_misalign  = (capture_data[bus_con_bundle] >> 29) & 0x00000001
            ack             = (capture_data[bus_con_bundle] >> 10) & 0x00000001

            return  pd.DataFrame({
                "Signal": [
                    "Load",
                    "Store",
                    "Wait",
                    "Load Error",
                    "Load Misalign",
                    "Store Error",
                    "Store Misalign",
                    "Ack Error",
                ],
                "Value": [
                    hex(load)[2:].zfill(1),
                    hex(store)[2:].zfill(1),
                    hex(wait)[2:].zfill(1),
                    hex(load_error)[2:].zfill(1),
                    hex(load_misalign)[2:].zfill(1),
                    hex(store_error)[2:].zfill(1),
                    hex(store_misalign)[2:].zfill(1),
                    hex(ack)[2:].zfill(1),
                ]
            })
        bus_data_label = widgets.Label("Data Access")
        bus_data_table = widgets.Output()
        bus_data = widgets.VBox([bus_data_label, bus_data_table])

        # Bus control section
        def generate_bus_signals_table(capture_data):
            size        = (capture_data[bus_con_bundle] >> 11) & 0x00000003
            unsigned    = (capture_data[bus_con_bundle] >> 15) & 0x00000001
            fence       = (capture_data[bus_con_bundle] >> 16) & 0x00000001
            lock        = (capture_data[bus_con_bundle] >> 16) & 0x00000001
            unlock      = (capture_data[bus_con_bundle] >> 17) & 0x00000001
            atomic      = (capture_data[bus_con_bundle] >> 19) & 0x00000001

            return  pd.DataFrame({
                "Signal": [
                    "Size",
                    "Unsigned",
                    "Fenced",
                    "Lock",
                    "Unlock",
                    "Atomic"
                ],
                "Value": [
                    hex(size)[2:].zfill(1),
                    hex(unsigned)[2:].zfill(1),
                    hex(fence)[2:].zfill(1),
                    hex(lock)[2:].zfill(1),
                    hex(atomic)[2:].zfill(1),
                    hex(atomic)[2:].zfill(1),
                ]
            })
        bus_signals_label = widgets.Label("Control Signals")
        bus_signals_table = widgets.Output()
        bus_signals = widgets.VBox([bus_signals_label, bus_signals_table])

        bus_section_label = widgets.Label("Bus Control")
        bus_columes = widgets.HBox([bus_instr, bus_data, bus_signals])
        bus_section = widgets.VBox([bus_section_label, bus_columes])

        # Bus switch sections
        # Instruction Bus Section
        Instr_bus_label = widgets.Label("Instruction Bus")
        Instr_bus_table = widgets.Output()
        Instr_bus = widgets.VBox([Instr_bus_label, Instr_bus_table])

        # Data Bus Section
        data_bus_label = widgets.Label("Data Bus")
        data_bus_table = widgets.Output()
        data_bus = widgets.VBox([data_bus_label, data_bus_table])

        # Bus switch Section
        def generate_switch_controls_table(capture_data):
            keeper   = (capture_data[buses_bundle] >> 31) & 0x00000001
            external = (capture_data[buses_bundle] >> 20) & 0x00000001
            ored     = (capture_data[buses_bundle] >> 24) & 0x00000001

            return  pd.DataFrame({
                "Signal": [
                    "Keeper Error",
                    "External Error",
                    "ORed Error",
                ],
                "Value": [
                    hex(keeper)[2:].zfill(1),
                    hex(external)[2:].zfill(1),
                    hex(ored)[2:].zfill(1),
                ]
            })
        switch_controls_label = widgets.Label("Controls")
        switch_controls_table = widgets.Output()
        switch_controls = widgets.VBox([switch_controls_label, switch_controls_table])

        # Muxed Bus Section
        muxed_bus_label = widgets.Label("Muxed Bus")
        muxed_bus_table = widgets.Output()
        muxed_bus = widgets.VBox([muxed_bus_label, muxed_bus_table])

        switch_section_label = widgets.Label("Bus switch")
        switch_columes = widgets.HBox([Instr_bus, data_bus, switch_controls, muxed_bus])
        switch_section = widgets.VBox([switch_section_label, switch_columes])

        # External bus section
        # Wishbone
        def generate_wishbone_table(capture_data):
            read_write = (capture_data[wb_bundle] >>  0) & 0x00000001
            strobe     = (capture_data[wb_bundle] >>  1) & 0x00000001
            cycle      = (capture_data[wb_bundle] >>  2) & 0x00000001
            ack        = (capture_data[wb_bundle] >>  4) & 0x00000001
            err        = (capture_data[wb_bundle] >>  5) & 0x00000001
            lock       = (capture_data[wb_bundle] >>  3) & 0x00000001
            tag        = (capture_data[wb_bundle] >>  8) & 0x00000007
            bytes      = (capture_data[wb_bundle] >> 12) & 0x0000000F

            return  pd.DataFrame({
                "Signal": [
                    "Strobe",
                    "Cycle",

                    "Addr",
                    "Read/Write",
                    "Read Data",
                    "Write Data",

                    "Bytes",
                    "Tag",
                    "Lock",
                    "Ack",
                    "Error",
                ],
                "Value": [
                    hex(strobe)[2:].zfill(1),
                    hex(cycle)[2:].zfill(1),

                    hex(capture_data[wb_addr])[2:].zfill(8),
                    hex(read_write)[2:].zfill(1),
                    hex(capture_data[wb_read_data])[2:].zfill(8),
                    hex(capture_data[wb_write_data])[2:].zfill(8),

                    hex(bytes)[2:].zfill(1),
                    hex(tag)[2:].zfill(1),
                    hex(lock)[2:].zfill(1),
                    hex(ack)[2:].zfill(1),
                    hex(err)[2:].zfill(1),
                ]
            })
        wishbone_label = widgets.Label("Wishbone")
        wishbone_table = widgets.Output()
        wishbone = widgets.VBox([wishbone_label, wishbone_table])

        # External axi4lite
        neo_axi_label = widgets.Label("NeoRV Axi")
        neo_axi_table = widgets.Output()
        neo_axi = widgets.VBox([neo_axi_label, neo_axi_table])

        external_bus_section_label = widgets.Label("External Bus")
        external_bus_columes = widgets.HBox([wishbone, neo_axi])
        external_bus_section = widgets.VBox([external_bus_section_label, external_bus_columes])

        # BRAM section
        # BRAM axi
        BRAM_axi_label = widgets.Label("BRAM Axi")
        BRAM_axi_table = widgets.Output()
        BRAM_axi = widgets.VBox([BRAM_axi_label, BRAM_axi_table])

        # BRAM port
        def generate_BRAM_port_table(capture_data):
            enable  = (capture_data[BRAM_bundle] >> 0) & 0x00000001
            bytes   = (capture_data[BRAM_bundle] >> 4) & 0x0000000F

            return  pd.DataFrame({
                "Signal": [
                    "Addr"
                    "Enable",
                    "read_data",
                    "Write Sel",
                    "write_data",
                ],
                "Value": [
                    hex(capture_data[BRAM_addr])[2:].zfill(8),
                    hex(enable)[2:].zfill(1),
                    hex(capture_data[BRAM_read_data])[2:].zfill(8),
                    hex(bytes)[2:].zfill(1),
                    hex(capture_data[BRAM_write_data])[2:].zfill(8),
                ]
            })

        BRAM_port_label = widgets.Label("BRAM")
        BRAM_port_table = widgets.Output()
        BRAM_port = widgets.VBox([BRAM_port_label, BRAM_port_table])

        BRAM_section_label = widgets.Label("BRAM")
        BRAM_columes = widgets.HBox([BRAM_axi, ])
        BRAM_section = widgets.VBox([BRAM_section_label, BRAM_columes])

        # BRAM internface

        # LED section
        # LED axi
        LED_axi_label = widgets.Label("LED Axi")
        LED_axi_table = widgets.Output()
        LED_axi = widgets.VBox([LED_axi_label, LED_axi_table])

        LED_section_label = widgets.Label("LEDs")
        LED_columes = widgets.HBox([LED_axi, ])
        LED_section = widgets.VBox([LED_section_label, LED_columes])

        # buttons section
        # buttons axi
        buttons_axi_label = widgets.Label("Buttons Axi")
        buttons_axi_table = widgets.Output()
        buttons_axi = widgets.VBox([buttons_axi_label, buttons_axi_table])

        buttons_section_label = widgets.Label("Buttons")
        buttons_columes = widgets.HBox([buttons_axi, ])
        buttons_section = widgets.VBox([buttons_section_label, buttons_columes])

        # Define update function and blank out tables
        def update_internals(captured_data):
            # Update regfile section's tables
            regfile_rs1_addr_table.clear_output()
            regfile_rs2_addr_table.clear_output()
            regfile_cmp_results_table.clear_output()
            regfile_rd_addr_table.clear_output()
            regfile_rd_input_table.clear_output()
            regfile_rd_control_table.clear_output()
            with regfile_rs1_addr_table : display(generate_regfile_rs1_addr_table(captured_data))
            with regfile_rs2_addr_table : display(generate_regfile_rs2_addr_table(captured_data))
            with regfile_cmp_results_table : display(generate_regfile_cmp_results_table(captured_data))
            with regfile_rd_addr_table  : display(generate_regfile_rd_addr_table(captured_data))
            with regfile_rd_input_table : display(generate_regfile_rd_input_table(captured_data))
            with regfile_rd_control_table : display(generate_regfile_rd_control_table(captured_data))

            # Update ALU section's tables
            ALU_opA_input_table.clear_output()
            ALU_opB_input_table.clear_output()
            ALU_controls_table.clear_output()
            ALU_results_table.clear_output()
            with ALU_opA_input_table : display(generate_ALU_opA_input_table(captured_data))
            with ALU_opB_input_table : display(generate_ALU_opB_input_table(captured_data))
            with ALU_controls_table : display(generate_ALU_controls_table(captured_data))
            with ALU_results_table : display(generate_ALU_results_table(captured_data))

            # Update Coprocesspr section's tables
            copro_funct_table.clear_output()
            copro_ALU_interface_table.clear_output()
            copro_results_table.clear_output()
            with copro_funct_table : display(generate_copro_funct_table(captured_data))
            with copro_ALU_interface_table : display(generate_copro_ALU_interface_table(captured_data))
            with copro_results_table : display(generate_copro_results_table(captured_data))

            # Update bus control section's tables
            bus_instr_table.clear_output()
            bus_data_table.clear_output()
            bus_signals_table.clear_output()
            with bus_instr_table : display(generate_bus_instr_table(captured_data))
            with bus_data_table : display(generate_bus_data_table(captured_data))
            with bus_signals_table : display(generate_bus_signals_table(captured_data))

            # Update buses section's tables
            Instr_bus_table.clear_output()
            data_bus_table.clear_output()
            switch_controls_table.clear_output()
            muxed_bus_table.clear_output()
            with Instr_bus_table : display(generate_internal_bus_table(captured_data, instr_bundle_offset, instr_bus_words))
            with data_bus_table : display(generate_internal_bus_table(captured_data, data_bundle_offset, data_bus_words))
            with switch_controls_table : display(generate_switch_controls_table(captured_data))
            with muxed_bus_table : display(generate_internal_bus_table(captured_data, muxed_bundle_offset, muxed_bus_words))

            # Update External bus section's tables
            wishbone_table.clear_output()
            neo_axi_table.clear_output()
            with wishbone_table : display(generate_wishbone_table(captured_data))
            with neo_axi_table : display(generate_axi_table(captured_data, neo_axi_words))

            # Update BRAM section's tables
            BRAM_axi_table.clear_output()
            with BRAM_axi_table : display(generate_axi_table(captured_data, BRAM_axi_words))

            # Update LED section's tables3
            LED_axi_table.clear_output()
            with LED_axi_table : display(generate_axi_table(captured_data, LED_axi_words))

            # Update Buttons section's tables
            buttons_axi_table.clear_output()
            with buttons_axi_table : display(generate_axi_table(captured_data, button_axi_words))
        update_internals([0]*60)

        # Add update button
        capture_button = widgets.Button(
            description="Capture Internals",
            tooltip="Capture the value of internal signals and updates the show_internals GUI"
        )
        def capture_button_click(_):
            captured_date = [
                this._capharness_read_word(4*word)
                for word in range(60)
            ]
            update_internals(captured_date)
        capture_button.on_click(capture_button_click)

        # Collect all sections into GUI
        gui_label = widgets.Label("Internals")
        section_tabs = widgets.Tab(
            children=[regfile_section, ALU_section, copro__section, bus_section, switch_section, external_bus_section, BRAM_section, LED_section],
            titles =["Regfile", "ALU", "CoProcessers", "Bus Control", "Bus Switch", "External Bus", "BRAM", "LEDs", "Buttons"]
        )
        capture_GUI = widgets.VBox([gui_label, section_tabs, capture_button ])

        return capture_GUI
