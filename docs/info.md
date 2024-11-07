<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a simple circuit to display a 3-segment  "snake" on the 7-Segment display and make it move around.

## How to test

Supply a clock (10KHz to 50MHz).  Watch the snake move around on the 7-Segment display.  
Change the speed of movement by supplying a 4-bit value on ui_in[3:0].  Larger values 
mean faster movement.

## External hardware

Uses the 7-Segment display on the demo board.
