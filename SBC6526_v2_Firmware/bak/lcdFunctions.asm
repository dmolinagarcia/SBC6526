// LCD Functions for SBCv1
#importonce

/***************************
 SPEC

 lcdReset. Performs a reset of the LCD screen. 
 lcdInstr. Sends instructio in A HI nibble to lcd. Always 4 bit
 lcdChar.  Sends char in A to lcd. sends in two 4-bit instructions.

****************************/


lcdReset:   
// Reset, clear, and set 4 bit mode
            pha


            lda #$30
            jsr lcdInstr        // Enable 8-bit mode
            lda #$30
            jsr lcdInstr        // Enable 8-bit mode
            jsr krnShortDelay
            lda #$30
            jsr lcdInstr        // Enable 4-bit mode
            jsr krnShortDelay
            
            lda #$20
            jsr lcdInstr        // Enable 4-bit mode


            lda #$20            // 4-bit 2 lineas 5x8 fond
            jsr lcdInstr
            lda #$80
            jsr lcdInstr

            lda #$00            // Display OFF
            jsr lcdInstr
            lda #$80
            jsr lcdInstr

            lda #$00            // Clear Display
            jsr lcdInstr
            lda #$10
            jsr lcdInstr

            lda #$00            // Mode Set. Incrementd and shift
            jsr lcdInstr
            lda #$60
            jsr lcdInstr

            lda #$00            // Display on and cursor OFF
            jsr lcdInstr
            lda #$F0
            jsr lcdInstr

            pla
            rts



