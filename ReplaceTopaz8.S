

	*===============================================.
	;						|
	* 		   ReplaceTopaz8		(
	;						|
	*-----------------------------------------------+
	; by Photon of Scoopex © 2025 Henrik Erlandsson	|
	*=========#=====================================#
	; V0.20:  | Unpatch for 1.3			|
	; V0.19:  | Opti 3				|
	; V0.18:  | Opti 2				|
	; V0.17:  | Opti				|
	; V0.16:  | Cleanup, test 4			|
	; V0.15:  | Cleanup, test 3			|
	; V0.14:  | Cleanup, test 2			|
	; V0.13:  | Cleanup, test			|
	; V0.12:  | Back to working version. Cleanup	|
	; V0.11:  | SetFont				|
	; V0.10:  | Set back maxparams to 1		|
	; V0.09:  | Cleanup				|
	; V0.08:  | More weird patches, use TypeFace124!|
	; V0.07:  | Weird patch to skip src for char 160|
	; V0.06:  | Copy disk font cand #1		|
	; V0.05:  | Copy disk font chars WIP		|
	; V0.04:  | Copy disk font chars		|
	; V0.03:  | Successful CopyROMfont		|
	; V0.02:  | Allocs/checks OK, trying CopyRomFont|
	; V0.01:  | First try. All but copychars. Works.|
	*---------+-------------------------------------*
	; Notes: /
	*-------*

;TODO: Optimize up to 6 bytes by in-lining 3 subroutines. But very ugly.

;NOTE: *MUST* use WBFed or TypeFace font editor to save the font, with
;correct size and kern info. (Untick Kern info in TypeFace.)

	INCDIR "A:INC/Include/"		;standard LVO libs
	INCLUDE "graphics/text.i"

	INCDIR ""
	INCLUDE "A:INC/FINISHED/Makaper.S"

_Any	=0

R:
B:
	MAK_INIT 34,"Error/Not specified an 8x8 font!"
	MAK_OPENLIBS dos
	MAK_IO
	moveq #0,d6
	move.l d6,d5
	MAK_GETPARAMS MAK_ParamP-R(A5),1
	beq.w Not8x8

    *--- Alloc font dst ---*

	lea FontName-R(A5),a0
	move.l a0,FontDef-R(A5)		;avoid reloc

	moveq #96,d7			;192*8=1536 in d7 const
	lsl.w #4,d7

	MAK_ALLOC d7,_Any,d6
	beq.w Not8x8

    *--- Load font file ---*

	move.l MAK_Params-R(a5),a1
	MAK_LOADF a1,_Any
	move.l a0,a2
	move.l d0,d5
	ble.s Not8x8

	bsr.w ParseFontFile		;a0=file->a3,a4=textfont,chardata

    *--- Check font size ---*

	moveq #8,d0
	cmp.w tf_XSize(a3),d0
	bne.s Not8x8
	cmp.w tf_YSize(a3),d0
	bne.s Not8x8

    *--- Copy system chars ---*
	
	move.l d6,a1
	bsr.w CopySystemChars		;a1=src,dest ->d0=-1 (or 0=err)
	beq.s Not8x8

    *--- Copy disk font chars ---*

	move.w tf_modulo(a3),d0
	bsr CopyFontChars ;d0/a1-a4=modulo,dst(allocP),textfont,src(chardataP)

    *--- Exit ---*

Exit:
	MAK_FREE a2,d5			;OK if 0,0
	MAK_CLOSELIBS
	rts

Not8x8:
	MAK_FREE d6,d7			;OK if 0,0
	lea MAK_TxtBuf-R(A5),a0
	MAK_WRITELNA a0
	bra.w Exit

********************  Routines  ********************

ParseFontFile:		;a0=file->a3,a4=textfont,chardata

    *--- Parse font file ---*

	move.l a0,a3
	lea $20(a3),a3			;skip hunk header
	move.l a3,d0			;start of binary in d0
	lea $4(a3),a3			;skip "moveq #64,d0 rts"
	add.l d0,LN_NAME(a3)		;reloc

    *--- get ptr to char bitmap ---*

	lea $36(a3),a3			;now *TextFont in a3, a3 used outside
	add.l d0,LN_NAME(a3)		;reloc
	add.l d0,tf_CharData(a3)	;reloc

	move.l tf_CharData(a3),a4
	RTS

CopySystemChars:			;d7,a1=192*8,allocP(dst),a6=execbase
	MOVEM.L D7/A1-A2/A6,-(SP)
	move.l a1,a2
	move.l 156(a6),a6		;gfxbase

	lea FontDef(PC),a0
	jsr -72(a6)			;openFont(topaz.font)
	tst.l d0
	beq.s .Err
	move.l d0,a1
	move.l $22(a1),a0		;fontaddr
	move.l a2,$22(a1)

.Copyl:
	move.b (a0)+,(a2)+		;copy system chars
	subq.w #1,d7
	bne.s .Copyl

	tst.l d0
.Err:	MOVEM.L (SP)+,D7/A1-A2/A6
	RTS				;->d0=-1 (or 0=err)


CopyFontChars:		;d0/a1-a4=modulo,dst(allocP),textfont,src(chardataP)
	MOVEM.L D4/A3-A4,-(SP)
	moveq #-36,d4
	add.w 20(a6),d4			;d4 < 0 if KS < 2.0

    *--- Get start/stop char ---*

	moveq #0,d2
	moveq #0,d3
	move.b tf_LoChar(a3),d2		;char counter = start char
	move.b tf_HiChar(a3),d3

	lea -32(a1,d2.w),a1		;skip to first used char

    *--- char loop ---*

.charl:
	move.l a4,a0
	tst.w d4
	bmi.s .LS20
	cmp.w #$ac,d2			;ignore weird duplicated char
	beq.s .adv
.LS20:
	cmp.w #$80,d2
	blo.s .noskip
	cmp.w #$a0,d2
	blo.s .skipchar
	tst.w d4
	bmi.s .noadv
	cmp.w #$a0,d2
	bne.s .noadv
.adv:
	addq.w #1,a4			;ignore char in font file and advance
	move.l a4,a0
.noadv:
.noskip:
	move.l a1,a3

    *--- copy char ---*

	moveq #8-1,d1
.l5:
	move.b (a4),(a1)
	add.w d0,a4
	lea 192(a1),a1			;dst modulo
	dbf d1,.l5

    *--- next char ---*

	lea 1(a3),a1			;char copied - next char in dst

.skipchar:
	lea 1(a0),a4			;next char in src
	cmp.w d3,d2			;was stop char?
	beq.s .done

	addq.w #1,d2			;increase char counter
	bra.s .charl
.done:
	MOVEM.L (SP)+,D4/A3-A4
	RTS

********************  DATA  ********************

FontDef:dc.l 0
	dc.w 8,0,8
Fontname:dc.b 'topaz.font',0
FontNameE:
;	dc.b "Photon+a4k-oerx"		;opti,credit in readme.
E:

