##########################################################
# author: Ignacio Sarmiento-Barbieri
#
##########################################################

#Clean the workspace
rm(list=ls())
cat("\014")
local({r <- getOption("repos"); r["CRAN"] <- "http://cran.r-project.org"; options(repos=r)}) #set repo



#Load Packages
pkg<-list("tidyverse","ggplot2")
lapply(pkg, require, character.only=T)
rm(pkg)


#Set WD local
setwd("~/Dropbox/Teaching/2021/Surcolombiana/Lectures/Lecture03")

set.seed(1010101)

x1<-runif(1000)


#beta<-db$beta[1]
#lambda<-db$lambda[1]
y1<- x1 


# res<-summary(lm(y~x1))
# ssr<-sum(res$residuals^2)

Lasso_iki<-function(B,L,y=y1,x=x1,u=u1){
  
  if(B>=0){
    R<-sum((y-x*B)^2) + L*B
  }else if(B<0){
    R<-sum((y-x*B)^2) - L*B
  }
  R
}


db<-expand.grid(lambda=c(0,100,300,500,2*sum(y1*x1),800,1000),beta=seq(-1,2,.2))



db$L<-NA
for(i in 1:dim(db)[1]){
  db$L[i]<-Lasso_iki(db$beta[i],db$lambda[i])
}

db <- db %>% group_by(lambda) %>% mutate(min_point=min(L)) %>% ungroup()

db <- db %>%  mutate(min_beta=ifelse(L==min_point,beta,NA))

#db$L<-db$L/max(db$L,na.rm=TRUE)
db$lambda<-as.factor(db$lambda)
db$group<-"other"
db$group[db$lambda==0]<-"MCO"
db$group[db$lambda==2*sum(y1*x1)]<-"Max Lambda"

ggplot(data=db,aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("red","black","gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso_final.pdf",width = 6,height = 4)



ggplot(data=db %>% filter(group=="MCO"),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  #geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso0.pdf",width = 6,height = 4)

#Plot1
ggplot(data=db %>% filter(group=="MCO"),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso1.pdf",width = 6,height = 4)


#Plot2
ggplot(data=db %>% filter(lambda%in%c(0,100)),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("black","gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso2.pdf",width = 6,height = 4)

#Plot3
ggplot(data=db %>% filter(lambda%in%c(0,100,300)),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("black","gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso3.pdf",width = 6,height = 4)

#Plot4
ggplot(data=db %>% filter(lambda%in%c(0,100,300,500)),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("black","gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso4.pdf",width = 6,height = 4)

#Plot5
ggplot(data=db %>% filter(lambda%in%c(0,100,300,500)| group=="Max Lambda"),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("gray","black","gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso5.pdf",width = 6,height = 4)


#Plot6
ggplot(data=db %>% filter(lambda%in%c(0,100,300,500)| group=="Max Lambda"),aes(x=beta,y=L,group=lambda,col=group))+
  geom_vline(aes(xintercept=0), col="gray",lty="dashed") +
  geom_line() +
  geom_point(aes(x=min_beta,y=L,col=group)) +
  xlab(expression(beta)) + 
  ylab("")+
  ylim(-500,2600) +
  theme_bw() +
  scale_colour_manual(values=c("red","black","gray")) +
  theme(legend.title= element_blank() ,
        legend.position="none",
        legend.direction="horizontal",
        legend.box="horizontal",
        legend.box.just = c("top"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill='transparent'),
        rect = element_rect(colour = "transparent", fill = "white"),
        plot.margin = unit(c(2,3.5,1,1), "lines")) 
ggsave("figures/lasso6.pdf",width = 6,height = 4)
