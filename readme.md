# NEORV32 on PYNQ

This repository contains a basic PYNQ overlay based on the NEORV32 soft-processor, https://github.com/stnolting/neorv32, intended for use in teaching  RISC-V, FPEAs, and processor design.

Currently supported boards: Xilinx's PYNQ-Z2

# Installing on a PYNQ board

This repository supports pip installation on PYNQ boards. To do so start Jupyter Lab (go to http://pynq:9090/lab), launch a terminal, and run the commands below. You may need to answer yes about getting the notebooks.

```
pip install git+https://github.com/AgNatishia/NEORV32-on-PYNQ
pynq-get-notebooks --force --path /home/xilinx/jupyter_notebooks/
```

This should install the NeoRV32OnPynq module on your PYNQ board, and deliver the notebooks contained within it to /home/xilinx/jupyter_notebooks/NeoRV32OnPynq/.

However in order to develop programs for this overlay a C-to-RISCV compiler must be available on your board.
One has been provided in the releases of this repository, https://github.com/AgNatishia/NEORV32-on-PYNQ/releases/tag/toolchain.
It should be downloaded, copied to the board, unzipped, and it's location added to the path variables used by jupyter notebooks and your terminal.

There are a range of methods available in getting the zipped toolchain onto your board, I will only cover uploading via jupyter Labs.
<ol>
<li>Download the the zipped toolchain to your computer</li>
<li>Open jupyter Labs (go to http://pynq:9090/lab)</li>
<li>Click the "Upload Files" button (the upwards arrow icon in the upper left)</li>
<li>Select the zipped toolchain in the popup and click "open", you may get a warning about a large file, click "upload" to confirm</li>
<li>It will take some time for the file to upload (about a minute for me but your setup by differ), the progress in uploading can be seen in the blue progress bar at the bottom of the screen, once the upload is complete the progress bar will disappear</li>
<li>The zipped toolchain should now be in the directory "/home/xilinx/jupyter_notebooks/", open a terminal and change your working directory to this location in preparation for unzipping and setting up the toolchain</li>
</ol>

However you choose to get the zipped toolchain onto the board, something akin to the following code will need to be run.
it handles unzipping, setting file permissions, modifying the PATH variables, and restarting the board so the modified PATH variables are loaded.
This example code assumes the zipped toolchain has been copied into the current working  directory, and installs the unzipped toolchain "/home/xilinx/GNU-RISCV-toolchain-for-PYNQ/".

```
unzip GNU-RISCV-toolchain-for-PYNQ.zip -d /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/
chmod 755 -R /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/
chmod 755 -R /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/libexec/
chmod 755 -R /home/xilinx/GNU-RISCV-toolchain-for-PYNQ/riscv32-unknown-elf/
echo 'export PATH="$PATH:/home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/"' >> /etc/bash.bashrc
echo 'PATH="$PATH:/home/xilinx/GNU-RISCV-toolchain-for-PYNQ/bin/"' >> /etc/environment
shutnow -r now
```

Once this is done I suggest starting with the notebook "Introduction_to_NeoRV32OnPynq" which should be in "/home/xilinx/jupyter_notebooks/NeoRV32OnPynq/".
