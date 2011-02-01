/**
 * @file _FILENAME_.oil
 *
 * @section desc File description
 *
 * @section copyright Copyright
 *
 * @section infos File informations
 *
 */
OIL_VERSION = "2.5" : "test" ;

IMPLEMENTATION trampoline {
    TASK {
        UINT32 STACKSIZE = 500 ;
        UINT32 PRIORITY = 1 ;
    } ;
    ISR {
        UINT32 STACKSIZE = 500 ;
    } ;
};

CPU test {

    OS config {
        STATUS = EXTENDED;
        ERRORHOOK = FALSE;
        PRETASKHOOK = FALSE;
        APP_SRC = "_FILENAME_.c"; 
        APP_NAME = "`'_FILENAME_`'_exe";
        TRAMPOLINE_BASE_PATH = "_TRAMPOLINE_";
        CFLAGS = "-g -c -ffreestanding -fsigned-char -mcpu=arm7tdmi -Os -Winline -Wall -Werror-implicit-function-declaration --param max-inline-insns-single=1000 -ffunction-sections -fdata-sections -std=gnu99";
        ASFLAGS = "-g -mcpu=arm7tdmi --fatal-warnings ";
        LDFLAGS = "-g --cref --allow-multiple-definition --gc-sections";
        LDFLAGS = "-L`'_LIBGCC_DIR_ -lgcc -L`'_LIBC_DIR_ -lc";
        SYSTEM_CALL = TRUE;
        
        COMPILER = "arm-elf-gcc";
        ASSEMBLER = "arm-elf-as";
        LINKER = "arm-elf-ld";
        MEMMAP = TRUE{
          COMPILER = gcc;
          LINKER = gnu_ld { SCRIPT = "script.ld"; };
          ASSEMBLER = gnu_as;
          MEMORY_PROTECTION = FALSE;
        };
    } ;

    APPMODE std {
    };

    TASK task1 {
        PRIORITY = 1;
        AUTOSTART = TRUE { APPMODE = std; };
        ACTIVATION = 1;
        SCHEDULE = FULL;
    };   
    
    COUNTER SystemCounter {
      SOURCE = it_timer1;
      MAXALLOWEDVALUE = 2000;
      TICKSPERBASE = 1;
      MINCYCLE = 1; 
    };

   ISR isr_button_start {
       CATEGORY = 2;
		PRIORITY = 1;
		SOURCE = button_start;
   };

   ISR isr_button_stop {
       CATEGORY = 2;
		PRIORITY = 1;
		SOURCE = button_stop;
   };

   ISR isr_button_left {
       CATEGORY = 2;
		PRIORITY = 1;
		SOURCE = button_left;
   };

   ISR isr_button_right {
       CATEGORY = 2;
		PRIORITY = 1;
		SOURCE = button_right;
   };
};

/* End of file nxt_simple.oil */

