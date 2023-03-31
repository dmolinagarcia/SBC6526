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

// 2018 - 2023
//
// -----------------------------------------------------------------------------

#import "91.ciaTestsInit.asm"
testCIA2:
#import "92.ciaTestsDdrPort.asm"
#import "93.ciaTestsCregTimerA.asm"
#import "94.ciaTestsCregTimerB.asm"
#import "95.ciaTestsIcr.asm"
#import "99.ciaTestsEnd.asm"

jsr kbdWaitOK
stop:
lda MACHINE_TYPE
cmp #$01
beq stop
jmp reset

