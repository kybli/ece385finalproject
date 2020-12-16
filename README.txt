Instructions to Run:

1. Go to platform designer and generate HDL. If this doesn't work, double check that you've downloaded all of the files including the .tcl file so that the audio IP core is on your local machine.

2. Go to quartus and Syntesize. This may take a while. Then use the fpga programmer to program your fpga

3. Plug in peripherals. Plug in line in to your audio playing device. Then plug in line out to your headphones or speaker. Lastly, plug your keyboard into the usb port.

4. Go to eclipse and open up the project's software.

5. Comment out the main.c file. Then uncomment the sgtl5000_test.c file and then Generate BSP, and then Build all. Next, run the De10 configuration to run the pgrogram. This helps set up the audio interface.

6. Comment out the sgtl5000_test.c file and uncomment the main.c file. Generate Bsp, build all, then run the DE 10 configuration. This runs the actual program.

7. You'll see the audio visualizer appear. In order to play the gae, use the 'A' and 'D' keys to move the ball left and right. You earn a point
   every time you "catch" the bomb. The points are reflected on the hex displays. The bomb falls faster each time you catch it.