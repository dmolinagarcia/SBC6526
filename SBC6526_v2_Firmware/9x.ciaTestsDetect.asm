jsr ciaReset

jsr printReg
jsr printSmallKO

jsr printReg
jsr printSmallKO

jsr printReg
jsr printSmallKO

jsr printReg
jsr printSmallKO

jsr printReg
jsr printSmallKO

jsr printReg
jsr printSmallKO

jsr printReg
jsr printSmallKO

jmp stophere


lda #$50
sta CIA2_DDRA
lda CIA2_DDRA
cmp #$50

bne ddra_ko
jsr printOK
stophere: jmp stophere
ddra_ko:
jsr printKO
jmp stophere

reg: .byte $00

printReg:
	pha 
	lda reg 
	jsr scrPrint8
	inc reg 
	pla 
	rts 

printSmallKO:
			phx
			phy
			ldx #<str_txtSmallKO
			ldy #>str_txtSmallKO
			jsr scrPrintStr
			ply
			plx
			rts

printSmallOK:
			phx
			phy
			pha
			ldx #<str_txtSmallOK
			ldy #>str_txtSmallOK
			jsr scrPrintStr
			pla
			ply
			plx
			rts

str_txtSmallOK:
			.text "  OK "
			.byte $00

str_txtSmallKO:
			.text "  KO "
			.byte $00	