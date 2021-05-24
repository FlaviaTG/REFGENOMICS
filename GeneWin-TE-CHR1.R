library(GenWin)
data <- read.table("repeatmasker-ouput_coverage.tab")
#subset per Chr in this case is first CHR1, the name is the same as in the .tab file
Z <- subset(data,V1 == "CHR1")
fstsubset<-Z[complete.cases(Z),]
Y <- Z$V8
map <- Z$V2
#give variables
png("spline-Wstat-TE-proportion-CHR1.png")
ZW <- splineAnalyze(Y, map, plotRaw = T, smoothness = 100, plotWindows = T, method = 3)
dev.off()
#
R <- as.data.frame(ZW$windowData)
write.table(R,"CHR1-TE-proportion-GeneWin.txt", quote=F,row=F)
