// -----------------------------------------------------------------------------
// Draft Area
// -----------------------------------------------------------------------------

// Skip execution of all this sh**

			jmp endendendend



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
				lda CIA2_ICR		// CLEAR CIA IRQ
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








/////////////////////


		





//// 

jsr ciaReset

lda #%01000000
sta CIA2_CRGA				// CIA2 SPMODE = OUTPUT											

lda #$FF
sta CIA2_TALO 				// CIA2 TA = 00FF
lda #$FF
sta CIA2_TAHI

lda #$21
sta CIA1_CRGB				// CIA2 counts CNT

lda #%01000001				
sta CIA2_CRGA 				// START timera and SPOUT
ldx #$AA
stx CIA2_SDR 				// Write to PORT OUT		
ldx #$AA
stx CIA2_SDR 				// Write to PORT OUT		


jmp jmp_displayCIA1
			


////

jsr printTest
jsr ciaReset

lda #%00000000
sta CIA2_CRGA				// CIA2 SPMODE = INPUT											

lda #%01000000
sta CIA1_CRGA				// CIA1 SPMODE = OUTPUT		

lda #$FF
sta CIA1_TALO 				// CIA1 TA = 00FF
lda #$00
sta CIA1_TAHI

lda #%01000001				
sta CIA1_CRGA 				// CIA1  START timera and SPOUT

ldx #$AA
stx CIA1_SDR 				// Write to CIA 1 PORT OUT	

jsr krnLongDelay

				







jsr ciaReset

sei

lda #$88
sta CIA2_ICR				// Enable SDR interrupts

lda #%01000000
sta CIA2_CRGA				// CIA2 SPMODE = OUTPUT											
lda #$FF
sta CIA2_TALO 				// CIA2 TA = 00FF
lda #$00
sta CIA2_TAHI
lda #%01000001				
sta CIA2_CRGA 				// START timera and SPOUT


lda #$21
sta CIA1_CRGB

ldx #$44
stx CIA2_SDR 				// Write to PORT OUT		

lda #$20
delay:
jsr krnLongDelay
dex 
bne delay 

lda CIA2_ICR				// LOAD ICR
jsr scrPrint8				// 89
lda #$20
jsr scrPrintChar
lda CIA2_SDR
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_ICR
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_SDR
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_TBLO
jsr scrPrint8


// // 2 to 1 OKKKKK

testSDR2to1:

ldx #$00
stx $55		// byte to send

jsr ciaReset
sei 
lda #$88
sta CIA2_ICR				// Enable SDR interrupts

lda #%01000000
sta CIA2_CRGA				// CIA2 SPMODE = OUTPUT											
lda #$20
sta CIA2_TALO 				// CIA2 TA = 00FF
lda #$00
sta CIA2_TAHI
lda #%01000001				
sta CIA2_CRGA 				// START timera and SPOUT


lda #$21
sta CIA1_CRGB

gooooo1:


ldx $55
inc $55
bne continue1
jmp stophere

continue1:
stx CIA2_SDR 				// Write to PORT OUT		
jsr krnLongDelay
wai 

lda CIA2_ICR				// LOAD ICR
jsr scrPrint8				// 89   IRQ ICR and SDR
lda #$20
jsr scrPrintChar
lda CIA2_SDR				// AA same as line 37
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_ICR				// 08  SDR
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_SDR				// Sames as 50, AA
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_TBLO				// F7 for single bit
jsr scrPrint8
lda #$20
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrSetWindow

lda CIA1_SDR
cmp CIA2_SDR
beq gooooo1	
jmp stophere




//// 1 to 2
testSDR1to2:

ldx #$00
stx $55		// byte to send

jsr ciaReset
sei 

lda #$88
sta CIA1_ICR				// Enable SDR interrupts

lda #%01000000
sta CIA1_CRGA				// CIA2 SPMODE = OUTPUT											
lda #$10
sta CIA1_TALO 				// CIA2 TA = 00FF
lda #$00
sta CIA1_TAHI
lda #%01000001				
sta CIA1_CRGA 				// START timera and SPOUT


lda #$21
sta CIA2_CRGB

gooooo:


ldx $55

stx CIA1_SDR 				// Write to PORT OUT		

wai 

lda CIA1_ICR				// LOAD ICR
// jsr scrPrint8				// 89   IRQ ICR and SDR
// lda #$20
// jsr scrPrintChar
lda CIA1_SDR				// AA same as line 37
jsr scrPrint8bin
lda #$20
jsr scrPrintChar
lda CIA2_ICR				// 08  SDR
// jsr scrPrint8
// lda #$20
// jsr scrPrintChar
lda CIA2_SDR				// Sames as 50, AA
jsr scrPrint8bin
lda #$20
jsr scrPrintChar
// lda CIA2_TBLO				// F7 for single bit
// jsr scrPrint8
lda CIA2_SDR
jsr scrPrint8
jsr scrSetWindow

inc $55

lda CIA1_SDR
cmp CIA2_SDR
beq gooooo

stophere: jmp stophere		





sendONE2to1:

jsr ciaReset
sei 

lda #%01000000
sta CIA2_CRGA				// CIA2 SPMODE = OUTPUT											
lda #$FF
sta CIA2_TALO 				// CIA2 TA = 00FF
lda #$00
sta CIA2_TAHI
lda #%01000001				
sta CIA2_CRGA 				// START timera and SPOUT

lda #$21
sta CIA1_CRGB

ldx #$AA
stx CIA2_SDR 				// Write to PORT OUT		
wai 

lda CIA2_ICR				// LOAD ICR
jsr scrPrint8				// 89   IRQ ICR and SDR
lda #$20
jsr scrPrintChar
lda CIA2_SDR				// AA same as line 37
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_ICR				// 08  SDR
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_SDR				// Sames as 50, AA
jsr scrPrint8
lda #$20
jsr scrPrintChar
lda CIA1_TBLO				// F7 for single bit
jsr scrPrint8
lda #$20
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrPrintChar
jsr scrSetWindow



jmp stophere




//////// small test for 01cmpold

/*


jsr ciaReset

lda #$03
sta loadb+1

sei 

// CIA 1 fires IRQ

lda #<nmi
sta vecIRQ
lda #>nmi
sta vecIRQ+1

cli

test:
ldx #$00
stx $AA

ldy #$82
sty CIA2_ICR
ldy #$ff
sta CIA1_TALO
ldy #$00
sty CIA1_TAHI
ldy #$d5
sty CIA1_CRGA

loada:
	ldy #$10
	sty CIA2_TALO
	ldy #$00
	sty CIA2_TAHI
forceloada:
	ldy #$d5
	sty CIA2_CRGA

loadb:
	ldy #$01
	sty CIA2_TBLO
	ldy #$00
	sty CIA2_TBHI
forceloadb:
	ldy #$d9
	sty CIA2_CRGB

// Wait for irq
waitfornmi:
	ldy $AA
	cpy #$01
	bne waitfornmi

jmp test

nmi:
	pha 
	lda CIA1_TALO
	jsr scrPrint8
	lda CIA2_ICR
 	pla
 	ldx loadb+1
 	dex 
 	stx loadb+1
 	cpx #$FF
 	beq endlalala
 	inc $AA
	rti



endlalala: jmp stophere


////// */



//// Test for 01cmp

	// Test individual para 01cmp bug
  jsr ciaReset
  
					lda #%01000000
					sta VIA_IER 				// DISABLEVIA Timer 1 interrupts
												// Prevent unexpected delays

runciatest:
loada:
  ldy #$13
  sty CIA2_TALO
  ldy #$00
  sty CIA2_TAHI
forceloada:
  ldy #%00010011				// 00010111 : FL PULSE PB6ON START CONT PHI2
  sty CIA2_CRGA

loadb:
  ldy #$07
  sty CIA2_TBLO
  ldy #$00
  sty CIA2_TBHI
forceloadb:
  ldy #%01011011				// 01011011 : FL PULSE PB7 ON START O.S TAunderflows					
  sty CIA2_CRGB

waitforbunder:					// Wait until timerb has stopped
  lda CIA2_CRGB
  and #$01
  bne waitforbunder

  								// Setup next test
								// try with force load & without
  lda forceloada+1
  eor #$10
  sta forceloada+1
  and #$10
  beq setupend
  								// try all choices from 0x13 to 0x4
  ldx loada+1
  dex
  stx loada+1
  cpx #$03
  bne setupend
  ldx #$13
  stx loada+1
  								// try with force load & without
  lda forceloadb+1
  eor #$10
  sta forceloadb+1
  and #$10
  beq setupend
  								// decrement load until complete
  ldx loadb+1
  dex
  stx loadb+1
  cpx #$ff
  bne setupend
  								// end test

  lda #$00
  sta CIA2_CRGA
  sta CIA2_CRGB
  jsr printOK
			lda #%11000000
			sta VIA_IER					// Reenable VIA IRQ  
  jmp programEnd

setupend:
  jmp runciatest



