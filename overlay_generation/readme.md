
# Overlay Generation

The files in this directory were used to generate the NeoRV32OnPynq overlay for the PYNQ-Z2 board.
They are provided here to allow simulation of the overlay for debugging, when the signals exposed by the interface isn't enough.
However that could also be used to extend the overlay with new functionality, and/or regenerate the overlay to target a now board.

# Regenerating the Overlay

Should you wish to target a new board or add functionality you will have to first regenerate the overlay's block diagram.
This can be down in a pre-existing Vivado project or at same time as a new project is created, the only difference is where you run the tcl script.

<ol>
<li>
  Copy the contents of this folder from the repository to either:
  the folder where your pre-existing project is (if adding the block diagram to a project),
  or the folder where you want to create your new project (if creating the project and the block diagram together)
</li>
<li>
  If adding the block diagram to a project, open said profile.
  If creating the a project and block diagram together open Vivado
</li>
<li>
  Using the "Tcl Console" make sure the working directory is where you copied the files from the repository.
  Use `pwd` to print the working directory, and `cd` to change it
/li>
<li>
  Run `source rv32i_overlay.tcl`.
  This will create a profile (if once isn't already open), import the RTL files, and IPs needed for the block diagram, create the block diagram, create a wrapper for the block diagram, and set that wrapper as your top
</li>
<li>
  To then generate the overlay in the "Flow Navigator", under "Program and Debug" click "Generate Bitstream". If you are looking to add functionality to the overlay you do that via modifying the "rv32i_overlay" block diagram before clicking "Generate Bitstream"
</li>
</ol>


# Simulating a Program

The first time you go to simulate a program you will first need to generate the simulation block diagram.
However once this is done the same block diagram can be used to simulate any number of programs just by changed the .coe file loaded into the BRAM.

## Generating Simulation Block Diagram

The simulation block diagram can be generated within a pre-existing Vivado project or at same time as a new project is created, the only difference is where you run the tcl script.

<ol>
<li>
  Copy the contents of this folder from the repository to either:
  the folder where your pre-existing project is (if adding the block diagram to a project),
  or the folder where you want to create your new project (if creating the project and the block diagram together)
</li>
<li>
  If adding the block diagram to a project, open said profile.
  If creating the a project and block diagram together open Vivado
</li>
<li>
  Using the "Tcl Console" make sure the working directory is where you copied the files from the repository.
  Use `pwd` to print the working directory, and `cd` to change it
/li>
<li>
  Run `source simulation_rv32i_overlay.tcl`.
  This will create a profile (if once isn't already open), import the RTL files, and IPs needed for the block diagram, create the block diagram, create a wrapper for the block diagram, and set that wrapper as your top
</li>
</ol>

## Simulating the Program

With a newly generated or pre-used simulation block diagram. the process for setting the program to simulation is the same.
<ol>
<li> Copy the program's .coe from the PYNQ board to the computer with the block diagram</li>
<li> In Vivado, Open the simulation block diagram, double click "simulation_rv32i_overlay" (one level below simulation_rv32i_overlay_wrapper) <\li>
<li> In the block diagram find the BRAM (cpu_BRAM_controller_bram), double click it to open the customization menu.<\li>
<li>  Under "Other Options" check "Load Init File". and using the browse button to select the .coe of the program for simulation. Clink "OK" to close the customization menu.
<\li>
<li> In "Flow Navigator", under "Simulation" click "Run Simulation", then "Run Behavioral Simulation". This will start to simulate of you program </li>
<li> Once the simulation view has started run `source simulation_rv32i_overlay_start.tcl`, this handles setting up the clock and reset signals</li>
<li> Your program should start to run after after about 25000 ns have passed</li>
</ol>
