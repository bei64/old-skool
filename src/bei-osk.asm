BasicUpstart2(Start)

.label O = $2000
.label S = O+8
.label K = S+8

.label ScreenPointer = $FB
.label CurrentRow = $FD
.label ColorPointer = $FE

Colors: 
		.byte $09,$0B

Start:
    jsr $E544
    lda #$00
    sta $D020
    sta $D021

    lda #$20
    sta ScreenPointer
    lda #$05
    sta ScreenPointer + 1
    
    lda #$20
    sta ColorPointer
    lda #$D9
    sta ColorPointer + 1

    lda $01
    and #%11111011    
    sta $01
    ldx #0
CopyO:
    lda $D000 + $0F * 8,x
    sta O,x
    inx
    cpx #8
    bne CopyO

    ldx #0
CopyS:
    lda $D000 + $13 * 8,x
    sta S,x
    inx
    cpx #8
    bne CopyS

    ldx #0
CopyK:
    lda $D000 + $0B * 8,x
    sta K,x
    inx
    cpx #8
    bne CopyK

    lda $01
    ora #%00000100 
    sta $01


    ldx #0
RowLoop:
    lda O,x
    sta CurrentRow
    DrawLine(41, 0)
    lda O,x
    sta CurrentRow
    DrawLine(0, 5)


    lda S,x
    sta CurrentRow
    DrawLine(49, 0)
    lda S,x
    sta CurrentRow
    DrawLine(8, 2)


    lda K,x
    sta CurrentRow
    DrawLine(57, 0)
    lda K,x
    sta CurrentRow
    DrawLine(16, 13)
    
    lda ScreenPointer
    clc
    adc #40
    sta ScreenPointer
    lda ScreenPointer + 1
    adc #0
    sta ScreenPointer + 1
    lda ColorPointer
    clc
    adc #40
    sta ColorPointer
    lda ColorPointer + 1
    adc #0
    sta ColorPointer + 1
    
    inx
    cpx #8
    beq Done
    jmp RowLoop

Done:

    ldy #0
    ldx #0
wblank:
    lda $d011
    bpl wblank
wblank2: 
    lda $d011
    bmi wblank2


    inx
    cpx #$FF
    bne wblank
    lda $D020
    clc
    adc #1
    and #$01
    tay
    //and #1
    lda Colors,y
    sta $D020
    sta $D021

    jmp Done



.macro DrawLine(offset, color) {
    ldy #0 + offset
Loop:
    lda CurrentRow
    asl
    sta CurrentRow
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