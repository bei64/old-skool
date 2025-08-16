TABLES: {
    TileScreenLocations2x2:
		.byte 0,1,40,41	

    ScreenRowLSB:
		.fill 25, <[$4000 + i * $28]
	ScreenRowMSB:
		.fill 25, >[$4000 + i * $28]

    StarRows:
        .byte  2, 2, 3, 3, 4, 7, 8, 9, 9,13,14,17,17,17,19,21
    StarColumns:
        .byte  4,11, 5,22,35, 5,13,26,32,37, 5,10,18,24,14,38
}