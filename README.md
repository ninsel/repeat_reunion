# repeat_reunion
Matlab code for the repeat reunion study

The code is organized in a collection of Matlab scripts and livescripts
All main sections are titled repeatreunion_part<X>_livescript.mlx (or repeatreunion_part<X>_script.m if a script).
To run, start with **_part0_**, which sets-up the variables, and then use the part that applies to the analysis you want to perform
 
 Index of parts:
 
 part 0: loading and organizing tables/variables
     Calls:
       ReunionDatabase_0p2
          Calls 
              FindFiles.m
              ProcessBORIS.m
          Files needed
              repeatreunionall.xlsx (spreadsheet with all reunion info)
              eventsXXX.csv (all of the events files, located in a subdirectory of wherever repeatreunionall.xlsx is)               
       RR_AddVocs
       reun_mksumbehav.m
 part 1: analysis of female physical behavior, stranger/cagemate across days, using BORIS-scored data
 
 part 2: analysis of male physical behavior, stranger/cagemate across days, using BORIS-scored data
 
  
