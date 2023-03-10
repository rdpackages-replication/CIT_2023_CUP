#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
# A Practical Introduction to Regression Discontinuity Designs: Extensions
# Authors: Matias D. Cattaneo, Nicolás Idrobo and Rocío Titiunik
# Last update: 2023-01-21
#------------------------------------------------------------------------------#
# SOFTWARE WEBSITE: https://rdpackages.github.io/
#------------------------------------------------------------------------------#
# TO INSTALL/DOWNLOAD R PACKAGES/FUNCTIONS:
# install.packages('lpdensity')
# install.packages('rddensity')
# install.packages('rdlocrand')
# install.packages('rdrobust')
# install.packages('rdmulti')
# install.packages('foreign')
# install.packages('ggplot2')
# install.packages('grid')
# install.packages('TeachingDemos')
# install.packages('geosphere')
# install.packages('tidyverse')
# install.packages('sf')
# install.packages('USAboundaries')
#------------------------------------------------------------------------------#

###########################################################
###########################################################
###########################################################
######### Section 5: Multi-Dimensional RD Designs #########
######### Non-Geographic Empirical Application    #########
###########################################################
###########################################################
###########################################################

# Cleaning the R environment
rm(list=ls())

# Loading packages
library(foreign)
library(ggplot2)
library(lpdensity)
library(rddensity)
library(rdrobust)
library(rdlocrand)
library(TeachingDemos)
library(rdmulti)
library(geosphere)
library(tidyverse)
library(sf)
library(USAboundaries)

#------------------#
# Loading the data #
#------------------#
data <- read.dta("CIT_2023_CUP_multicutoff.dta")

#----------------------------------------#
# Figure 5.4                             #
# Panel a: rdplot on one cutoff          #
# Panel b: rdmcplot on the three cutoffs #
#----------------------------------------#
# Panel a
pdf("outputs/Vol-2-R_LRS_rdplot_cutoff1.pdf")
  rdplot(data$spadies_any[data$cutoff == -57.21], 
         data$sisben_score[data$cutoff == -57.21],
         c = -57.21, p = 1, title = "", x.label = "Distance to SISBEN cutoff",
         y.label = "Immediate access in any HEI")
dev.off()

#-----#
# Panel b

# Creating smaller data frames, one for each cutoff
data.cut1 <- data[data$cutoff == -57.21,]
data.cut2 <- data[data$cutoff == -56.32,]
data.cut3 <- data[data$cutoff == -40.75,]

# Calling rdplot on each cutoff and extracting the optimal number of bins
out <- rdplot(data.cut1$spadies_any, data.cut1$sisben_score, 
              p = 1, c = -57.21, binselect = "esmv")
bins.cut1 <- ceiling(out$J / 2)

out <- rdplot(data.cut2$spadies_any, data.cut2$sisben_score, 
              p = 1, c = -56.32, binselect = "esmv")
bins.cut2 <- ceiling(out$J / 2)

out <- rdplot(data.cut3$spadies_any, data.cut3$sisben_score, 
              p = 1, c = -40.75, binselect = "esmv")
bins.cut3 <- ceiling(out$J / 2)

# Calling rdmcplot and using the number of bins defined above
aux <- rdmcplot(data$spadies_any, data$sisben_score, data$cutoff, 
                pvec = c(1, 1, 1), binselectvec = c("esmv", "esmv", "esmv"), 
                nbinsmat = rbind(bins.cut1, bins.cut2, bins.cut3))

# Deafult plot
aux$rdmc_plot

# The rest of the code in this Figure 5.4b illustrates how to create the
# plot by hand, using the outputs from rdmcplot. This is useful in case
# the user wants to customize the plot even further.

# Extracting the variables created by rdmcplot
Xmean <- aux$Xmean
Ymean <- aux$Ymean
X0 <- aux$X0
X1 <- aux$X1
Yhat0 <- aux$Yhat0
Yhat1 <- aux$Yhat1

# Starting the plot
rdmc_plot <- ggplot() + theme_bw() + 
  labs(x = "Distance to SISBEN cutoff", y = "Immediate access to any HEI")

# Adding the first cutoff: -57.21
rdmc_plot <- rdmc_plot + geom_point(aes(x = Xmean[, 1], y = Ymean[, 1]), col = "blue4", na.rm = TRUE) +
  geom_line(aes(x = X0[, 1], y = Yhat0[, 1]), col = "blue4", linetype = 1, na.rm = TRUE, size = 1) +
  geom_line(aes(x = X1[, 1], y = Yhat1[, 1]), col = "blue4", linetype = 1, na.rm = TRUE, size = 1) +
  geom_vline(xintercept = -57.21, col = "blue4", linetype = "dashed", size = 1)
rdmc_plot

# Adding the second cutoff: -56.32
rdmc_plot <- rdmc_plot + geom_point(aes(x = Xmean[, 2], y = Ymean[, 2]), col = "red4", shape = 0, na.rm = TRUE) +
  geom_line(aes(x = X0[, 2], y = Yhat0[, 2]), col = "red4", linetype = 1, na.rm = TRUE, size = 1) +
  geom_line(aes(x = X1[, 2], y = Yhat1[,2]), col = "red4", linetype = 1, na.rm = TRUE, size = 1) +
  geom_vline(xintercept = -56.32, col = "red4", linetype = "dashed", size = 1)
rdmc_plot

# Adding the third cutoff: -40.75
rdmc_plot <- rdmc_plot + geom_point(aes(x = Xmean[, 3], y = Ymean[, 3]), col = "darkgreen", shape = 2, na.rm = TRUE) +
  geom_line(aes(x = X0[, 3], y = Yhat0[, 3]), col = "darkgreen", linetype = 1, na.rm = TRUE, size = 1) +
  geom_line(aes(x = X1[, 3], y = Yhat1[, 3]), col = "darkgreen", linetype = 1, na.rm = TRUE, size = 1) +
  geom_vline(xintercept = -40.75, col = "darkgreen", linetype = "dashed", size = 1)
rdmc_plot
ggsave("outputs/Vol-2-R_LRS_rdmcplot.pdf", plot = rdmc_plot, width = 5.7, height = 5.5, units = "in")

#-------------------------#
# Snippet 5.1             #
# rdrobust using cutoff 1 #
#-------------------------#
txtStart("outputs/Vol-2-R_LRS_rdrobust_cutoff1.txt", commands = TRUE, 
         results = TRUE, append = FALSE, visible.only = TRUE)
  out <- rdrobust(data$spadies_any[data$cutoff == -57.21], 
                  data$sisben_score[data$cutoff == -57.21], c = -57.21)
  summary(out)
txtStop()

#----------------------------------#
# Snippet 5.2                      #
# Using rdmc and the three cutoffs #
#----------------------------------#
txtStart("outputs/Vol-2-R_LRS_rdmc.txt", commands = TRUE, 
         results = TRUE, append = FALSE, visible.only = TRUE)
  out <- rdmc(data$spadies_any, data$sisben_score, data$cutoff)
txtStop()

#----------------------------------------#
# Snippet 5.3                            #
# Using rdrobust with a normalized score #
#----------------------------------------#
txtStart("outputs/Vol-2-R_LRS_rdrobust_pooled_xnorm.txt", commands = TRUE, 
         results = TRUE, append = FALSE, visible.only = TRUE)
  data$xnorm <- NA
  data$xnorm[data$sisben_area == "Main metro area"] <- 
    data$sisben_score[data$sisben_area == "Main metro area"] + 57.21
  data$xnorm[data$sisben_area == "Other urban area"] <- 
    data$sisben_score[data$sisben_area == "Other urban area"] + 56.32
  data$xnorm[data$sisben_area == "Rural area"] <- 
    data$sisben_score[data$sisben_area == "Rural area"] + 40.75
  out <- rdrobust(data$spadies_any, data$xnorm, c=0)
  summary(out)
txtStop()

#------------------------------------------#
# Snippet 5.4                              #
# Using rdmc and understanding its outputs #
#------------------------------------------#
txtStart("outputs/Vol-2-R_LRS_rdmc_row_weightedresults.txt", commands = TRUE, 
         results = TRUE, append = FALSE, visible.only = TRUE)
  out <- rdmc(data$spadies_any, data$sisben_score, data$cutoff) 
  names(out)
  print(out$Coefs)
  print(out$W)
  print(out$Coefs[1,1] * out$W[1,1] +
          out$Coefs[1,2] * out$W[1,2] +
          out$Coefs[1,3] * out$W[1,3])
txtStop()

#--------------------------------------------------------------------#
# Snippet 5.5                                                        #
# Formally testing the difference between the effects at the cutoffs #
#--------------------------------------------------------------------#
txtStart("outputs/Vol-2-R_LRS_rdmc_comparing_effects.txt", commands = TRUE, 
         results = TRUE, append = FALSE, visible.only = TRUE)
  out <- rdmc(data$spadies_any, data$sisben_score, data$cutoff)
  dif <- out$B[1,1] - out$B[1,2]
  print(paste("The difference is ", round(dif,3)))
  dif_se <- sqrt( out$V[1,1] + out$V[1,2] )
  print(paste("The standard error of the difference is ", round(dif_se,3)))
  zstat <- dif / dif_se
  print(paste("The z-statistic is ", round(zstat,3)))
  pval <- 2 * pnorm(-abs(zstat))
  print(paste("The associated p-value is ", round(pval,3)))
txtStop()
