BasicUpstart2(Start)

MaxNumOfCols: .byte 40
MaxNumOfRows: .byte 24
StartIndex: .byte $FF
CurrentChar: .byte $51
CurrentColor: .byte $0
Iterations: .byte 6
.label ZeroPage = $FB
.label ZeroPageColor = $FD

Start:
    jsr $E544
    ldy #0
    ldx #0
    lda #$00
    sta ZeroPage
    sta ZeroPageColor
    lda #$04
    sta ZeroPage + 1

    lda #$D8
    sta ZeroPageColor + 1

Loop:
TopLoop:
    lda CurrentChar
    sta (ZeroPage),y
    lda CurrentColor
    sta (ZeroPageColor),y
    inc CurrentColor
    iny
    cpy MaxNumOfCols
    bne TopLoop

    dey

RightLoop:
    NextLine(ZeroPage, CurrentChar)
    NextLine(ZeroPageColor, CurrentColor)

    inc CurrentColor

    inx
    cpx MaxNumOfRows
    bne RightLoop

    // Up will have to lines less
    dec MaxNumOfRows
    dec MaxNumOfRows

BottomLoop:

    lda CurrentChar
    sta (ZeroPage),y
    
    lda CurrentColor
    sta (ZeroPageColor),y
    inc CurrentColor

    dey
    cpy StartIndex
    bne BottomLoop
    iny
    ldx #0
LeftLoop:
    PrevLine(ZeroPage, CurrentChar)
    PrevLine(ZeroPageColor, CurrentColor)
    inc CurrentColor

    inx
    cpx MaxNumOfRows
    bne LeftLoop

    // change the values for next iteration.
    dec MaxNumOfCols
    dec MaxNumOfCols
    dec MaxNumOfRows
    dec MaxNumOfRows
    inc StartIndex
    inc StartIndex
    ldx #0

    dec Iterations
    beq LastLoop

    jmp Loop


LastLoop:
    lda CurrentChar
    sta (ZeroPage),y
    
    lda CurrentColor
    sta (ZeroPageColor),y
    inc CurrentColor

    iny
    cpy MaxNumOfCols
    bne LastLoop
End:
    jmp End
    rts


.macro NextLine(addr, value) {
    lda addr
    clc
    adc #40
    sta addr
    lda addr + 1
    adc #0
    sta addr + 1

    lda value
    sta (addr),y
}

.macro PrevLine(addr, value) {
    lda addr
    sec
    sbc #40
    sta addr
    lda addr + 1
    sbc #0
    sta addr + 1

    lda value
    sta (addr),y
}