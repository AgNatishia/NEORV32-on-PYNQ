from pynq import GPIO
from pynq.overlay import Overlay

import time

class overlay():
    def __init__(this):
        this.overlay = Overlay("/usr/local/lib/python3.6/dist-packages/NEORV32_on_PYNQ/rv32i_overlay.bit")

        this.core_reset = GPIO(GPIO.get_gpio_pin(0), 'out')
        this.BRAM = this.overlay.pynq_BRAM_controller

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

    def start_reset(this):
        this.core_reset.write(0) # 0 as reset is negtive logic

    def end_reset(this):
        this.core_reset.write(1) # 1 as reset is negtive logic

    def pulse_reset(this, pulse_time=0.005):
        this.start_reset()
        time.sleep(pulse_time)
        this.end_reset()
