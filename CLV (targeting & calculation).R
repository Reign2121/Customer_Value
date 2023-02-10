########
#rfm
#손익분기점
setwd("/Users/reign/Downloads") #set your working directory
install.packages("rfm")
library(dplyr)
library(ggplot2)
library(rfm)
df = read.csv("purch_behavior.csv") #read data

#데이터 개요
df %>%
  glimpse

#명목형 변수 변환
df$married = as.factor(df$married)
df$loyalty_card = as.factor(df$loyalty_card)
df$purchase = as.factor(df$purchase)

colnames(df)


# EDA (기술통계 + 시각화)
df %>%
  group_by(customer_id)
  ggplot(df,aes(married,revenue, fill = purchase))+
  geom_bar(width = 0.5, stat="identity",position = "stack")

df %>%
  group_by(customer_id)
  ggplot(df,aes(x = loyalty_card, y = revenue, fill = purchase))+
  geom_bar(width=0.5, stat="identity", position = "stack")

df %>%
  group_by(customer_id)
  ggplot(df, aes(x=number_of_orders, y=revenue, fill = purchase, colour = purchase))+
  geom_point(shape=15, size=2)

#check the correlation
cor(df$revenue,df$number_of_orders) #positive

#cor.test
cor.test(df$revenue,df$income)
cor.test(df$revenue,df$number_of_orders) #매우 강한 상관관계가 존재한다.

mean(df$revenue)
mean(df$number_of_orders)
mean(df$income)  

# 손익분기점 넘는 구매율 break-even point!!
C=27.2 #COST
M = (40-27.2)/40 #PCM(margin)
ez = mean(df$revenue)
break_even = C/(M*ez) #break-even #손익분기점 구매율
break_even


#########구매율 추정###########

#df2$purchase = as.factor(df2$purchase) #명목형 변환
#df2$married = as.factor(df2$married)
#df2$loyalty_card = as.factor(df2$loyalty_card)


#응답률 예측 모델 개발
#logistic regression
df = df[,-9] #zip_code(불필요한 변수) 제거
logitm <- glm(df$purchase ~ ., #우선 모든 변수들을 넣는다.
              family = binomial, data = df)
summary(logitm) 


library(MASS)  #단계적 변수 선택
logitNew <- step(logitm, direction="both") 
summary(logitNew) #채택

coefsexp <- exp(coef(logitNew))#자연수 함수
coefsexp


#predicted purchase rate
df$predict = predict(logitNew, type = "response", na.action = TRUE)


#### set the target ####

break_even  #break-even point (rate)
sum(df$predict > break_even) #2529명


####캠페인 기대효과#####

# non-targeting simulation

df %>%
  mutate(exp_profit = ez*M*predict - C) %>%
  #filter(predict > break_even) %>%
  summarise(sum(exp_profit))

df$exp_profit = ez*M*df$predict - C


# targeting simulation

df %>%
  mutate(exp_profit = ez*M*predict - C) %>%
  filter(predict > break_even) %>% 
  summarise(sum(exp_profit))


df_target = subset(df, df$predict > break_even) #새 데이터프레임에 담기

df_target$exp_profit = ez*M*df_target$predict - C



###compare it! 
#it is effect of targeting
sum(df$exp_profit)
sum(df_target$exp_profit)


# t-test로 두 수익의 평균차이 유효성 검증
t.test(df_target$exp_profit,df$exp_profit) #21.386068 - 6.772261 = 14.61381

21.386068 - (-6.772261)
#통계적으로 유효한 차이 존재!!



########CLV calculation###########
df2 = df[,1:8] #초기 데이터로 피팅, 
# 변수들간 독립성을 보장하고 초기 변수들의 순수 영향력을 알아보기 위함

##non - targeting##
clvm1 = lm(df2$revenue ~ ., data = df2)
summary(clvm1)
new_model1 = step(clvm1, direction="both") #단계적 선택법 이용

df2$pred <- predict(new_model1, data = df2)


#계산
discountR = 0.1
df2$predict = predict(logitNew, type = "response", na.action = TRUE) #응답률 다시 추가
churnR = (1 - df2$predict) #강의자료에 쓰인대로 가자
df2$churnR = churnR

df2$clvs = (1+discountR)*mean(df2$revenue)/(discountR+churnR) #미래가치 예측
df2$customer_id[sort(df2$clvs, decreasing = T)]
sum(df2$clvs)
mean(df2$clvs)


##targeting##
df2_target = df_target[,1:8]#초기 데이터로 피팅, 
# 변수들간 독립성을 보장하고 초기 변수들의 순수 영향력을 알아보기 위함
clvm2 = lm(df2_target$revenue ~ ., data = df2_target)
summary(clvm2)
new_model2 = step(clvm2, direction="both")
pred2 <- predict(new_model2, data = df2_target)
summary(new_model2)


discountR = 0.1
#원상 복구(응답률 필요)
df2_target = subset(df, df$predict > break_even)
churnR2 = 1-(df2_target$predict)
#churnR2 = (1- df2_target$predict)
#df2_target$churnR2 = churnR2

df2_target$clvs = (1+discountR)*mean(df2_target$revenue)/(discountR+churnR2)
sum(df2_target$clvs)
mean(df2_target$clvs)


#평균차이 유효성 검정
t.test(df2_target$clvs,df2$clvs) #유효함!
1439.8347 - 462.1931 
