import os

# Varables used in script
repo_path = os.path.join("..","neorv32","rtl","core")

# Constants used in script
ALU_coprocessers = 8
pmp_max_regions  = 64
pmp_addr_width   = 34
pmp_ctrl_width   = 8


# Pull out files for processing
repo_rtl_files = [f for f in os.listdir(repo_path) if os.path.isfile(os.path.join(repo_path, f))]
cpu_rtl_files = [f for f in repo_rtl_files if f.startswith("neorv32_cpu_")]
additional_files = [ "neorv32_busswitch.vhd", "neorv32_bus_keeper.vhd", "neorv32_wishbone.vhd", "neorv32_package.vhd"]
files_to_process = cpu_rtl_files + additional_files

# Process files
for file_name in files_to_process:
    # Load file from repo
    with open(os.path.join(repo_path, file_name), "r") as f:
        file_text = f.read()

    # Handle ALU cp_data_if_t port
    if file_name == "neorv32_cpu_alu.vhd":
        # Replace port witn wrapped port
        port = "cp_result_i : in  cp_data_if_t;"
        wrapped_port = "wrapped_cp_result_i : in  std_logic_vector((%i*32) - 1 downto 0);"%(ALU_coprocessers)
        assert(file_text.count(port) == 1)
        file_text = file_text.replace(port, wrapped_port)

        # Create replacement signal for wrapped port
        location = "architecture neorv32_cpu_cpu_rtl of neorv32_cpu_alu is"
        addition = "\n\tsignal cp_result_i : cp_data_if_t;"
        assert(file_text.count(location) == 1)
        file_text = file_text.replace(location, location + addition)

        # Add wrapping logic to link wrapper port and signal
        location = "end neorv32_cpu_cpu_rtl;"
        assert(file_text.count(location) == 1)
        addition = ""
        for i in range(ALU_coprocessers):
            addition += "\n\tcp_result_i(%i) <= wrapped_cp_result_i((%i*32) + 31 downto %i*32);\n"%(i, i, i )
        file_text = file_text.replace(location, addition + location)

    # Handle bus control pmp ports
    if file_name == "neorv32_cpu_bus.vhd":
        # Replace pmp_addr_i port witn wrapped port
        port = "pmp_addr_i     : in  pmp_addr_if_t;"
        wrapped_port = "wrapped_pmp_addr_i : in  std_logic_vector((%i*%i) - 1 downto 0);"%(pmp_max_regions, pmp_addr_width)
        assert(file_text.count(port) == 1)
        file_text = file_text.replace(port, wrapped_port)

        # Replace pmp_addr_i port witn wrapped port
        port = "pmp_ctrl_i     : in  pmp_ctrl_if_t;"
        wrapped_port = "wrapped_pmp_ctrl_i : in  std_logic_vector((%i*%i) - 1 downto 0);"%(pmp_max_regions, pmp_ctrl_width)
        assert(file_text.count(port) == 1)
        file_text = file_text.replace(port, wrapped_port)

        # Create replacement signal for wrapped port
        location = "architecture neorv32_cpu_bus_rtl of neorv32_cpu_bus is"
        addition = "\n\tsignal pmp_addr_i : pmp_addr_if_t;\n\tsignal pmp_ctrl_i : pmp_ctrl_if_t;"
        assert(file_text.count(location) == 1)
        file_text = file_text.replace(location, location + addition)

        # Add wrapping logic to link wrapper port and signal
        location = "end neorv32_cpu_bus_rtl;"
        assert(file_text.count(location) == 1)
        addition = ""
        for i in range(pmp_max_regions):
            addition += "\tpmp_addr_i(%i) <= wrapped_pmp_addr_i((%i*%i) + %i downto %i*%i);\n"%(i, i, pmp_addr_width, pmp_addr_width - 1, i, pmp_addr_width)
        addition += "\n"
        for i in range(pmp_max_regions):
            addition += "\tpmp_ctrl_i(%i) <= wrapped_pmp_ctrl_i((%i*%i) + %i downto %i*%i);\n"%(i, i, pmp_ctrl_width, pmp_ctrl_width - 1, i, pmp_ctrl_width)
        file_text = file_text.replace(location, addition + location)

    # Handle cpu control pmp ports
    if file_name == "neorv32_cpu_control.vhd":
        # Replace pmp_addr_i port witn wrapped port
        port = "pmp_addr_o    : out pmp_addr_if_t;"
        wrapped_port = "wrapped_pmp_addr_o : out std_logic_vector((%i*%i) - 1 downto 0);"%(pmp_max_regions, pmp_addr_width)
        assert(file_text.count(port) == 1)
        file_text = file_text.replace(port, wrapped_port)

        # Replace pmp_addr_i port witn wrapped port
        port = "pmp_ctrl_o    : out pmp_ctrl_if_t;"
        wrapped_port = "wrapped_pmp_ctrl_o : out std_logic_vector((%i*%i) - 1 downto 0);"%(pmp_max_regions, pmp_ctrl_width)
        assert(file_text.count(port) == 1)
        file_text = file_text.replace(port, wrapped_port)

        # Create replacement signal for wrapped port
        location = "architecture neorv32_cpu_control_rtl of neorv32_cpu_control is"
        addition = "\n\tsignal pmp_addr_o : pmp_addr_if_t;\n\tsignal pmp_ctrl_o : pmp_ctrl_if_t;"
        assert(file_text.count(location) == 1)
        file_text = file_text.replace(location, location + addition)

        # Add wrapping logic to link wrapper port and signal
        location = "end neorv32_cpu_control_rtl;"
        assert(file_text.count(location) == 1)
        addition = ""
        for i in range(pmp_max_regions):
            addition += "\twrapped_pmp_addr_o((%i*%i) + %i downto %i*%i) <= pmp_addr_o(%i);\n"%(i, pmp_addr_width, pmp_addr_width - 1, i, pmp_addr_width, i,)
        addition += "\n"
        for i in range(pmp_max_regions):
            addition += "\twrapped_pmp_ctrl_o((%i*%i) + %i downto %i*%i) <= pmp_ctrl_o(%i);\n"%(i, pmp_ctrl_width, pmp_ctrl_width - 1, i, pmp_ctrl_width, i,)
        file_text = file_text.replace(location, addition + location)


    # Update neorv32_package to BD_neorv32_package
    file_text = file_text.replace("use neorv32.neorv32_package.all;", "use neorv32.BD_neorv32_package.all;")

    # Convert all std_ulogic to std_logic
    file_text = file_text.replace("std_ulogic", "std_logic")

    # Prefix BD to rtl name, to make telling modifier and non mogified versions apart easiler
    rtl_name = file_name.split(".")[0]
    file_text = file_text.replace(rtl_name, "BD_"+rtl_name)


    # Save modified file
    with open("BD_" + file_name, "w") as f:
        f.write(file_text)
