# NEORV32 on PYNQ

This repository contains a PYNQ overlay based on the [NEORV32 RISC-V soft-processor](https://github.com/stnolting/neorv32), intended for use in teaching  RISC-V, FPGAs, and processor design.

Currently supported boards: [PYNQ-Z2](https://www.tul.com.tw/ProductsPYNQ-Z2.html)

# Installing on a PYNQ board

This repository supports pip installation on PYNQ boards. To connect to Jupyter Lab on your PYNQ board (go to http://pynq:9090/lab), launch a terminal, and run the commands below. You may need to answer yes about getting the notebooks.

```
pip install git+https://github.com/AgNatishia/NEORV32-on-PYNQ
pynq-get-notebooks --force --path /home/xilinx/jupyter_notebooks/
```

This should install the NeoRV32OnPynq module on your PYNQ board, and deliver the notebooks contained within it to /home/xilinx/jupyter_notebooks/NeoRV32OnPynq/.

To compile programs for the RISC-V processor on the board, a RISC-V toolchain needs to be installed. 

One has been provided in the releases of this repository, https://github.com/AgNatishia/NEORV32-on-PYNQ/releases/tag/toolchain.
You will need to download the Zip file of the toolchain, copy it to the board, unzip, and add the executable directories to the *PATH* variables used by jupyter notebooks and your terminal.

There are a range of methods available in getting the zipped toolchain onto your board. This is the suggested way: 

* Download the the zipped toolchain to your computer
* Connect to Jupyter Lab (go to http://pynq:9090/lab)
* Drag and drop the zipped file to the Jupyter home area to upload it. 
* The zipped toolchain should now be in the directory "/home/xilinx/jupyter_notebooks/"
* Open a terminal and change your working directory to this location 

However you choose to get the zipped toolchain onto the board, something akin to the following code will need to be run.
It will unzip, set file permissions, modify the PATH variables, and restart the board so the modified PATH variables are loaded.

This example code assumes the zipped toolchain is in current working  directory, and upzips  the  toolchain to `/home/xilinx/GNU-RISCV-toolchain-for-PYNQ/`

```
unzip GNU-RISCV-toolchain-for-PYNQ.zip -d /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/
chmod 755 -R /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/
chmod 755 -R /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/libexec/
chmod 755 -R /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/riscv32-unknown-elf/
echo 'export PATH="$PATH:/home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/"' >> /etc/bash.bashrc
echo 'PATH="$PATH:/home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/"' >> /etc/environment
shutdown -r now
```

Once this is done starting with the notebook `Introduction_to_NeoRV32OnPynq` which should be in `/home/xilinx/jupyter_notebooks/NeoRV32OnPynq/`.
