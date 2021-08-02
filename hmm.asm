#define progStart $9D95
#define lcdDelay $000B
#define bClrLCDFull $4540
#define bRunIndicOff $4570
#define bGetKey $4972
#define lcdComPort $10
#define lcdDataPort $11

.org progStart

main:
	rst 28h
	.dw bClrLCDFull
	rst 28h
	.dw bRunIndicOff
	ld bc,$020D
	ld hl,boohoo
	call lcdDrawTile
	rst 28h
	.dw bGetKey
	ret
	
;lcdOut: Writes to a port with a required LCD delay if writing to LCD ports
;
;Parameters:
;
;	C: Port Address
;	A: Port Data
;
;Returns:
;
;	Nothing

lcdOut:

	out (c),a
	push af
	call lcdDelay
	pop af
	ret

;lcdDrawTile: Draw a tile to the LCD.
;
;Parameters:
;
;	Mirroring is currently not implemented
;	B: Column (X)
;	C: Row (Y)
;	HL: Tile Address
;
;Returns:
;
;	Nothing

lcdDrawTile:

	push af ;Save Registers because I might mess them up
	push bc
	push de
	push hl

	ex de,hl ;Save Tile Address
	ld hl,$2080
	add hl,bc ;Add $20 to Column and $80 to Row for true Column and Row
	ex de,hl ;Restore Tile Address

	ld c,lcdComPort
	ld a,d
	call lcdOut ;Set Column
	ld a,e
	call lcdOut ;Set Row

	ld b,0
	ld c,lcdDataPort

ldtLoop:

	ld a,(hl) ;Load Tile Row Data into A
	call lcdOut ;Draw Tile Row
	inc hl ;Next Tile Row
	inc b
	ld a,8 ;Drawing 8 Rows is 1 Tile
	cp b
	jp nz,ldtLoop

ldtEnd:

	pop hl ;Restore the registers
	pop de
	pop bc
	pop af
	ret

boohoo:
.db $18,$24,$5A,$5A,$5A,$5A,$24,$18