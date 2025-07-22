BasicUpstart2(Start)

.label O = $2000
.label S = O+8
.label K = S+8

.label BackgroundPointer = $02
.label BackgroundLine = $BF
.label Temp = $70
.label ScreenPointer = $FB
.label CurrentRow = $FD
.label ColorPointer = $FE

Colors: 
		.byte $09,$0B
BackgroundChars: 
		.byte $5F,$DF
BackgroundColors: 
		.byte $0f,$0f,$0f,$0f,$0a,$0a,$03,$03,$0e,$0e,$06,$06,$0d,$0d,$06,$06
        .byte $0e,$0e,$03,$03,$0a,$0a,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
        .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
        .byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
Start:
    jsr $E544
    lda #LIGHT_GREY
    sta $D020
    sta $D021

    jsr Background.Draw



    lda $01
    and #%11111011    
    sta $01
    
    ldx #8
Copy:
    lda $D000 + $0F * 8,x
    sta O,x
    lda $D000 + $13 * 8,x
    sta S,x
    lda $D000 + $0B * 8,x
    sta K,x
    dex
    bmi !+
    jmp Copy

!:
    lda $01
    ora #%00000100 
    sta $01

    jsr OSK.Draw
    
Done:

    :waitForRasterLine($FE)
    :waitForRasterLine($FF)
    jsr Background.Color
    

    jmp Done

.macro NewLine(addr) {
    lda addr
    clc
    adc #40
    sta addr
    bcc !+
    inc addr + 1
!:
}
.macro waitForRasterLine( line ) {
		lda #line
		cmp $d012
		bne *-3	
}
.macro DrawLine(offset, color) {
    ldy #0 + offset
Loop:
    asl CurrentRow
    bcc !+
    lda #$A0
    sta (ScreenPointer),y
    lda #color   
    sta (ColorPointer),y
!:
    iny
    cpy #8 + offset
    bne Loop
}

.macro ColorLine(offset, color) {
    ldy #0 + offset
Loop:
    asl CurrentRow
    bcc !+
    lda #$A0
    sta (ScreenPointer),y
    lda #color   
    sta (ColorPointer),y
!:
    iny
    cpy #8 + offset
    bne Loop
}


OSK: {
    Draw: {
        lda #$20
        sta ScreenPointer
        lda #$05
        sta ScreenPointer + 1
        
        lda #$20
        sta ColorPointer
        lda #$D9
        sta ColorPointer + 1

        ldx #0
    RowLoop:
        lda O,x
        sta CurrentRow
        DrawLine(41, 11)
        lda O,x
        sta CurrentRow
        DrawLine(0, 5)


        lda S,x
        sta CurrentRow
        DrawLine(49, 11)
        lda S,x
        sta CurrentRow
        DrawLine(8, 7)


        lda K,x
        sta CurrentRow
        DrawLine(57, 11)
        lda K,x
        sta CurrentRow
        DrawLine(16, 2)
        
        NewLine(ScreenPointer)
        NewLine(ColorPointer)
        
        inx
        cpx #8
        beq !+
        jmp RowLoop
    !:
            
        rts
    }
}

Background: {
    ColorTimer: .byte $00
    Iteration: .byte $00
    Draw: {
            lda #$01
            sta BackgroundPointer
            lda #$04
            sta BackgroundPointer + 1
            lda #25
            sta BackgroundLine
        BG_Loop:
            ldy #40
        Loop:
            tya
            clc
            adc BackgroundLine
            and #$01
            tax
            lda BackgroundChars,x
            sta (BackgroundPointer),y
            dey
            bpl Loop

            NewLine(BackgroundPointer)
            dec BackgroundLine
            bne BG_Loop
            rts
    }
    Color: {
        dec ColorTimer
			beq !+
			rts
		!:
            lda #$01
            sta ColorTimer

            lda #$00
            sta BackgroundPointer
            lda #$d8
            sta BackgroundPointer + 1
            lda #0
            sta BackgroundLine
        BG_Loop:
            ldy #0


        Loop:
            lda (BackgroundPointer),y
            and #$0F
            cmp #$0B
            bne !+
            iny
            jmp Loop
        !:
            cmp #$05
            bne !+
            iny
            jmp Loop
        !:
            cmp #$07
            bne !+
            iny
            jmp Loop
        !:
            cmp #$02
            bne !+
            iny
            jmp Loop
        !:
            tya
            clc
            adc #1
            adc Iteration
            sec
            sbc BackgroundLine
            and #%00111111
            tax
            lda BackgroundColors,x

            sta (BackgroundPointer),y

            iny
            cpy #40
            bne Loop
            NewLine(BackgroundPointer)
            inc BackgroundLine
            lda BackgroundLine
            cmp #25
            bne BG_Loop
            inc Iteration
            inc Iteration
            rts
    }
}