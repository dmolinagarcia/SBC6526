// -----------------------------------------------------------------------------
// 
// LOGISIM 6526 SBC Firmware
//
//
// 0300 - 7FFF Free RAM
// 8000 - BFFF 8 Blocks IO
// 8800 - CIA1
// 9800 - CIA2
// Write to $A000 outputs to TERM
// Write to $A001 Resets CIAs
// C000 - FEFF Free RAM
// FF00 - FFFF Minimum Kernel
//
// Author : Daniel Molina 
// https://github.com/dmolinagarcia
//
// 2018 - 2023
//
// -----------------------------------------------------------------------------

.cpu _65c02
.file [name="logisim.bin", type="bin", segments="ROM"]

			#import "10.addresing.asm"

.segment ROM [min=$0000, max=$FFFF, fill]
 
*=$0300 "CODE" 
reset:
			lda #$01
			sta MACHINE_TYPE				// LOGISIM
			sta $B000 						// CIA RESET

start:
  lda #$00
  sta $fa

nexttest:
  lda #$00
  sta $880e
  sta $880f
  sta $980e
  sta $980f
  lda $880d
  lda $980d
  ldx $fa
  lda icr,x
  sta useirc+1
  lda cr,x
  sta usecr+1
  lda tlow,x
  sta usetlow+1
  lda cianr,x
  sta usecia11+2
  sta usecia12+2
  sta usecia13+2
  sta usecia14+2
  sta usecr+2
  sta usetlow+2
  eor #$10
  sta usecia21+2
  sta usecia22+2
  sta usecia23+2
  sta usecia24+2
  txa
  asl
  tax
  lda out+1,x
  tay
  lda out,x
  // sta output0+1
  // sty output0+2
  clc
  adc #40
  // sta output1+1
  bcc nr1
  iny
nr1:
  // sty output1+2
  clc
  adc #40
  // sta output2+1
  bcc nr2
  iny
nr2:
  // sty output2+2
  clc
  adc #40
  // sta output3a+1
  // sta output3b+1
  bcc nr3
  iny
nr3:
  // sty output3a+2
  // sty output3b+2
  clc
  adc #40
  // sta output4a+1
  // sta output4b+1
  bcc nr4
  iny
nr4:
  // sty output4a+2
  // sty output4b+2
  sei
  lda #$35
  sta $01
  lda #<irqhandler
  sta $fffe
  lda #>irqhandler
  sta $ffff
  lda #<irqhandler
  sta $fffa
  lda #>irqhandler
  sta $fffb
  lda #$7f
  sta $880d
  sta $980d
useirc:
  lda #$80
usecia11:
  sta $880d
  inc $d019
  lda $880d
  lda $980d
  cli
  jsr test

  inc $fa
  lda $fa
  cmp #$01
  bne nrst

  lda #$00
  sta $880e
  sta $880f
  sta $980e
  sta $980f
  lda $880d
  lda $980d
  lda #$1b
  sta $d011
  jsr checkdata
  jmp end
nrst:
  jmp nexttest
end:
  jmp end

*=$0800 "test"
test:
  ldx #$10
  lda $880d
  lda $980d
  lda #$00
  sta $8804
  sta $8806
  sta $9804
  sta $9806
  lda #$01
  sta $8805
  sta $8807
  sta $9805
  sta $9807
usecia21:
  inc $9804
  lda #$11
usecr:
  sta $880f
usecia22:
  sta $980e
lp0:
  lda #$20
output3a:
  sta $5478,x 			// Lineas 3 y 4, las mando al limbo
output4a:
  sta $54a0,x 			// Lineas 3 y 4, las mando al limbo
  ldy #$1a
lp1:
  dey
  bne lp1
  lda #$80
  sec
usecia23:
  sbc $9804
  jsr delay
usetlow:
  lda $8806
  sec
  sbc #$05
output0:
  sta $A000,x
usecia12:
  lda $880d
output1:
  sta $A028,x
usecia13:
  lda $880d
output2:
  sta $A000,x
  dex
  bne lp0
  rts

*=$0f00
irqhandler:
  pha
usecia14:
  lda $880d
output3b:
  sta $0478,x
usecia24:
  lda $9804
  clc
  adc #$10
output4b:
  sta $04a0,x
  pla
intexit:
  rti  

clrscr:
  ldx #$00
  stx $d020
  stx $d021
clrlp:
  lda #$01
  sta $d800,x
  sta $d900,x
  sta $da00,x
  sta $db00,x
  inx
  bne clrlp
  rts

*=$1000
delay:              
    lsr             
    bcc waste1cycle 
waste1cycle:
    sta smod+1      
    clc             
smod:
    bcc smod
  .byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
  .byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
  .byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
  .byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
    rts             

icr:
  .byte $80,$81,$80,$82,$80,$81,$80,$82
cr:
  .byte $0e,$0e,$0f,$0f,$0e,$0e,$0f,$0f
tlow:
  .byte $04,$04,$06,$06,$04,$04,$06,$06
cianr:
  .byte $88,$88,$88,$88,$98,$98,$98,$98  
out:
  .word $0450,$0518,$0464,$052c,$0608,$06d0,$061c,$06e4


checkdata:
rts




//		#import "90.ciaTests.asm"

codeEnd:	jmp codeEnd

*=$FF00 "KERNEL"
ciaReset:
			sta $B000
			rts

scrPrintChar:
			sta $A000
			rts

scrPrintStr:
// Prints string stored at X_Y
			pha
			stx STRING_POINTER
			sty STRING_POINTER+1

scrPrintStr1:
			ldy #$00
			lda (STRING_POINTER),y 
			cmp #$00
			beq scrPrintStrEnd
			sta $A000
			inc STRING_POINTER
			bne scrPrintStr1
			inc STRING_POINTER+1
			jmp scrPrintStr1

scrPrintStrEnd:
			pla
			rts

// TODO. Ported form v1 'as is'
// Dummy functions for logisim
// kbd and lcd functions not loaded
// Where are these used???
tickTodFromVia:
			sta $8000
kbdWaitOK:
scrScrollUp:
scrScrollDown:
scrInitialize:
scrClear:
krnDoNothing:
scrRefresh:
enableTodFromVia:
			rts


krnShortDelay:		
			rts		

krnLongDelay:		
			phx
     		ldx #$FF
	krnLongDelayLoop:  	
			jsr krnLongDelayEnd
     		dex
     		bne krnLongDelayLoop
     		plx
	krnLongDelayEnd:	
			rts	




kbdUp:
	jmp (keyUp)
kbdDown:
	jmp (keyDown)
kbdOk:
    jmp (keyOk)
kbdCancel:
	jmp (keyCancel)

keyUp: 		.word scrScrollUp 		// keyUp
keyDown:	.word scrScrollDown     // keydown
keyOk:		.word krnDoNothing      // keyOk
keyCancel:	.word krnDoNothing      // keyCancel


nib2hex:
// Converts lower nibble in A into hexadecimal ascci
// We don't save A in stack, as it's our return value
				cmp #$0a
         		bcc nib2hex0_9           
		        ora #$30
		        clc
		        adc #$07
		        rts
nib2hex0_9:		ora #$30         
				rts

irqHand:		lda CIA2_ICR	
				rti				


//////////////////////////////////////////////////////////////////////////////
//////   VECTORS                                                        //////
//////////////////////////////////////////////////////////////////////////////

*=$FFFA "VECTORS"
vecNMI:		.word irqHand 			// NMI
vecRES:		.word reset  			// Reset
vecIRQ:		.word irqHand  			// IRQ/BRK

// VECTORS ///////////////////////////////////////////////////////////////////



// Test Results

// 41 TB counts TA >> kbdOk
// 48 KO 
// 49 KO 
// 50 KO 
// 51 KO 
// 52 NA 
// 53 STUCK 

// 41 Is normal counting
// 48 - 53 are interrupt firing tests
