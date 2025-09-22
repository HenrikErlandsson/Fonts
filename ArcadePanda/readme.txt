ArcadePanda
- another 8x8x1 font pixeled for AmiGameJam 2025

Supports Amiga ANSI characters. Some ASCII characters, like []{}\|@~` are 
replaced with useful game/menu characters like arrow keys and transport 
controls.

Contents:
* IFF file, for conversion to bitmap for games that don't use system fonts.
* Fonts/ contains the system font version.
* C/ArcadePanda, an Amiga CLI command which attempts to set bitplane depth to 1 
to save Chipmem, and replaces Topaz 8 for some coding environments which do not 
easily support loading a system font. Even if one of the other two alternatives
are used in the game, this can be used to increase Chipmem, and also to print 
loading messages in CLI using the same font as in-game.
* ArcadePandaBoot.adf contains a bootblock that replaces Topaz 8, but only the ASCII characters - not the ANSI characters.

(c) Henrik Erlandsson
License: CC0 1.0 Universal
