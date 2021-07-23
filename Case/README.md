# Installing the Micro-PET into a C64c case

I installed the Micro-PET into a C64c case, i.e. the flat one. The reason to select this type of case
is that there are new cases available since the original casts have been recovered.

## Board mounts

The board is screwed onto a support that is itself screwed to the bottom of the case.
Only one screw is used to directly screw the board to the case, the other screws fix the board to the support.

The back cover covers the case holes for the old expansion board hole that is not needed anymore.
It can also be used as template where to cut holes into the C64c case for the IEEE488, VGA, Ethernet and USB connectors.

[board support](board/MicroPET board mounts with batt holder.stl)
[back cover](board/Final MicroPET Back Cover.stl)

## Keyboard

### Options

There are three keyboard options available:

1. The open source [keyboard by Steve J. Gray](http://www.6502.org/users/sjgray/projects/mxkeyboards/index.html), using the "N-V1-R2" boards there.
2. The Petskey v1.0 keyboard from [texELEC](https://texelec.com/product/petskey/)
3. An original C64 keyboard.

The first two options are replacements for an N-type PET keyboard, the third options is a C64 keyboard.
The boot menu will detect which keyboard is used by noting which key is pressed to select the PET model, 
and will automatically load the right editor ROM (except for BASIC2 that only works with the N keyboard).

Note that options 1. and 2. will need MX key switches, preferrably of the 5 pin type that better locks in
and alignes in the right direction. Also, for thos switches you need to have appropriate key caps (see below).

### Supports

For each of the options there are different keyboard supports. You need the common
[keyboard support plate](kbd_support/C64c keyboard support plate.stl) and then
either

1. four [supports for SJG keyboards](kbd_support/Lower sjg keyboard support.stl) or
2. four [supports for petskeys keyboards](kbd_support/Lower petskey keyboard support.stl), or
3. two [supports for C64 keyboards](kbd_support/C64 keyboard support.stl)

### Standard Keycaps

As, for the self-built keyboards from option 1 or 2 some standard MX switches are used, standard 
key caps can be used as well. There is one caveat, however.

Newer key caps typically have a different inclination for each row of keys, that is the angle of the top key surface against the horizontal
is different for each row. This is to facilitate easier typing. In fact even the C64 keyboard has this.
The old PET keyboards, however, have the same angle - which is not zero! - for all rows. This makes it easier to use the same cap (in terms of physical dimensions)
on all rows, and just print on a different character for each key. Read more on those [key profiles](https://switchandclick.com/sa-vs-dsa-vs-oem-vs-cherry-vs-xda-keycap-profiles/).

I used two type of standard key caps:

1. [XDA profile, unmarked](https://www.amazon.de/gp/product/B06XSHK528/): this set of key caps does not have a print on it, and all keys have the same angle - zero. So it is 
possible to use any of the key caps in any row. Which is important, as you need a specific number of keys for each key width.
Also, this set has space bars in different lengths, and there is one that fits the 6.25 character wide space bar for the petskey and sjg keyboards.
For the markings I just used a pen...

2. This one [GLorious PC Gaming Race ABS Doubleshot black, ANSI layout GAKC-045](https://www.caseking.de/glorious-pc-gaming-race-abs-doubleshot-schwarz-ansi-us-layout-gakc-045.html) I actually bought more or less 
by accident. I only noticed that it has different angles per row when I tried it out. However, with the amount of caps I was able to only
use a wrong angle on Shift Lock, left Shift, Return and "4" - but it's barely noticable.
For the markings I used template from Steve's page, printed it on sticky paper, cut it out and glued it on the keys where the original did not fit.

### Printed Keycaps

As a third option I used 3-D printed key caps that I designed myself. 

The keycaps are made of three parts each:
1) a key form created by a parametric generator,
2) the top character print, extruded from the key form,
3) the front character (mostly the shifted character), extruded from the key form.

I created all parts, and integrated them in the [Tinkercad](https://tinkercad.com) web tool.

The key form is created by a [parametric generator](https://www.thingiverse.com/thing:2783650) in OpenSCAD. Here is the [parameter file](keycaps/key_cbm3_customizer.scad). Only the key width needs to be adapted, and the inversion of the top for the space key.

Most of the top character prints are made from a [Microgramm font](https://www.wfonts.com/font/microgramma), converted to SVG using the [Font Squirrel](https://www.fontsquirrel.com/tools/webfont-generator) web page.

Some top characters, and especially the top words ("SHIFT", "RUN STOP" etc) are taken from [Steve's github page](https://github.com/sjgray/CBM-MX-Keyboards/tree/master/stickers). As SVG exported from inkscape did not work when imported
into tinkercad, I had to make screenshots from each character, and convert these screenshots into SVGs using this [online converter](https://image.online-convert.com/convert-to-svg). 

The front characters are all from an [SVG file from wikipedia](https://en.wikipedia.org/wiki/Commodore_PET#/media/File:PET_Keyboard_improved.svg), from which I also took screenshots and converted to SVG as above.

You can find the STL files [here](keycaps/), in four parts due to its size.
Please note that it took me about 100+ hours just to print the full set of keys on my Snapmaker printer in high quality.
After printing you have to remove the supports that anchor the stem to the outside of the keycaps so it does
not break away when printing.





