//  TEST 0013. CRGA Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO

test0013:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_CRGA
					cmp #$00					// Compare reset value
					beq test0013_ok
					jsr printKO 				// KO
					jmp test0013_end
test0013_ok:		jsr printOK 				// OK
test0013_end:

//  TEST 0014. CRGA Write and read
//      WRITE FF to CRGA
//		READ Should be 11101111

test0014:			jsr printTest				// Test header
					lda #$FF
					sta CIA2_CRGA
					lda CIA2_CRGA
					cmp #%11101111				// Compare
					beq test0014_ok
					jsr printKO 				// KO
					jmp test0014_end
test0014_ok:		jsr printOK 				// OK
test0014_end:

//  TEST 0015. CRGA Timer output on PB6
//  	Set PORTB as OUTPUT
//		Enable PB6 output (CREGA1=1)
//		Enable TIMERA Toggle (CREGA=2)
//		Check PB6. Should be 0
//		START and STOP Timer. PB6 should be 1

test0015:			jsr printTest
					jsr ciaReset
					lda #$FF
					sta CIA2_DDRB				// PORTB as output
					lda #%00000110
					sta CIA2_CRGA				// PB6 on and TOGGLE 
					lda CIA2_PRTB
					and #%01000000
					bne test0015_ko				// PB6 should be 0
					lda #%00000111
					ldx #%00000110
					sta CIA2_CRGA
					stx CIA2_CRGA				// start and stop TIMERA
					lda CIA2_PRTB
					and #%01000000
					beq test0015_ko				// Should be 1
					jsr printOK
					jmp test0015_end
test0015_ko:		jsr printKO
test0015_end:		

//	TEST 0016. TIMERA reload on RESET
// 		Resets CIA
//		TALO/TAHI should be FFFF

test0016:			jsr printTest
					jsr ciaReset
					lda CIA2_TALO
					cmp #$FF
					bne test0016_ko				// If not FF, test fails
					lda CIA2_TAHI
					cmp #$FF
					bne test0016_ko				// If not FF, test fails
					jsr printOK
					jmp test0016_end
test0016_ko:		jsr printKO
test0016_end:	

// 	TEST 0017. TIMERA read and write
//			Write 0000 and test back
//			If ON, inc until FF
//			

test0017:			jsr printTest
					jsr ciaReset
					ldx #$00
					ldy #$00
test0017_loop:		stx CIA2_TALO
					sty CIA2_TAHI
					cpx CIA2_TALO
					bne test0017_ko
					cpy CIA2_TAHI
					bne test0017_ko
					inx
					cpx #$00 
					bne test0017_loop
					lda #$01
					cmp MACHINE_TYPE
					beq test0017_ok 		 	// In Logisim complete only one loop
					iny
					cpy #$00
					bne test0017_loop

test0017_ok:		jsr printOK
					jmp test0017_end

test0017_ko:		jsr printKO
test0017_end:					

// 	TEST 0018. TIMERA reload on FORCELOAD
//			Start timer
//			Wait for delay
//			Issue FORCELOAD
// 			Wait for delay and stop
//			Test value.
//			Reload and test
//	Tests show that original MOS6526 stops at EEF7


test0018:			jsr ciaReset
					jsr printTest
					lda #$01
					sta CIA2_CRGA				// Start Timer
					jsr krnShortDelay	 		// Wait for delay
					lda #$11 					
					sta CIA2_CRGA 				// Force LOAD
					jsr krnLongDelay
					lda #$00 					
					sta CIA2_CRGA 				// Stop Timer
					nop
					nop
					lda CIA2_TALO 
					cmp #$F7
					bne test0018_ko
test0018_cont:		lda CIA2_TAHI
					cmp #$EE 
					bne test0018_ko 			// Test EEF7
					lda #$10 					
					sta CIA2_CRGA 				// Reload again
					lda CIA2_TALO 
					cmp #$FF
					bne test0018_ko
					lda CIA2_TAHI
					cmp #$FF 
					bne test0018_ko 			// Test FFFF
					jsr printOK
					jmp test0018_end
test0018_ko:		jsr printKO
test0018_end:

// 	TEST 0019. TIMERA reload on OVERFLOW
//			Set timer to low value
// 			Start timer
//			Delay
//			Stop Timer
//			Check timer
//	If reload on underflow is ok. should get same value

test0019:			jsr printTest
					jsr ciaReset
					lda #$10
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI				// Load 0010 on timer
					lda #$01
					sta CIA2_CRGA				// Start timer
					jsr krnLongDelay 			// Delay
					lda #$00
					sta CIA2_CRGA 				// Stop timer.Should be 0007
					lda CIA2_TAHI
					cmp #$00
					bne test0019_ko
					lda CIA2_TALO 
					cmp #$07
					bne test0019_ko
					jsr printOK
					jmp test0019_end
test0019_ko:		jsr printKO
test0019_end:		

// TEST 0020. TIMERA reload on TAHI write when not running
//		Reset CIA
// 		Start Timer (At FFFF)
//		write to TAHI while running
// 		read TAHI
//		Shouldn't reload
//		Stop timer
//		Read TAhi. shoudn't yet reload
//		Write TAHI
//		Read TAHI
//		Should Reload

test0020: 			jsr printTest
					jsr ciaReset
					lda #$01
					sta CIA2_CRGA 				// Start timer							
					sta CIA2_TAHI 				// Write 01 to TAHI
					lda CIA2_TAHI 				// Read TAHI
					cmp #$FF 		
					bne test0020_ko 			// STill should be FF
					lda #$00
					sta CIA2_CRGA 				// Stop Timer
					lda CIA2_TAHI
					cmp #$FF 					// Still should be FF
					bne test0020_ko
					lda #$01
					sta CIA2_TAHI				// Write 01 to TAHI
					lda CIA2_TAHI
					cmp #$01 					// Should update
					bne test0020_ko
					jsr printOK
					jmp test0020_end
test0020_ko:		jsr printKO
test0020_end:



// TEST 0021. TOGGLE OUTPUT
//		Reset CIA
//		Set PB6 ON / PB6 as output
//		Check timer output. Should be 0
//		Set low value
//		Start
//		Check. (Before toggling) Should be 1
//		Wait until toggle
//		Check.  Should be 0
//		Wait until toggle
//		Check.  Should be 1
//		Wait until toggle
//		Check.  Should be 0
//		Wait until toggle
//		Check.  Should be 1
//		Wait until toggle
//		Check.  Should be 0

test0021:  			jsr printTest
					jsr ciaReset

					lda #$07
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI				// Count 7 cycles

					lda #$02
					sta CIA2_CRGA 				// PB6 = on
					lda #$40
					sta CIA2_DDRB 				// PB6 as output
					and CIA2_PRTB
					bne test0021_ko 			// If PB6 != 0

  					lda #$07
  					sta CIA2_CRGA 				// Start time, PB6 as out,
  												// And toggle
  
  					lda #$40
  					and CIA2_PRTB
  					beq	test0021_ko				// Just started, if PB6 !=1
  												// This loop takes 7 cycles
  												// So each test, it should've
  												// toggled!
  
  					lda #$40
  					and CIA2_PRTB
  					bne	test0021_ko
  
  					lda #$40
  					and CIA2_PRTB
  					beq	test0021_ko
  
  					lda #$40
  					and CIA2_PRTB
  					bne	test0021_ko
  
  					lda #$40
  					and CIA2_PRTB
  					beq	test0021_ko															
  
  					lda #$40
  					and CIA2_PRTB
  					bne	test0021_ko
  
  					lda #$40
  					and CIA2_PRTB
  					beq	test0021_ko															
  
  					lda #$40
  					and CIA2_PRTB
  					bne	test0021_ko
  
  					lda #$40
  					and CIA2_PRTB
  					beq	test0021_ko															
  
  					lda #$40
  					and CIA2_PRTB
  					bne	test0021_ko
  
  					lda #$40
  					and CIA2_PRTB
  					beq	test0021_ko															

					jsr printOK	
					jmp test0021_end
test0021_ko:  		jsr printKO
test0021_end:

// TEST 0022. PULSE OUTPUT
//		Reset CIA
//		Set PB6 ON / PB6 as output
//		Check timer output. Should be 0
//		Set low value (0008)
//		Start
// 		Check timer on a 7 cycle long. Still 0

test0022:  			jsr printTest
					jsr ciaReset

					lda #$08
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI				// Count 8 cycles

					lda #$02
					sta CIA2_CRGA 				// PB6 = on
					lda #$40
					sta CIA2_DDRB 				// PB6 as output
					and CIA2_PRTB
					bne test0022_ko 			// If PB6 != 0

  					lda #$03
  					sta CIA2_CRGA 				// Start time, PB6 as out,
  												// And PULSE
  
  					lda #$40
  					and CIA2_PRTB
  					bne	test0022_ko				// Just started, if PB6 !=0
  												// This loop takes 7 cycles
  												// So each test, it drifts 1 cycle
  					lda #$40
  					and CIA2_PRTB
  					bne	test0022_ko				// Still 0
  					lda #$40
  					and CIA2_PRTB
  					bne	test0022_ko				// Still 0
  					lda #$40
  					and CIA2_PRTB
  					bne	test0022_ko				// Still 0
  					lda #$40
  					and CIA2_PRTB
  					bne	test0022_ko				// Still 0

  					lda #$40
  					and CIA2_PRTB
  					beq	test0022_ko				// Pulse!

					jsr printOK	
					jmp test0022_end
test0022_ko:  		jsr printKO
test0022_end:

// TEST 0023. Test ONESHOT
// 		Reset, and set timer for 0006
//		Start on oneshot
//		nop nop
// 		CHECK CREGA for 8
// 		CHECK TIMERA for 0006

test0023:  			jsr printTest
					jsr ciaReset
					lda #$06
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI
					lda #$09
					sta CIA2_CRGA 				// Start on oneshot
					nop
					nop
					nop
					lda CIA2_CRGA
					cmp #$08
					bne test0023_ko
					lda CIA2_TAHI
					cmp #$00
					bne test0023_ko
					lda CIA2_TALO
					cmp #$06
					bne test0023_ko
					jsr printOK
					jmp test0023_end
test0023_ko:		jsr printKO
test0023_end: 				



// TEST 0024. Double Count on underflow under PHI2
//		Reset CIA
//		Load timers with 6
//		Start
// 		Check value
// 		ON MOS6526 first count is 4
//		ON 74HCT6526 first count is 3. It start to count 1 cycle earler
//		OTHERWISE, check. 

test0024:  			jsr printTest
					jsr ciaReset

					lda #$06
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI				// Count 6 cycles

  					lda #$01
  					sta CIA2_CRGA 				// Start timer
  
  					lda CIA2_TALO
  					cmp #$04
  					bne	test0024_ko				

  					lda CIA2_TALO
  					cmp #$03
  					bne	test0024_ko				

  					lda CIA2_TALO
  					cmp #$02
  					bne	test0024_ko				

  					lda CIA2_TALO
  					cmp #$01
  					bne	test0024_ko				

  					lda CIA2_TALO
  					cmp #$06
  					bne	test0024_ko				

  					lda CIA2_TALO
  					cmp #$06
  					bne	test0024_ko				

  					lda CIA2_TALO
  					cmp #$05
  					bne	test0024_ko				

					jsr printOK	
					jmp test0024_end
test0024_ko:  		jsr printKO
test0024_end:

// TEST 0025. COUNT on CNT, and count = 0 on underflow
// 		Usaremos SPSEND desde la CIA1, para generar 8 pulsos
//		Set CIA2 SPMODE to IN
test0025:  			jsr printTest
					jsr ciaReset

					lda #$08
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI				// TIMERA set to 0008

					lda #%00100001
					sta CIA2_CRGA 				// SPMODE = input
												// Count CNT
												// Start TIMERA
					
					lda #%01000000
					sta CIA1_CRGA				// CIA1 SPMODE = OUTPUT											

					lda #$FF
					sta CIA1_TALO 				// CIA1 TA = 00FF
					lda #$00
					sta CIA1_TAHI

					lda #%01000001				
					sta CIA1_CRGA 				// START timera and SPOUT

					ldx #$AA
					stx CIA1_SDR 				// Write to PORT OUT

					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$00					// Should be 0
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$01					// Should be 1
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$02					// Should be 2
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$03					// Should be 3
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$04					// Should be 4
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$05					// Should be 5
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$06					// Should be 6
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$07					// Should be 7
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$08					// Should be 8
					bne test0025_ko

					stx CIA1_SDR 				// Write to PORT OUT
					jsr krnLongDelay 			// WAIT FOR SEND
					lda CIA2_TALO
					cmp #$00					// Should be 0
					bne test0025_ko

					jsr printOK
					jmp test0025_end
test0025_ko:		jsr printKO
test0025_end:					

// TEST 0026. 
// Stop timer on underflow. Even in continuos mode, it should stop a 0

test0026: 			jsr printTest
					jsr ciaReset
					lda #$06
					sta CIA2_TALO
					lda #$00
					sta CIA2_TAHI
					lda #$01
					sta CIA2_CRGA
					lda #$00
					sta CIA2_CRGA
					lda CIA2_TALO
					cmp #$00
					bne test0026_ko
					jsr printOK
					jmp test0026_end
test0026_ko:		jsr printKO
test0026_end:		