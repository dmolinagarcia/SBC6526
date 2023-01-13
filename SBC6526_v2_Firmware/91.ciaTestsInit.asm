// -----------------------------------------------------------------------------
// Register Detection                                            
// -----------------------------------------------------------------------------
		// Skip variable area
						jmp registerDetection

						.const TOD_PRESENT		= %00100000
						.const SDR_PRESENT		= %00010000
						.const ICR_PRESENT		= %00001000
						.const TMB_PRESENT  	= %00000100
						.const TMA_PRESENT 		= %00000010
						.const DDR_PRESENT		= %00000001

reg_present:
						.byte  $00
icr_mask:
						.byte  %11110011		
						// TOD and SDR disables initialy. If present, enable them

registerDetection:		lda reg_present
						jsr ciaReset
						ldx CIA2_DDRA
						bne registerDetection1					// IF equals 0, not jump, as DDR is PRESENT
						ora #DDR_PRESENT
registerDetection1:		ldx CIA2_CRGA
						bne registerDetection2					// IF equals 0, not jump, as TMA is PRESENT
						ora #TMA_PRESENT						
registerDetection2:		ldx CIA2_CRGB
						bne registerDetection3					// IF equals 0, not jump, as TMB is PRESENT
						ora #TMB_PRESENT						
registerDetection3:		ldx CIA2_ICR
						bne registerDetection4					// IF equals 0, not jump, as ICR is PRESENT
						ora #ICR_PRESENT						
registerDetection4:		ldx CIA2_SDR
						bne registerDetection5					// IF equals 0, not jump, as SDR is PRESENT
						ora #SDR_PRESENT						
						pha 
						lda icr_mask
						ora #%00001000
						sta icr_mask
						pla
registerDetection5:		ldx CIA2_TODM
						bne registerDetection6					// IF equals 0, not jump, as TOD is PRESENT
						ora #TOD_PRESENT						
						pha 
						lda icr_mask
						ora #%00000100
						sta icr_mask
						pla						
registerDetection6:     sta reg_present

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

					lda #%01000000
					sta VIA_IER 				// DISABLEVIA Timer 1 interrupts
												// Prevent unexpected delays

					jmp testCIA2 				// Jump to option

// -----------------------------------------------------------------------------
// CIA DISPLAY
// -----------------------------------------------------------------------------
displayCIA:			
					ldx #$00
					ldy #$00
					
					lda #%11000000
					sta VIA_IER					// Reenable VIA IRQ

displayCIAnext:					
					lda ($FE),y 				// L
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