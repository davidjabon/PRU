// PRU-ICSS program to output a 40kHz square wave on P9_27 (pru0_pru_r30_5)
// until a button that is connected to P9_28 (pru0_pru_r31_3 is pressed.

.origin 0 			//start of program in PRU memory
.entrypoint START		//program entry point (for a debugger)

#define DELAY 1249		//1/2*1/40000*1/(5e-9)*(1 loop/2 instructions) minus 1 (for clearing/setting pin and reseting REG0)
#define PRU0_R31_VEC_VALID 32   //allows notification of program completion
#define PRU_EVTOUT_0 3		//the event number that is sent back

START:
	SET	r30.t5		//turn on the output pin
	MOV	r0, DELAY	//store the length of the delay in REG0
DELAYON:
	SUB 	r0, r0, 1	//decrement register by 1
	QBNE	DELAYON, r0,0	//Loop to DELAYON, unlies REG0=0
LEDOFF:
	CLR	r30.t5		//clear the output pin
	MOV 	r0, DELAY	//reset the REG0 to the lenght of the delay
DELAYOFF:
	SUB 	r0, r0, 1	//decrement REG0 by 1
	QBNE	DELAYOFF, r0, 0	//Loop to DELAYOFF, unless REG0=0
	QBBC 	START, r31.t3	//check if button is pressed. If not, loop
END:				//notify the calling app that finished
	MOV 	r31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_0
	HALT			//halt the PRU program
