
################################################################
# This is a generated script based on design: rv32i_overlay
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
# source rv32i_overlay_script.tcl

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
set design_name rv32i_overlay

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
xilinx.com:user:processor_stepper:1.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:user:neo_capture_harness:1.1\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:proc_sys_reset:5.0\
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
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  set btns_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 btns_4bits ]

  set leds_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]


  # Create ports

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
   CONFIG.EN_SAFETY_CKT {true} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Load_Init_File {false} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
   CONFIG.Use_Byte_Write_Enable {true} \
   CONFIG.Use_RSTA_Pin {true} \
   CONFIG.Use_RSTB_Pin {true} \
   CONFIG.use_bram_block {BRAM_Controller} \
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

  # Create instance: cpu_clock_stepper, and set properties
  set cpu_clock_stepper [ create_bd_cell -type ip -vlnv xilinx.com:user:processor_stepper:1.0 cpu_clock_stepper ]

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
   CONFIG.DIN_WIDTH {74} \
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

  # Create instance: neo_signal_capture, and set properties
  set neo_signal_capture [ create_bd_cell -type ip -vlnv xilinx.com:user:neo_capture_harness:1.1 neo_signal_capture ]

  # Create instance: neo_smartconnect, and set properties
  set neo_smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 neo_smartconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
 ] $neo_smartconnect

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {650.000000} \
   CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095} \
   CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.096154} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
   CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {650} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {26} \
   CONFIG.PCW_CAN0_BASEADDR {0xE0008000} \
   CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
   CONFIG.PCW_CAN0_HIGHADDR {0xE0008FFF} \
   CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_CAN0_PERIPHERAL_FREQMHZ {-1} \
   CONFIG.PCW_CAN1_BASEADDR {0xE0009000} \
   CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
   CONFIG.PCW_CAN1_HIGHADDR {0xE0009FFF} \
   CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_CAN1_PERIPHERAL_FREQMHZ {-1} \
   CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
   CONFIG.PCW_CLK0_FREQ {100000000} \
   CONFIG.PCW_CLK1_FREQ {100000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CORE0_FIQ_INTR {0} \
   CONFIG.PCW_CORE0_IRQ_INTR {0} \
   CONFIG.PCW_CORE1_FIQ_INTR {0} \
   CONFIG.PCW_CORE1_IRQ_INTR {0} \
   CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1300.000} \
   CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {52} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {21} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1050.000} \
   CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
   CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
   CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
   CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
   CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
   CONFIG.PCW_DM_WIDTH {4} \
   CONFIG.PCW_DQS_WIDTH {4} \
   CONFIG.PCW_DQ_WIDTH {32} \
   CONFIG.PCW_ENET0_BASEADDR {0xE000B000} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
   CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} \
   CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {1} \
   CONFIG.PCW_ENET0_RESET_IO {MIO 9} \
   CONFIG.PCW_ENET1_BASEADDR {0xE000C000} \
   CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
   CONFIG.PCW_ENET1_HIGHADDR {0xE000CFFF} \
   CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_4K_TIMER {0} \
   CONFIG.PCW_EN_CAN0 {0} \
   CONFIG.PCW_EN_CAN1 {0} \
   CONFIG.PCW_EN_CLK0_PORT {1} \
   CONFIG.PCW_EN_CLK1_PORT {1} \
   CONFIG.PCW_EN_CLK2_PORT {0} \
   CONFIG.PCW_EN_CLK3_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG0_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG1_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG2_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG3_PORT {0} \
   CONFIG.PCW_EN_DDR {1} \
   CONFIG.PCW_EN_EMIO_CAN0 {0} \
   CONFIG.PCW_EN_EMIO_CAN1 {0} \
   CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
   CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
   CONFIG.PCW_EN_EMIO_ENET0 {0} \
   CONFIG.PCW_EN_EMIO_ENET1 {0} \
   CONFIG.PCW_EN_EMIO_GPIO {1} \
   CONFIG.PCW_EN_EMIO_I2C0 {0} \
   CONFIG.PCW_EN_EMIO_I2C1 {0} \
   CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
   CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
   CONFIG.PCW_EN_EMIO_PJTAG {0} \
   CONFIG.PCW_EN_EMIO_SDIO0 {0} \
   CONFIG.PCW_EN_EMIO_SDIO1 {0} \
   CONFIG.PCW_EN_EMIO_SPI0 {0} \
   CONFIG.PCW_EN_EMIO_SPI1 {0} \
   CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
   CONFIG.PCW_EN_EMIO_TRACE {0} \
   CONFIG.PCW_EN_EMIO_TTC0 {0} \
   CONFIG.PCW_EN_EMIO_TTC1 {0} \
   CONFIG.PCW_EN_EMIO_UART0 {0} \
   CONFIG.PCW_EN_EMIO_UART1 {0} \
   CONFIG.PCW_EN_EMIO_WDT {0} \
   CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
   CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_ENET1 {0} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_I2C0 {0} \
   CONFIG.PCW_EN_I2C1 {0} \
   CONFIG.PCW_EN_MODEM_UART0 {0} \
   CONFIG.PCW_EN_MODEM_UART1 {0} \
   CONFIG.PCW_EN_PJTAG {0} \
   CONFIG.PCW_EN_PTP_ENET0 {0} \
   CONFIG.PCW_EN_PTP_ENET1 {0} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_RST0_PORT {1} \
   CONFIG.PCW_EN_RST1_PORT {0} \
   CONFIG.PCW_EN_RST2_PORT {0} \
   CONFIG.PCW_EN_RST3_PORT {0} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_SDIO1 {0} \
   CONFIG.PCW_EN_SMC {0} \
   CONFIG.PCW_EN_SPI0 {0} \
   CONFIG.PCW_EN_SPI1 {0} \
   CONFIG.PCW_EN_TRACE {0} \
   CONFIG.PCW_EN_TTC0 {0} \
   CONFIG.PCW_EN_TTC1 {0} \
   CONFIG.PCW_EN_UART0 {0} \
   CONFIG.PCW_EN_UART1 {0} \
   CONFIG.PCW_EN_USB0 {0} \
   CONFIG.PCW_EN_USB1 {0} \
   CONFIG.PCW_EN_WDT {0} \
   CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
   CONFIG.PCW_FCLK_CLK1_BUF {FALSE} \
   CONFIG.PCW_FCLK_CLK2_BUF {FALSE} \
   CONFIG.PCW_FCLK_CLK3_BUF {FALSE} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_GP0_EN_MODIFIABLE_TXN {1} \
   CONFIG.PCW_GP0_NUM_READ_THREADS {4} \
   CONFIG.PCW_GP0_NUM_WRITE_THREADS {4} \
   CONFIG.PCW_GP1_EN_MODIFIABLE_TXN {1} \
   CONFIG.PCW_GP1_NUM_READ_THREADS {4} \
   CONFIG.PCW_GP1_NUM_WRITE_THREADS {4} \
   CONFIG.PCW_GPIO_BASEADDR {0xE000A000} \
   CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
   CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} \
   CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C0_BASEADDR {0xE0004000} \
   CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} \
   CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_BASEADDR {0xE0005000} \
   CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C1_HIGHADDR {0xE0005FFF} \
   CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
   CONFIG.PCW_IMPORT_BOARD_PRESET {None} \
   CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} \
   CONFIG.PCW_INCLUDE_TRACE_BUFFER {0} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {20} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_IRQ_F2P_INTR {0} \
   CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {enabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {inout} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {inout} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_16_PULLUP {enabled} \
   CONFIG.PCW_MIO_16_SLEW {slow} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_17_PULLUP {enabled} \
   CONFIG.PCW_MIO_17_SLEW {slow} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_18_PULLUP {enabled} \
   CONFIG.PCW_MIO_18_SLEW {slow} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_19_PULLUP {enabled} \
   CONFIG.PCW_MIO_19_SLEW {slow} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_20_PULLUP {enabled} \
   CONFIG.PCW_MIO_20_SLEW {slow} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_21_PULLUP {enabled} \
   CONFIG.PCW_MIO_21_SLEW {slow} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_22_PULLUP {enabled} \
   CONFIG.PCW_MIO_22_SLEW {slow} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_23_PULLUP {enabled} \
   CONFIG.PCW_MIO_23_SLEW {slow} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_24_PULLUP {enabled} \
   CONFIG.PCW_MIO_24_SLEW {slow} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_25_PULLUP {enabled} \
   CONFIG.PCW_MIO_25_SLEW {slow} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_26_PULLUP {enabled} \
   CONFIG.PCW_MIO_26_SLEW {slow} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_27_PULLUP {enabled} \
   CONFIG.PCW_MIO_27_SLEW {slow} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_28_PULLUP {enabled} \
   CONFIG.PCW_MIO_28_SLEW {slow} \
   CONFIG.PCW_MIO_29_DIRECTION {inout} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_29_PULLUP {enabled} \
   CONFIG.PCW_MIO_29_SLEW {slow} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {inout} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_30_PULLUP {enabled} \
   CONFIG.PCW_MIO_30_SLEW {slow} \
   CONFIG.PCW_MIO_31_DIRECTION {inout} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_31_PULLUP {enabled} \
   CONFIG.PCW_MIO_31_SLEW {slow} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_32_PULLUP {enabled} \
   CONFIG.PCW_MIO_32_SLEW {slow} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_33_PULLUP {enabled} \
   CONFIG.PCW_MIO_33_SLEW {slow} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_34_PULLUP {enabled} \
   CONFIG.PCW_MIO_34_SLEW {slow} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_35_PULLUP {enabled} \
   CONFIG.PCW_MIO_35_SLEW {slow} \
   CONFIG.PCW_MIO_36_DIRECTION {inout} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_36_PULLUP {enabled} \
   CONFIG.PCW_MIO_36_SLEW {slow} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_37_PULLUP {enabled} \
   CONFIG.PCW_MIO_37_SLEW {slow} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_38_PULLUP {enabled} \
   CONFIG.PCW_MIO_38_SLEW {slow} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_39_PULLUP {enabled} \
   CONFIG.PCW_MIO_39_SLEW {slow} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {enabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {enabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {enabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {enabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {enabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {enabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {inout} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {in} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {inout} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {inout} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {out} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_52_PULLUP {enabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_53_PULLUP {enabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {out} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_PRIMITIVE {54} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#Quad SPI Flash#ENET Reset#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO#SD 0#GPIO#GPIO#GPIO#GPIO#Enet 0#Enet 0} \
   CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#qspi_fbclk#reset#gpio[10]#gpio[11]#gpio[12]#gpio[13]#gpio[14]#gpio[15]#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#gpio[28]#gpio[29]#gpio[30]#gpio[31]#gpio[32]#gpio[33]#gpio[34]#gpio[35]#gpio[36]#gpio[37]#gpio[38]#gpio[39]#clk#cmd#data[0]#data[1]#data[2]#data[3]#gpio[46]#cd#gpio[48]#gpio[49]#gpio[50]#gpio[51]#mdc#mdio} \
   CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} \
   CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} \
   CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} \
   CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} \
   CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {0} \
   CONFIG.PCW_M_AXI_GP1_ID_WIDTH {12} \
   CONFIG.PCW_M_AXI_GP1_SUPPORT_NARROW_BURST {0} \
   CONFIG.PCW_M_AXI_GP1_THREAD_ID_WIDTH {12} \
   CONFIG.PCW_NAND_CYCLES_T_AR {1} \
   CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
   CONFIG.PCW_NAND_CYCLES_T_RC {11} \
   CONFIG.PCW_NAND_CYCLES_T_REA {1} \
   CONFIG.PCW_NAND_CYCLES_T_RR {1} \
   CONFIG.PCW_NAND_CYCLES_T_WC {11} \
   CONFIG.PCW_NAND_CYCLES_T_WP {1} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_CS0_T_CEOE {1} \
   CONFIG.PCW_NOR_CS0_T_PC {1} \
   CONFIG.PCW_NOR_CS0_T_RC {11} \
   CONFIG.PCW_NOR_CS0_T_TR {1} \
   CONFIG.PCW_NOR_CS0_T_WC {11} \
   CONFIG.PCW_NOR_CS0_T_WP {1} \
   CONFIG.PCW_NOR_CS0_WE_TIME {0} \
   CONFIG.PCW_NOR_CS1_T_CEOE {1} \
   CONFIG.PCW_NOR_CS1_T_PC {1} \
   CONFIG.PCW_NOR_CS1_T_RC {11} \
   CONFIG.PCW_NOR_CS1_T_TR {1} \
   CONFIG.PCW_NOR_CS1_T_WC {11} \
   CONFIG.PCW_NOR_CS1_T_WP {1} \
   CONFIG.PCW_NOR_CS1_WE_TIME {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
   CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
   CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
   CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
   CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
   CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
   CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
   CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
   CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
   CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
   CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
   CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
   CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
   CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
   CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
   CONFIG.PCW_P2F_CAN0_INTR {0} \
   CONFIG.PCW_P2F_CAN1_INTR {0} \
   CONFIG.PCW_P2F_CTI_INTR {0} \
   CONFIG.PCW_P2F_DMAC0_INTR {0} \
   CONFIG.PCW_P2F_DMAC1_INTR {0} \
   CONFIG.PCW_P2F_DMAC2_INTR {0} \
   CONFIG.PCW_P2F_DMAC3_INTR {0} \
   CONFIG.PCW_P2F_DMAC4_INTR {0} \
   CONFIG.PCW_P2F_DMAC5_INTR {0} \
   CONFIG.PCW_P2F_DMAC6_INTR {0} \
   CONFIG.PCW_P2F_DMAC7_INTR {0} \
   CONFIG.PCW_P2F_DMAC_ABORT_INTR {0} \
   CONFIG.PCW_P2F_ENET0_INTR {0} \
   CONFIG.PCW_P2F_ENET1_INTR {0} \
   CONFIG.PCW_P2F_GPIO_INTR {0} \
   CONFIG.PCW_P2F_I2C0_INTR {0} \
   CONFIG.PCW_P2F_I2C1_INTR {0} \
   CONFIG.PCW_P2F_QSPI_INTR {0} \
   CONFIG.PCW_P2F_SDIO0_INTR {0} \
   CONFIG.PCW_P2F_SDIO1_INTR {0} \
   CONFIG.PCW_P2F_SMC_INTR {0} \
   CONFIG.PCW_P2F_SPI0_INTR {0} \
   CONFIG.PCW_P2F_SPI1_INTR {0} \
   CONFIG.PCW_P2F_UART0_INTR {0} \
   CONFIG.PCW_P2F_UART1_INTR {0} \
   CONFIG.PCW_P2F_USB0_INTR {0} \
   CONFIG.PCW_P2F_USB1_INTR {0} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.279} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.260} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.085} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.092} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.051} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.006} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.009} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.033} \
   CONFIG.PCW_PACKAGE_NAME {clg400} \
   CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_PERIPHERAL_BOARD_PRESET {part0} \
   CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
   CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_PS7_SI_REV {PRODUCTION} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
   CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
   CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SD1_GRP_CD_ENABLE {0} \
   CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD1_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} \
   CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} \
   CONFIG.PCW_SDIO1_BASEADDR {0xE0101000} \
   CONFIG.PCW_SDIO1_HIGHADDR {0xE0101FFF} \
   CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
   CONFIG.PCW_SMC_CYCLE_T0 {NA} \
   CONFIG.PCW_SMC_CYCLE_T1 {NA} \
   CONFIG.PCW_SMC_CYCLE_T2 {NA} \
   CONFIG.PCW_SMC_CYCLE_T3 {NA} \
   CONFIG.PCW_SMC_CYCLE_T4 {NA} \
   CONFIG.PCW_SMC_CYCLE_T5 {NA} \
   CONFIG.PCW_SMC_CYCLE_T6 {NA} \
   CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SMC_PERIPHERAL_VALID {0} \
   CONFIG.PCW_SPI0_BASEADDR {0xE0006000} \
   CONFIG.PCW_SPI0_GRP_SS0_ENABLE {0} \
   CONFIG.PCW_SPI0_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_SPI0_GRP_SS2_ENABLE {0} \
   CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF} \
   CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_SPI1_BASEADDR {0xE0007000} \
   CONFIG.PCW_SPI1_GRP_SS0_ENABLE {0} \
   CONFIG.PCW_SPI1_GRP_SS0_IO {<Select>} \
   CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_SPI1_GRP_SS1_IO {<Select>} \
   CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
   CONFIG.PCW_SPI1_GRP_SS2_IO {<Select>} \
   CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF} \
   CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_SPI1_SPI1_IO {<Select>} \
   CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
   CONFIG.PCW_SPI_PERIPHERAL_VALID {0} \
   CONFIG.PCW_S_AXI_ACP_ARUSER_VAL {31} \
   CONFIG.PCW_S_AXI_ACP_AWUSER_VAL {31} \
   CONFIG.PCW_S_AXI_ACP_ID_WIDTH {3} \
   CONFIG.PCW_S_AXI_GP0_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_GP1_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP1_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP2_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP3_ID_WIDTH {6} \
   CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_TRACE_BUFFER_CLOCK_DELAY {12} \
   CONFIG.PCW_TRACE_BUFFER_FIFO_SIZE {128} \
   CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
   CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_TRACE_PIPELINE_WIDTH {8} \
   CONFIG.PCW_TTC0_BASEADDR {0xE0104000} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff} \
   CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_TTC1_BASEADDR {0xE0105000} \
   CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC1_HIGHADDR {0xE0105fff} \
   CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART0_BASEADDR {0xE0000000} \
   CONFIG.PCW_UART0_BAUD_RATE {115200} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_UART0_UART0_IO {<Select>} \
   CONFIG.PCW_UART1_BASEADDR {0xE0001000} \
   CONFIG.PCW_UART1_BAUD_RATE {115200} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {0} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {525.000000} \
   CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
   CONFIG.PCW_UIPARAM_DDR_AL {0} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BL {8} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.279} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.260} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.085} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.092} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {27.95} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {27.95} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {80.4535} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {32.14} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {105.056} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {31.12} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {66.904} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {89.1715} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {113.63} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.051} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.006} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.009} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.033} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {32.2} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {98.503} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {31.08} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {68.5855} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {90.295} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {103.977} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
   CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {525} \
   CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
   CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {48.91} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
   CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} \
   CONFIG.PCW_USB0_BASEADDR {0xE0102000} \
   CONFIG.PCW_USB0_HIGHADDR {0xE0102fff} \
   CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB0_RESET_ENABLE {0} \
   CONFIG.PCW_USB0_RESET_IO {<Select>} \
   CONFIG.PCW_USB0_USB0_IO {<Select>} \
   CONFIG.PCW_USB1_BASEADDR {0xE0103000} \
   CONFIG.PCW_USB1_HIGHADDR {0xE0103fff} \
   CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
   CONFIG.PCW_USB_RESET_SELECT {<Select>} \
   CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} \
   CONFIG.PCW_USE_AXI_NONSECURE {0} \
   CONFIG.PCW_USE_CORESIGHT {0} \
   CONFIG.PCW_USE_CROSS_TRIGGER {0} \
   CONFIG.PCW_USE_CR_FABRIC {1} \
   CONFIG.PCW_USE_DDR_BYPASS {0} \
   CONFIG.PCW_USE_DEBUG {0} \
   CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {0} \
   CONFIG.PCW_USE_DMA0 {0} \
   CONFIG.PCW_USE_DMA1 {0} \
   CONFIG.PCW_USE_DMA2 {0} \
   CONFIG.PCW_USE_DMA3 {0} \
   CONFIG.PCW_USE_EXPANDED_IOP {0} \
   CONFIG.PCW_USE_EXPANDED_PS_SLCR_REGISTERS {0} \
   CONFIG.PCW_USE_FABRIC_INTERRUPT {0} \
   CONFIG.PCW_USE_HIGH_OCM {0} \
   CONFIG.PCW_USE_M_AXI_GP0 {1} \
   CONFIG.PCW_USE_M_AXI_GP1 {0} \
   CONFIG.PCW_USE_PROC_EVENT_BUS {0} \
   CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} \
   CONFIG.PCW_USE_S_AXI_ACP {0} \
   CONFIG.PCW_USE_S_AXI_GP0 {0} \
   CONFIG.PCW_USE_S_AXI_GP1 {0} \
   CONFIG.PCW_USE_S_AXI_HP0 {0} \
   CONFIG.PCW_USE_S_AXI_HP1 {0} \
   CONFIG.PCW_USE_S_AXI_HP2 {0} \
   CONFIG.PCW_USE_S_AXI_HP3 {0} \
   CONFIG.PCW_USE_TRACE {0} \
   CONFIG.PCW_USE_TRACE_DATA_EDGE_DETECTOR {0} \
   CONFIG.PCW_VALUE_SILVERSION {3} \
   CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
 ] $processing_system7_0

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

  # Create instance: pynq_BRAM_controller, and set properties
  set pynq_BRAM_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 pynq_BRAM_controller ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $pynq_BRAM_controller

  # Create instance: pynq_GPIO_neo_reset_slice, and set properties
  set pynq_GPIO_neo_reset_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pynq_GPIO_neo_reset_slice ]
  set_property -dict [ list \
   CONFIG.DIN_WIDTH {64} \
 ] $pynq_GPIO_neo_reset_slice

  # Create instance: pynq_smartconnect, and set properties
  set pynq_smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 pynq_smartconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
 ] $pynq_smartconnect

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps7_0_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net LED_controller_GPIO [get_bd_intf_ports leds_4bits] [get_bd_intf_pins LED_controller/GPIO]
  connect_bd_intf_net -intf_net button_controller_GPIO [get_bd_intf_ports btns_4bits] [get_bd_intf_pins button_controller/GPIO]
  connect_bd_intf_net -intf_net interface_wishbone_to_axi_m_axi [get_bd_intf_pins interface_wishbone_to_axi/m_axi] [get_bd_intf_pins neo_smartconnect/S00_AXI]
  connect_bd_intf_net -intf_net neo_smartconnect_M00_AXI [get_bd_intf_pins cpu_BRAM_controller/S_AXI] [get_bd_intf_pins neo_smartconnect/M00_AXI]
  connect_bd_intf_net -intf_net neo_smartconnect_M01_AXI [get_bd_intf_pins LED_controller/S_AXI] [get_bd_intf_pins neo_smartconnect/M01_AXI]
  connect_bd_intf_net -intf_net neo_smartconnect_M02_AXI [get_bd_intf_pins button_controller/S_AXI] [get_bd_intf_pins neo_smartconnect/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins pynq_smartconnect/S00_AXI]
  connect_bd_intf_net -intf_net pynq_BRAM_controller_BRAM_PORTA [get_bd_intf_pins cpu_BRAM_controller_bram/BRAM_PORTA] [get_bd_intf_pins pynq_BRAM_controller/BRAM_PORTA]
  connect_bd_intf_net -intf_net pynq_smartconnect_M00_AXI [get_bd_intf_pins pynq_BRAM_controller/S_AXI] [get_bd_intf_pins pynq_smartconnect/M00_AXI]
  connect_bd_intf_net -intf_net pynq_smartconnect_M01_AXI [get_bd_intf_pins cpu_clock_stepper/S00_AXI] [get_bd_intf_pins pynq_smartconnect/M01_AXI]
  connect_bd_intf_net -intf_net pynq_smartconnect_M02_AXI [get_bd_intf_pins neo_signal_capture/S00_AXI] [get_bd_intf_pins pynq_smartconnect/M02_AXI]

  # Create port connections
  connect_bd_net -net BD_neorv32_busswitch_0_ca_bus_ack_o [get_bd_pins cpu_external_bus_control/d_bus_ack_i] [get_bd_pins interface_bus_switch/ca_bus_ack_o] [get_bd_pins neo_signal_capture/data_bus_ack]
  connect_bd_net -net BD_neorv32_busswitch_0_ca_bus_err_o [get_bd_pins cpu_external_bus_control/d_bus_err_i] [get_bd_pins interface_bus_switch/ca_bus_err_o] [get_bd_pins neo_signal_capture/data_bus_err]
  connect_bd_net -net BD_neorv32_busswitch_0_ca_bus_rdata_o [get_bd_pins cpu_external_bus_control/d_bus_rdata_i] [get_bd_pins interface_bus_switch/ca_bus_rdata_o] [get_bd_pins neo_signal_capture/data_bus_read_data]
  connect_bd_net -net BD_neorv32_busswitch_0_cb_bus_ack_o [get_bd_pins cpu_external_bus_control/i_bus_ack_i] [get_bd_pins interface_bus_switch/cb_bus_ack_o] [get_bd_pins neo_signal_capture/instr_bus_ack]
  connect_bd_net -net BD_neorv32_busswitch_0_cb_bus_err_o [get_bd_pins cpu_external_bus_control/i_bus_err_i] [get_bd_pins interface_bus_switch/cb_bus_err_o] [get_bd_pins neo_signal_capture/instr_bus_err]
  connect_bd_net -net BD_neorv32_busswitch_0_cb_bus_rdata_o [get_bd_pins cpu_external_bus_control/i_bus_rdata_i] [get_bd_pins interface_bus_switch/cb_bus_rdata_o] [get_bd_pins neo_signal_capture/instr_bus_read_data]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_addr_o [get_bd_pins interface_bus_keeper/addr_i] [get_bd_pins interface_bus_switch/p_bus_addr_o] [get_bd_pins interface_bus_to_wishbone/addr_i] [get_bd_pins neo_signal_capture/external_bus_addr]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_ben_o [get_bd_pins interface_bus_switch/p_bus_ben_o] [get_bd_pins interface_bus_to_wishbone/ben_i] [get_bd_pins neo_signal_capture/external_bus_byte_enable]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_lock_o [get_bd_pins interface_bus_switch/p_bus_lock_o] [get_bd_pins interface_bus_to_wishbone/lock_i] [get_bd_pins neo_signal_capture/external_bus_lock]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_re_o [get_bd_pins interface_bus_keeper/rden_i] [get_bd_pins interface_bus_switch/p_bus_re_o] [get_bd_pins interface_bus_to_wishbone/rden_i] [get_bd_pins neo_signal_capture/external_bus_read_enable]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_src_o [get_bd_pins interface_bus_switch/p_bus_src_o] [get_bd_pins interface_bus_to_wishbone/src_i] [get_bd_pins neo_signal_capture/external_bus_src]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_wdata_o [get_bd_pins interface_bus_switch/p_bus_wdata_o] [get_bd_pins interface_bus_to_wishbone/data_i] [get_bd_pins neo_signal_capture/external_bus_write_data]
  connect_bd_net -net BD_neorv32_busswitch_0_p_bus_we_o [get_bd_pins interface_bus_keeper/wren_i] [get_bd_pins interface_bus_switch/p_bus_we_o] [get_bd_pins interface_bus_to_wishbone/wren_i] [get_bd_pins neo_signal_capture/external_bus_write_enable]
  connect_bd_net -net BD_neorv32_cpu_alu_0_res_o [get_bd_pins cpu_alu/res_o] [get_bd_pins cpu_regfile/alu_i] [get_bd_pins neo_signal_capture/alu_result]
  connect_bd_net -net BD_neorv32_cpu_regfi_0_rs1_o [get_bd_pins cpu_alu/rs1_i] [get_bd_pins cpu_control_unit/rs1_i] [get_bd_pins cpu_regfile/rs1_o] [get_bd_pins neo_signal_capture/regfile_read_0]
  connect_bd_net -net BD_neorv32_cpu_regfi_0_rs2_o [get_bd_pins cpu_alu/rs2_i] [get_bd_pins cpu_external_bus_control/wdata_i] [get_bd_pins cpu_regfile/rs2_o] [get_bd_pins neo_signal_capture/regfile_read_1]
  connect_bd_net -net BD_neorv32_wishbone_0_ack_o [get_bd_pins interface_bus_keeper/ack_i] [get_bd_pins interface_bus_switch/p_bus_ack_i] [get_bd_pins interface_bus_to_wishbone/ack_o] [get_bd_pins neo_signal_capture/external_bus_ack]
  connect_bd_net -net BD_neorv32_wishbone_0_data_o [get_bd_pins interface_bus_switch/p_bus_rdata_i] [get_bd_pins interface_bus_to_wishbone/data_o] [get_bd_pins neo_signal_capture/external_bus_read_data]
  connect_bd_net -net BD_wishbon_axi4lite_0_wb_ack [get_bd_pins interface_bus_to_wishbone/wb_ack_i] [get_bd_pins interface_wishbone_to_axi/wb_ack] [get_bd_pins neo_signal_capture/wishbone_ack]
  connect_bd_net -net BD_wishbon_axi4lite_0_wb_data_read [get_bd_pins interface_bus_to_wishbone/wb_dat_i] [get_bd_pins interface_wishbone_to_axi/wb_data_read] [get_bd_pins neo_signal_capture/wishbone_read_data]
  connect_bd_net -net BD_wishbon_axi4lite_0_wb_err [get_bd_pins interface_bus_to_wishbone/wb_err_i] [get_bd_pins interface_wishbone_to_axi/wb_err] [get_bd_pins neo_signal_capture/wishbone_err]
  connect_bd_net -net Net [get_bd_pins cpu_alu/rstn_i] [get_bd_pins cpu_control_unit/rstn_i] [get_bd_pins cpu_external_bus_control/rstn_i] [get_bd_pins interface_bus_keeper/rstn_i] [get_bd_pins interface_bus_switch/rstn_i] [get_bd_pins interface_bus_to_wishbone/rstn_i] [get_bd_pins interface_wishbone_to_axi/m_axi_aresetn] [get_bd_pins pynq_GPIO_neo_reset_slice/Dout]
  connect_bd_net -net Net20 [get_bd_pins cpu_BRAM_controller/bram_rddata_a] [get_bd_pins cpu_BRAM_controller_bram/doutb] [get_bd_pins neo_signal_capture/BRAM_read_data]
  connect_bd_net -net Net21 [get_bd_pins LED_controller/s_axi_arready] [get_bd_pins LED_controller/s_axi_rready] [get_bd_pins neo_signal_capture/LEDs_axi_arready] [get_bd_pins neo_smartconnect/M01_AXI_arready]
  connect_bd_net -net Net22 [get_bd_pins LED_controller/s_axi_rdata] [get_bd_pins neo_signal_capture/LEDs_axi_rdata] [get_bd_pins neo_smartconnect/M01_AXI_rdata]
  connect_bd_net -net Net23 [get_bd_pins LED_controller/s_axi_rresp] [get_bd_pins neo_signal_capture/LEDs_axi_rresp] [get_bd_pins neo_smartconnect/M01_AXI_rresp]
  connect_bd_net -net Net24 [get_bd_pins LED_controller/s_axi_rvalid] [get_bd_pins neo_signal_capture/LEDs_axi_rvalid] [get_bd_pins neo_smartconnect/M01_AXI_rvalid]
  connect_bd_net -net Net25 [get_bd_pins LED_controller/s_axi_awready] [get_bd_pins neo_signal_capture/LEDs_axi_awready] [get_bd_pins neo_smartconnect/M01_AXI_awready]
  connect_bd_net -net Net26 [get_bd_pins LED_controller/s_axi_wready] [get_bd_pins neo_signal_capture/LEDs_axi_wready] [get_bd_pins neo_smartconnect/M01_AXI_wready]
  connect_bd_net -net Net27 [get_bd_pins LED_controller/s_axi_bresp] [get_bd_pins neo_signal_capture/LEDs_axi_bresp] [get_bd_pins neo_smartconnect/M01_AXI_bresp]
  connect_bd_net -net Net28 [get_bd_pins LED_controller/s_axi_bvalid] [get_bd_pins neo_signal_capture/LEDs_axi_bvalid] [get_bd_pins neo_smartconnect/M01_AXI_bvalid]
  connect_bd_net -net Net30 [get_bd_pins button_controller/s_axi_arready] [get_bd_pins neo_signal_capture/buttons_axi_arready] [get_bd_pins neo_smartconnect/M02_AXI_arready]
  connect_bd_net -net Net31 [get_bd_pins button_controller/s_axi_rdata] [get_bd_pins neo_signal_capture/buttons_axi_rdata] [get_bd_pins neo_smartconnect/M02_AXI_rdata]
  connect_bd_net -net Net32 [get_bd_pins button_controller/s_axi_rresp] [get_bd_pins neo_signal_capture/buttons_axi_rresp] [get_bd_pins neo_smartconnect/M02_AXI_rresp]
  connect_bd_net -net Net33 [get_bd_pins button_controller/s_axi_rvalid] [get_bd_pins neo_signal_capture/buttons_axi_rvalid] [get_bd_pins neo_smartconnect/M02_AXI_rvalid]
  connect_bd_net -net Net34 [get_bd_pins button_controller/s_axi_awready] [get_bd_pins neo_signal_capture/buttons_axi_awready] [get_bd_pins neo_smartconnect/M02_AXI_awready]
  connect_bd_net -net Net35 [get_bd_pins button_controller/s_axi_wready] [get_bd_pins neo_signal_capture/buttons_axi_wready] [get_bd_pins neo_smartconnect/M02_AXI_wready]
  connect_bd_net -net Net36 [get_bd_pins button_controller/s_axi_bresp] [get_bd_pins neo_signal_capture/buttons_axi_bresp] [get_bd_pins neo_smartconnect/M02_AXI_bresp]
  connect_bd_net -net Net37 [get_bd_pins button_controller/s_axi_bvalid] [get_bd_pins neo_signal_capture/buttons_axi_bvalid] [get_bd_pins neo_smartconnect/M02_AXI_bvalid]
  connect_bd_net -net at_0_dout [get_bd_pins cpu_alu/wrapped_cp_result_i] [get_bd_pins cpu_cp_result_concat/dout] [get_bd_pins neo_signal_capture/coprocessor_results]
  connect_bd_net -net cpu_BRAM_controller_bram_addr_a [get_bd_pins cpu_BRAM_controller/bram_addr_a] [get_bd_pins cpu_BRAM_controller_bram/addrb] [get_bd_pins neo_signal_capture/BRAM_addr]
  connect_bd_net -net cpu_BRAM_controller_bram_clk_a [get_bd_pins cpu_BRAM_controller/bram_clk_a] [get_bd_pins cpu_BRAM_controller_bram/clkb]
  connect_bd_net -net cpu_BRAM_controller_bram_en_a [get_bd_pins cpu_BRAM_controller/bram_en_a] [get_bd_pins cpu_BRAM_controller_bram/enb] [get_bd_pins neo_signal_capture/BRAM_enable]
  connect_bd_net -net cpu_BRAM_controller_bram_rst_a [get_bd_pins cpu_BRAM_controller/bram_rst_a] [get_bd_pins cpu_BRAM_controller_bram/rstb]
  connect_bd_net -net cpu_BRAM_controller_bram_we_a [get_bd_pins cpu_BRAM_controller/bram_we_a] [get_bd_pins cpu_BRAM_controller_bram/web] [get_bd_pins neo_signal_capture/BRAM_write_data]
  connect_bd_net -net cpu_BRAM_controller_bram_wrdata_a [get_bd_pins cpu_BRAM_controller/bram_wrdata_a] [get_bd_pins cpu_BRAM_controller_bram/dinb] [get_bd_pins neo_signal_capture/BRAM_write_enable]
  connect_bd_net -net cpu_BRAM_controller_s_axi_arready [get_bd_pins cpu_BRAM_controller/s_axi_arready] [get_bd_pins neo_signal_capture/BRAM_axi_arready] [get_bd_pins neo_smartconnect/M00_AXI_arready]
  connect_bd_net -net cpu_BRAM_controller_s_axi_awready [get_bd_pins cpu_BRAM_controller/s_axi_awready] [get_bd_pins neo_signal_capture/BRAM_axi_awready] [get_bd_pins neo_smartconnect/M00_AXI_awready]
  connect_bd_net -net cpu_BRAM_controller_s_axi_bresp [get_bd_pins cpu_BRAM_controller/s_axi_bresp] [get_bd_pins neo_signal_capture/BRAM_axi_bresp] [get_bd_pins neo_smartconnect/M00_AXI_bresp]
  connect_bd_net -net cpu_BRAM_controller_s_axi_bvalid [get_bd_pins cpu_BRAM_controller/s_axi_bvalid] [get_bd_pins neo_signal_capture/BRAM_axi_bvalid] [get_bd_pins neo_smartconnect/M00_AXI_bvalid]
  connect_bd_net -net cpu_BRAM_controller_s_axi_rdata [get_bd_pins cpu_BRAM_controller/s_axi_rdata] [get_bd_pins neo_signal_capture/BRAM_axi_rdata] [get_bd_pins neo_smartconnect/M00_AXI_rdata]
  connect_bd_net -net cpu_BRAM_controller_s_axi_rresp [get_bd_pins cpu_BRAM_controller/s_axi_rresp] [get_bd_pins neo_signal_capture/BRAM_axi_rresp] [get_bd_pins neo_smartconnect/M00_AXI_rresp]
  connect_bd_net -net cpu_BRAM_controller_s_axi_rvalid [get_bd_pins cpu_BRAM_controller/s_axi_rvalid] [get_bd_pins neo_signal_capture/BRAM_axi_rvalid] [get_bd_pins neo_smartconnect/M00_AXI_rvalid]
  connect_bd_net -net cpu_BRAM_controller_s_axi_wready [get_bd_pins cpu_BRAM_controller/s_axi_wready] [get_bd_pins neo_signal_capture/BRAM_axi_wready] [get_bd_pins neo_smartconnect/M00_AXI_wready]
  connect_bd_net -net cpu_control_unit_csr_rdata_o [get_bd_pins cpu_control_unit/csr_rdata_o] [get_bd_pins cpu_cp_result_concat/In0]
  connect_bd_net -net cpu_cp_0_start_slice_Dout [get_bd_pins cpu_cp_0_start_slice/Dout] [get_bd_pins cpu_cp_valid_concat/In0]
  connect_bd_net -net cpu_external_bus_control_d_bus_fence_o [get_bd_pins cpu_external_bus_control/d_bus_fence_o] [get_bd_pins neo_signal_capture/data_bus_fence]
  connect_bd_net -net cpu_external_bus_control_i_bus_fence_o [get_bd_pins cpu_external_bus_control/i_bus_fence_o] [get_bd_pins neo_signal_capture/instr_bus_fence]
  connect_bd_net -net interface_bus_err_or_Res [get_bd_pins interface_bus_err_or/Res] [get_bd_pins interface_bus_switch/p_bus_err_i] [get_bd_pins neo_signal_capture/external_bus_err_ored]
  connect_bd_net -net interface_bus_keeper_err_o [get_bd_pins interface_bus_err_or/Op1] [get_bd_pins interface_bus_keeper/err_o] [get_bd_pins neo_signal_capture/keeper_bus_err]
  connect_bd_net -net interface_bus_to_wishbone_err_o [get_bd_pins interface_bus_err_or/Op2] [get_bd_pins interface_bus_keeper/err_i] [get_bd_pins interface_bus_to_wishbone/err_o] [get_bd_pins neo_signal_capture/external_bus_err_in]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_araddr [get_bd_pins interface_wishbone_to_axi/m_axi_araddr] [get_bd_pins neo_signal_capture/NEORV_axi_araddr] [get_bd_pins neo_smartconnect/S00_AXI_araddr]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_arprot [get_bd_pins interface_wishbone_to_axi/m_axi_arprot] [get_bd_pins neo_signal_capture/NEORV_axi_arprot] [get_bd_pins neo_smartconnect/S00_AXI_arprot]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_arvalid [get_bd_pins interface_wishbone_to_axi/m_axi_arvalid] [get_bd_pins neo_signal_capture/NEORV_axi_arvalid] [get_bd_pins neo_smartconnect/S00_AXI_arvalid]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_awaddr [get_bd_pins interface_wishbone_to_axi/m_axi_awaddr] [get_bd_pins neo_signal_capture/NEORV_axi_awaddr] [get_bd_pins neo_signal_capture/NEORV_axi_awprot] [get_bd_pins neo_smartconnect/S00_AXI_awaddr]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_awprot [get_bd_pins interface_wishbone_to_axi/m_axi_awprot] [get_bd_pins neo_smartconnect/S00_AXI_awprot]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_awvalid [get_bd_pins interface_wishbone_to_axi/m_axi_awvalid] [get_bd_pins neo_signal_capture/NEORV_axi_awvalid] [get_bd_pins neo_smartconnect/S00_AXI_awvalid]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_bready [get_bd_pins interface_wishbone_to_axi/m_axi_bready] [get_bd_pins neo_signal_capture/NEORV_axi_bready] [get_bd_pins neo_smartconnect/S00_AXI_bready]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_rready [get_bd_pins interface_wishbone_to_axi/m_axi_rready] [get_bd_pins neo_signal_capture/NEORV_axi_rready] [get_bd_pins neo_smartconnect/S00_AXI_rready]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_wdata [get_bd_pins interface_wishbone_to_axi/m_axi_wdata] [get_bd_pins neo_signal_capture/NEORV_axi_wdata] [get_bd_pins neo_smartconnect/S00_AXI_wdata]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_wstrb [get_bd_pins interface_wishbone_to_axi/m_axi_wstrb] [get_bd_pins neo_signal_capture/NEORV_axi_wstrb] [get_bd_pins neo_smartconnect/S00_AXI_wstrb]
  connect_bd_net -net interface_wishbone_to_axi_m_axi_wvalid [get_bd_pins interface_wishbone_to_axi/m_axi_wvalid] [get_bd_pins neo_signal_capture/NEORV_axi_wvalid] [get_bd_pins neo_smartconnect/S00_AXI_wvalid]
  connect_bd_net -net neo_smartconnect_M00_AXI_araddr [get_bd_pins cpu_BRAM_controller/s_axi_araddr] [get_bd_pins neo_signal_capture/BRAM_axi_araddr] [get_bd_pins neo_smartconnect/M00_AXI_araddr]
  connect_bd_net -net neo_smartconnect_M00_AXI_arprot [get_bd_pins cpu_BRAM_controller/s_axi_arprot] [get_bd_pins neo_signal_capture/BRAM_axi_arprot] [get_bd_pins neo_smartconnect/M00_AXI_arprot]
  connect_bd_net -net neo_smartconnect_M00_AXI_arvalid [get_bd_pins cpu_BRAM_controller/s_axi_arvalid] [get_bd_pins neo_signal_capture/BRAM_axi_arvalid] [get_bd_pins neo_smartconnect/M00_AXI_arvalid]
  connect_bd_net -net neo_smartconnect_M00_AXI_awaddr [get_bd_pins cpu_BRAM_controller/s_axi_awaddr] [get_bd_pins neo_signal_capture/BRAM_axi_awaddr] [get_bd_pins neo_smartconnect/M00_AXI_awaddr]
  connect_bd_net -net neo_smartconnect_M00_AXI_awprot [get_bd_pins cpu_BRAM_controller/s_axi_awprot] [get_bd_pins neo_signal_capture/BRAM_axi_awprot] [get_bd_pins neo_smartconnect/M00_AXI_awprot]
  connect_bd_net -net neo_smartconnect_M00_AXI_awvalid [get_bd_pins cpu_BRAM_controller/s_axi_awvalid] [get_bd_pins neo_signal_capture/BRAM_axi_awvalid] [get_bd_pins neo_smartconnect/M00_AXI_awvalid]
  connect_bd_net -net neo_smartconnect_M00_AXI_bready [get_bd_pins cpu_BRAM_controller/s_axi_bready] [get_bd_pins neo_signal_capture/BRAM_axi_bready] [get_bd_pins neo_smartconnect/M00_AXI_bready]
  connect_bd_net -net neo_smartconnect_M00_AXI_rready [get_bd_pins cpu_BRAM_controller/s_axi_rready] [get_bd_pins neo_signal_capture/BRAM_axi_rready] [get_bd_pins neo_smartconnect/M00_AXI_rready]
  connect_bd_net -net neo_smartconnect_M00_AXI_wdata [get_bd_pins cpu_BRAM_controller/s_axi_wdata] [get_bd_pins neo_signal_capture/BRAM_axi_wdata] [get_bd_pins neo_smartconnect/M00_AXI_wdata]
  connect_bd_net -net neo_smartconnect_M00_AXI_wstrb [get_bd_pins cpu_BRAM_controller/s_axi_wstrb] [get_bd_pins neo_signal_capture/BRAM_axi_wstrb] [get_bd_pins neo_smartconnect/M00_AXI_wstrb]
  connect_bd_net -net neo_smartconnect_M00_AXI_wvalid [get_bd_pins cpu_BRAM_controller/s_axi_wvalid] [get_bd_pins neo_signal_capture/BRAM_axi_wvalid] [get_bd_pins neo_smartconnect/M00_AXI_wvalid]
  connect_bd_net -net neo_smartconnect_M01_AXI_araddr [get_bd_pins LED_controller/s_axi_araddr] [get_bd_pins neo_signal_capture/LEDs_axi_araddr] [get_bd_pins neo_smartconnect/M01_AXI_araddr]
  connect_bd_net -net neo_smartconnect_M01_AXI_arprot [get_bd_pins neo_signal_capture/LEDs_axi_arprot] [get_bd_pins neo_smartconnect/M01_AXI_arprot]
  connect_bd_net -net neo_smartconnect_M01_AXI_arvalid [get_bd_pins LED_controller/s_axi_arvalid] [get_bd_pins neo_signal_capture/LEDs_axi_arvalid] [get_bd_pins neo_smartconnect/M01_AXI_arvalid]
  connect_bd_net -net neo_smartconnect_M01_AXI_awaddr [get_bd_pins LED_controller/s_axi_awaddr] [get_bd_pins neo_signal_capture/LEDs_axi_awaddr] [get_bd_pins neo_smartconnect/M01_AXI_awaddr]
  connect_bd_net -net neo_smartconnect_M01_AXI_awprot [get_bd_pins neo_signal_capture/LEDs_axi_awprot] [get_bd_pins neo_smartconnect/M01_AXI_awprot]
  connect_bd_net -net neo_smartconnect_M01_AXI_awvalid [get_bd_pins LED_controller/s_axi_awvalid] [get_bd_pins neo_signal_capture/LEDs_axi_awvalid] [get_bd_pins neo_smartconnect/M01_AXI_awvalid]
  connect_bd_net -net neo_smartconnect_M01_AXI_bready [get_bd_pins LED_controller/s_axi_bready] [get_bd_pins neo_signal_capture/LEDs_axi_bready] [get_bd_pins neo_smartconnect/M01_AXI_bready]
  connect_bd_net -net neo_smartconnect_M01_AXI_rready [get_bd_pins neo_signal_capture/LEDs_axi_rready] [get_bd_pins neo_smartconnect/M01_AXI_rready]
  connect_bd_net -net neo_smartconnect_M01_AXI_wdata [get_bd_pins LED_controller/s_axi_wdata] [get_bd_pins neo_signal_capture/LEDs_axi_wdata] [get_bd_pins neo_smartconnect/M01_AXI_wdata]
  connect_bd_net -net neo_smartconnect_M01_AXI_wstrb [get_bd_pins LED_controller/s_axi_wstrb] [get_bd_pins neo_signal_capture/LEDs_axi_wstrb] [get_bd_pins neo_smartconnect/M01_AXI_wstrb]
  connect_bd_net -net neo_smartconnect_M01_AXI_wvalid [get_bd_pins LED_controller/s_axi_wvalid] [get_bd_pins neo_signal_capture/LEDs_axi_wvalid] [get_bd_pins neo_smartconnect/M01_AXI_wvalid]
  connect_bd_net -net neo_smartconnect_M02_AXI_araddr [get_bd_pins button_controller/s_axi_araddr] [get_bd_pins neo_signal_capture/buttons_axi_araddr] [get_bd_pins neo_smartconnect/M02_AXI_araddr]
  connect_bd_net -net neo_smartconnect_M02_AXI_arprot [get_bd_pins neo_signal_capture/buttons_axi_arprot] [get_bd_pins neo_smartconnect/M02_AXI_arprot]
  connect_bd_net -net neo_smartconnect_M02_AXI_arvalid [get_bd_pins button_controller/s_axi_arvalid] [get_bd_pins neo_signal_capture/buttons_axi_arvalid] [get_bd_pins neo_smartconnect/M02_AXI_arvalid]
  connect_bd_net -net neo_smartconnect_M02_AXI_awaddr [get_bd_pins button_controller/s_axi_awaddr] [get_bd_pins neo_signal_capture/buttons_axi_awaddr] [get_bd_pins neo_smartconnect/M02_AXI_awaddr]
  connect_bd_net -net neo_smartconnect_M02_AXI_awprot [get_bd_pins neo_signal_capture/buttons_axi_awprot] [get_bd_pins neo_smartconnect/M02_AXI_awprot]
  connect_bd_net -net neo_smartconnect_M02_AXI_awvalid [get_bd_pins button_controller/s_axi_awvalid] [get_bd_pins neo_signal_capture/buttons_axi_awvalid] [get_bd_pins neo_smartconnect/M02_AXI_awvalid]
  connect_bd_net -net neo_smartconnect_M02_AXI_bready [get_bd_pins button_controller/s_axi_bready] [get_bd_pins neo_signal_capture/buttons_axi_bready] [get_bd_pins neo_smartconnect/M02_AXI_bready]
  connect_bd_net -net neo_smartconnect_M02_AXI_rready [get_bd_pins button_controller/s_axi_rready] [get_bd_pins neo_signal_capture/buttons_axi_rready] [get_bd_pins neo_smartconnect/M02_AXI_rready]
  connect_bd_net -net neo_smartconnect_M02_AXI_wdata [get_bd_pins button_controller/s_axi_wdata] [get_bd_pins neo_signal_capture/buttons_axi_wdata] [get_bd_pins neo_smartconnect/M02_AXI_wdata]
  connect_bd_net -net neo_smartconnect_M02_AXI_wstrb [get_bd_pins button_controller/s_axi_wstrb] [get_bd_pins neo_signal_capture/buttons_axi_wstrb] [get_bd_pins neo_smartconnect/M02_AXI_wstrb]
  connect_bd_net -net neo_smartconnect_M02_AXI_wvalid [get_bd_pins button_controller/s_axi_wvalid] [get_bd_pins neo_signal_capture/buttons_axi_wvalid] [get_bd_pins neo_smartconnect/M02_AXI_wvalid]
  connect_bd_net -net neo_smartconnect_S00_AXI_arready [get_bd_pins interface_wishbone_to_axi/m_axi_arready] [get_bd_pins neo_signal_capture/NEORV_axi_arready] [get_bd_pins neo_smartconnect/S00_AXI_arready]
  connect_bd_net -net neo_smartconnect_S00_AXI_awready [get_bd_pins interface_wishbone_to_axi/m_axi_awready] [get_bd_pins neo_signal_capture/NEORV_axi_awready] [get_bd_pins neo_smartconnect/S00_AXI_awready]
  connect_bd_net -net neo_smartconnect_S00_AXI_bresp [get_bd_pins interface_wishbone_to_axi/m_axi_bresp] [get_bd_pins neo_signal_capture/NEORV_axi_bresp] [get_bd_pins neo_smartconnect/S00_AXI_bresp]
  connect_bd_net -net neo_smartconnect_S00_AXI_bvalid [get_bd_pins interface_wishbone_to_axi/m_axi_bvalid] [get_bd_pins neo_signal_capture/NEORV_axi_bvalid] [get_bd_pins neo_smartconnect/S00_AXI_bvalid]
  connect_bd_net -net neo_smartconnect_S00_AXI_rdata [get_bd_pins interface_wishbone_to_axi/m_axi_rdata] [get_bd_pins neo_signal_capture/NEORV_axi_rdata] [get_bd_pins neo_smartconnect/S00_AXI_rdata]
  connect_bd_net -net neo_smartconnect_S00_AXI_rresp [get_bd_pins interface_wishbone_to_axi/m_axi_rresp] [get_bd_pins neo_signal_capture/NEORV_axi_rresp] [get_bd_pins neo_smartconnect/S00_AXI_rresp]
  connect_bd_net -net neo_smartconnect_S00_AXI_rvalid [get_bd_pins interface_wishbone_to_axi/m_axi_rvalid] [get_bd_pins neo_signal_capture/NEORV_axi_rvalid] [get_bd_pins neo_smartconnect/S00_AXI_rvalid]
  connect_bd_net -net neo_smartconnect_S00_AXI_wready [get_bd_pins interface_wishbone_to_axi/m_axi_wready] [get_bd_pins neo_signal_capture/NEORV_axi_wready] [get_bd_pins neo_smartconnect/S00_AXI_wready]
  connect_bd_net -net neorv32_cp_valid_concat_dout [get_bd_pins cpu_alu/cp_valid_i] [get_bd_pins cpu_cp_valid_concat/dout] [get_bd_pins neo_signal_capture/alu_cp_valid]
  connect_bd_net -net neorv32_cpu_alu_add_o [get_bd_pins cpu_alu/add_o] [get_bd_pins cpu_control_unit/alu_add_i] [get_bd_pins cpu_external_bus_control/addr_i] [get_bd_pins neo_signal_capture/alu_addr]
  connect_bd_net -net neorv32_cpu_alu_cp_start_o [get_bd_pins cpu_alu/cp_start_o] [get_bd_pins cpu_cp_0_start_slice/Din] [get_bd_pins cpu_cp_1_start_slice/Din] [get_bd_pins cpu_cp_2_start_slice/Din] [get_bd_pins cpu_cp_3_start_slice/Din] [get_bd_pins cpu_cp_4_start_slice/Din] [get_bd_pins cpu_cp_5_start_slice/Din] [get_bd_pins cpu_cp_6_start_slice/Din] [get_bd_pins cpu_cp_7_start_slice/Din] [get_bd_pins neo_signal_capture/alu_cp_start]
  connect_bd_net -net neorv32_cpu_alu_wait_o [get_bd_pins cpu_alu/wait_o] [get_bd_pins cpu_control_unit/alu_wait_i]
  connect_bd_net -net neorv32_cpu_bus_be_instr_o [get_bd_pins cpu_control_unit/be_instr_i] [get_bd_pins cpu_external_bus_control/be_instr_o] [get_bd_pins neo_signal_capture/bus_instr_bus_error]
  connect_bd_net -net neorv32_cpu_bus_be_load_o [get_bd_pins cpu_control_unit/be_load_i] [get_bd_pins cpu_external_bus_control/be_load_o] [get_bd_pins neo_signal_capture/bus_load_bus_error]
  connect_bd_net -net neorv32_cpu_bus_be_store_o [get_bd_pins cpu_control_unit/be_store_i] [get_bd_pins cpu_external_bus_control/be_store_o] [get_bd_pins neo_signal_capture/bus_store_bus_error]
  connect_bd_net -net neorv32_cpu_bus_d_bus_addr_o [get_bd_pins cpu_external_bus_control/d_bus_addr_o] [get_bd_pins interface_bus_switch/ca_bus_addr_i] [get_bd_pins neo_signal_capture/data_bus_addr]
  connect_bd_net -net neorv32_cpu_bus_d_bus_ben_o [get_bd_pins cpu_external_bus_control/d_bus_ben_o] [get_bd_pins interface_bus_switch/ca_bus_ben_i] [get_bd_pins neo_signal_capture/data_bus_byte_enable]
  connect_bd_net -net neorv32_cpu_bus_d_bus_lock_o [get_bd_pins cpu_external_bus_control/d_bus_lock_o] [get_bd_pins interface_bus_switch/ca_bus_lock_i] [get_bd_pins neo_signal_capture/data_bus_lock]
  connect_bd_net -net neorv32_cpu_bus_d_bus_re_o [get_bd_pins cpu_external_bus_control/d_bus_re_o] [get_bd_pins interface_bus_switch/ca_bus_re_i] [get_bd_pins neo_signal_capture/data_bus_read_enable]
  connect_bd_net -net neorv32_cpu_bus_d_bus_wdata_o [get_bd_pins cpu_external_bus_control/d_bus_wdata_o] [get_bd_pins interface_bus_switch/ca_bus_wdata_i] [get_bd_pins neo_signal_capture/data_bus_write_data]
  connect_bd_net -net neorv32_cpu_bus_d_bus_we_o [get_bd_pins cpu_external_bus_control/d_bus_we_o] [get_bd_pins interface_bus_switch/ca_bus_we_i] [get_bd_pins neo_signal_capture/data_bus_write_enable]
  connect_bd_net -net neorv32_cpu_bus_d_wait_o [get_bd_pins cpu_control_unit/bus_d_wait_i] [get_bd_pins cpu_external_bus_control/d_wait_o] [get_bd_pins neo_signal_capture/bus_data_wait]
  connect_bd_net -net neorv32_cpu_bus_excl_state_o [get_bd_pins cpu_control_unit/excl_state_i] [get_bd_pins cpu_external_bus_control/excl_state_o] [get_bd_pins neo_signal_capture/bus_excl_state]
  connect_bd_net -net neorv32_cpu_bus_i_bus_addr_o [get_bd_pins cpu_external_bus_control/i_bus_addr_o] [get_bd_pins interface_bus_switch/cb_bus_addr_i] [get_bd_pins neo_signal_capture/instr_bus_addr]
  connect_bd_net -net neorv32_cpu_bus_i_bus_ben_o [get_bd_pins cpu_external_bus_control/i_bus_ben_o] [get_bd_pins interface_bus_switch/cb_bus_ben_i] [get_bd_pins neo_signal_capture/instr_bus_byte_enable]
  connect_bd_net -net neorv32_cpu_bus_i_bus_lock_o [get_bd_pins cpu_external_bus_control/i_bus_lock_o] [get_bd_pins interface_bus_switch/cb_bus_lock_i] [get_bd_pins neo_signal_capture/instr_bus_lock]
  connect_bd_net -net neorv32_cpu_bus_i_bus_re_o [get_bd_pins cpu_external_bus_control/i_bus_re_o] [get_bd_pins interface_bus_switch/cb_bus_re_i] [get_bd_pins neo_signal_capture/instr_bus_read_enable]
  connect_bd_net -net neorv32_cpu_bus_i_bus_wdata_o [get_bd_pins cpu_external_bus_control/i_bus_wdata_o] [get_bd_pins interface_bus_switch/cb_bus_wdata_i] [get_bd_pins neo_signal_capture/instr_bus_write_data]
  connect_bd_net -net neorv32_cpu_bus_i_bus_we_o [get_bd_pins cpu_external_bus_control/i_bus_we_o] [get_bd_pins interface_bus_switch/cb_bus_we_i] [get_bd_pins neo_signal_capture/instr_bus_write_enable]
  connect_bd_net -net neorv32_cpu_bus_i_wait_o [get_bd_pins cpu_control_unit/bus_i_wait_i] [get_bd_pins cpu_external_bus_control/i_wait_o] [get_bd_pins neo_signal_capture/bus_instr_wait]
  connect_bd_net -net neorv32_cpu_bus_instr_o [get_bd_pins cpu_control_unit/instr_i] [get_bd_pins cpu_external_bus_control/instr_o] [get_bd_pins neo_signal_capture/bus_instr]
  connect_bd_net -net neorv32_cpu_bus_ma_instr_o [get_bd_pins cpu_control_unit/ma_instr_i] [get_bd_pins cpu_external_bus_control/ma_instr_o] [get_bd_pins neo_signal_capture/bus_instr_misaligned]
  connect_bd_net -net neorv32_cpu_bus_ma_load_o [get_bd_pins cpu_control_unit/ma_load_i] [get_bd_pins cpu_external_bus_control/ma_load_o] [get_bd_pins neo_signal_capture/bus_load_misaligned]
  connect_bd_net -net neorv32_cpu_bus_ma_store_o [get_bd_pins cpu_control_unit/ma_store_i] [get_bd_pins cpu_external_bus_control/ma_store_o] [get_bd_pins neo_signal_capture/bus_store_misaligned]
  connect_bd_net -net neorv32_cpu_bus_mar_o [get_bd_pins cpu_control_unit/mar_i] [get_bd_pins cpu_external_bus_control/mar_o] [get_bd_pins neo_signal_capture/bus_data_addr]
  connect_bd_net -net neorv32_cpu_bus_rdata_o [get_bd_pins cpu_external_bus_control/rdata_o] [get_bd_pins cpu_regfile/mem_i] [get_bd_pins neo_signal_capture/bus_read_data]
  connect_bd_net -net neorv32_cpu_control_ctrl_o [get_bd_pins cpu_alu/ctrl_i] [get_bd_pins cpu_control_unit/ctrl_o] [get_bd_pins cpu_external_bus_control/ctrl_i] [get_bd_pins cpu_regfile/ctrl_i] [get_bd_pins interface_wishbone_priv_slice/Din] [get_bd_pins neo_signal_capture/control_ctrl]
  connect_bd_net -net neorv32_cpu_control_curr_pc_o [get_bd_pins cpu_alu/pc2_i] [get_bd_pins cpu_clock_stepper/curr_PC] [get_bd_pins cpu_control_unit/curr_pc_o] [get_bd_pins neo_signal_capture/control_curr_PC]
  connect_bd_net -net neorv32_cpu_control_fetch_pc_o [get_bd_pins cpu_control_unit/fetch_pc_o] [get_bd_pins cpu_external_bus_control/fetch_pc_i] [get_bd_pins neo_signal_capture/control_fetch_PC]
  connect_bd_net -net neorv32_cpu_control_imm_o [get_bd_pins cpu_alu/imm_i] [get_bd_pins cpu_control_unit/imm_o] [get_bd_pins neo_signal_capture/control_imm]
  connect_bd_net -net neorv32_cpu_control_wrapped_pmp_addr_o [get_bd_pins cpu_control_unit/wrapped_pmp_addr_o] [get_bd_pins cpu_external_bus_control/wrapped_pmp_addr_i]
  connect_bd_net -net neorv32_cpu_control_wrapped_pmp_ctrl_o [get_bd_pins cpu_control_unit/wrapped_pmp_ctrl_o] [get_bd_pins cpu_external_bus_control/wrapped_pmp_ctrl_i]
  connect_bd_net -net neorv32_cpu_regfile_cmp_o [get_bd_pins cpu_control_unit/cmp_i] [get_bd_pins cpu_regfile/cmp_o] [get_bd_pins neo_signal_capture/regfile_compare]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_adr_o [get_bd_pins interface_bus_to_wishbone/wb_adr_o] [get_bd_pins interface_wishbone_to_axi/wb_addr] [get_bd_pins neo_signal_capture/wishbone_addr]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_cyc_o [get_bd_pins interface_bus_to_wishbone/wb_cyc_o] [get_bd_pins interface_wishbone_to_axi/wb_cyc] [get_bd_pins neo_signal_capture/wishbone_cycle]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_dat_o [get_bd_pins interface_bus_to_wishbone/wb_dat_o] [get_bd_pins interface_wishbone_to_axi/wb_data_write] [get_bd_pins neo_signal_capture/wishbone_write_data]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_lock_o [get_bd_pins interface_bus_to_wishbone/wb_lock_o] [get_bd_pins interface_wishbone_to_axi/wb_lock] [get_bd_pins neo_signal_capture/wishbone_lock]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_sel_o [get_bd_pins interface_bus_to_wishbone/wb_sel_o] [get_bd_pins interface_wishbone_to_axi/wb_sel] [get_bd_pins neo_signal_capture/wishbone_byte_sel]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_stb_o [get_bd_pins interface_bus_to_wishbone/wb_stb_o] [get_bd_pins interface_wishbone_to_axi/wb_stb] [get_bd_pins neo_signal_capture/wishbone_strobe]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_tag_o [get_bd_pins interface_bus_to_wishbone/wb_tag_o] [get_bd_pins interface_wishbone_to_axi/wb_tag] [get_bd_pins neo_signal_capture/wishbone_tag]
  connect_bd_net -net neorv32_interface_bus_to_wishbone_wb_we_o [get_bd_pins interface_bus_to_wishbone/wb_we_o] [get_bd_pins interface_wishbone_to_axi/wb_we] [get_bd_pins neo_signal_capture/wishbone_read_write]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins cpu_clock_stepper/s00_axi_aclk] [get_bd_pins neo_signal_capture/s00_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins pynq_BRAM_controller/s_axi_aclk] [get_bd_pins pynq_smartconnect/aclk] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net processing_system7_0_GPIO_O [get_bd_pins processing_system7_0/GPIO_O] [get_bd_pins pynq_GPIO_neo_reset_slice/Din]
  connect_bd_net -net processor_stepper_0_gated_clock [get_bd_pins LED_controller/s_axi_aclk] [get_bd_pins button_controller/s_axi_aclk] [get_bd_pins cpu_BRAM_controller/s_axi_aclk] [get_bd_pins cpu_alu/clk_i] [get_bd_pins cpu_clock_stepper/gated_clock] [get_bd_pins cpu_control_unit/clk_i] [get_bd_pins cpu_external_bus_control/clk_i] [get_bd_pins cpu_regfile/clk_i] [get_bd_pins interface_bus_keeper/clk_i] [get_bd_pins interface_bus_switch/clk_i] [get_bd_pins interface_bus_to_wishbone/clk_i] [get_bd_pins interface_wishbone_to_axi/m_axi_aclk] [get_bd_pins neo_smartconnect/aclk]
  connect_bd_net -net pull_down_16_bit_dout [get_bd_pins cpu_control_unit/firq_i] [get_bd_pins pull_down_16_bit/dout]
  connect_bd_net -net pull_down_5_bit_dout [get_bd_pins cpu_control_unit/fpu_flags_i] [get_bd_pins pull_down_5_bit/dout]
  connect_bd_net -net pull_down_64_bit_dout [get_bd_pins cpu_control_unit/time_i] [get_bd_pins pull_down_64_bit/dout]
  connect_bd_net -net rst_ps7_0_100M_interconnect_aresetn [get_bd_pins neo_smartconnect/aresetn] [get_bd_pins pynq_smartconnect/aresetn] [get_bd_pins rst_ps7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins LED_controller/s_axi_aresetn] [get_bd_pins button_controller/s_axi_aresetn] [get_bd_pins cpu_BRAM_controller/s_axi_aresetn] [get_bd_pins cpu_clock_stepper/s00_axi_aresetn] [get_bd_pins neo_signal_capture/s00_axi_aresetn] [get_bd_pins pynq_BRAM_controller/s_axi_aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins cpu_control_unit/db_halt_req_i] [get_bd_pins cpu_control_unit/mext_irq_i] [get_bd_pins cpu_control_unit/msw_irq_i] [get_bd_pins cpu_control_unit/mtime_irq_i] [get_bd_pins cpu_control_unit/nm_irq_i] [get_bd_pins pull_down_1_bit/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins interface_bus_to_wishbone/priv_i] [get_bd_pins interface_wishbone_priv_slice/Dout]

  # Create address segments
  assign_bd_address -offset 0x40020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces interface_wishbone_to_axi/m_axi] [get_bd_addr_segs LED_controller/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces interface_wishbone_to_axi/m_axi] [get_bd_addr_segs button_controller/S_AXI/Reg] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces interface_wishbone_to_axi/m_axi] [get_bd_addr_segs cpu_BRAM_controller/S_AXI/Mem0] -force
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs cpu_clock_stepper/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x43C10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs neo_signal_capture/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x40000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pynq_BRAM_controller/S_AXI/Mem0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

# Create wrapped and set as top
make_wrapper -files [get_files ./myproj/project_1.srcs/sources_1/bd/rv32i_overlay/rv32i_overlay.bd] -top
add_files -norecurse ./myproj/project_1.srcs/sources_1/bd/rv32i_overlay/hdl/rv32i_overlay_wrapper.v
update_compile_order -fileset sources_1
set_property top rv32i_overlay_wrapper [current_fileset]
update_compile_order -fileset sources_1
