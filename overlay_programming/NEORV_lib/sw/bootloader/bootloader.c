// #################################################################################################
// # << NEORV32 - Bootloader >>                                                                    #
// # ********************************************************************************************* #
// # In order to run the bootloader on *any* CPU configuration, the bootloader should be compiled  #
// # using the base ISA (rv32i/rv32e) only.                                                        #
// # ********************************************************************************************* #
// # Boot from (internal) instruction memory, UART or SPI Flash.                                   #
// # Bootloader executables (neorv32_exe.bin) are LITTLE-ENDIAN!                                   #
// #                                                                                               #
// # The bootloader uses the primary UART (UART0) for user console interface.                      #
// #                                                                                               #
// # UART configuration: 8 data bits, NO parity bit, 1 stop bit, 19200 baud (19200-8N1)            #
// # Boot Flash: 8-bit SPI, 24-bit addresses (like Micron N25Q032A) @ neorv32.spi_csn_o(0)         #
// # neorv32.gpio_o(0) is used as high-active status LED (can be disabled via #STATUS_LED_EN).     #
// #                                                                                               #
// # Auto boot sequence (can be disabled via #AUTOBOOT_EN) after timeout (via #AUTOBOOT_TIMEOUT):  #
// #  -> Try booting from SPI flash at spi_csn_o(0).                                               #
// #  -> Permanently light up status led and stall CPU if SPI flash booting attempt fails.         #
// # ********************************************************************************************* #
// # BSD 3-Clause License                                                                          #
// #                                                                                               #
// # Copyright (c) 2021, Stephan Nolting. All rights reserved.                                     #
// #                                                                                               #
// # Redistribution and use in source and binary forms, with or without modification, are          #
// # permitted provided that the following conditions are met:                                     #
// #                                                                                               #
// # 1. Redistributions of source code must retain the above copyright notice, this list of        #
// #    conditions and the following disclaimer.                                                   #
// #                                                                                               #
// # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
// #    conditions and the following disclaimer in the documentation and/or other materials        #
// #    provided with the distribution.                                                            #
// #                                                                                               #
// # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
// #    endorse or promote products derived from this software without specific prior written      #
// #    permission.                                                                                #
// #                                                                                               #
// # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
// # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
// # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
// # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
// # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
// # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
// # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
// # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
// # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
// # ********************************************************************************************* #
// # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
// #################################################################################################


/**********************************************************************//**
 * @file bootloader.c
 * @author Stephan Nolting
 * @brief Default NEORV32 bootloader.
 **************************************************************************/

// Libraries
#include <stdint.h>
#include <neorv32.h>


/**********************************************************************//**
 * @name User configuration
 **************************************************************************/
/**@{*/
/** UART BAUD rate */
#define BAUD_RATE              (19200)
/** Enable auto-boot sequence if != 0 */
#define AUTOBOOT_EN            (1)
/** Time until the auto-boot sequence starts (in seconds) */
#define AUTOBOOT_TIMEOUT       (8)
/** Set to 0 to disable bootloader status LED */
#define STATUS_LED_EN          (1)
/** Set to 1 to enable SPI direct boot (disables the entire user console!) */
#define SPI_DIRECT_BOOT_EN     (0)
/** Bootloader status LED at GPIO output port */
#define STATUS_LED             (0)
/** SPI flash boot image base address (warning! address might wrap-around!) */
#define SPI_FLASH_BOOT_ADR     (0x00800000)
/** SPI flash chip select line at spi_csn_o */
#define SPI_FLASH_CS           (0)
/** Default SPI flash clock prescaler */
#define SPI_FLASH_CLK_PRSC     (CLK_PRSC_8)
/** SPI flash sector size in bytes (default = 64kb) */
#define SPI_FLASH_SECTOR_SIZE  (64*1024)
/** ASCII char to start fast executable upload process (for use with automatic upload scripts) */
#define FAST_UPLOAD_CMD        ('#')
/**@}*/


/**********************************************************************//**
  Executable stream source select
 **************************************************************************/
enum EXE_STREAM_SOURCE {
  EXE_STREAM_UART  = 0, /**< Get executable via UART */
  EXE_STREAM_FLASH = 1  /**< Get executable via SPI flash */
};


/**********************************************************************//**
 * Error codes
 **************************************************************************/
enum ERROR_CODES {
  ERROR_SIGNATURE = 0, /**< 0: Wrong signature in executable */
  ERROR_SIZE      = 1, /**< 1: Insufficient instruction memory capacity */
  ERROR_CHECKSUM  = 2, /**< 2: Checksum error in executable */
  ERROR_FLASH     = 3, /**< 3: SPI flash access error */
  ERROR_SYSTEM    = 4  /**< 4: System exception */
};


/**********************************************************************//**
 * SPI flash commands
 **************************************************************************/
enum SPI_FLASH_CMD {
  SPI_FLASH_CMD_PAGE_PROGRAM = 0x02, /**< Program page */
  SPI_FLASH_CMD_READ         = 0x03, /**< Read data */
  SPI_FLASH_CMD_READ_STATUS  = 0x05, /**< Get status register */
  SPI_FLASH_CMD_WRITE_ENABLE = 0x06, /**< Allow write access */
  SPI_FLASH_CMD_READ_ID      = 0x9E, /**< Read manufacturer ID */
  SPI_FLASH_CMD_SECTOR_ERASE = 0xD8  /**< Erase complete sector */
};


/**********************************************************************//**
 * NEORV32 executable
 **************************************************************************/
enum NEORV32_EXECUTABLE {
  EXE_OFFSET_SIGNATURE =  0, /**< Offset in bytes from start to signature (32-bit) */
  EXE_OFFSET_SIZE      =  4, /**< Offset in bytes from start to size (32-bit) */
  EXE_OFFSET_CHECKSUM  =  8, /**< Offset in bytes from start to checksum (32-bit) */
  EXE_OFFSET_DATA      = 12, /**< Offset in bytes from start to data (32-bit) */
};


/**********************************************************************//**
 * Valid executable identification signature.
 **************************************************************************/
#define EXE_SIGNATURE 0x4788CAFE


/**********************************************************************//**
 * String output helper macros.
 **************************************************************************/
/**@{*/
/* Actual define-to-string helper */
#define xstr(a) str(a)
/* Internal helper macro */
#define str(a) #a
/**@}*/


/**********************************************************************//**
 * This global variable keeps the size of the available executable in bytes.
 * If =0 no executable is available (yet).
 **************************************************************************/
volatile uint32_t exe_available = 0;


/**********************************************************************//**
 * Only set during executable fetch (required for cpaturing STORE-BUS-TIMOUT exception).
 **************************************************************************/
volatile uint32_t getting_exe = 0;


// Function prototypes
void __attribute__((__interrupt__)) bootloader_trap_handler(void);
void fast_upload(int src);
void print_help(void);
void start_app(void);
void get_exe(int src);
void save_exe(void);
uint32_t get_exe_word(int src, uint32_t addr);
void system_error(uint8_t err_code);
void print_hex_word(uint32_t num);

// SPI flash driver functions
uint8_t spi_flash_read_byte(uint32_t addr);
void spi_flash_write_byte(uint32_t addr, uint8_t wdata);
void spi_flash_write_word(uint32_t addr, uint32_t wdata);
void spi_flash_erase_sector(uint32_t addr);
uint8_t spi_flash_read_1st_id(void);
void spi_flash_write_wait(void);
void spi_flash_write_enable(void);
void spi_flash_write_addr(uint32_t addr);


/**********************************************************************//**
 * Bootloader main.
 **************************************************************************/
int main(void) {

// check ISA
#if defined __riscv_atomic || defined __riscv_a || __riscv_b || __riscv_compressed || defined __riscv_c || defined __riscv_mul || defined __riscv_m
  #warning In order to allow the bootloader to run on *ANY* CPU configuration it should be compiled using the base ISA (rv32i/e) only.
#endif

  exe_available = 0; // global variable for executable size; 0 means there is no exe available
  getting_exe   = 0; // we are not trying to get an executable yet

  // ------------------------------------------------
  // Minimal processor hardware initialization
  // - all IO devices are reset and disabled by the crt0 code
  // ------------------------------------------------

  // get clock speed (in Hz)
  uint32_t clock_speed = SYSINFO_CLK;

  // init SPI for 8-bit, clock-mode 0
  if (clock_speed < 40000000) {
    neorv32_spi_setup(SPI_FLASH_CLK_PRSC, 0, 0);
  }
  else {
    neorv32_spi_setup(CLK_PRSC_128, 0, 0);
  }

#if (STATUS_LED_EN != 0)
    // activate status LED, clear all others
    neorv32_gpio_port_set(1 << STATUS_LED);
#endif

  // init UART (no parity bit, no hardware flow control)
  neorv32_uart_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);

  // Configure machine system timer interrupt for ~2Hz
  neorv32_mtime_set_timecmp(neorv32_mtime_get_time() + (clock_speed/4));

  // configure trap handler (bare-metal, no neorv32 rte available)
  neorv32_cpu_csr_write(CSR_MTVEC, (uint32_t)(&bootloader_trap_handler));

  // active timer IRQ
  neorv32_cpu_csr_write(CSR_MIE, 1 << CSR_MIE_MTIE); // activate MTIME IRQ source
  neorv32_cpu_eint(); // enable global interrupts


  // ------------------------------------------------
  // Fast boot mode: Direct SPI boot
  // Bootloader will directly boot and execute image from SPI memory.
  // No user UART console is available in this mode!
  // ------------------------------------------------
#if (SPI_DIRECT_BOOT_EN != 0)
  #warning Compiling bootloader in 'SPI direct boot mode'. Bootloader will directly boot from SPI memory. No user UART console will be available.

  neorv32_uart_print("\nNEORV32 bootloader\nAccessing SPI flash at ");
  print_hex_word((uint32_t)SPI_FLASH_BOOT_ADR);
  neorv32_uart_print("\n");

  get_exe(EXE_STREAM_FLASH);
  neorv32_uart_print("\n");
  start_app();

  return 1; // bootloader should never return
#endif


  // ------------------------------------------------
  // Show bootloader intro and system info
  // ------------------------------------------------
  neorv32_uart_print("\n\n\n\n<< NEORV32 Bootloader >>\n\n"
                     "BLDV: "__DATE__"\nHWV:  ");
  print_hex_word(neorv32_cpu_csr_read(CSR_MIMPID));
  neorv32_uart_print("\nCLK:  ");
  print_hex_word(SYSINFO_CLK);
  neorv32_uart_print("\nUSER: ");
  print_hex_word(SYSINFO_USER_CODE);
  neorv32_uart_print("\nMISA: ");
  print_hex_word(neorv32_cpu_csr_read(CSR_MISA));
  neorv32_uart_print("\nZEXT: ");
  print_hex_word(neorv32_cpu_csr_read(CSR_MZEXT));
  neorv32_uart_print("\nPROC: ");
  print_hex_word(SYSINFO_FEATURES);
  neorv32_uart_print("\nIMEM: ");
  print_hex_word(SYSINFO_IMEM_SIZE);
  neorv32_uart_print(" bytes @ ");
  print_hex_word(SYSINFO_ISPACE_BASE);
  neorv32_uart_print("\nDMEM: ");
  print_hex_word(SYSINFO_DMEM_SIZE);
  neorv32_uart_print(" bytes @ ");
  print_hex_word(SYSINFO_DSPACE_BASE);


  // ------------------------------------------------
  // Auto boot sequence
  // ------------------------------------------------
#if (AUTOBOOT_EN != 0)
  neorv32_uart_print("\n\nAutoboot in "xstr(AUTOBOOT_TIMEOUT)"s. Press key to abort.\n");

  uint64_t timeout_time = neorv32_mtime_get_time() + (uint64_t)(AUTOBOOT_TIMEOUT * clock_speed);

  while (neorv32_uart_char_received() == 0) { // wait for any key to be pressed

    if (neorv32_mtime_get_time() >= timeout_time) { // timeout? start auto boot sequence
      fast_upload(EXE_STREAM_FLASH); // try booting from flash
    }
  }
  neorv32_uart_print("Aborted.\n\n");

  // fast executable upload?
  if (neorv32_uart_char_received_get() == FAST_UPLOAD_CMD) {
    fast_upload(EXE_STREAM_UART);
  }
#else
  neorv32_uart_print("\n\n");
#endif

  print_help();


  // ------------------------------------------------
  // Bootloader console
  // ------------------------------------------------
  while (1) {

    neorv32_uart_print("\nCMD:> ");
    char c = neorv32_uart_getc();
    neorv32_uart_putc(c); // echo
    neorv32_uart_print("\n");

    if (c == FAST_UPLOAD_CMD) { // fast executable upload
      fast_upload(EXE_STREAM_UART);
    }
    else if (c == 'r') { // restart bootloader
      asm volatile ("li t0, %[input_i]; jr t0" :  : [input_i] "i" (BOOTLOADER_BASE_ADDRESS)); // jump to beginning of boot ROM
    }
    else if (c == 'h') { // help menu
      print_help();
    }
    else if (c == 'u') { // get executable via UART
      get_exe(EXE_STREAM_UART);
    }
    else if (c == 's') { // program flash from memory (IMEM)
      save_exe();
    }
    else if (c == 'l') { // get executable from flash
      get_exe(EXE_STREAM_FLASH);
    }
    else if (c == 'e') { // start application program
      start_app();
    }
    else { // unknown command
      neorv32_uart_print("Invalid CMD");
    }
  }

  return 1; // bootloader should never return
}


/**********************************************************************//**
 * Get executable stream and execute it.
 *
 * @param src Source of executable stream data. See #EXE_STREAM_SOURCE.
 **************************************************************************/
void fast_upload(int src) {

  get_exe(src);
  neorv32_uart_print("\n");
  start_app();
  while(1);
}


/**********************************************************************//**
 * Print help menu.
 **************************************************************************/
void print_help(void) {

  neorv32_uart_print("Available CMDs:\n"
                     " h: Help\n"
                     " r: Restart\n"
                     " u: Upload\n"
                     " s: Store to flash\n"
                     " l: Load from flash\n"
                     " e: Execute");
}


/**********************************************************************//**
 * Start application program at the beginning of instruction space.
 **************************************************************************/
void start_app(void) {

  // executable available?
  if (exe_available == 0) {
    neorv32_uart_print("No executable available.");
    return;
  }

  // no need to shut down/reset the used peripherals
  // no need to disable interrupt sources
  // -> crt0 will do a clean CPU/processor reset/setup

  // deactivate global IRQs
  neorv32_cpu_dint();

  neorv32_uart_print("Booting...\n\n");

  // wait for UART to finish transmitting
  while (neorv32_uart_tx_busy());

  // start app at instruction space base address
  register uint32_t app_base = SYSINFO_ISPACE_BASE;
  asm volatile ("jalr zero, %0" : : "r" (app_base));
  while (1);
}


/**********************************************************************//**
 * Bootloader trap handler. Used for the MTIME tick and to capture any other traps.
 * @warning Since we have no runtime environment, we have to use the interrupt attribute here. Here and only here!
 **************************************************************************/
void __attribute__((__interrupt__)) bootloader_trap_handler(void) {

  uint32_t cause = neorv32_cpu_csr_read(CSR_MCAUSE);

  // make sure this was caused by MTIME IRQ
  if (cause == TRAP_CODE_MTI) { // raw exception code for MTI
#if (STATUS_LED_EN != 0)
      // toggle status LED
      neorv32_gpio_pin_toggle(STATUS_LED);
#endif
    // set time for next IRQ
    neorv32_mtime_set_timecmp(neorv32_mtime_get_time() + (SYSINFO_CLK/4));
  }
  else {
    // store bus access error during get_exe
    // -> seems like executable is too large
    if ((cause == TRAP_CODE_S_ACCESS) && (getting_exe)) {
      system_error(ERROR_SIZE);
    }
    // unknown error
    else {
      neorv32_uart_print("\n\nEXCEPTION mcause=");
      print_hex_word(cause);
      neorv32_uart_print(" @ pc=");
      print_hex_word(neorv32_cpu_csr_read(CSR_MEPC));
      neorv32_uart_print(" mtval=");
      print_hex_word(neorv32_cpu_csr_read(CSR_MTVAL));
      system_error(ERROR_SYSTEM);
    }
  }
}


/**********************************************************************//**
 * Get executable stream.
 *
 * @param src Source of executable stream data. See #EXE_STREAM_SOURCE.
 **************************************************************************/
void get_exe(int src) {

  getting_exe = 1; // to inform trap handler we were trying to get an executable

  // flash image base address
  uint32_t addr = SPI_FLASH_BOOT_ADR;

  // get image from flash?
  if (src == EXE_STREAM_UART) {
    neorv32_uart_print("Awaiting neorv32_exe.bin... ");
  }
  else {
    neorv32_uart_print("Loading... ");

    // check if SPI is available at all
    if (neorv32_spi_available() == 0) {
      system_error(ERROR_FLASH);
    }

    // check if flash ready (or available at all)
    if (spi_flash_read_1st_id() == 0x00) { // manufacturer ID
      system_error(ERROR_FLASH);
    }
  }

  // check if valid image
  uint32_t signature = get_exe_word(src, addr + EXE_OFFSET_SIGNATURE);
  if (signature != EXE_SIGNATURE) { // signature
    system_error(ERROR_SIGNATURE);
  }

  // image size and checksum
  uint32_t size  = get_exe_word(src, addr + EXE_OFFSET_SIZE); // size in bytes
  uint32_t check = get_exe_word(src, addr + EXE_OFFSET_CHECKSUM); // complement sum checksum

  // transfer program data
  uint32_t *pnt = (uint32_t*)SYSINFO_ISPACE_BASE;
  uint32_t checksum = 0;
  uint32_t d = 0, i = 0;
  addr = addr + EXE_OFFSET_DATA;
  while (i < (size/4)) { // in words
    d = get_exe_word(src, addr);
    checksum += d;
    pnt[i++] = d;
    addr += 4;
  }

  // error during transfer?
  if ((checksum + check) != 0) {
    system_error(ERROR_CHECKSUM);
  }
  else {
    neorv32_uart_print("OK");
    exe_available = size; // store exe size
  }

  getting_exe = 0; // to inform trap handler we are done getting an executable
}


/**********************************************************************//**
 * Store content of instruction memory to SPI flash.
 **************************************************************************/
void save_exe(void) {

  // size of last uploaded executable
  uint32_t size = exe_available;

  if (size == 0) {
    neorv32_uart_print("No executable available.");
    return;
  }

  uint32_t addr = SPI_FLASH_BOOT_ADR;

  // info and prompt
  neorv32_uart_print("Write 0x");
  print_hex_word(size);
  neorv32_uart_print(" bytes to SPI flash @ 0x");
  print_hex_word(addr);
  neorv32_uart_print("? (y/n) ");

  char c = neorv32_uart_getc();
  neorv32_uart_putc(c);
  if (c != 'y') {
    return;
  }

  // check if flash ready (or available at all)
  if (spi_flash_read_1st_id() == 0x00) { // manufacturer ID
    system_error(ERROR_FLASH);
  }

  neorv32_uart_print("\nFlashing... ");

  // clear memory before writing
  uint32_t num_sectors = (size / SPI_FLASH_SECTOR_SIZE) + 1; // clear at least 1 sector
  uint32_t sector = SPI_FLASH_BOOT_ADR;
  while (num_sectors--) {
    spi_flash_erase_sector(sector);
    sector += SPI_FLASH_SECTOR_SIZE;
  }

  // write EXE signature
  spi_flash_write_word(addr + EXE_OFFSET_SIGNATURE, EXE_SIGNATURE);

  // write size
  spi_flash_write_word(addr + EXE_OFFSET_SIZE, size);

  // store data from instruction memory and update checksum
  uint32_t checksum = 0;
  uint32_t *pnt = (uint32_t*)SYSINFO_ISPACE_BASE;
  addr = addr + EXE_OFFSET_DATA;
  uint32_t i = 0;
  while (i < (size/4)) { // in words
    uint32_t d = (uint32_t)*pnt++;
    checksum += d;
    spi_flash_write_word(addr, d);
    addr += 4;
    i++;
  }

  // write checksum (sum complement)
  checksum = (~checksum) + 1;
  spi_flash_write_word(SPI_FLASH_BOOT_ADR + EXE_OFFSET_CHECKSUM, checksum);

  neorv32_uart_print("OK");
}


/**********************************************************************//**
 * Get word from executable stream
 *
 * @param src Source of executable stream data. See #EXE_STREAM_SOURCE.
 * @param addr Address when accessing SPI flash.
 * @return 32-bit data word from stream.
 **************************************************************************/
uint32_t get_exe_word(int src, uint32_t addr) {

  union {
    uint32_t uint32;
    uint8_t  uint8[sizeof(uint32_t)];
  } data;

  uint32_t i;
  for (i=0; i<4; i++) {
    if (src == EXE_STREAM_UART) {
      data.uint8[i] = (uint8_t)neorv32_uart_getc();
    }
    else {
      data.uint8[i] = spi_flash_read_byte(addr + i);
    }
  }

  return data.uint32;
}


/**********************************************************************//**
 * Output system error ID and stall.
 *
 * @param[in] err_code Error code. See #ERROR_CODES.
 **************************************************************************/
void system_error(uint8_t err_code) {

  neorv32_uart_print("\a\nERROR_"); // output error code with annoying bell sound
  neorv32_uart_putc('0' + ((char)err_code)); // FIXME err_code should/must be below 10

  neorv32_cpu_dint(); // deactivate IRQs
  if (STATUS_LED_EN == 1) {
    neorv32_gpio_port_set(1 << STATUS_LED); // permanently light up status LED
  }

  while(1); // freeze
}


/**********************************************************************//**
 * Print 32-bit number as 8-digit hexadecimal value (with "0x" suffix).
 *
 * @param[in] num Number to print as hexadecimal.
 **************************************************************************/
void print_hex_word(uint32_t num) {

  static const char hex_symbols[16] = "0123456789abcdef";

  neorv32_uart_print("0x");

  int i;
  for (i=0; i<8; i++) {
    uint32_t index = (num >> (28 - 4*i)) & 0xF;
    neorv32_uart_putc(hex_symbols[index]);
  }
}



// -------------------------------------------------------------------------------------
// SPI flash driver functions
// -------------------------------------------------------------------------------------

/**********************************************************************//**
 * Read byte from SPI flash.
 *
 * @param[in] addr Flash read address.
 * @return Read byte from SPI flash.
 **************************************************************************/
uint8_t spi_flash_read_byte(uint32_t addr) {

  neorv32_spi_cs_en(SPI_FLASH_CS);

  neorv32_spi_trans(SPI_FLASH_CMD_READ);
  spi_flash_write_addr(addr);
  uint8_t rdata = (uint8_t)neorv32_spi_trans(0);

  neorv32_spi_cs_dis(SPI_FLASH_CS);

  return rdata;
}


/**********************************************************************//**
 * Write byte to SPI flash.
 *
 * @param[in] addr SPI flash read address.
 * @param[in] wdata SPI flash read data.
 **************************************************************************/
void spi_flash_write_byte(uint32_t addr, uint8_t wdata) {

  spi_flash_write_enable(); // allow write-access

  neorv32_spi_cs_en(SPI_FLASH_CS);

  neorv32_spi_trans(SPI_FLASH_CMD_PAGE_PROGRAM);
  spi_flash_write_addr(addr);
  neorv32_spi_trans(wdata);

  neorv32_spi_cs_dis(SPI_FLASH_CS);

  spi_flash_write_wait(); // wait for write operation to finish
}


/**********************************************************************//**
 * Write word to SPI flash.
 *
 * @param addr SPI flash write address.
 * @param wdata SPI flash write data.
 **************************************************************************/
void spi_flash_write_word(uint32_t addr, uint32_t wdata) {

  union {
    uint32_t uint32;
    uint8_t  uint8[sizeof(uint32_t)];
  } data;

  data.uint32 = wdata;

  int i;
  for (i=0; i<4; i++) {
    spi_flash_write_byte(addr + i, data.uint8[i]);
  }
}


/**********************************************************************//**
 * Erase sector (64kB) at base adress.
 *
 * @param[in] addr Base address of sector to erase.
 **************************************************************************/
void spi_flash_erase_sector(uint32_t addr) {

  spi_flash_write_enable(); // allow write-access

  neorv32_spi_cs_en(SPI_FLASH_CS);

  neorv32_spi_trans(SPI_FLASH_CMD_SECTOR_ERASE);
  spi_flash_write_addr(addr);

  neorv32_spi_cs_dis(SPI_FLASH_CS);

  spi_flash_write_wait(); // wait for write operation to finish
}


/**********************************************************************//**
 * Read first byte of ID (manufacturer ID), should be != 0x00.
 *
 * @note The first bit of the manufacturer ID is used to detect if a Flash is connected at all.
 *
 * @return First byte of ID.
 **************************************************************************/
uint8_t spi_flash_read_1st_id(void) {

  neorv32_spi_cs_en(SPI_FLASH_CS);

  neorv32_spi_trans(SPI_FLASH_CMD_READ_ID);
  uint8_t id = (uint8_t)neorv32_spi_trans(0);

  neorv32_spi_cs_dis(SPI_FLASH_CS);

  return id;
}


/**********************************************************************//**
 * Wait for flash write operation to finisch.
 **************************************************************************/
void spi_flash_write_wait(void) {

  while(1) {

    neorv32_spi_cs_en(SPI_FLASH_CS);

    neorv32_spi_trans(SPI_FLASH_CMD_READ_STATUS);
    uint8_t status = (uint8_t)neorv32_spi_trans(0);

    neorv32_spi_cs_dis(SPI_FLASH_CS);

    if ((status & 0x01) == 0) { // write in progress flag cleared?
      break;
    }
  }
}


/**********************************************************************//**
 * Enable flash write access.
 **************************************************************************/
void spi_flash_write_enable(void) {

  neorv32_spi_cs_en(SPI_FLASH_CS);
  neorv32_spi_trans(SPI_FLASH_CMD_WRITE_ENABLE);
  neorv32_spi_cs_dis(SPI_FLASH_CS);
}


/**********************************************************************//**
 * Send address word to flash.
 *
 * @param[in] addr Address word.
 **************************************************************************/
void spi_flash_write_addr(uint32_t addr) {

  union {
    uint32_t uint32;
    uint8_t  uint8[sizeof(uint32_t)];
  } address;

  address.uint32 = addr;

  int i;
  for (i=2; i>=0; i--) {
    neorv32_spi_trans(address.uint8[i]);
  }
}
