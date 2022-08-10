# Sony PlayStation - Modchip HEX / Diagram Pack

**MM3/MultiMode3** hex dumps (Hex\\MultiMode3 12C508X\\) will work with pretty much every PS1 except for the **PAL PSOne slim** models, as it has the extra detection (using some detection for custom boot logos? Use **OneChip** instead for these consoles).
The **MM3** hex dumps here work on **12C508**, **12C508a**, **12C509**, **12C509a** PIC chips.

A port of the original MM3 was done in 2012 for the **12F629** PIC chip (same PIC used for the WiiFree).
Check (Hex\\MultiMode3 12F629\\) for these.

**ONEChip** (Hex\\Onechip 12C508A\\) is designed exclusively for PAL PSOne slim models.  
However the onechip is documented to only work on **12C508a** and not 12C509/12C509a/12C508 PIC chips!  
~~Although a rewritable version of the PIC like the **12F508**, should in theory also be compatible but is not tested!~~ **- Tested 28/02/2020, doesn't work and boots every CD as an Audio CD**  
Both of these chips are **stealth** modchips.

HQ Modding diagrams for the MM3 are in the **\\HQMM3-Diagrams\\** directory. 
HQ Modding diagrams for the OneChip are in the **\\HQOneChip-Diagrams\\** directory. 
Classic 2000s low quality MM3/OneChip diagrams and PAL60 colour mod diagrams are in the **\\2000s-Diagrams\\** directory.

**PAL60** Colour Mod is only required if your TV doesn't support **NTSC 4.43** (as modded PS1 PAL consoles don't use a pure **NTSC 3.58** signal).  
In my experience, every CRT TV that I've used in Australia has supported either mode. However funnily enough quite a lot of modern LCD TV's that I've used don't support the **PAL60** mod and support the **NTSC 4.43** mode anyway. So doing the mod actually breaks colour from working (often looks sepia, or doesn't sync at all).

SCPH-550X and below may require an external crystal for colour in NTSC games however. 
Check **\\2000s-Diagrams\\NTSC 3.58 PAL 4.43 Color Mod 100X-550X.PNG** for more details.

Software for the K150 PIP Programmer board are in **\\Hex\K150\\**
I recommend watching [**MrMario2011's** guide on programming the PIC chips.](https://www.youtube.com/watch?v=UM_Vyg-5QN4 "**MrMario2011's** guide on programming the PIC chips.")

Enjoy and good luck!
~Kippykip
