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
  print("XLConnect is loaded correctly")
} else {
  print("trying to install XLConnect")
  install.packages("XLConnect")
}

workbook <- loadWorkbook("data.xlsx")

data_file <- readWorksheet(workbook, sheet = 1, header = TRUE)

tumor_data_file <- data_file[ with(data_file,  grepl("T_tumor", Sample)  & !is.na(data_file$Sample) ) , ]
metastasis_data_file <- data_file[ with(data_file,  grepl("M_tumor", Sample)  & !is.na(data_file$Sample) ) , ]

saveRDS(tumor_data_file, file = "tumor.rds")
saveRDS(metastasis_data_file, file = "metastasis.rds")