# Genomics Visualizer
This script, designed to be used primarily in LabKey Server, creates some common visualizations of tumor and metastasis gene varient data that is imported as a list.

# Prerequisites 
- LabKey Server
- R statistical Software

# Usage
The script, as of now, expects a LabKey list as input. The list should follow the format, with headers, folowing this format:

context;gene;contig;start;end;ref;alt;sample;db;total;t\_ref\_count;t\_alt\_count;n\_ref\_count;n\_alt\_count

In addition, the script expects the sample name to end with T_tumor for the primary tumor, or M_tumor, for the metastasis tumor.

The script then produces an R view that, depending on the data, produces bar plots of the mutations and compares what mutations exist between both the metastasis tumor and primary tumor.
