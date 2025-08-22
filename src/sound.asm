
BasicUpstart2(start)

start:
    jsr sound.init
    jsr sound.Blip
    ldx #$ff
delay: dex
    bne delay
    jsr sound.Hit
    rts
sound:
{
//    7	      6	        5	        4	     3	            2	1	0
//  noise	pulse	sawtooth	triangle	test	ring modulation with voice 3	synchronize with voice 3	gate
//                  7..4	                                   3..0
.const V1FreqLo  =   $d400   //  (54272)   frequency voice 1 low byte
.const V1FreqHi  =   $d401   //  (54273)   frequency voice 1 high byte
.const v1PulseLo =   $d402   //  (54274)   pulse wave duty cycle voice 1 low byte
.const V1PulseHi =   $d403   //  (54275)   —	pulse wave duty cycle voice 1 high byte
.const V1Voice   =   $d404   //  (54276)   control register voice 1
.const V1AttDec  =   $d405   //  (54277)   attack duration	decay duration voice 1
.const V1SusRel  =   $d406   //  (54278)   sustain level	release duration
.const V2FreqLo  =   $d407   //  (54279)   frequency voice 2 low byte
.const V2FreqHi  =   $d408   //  (54280)   frequency voice 2 high byte
.const v2PulseLo =   $d409   //  (54281)   pulse wave duty cycle voice 2 low byte
.const V2PulseHi =   $d40a   //  (54282)   —	pulse wave duty cycle voice 2 high byte
.const V2Voice   =   $d40b   //  (54283)   control register voice 2
.const V2AttDec  =   $d40c   //  (54284)   attack duration	decay duration voice 2
.const V2SusRel  =   $d40d   //  (54285)   sustain level	release duration voice 2
.const V3FreqLo  =   $d40e   //  (54286)   frequency voice 3 low byte
.const V3FreqHi  =   $d40f   //  (54287)   frequency voice 3 high byte
.const v3PulseLo =   $d410   //  (54288)   pulse wave duty cycle voice 3 low byte
.const V3PulseHi =   $d411   //  (54289)   —	pulse wave duty cycle voice 3 high byte
.const V3Voice   =   $d412   //  (54290)   control register voice 3
.const V3AttDec  =   $d413   //  (54291)   attack duration	decay duration voice 3
.const V3SusRel  =   $d414   //  (54292)   sustain level	release duration voice 3
.const Filter1   =   $d415   //  (54293)   —	filter cutoff frequency low byte
.const Filter2   =   $d416   //  (54294)   filter cutoff frequency high byte
.const Filter3   =   $d417   //  (54295)   filter resonance and routing
.const VOL       =   $d418   //  (54296)   filter mode and main volume control

init:
    {
        
        ldx #18
        lda #0
    loop:
        sta V1FreqLo,x
        dex
        bpl loop
        lda #$0f
        sta VOL
        rts
    }
Hit:
    {
        
        ldx #15
    loop2:
        lda #$ff
    loop3:
        cmp $d012
        bne loop3
        stx VOL
        lda #129
        sta V1Voice
        lda #15
        sta V1AttDec
        lda 15
        sta V1SusRel
        lda #34
        sta V1FreqHi
        lda #75
        sta V1FreqLo
        ldy #64
    delay:
        dey
        bne delay
        dex
        bpl loop2
        lda 128
        sta V1Voice
        lda 0
        sta V1AttDec
        rts
    }
Blip:
    {
        lda #$0f
        sta VOL
        lda #129
        sta V1Voice
        lda #8
        sta V1AttDec
        lda #8
        sta V1SusRel
        lda #40
        sta V1FreqHi
        lda Tone: #200
        sta V1FreqLo
        lda #33
        sta V1Voice
        ldy #64
    delay:
        dey
        bne delay
        lda #32
        sta V1Voice
        lda Tone
        eor #201
        sta Tone
        rts 
    }
}
