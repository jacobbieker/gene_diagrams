#          Designed and Developed by Jacob Bieker (jacob@bieker.us)
#     
#       This script is designed to created plots of genomics data for the 
#       Brenden-Colson Center and Stand Up 2 Cancer. 
#
#       Assumptions:
#       - Data will be passed from another R script in a standard format to this
#       script.
#
##############################################################################
#
#                 Setup
#
##############################################################################
# Check if libraries are installed, if not, install them
if(require("VennDiagram")){
  print("VennDiagram are loaded correctly")
} else {
  print("trying to installVennDiagram")
  install.packages("VennDiagram")
}

# Load data from the Rdata file created by the data import file
# Assumptions: there is a data.frame called genomics that contains the data needed
metastasis_data <- readRDS("metastasis.rds")
tumor_data <- readRDS('tumor.rds')
