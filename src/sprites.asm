SPRITES: {
	.label JOY_PORT_2 = $dc00
	.label PLAYER_UP 		= %00000001
	.label PLAYER_DOWN 	    = %00000010
	.label PLAYER_LEFT 	    = %00000100
	.label PLAYER_RIGHT 	= %00001000

	.label JOY_UP = %00001
	.label JOY_DN = %00010
	.label JOY_LT = %00100
	.label JOY_RT = %01000
	.label JOY_FR = %10000


    .label DIR_UP = 1
    .label DIR_DOWN = 2
    .label DIR_LEFT = 3
    .label DIR_RIGHT = 4

    PlayerState: .byte $00
    PlayerShooting: .byte $00
    BulletDirection: .byte $00
    EnemyDirection: .byte $00

    
    SpriteMSB:  .fill 8,0 
    SpriteMSBValue: .fill 8, 1 << i

    Init: {
        lda #RED
        sta VIC.SPRITE_MULTICOLOR_1
        lda #GREY
        sta VIC.SPRITE_MULTICOLOR_2

        lda #BLUE
        sta VIC.SPRITE_COLOR_0

        lda #CYAN
        sta VIC.SPRITE_COLOR_1
        lda #$40
        sta SPRITE_POINTERS
        //sta SPRITE_POINTERS + 1

        lda VIC.SPRITE_ENABLE 
        ora #%00000001
        sta VIC.SPRITE_ENABLE

        lda VIC.SPRITE_MULTICOLOR
        ora #%00000011
        sta VIC.SPRITE_MULTICOLOR

        lda #$A8
        sta VIC.SPRITE_0_X
        
        lda #$88
        sta VIC.SPRITE_0_Y

        rts
    }

    MSBSetter:
        // Input X: is the sprite number
        lda SpriteMSB,x
        beq !SetMSB+

        lda SpriteMSBValue,x
        eor #$FF
        and VIC.SPRITE_MSB
        sta VIC.SPRITE_MSB

        lda #0
        sta SpriteMSB,x 
    !Exit:
        rts

    !SetMSB:
        lda SpriteMSBValue,x
        ora VIC.SPRITE_MSB
        sta VIC.SPRITE_MSB

        lda #1
        sta SpriteMSB,x   
        jmp !Exit-

    BulletMove: {
        lda PlayerShooting
        bne !+
        jmp !Done+
    !:
        lda BulletDirection
        cmp #DIR_UP
        beq !MoveUp+
        cmp #DIR_DOWN
        beq !MoveDown+
        cmp #DIR_LEFT
        beq !MoveLeft+
        cmp #DIR_RIGHT
        beq !MoveRight+

    !MoveRight:
        lda VIC.SPRITE_1_X
        clc
        adc #$06
        sta VIC.SPRITE_1_X
        bcc !+
        ldx #1
        jsr MSBSetter
    !:
        lda VIC.SPRITE_1_X
        cmp #84
        bne !Done+
        jsr MSBSetter
        lda #0
        sta PlayerShooting
        lda VIC.SPRITE_ENABLE 
        and #%11111101
        sta VIC.SPRITE_ENABLE
        jmp !Done+
    !MoveLeft:
        lda VIC.SPRITE_1_X
        sec
        sbc #$06
        sta VIC.SPRITE_1_X
        cmp #00
        bne !Done+
        lda #0
        sta PlayerShooting
        lda VIC.SPRITE_ENABLE 
        and #%11111101
        sta VIC.SPRITE_ENABLE
        jmp !Done+
    !MoveDown:
        lda VIC.SPRITE_1_Y
        clc
        adc #$06
        sta VIC.SPRITE_1_Y
        cmp #$FC
        bne !Done+
        lda #0
        sta PlayerShooting
        lda VIC.SPRITE_ENABLE 
        and #%11111101
        sta VIC.SPRITE_ENABLE
        jmp !Done+

    !MoveUp:
        lda VIC.SPRITE_1_Y
        sec
        sbc #$06
        sta VIC.SPRITE_1_Y
        cmp #00
        bne !Done+
        lda #0
        sta PlayerShooting
        lda VIC.SPRITE_ENABLE 
        and #%11111101
        sta VIC.SPRITE_ENABLE

    !Done:
        rts
    }

    
	PlayerInput: {
        lda JOY_PORT_2
        sta JOY_ZP1
    !Fire:
        lda JOY_ZP1
        and #JOY_FR
        beq !+
        jmp !Up+
    !:
        lda PlayerState
        bne !+
        jmp !Up+
    !:
        lda PlayerShooting
        beq !+
        jmp !Up+

    !:


        lda PlayerState
        cmp #DIR_UP
        beq !ShootUp+
        cmp #DIR_DOWN
        beq !ShootDown+
        cmp #DIR_LEFT
        beq !ShootLeft+
        cmp #DIR_RIGHT
        beq !ShootRight+

        jmp !Up+


    !ShootUp:
        lda #1
        sta PlayerShooting
        lda #DIR_UP
        sta BulletDirection

        lda #$44
        sta SPRITE_POINTERS + 1
        
        lda VIC.SPRITE_ENABLE 
        ora #%00000010
        sta VIC.SPRITE_ENABLE

        lda #$A8
        sta VIC.SPRITE_1_X
        
        lda #$84
        sta VIC.SPRITE_1_Y
        jmp !Up+
    !ShootDown:
        lda #1
        sta PlayerShooting
        lda #DIR_DOWN
        sta BulletDirection

        lda #$44
        sta SPRITE_POINTERS + 1
        
        lda VIC.SPRITE_ENABLE 
        ora #%00000010
        sta VIC.SPRITE_ENABLE

        lda #$A8
        sta VIC.SPRITE_1_X
        
        lda #$90
        sta VIC.SPRITE_1_Y

        jmp !Up+
    !ShootLeft:
        lda #1
        sta PlayerShooting
        lda #DIR_LEFT
        sta BulletDirection

        lda #$45
        sta SPRITE_POINTERS + 1
        
        lda VIC.SPRITE_ENABLE 
        ora #%00000010
        sta VIC.SPRITE_ENABLE

        lda #$9C
        sta VIC.SPRITE_1_X
        
        lda #$88
        sta VIC.SPRITE_1_Y

        
        jmp !Up+

    !ShootRight:
        lda #1
        sta PlayerShooting
        lda #DIR_RIGHT
        sta BulletDirection

        lda #$45
        sta SPRITE_POINTERS + 1
        
        lda VIC.SPRITE_ENABLE 
        ora #%00000010
        sta VIC.SPRITE_ENABLE

        lda #$AC
        sta VIC.SPRITE_1_X
        
        lda #$88
        sta VIC.SPRITE_1_Y


    !Up:
        lda JOY_ZP1
        and #JOY_UP
        bne !Left+
        lda #$40
        sta SPRITE_POINTERS
        lda #DIR_UP
        sta PlayerState
        jmp !Done+
    !Left:
        lda JOY_ZP1
        and #JOY_LT
        bne !Right+
        lda #$41
        sta SPRITE_POINTERS
        lda #DIR_LEFT
        sta PlayerState
        jmp !Done+
    
    !Right:
        lda JOY_ZP1
        and #JOY_RT
        bne !Down+
        lda #$42
        sta SPRITE_POINTERS
        lda #DIR_RIGHT
        sta PlayerState
        jmp !Done+
    
    !Down:
        lda JOY_ZP1
        and #JOY_DN
        bne !Done+
        lda #$43
        sta SPRITE_POINTERS

        lda #DIR_DOWN
        sta PlayerState
        jmp !Done+

    !Done:
        rts
    }


    HandleEnemy: {
        rts
    }
}