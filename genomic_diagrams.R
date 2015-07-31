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
require(Cairo)

# Taken From: https://stackoverflow.com/questions/3402371/combine-two-data-frames-by-rows-rbind-when-they-have-different-sets-of-columns
### combines data frames (like rbind) but by matching column names
# columns without matches in the other data frame are still combined
# but with NA in the rows corresponding to the data frame without
# the variable
# A warning is issued if there is a type mismatch between columns of
# the same name and an attempt is made to combine the columns
combineByName <- function(A,B) {
  a.names <- names(A)
  b.names <- names(B)
  all.names <- union(a.names,b.names)
  print(paste("Number of columns:",length(all.names)))
  a.type <- NULL
  for (i in 1:ncol(A)) {
    a.type[i] <- typeof(A[,i])
  }
  b.type <- NULL
  for (i in 1:ncol(B)) {
    b.type[i] <- typeof(B[,i])
  }
  a_b.names <- names(A)[!names(A)%in%names(B)]
  b_a.names <- names(B)[!names(B)%in%names(A)]
  if (length(a_b.names)>0 | length(b_a.names)>0){
    print("Columns in data frame A but not in data frame B:")
    print(a_b.names)
    print("Columns in data frame B but not in data frame A:")
    print(b_a.names)
  } else if(a.names==b.names & a.type==b.type){
    C <- rbind(A,B)
    return(C)
  }
  C <- list()
  for(i in 1:length(all.names)) {
    l.a <- all.names[i]%in%a.names
    pos.a <- match(all.names[i],a.names)
    typ.a <- a.type[pos.a]
    l.b <- all.names[i]%in%b.names
    pos.b <- match(all.names[i],b.names)
    typ.b <- b.type[pos.b]
    if(l.a & l.b) {
      if(typ.a==typ.b) {
        vec <- c(A[,pos.a],B[,pos.b])
      } else {
        warning(c("Type mismatch in variable named: ",all.names[i],"\n"))
        vec <- try(c(A[,pos.a],B[,pos.b]))
      }
    } else if (l.a) {
      vec <- c(A[,pos.a],rep(0,nrow(B)))
    } else {
      vec <- c(rep(0,nrow(A)),B[,pos.b])
    }
    C[[i]] <- vec
  }
  names(C) <- all.names
  C <- as.data.frame(C)
  return(C)
}
##############################################################################
#
#                 End Setup
#
##############################################################################

#Split data into tumor data and metastasis data
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
barplot(average_t, ylab= "Variant Frequency", names.arg=t_labels, axis.lty=3, space=0.5, cex.names=0.8, las=3, main="Primary Tumor");
dev.off();

#   Open a Cairo device to take your plotting output:
Cairo(file="${imgout:Metastasis_barplot.png}", type="png");
#  Plot:
barplot(average_m, ylab= "Variant Frequency", names.arg=m_labels, axis.lty=3, space=0.5, cex.names=0.8, las=3, main="Metastisis Tumor");
dev.off();

# Start creation of tumor vs metastasis plot. Main problem is having to make both vectors the same length
# Plan: Start with creating a single row data.frame with all the Tumor ones. Then, go through the column names in that data.frame, checking whether the column names from Metastasis exist or not, if not, add the column with a 0, if so, do nothing. Repeat for other one. Sort both alphabetically to make sure they line up correctly, then scatter plot it.

#Adds all primary tumor labels and values to the data.frame
tumor_data.frame <- data.frame(default = 0);
for( i in 1:length(t_labels)) {
  tumor_data.frame[, t_labels[i]] <- average_t[i];
}

# Now add the metastasis ones that do not exist in the tumor part
for ( i in 1:length(m_labels)) {
  if (m_labels[i] %in% colnames(tumor_data.frame)) {
    print("Overlap");
  } else {
    # If it exits in metastasis and not tumor, then tumor has a 0 for the mutation
    tumor_data.frame[, m_labels[i]] <- 0;
  }
}

print(tumor_data.frame);

#Same thing, now for metastasis first
#TODO: Make this a function
#Adds all primary metastasis labels and values to the data.frame
metastasis_data.frame <- data.frame(default = 0);
for( i in 1:length(m_labels)) {
  metastasis_data.frame[, m_labels[i]] <- average_m[i];
}

# Now add the tumor ones that do not exist in the metastasis part
for ( i in 1:length(t_labels)) {
  if (t_labels[i] %in% colnames(metastasis_data.frame)) {
    print("Overlap");
  } else {
    # If it exits in tumor and not metastasis, then metastasis has a 0 for the mutation
    metastasis_data.frame[, t_labels[i]] <- 0;
  }
}
print(metastasis_data.frame);

#Sort both so the order is the same and the points line up, not really matter the order
metastasis_data.frame <- metastasis_data.frame[,order(names(metastasis_data.frame))]
tumor_data.frame <- tumor_data.frame[,order(names(tumor_data.frame))]

#Convert points to vector to be plotted
tumor_scatterplot.data <- as.numeric(as.vector(tumor_data.frame[1,]))
metastasis_scatterplot.data <- as.numeric(as.vector(metastasis_data.frame[1,]))
#TODO If a gene exists in one, but not the other, create an entry in the other for that gene and add a zero, else continue


#   Open a Cairo device to take your plotting output:
Cairo(file="${imgout:Primary_Metastasis.png}", type="png");
#  Plot:
plot(tumor_scatterplot.data, metastasis_scatterplot.data, ylab= "Metastasis", xlab = "Primary", main="Primary Tumor");
dev.off();
