# repeat_reunion
Matlab code for the repeat reunion study

The code is organized in a collection of Matlab livescripts (rr_livescripts) that call supporting functions (rr_supportingfunctions). A few intermediate variables are saved in rr_matfiles

All main livescripts are titled repeatreunion_part<X>_FM_<topic>.mlx 

To run, always start with **_part0_**, which sets-up the variables, and then use the part that applies to the analysis to be performed. 
 
Index of parts:
 
 part 0: loading and organizing tables/variables     
       Requires, for example: 
            - ReunionDatabase_0p2
            - FindFiles.m
            - ProcessBORIS.m
            - ... 
          Data files needed:
              - Spreadsheet with all reunion info
              - (in subfolder of directory with spreadsheet): eventsXXX.csv files (all of the events files)       

 part 2: Processing interaction levels across individual degus

 part 3A: Computing variances across sessions using interaction vector distances

 part 3B: Computing variances across sessions using SVM-based, dyad-classification success  

 part 4A: Computing variances in within-session, interaction sequencing and relative timing

 part 4B: Computing variances in blocks of interactions within-sessions
