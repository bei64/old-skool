IRQ: {
	Setup: {
		sei

		lda #$7f	//Disable CIA IRQ's to prevent crash because 
		sta $dc0d
		sta $dd0d

		lda $d01a
		ora #%00000001	
		sta $d01a

		lda #<MainIRQ    
		ldx #>MainIRQ
		sta $fffe   // 0314
		stx $ffff	// 0315

		lda #$e2
		sta $d012
		lda $d011
		and #%01111111
		sta $d011	

		asl $d019
		cli
		rts
	}

	MainIRQ: {		
		:StoreState();

            
			jsr CHAR_ANIMATIONS.FlickerStar


			asl $d019 //Acknowledging the interrupt
		:RestoreState();
		rti
	}
}
FlickerTimer: 
    .byte $20, $20
StarIndex: 
    .byte $00
LastStar: 
    .byte $00
CHAR_ANIMATIONS: {
    FlickerStar: {
        dec FlickerTimer
        beq !+
        rts
    !:
        jsr Random
		and #%00011111
        sta FlickerTimer

        lda LastStar
		cmp #1
		bne !+
		ldy StarIndex
		jmp !++
        

	!:
        jsr Random
        and #%00001111
        sta StarIndex
        tay
	!:
        ldx TABLES.StarRows, y

        lda TABLES.ScreenRowLSB, x
        sta TEMP1
        lda TABLES.ScreenRowMSB, x
        sta TEMP1 + 1


        lda StarIndex
        tax
        ldy TABLES.StarColumns, x

        lda (TEMP1), y
        cmp #2
        beq SmallStar
        lda #2
        sta (TEMP1), y
		sta LastStar
        rts
	SmallStar:
        lda #1
        sta (TEMP1), y
		sta LastStar
        rts
    }
}