// PERIPHERAL ADDRESSING
//////////////////////////////////////////////////////////////////////////////

// VIA 
.const VIA_PRTB			= $9000
.const VIA_PRTA			= $9001
.const VIA_DDRB			= $9002
.const VIA_DDRA  		= $9003
.const VIA_T1CL			= $9004
.const VIA_T1CH			= $9005
.const VIA_T1LL			= $9006
.const VIA_T1LH			= $9007		
.const VIA_ACR			= $900B
.const VIA_IER			= $900E

// CIA
.const CIA1_PRTA		= $8800
.const CIA1_PRTB		= $8801
.const CIA1_DDRA		= $8802
.const CIA1_DDRB		= $8803
.const CIA1_TALO	    = $8804
.const CIA1_TAHI        = $8805
.const CIA1_TBLO	    = $8806
.const CIA1_TBHI        = $8807
.const CIA1_TODT		= $8808
.const CIA1_TODS		= $8809
.const CIA1_TODM		= $880A
.const CIA1_TODH		= $880B
.const CIA1_SDR   	    = $880C
.const CIA1_ICR			= $880D
.const CIA1_CRGA		= $880E
.const CIA1_CRGB		= $880F

// CIAEXT
.const CIA2_PRTA		= $9800
.const CIA2_PRTB		= $9801
.const CIA2_DDRA		= $9802
.const CIA2_DDRB		= $9803
.const CIA2_TALO	    = $9804
.const CIA2_TAHI        = $9805
.const CIA2_TBLO	    = $9806
.const CIA2_TBHI        = $9807
.const CIA2_TODT		= $9808
.const CIA2_TODS		= $9809
.const CIA2_TODM		= $980A
.const CIA2_TODH		= $980B
.const CIA2_SDR  	    = $980C
.const CIA2_ICR			= $980D
.const CIA2_CRGA		= $980E
.const CIA2_CRGB		= $980F

// SCREEN 
//////////////////////////////////////////////////////////////////////////////

// Screen memory is 4 KB. $7000-$7FFF

// Top left corner of screen at startup
.const SCREEN_BASE      = $7000
// 10 11. Pointer to top left on Screen
.const SCREEN_POINTER   = $10
// 12 13, Similar a screen pointer, pero para el cursor
.const SCREEN_CURSOR_POINTER = $12
// 14   . Cursor, next position to print (SCREEN_CURSOR_POINTER),SCREEN_CURSOR
.const SCREEN_CURSOR	= $14
// 15 16 . temporal para calculos de screen windows
.const SCREEN_WINDOW_TEMP = $15

// Kernal variables
//////////////////////////////////////////////////////////////////////////////

// 20 21 string pointer
.const STRING_POINTER	= $20