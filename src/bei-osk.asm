BasicUpstart2(Start)

.label O = $2000
.label S = O+8
.label K = S+8

.label BackgroundPointer = $02
.label BackgroundLine = $BF
.label Temp = $70
.label CurrentChar = $71
.label CurrentCharColor = $72
.label CurrentCharColorO = $73
.label CurrentCharColorS = $74
.label CurrentCharColorK = $75
.label ScreenPointer = $FB
.label CurrentRow = $FD
.label ColorPointer = $FE

// 63
CharCycle:  .byte $63, $77, $78, $E2, $F9, $EF, $A0 //$E4
CharCycle2: .byte $E3, $F7, $F8, $62, $79, $6F, $64

CharColors: .byte $05, $07, $02//, $04
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
    jsr OSK.Reset
Done:

    :WaitForRasterLine($FE)
    :WaitForRasterLine($FF)
    jsr Background.Color
    jsr OSK.Update

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

.macro IncCharColor(addr) {
    lda addr
    clc
    adc #1
    cmp #3
    bne !+
    lda #0
!:
    sta addr
}

.macro WaitForRasterLine( line ) {
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
.macro DrawLineAddr(offset, addr) {
    ldy #0 + offset
    txa
    pha
Loop:
    asl CurrentRow
    bcc !+
    lda #$A0
    sta (ScreenPointer),y
    ldx addr
    lda CharColors, x   
    sta (ColorPointer),y
!:
    iny
    cpy #8 + offset
    bne Loop
    pla
    tax
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


.macro UpdateLine(offset,addr) {
    ldy #0 + offset
    txa
    pha
Loop:
    asl CurrentRow
    bcc !+
    lda CurrentChar
    sta (ScreenPointer),y
    
    ldx addr
    lda CharColors, x   
    sta (ColorPointer),y
!:
    iny
    cpy #8 + offset
    bne Loop
    pla
    tax
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

        lda #0
        sta CurrentCharColorO
        lda #1
        sta CurrentCharColorS
        lda #2
        sta CurrentCharColorK

        ldx #0
    RowLoop:
        lda O,x
        sta CurrentRow
        DrawLine(41, 11)
        lda O,x
        sta CurrentRow
        DrawLineAddr(0, CurrentCharColorO)


        lda S,x
        sta CurrentRow
        DrawLine(49, 11)
        lda S,x
        sta CurrentRow
        DrawLineAddr(8, CurrentCharColorS)


        lda K,x
        sta CurrentRow
        DrawLine(57, 11)
        lda K,x
        sta CurrentRow
        DrawLineAddr(16, CurrentCharColorK)
        
        NewLine(ScreenPointer)
        NewLine(ColorPointer)
        
        inx
        cpx #8
        beq !+
        jmp RowLoop
    !:
        rts
    }

    Row: .byte $07
    Char: .byte $00
    Char2: .byte $00
    RenderRow: .byte $00

    Reset: {
        lda #$20
        sta ScreenPointer
        lda #$05
        sta ScreenPointer + 1
        lda #0
        sta Char

        
        
        lda #$20
        sta ColorPointer
        lda #$D9
        sta ColorPointer + 1
        
        IncCharColor(CurrentCharColorO)  
        IncCharColor(CurrentCharColorS)  
        IncCharColor(CurrentCharColorK) 
        rts
    }

    Update: {
        ldx RenderRow
        ldy Char
        lda CharCycle, y
        sta CurrentChar
        lda O, x
        sta CurrentRow

        UpdateLine(0, CurrentCharColorO)
        lda S, x
        sta CurrentRow
        UpdateLine(8, CurrentCharColorS)
        lda K,x
        sta CurrentRow
        UpdateLine(16, CurrentCharColorK)


        ldx RenderRow
        ldy Char
        lda CharCycle2, y
        sta CurrentChar

        lda O + 1, x
        sta CurrentRow
        UpdateLine(40, CurrentCharColorK)
        lda S + 1,x
        sta CurrentRow
        UpdateLine(48, CurrentCharColorO)
        lda K + 1,x
        sta CurrentRow
        UpdateLine(56, CurrentCharColorS)

        inc Char
        lda Char
        cmp #$07
        beq !+
        jmp DoneUpdate
    !:
        lda #0
        sta Char
        
        inc RenderRow
        lda RenderRow
        cmp #6
        bne !+

        lda #0
        sta RenderRow
        lda #$A0
        sta CurrentChar

        lda O + 1, x
        sta CurrentRow
        UpdateLine(40, CurrentCharColorO)
        lda S + 1,x
        sta CurrentRow
        UpdateLine(48, CurrentCharColorS)
        lda K + 1,x
        sta CurrentRow
        UpdateLine(56, CurrentCharColorK)
        jsr Reset
        jmp DoneUpdate
    !:
        
        NewLine(ScreenPointer)
        NewLine(ColorPointer)
    DoneUpdate:
        rts
    }
}

Background: {
    ColorTimer: .byte $01
    Iteration: .byte $00
    SkipTable: .byte 0,0,1,0,0,1,0,1,0,0,0,1,0,0,0,0
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
            tax
            lda SkipTable, x
            beq !+
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