#          Designed and Developed by Jacob Bieker (jacob@bieker.us)
#     
#       This script is designed convert input data to a standard format for
#       use Brenden-Colson Center and Stand Up 2 Cancer. 
#
#       Assumptions:
#       - Raw data will be passed to this file in an Excel document to be parsed and saved to 
#       an Rdata file for use in the view script
#

##############################################################################
#
#                 Setup
#
##############################################################################
# Check if libraries are installed, if not, install them
if(require("XLConnect")){
  print("XLConnect are loaded correctly")
} else {
  print("trying to install XLConnect")
  install.packages("XLConnet")
  if(require("XLConnect"){
    print("XLConnect are installed and loaded")
  } else {
    stop("could not install XLConnect")
  }
}

excel_file <- system.file("data.xlsx", package = "XLConnect")

workbook <- loadWorkbook(excel_file)

