// -----------------------------------------------------------------------------
// 
// 6526 Test Suite for SBC6526 v2 v2.0.2
//
// -----------------------------------------------------------------------------
//  
// Target Test is CIA2 (CIAEXT)
// CIA1 should be regular CIA
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//
// 2018 - 2022
//
// -----------------------------------------------------------------------------

					// bypass menu
 					// jmp test0026


// -----------------------------------------------------------------------------
// Initialization
// -----------------------------------------------------------------------------
ciaTestStart:
					lda #$01
					cmp MACHINE_TYPE 
					beq jmp_testCIA2			// In logisim, skip to TEST

					ldx #<str_title				// Print title			
					ldy #>str_title
					jsr scrPrintStr		

					ldx #<str_menu
					ldy #>str_menu				// Print Menu
					jsr scrPrintStr

					lda #$70
					sta SCREEN_POINTER+1
					stz SCREEN_POINTER			// Move screen window to menu

					ldx #$15  					// 21 2 row 2 col
					stx SCREEN_CURSOR_POINTER   // Seleccionamos opcion 1

					lda #<menuKeyDown
					sta keyDown
					lda #>menuKeyDown
					sta keyDown+1

					lda #<menuKeyUp
					sta keyUp
					lda #>menuKeyUp
					sta keyUp+1 				// Remay UP/DOWN for MENU		

					jsr kbdWaitOK 				// Wait for SEL

					cpx #$15 					// TEST CIA 2
					beq jmp_testCIA2
					cpx #$29 					// DISPLAY CIA 1
					beq jmp_displayCIA1
					cpx #$3D					// DISPLAY CIA 2
					beq jmp_displayCIA2
					jmp ciaTestStart

jmp_displayCIA1:
					lda #$88
					sta $FF
					lda #$00
					sta $FE
					jsr scrClear
					jmp displayCIA
jmp_displayCIA2:
					lda #$98
					sta $FF
					lda #$00
					sta $FE		
					jsr scrClear
					jmp displayCIA

jmp_testCIA2:					
					lda #<scrScrollDown
					sta keyDown
					lda #>scrScrollDown
					sta keyDown+1

					lda #<scrScrollUp
					sta keyUp
					lda #>scrScrollUp
					sta keyUp+1 				// Restore UP/DOWN for scroll

					jsr scrInitialize
					jsr scrClear					
			     	ldx #<str_title				// Print title			
					ldy #>str_title
					jsr scrPrintStr	

					jmp testCIA2 				// Jump to option

// -----------------------------------------------------------------------------
// CIA DISPLAY
// -----------------------------------------------------------------------------
displayCIA:			
					lda #%11000000
					sta VIA_IER					// just in case, enable VIA int

					ldx #$00
					ldy #$00
displayCIAnext:					
					lda ($FE),y 				// LDA PRTA

					clc
					and #$F0
					ror
					ror
					ror
					ror
					jsr nib2hex
					sta $7001,x 				// Sta en screen
					inx 
					lda ($FE),y 				// LDA PRTA again
				
					and #$0F
					jsr nib2hex
					sta $7001,x 
					inx
					inx
					inx 						// TWo blancs
					iny 						// next register
					cpy #$10
					beq displayCIA 				// Rollover. Restart
					jmp displayCIAnext	        // no, next register



// -----------------------------------------------------------------------------
// Selection Menu Handler
// -----------------------------------------------------------------------------
menuKeyDown:
					pha
					lda #' '
					sta ($7000),x
					cpx #$15
					bne mKD_1
					ldx #$29
					jmp menuKeyEnd

mKD_1: 				cpx #$29
					bne menuKeyEnd
					ldx #$3D
 					jmp menuKeyEnd			

menuKeyUp:
					pha
					lda #' '
					sta ($7000),x			
					cpx #$3D
					bne mKU_1
					ldx #$29
					jmp menuKeyEnd 

mKU_1:				cpx #$29
					bne menuKeyEnd
					ldx #$15

menuKeyEnd:			pla
					stx SCREEN_CURSOR_POINTER
					rts

// -----------------------------------------------------------------------------
// Begin of CIA2 Testing
// -----------------------------------------------------------------------------

testCIA2:
					lda #$01 					// Reset test value to 1
					sta testNo					// TestNo holds running test
            		dec
	           		sta testNo+1 				// as a 2 byte decimal
	           		sta testOK+1
	           		sta testOK
            		jsr ciaReset				// Local Reset CIAs

//  TEST 0001. DDRA Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO

test0001:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_DDRA
					cmp #$00					// Compare reset value
					beq test0001_ok
					jsr printKO 				// KO
					jmp test0001_end
test0001_ok:		jsr printOK 				// OK
test0001_end:

//  TEST 0002. DDRB Initialization Value
//		RESET
//		READ and CMP #$0
//		EQ OK NE KO

test0002: 			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_DDRB
					cmp #$00					// Compare reset value
					beq test0002_ok
					jsr printKO 				// KO
					jmp test0002_end
test0002_ok:		jsr printOK 				// OK
test0002_end:	

//	TEST 0003. DDRA WRITE / READ
//		RESET
//		WRITE 00..FF to DDRA
//		READ BACK
//		IF ALL EQ OK, NE KO

test0003:			jsr printTest
         			jsr ciaReset
         			clc
         			lda #$00
test0003_01:		sta CIA2_DDRA
         			cmp CIA2_DDRA
         			bne test0003_ko
         			clc
         			adc #$01
         			bcs test0003_ok
         			jmp test0003_01
test0003_ko: 		jsr printKO
         			jmp test0003_end
test0003_ok:		jsr printOK
test0003_end:		lda #$00
					sta CIA2_DDRA

//	TEST 0004. DDRB WRITE / READ
//		RESET
//		WRITE 00..FF to DDRB
//		READ BACK
//		IF ALL EQ OK, NE KO

test0004:			jsr printTest
         			jsr ciaReset
         			clc
         			lda #$00
test0004_01:		sta CIA2_DDRB
         			cmp CIA2_DDRB
         			bne test0004_ko
         			clc
         			adc #$01
         			bcs test0004_ok
         			jmp test0004_01
test0004_ko: 		jsr printKO
         			jmp test0004_end
test0004_ok:		jsr printOK
test0004_end:		lda #$00
					sta CIA2_DDRB

//	TEST 0005. PORTA as INPUT
//		RESET
//		READ PORTA
//		EQ FF OK, NE KO
//		Tests DDR=0 (All inputs) and passive pull-ups

test0005:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_PRTA
					cmp #$FF					// Compare reset value
					beq test0005_ok
					jsr printKO 				// KO
					jmp test0005_end
test0005_ok:		jsr printOK 				// OK
test0005_end:

//	TEST 0006. PORTB as INPUT
//		RESET
//		READ PORTB
//		EQ FF OK, NE KO
//		Tests DDR=0 (All inputs) and passive pull-ups

test0006:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda CIA2_PRTB
					cmp #$FF					// Compare reset value
					beq test0006_ok
					jsr printKO 				// KO
					jmp test0006_end
test0006_ok:		jsr printOK 				// OK
test0006_end:

//	TEST 0007. PORTA as OUTPUT RESET VALUE
//		RESET. DDRA=FF
//		READ PORTA
//		EQ 00 OK, NE KO
//		Tests DDR=1 (All outputs) reset value

test0007:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda #$FF
					sta CIA2_DDRA
					lda CIA2_PRTA
					cmp #$00 					// Compare reset value
					beq test0007_ok
					jsr printKO 				// KO
					jmp test0007_end
test0007_ok:		jsr printOK 				// OK
test0007_end:

//	TEST 0008. PORTB as OUTPUT RESET VALUE
//		RESET. DDRB=FF
//		READ PORTB
//		EQ 00 OK, NE KO
//		Tests DDR=1 (All outputs) reset value

test0008:			jsr printTest				// Test header
					jsr ciaReset				// Reset CIA
					lda #$FF
					sta CIA2_DDRB
					lda CIA2_PRTB
					cmp #$00 					// Compare reset value
					beq test0008_ok
					jsr printKO 				// KO
					jmp test0008_end
test0008_ok:		jsr printOK 				// OK
test0008_end:

//	TEST 0009. PORTA as input
//		RESET. DDRA1=FF
//		WRITE 00..FF to PORTA1
//		READ PORTA2
//		IF ALL EQ OK, NE KO
//		Tests PORTA2 as input, driven by PORTA1

test0009:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA1_DDRA						
					clc									
					lda #$00 							
test0009_01:		sta CIA1_PRTA 						
         			cmp CIA2_PRTA 						
  					bne test0009_ko						
  					clc
         			adc #$01
         			bcs test0009_ok
         			jmp test0009_01
test0009_ko: 		jsr printKO
         			jmp test0009_end
test0009_ok:		jsr printOK
test0009_end:		lda #$00
					sta CIA1_DDRA

//	TEST 0010. PORTB as input
//		RESET. DDRB1=FF
//		WRITE 00..FF to PORTB1
//		READ PORTB2
//		IF ALL EQ OK, NE KO
//		Tests PORTB2 as input, driven by PORTB1

test0010:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA1_DDRB						
					clc									
					lda #$00 							
test0010_01:		sta CIA1_PRTB 						
         			cmp CIA2_PRTB 						
  					bne test0010_ko						
  					clc
         			adc #$01
         			bcs test0010_ok
         			jmp test0010_01
test0010_ko: 		jsr printKO
         			jmp test0010_end
test0010_ok:		jsr printOK
test0010_end:		lda #$00
					sta CIA1_DDRB

//	TEST 0011. PORTA as output
//		RESET. DDRA2=FF
//		WRITE 00..FF to PORTA2
//		READ PORTA1
//		IF ALL EQ OK, NE KO
//		Tests PORTA2 as output, read by PORTA1

test0011:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA2_DDRA						
					clc									
					lda #$00 							
test0011_01:		sta CIA2_PRTA 						
         			cmp CIA1_PRTA 						
  					bne test0011_ko						
  					clc
         			adc #$01
         			bcs test0011_ok
         			jmp test0011_01
test0011_ko: 		jsr printKO
         			jmp test0011_end
test0011_ok:		jsr printOK
test0011_end:		lda #$00
					sta CIA2_DDRA

//	TEST 0012. PORTB as output
//		RESET. DDRB2=FF
//		WRITE 00..FF to PORTB2
//		READ PORTB1
//		IF ALL EQ OK, NE KO
//		Tests PORTB2 as output, read by PORTB1

test0012:			jsr printTest
         			jsr ciaReset
         			lda #$FF							
					sta CIA2_DDRB						
					clc									
					lda #$00 							
test0012_01:		sta CIA2_PRTB 						
         			cmp CIA1_PRTB 						
  					bne test0012_ko						
  					clc
         			adc #$01
         			bcs test0012_ok
         			jmp test0012_01
test0012_ko: 		jsr printKO
         			jmp test0012_end
test0012_ok:		jsr printOK
test0012_end:		lda #$00
					sta CIA2_DDRB

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
//		START and STOP Timer. PB7 should be 1

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
//      74HCT6526 stops at EEF8. Reload happens a cycle earlier.
//      MOS6526 will end OK
//      74HCT6526 will end as PR (Partial Result)
// 			FIX: Removed one FF in the FORCELOAD chain


test0018:			jsr ciaReset
					jsr printTest
					lda #$00
					sta part 					// Flag de resultado parcial a 0
					lda #$01
					sta CIA2_CRGA				// Start Timer
					jsr krnLongDelay 			// Wait for delay
					lda #$11 					
					sta CIA2_CRGA 				// Force LOAD
					jsr krnLongDelay
					lda #$00 					
					sta CIA2_CRGA 				// Stop Timer
					nop
					nop
					lda CIA2_TALO 
					cmp #$F7
					beq test0018_cont
					cmp #$F8
					bne test0018_ko
					lda #$FF
					sta part
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
					lda part
					cmp #$00
					bne test0018_part
					jsr printOK
					jmp test0018_end
test0018_ko:		jsr printKO
					jmp test0018_end
test0018_part:		jsr printPR
					jmp test0018_end
part:				.byte 00					
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

// 					lda #$40
// 					and CIA2_PRTB
// 					bne	test0022_ko				// Still 0 on hct :(

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



// Exit
			jmp ciaTestsEnd

// -----------------------------------------------------------------------------
// End of Tests
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Functions
// -----------------------------------------------------------------------------

printTest:

		// Print " TEST "
			phx
			phy
			pha
			ldx #<str_test
			ldy #>str_test
			jsr scrPrintStr
			
		// Print number
			lda testNo+1
			ror
			ror
			ror
			ror
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar
			lda testNo+1
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar

			lda testNo
			ror
			ror
			ror
			ror
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar
			lda testNo
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar		


										// Very long delay for screen 
		    lda #$01
		    cmp MACHINE_TYPE
		    beq printTest_01
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
			jsr krnLongDelay
printTest_01: 
			lda #%01000000
			sta VIA_IER 				// DISABLEVIA Timer 1 interrupts
										// Prevent unexpected delays

		// Increment test number
			sed
			lda testNo
			clc
			adc #$01
			sta testNo
			cmp #$00
			beq incrementNext
			cld
			pla
			ply
			plx
			rts

	incrementNext:
			lda testNo+1
			clc
			adc #$01
			sta testNo+1
			cld 			
			pla
			ply
			plx
			rts

printKO:
			phx
			phy
			ldx #<str_txtKO
			ldy #>str_txtKO
			jsr scrPrintStr
			ply
			plx
			lda #%11000000
			sta VIA_IER 				// Enable Timer 1 interrupts
			rts

printPR:
			phx
			phy
			ldx #<str_txtPR
			ldy #>str_txtPR
			jsr scrPrintStr
			ply
			plx
			lda #%11000000
			sta VIA_IER 				// Enable Timer 1 interrupts
			rts			


printOK:
			phx
			phy
			pha
			ldx #<str_txtOK
			ldy #>str_txtOK
			jsr scrPrintStr
		// Increment OK TEST counter
			sed
			lda testOK
			clc
			adc #$01
			sta testOK
			cmp #$00
			beq incrementNextOK
			cld
			pla
			ply
			plx
			lda #%11000000
			sta VIA_IER 				// Enable Timer 1 interrupts
			rts

	incrementNextOK:
			lda testOK+1
			clc
			adc #$01
			sta testOK+1
			cld 			
			pla
			ply
			plx
			rts

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------

testNo:
			.word $0000

testOK:		.word $0000			

str_title:
			.text "-= 74HCT6526 TEST =-"
			.byte $00

str_menu:
			.text "   TEST CIA 2       "
			.text "   DISPLAY CIA 1    "
			.text "   DISPLAY CIA 2    "
			.byte $00
str_test:
			.text " TEST "
			.byte $00

str_txtOK:
			.text "   ( OK ) "
			.byte $00

str_txtKO:
			.text "   ( KO ) "
			.byte $00

str_txtPR:
			.text "   ( PR ) "
			.byte $00

str_total:  .text "   OK "
			.byte $00

str_slash:  .text " / "
			.byte $00


ciaTestsEnd:

			ldx #<str_total	
			ldy #>str_total
			jsr scrPrintStr

			// Print total oks
			lda testOK+1
			ror
			ror
			ror
			ror
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar
			lda testOK+1
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar

			lda testOK
			ror
			ror
			ror
			ror
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar
			lda testOK
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar		

			ldx #<str_slash	
			ldy #>str_slash
			jsr scrPrintStr	

			// Print total result 
			// substract 1 first
			sed
			sec
			lda testNo
			sbc #$01 
			sta testNo
			bne printTotal
			dec testNo+1
printTotal:
			cld
			lda testNo+1
			ror
			ror
			ror
			ror
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar
			lda testNo+1
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar

			lda testNo
			ror
			ror
			ror
			ror
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar
			lda testNo
			and #$0F
			clc
			adc #$30
			jsr scrPrintChar					
			jmp endendendend

// -----------------------------------------------------------------------------
// Draft Area
// -----------------------------------------------------------------------------


// tests. PORTS _ TEST PC PULSE!
//        PORTS _ irq ON pc PULSE VIA FLAG?

testAlarmIRQ:
	// SET IRQ VECTOR
				sei
				lda #<ciaIRQ
				sta vecIRQ
				lda #>ciaIRQ
				sta vecIRQ+1

	// SETUP IRQ. Solo TOD activo
				lda #%10000100
				sta CIA2_ICR
				lda #%00011011			 
				sta CIA2_ICR
				lda CIA2_ICR			// clear irq
				
				jsr stopTODticker   // Control del TOD mediante la VIA
				jsr loadTOD  		// 01.00.00.0
	//			jsr loadALARM		// 01.00.10.0
	// Screen IRQ counter
				lda #$30
				sta $7008			// 0 en el contador de interrupciones

				lda CIA2_ICR	

				cli 
todtest:
				jsr printTOD
				jsr tickTod
				jmp todtest


//////////////////////////////////////
tickTod:
				ldx #1
tick1:		
				ldy #1
tick2:		
				lda VIA_PRTB
				ora #%00000010
				sta VIA_PRTB			// PB1 high, others, unchanged

				and #%11111101
				sta VIA_PRTB			// PB1 low, others, unchanged


				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				jsr krnShortDelay
				
				inc $7002
				lda $7002
				cmp #'6'
				bne endBummer
				lda #'0'
				sta $7002
 endBummer:
				dey
				bne tick2
				dex
				bne tick1

				rts

//////////////////////////////////////
stopTODticker:
				// PB0 en la via se debe poner HIGH (es tod enable)
				lda VIA_DDRB
				ora #%00000001    
				sta VIA_DDRB			// PB0 as output, (TODENABLE) others unchanged

				lda VIA_PRTB
				ora #%00000001
				sta VIA_PRTB			// PB0 high, others, unchanged

				lda VIA_DDRB
				ora #%00000010    
				sta VIA_DDRB			// PB1 as output, (TOD) others unchanged

				lda #'0'
				sta $7002

				jsr krnShortDelay				// arduino ha soltado tod
				rts

//////////////////////////////////////
loadTOD:
				lda CIA2_CRGB
				and #$7F
				sta CIA2_CRGB 					// ALARM=0
				lda #$04
				sta CIA2_TODH
				lda #$24
				sta CIA2_TODM
				lda #$02
				sta CIA2_TODS
				lda #$00
				sta CIA2_TODT
				rts

//////////////////////////////////////
loadALARM:
				lda CIA2_CRGB
				ora #$80
				sta CIA2_CRGB 					// ALARM=1
				lda #$04
				sta CIA2_TODH
				lda #$24
				sta CIA2_TODM
				lda #$10
				sta CIA2_TODS
				lda #$02
				sta CIA2_TODT
				lda CIA2_CRGB
				and #$7F
				sta CIA2_CRGB 					// ALARM=0
				rts

loadTenths:
				pha
				lda #$00
				sta CIA2_TODT
				pla
				rts


//////////////////////////////////////
ciaIRQ:
				inc $7008
				lda CIA2_ICR		// CREAR CIA IRQ
				jsr printTOD2
				rti

//////////////////////////////////////
printTOD:
				lda CIA2_TODH
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex

				sta $7000+60

				lda CIA2_TODH
				and #$0F
				jsr nib2hex
				sta $7001+60

				lda #':'			// :
				sta $7002+60
				sta $7005+60
				sta $7008+60
				
				lda CIA2_TODM
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7003+60

				lda CIA2_TODM
				and #$0F
				jsr nib2hex
				sta $7004+60

				lda CIA2_TODS
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7006+60

				lda CIA2_TODS
				and #$0F
				jsr nib2hex
				sta $7007+60

				lda CIA2_TODT
				and #$0F
				jsr nib2hex
				sta $7009+60
				rts

//////////////////////////////////////
printTOD2:
				lda CIA2_TODH
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex

				sta $7000+40

				lda CIA2_TODH
				and #$0F
				jsr nib2hex
				sta $7001+40

				lda #':'			// :
				sta $7002+40
				sta $7005+40
				sta $7008+40
				
				lda CIA2_TODM
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7003+40

				lda CIA2_TODM
				and #$0F
				jsr nib2hex
				sta $7004+40

				lda CIA2_TODS
				and #$F0
				ror
				ror
				ror
				ror
				jsr nib2hex
				sta $7006+40

				lda CIA2_TODS
				and #$0F
				jsr nib2hex
				sta $7007+40

				lda CIA2_TODT
				jsr nib2hex
				sta $7009+40
				rts

flipTODIN:
				pha
				lda CIA2_CRGA
				eor #$80
				sta CIA2_CRGA
				pla
				rts

endendendend: