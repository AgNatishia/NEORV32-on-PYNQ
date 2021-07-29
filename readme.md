# NEORV32 on PYNQ

This repository contains a basic PYNQ overlay based on the NEORV32 soft-processor, https://github.com/stnolting/neorv32, intended for use in teaching  RISC-V, FPEAs, and processor design.

Currently supported boards: Xilinx's PYNQ-Z2

# Installing on a PYNQ board

This repo supports pip installation on PYNQ boards using the following commands.

```
pip install git+https://github.com/AgNatishia/NEORV32-on-PYNQ
pynq-get-notebooks --force --path /home/xilinx/jupyter_notebooks/
```

This should install the NeoRV32OnPynq module on your PYNQ board, and deliver the notebooks contained within it to /home/xilinx/jupyter_notebooks/NeoRV32OnPynq/.

However in order to develop programs for this overlay a C-to-RISCV compiler must be available on your board.
One has been provided in the releases of this repository, https://github.com/AgNatishia/NEORV32-on-PYNQ/releases/tag/toolchain.
It should be downloaded, copied to the board, unzipped, and it's location added to the path variables used by jupyter notebooks and your terminal.

Due to the range of methods available in getting the zipped toolchain onto your board, I will only provide code for unzipping and setting up the path variables below.
This code assumes the working directory is "/home/xilinx/" and the zipped toolchain has been copied to this directory.

```
unzip /home/xilinx/GNU-RISCV-toolchain-for-PYNQ.zip
chmod 775 -R GNU-RISCV-toolchain-for-PYNQ
echo 'export PATH="$PATH:home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/"' >> /etc/bash.bashrc
echo 'PATH="$PATH:home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/"' >> /etc/environment
```

Once this is done I suggest starting with the notebook "Introduction_to_NeoRV32OnPynq" which should be in "/home/xilinx/jupyter_notebooks/NeoRV32OnPynq/".
