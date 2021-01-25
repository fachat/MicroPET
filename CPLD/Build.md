
# Build setup for the CPLD

## WebISE

The xc95xxx CPLDs are only supported by the WebISE software available for download from Xilinx.
Support has not (yet to my knowledge) been integrated into their new Vivado software.

### Setting up the project

When you start WebISE, you have to create a new project. 

Use this CPLD folder as project folder, and a "work" subfolder as work folder. It is better not to use the same folder, as 
in the work folder many files are created that clutter the folder only.

Then setup the project as shown in this images

![Project Settings](images/project_settings.png)

Under the project, "Add Source" and add the "Top.vhd" VHDL file

![Add Top VHDL file](images/add_top_file.png)

Then add the other VHDL files underneath by assigning the VHDL files to their respective components.
Note that for the Video and Clock components, two options are available, Composite video out or VGA (640x480) output.

![Add other VHDL files](images/add_mapper_and_video.png)

Finally, add the constraints file

![Add Pinout](images/add_pinout.png)

In the process properties, set "Area" as optimization goal, and optimization effort to "High".

![Synthesis properties](images/process_synthesis.png)

Set "Optimize Density" for the Fitting.

![Fitting properties](images/process_fitting.png)

Also, enable "advanced" build properties, and click "extensive fitting", to allow for slower, but better fitting.
The r2 managed to be fitted with pterm limit: 12 and input limit: 17 - so this may be a worth a try to shorten
the fitting time (with full levels it took over 2-3h...).

Then you can build the "Top.jed" file by clicking the green triangle to start the build.

### Programming the CPLD

To program the CPLD, the "iMPACT" tool is used, that is part of the WebISE package.

Here you have to create a new project too.

![iMPACT project](images/impact_save_new_project.png)

Connect the USB JTAG cable to the PC, attach the JTAG wires to the probe connector on the Micro-PET board, and power it up.
Then let iMPACT automatically detect the CPLD

![Detecting the CPLD](images/impact_project.png)

It may be possible to use other cables, to set them up use the Output/Device Setup menu

![iMPACT cable setup](images/impact_cable_example.png)

Right-clicking on the Device and reading the Device ID is a good check if the cable works

![iMPACT cable check](images/get_device_id.png)

Then assign a configuration file to the CPLD

![Assign configuration](images/impact_assign_config.png)

After that, you can right-click on the CPLD device on display and select "Program" to program the configuration into the CPLD.


