BasicUpstart2(Start)


#import "zeropage.asm"
#import "tables.asm"
#import "vic.asm"
#import "irq.asm"

#import "map_loader.asm"
#import "sprites.asm"


.label SCREEN_RAM = $4000
.label SPRITE_POINTERS = SCREEN_RAM + $3f8

Random: {
        lda seed
        beq doEor
        asl
        beq noEor
        bcc noEor
    doEor:    
        eor #$1d
    noEor:  
        sta seed
        rts
    seed:
        .byte $76
}

Start:
    lda #RED
    sta VIC.BORDER_COLOR
    lda #BLACK
    sta VIC.BACKGROUND_COLOR


    jsr IRQ.Setup

        // Band out Basic and Kernal ROM
    lda $01
    and #%11111000
    ora #%00000101
    sta $01

    lda $DD00
    and #%11111100
    ora #%00000010
    sta $DD00

    lda VIC.MEMORY_SETUP
    and #%00000001
    ora #%00001100  
    sta VIC.MEMORY_SETUP

    lda VIC.SCREEN_CONTROL_2
    ora #%00010000
    sta VIC.SCREEN_CONTROL_2

    lda #YELLOW
    sta VIC.EXTENDED_BG_COLOR_1
    lda #WHITE
    sta VIC.EXTENDED_BG_COLOR_2


    jsr MAPLOADER.DrawMap
    jsr SPRITES.Init
    
GameLoop:
    :WaitForRasterLine($FF)
    
    lda #BLUE
    sta VIC.BORDER_COLOR
    jsr SPRITES.PlayerInput
    
    lda #GREEN
    sta VIC.BORDER_COLOR
    jsr SPRITES.BulletMove
    lda #BROWN
    sta VIC.BORDER_COLOR
    jsr SPRITES.HandleEnemy

    lda #RED
    sta VIC.BORDER_COLOR
    jmp GameLoop



* = $5000 "Player Sprites"
		.import binary "../assets/Player.bin"
		.import binary "../assets/Bullet.bin"
		.import binary "../assets/Enemy.bin"

* = $2000 "Map data"
    MAP_TILES:
        .import binary "../assets/GameScreen - Tiles.bin"
    CHAR_COLORS:
        .import binary "../assets/GameScreen - CharAttribs.bin"
    MAP_1:
        .import binary "../assets/GameScreen - Map (20x11).bin"

* = $7000 "Character data"
    CharData:
        .import binary "../assets/GameScreen - Chars.bin"




.macro StoreState() {
		pha //A
		txa 
		pha //X
		tya 
		pha //Y
}

.macro RestoreState() {
		pla 
		tay
		pla 
		tax 
		pla 
}

.macro WaitForRasterLine( line ) {
    lda #line
    cmp $d012
    bne *-3	
}