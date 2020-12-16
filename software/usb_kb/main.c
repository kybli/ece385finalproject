//ECE 385 USB Host Shield code
//based on Circuits-at-home USB Host code 1.x
//to be used for ECE 385 course materials
//Revised October 2020 - Zuofu Cheng

#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"
extern HID_DEVICE hid_device;
static BYTE addr = 1; 				//hard-wired USB address
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };
BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;
	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}
void setLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) | (0x001 << LED)));
}
void clearLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) & ~(0x001 << LED)));
}
void printSignedHex0(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	WORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(11);
		value = -value;
	} else {
		clearLED(11);
	}
	//handled hundreds
	if (value / 100)
		setLED(13);
	else
		clearLED(13);
	value = value % 100;
	tens = value / 10;
	ones = value % 10;
	pio_val &= 0x00FF;
	pio_val |= (tens << 12);
	pio_val |= (ones << 8);
	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}
void printSignedHex1(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	DWORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(10);
		value = -value;
	} else {
		clearLED(10);
	}
	//handled hundreds
	if (value / 100)
		setLED(12);
	else
		clearLED(12);
	value = value % 100;
	tens = value / 10;
	ones = value % 10;
	tens = value / 10;
	ones = value % 10;
	pio_val &= 0xFF00;
	pio_val |= (tens << 4);
	pio_val |= (ones << 0);
	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}
void setKeycode(WORD keycode)
{
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, keycode);
}
/*
int main() {
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;
	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	WORD keycode;
	printf("initializing MAX3421E...\n");
	MAX3421E_init();
	printf("initializing USB...\n");
	USB_init();
	while (1) {
		printf(".");
		MAX3421E_Task();
		USB_Task();
		//usleep (500000);
		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				setLED(9);
				device = GetDriverandReport();
			} else if (device == 1) {
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
				if (rcode == hrNAK) {
					continue; //NAK means no new data
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				printf("keycodes: ");
				for (int i = 0; i < 6; i++) {
					printf("%x ", kbdbuf.keycode[i]);
				}
				setKeycode(kbdbuf.keycode[0]);
				printSignedHex0(kbdbuf.keycode[0]);
				printSignedHex1(kbdbuf.keycode[1]);
				printf("\n");
			}
			else if (device == 2) {
				rcode = mousePoll(&buf);
				if (rcode == hrNAK) {
					//NAK means no new data
					continue;
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				printf("X displacement: ");
				printf("%d ", (signed char) buf.Xdispl);
				printSignedHex0((signed char) buf.Xdispl);
				printf("Y displacement: ");
				printf("%d ", (signed char) buf.Ydispl);
				printSignedHex1((signed char) buf.Ydispl);
				printf("Buttons: ");
				printf("%x\n", buf.button);
				if (buf.button & 0x04)
					setLED(2);
				else
					clearLED(2);
				if (buf.button & 0x02)
					setLED(1);
				else
					clearLED(1);
				if (buf.button & 0x01)
					setLED(0);
				else
					clearLED(0);
			}
		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
				errorflag = 1;
				clearLED(9);
				printf("USB Error State\n");
				//print out string descriptor here
			}
		} else //not in USB running state
		{
			printf("USB task state: ");
			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}
	}
	return 0;
}
*/																	/*
#include "kiss_fft.h"

#include <time.h>
#include <stdlib.h>
#include <math.h>

#define FIXED_POINT 32
#define SIZE 256
#define BILLION 1000000000.0
#define INPUT_MAX 16777216

int main() {
	// Test the memory access;
	// memory_ptr[260] = 0xA0A0;
	// Initialize possible test vectors
	// Vector 1. This will be used for the imaginary component of inputs as all our inputs are real

    int i;
    // int vec1[SIZE];
    float vec1[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec1[i] = 0.0f;
    																*/
    // Vector 2: Only 1s
    /*
    int vec2[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec2[i] = 1;
    */
    // Vector 3: Impulse at n = 0
    /*
    int vec3[SIZE];
    for (i = 1; i < SIZE; ++i)
        vec3[i] = 0;
    vec3[0] = 1;
    */
    
    // Vector 4: Impulse at n = SIZE/4
	/*
    int vec4[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec4[i] = 0;
    vec4[SIZE/4] = 1;
    */
   
    // Vector 5: Impulse at n = SIZE/2
    /*
    int vec5[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec5[i] = 0;
    vec5[3*SIZE/4] = 1;
    */

	// Vector 6: Random impulses
    /*
    int vec6[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec6[i] = rand() % INPUT_MAX;
    */
    // Vector 7: Rectangle, where the first 8 impulses are 1
    /*
   int vec7[SIZE];
   for (i = 0; i < SIZE; ++i) {
	   vec7[i] = 0.0;
   }
   for (int i = 0; i < 8; ++i)
   {
	   vec7[i] = 1.0;
   }
   */
   	   	   	   	   	   	   	   	   	   	   	   	   	   	   	   	   	   	   	   	   /*

	// NEW EDITS
	volatile unsigned int * audio_data_transfer = (unsigned int *) 0x08002000;
	// unsigned int audio_data[SIZE];
	int audio_data[SIZE];

	int is_inverse_fft = 0; // We are not doing an inverse fft
	kiss_fft_cfg config = kiss_fft_alloc(SIZE, is_inverse_fft, 0 ,0);
	
	while(1)
		{
			// set ready bit so that data can't be changed while reading
			//audio_data_transfer[512] = 0;
			// audio_data_transfer[512] = 0x234432;
			// printf(" Val in reg: %d", audio_data_transfer[512]);

			for(i = 0; i < SIZE; i++)
			{
				// always 1 dummy sclk period before each audio sample in DIN, so fix it here
				// also add 1 to index of audio_data_transfer_in because the first reg (idx 0) of audio_data_in_transfer is the ready reg
				// audio_data[i] = audio_data_transfer[i] >> 1;
				audio_data[i] = (float) audio_data_transfer[i];
			}
			//audio_data_transfer[512] = 0;
			// printf(" Val in reg: %d", audio_data_transfer[512]);


			
			kiss_fft_cpx in[SIZE], out[SIZE];
			int out_int[SIZE];
			// Load the complex and real values into the inputs.
			for (int i = 0; i < SIZE; ++i)
			{
				in[i].r = audio_data[i];
				in[i].i = vec1[i];
			}
			
			kiss_fft(config, in, out);
			#define BIN_FREQ (float)((i-SIZE/2.0)*44100.0/SIZE)
			

			for (i = 0; i < SIZE; ++i)
			{
				printf("Audio bin %d : %d", i, audio_data_transfer[i]);
				 printf("Freq %f, Real : %f; Complex: %f \n", BIN_FREQ, out[i].r, out[i].i);
				 //out_int[i] = (int) sqrt((out[i].r*out[i].r + out[i].i*out[i].i));
				//printf("Magnitude : %d \n", out_int[i]);

				// NEW EDITS
				audio_data_transfer[i + SIZE] = out_int[i];
    		}
			
		}

    
    return 0;
}
																						*/



/*
int is_inverse_fft = 0; // We are not doing an inverse fft
kiss_fft_cfg config = kiss_fft_alloc(SIZE, is_inverse_fft, 0 ,0);
kiss_fft_cpx in[SIZE], out[SIZE];
int out_int[SIZE];
// Load the complex and real values into the inputs.
for (int i = 0; i < SIZE; ++i)
{
	in[i].r = vec8[i];
	in[i].i = vec1[i];
}
kiss_fft(config, in, out);
#define BIN_FREQ (float)((i-SIZE/2.0)*44100.0/SIZE)
for (i = 0; i < SIZE; ++i)
{
	// printf("Freq %f, Real : %f; Complex: %f \n", BIN_FREQ, out[i].r, out[i].i);
	out_int[i] = (int) (out[i].r*out[i].r + out[i].i*out[i].i);
	printf("Magnitude : %d \n", out_int[i]);	
}
kiss_fft_free(config);
// clock_gettime(CLOCK_REALTIME, &end);
// double time_spent;
// time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
// printf("Time Elapsed: %f s\n", time_spent);
*/


/*
256 - Dynamically update 0 1 2 ... ~24 bits [24]      [24]            [24]
260?? - Store a copy of them  32 bits [00000.. 1 - 24][00000.. 1 - 24][00000.. 1 - 24]
When we ask for samples, we need to send a signal similar to the AES_Done signal.
*/








#include "kiss_fft.h"

#include <time.h>
#include <stdlib.h>

#define FIXED_POINT 32
#define SIZE 256
#define BILLION 1000000000.0
#define INPUT_MAX 16777216

int main() {
    // Initialize possible test vectors
    //struct timespec start, end;
    //clock_gettime(CLOCK_REALTIME, &start);
    //srand(start.tv_nsec);
    // Vector 1. This will be used for the imaginary component of inputs as all our inputs are real
    int i;
    float vec1[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec1[i] = 0;


    // Vector 2: Only 1s
    float vec2[SIZE];
    vec2[0] = 65535;
    vec2[1] = 65535;
    vec2[2] = 65535;
    vec2[3] = 65535;
    for (i = 4; i < SIZE; ++i)
        vec2[i] = 4294967296;

    /*
    // Vector 3: Impulse at n = 0
    int vec3[SIZE];
    for (i = 1; i < SIZE; ++i)
        vec3[i] = 0;
    vec3[0] = 1;
    */
    /*
    // Vector 4: Impulse at n = SIZE/4
    int vec4[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec4[i] = 0;
    vec4[SIZE/4] = 1;
    */
    /*
    // Vector 5: Impulse at n = SIZE/2
    int vec5[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec5[i] = 0;
    vec5[3*SIZE/4] = 1;
    */
    /*
    // Vector 6: Random impulses

    int vec6[SIZE];
    for (i = 0; i < SIZE; ++i)
        vec6[i] = rand() % INPUT_MAX;
    */

    ////int is_inverse_fft = 0; // We are not doing an inverse fft
    ////kiss_fft_cfg config = kiss_fft_alloc(SIZE, is_inverse_fft, 0 ,0);
    ////kiss_fft_cpx in[SIZE], out[SIZE];
    // Load the complex and real values into the inputs.
    ////for (int i = 0; i < SIZE; ++i) {
    ////    in[i].r = vec2[i];
    ////    in[i].i = vec1[i];
    ////}
    ////kiss_fft(config, in, out);
    ////#define BIN_FREQ (float)((i-SIZE/2.0)*44100.0/SIZE)
    ////for (i = 0; i < SIZE; ++i) {
        // printf("Element %f, Real : %f; Complex: %f \n", i, out[i].r, out[i].i);
        ////printf("Freq %f, Real : %f; Complex: %f \n", BIN_FREQ, out[i].r, out[i].i);
        // printf("Freq %f, Real : %a; Complex: %a \n", BIN_FREQ, out[i].r, out[i].i);
    ////}
    ////kiss_fft_free(config);



    	BYTE rcode;
    	BOOT_MOUSE_REPORT buf;		//USB mouse report
    	BOOT_KBD_REPORT kbdbuf;
    	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
    	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
    	BYTE device;
    	WORD keycode;
    	printf("initializing MAX3421E...\n");
    	MAX3421E_init();
    	printf("initializing USB...\n");
    	USB_init();







    volatile unsigned int * audio_data_transfer = (unsigned int *) 0x08002000;
    	// unsigned int audio_data[SIZE];
    	float audio_data[SIZE];

    	int is_inverse_fft = 0; // We are not doing an inverse fft
    	kiss_fft_cfg config = kiss_fft_alloc(SIZE, is_inverse_fft, 0 ,0);

    	int out_int[SIZE];

    	while(1)
    		{
    			// set ready bit so that data can't be changed while reading
    			audio_data_transfer[512] = 1;
    			// audio_data_transfer[512] = 0x234432;
    			// printf(" Val in reg: %d", audio_data_transfer[512]);

    			for(i = 0; i < SIZE; i++)
    			{
    				// always 1 dummy sclk period before each audio sample in DIN, so fix it here
    				// also add 1 to index of audio_data_transfer_in because the first reg (idx 0) of audio_data_in_transfer is the ready reg
    				// audio_data[i] = audio_data_transfer[i] >> 1;
    				audio_data[i] = (float) audio_data_transfer[i];
    			}
    			audio_data_transfer[512] = 0;
    			// printf(" Val in reg: %d", audio_data_transfer[512]);



    			kiss_fft_cpx in[SIZE], out[SIZE];

    			// Load the complex and real values into the inputs.
    			for (int i = 0; i < SIZE; ++i)
    			{
    				in[i].r = audio_data[i];
    				//in[i].r = vec2[i];
    				in[i].i = vec1[i];
    			}

    			kiss_fft(config, in, out);
    			#define BIN_FREQ (float)((i-SIZE/2.0)*44100.0/SIZE)


    			for (i = 0; i < SIZE; ++i)
    			{
    				///printf("Audio bin %d : %f, %f", i, audio_data[i], vec2[i]);
    				//printf("Audio binT %d : %d", i, audio_data_transfer[i]);
    				 ///printf("Freq %f, Real : %f; Complex: %f \n", BIN_FREQ, out[i].r, out[i].i);
    				 out_int[i] = (int) sqrt((out[i].r*out[i].r + out[i].i*out[i].i));
    				//printf("Magnitude : %d \n", out_int[i]);
    				 printf("Freq %f, Real : %f; Complex: %f \n", BIN_FREQ, out[i].r, out[i].i);
    				 //printf("DATA : %d \n", out_int[i]);
    				// NEW EDITS
    				audio_data_transfer[i + SIZE] = out_int[i];
        		}

    			//kiss_fft_free(config);






    			///printf(".");
					MAX3421E_Task();
					USB_Task();
					//usleep (500000);
					if (GetUsbTaskState() == USB_STATE_RUNNING) {
						if (!runningdebugflag) {
							runningdebugflag = 1;
							setLED(9);
							device = GetDriverandReport();
						} else if (device == 1) {
							//run keyboard debug polling
							rcode = kbdPoll(&kbdbuf);
							if (rcode == hrNAK) {
								continue; //NAK means no new data
							} else if (rcode) {
								///printf("Rcode: ");
								///printf("%x \n", rcode);
								continue;
							}
							printf("keycodes: ");
							for (int i = 0; i < 6; i++) {
								///printf("%x ", kbdbuf.keycode[i]);
							}
							setKeycode(kbdbuf.keycode[0]);
							printSignedHex0(kbdbuf.keycode[0]);
							printSignedHex1(kbdbuf.keycode[1]);
							///printf("\n");
						}
						else if (device == 2) {
							rcode = mousePoll(&buf);
							if (rcode == hrNAK) {
								//NAK means no new data
								continue;
							} else if (rcode) {
								printf("Rcode: ");
								printf("%x \n", rcode);
								continue;
							}
							printf("X displacement: ");
							printf("%d ", (signed char) buf.Xdispl);
							printSignedHex0((signed char) buf.Xdispl);
							printf("Y displacement: ");
							printf("%d ", (signed char) buf.Ydispl);
							printSignedHex1((signed char) buf.Ydispl);
							printf("Buttons: ");
							printf("%x\n", buf.button);
							if (buf.button & 0x04)
								setLED(2);
							else
								clearLED(2);
							if (buf.button & 0x02)
								setLED(1);
							else
								clearLED(1);
							if (buf.button & 0x01)
								setLED(0);
							else
								clearLED(0);
						}
    					} else if (GetUsbTaskState() == USB_STATE_ERROR) {
    						if (!errorflag) {
    							errorflag = 1;
    							clearLED(9);
    							printf("USB Error State\n");
    							//print out string descriptor here
    						}
    					} else //not in USB running state
    					{
    						printf("USB task state: ");
    						printf("%x\n", GetUsbTaskState());
    						if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
    							runningdebugflag = 0;
    							MAX3421E_init();
    							USB_init();
    						}
    						errorflag = 0;
    						clearLED(9);
    					}
    		}





    /*clock_gettime(CLOCK_REALTIME, &end);
    double time_spent;
    time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
    printf("Time Elapsed: %f s\n", time_spent);*/


    return 0;
}



//ECE 385 USB Host Shield code
//based on Circuits-at-home USB Host code 1.x
//to be used for ECE 385 course materials
//Revised October 2020 - Zuofu Cheng
/*
#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"

extern HID_DEVICE hid_device;

static BYTE addr = 1; 				//hard-wired USB address
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };

BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;

	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}

void setLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) | (0x001 << LED)));
}

void clearLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) & ~(0x001 << LED)));

}

void printSignedHex0(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	WORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(11);
		value = -value;
	} else {
		clearLED(11);
	}
	//handled hundreds
	if (value / 100)
		setLED(13);
	else
		clearLED(13);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0x00FF;
	pio_val |= (tens << 12);
	pio_val |= (ones << 8);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void printSignedHex1(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	DWORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(10);
		value = -value;
	} else {
		clearLED(10);
	}
	//handled hundreds
	if (value / 100)
		setLED(12);
	else
		clearLED(12);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0xFF00;
	pio_val |= (tens << 4);
	pio_val |= (ones << 0);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void setKeycode(WORD keycode)
{
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, keycode);
}
int main() {
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	WORD keycode;

	printf("initializing MAX3421E...\n");
	MAX3421E_init();
	printf("initializing USB...\n");
	USB_init();
	while (1) {
		printf(".");
		MAX3421E_Task();
		USB_Task();
		//usleep (500000);
		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				setLED(9);
				device = GetDriverandReport();
			} else if (device == 1) {
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
				if (rcode == hrNAK) {
					continue; //NAK means no new data
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				printf("keycodes: ");
				for (int i = 0; i < 6; i++) {
					printf("%x ", kbdbuf.keycode[i]);
				}
				setKeycode(kbdbuf.keycode[0]);
				printSignedHex0(kbdbuf.keycode[0]);
				printSignedHex1(kbdbuf.keycode[1]);
				printf("\n");
			}

			else if (device == 2) {
				rcode = mousePoll(&buf);
				if (rcode == hrNAK) {
					//NAK means no new data
					continue;
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				printf("X displacement: ");
				printf("%d ", (signed char) buf.Xdispl);
				printSignedHex0((signed char) buf.Xdispl);
				printf("Y displacement: ");
				printf("%d ", (signed char) buf.Ydispl);
				printSignedHex1((signed char) buf.Ydispl);
				printf("Buttons: ");
				printf("%x\n", buf.button);
				if (buf.button & 0x04)
					setLED(2);
				else
					clearLED(2);
				if (buf.button & 0x02)
					setLED(1);
				else
					clearLED(1);
				if (buf.button & 0x01)
					setLED(0);
				else
					clearLED(0);
			}
		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
				errorflag = 1;
				clearLED(9);
				printf("USB Error State\n");
				//print out string descriptor here
			}
		} else //not in USB running state
		{

			printf("USB task state: ");
			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}

	}
	return 0;
}
*/
