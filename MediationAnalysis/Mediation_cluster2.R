rm(list=ls())
library(readxl)
library(lavaan)
library(semTools)
library(openxlsx)
library(extrafont)
font_import(pattern = "Arial")
loadfonts(device = "all")

setwd("/Users/yangwuyue/Downloads/review") 
Data <- read_excel("/Users/yangwuyue/Downloads/review/Data_log10_cluster2.xlsx")
Data[, -1] <- lapply(Data[, -1], function(col) col - mean(col, na.rm = TRUE))
covid <- Data
colnames(covid)[colnames(covid) == "Internalmovement"] <- "x1"
colnames(covid)[colnames(covid) == "Publicevents"] <- "x2"
colnames(covid)[colnames(covid) == "Schoolsclosures"] <- "x3"
colnames(covid)[colnames(covid) == "Publicgatherings"] <- "x4"
colnames(covid)[colnames(covid) == "Stayathomerestrictions"] <- "x5"
colnames(covid)[colnames(covid) == "Publictransport"] <- "x6"
colnames(covid)[colnames(covid) == "Workplacesclosures"] <- "x7"
#colnames(covid)[colnames(covid) == "Publicinformationcampaigns"] <- "x8"
colnames(covid)[colnames(covid) == "Personalprotection"] <- "x9"
colnames(covid)[colnames(covid) == "Internationaltravelcontrols"] <- "x10"
colnames(covid)[colnames(covid) == "Incomesupport"] <- "x11"
colnames(covid)[colnames(covid) == "Testingpolicy"] <- "x12"
colnames(covid)[colnames(covid) == "Contacttracing"] <- "x13"
colnames(covid)[colnames(covid) == "Suspectedcase"] <- "x14"
#colnames(covid)[colnames(covid) == "Detectionandtreatment"] <- "x15"
colnames(covid)[colnames(covid) == "Medicalresources"] <- "x16"
colnames(covid)[colnames(covid) == "alpha"] <- "M1"
colnames(covid)[colnames(covid) == "beta"] <- "M2"
colnames(covid)[colnames(covid) == "delta"] <- "M3"
colnames(covid)[colnames(covid) == "lambda"] <- "M4"
colnames(covid)[colnames(covid) == "kappa"] <- "M5"
colnames(covid)[colnames(covid) == "Spreading_rate"] <- "Y"


model <- '
  Z1 =~ x1+x2+x3+x4+x5+x6+x7+x9+x10
  Z2 =~ x11 + x12 + x13
  Z3 =~ x14 
  Z4 =~ x16

  # ?н?ЧӦ
  M1 ~ a1*Z1 + a2*Z2 + a3*Z3 + a4*Z4
  M2 ~ b1*Z1 + b2*Z2 + b3*Z3 + b4*Z4
  M3 ~ d1*Z1 + d2*Z2 + d3*Z3 + d4*Z4
  M4 ~ l1*Z1 + l2*Z2 + l3*Z3 + l4*Z4
  M5 ~ k1*Z1 + k2*Z2 + k3*Z3 + k4*Z4

  # ֱ??????Q100
  #Q100 ~ 

  # ????????
  Y ~ m1*M1 + m2*M2 + m3*M3 + m4*M4 + m5*M5 + c1*Z1 + c2*Z2 + c3*Z3 + c4*Z4

  indirect_alpha_Z1 := a1*m1
  indirect_alpha_Z2 := a2*m1
  indirect_alpha_Z3 := a3*m1
  indirect_alpha_Z4 := a4*m1

  indirect_beta_Z1 := b1*m2
  indirect_beta_Z2 := b2*m2
  indirect_beta_Z3 := b3*m2
  indirect_beta_Z4 := b4*m2

  indirect_delta_Z1 := d1*m3
  indirect_delta_Z2 := d2*m3
  indirect_delta_Z3 := d3*m3
  indirect_delta_Z4 := d4*m3

  indirect_lambda_Z1 := l1*m4
  indirect_lambda_Z2 := l2*m4
  indirect_lambda_Z3 := l3*m4
  indirect_lambda_Z4 := l4*m4

  indirect_kappa_Z1 := k1*m5
  indirect_kappa_Z2 := k2*m5
  indirect_kappa_Z3 := k3*m5
  indirect_kappa_Z4 := k4*m5
  
  
  indirect_Z1_suoyouM_Y6 := a1*m1 + b1*m2 + d1*m3 + l1*m4 + k1*m5
  indirect_Z2_suoyouM_Y6 := a2*m1 + b2*m2 + d2*m3 + l2*m4 + k2*m5
  indirect_Z3_suoyouM_Y6 := a3*m1 + b3*m2 + d3*m3 + l3*m4 + k3*m5
  indirect_Z4_suoyouM_Y6 := a4*m1 + b4*m2 + d4*m3 + l4*m4 + k4*m5

  indirect_suoyouZ_M1_Y6 := a1*m1 + a2*m1 + a3*m1 + a4*m1
  indirect_suoyouZ_M2_Y6 := b1*m2 + b2*m2 + b3*m2 + b4*m2
  indirect_suoyouZ_M3_Y6 := d1*m3 + d2*m3 + d3*m3 + d4*m3
  indirect_suoyouZ_M4_Y6 := l1*m4 + l2*m4 + l3*m4 + l4*m4
  indirect_suoyouZ_M5_Y6 := k1*m5 + k2*m5 + k3*m5 + k4*m5
  
  # ?ܼ???Ӱ??
  total_indirect := indirect_alpha_Z1 + indirect_alpha_Z2 + indirect_alpha_Z3 + indirect_alpha_Z4 +
  indirect_beta_Z1 + indirect_beta_Z2 + indirect_beta_Z3 + indirect_beta_Z4 +
  indirect_delta_Z1 + indirect_delta_Z2 + indirect_delta_Z3 + indirect_delta_Z4 +
  indirect_lambda_Z1 + indirect_lambda_Z2 + indirect_lambda_Z3 + indirect_lambda_Z4 +
  indirect_kappa_Z1 + indirect_kappa_Z2 + indirect_kappa_Z3 + indirect_kappa_Z4
  
  # ??ЧӦ
  total_effect := c1 + c2 + c3 + c4 + total_indirect
'

#fit <- sem(model, data = covid, se = 'bootstrap',bootstrap = 1000, optim.method = "BFGS", verbose = TRUE)
fit <- sem(model, data = covid, se = 'bootstrap', bootstrap = 1000, optim.method = "BFGS", check.gradient = FALSE, verbose = TRUE)
resull <- summary(fit, standardized = T, rsquare = T)
results<-parameterEstimates(fit)

write.csv(results, file = "Spreading_rate_cluster2.csv", row.names = FALSE)
save(fit, file = "Spreading_rate_cluster2.RData")
load("Spreading_rate_cluster2.RData")
##plot
library(semPlot) 
# Incomesupport + Testingpolicy + Contacttracing
# Suspectedcase + Detectionandtreatment

png("Spreading_rate_cluster2.png", width=20, height=20, units="in", res=300)
par(family="Arial")
semPaths(fit, what = "Estimate", style = "lisrel" ,edge.width = 2, node.width = 1.1, edge.label.cex = 0.6)
dev.off()

#dev.copy(png, "Spreading_rate_0813.png")
#semPaths(fit, what = "std", fixedStyle = "reg", freeStyle = "auto")
