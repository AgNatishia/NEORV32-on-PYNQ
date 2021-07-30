
################################################################
# This is a generated script based on design: simulation_rv32i_overlay
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source simulation_rv32i_overlay_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART tul.com.tw:pynq-z2:part0:1.0 [current_project]
}

# Add referenced RTL modules
add_files {./block_parts/BD_neorv32_cpu_decompressor.vhd ./block_parts/BD_neorv32_bus_keeper.vhd ./block_parts/BD_neorv32_cpu_cp_fpu.vhd ./block_parts/BD_neorv32_busswitch.vhd ./block_parts/BD_neorv32_cpu_control.vhd ./block_parts/BD_neorv32_cpu_alu.vhd ./block_parts/BD_neorv32_cpu_bus.vhd ./block_parts/BD_neorv32_cpu_regfile.vhd ./block_parts/BD_neorv32_package.vhd ./block_parts/BD_neorv32_wishbone.vhd ./block_parts/BD_wishbon_axi4lite_bridge.vhd ./block_parts/BD_neorv32_cpu_cp_muldiv.vhd}
set_property library neorv32 [get_files  {./block_parts/BD_neorv32_cpu_decompressor.vhd ./block_parts/BD_neorv32_bus_keeper.vhd ./block_parts/BD_neorv32_cpu_cp_fpu.vhd ./block_parts/BD_neorv32_busswitch.vhd ./block_parts/BD_neorv32_cpu_control.vhd ./block_parts/BD_neorv32_cpu_alu.vhd ./block_parts/BD_neorv32_cpu_bus.vhd ./block_parts/BD_neorv32_cpu_regfile.vhd ./block_parts/BD_neorv32_package.vhd ./block_parts/BD_neorv32_wishbone.vhd ./block_parts/BD_wishbon_axi4lite_bridge.vhd ./block_parts/BD_neorv32_cpu_cp_muldiv.vhd}]

# Add referenced IPs
set_property  ip_repo_paths  ./ip_repo [current_project]
update_ip_catalog

# CHANGE DESIGN NAME HERE
variable design_name
set design_name simulation_rv32i_overlay

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\
BD_neorv32_cpu_alu\
BD_neorv32_cpu_control\
BD_neorv32_cpu_bus\
BD_neorv32_cpu_regfile\
BD_neorv32_bus_keeper\
BD_neorv32_busswitch\
BD_neorv32_wishbone\
BD_wishbon_axi4lite_bridge\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set btns_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 btns_4bits ]

  set leds_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]


  # Create ports
  set clock [ create_bd_port -dir I -type clk -freq_hz 100000000 clock ]
  set cpu_reset [ create_bd_port -dir I -type rst cpu_reset ]
  set peripheral_reset [ create_bd_port -dir I -type rst peripheral_reset ]
  set smartconnect_reset [ create_bd_port -dir I -type rst smartconnect_reset ]

  # Create instance: LED_controller, and set properties
  set LED_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 LED_controller ]
  set_property -dict [ list \
   CONFIG.C_GPIO_WIDTH {4} \
   CONFIG.GPIO_BOARD_INTERFACE {leds_4bits} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $LED_controller

  # Create instance: button_controller, and set properties
  set button_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 button_controller ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_GPIO_WIDTH {4} \
   CONFIG.GPIO_BOARD_INTERFACE {btns_4bits} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $button_controller

  # Create instance: cpu_BRAM_controller, and set properties
  set cpu_BRAM_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 cpu_BRAM_controller ]
  set_property -dict [ list \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $cpu_BRAM_controller

  # Create instance: cpu_BRAM_controller_bram, and set properties
  set cpu_BRAM_controller_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 cpu_BRAM_controller_bram ]
  set_property -dict [ list \
   CONFIG.Byte_Size {8} \
   CONFIG.Coe_File {no_coe_file_loaded} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Fill_Remaining_Memory_Locations {false} \
   CONFIG.Load_Init_File {false} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
   CONFIG.Use_Byte_Write_Enable {true} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $cpu_BRAM_controller_bram

  # Create instance: cpu_alu, and set properties
  set block_name BD_neorv32_cpu_alu
  set block_cell_name cpu_alu
  if { [catch {set cpu_alu [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cpu_alu eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.CPU_EXTENSION_RISCV_M {false} \
 ] $cpu_alu

  # Create instance: cpu_control_unit, and set properties
  set block_name BD_neorv32_cpu_control
  set block_cell_name cpu_control_unit
  if { [catch {set cpu_control_unit [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cpu_control_unit eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.CPU_BOOT_ADDR {0x40000000} \
 ] $cpu_control_unit

  # Create instance: cpu_cp_0_start_slice, and set properties
  set cpu_cp_0_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_0_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_WIDTH {8} \
 ] $cpu_cp_0_start_slice

  # Create instance: cpu_cp_1_start_slice, and set properties
  set cpu_cp_1_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_1_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_1_start_slice

  # Create instance: cpu_cp_2_start_slice, and set properties
  set cpu_cp_2_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_2_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_2_start_slice

  # Create instance: cpu_cp_3_start_slice, and set properties
  set cpu_cp_3_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_3_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {3} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_3_start_slice

  # Create instance: cpu_cp_4_start_slice, and set properties
  set cpu_cp_4_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_4_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {4} \
   CONFIG.DIN_TO {4} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_4_start_slice

  # Create instance: cpu_cp_5_start_slice, and set properties
  set cpu_cp_5_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_5_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {5} \
   CONFIG.DIN_TO {5} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_5_start_slice

  # Create instance: cpu_cp_6_start_slice, and set properties
  set cpu_cp_6_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_6_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {6} \
   CONFIG.DIN_TO {6} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_6_start_slice

  # Create instance: cpu_cp_7_start_slice, and set properties
  set cpu_cp_7_start_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cpu_cp_7_start_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {7} \
   CONFIG.DIN_TO {7} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $cpu_cp_7_start_slice

  # Create instance: cpu_cp_result_concat, and set properties
  set cpu_cp_result_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 cpu_cp_result_concat ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {32} \
   CONFIG.IN1_WIDTH {32} \
   CONFIG.IN2_WIDTH {32} \
   CONFIG.IN3_WIDTH {32} \
   CONFIG.IN4_WIDTH {32} \
   CONFIG.IN5_WIDTH {32} \
   CONFIG.IN6_WIDTH {32} \
   CONFIG.IN7_WIDTH {32} \
   CONFIG.NUM_PORTS {8} \
 ] $cpu_cp_result_concat

  # Create instance: cpu_cp_valid_concat, and set properties
  set cpu_cp_valid_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 cpu_cp_valid_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $cpu_cp_valid_concat

  # Create instance: cpu_external_bus_control, and set properties
  set block_name BD_neorv32_cpu_bus
  set block_cell_name cpu_external_bus_control
  if { [catch {set cpu_external_bus_control [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cpu_external_bus_control eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.CPU_EXTENSION_RISCV_C {false} \
 ] $cpu_external_bus_control

  # Create instance: cpu_regfile, and set properties
  set block_name BD_neorv32_cpu_regfile
  set block_cell_name cpu_regfile
  if { [catch {set cpu_regfile [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cpu_regfile eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: interface_bus_err_or, and set properties
  set interface_bus_err_or [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 interface_bus_err_or ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $interface_bus_err_or

  # Create instance: interface_bus_keeper, and set properties
  set block_name BD_neorv32_bus_keeper
  set block_cell_name interface_bus_keeper
  if { [catch {set interface_bus_keeper [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interface_bus_keeper eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.MEM_EXT_EN {true} \
   CONFIG.MEM_INT_DMEM_EN {false} \
   CONFIG.MEM_INT_IMEM_EN {false} \
 ] $interface_bus_keeper

  # Create instance: interface_bus_switch, and set properties
  set block_name BD_neorv32_busswitch
  set block_cell_name interface_bus_switch
  if { [catch {set interface_bus_switch [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interface_bus_switch eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.PORT_CB_READ_ONLY {true} \
 ] $interface_bus_switch

  # Create instance: interface_bus_to_wishbone, and set properties
  set block_name BD_neorv32_wishbone
  set block_cell_name interface_bus_to_wishbone
  if { [catch {set interface_bus_to_wishbone [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interface_bus_to_wishbone eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.BUS_TIMEOUT {0} \
   CONFIG.MEM_INT_DMEM_EN {false} \
   CONFIG.MEM_INT_IMEM_EN {false} \
 ] $interface_bus_to_wishbone

  # Create instance: interface_wishbone_priv_slice, and set properties
  set interface_wishbone_priv_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 interface_wishbone_priv_slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {46} \
   CONFIG.DIN_TO {45} \
   CONFIG.DIN_WIDTH {73} \
   CONFIG.DOUT_WIDTH {2} \
 ] $interface_wishbone_priv_slice

  # Create instance: interface_wishbone_to_axi, and set properties
  set block_name BD_wishbon_axi4lite_bridge
  set block_cell_name interface_wishbone_to_axi
  if { [catch {set interface_wishbone_to_axi [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interface_wishbone_to_axi eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: neo_smartconnect, and set properties
  set neo_smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 neo_smartconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
 ] $neo_smartconnect

  # Create instance: pull_down_16_bit, and set properties
  set pull_down_16_bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 pull_down_16_bit ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {16} \
 ] $pull_down_16_bit

  # Create instance: pull_down_1_bit, and set properties
  set pull_down_1_bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 pull_down_1_bit ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $pull_down_1_bit

  # Create instance: pull_down_5_bit, and set properties
  set pull_down_5_bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 pull_down_5_bit ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {5} \
 ] $pull_down_5_bit

  # Create instance: pull_down_64_bit, and set properties
  set pull_down_64_bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 pull_down_64_bit ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {64} \
 ] $pull_down_64_bit

  # Create interface connections
  connect_bd_intf_net -intf_net LED_controller_GPIO [get_bd_intf_ports leds_4bits] [get_bd_intf_pins LED_controller/GPIO]
  connect_bd_intf_net -intf_net button_controller_GPIO [get_bd_intf_ports btns_4bits] [get_bd_intf_pins button_controller/GPIO]
  connect_bd_intf_net -intf_net cpu_BRAM_controller_BRAM_PORTA [get_bd_intf_pins cpu_BRAM_controller/BRAM_PORTA] [get_bd_intf_pins cpu_BRAM_controller_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net cpu_smartconnect_M01_AXI [get_bd_intf_pins LED_controller/S_AXI] [get_bd_intf_pins neo_smartconnect/M01_AXI]
  connect_bd_intf_net -intf_net cpu_smartconnect_M02_AXI [get_bd_intf_pins button_controller/S_AXI] [get_bd_intf_pins neo_smartconnect/M02_AXI]
  connect_bd_intf_net -intf_net neo_smartconnect_M00_AXI [get_bd_intf_pins cpu_BRAM_controller/S_AXI] [get_bd_intf_pins neo_smartconnect/M00_AXI]
  connect_bd_intf_net -intf_net neorv32_interface_wishbone_to_axi_m_axi [get_bd_intf_pins interface_wishbone_to_axi/m_axi] [get_bd_intf_pins neo_smartconnect/S00_AXI]

  # Create port connections
  connect_bd_net -net BD_neorv32_busswitch_0_ca_bus_ack_o [get_bd_pins cpu_external_bus_control/d_bus_ack_i] [get_bd_pins interface_bus_switch/ca_bus_ack_o]
  connect_bd_net -net BD_neorv32_busswitch_0_ca_bus_err_o [get_bd_pins cpu_external_bus_control/d_bus_err_i] [get_bd_pins interface_bus_switch/ca_bus_err_o]
  connect_bd_net -net BD_neorv32_busswitch_0_ca_bus_rdata_o [get_bd_pins cpu_external_bus_control/d_bus_rdata_i] [get_bd_pins interface_bus_switch/ca_bus_rdata_o]
  connect_bd_net -net BD_neorv32_busswitch_0_cb_bus_ack_o [get_bd_pins cpu_external_bus_control/i_bus_ack_i] [get_bd_pins interface_bus_switch/cb_bus_ack_o]
  connect_bd_net -net BD_neorv32_busswitch_0_cb_bus_err_o [get_bd_pins cpu_external_bus_control/i_bus_err_i] [get_bd_pins interface_bus_switch/cb_bus_err_o]
  connect_bd_net -net BD_neorv32_busswitch_0_cb_bus_rdata_o [get_bd_pins cpu_external_bus_control/i_bus_rdata_i] [get_bd_pins interface_bus_switch/cb_bus_rdata_o]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_addr_o [get_bd_pins interface_bus_keeper/addr_i] [get_bd_pins interface_bus_switch/p_bus_addr_o] [get_bd_pins interface_bus_to_wishbone/addr_i]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_ben_o [get_bd_pins interface_bus_switch/p_bus_ben_o] [get_bd_pins interface_bus_to_wishbone/ben_i]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_lock_o [get_bd_pins interface_bus_switch/p_bus_lock_o] [get_bd_pins interface_bus_to_wishbone/lock_i]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_re_o [get_bd_pins interface_bus_keeper/rden_i] [get_bd_pins interface_bus_switch/p_bus_re_o] [get_bd_pins interface_bus_to_wishbone/rden_i]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_src_o [get_bd_pins interface_bus_switch/p_bus_src_o] [get_bd_pins interface_bus_to_wishbone/src_i]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_wdata_o [get_bd_pins interface_bus_switch/p_bus_wdata_o] [get_bd_pins interface_bus_to_wishbone/data_i]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_we_o [get_bd_pins interface_bus_keeper/wren_i] [get_bd_pins interface_bus_switch/p_bus_we_o] [get_bd_pins interface_bus_to_wishbone/wren_i]
  connect_bd_net -net BD_neorv32_cpu_alu_0_res_o [get_bd_pins cpu_alu/res_o] [get_bd_pins cpu_regfile/alu_i]
  connect_bd_net -net BD_neorv32_cpu_regfi_0_rs1_o [get_bd_pins cpu_alu/rs1_i] [get_bd_pins cpu_control_unit/rs1_i] [get_bd_pins cpu_regfile/rs1_o]
  connect_bd_net -net BD_neorv32_cpu_regfi_0_rs2_o [get_bd_pins cpu_alu/rs2_i] [get_bd_pins cpu_external_bus_control/wdata_i] [get_bd_pins cpu_regfile/rs2_o]
  connect_bd_net -net BD_neorv32_wishbone_0_ack_o [get_bd_pins interface_bus_keeper/ack_i] [get_bd_pins interface_bus_switch/p_bus_ack_i] [get_bd_pins interface_bus_to_wishbone/ack_o]
  connect_bd_net -net BD_neorv32_wishbone_0_data_o [get_bd_pins interface_bus_switch/p_bus_rdata_i] [get_bd_pins interface_bus_to_wishbone/data_o]
  connect_bd_net -net BD_wishbon_axi4lite_0_wb_ack [get_bd_pins interface_bus_to_wishbone/wb_ack_i] [get_bd_pins interface_wishbone_to_axi/wb_ack]
  connect_bd_net -net BD_wishbon_axi4lite_0_wb_data_read [get_bd_pins interface_bus_to_wishbone/wb_dat_i] [get_bd_pins interface_wishbone_to_axi/wb_data_read]
  connect_bd_net -net BD_wishbon_axi4lite_0_wb_err [get_bd_pins interface_bus_to_wishbone/wb_err_i] [get_bd_pins interface_wishbone_to_axi/wb_err]
  connect_bd_net -net Net [get_bd_ports cpu_reset] [get_bd_pins cpu_alu/rstn_i] [get_bd_pins cpu_control_unit/rstn_i] [get_bd_pins cpu_external_bus_control/rstn_i] [get_bd_pins interface_bus_keeper/rstn_i] [get_bd_pins interface_bus_switch/rstn_i] [get_bd_pins interface_bus_to_wishbone/rstn_i] [get_bd_pins interface_wishbone_to_axi/m_axi_aresetn]
  connect_bd_net -net at_0_dout [get_bd_pins cpu_alu/wrapped_cp_result_i] [get_bd_pins cpu_cp_result_concat/dout]
  connect_bd_net -net cpu_control_unit_csr_rdata_o [get_bd_pins cpu_control_unit/csr_rdata_o] [get_bd_pins cpu_cp_result_concat/In0]
  connect_bd_net -net cpu_cp_0_start_slice_Dout [get_bd_pins cpu_cp_0_start_slice/Dout] [get_bd_pins cpu_cp_valid_concat/In0]
  connect_bd_net -net interface_bus_err_or_Res [get_bd_pins interface_bus_err_or/Res] [get_bd_pins interface_bus_switch/p_bus_err_i]
  connect_bd_net -net interface_bus_keeper_err_o [get_bd_pins interface_bus_err_or/Op1] [get_bd_pins interface_bus_keeper/err_o]
  connect_bd_net -net interface_bus_to_wishbone_err_o [get_bd_pins interface_bus_err_or/Op2] [get_bd_pins interface_bus_keeper/err_i] [get_bd_pins interface_bus_to_wishbone/err_o]
  connect_bd_net -net neorv32_cp_valid_concat_dout [get_bd_pins cpu_alu/cp_valid_i] [get_bd_pins cpu_cp_valid_concat/dout]
  connect_bd_net -net neorv32_cpu_alu_add_o [get_bd_pins cpu_alu/add_o] [get_bd_pins cpu_control_unit/alu_add_i] [get_bd_pins cpu_external_bus_control/addr_i]
  connect_bd_net -net neorv32_cpu_alu_cp_start_o [get_bd_pins cpu_alu/cp_start_o] [get_bd_pins cpu_cp_0_start_slice/Din] [get_bd_pins cpu_cp_1_start_slice/Din] [get_bd_pins cpu_cp_2_start_slice/Din] [get_bd_pins cpu_cp_3_start_slice/Din] [get_bd_pins cpu_cp_4_start_slice/Din] [get_bd_pins cpu_cp_5_start_slice/Din] [get_bd_pins cpu_cp_6_start_slice/Din] [get_bd_pins cpu_cp_7_start_slice/Din]
  connect_bd_net -net neorv32_cpu_alu_wait_o [get_bd_pins cpu_alu/wait_o] [get_bd_pins cpu_control_unit/alu_wait_i]
  connect_bd_net -net neorv32_cpu_bus_be_instr_o [get_bd_pins cpu_control_unit/be_instr_i] [get_bd_pins cpu_external_bus_control/be_instr_o]
  connect_bd_net -net neorv32_cpu_bus_be_load_o [get_bd_pins cpu_control_unit/be_load_i] [get_bd_pins cpu_external_bus_control/be_load_o]
  connect_bd_net -net neorv32_cpu_bus_be_store_o [get_bd_pins cpu_control_unit/be_store_i] [get_bd_pins cpu_external_bus_control/be_store_o]
  connect_bd_net -net neorv32_cpu_bus_d_bus_addr_o [get_bd_pins cpu_external_bus_control/d_bus_addr_o] [get_bd_pins interface_bus_switch/ca_bus_addr_i]
  connect_bd_net -net neorv32_cpu_bus_d_bus_ben_o [get_bd_pins cpu_external_bus_control/d_bus_ben_o] [get_bd_pins interface_bus_switch/ca_bus_ben_i]
  connect_bd_net -net neorv32_cpu_bus_d_bus_lock_o [get_bd_pins cpu_external_bus_control/d_bus_lock_o] [get_bd_pins interface_bus_switch/ca_bus_lock_i]
  connect_bd_net -net neorv32_cpu_bus_d_bus_re_o [get_bd_pins cpu_external_bus_control/d_bus_re_o] [get_bd_pins interface_bus_switch/ca_bus_re_i]
  connect_bd_net -net neorv32_cpu_bus_d_bus_wdata_o [get_bd_pins cpu_external_bus_control/d_bus_wdata_o] [get_bd_pins interface_bus_switch/ca_bus_wdata_i]
  connect_bd_net -net neorv32_cpu_bus_d_bus_we_o [get_bd_pins cpu_external_bus_control/d_bus_we_o] [get_bd_pins interface_bus_switch/ca_bus_we_i]
  connect_bd_net -net neorv32_cpu_bus_d_wait_o [get_bd_pins cpu_control_unit/bus_d_wait_i] [get_bd_pins cpu_external_bus_control/d_wait_o]
  connect_bd_net -net neorv32_cpu_bus_excl_state_o [get_bd_pins cpu_control_unit/excl_state_i] [get_bd_pins cpu_external_bus_control/excl_state_o]
  connect_bd_net -net neorv32_cpu_bus_i_bus_addr_o [get_bd_pins cpu_external_bus_control/i_bus_addr_o] [get_bd_pins interface_bus_switch/cb_bus_addr_i]
  connect_bd_net -net neorv32_cpu_bus_i_bus_ben_o [get_bd_pins cpu_external_bus_control/i_bus_ben_o] [get_bd_pins interface_bus_switch/cb_bus_ben_i]
  connect_bd_net -net neorv32_cpu_bus_i_bus_lock_o [get_bd_pins cpu_external_bus_control/i_bus_lock_o] [get_bd_pins interface_bus_switch/cb_bus_lock_i]
  connect_bd_net -net neorv32_cpu_bus_i_bus_re_o [get_bd_pins cpu_external_bus_control/i_bus_re_o] [get_bd_pins interface_bus_switch/cb_bus_re_i]
  connect_bd_net -net neorv32_cpu_bus_i_bus_wdata_o [get_bd_pins cpu_external_bus_control/i_bus_wdata_o] [get_bd_pins interface_bus_switch/cb_bus_wdata_i]
  connect_bd_net -net neorv32_cpu_bus_i_bus_we_o [get_bd_pins cpu_external_bus_control/i_bus_we_o] [get_bd_pins interface_bus_switch/cb_bus_we_i]
  connect_bd_net -net neorv32_cpu_bus_i_wait_o [get_bd_pins cpu_control_unit/bus_i_wait_i] [get_bd_pins cpu_external_bus_control/i_wait_o]
  connect_bd_net -net neorv32_cpu_bus_instr_o [get_bd_pins cpu_control_unit/instr_i] [get_bd_pins cpu_external_bus_control/instr_o]
  connect_bd_net -net neorv32_cpu_bus_ma_instr_o [get_bd_pins cpu_control_unit/ma_instr_i] [get_bd_pins cpu_external_bus_control/ma_instr_o]
  connect_bd_net -net neorv32_cpu_bus_ma_load_o [get_bd_pins cpu_control_unit/ma_load_i] [get_bd_pins cpu_external_bus_control/ma_load_o]
  connect_bd_net -net neorv32_cpu_bus_ma_store_o [get_bd_pins cpu_control_unit/ma_store_i] [get_bd_pins cpu_external_bus_control/ma_store_o]
  connect_bd_net -net neorv32_cpu_bus_mar_o [get_bd_pins cpu_control_unit/mar_i] [get_bd_pins cpu_external_bus_control/mar_o]
  connect_bd_net -net neorv32_cpu_bus_rdata_o [get_bd_pins cpu_external_bus_control/rdata_o] [get_bd_pins cpu_regfile/mem_i]
  connect_bd_net -net neorv32_cpu_control_ctrl_o [get_bd_pins cpu_alu/ctrl_i] [get_bd_pins cpu_control_unit/ctrl_o] [get_bd_pins cpu_external_bus_control/ctrl_i] [get_bd_pins cpu_regfile/ctrl_i] [get_bd_pins interface_wishbone_priv_slice/Din]
  connect_bd_net -net neorv32_cpu_control_curr_pc_o [get_bd_pins cpu_alu/pc2_i] [get_bd_pins cpu_control_unit/curr_pc_o]
  connect_bd_net -net neorv32_cpu_control_fetch_pc_o [get_bd_pins cpu_control_unit/fetch_pc_o] [get_bd_pins cpu_external_bus_control/fetch_pc_i]
  connect_bd_net -net neorv32_cpu_control_fpu_rm_o [get_bd_pins cpu_control_unit/fpu_rm_o] [get_bd_pins cpu_control_unit/nm_irq_i]
  connect_bd_net -net neorv32_cpu_control_imm_o [get_bd_pins cpu_alu/imm_i] [get_bd_pins cpu_control_unit/imm_o]
  connect_bd_net -net neorv32_cpu_control_wrapped_pmp_addr_o [get_bd_pins cpu_control_unit/wrapped_pmp_addr_o] [get_bd_pins cpu_external_bus_control/wrapped_pmp_addr_i]
  connect_bd_net -net neorv32_cpu_control_wrapped_pmp_ctrl_o [get_bd_pins cpu_control_unit/wrapped_pmp_ctrl_o] [get_bd_pins cpu_external_bus_control/wrapped_pmp_ctrl_i]
  connect_bd_net -net neorv32_cpu_regfile_cmp_o [get_bd_pins cpu_control_unit/cmp_i] [get_bd_pins cpu_regfile/cmp_o]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_adr_o [get_bd_pins interface_bus_to_wishbone/wb_adr_o] [get_bd_pins interface_wishbone_to_axi/wb_addr]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_cyc_o [get_bd_pins interface_bus_to_wishbone/wb_cyc_o] [get_bd_pins interface_wishbone_to_axi/wb_cyc]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_dat_o [get_bd_pins interface_bus_to_wishbone/wb_dat_o] [get_bd_pins interface_wishbone_to_axi/wb_data_write]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_lock_o [get_bd_pins interface_bus_to_wishbone/wb_lock_o] [get_bd_pins interface_wishbone_to_axi/wb_lock]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_sel_o [get_bd_pins interface_bus_to_wishbone/wb_sel_o] [get_bd_pins interface_wishbone_to_axi/wb_sel]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_stb_o [get_bd_pins interface_bus_to_wishbone/wb_stb_o] [get_bd_pins interface_wishbone_to_axi/wb_stb]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_tag_o [get_bd_pins interface_bus_to_wishbone/wb_tag_o] [get_bd_pins interface_wishbone_to_axi/wb_tag]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_we_o [get_bd_pins interface_bus_to_wishbone/wb_we_o] [get_bd_pins interface_wishbone_to_axi/wb_we]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_ports clock] [get_bd_pins LED_controller/s_axi_aclk] [get_bd_pins button_controller/s_axi_aclk] [get_bd_pins cpu_BRAM_controller/s_axi_aclk] [get_bd_pins cpu_alu/clk_i] [get_bd_pins cpu_control_unit/clk_i] [get_bd_pins cpu_external_bus_control/clk_i] [get_bd_pins cpu_regfile/clk_i] [get_bd_pins interface_bus_keeper/clk_i] [get_bd_pins interface_bus_switch/clk_i] [get_bd_pins interface_bus_to_wishbone/clk_i] [get_bd_pins interface_wishbone_to_axi/m_axi_aclk] [get_bd_pins neo_smartconnect/aclk]
  connect_bd_net -net pull_down_16_bit_dout [get_bd_pins cpu_control_unit/firq_i] [get_bd_pins pull_down_16_bit/dout]
  connect_bd_net -net pull_down_5_bit_dout [get_bd_pins cpu_control_unit/fpu_flags_i] [get_bd_pins pull_down_5_bit/dout]
  connect_bd_net -net pull_down_64_bit_dout [get_bd_pins cpu_control_unit/time_i] [get_bd_pins pull_down_64_bit/dout]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_ports peripheral_reset] [get_bd_pins LED_controller/s_axi_aresetn] [get_bd_pins button_controller/s_axi_aresetn] [get_bd_pins cpu_BRAM_controller/s_axi_aresetn]
  connect_bd_net -net smartconnect_reset_1 [get_bd_ports smartconnect_reset] [get_bd_pins neo_smartconnect/aresetn]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins cpu_control_unit/db_halt_req_i] [get_bd_pins cpu_control_unit/mext_irq_i] [get_bd_pins cpu_control_unit/msw_irq_i] [get_bd_pins cpu_control_unit/mtime_irq_i] [get_bd_pins pull_down_1_bit/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins interface_bus_to_wishbone/priv_i] [get_bd_pins interface_wishbone_priv_slice/Dout]

  # Create address segments
  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces interface_wishbone_to_axi/m_axi] [get_bd_addr_segs LED_controller/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces interface_wishbone_to_axi/m_axi] [get_bd_addr_segs button_controller/S_AXI/Reg] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces interface_wishbone_to_axi/m_axi] [get_bd_addr_segs cpu_BRAM_controller/S_AXI/Mem0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_gid_msg -ssname BD::TCL -id 2053 -severity "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

# Create wrapped and set as top
make_wrapper -files [get_files ./myproj/project_1.srcs/sources_1/bd/rv32i_overlay/rv32i_overlay.bd] -top
add_files -norecurse ./myproj/project_1.srcs/sources_1/bd/rv32i_overlay/hdl/rv32i_overlay_wrapper.v
update_compile_order -fileset sources_1
set_property top rv32i_overlay_wrapper [current_fileset]
update_compile_order -fileset sources_1
