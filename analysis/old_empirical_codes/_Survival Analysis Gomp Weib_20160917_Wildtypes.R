
library(varhandle)
library('flexsurv')

new_rls<-read.csv("rls 2016-08-02.csv")


my.data=new_rls

#my.data<-my.data[complete.cases(my.data$ref_lifespan_mean),]

big_data<-my.data[!duplicated(my.data$ref_lifespans),] 

#you uniquely determine the ref_lifespans of each experiments individually
big_data= big_data[!is.na(big_data[,26]), ]

#big_data = big_data[complete.cases(big_data$ref_lifespan_mean),]
for (k in 1:length(sort(big_data$ref_lifespans))){
  
f1<-big_data$ref_lifespans
f<-unfactor(f1[k])
ref_lifespan_single<-as.numeric(unlist(strsplit(f, ",")))

avg.ref.ls<-round(mean(c(ref_lifespan_single)))
x<-big_data$id
ref_lifespan_mean<-round(big_data$ref_lifespan_mean[k])
if (avg.ref.ls==ref_lifespan_mean){
  message("mean is correct at id ",x[k])
} else {
  message("mean is wrong at id ",x[k])
}

}




fit_names = c( 'genotype','media','mat','sd.ls','medianLS','Delta_LL','AvgLS','gompLogLik','gompRate','gompShape','weibLogLik','weibScale','weibShape')
fit = data.frame(matrix(, nrow=length(fit_names), ncol=length(fit_names))) #set up a skeleton table
names(fit) = c( "genotype","media","mat","sd.ls","medianLS","Delta_LL","AvgLS","gompLoglik","gompRate","gompShape","weibLogLik","weibScale","weibShape")



for (genotype_in in c(1:length(big_data$ref_name))){
  
  #genotype=117
  
  lifespansChar_set<-big_data$set_lifespans
  lifespansChar_set1<-unfactor(lifespansChar_set[genotype_in])
  lifespansTemp_set =as.numeric(unlist(strsplit(lifespansChar_set1, ",")))
  
  
  
  lifespansChar_ref<-big_data$ref_lifespans
  lifespansChar_ref1<-unfactor(lifespansChar_ref[genotype_in])
  lifespansTemp_ref =as.numeric(unlist(strsplit(lifespansChar_ref1, ",")))
  
  lifespansTemp<-c(lifespansTemp_set,lifespansTemp_ref)             
                       
  
  lifespansTemp[lifespansTemp < 0] <- 0
  lifespansTemp <-floor(lifespansTemp+0.5)
  lifespansTemp <- lifespansTemp[ lifespansTemp != 0 ]
  
  lifespanGomp = flexsurvreg(formula = Surv(lifespansTemp) ~ 1, dist = 'gompertz') ### Use the flexsurvreg package to fit lifespan data to gompertz or weibull distribution
  lifespanWeib = flexsurvreg(formula = Surv(lifespansTemp) ~ 1, dist = 'weibull')  
  
  ### Fill in added columns in the controlConditions table with data from gompertz and weibull fitting. Columns are named according to respective variables
  media<-big_data$ref_media
  media=unfactor(media[genotype_in])
  mat<-big_data$ref_mating_type
  mat=unfactor(mat[genotype_in])
  avgLS = mean(lifespansTemp)
  StddevLS = sd(lifespansTemp)
  medianLS = median(lifespansTemp)
  gompShape = lifespanGomp$res[1,1]
  gompRate = lifespanGomp$res[2,1]
  gompLogLik = lifespanGomp$loglik
  gompAIC = lifespanGomp$AIC
  
  weibShape = lifespanWeib$res[1,1]
  weibScale = lifespanWeib$res[2,1]
  weibLogLik = lifespanWeib$loglik
  weibAIC = lifespanWeib$AIC   
  
  delta_LL = lifespanWeib$loglik- lifespanGomp$loglik
  
  genotype<-big_data$ref_name
  
  genotype=unfactor(genotype[genotype_in])
  
  #fit_names = c( 'sd.ls','current.seed','i','medianLS','Delta_LL','AvgLS','gompLogLik','gompRate','gompShape','weibLogLik','weibScale','weibShape')
  
  fit = rbind(fit,c(genotype,media,mat,StddevLS,medianLS,delta_LL,avgLS,gompLogLik,gompRate,gompShape,weibLogLik,weibScale,weibShape))
  #write.csv(fit, file="Results.csv", row.names=F)
  #names(fit) = c( "genotype","media","mat","sd.ls","medianLS","Delta_LL","AvgLS","gompLoglik","gompRate","gompShape","weibLogLik","weibScale","weibShape")
  
  
  #fit= fit[!is.na(fit[,1]), ]
  
}

new_fit<-fit[14:130,]

#hist(new_fit$avgLS)




WT.BY4742<- new_fit[new_fit$genotype=="BY4742",]



#WT.BY4742.temp<-WT.BY4742[WT.BY4742$temp==30,]
WT.BY4742.media<-WT.BY4742[WT.BY4742$media=="YPD",]

pdf(paste("plots/", "Histogram_empirical_data_WT_BY4742.pdf", sep=''))
par(mfrow=c(3,1)) 
hist(as.numeric(WT.BY4742.media$AvgLS),xlab="Mean Lifespan",main="Wild type: BY4742",
     breaks=length(as.numeric(WT.BY4742.media$AvgLS)),col="gray",xlim=c(10,40),ylim=c(0,10))


hist(as.numeric(WT.BY4742.media$gompShape),xlab="G shape parameters",main="",
     breaks=length(as.numeric(WT.BY4742.media$gompShape)),col="blue",xlim=c(0,0.16),ylim=c(0,8))

hist(as.numeric(WT.BY4742.media$gompRate),xlab="R rate parameters",main="",
     breaks=length(as.numeric(WT.BY4742.media$gompRate)),col="green",xlim=c(0,0.07),ylim=c(0,13))
dev.off()


WT.BY4741<- new_fit[new_fit$genotype=="BY4741",]



#WT.BY4742.temp<-WT.BY4742[WT.BY4742$temp==30,]
WT.BY4741.media<-WT.BY4741[WT.BY4741$media=="YPD",]

pdf(paste("plots/", "Histogram_empirical_data_WT_BY4741.pdf", sep=''))
par(mfrow=c(3,1)) 
hist(as.numeric(WT.BY4741.media$AvgLS),xlab="Mean Lifespan",main="Wild type: BY4741",
     breaks=length(as.numeric(WT.BY4741.media$AvgLS)),col="gray",xlim=c(20,35),ylim=c(0,6))


hist(as.numeric(WT.BY4741.media$gompShape),xlab="G shape parameters",main="",
     breaks=length(as.numeric(WT.BY4741.media$gompShape)),col="blue",xlim=c(0.05,0.15),ylim=c(0,4))

hist(as.numeric(WT.BY4741.media$gompRate),xlab="R rate parameters",main="",
     breaks=length(as.numeric(WT.BY4741.media$gompRate)),col="green",xlim=c(0,0.02),ylim=c(0,4))
dev.off()


WT.BY4743<- new_fit[new_fit$genotype=="BY4743",]

WT.BY4743.media<-WT.BY4743[WT.BY4743$media=="YPD",]

pdf(paste("plots/", "Histogram_empirical_data_WT_BY4743.pdf", sep=''))
par(mfrow=c(3,1)) 
hist(as.numeric(WT.BY4743.media$AvgLS),xlab="Mean Lifespan",main="Wild type: BY4741",
     breaks=length(as.numeric(WT.BY4743.media$AvgLS)),col="gray",xlim=c(20,50),ylim=c(0,4))


hist(as.numeric(WT.BY4743.media$gompShape),xlab="G shape parameters",main="",
     breaks=length(as.numeric(WT.BY4743.media$gompShape)),col="blue",xlim=c(0.05,0.12),ylim=c(0,4))

hist(as.numeric(WT.BY4743.media$gompRate),xlab="R rate parameters",main="",
     breaks=length(as.numeric(WT.BY4743.media$gompRate)),col="green",xlim=c(0,0.005),ylim=c(0,4))
dev.off()




