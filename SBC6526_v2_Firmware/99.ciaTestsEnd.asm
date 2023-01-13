ciaTestsEnd:
// prints total and returns to "PROMPT"

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

			lda #%11000000
			sta VIA_IER					// Reenable VIA IRQ


// Skip functions
			jmp endCiaTests

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
			jsr scrRefresh					// Redraw Screen, as IRQ are off

printTest_01: 

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
			rts

printNA:
			phx
			phy
			pha
			ldx #<str_txtNA
			ldy #>str_txtNA
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

str_txtNA:
			.text "   (    ) "
			.byte $00

str_total:  .text "   OK "
			.byte $00

str_slash:  .text " / "
			.byte $00



endCiaTests: