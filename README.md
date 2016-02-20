# PRU
This repository contains assembly language programs for the BeagleBone PRU sub-processors. The workflow is as follows:
1. Compile the appropriate overlay and install it.  You can also install the overlay automatically on boot.
2. Compile the assembly language program using pasm.  A .bin file will be produced.
3. Compile the c language program to load any data to the PRU memory and to run the .bin file.
