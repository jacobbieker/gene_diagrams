#          Designed and Developed by Jacob Bieker (jacob@bieker.us)
#     
#       This script is designed to created plots of genomics data for the 
#       Brenden-Colson Center and Stand Up 2 Cancer. 
#
#       Assumptions:
#       - Average is taken by t_alt_count/(t_alt_count+t_ref_count)
#
##############################################################################
#
#                 Setup
#
##############################################################################
# Check if libraries are installed, if not, install them
require("VennDiagram")
require(Cairo)

tumor_data <- labkey.data[ with(labkey.data,  grepl("T_tumor", sample)  & !is.na(labkey.data$sample) ) , ]
metastasis_data <- labkey.data[ with(labkey.data,  grepl("M_tumor", sample)  & !is.na(labkey.data$sample) ) , ]

# Get percentages
average_t <- tumor_data$t_alt_count / (tumor_data$t_alt_count + tumor_data$t_ref_count);
#Add average back in so we can sort later to get right names
tumor_data <- cbind(tumor_data, average_t);
#Sort from biggest to smallest
average_t <- sort(average_t, decreasing = TRUE);

#Switch order of variants around to match sorted averages
tumor_data <- tumor_data[match(average_t, tumor_data$average_t),];

# Getting the labels to put on the plots
t_labels <- c();
t_variants <- tumor_data$variant;

for (t_variant in t_variants) {
  t_parts <- strsplit(t_variant, ":");
  t_labels <-c(t_labels, unique(rapply(t_parts, function(x) head(x, 1))))
}

#Get percentages
average_m <- metastasis_data$t_alt_count / (metastasis_data$t_alt_count + metastasis_data$t_ref_count);
#Add average back in so we can sort later to get right names
metastasis_data <- cbind(metastasis_data, average_m);
#Sort from biggest to smallest
average_m <- sort(average_m, decreasing = TRUE);

#Switch order of variants around to match sorted averages
metastasis_data <- metastasis_data[match(average_m, metastasis_data$average_m),];

# Getting the labels to put on the plots
m_labels <- c();
m_variants <- metastasis_data$variant;

for (m_variant in m_variants) {
  m_parts <- strsplit(m_variant, ":");
  m_labels <-c(m_labels, unique(rapply(m_parts, function(x) head(x, 1))))
}

##################################################
#
#           Graphing bar plot data
#
##################################################                                   

#   Open a Cairo device to take your plotting output:
Cairo(file="${imgout:Primary_barplot.png}", type="png");
#  Plot:
barplot(average_t, ylab= "Percentage", names.arg=t_labels, axis.lty=3, col=t_cols, space=0.5, cex.names=0.8, las=3, main="Average Test Percentage");
dev.off();

#   Open a Cairo device to take your plotting output:
Cairo(file="${imgout:Metastasis_barplot.png}", type="png");
#  Plot:
barplot(average_m, ylab= "Percentage", names.arg=m_labels, axis.lty=3, col=m_cols, space=0.5, cex.names=0.8, las=3, main="Average Test Percentage");
dev.off();