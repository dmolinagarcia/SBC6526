				lda #%01000000
				sta VIA_IER 				// DISABLEVIA Timer 1 interrupts
											// Prevent unexpected delays

                jsr ciaReset
                jsr krnLongDelay
                jsr ciaReset
                jsr krnLongDelay

                sei 
                lda #<nmi
				sta vecIRQ
				lda #>nmi
				sta vecIRQ+1
				cli 						// Enable IRQ and point to nmi

                lda #$00
                sta $AA 					// Flag to check if NMI has occured
                							// We will INC $AA within NMI

		    test:
				jsr runciatest
				jsr printResult
				jsr setupNext
				jsr runciatest
				jsr printResult

			end: 
				lda #%11000000
				sta VIA_IER 				// REENABLE Timer 1 interrupts
											// Prevent unexpected delays
				jmp stophere

runciatest:
				ldx #$08
				ldy #$82
				sty CIA2_ICR				// Enable CIA2 Interrupts
				ldy #$ff
				sty CIA1_TALO
				ldy #$00
				sty CIA1_TAHI				// Set CIA1 timer to 00FF for NMI test
				ldy #$d5
				sty CIA1_CRGA				// Start and Force Load
				nop
				nop
				nop
				nop
				nop 
	loada:
				ldy #$13
				sty CIA2_TALO
				ldy #$00
				sty CIA2_TAHI 				// CIA2 TA to 0013 for test
	forceloada:
				ldy #$d5
				sty CIA2_CRGA 				// ForceLoad will be toggled
				
	loadb:
				ldy #$07
				sty CIA2_TBLO
				ldy #$00
				sty CIA2_TBHI				// CIA2 TB to 0007
	forceloadb:
				ldy #$d9
				sty CIA2_CRGB				// TB start, FL (toggled) and One Shot
				
	// sample TBL into $2fff,x (pointer incremented by 8 for each test)
	readtb:
				lda CIA2_TBLO
	storesta:
				sta $2fff,x
				dex
				bne readtb
				
	// wait until NMI has certainly occured & done its thing
	 waitfornmi:
				lda $AA
				cmp #$01
				bne waitfornmi
				lda #$00
				sta $AA 					// Clear Flag
				
	/*		We will only sample in this loop 
				; compare the results of TBL sampling
				  ldx #$08
				storelda:
				  lda $2fff,x
				storecmp:
				  cmp $3fff,x
				  bne cmptestfailedjump
				  dex
				  bne storelda
    */
				  rts
				
				cmptestfailedjump:
				  jmp stophere

printResult:
				ldx #$08
			loop1:							// print Test Results
				lda $2fff,x 
				jsr scrPrint8
				dex 
				bne loop1 

				lda #$20					
				jsr scrPrintChar 			// Blank space

				lda $4000
				jsr scrPrint8 				// Print NMI test result

				lda #$20					
				jsr scrPrintChar 			// Blank space
				rts 

setupNext:
	storeb:
  				// update the check pointers of CIA values
  				clc
  				lda storesta+1
  				adc #$08
  				sta storesta+1
  				sta loop1+1
  				bcc nexta
  				inc storesta+2
  				inc loop1+2
			nexta:
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

  				//try with force load & without
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

				// end test: turn border green, restore IRQ/NMI
				jmp end
			setupend:
				rts

nmi:
				pha
				lda CIA1_TALO
			nmistore:
				sta $4000
				inc nmistore+1
				bcc acknmi
				inc nmistore+2
			acknmi:
				bit CIA2_ICR
				pla
				inc $AA
				rti


/*

  jsr setupnexttest
  jmp $ea81     ; return to the auxiliary raster interrupt







; debug printing section
screenptr: !by 0

printbyte:
  stx storex+1
  ldx screenptr
  sta $400,x
  inc screenptr
storex:
  ldx #$0
  rts

printhex:
  pha
  lsr
  lsr
  lsr
  lsr
  jsr printhexbyte
  pla
  and #$f
printhexbyte:
  cmp #$a
  bcc handleletter
  sbc #9
  jmp printbyte
handleletter:
  adc #$30
  jmp printbyte

nmitestfailed:
  jsr printhex
  lda #' '
  jsr printbyte
  lda #14
  jsr printbyte
  lda #13
  jsr printbyte
  lda #9
  jsr printbyte
  lda #' '
  jsr printbyte
  lda nmistore+2
  jsr printhex
  lda nmistore+1
  jsr printhex
  jmp freeze

freeze:
  inc $d020
  ; signal failure
  lda #$ff
  sta $d7ff
  jmp freeze

cmptestfailed:
  txa
  jsr printhex

  lda #' '
  jsr printbyte
  lda #3
  jsr printbyte
  lda #13
  jsr printbyte
  lda #16
  jsr printbyte
  lda #' '
  jsr printbyte

  lda storesta+2
  jsr printhex
  lda storesta+1
  jsr printhex

  jmp freeze

*/

jmp stophere



