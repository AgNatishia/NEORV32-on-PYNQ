from pynq import GPIO
from pynq.overlay import Overlay

import ipywidgets as widgets

import time
import os

stepper_controls = {
    "first_all"   : 0x00000001,
    "continous"   : 0x00000100,
    "clock_tick"  : 0x00010000,
    "clock_count" : 0x00020000,
    "instr_tick"  : 0x01000000,
    "instr_count" : 0x02000000,
    "PC_target"   : 0x04000000,
}

stepper_regmap = {
    "controls"    : 0x0,
    "clock_count" : 0x4,
    "instr_count" : 0x8,
    "PC_target"   : 0xC
}

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

class overlay():
    def __init__(this):
        this.overlay = Overlay("/usr/local/lib/python3.6/dist-packages/NEORV32_on_PYNQ/rv32i_overlay.bit")

        this.core_reset = GPIO(GPIO.get_gpio_pin(0), 'out')
        this.BRAM = this.overlay.pynq_BRAM_controller
        this.stepper = this.overlay.cpu_clock_stepper

    # Reset functions
    def start_reset(this):
        this.core_reset.write(0) # 0 as reset is negtive logic

    def end_reset(this):
        this.core_reset.write(1) # 1 as reset is negtive logic

    def pulse_reset(this, pulse_time=0.005):
        this.start_reset()
        time.sleep(pulse_time)
        this.end_reset()

    # BRAM functions
    def load_program(this, filename, swap_endianess=False):
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
        this.start_reset()

        # Write Program
        for addr, word in enumerate(BRAM_data):
            this.BRAM.write(4*addr, word)

        # Let NEO out of teset to start running the now program
        this.end_reset()

    # Stepper functions
    def write_stepper_registor(this, registor, value):
        this.stepper.write(registor, value)

    def read_stepper_registor(this, registor):
        return this.stepper.read(registor)

    # GUI functions
    def program_load_GUI(this, program_folder=None, folder_per_program = True):
        # Handle default program folder
        if program_folder == None:
            program_folder  = os.path.join(".", "programs")

        # Check program_folder is a valid path
        if not isinstance(program_folder, str):
            raise ValueError("program_folder must be a string")
        elif not os.path.isdir(program_folder):
            raise ValueError("program_folder, %s, doesn't pick to a folder"%(program_folder, ))

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

        # Build GUI
        gui_label = widgets.Label("Program Select:")

        gui_program_dropdown = widgets.Dropdown(
            options=programs,
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
        gui_lower_row = widgets.HBox([gui_program_dropdown, gui_write_button, gui_loaded_label])
        gui = widgets.VBox([gui_label, gui_lower_row])

        # Functions to handle interacting with the widgets, to load a program into the overlay's BRAM
        def gui_write_button_click(_):
            # Get selected program
            program = gui_program_dropdown.value

            # Load selected program
            if folder_per_program:
                this.load_program(os.path.join(program_folder, program, program))
            else:
                this.load_program(os.path.join(program_folder, program))

            # Update last Loaded
            gui_loaded_label.value = "Last Loaded: %s.bin"%(program, )

        # Bind gui_write_button_click to button's on_click hook
        gui_write_button.on_click(gui_write_button_click)

        return gui

    def clock_control_GUI(this):
        # Build GUI
        gui_label = widgets.Label("Clock Control:")

        # Clock counter rule
        clock_count_label  =  widgets.Label(
            value="Clock Count Rule:",
            tooltip="The Clock Count Rule is fulfilled after the overlay has run for a given number of clock cycles."
        )
        clock_count_enable = widgets.Checkbox(
            tooltip="Run the overlay for number of clock cyxles specisied by the 'Clock Count Rule Value' field",
            value=False
        )
        clock_count_value = widgets.Text(
            tooltip="The number of clock cyles the Clock Count Rule, if enabled by 'Clock Count Rule Enable' field, will be fulfilled after. The value can be any 32 bit unsigned number larger than 0, and can be entered in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)."
        )

        # Instr counter rule
        instr_count_label  =  widgets.Label(
            value="instruction Count Rule:",
            tooltip="The instruction Count Rule is fulfilled after the overlay has executed a given number of inctructions."
        )
        instr_count_enable = widgets.Checkbox(
            tooltip="Run the overlay for number of instructions specisied by the 'instr Count Rule Value' field",
            value=False
        )
        instr_count_value = widgets.Text(
            tooltip="The number of instructions the instr Count Rule, if enabled by 'instr Count Rule Enable' field, will be fulfilled after. The value can be any 32 bit unsigned number larger than 0, and can be entered in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)."
        )

        # PC target rule
        PC_target_label  =  widgets.Label(
            value="PC Target Rule:",
            tooltip="The PC Target Rule is fulfilled after the overlay reaches a given PC value."
        )
        PC_target_enable = widgets.Checkbox(
            tooltip="Run the overlay until the program counter matches the value specisied by the 'PC Target Rule Value' field",
            value=False,
        )
        PC_target_value = widgets.Text(
            tooltip="The PC value the PC Target Rule, if enabled by 'PC Target Rule Enable' field, will be fulfilled on reaching. The value can be any 32 bit unsigned number larger than 0, and can be entered in binary (prefixed 0b), decimal (no prefix), or hexadecimal (prefixed 0x)."
        )

        # Pack Rules together
        rule_labels = widgets.VBox([clock_count_label, instr_count_label, PC_target_label])
        rule_enables = widgets.VBox([clock_count_enable, instr_count_enable, PC_target_enable])
        rule_values = widgets.VBox([clock_count_value, instr_count_value, PC_target_value])
        rules = widgets.HBox([rule_labels, rule_enables, rule_values])

        # GUI Buttons
        step_clock_button = widgets.Button(
            description="Step Clock",
            tooltip="Run the overlay for one clock cycle"
        )
        def step_clock_button_click(_):
            this.write_stepper_registor(stepper_regmap["controls"], stepper_controls["clock_tick"])
        step_clock_button.on_click(step_clock_button_click)

        step_instruction_button = widgets.Button(
            description="Step Instruction",
            tooltip="Run the overlay until the next instruction"
        )
        def step_instruction_button_click(_):
            this.write_stepper_registor(stepper_regmap["controls"], stepper_controls["instr_tick"])
        step_instruction_button.on_click(step_instruction_button_click)

        run_continous_button  = widgets.Button(
            description="Run continous",
            tooltip="Runs the overlay continousally, can be overwrite by any of the other buttone."
        )
        def run_continous_button_click(_):
            this.write_stepper_registor(stepper_regmap["controls"], stepper_controls["continous"])
        run_continous_button.on_click(run_continous_button_click)

        stop_running_button  = widgets.Button(
            description="Stop",
            tooltip="Stops whatever rules are running on the overlay"
        )
        def stop_running_button_click(_):
            this.write_stepper_registor(stepper_regmap["controls"], 0)
        stop_running_button.on_click(stop_running_button_click)

        run_rules_button  = widgets.Button(
            description="Run Rules",
            tooltip="It any rules are enabled the overlay until the first enabled rule is fulfiled\n"
        )
        def run_rules_button_click(_):
            # Stop the overlay in order to write counters and target
            this.write_stepper_registor(stepper_regmap["controls"], 0)

            # Handle registors
            if clock_count_enable.value == True:
                reg_value = textboz_to_int(clock_count_value.value)
                if reg_value != 0:
                    this.write_stepper_registor(stepper_regmap["clock_count"], reg_value)
            if instr_count_enable.value == True:
                reg_value = textboz_to_int(instr_count_value.value)
                if reg_value != 0:
                    this.write_stepper_registor(stepper_regmap["instr_count"], reg_value)
            if PC_target_enable.value == True:
                reg_value = textboz_to_int(PC_target_value.value) + 0x40000000
                this.write_stepper_registor(stepper_regmap["PC_target"], reg_value)

            # Handle controls
            controls = 0
            if clock_count_enable.value == True:
                controls |= stepper_controls["clock_count"]
            if instr_count_enable.value == True:
                controls |= stepper_controls["instr_count"]
            if PC_target_enable.value == True:
                controls |= stepper_controls["PC_target"]
            this.write_stepper_registor(stepper_regmap["controls"], controls)

        run_rules_button.on_click(run_rules_button_click)

        run_button_box = widgets.HBox([step_clock_button, step_instruction_button, run_continous_button, run_rules_button, stop_running_button])

        control_box = widgets.VBox([gui_label, rules, run_button_box])

        return control_box
