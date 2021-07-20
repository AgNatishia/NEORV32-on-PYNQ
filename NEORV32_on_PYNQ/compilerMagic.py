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
        
        # Create C file
        with open(program_name + ".c", "w") as f:
            f.write(cell)
        
        # Run toolchain
        _ = run("make clean exe")
        _ = run("mv main.bin " + program_name + ".bin")
        _ = run("riscv32-unknown-elf-objdump -D main.elf > " + program_name + ".objdump")
        _ = run("bin2coe -i " + program_name + ".bin -o " + program_name + ".coe -w 32")


def load_ipython_extension(ipython):
    ipython.register_magics(compilerMagic)