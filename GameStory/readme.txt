GameStory
- an 8x8x1 font pixeled for AmiGameJam 2025

Supports Amiga ANSI characters. Some ASCII characters, like []{}\|@~` are 
replaced with useful game/menu characters like arrow keys and transport 
controls.

Contents:
* IFF file, for conversion to bitmap for game that don't use system fonts.
* Fonts/ contains the system font version.
* C/GameStory, an Amiga CLI command which attempts to set bitplane depth to 1 
to save Chipmem, and replaces Topaz 8 for some coding environments which do not 
easily support loading a system font. Even if one of the other two alternatives
are used in the game, this can be used to increase Chipmem, and also to print 
loading messages in CLI using the same font as in-game.
* GameStoryBoot, a bootblock that replaces the ASCII characters of the default Topaz font.

(c) Henrik Erlandsson
License: CC0 1.0 Universal
