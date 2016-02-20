// PRU-ICSS program to output 12 bit Sony IR 40kHz modulated signal on P9_27 
// (pru0_pru_r30_5)
// 

.origin 0 			//start of program in PRU memory
.entrypoint START		//program entry point (for a debugger)

#define DELAY 1249		//1/2*1/40000*1/(5e-9)*(1 loop/2 instructions)
#define PRU0_R31_VEC_VALID 32   //allows notification of program completion
#define PRU_EVTOUT_0 3		//the event number that is sent back

//macro to be off for 600 microseconds
//Note that whenever this macro is called, the pin is already low
//so we do not need to set the pin low
.macro off_for
.mparam LOOPS_OFF
        MOV     r0, LOOPS_OFF      //number of loops, 2 instructions (10ns) each
DELAY_START:
        SUB     r0, r0, 1       //decrement REG0 by 1
        QBNE    DELAY_START, r0, 0  //Loop to DELAY_START unless counter != 0
.endm


//macro to send 40kHz signal for 600 or 2400 microseconds (i.e. 24 or 96 cycles)
.macro on_for_n_cycles
.mparam CYCLES_ON
        MOV     r1, CYCLES_ON    //set the cycle count
START_CYCLE:
        SET     r30.t5          //turn on the output pin
        MOV     r0, DELAY       //store the length of the delay in REG0
DELAYON:
        SUB     r0, r0, 1       //decrement register by 1
        QBNE    DELAYON, r0,0   //Loop to DELAYON, unlies REG0=0

        CLR     r30.t5          //clear the output pin
        MOV     r0, DELAY       //reset the REG0 to the lenght of the delay
DELAYOFF:
        SUB     r0, r0, 1       //decrement REG0 by 1
        QBNE    DELAYOFF, r0, 0 //Loop to DELAYOFF, unless REG0=0

        SUB     r1, r1, 1        //decrement the cycle count
        QBNE    START_CYCLE, r1, 0      //Loop to START_CYCLE
.endm

//Beginning of the program
	//read the memory that was set by the C program into register
	MOV 	r0, 0x00000000
	LBBO	r12, r0, 0, 4
	MOV  r3, 3	//loop to send the pattern three times
START:
	on_for_n_cycles 96
	MOV 	r4, 0    //set inner loop variable; note we will count up
INNER_LOOP:
	off_for 60000
	on_for_n_cycles 24
	QBBC SKIP_TO, r12, r4
	on_for_n_cycles 24
SKIP_TO:
	ADD r4, r4, 1
	QBNE INNER_LOOP, r4, 12
OFF_PERIOD_AT_END:
	off_for 2640000
	SUB r3, r3, 1
	QBNE START, r3, 0		//loop back three times

END:				//notify the calling app that finished
	MOV 	r31.b0, PRU0_R31_VEC_VALID | PRU_EVTOUT_0
	HALT			//halt the PRU program