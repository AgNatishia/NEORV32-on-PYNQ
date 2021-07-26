from IPython.core.magic import Magics, magics_class, cell_magic

import subprocess

def run(command, cwd=None):
    print(command)
    completedProcess = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=cwd, shell=True)
    print(completedProcess.stdout.decode("utf-8") )
    return completedProcess.returncode == 0

@magics_class
class compilerMagic(Magics):

    @cell_magic
    def riscvc(self, line, cell):
        # Get program name from line
        program_name = line.strip()

        # Get the file character of program is a letter or underscore
        if not(program_name[0].isalpha() or program_name[0] == "_"):
            raise ValueError("program_name must start with a letter or underscore")
        if not all([char.isalpha() or char.isnumeric() or char  == "_" for char in program_name]):
            raise ValueError("program_name may only contain letters, numbers, and underscores")

        # Make sure a folder in programs exists and is prepared for this program
        _ = run("mkdir -p programs/%s"%(program_name,))
        _ = run("cp /usr/local/lib/python3.6/dist-packages/NEORV32_on_PYNQ/makefile programs/%s/makefile"%(program_name,))

        # Create C file
        with open("programs/%s/%s.c"%(program_name, program_name,), "w") as f:
            f.write(cell)

        # Run makefile
        _ = run(" ".join( [
                "make clean exe",
                "NEORV32_HOME=/usr/local/lib/python3.6/dist-packages/NeoRV32OnPynq/NEORV_lib",
                "LD_SCRIPT=/usr/local/lib/python3.6/dist-packages/NeoRV32OnPynq/NeoRV32OnPynq.ld",
            ] ),
            cwd="programs/%s"%(program_name, )
        )

        # Process makefile outputs
        _ = run("mv main.bin %s.bin"%(program_name, ), cwd="programs/%s"%(program_name, ))
        _ = run("mv main.asm %s.asm"%(program_name, ), cwd="programs/%s"%(program_name, ))
        _ = run("bin2coe -i %s.bin -o %s.coe -w 32"%(program_name, program_name), cwd="programs/%s"%(program_name, ))

        # Clean up main files
        _ = run("rm main.* neorv32_exe.bin", cwd="programs/%s"%(program_name, ))

def load_ipython_extension(ipython):
    ipython.register_magics(compilerMagic)
