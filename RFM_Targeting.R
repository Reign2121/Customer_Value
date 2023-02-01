email_response = read.csv("email_response.csv")


df_full = left_join(df, email_response, by = "customer_id")

df_full %>% glimpse()

df_full %>% 
  group_by(seg_id) %>% 
  summarise(avg_rr_seg = mean(avg_email_open))

df_full %>% 
  group_by(seg_id) %>%
  summarise(Med_count = median(avg_email_open)) %>%
  arrange(desc(Med_count)) %>%
  head(.,10) %>%
  ggplot(aes(x = reorder(seg_id,- Med_count), y = Med_count)) +
  geom_bar(stat="identity")

# C = unit cost of mailing a catalog
C = 100  #(cost)


# m = profit contribution margin
m = 0.3  #(profit)

# E(Z) = average value of customer order
Z =  mean(df_full$Monetary)

# Break-even response rate: r > C/(m*E(Z))
break_even = C/(m*Z)  #손익분기점을 넘기는 지점
print(break_even)
# The number of customers you should target
sum(df_full$avg_email_open > break_even) #전체 203

####################
# Net contribution##
####################

# With RFM
df_full %>%
  mutate(unit_profit = Z*m*avg_email_open - C) %>%
  filter(avg_email_open > break_even) %>% 
  summarise(sum(unit_profit))

# Without RFM
df_full %>%
  mutate(unit_profit = Z*m*avg_email_open - C) %>%
  # filter(avg_email_open > break_even) %>% 
  summarise(sum(unit_profit))

#손익분기점을 넘는 고객들에게 마케팅 캠패인을 전개해야 한다.

###################
# Using ANOVA######
###################
# For simplicity, let's change segment_num = 3
#아노바에서 인터렉션 효과 표현하는 방법 ":"
seg.aov <- aov(avg_email_open ~ Recency_code*Frequency_code*Monetary_code, data=df_full)
#*표시를 하면 모든 조합을 보여준다. 개별+인터렉션
anova(seg.aov)

#아노바 연구가설: 최소 2 집단의 차이가 있다.

#그룹에 의한 차이를 보는 것이다.
seg.aov <- aov(avg_email_open ~ Recency_code*Frequency_code
               +Recency_code*Monetary_code
               +Frequency_code*Monetary_code, data=df_full)
anova(seg.aov)

###################
# Using Regression#  ##회귀분석
###################
seg.lm <- lm(avg_email_open ~ 
               Recency_code*Frequency_code
             +Recency_code*Monetary_code
             +Frequency_code*Monetary_code, data=df_full)
summary(seg.lm)

# Predict the response rate with a new data
RFM_combination = expand.grid(
  Recency_code = factor(seq(1,segment_num)),
  Frequency_code = factor(seq(1,segment_num)),
  Monetary_code = factor(seq(1,segment_num))
)

conf_interval <- predict(seg.lm, newdata=RFM_combination, interval="confidence",
                         level = 0.95)

pred_df = cbind(RFM_combination, conf_interval)
pred_df$seg = paste(pred_df$Recency_code,
                    pred_df$Frequency_code,
                    pred_df$Monetary_code, 
                    sep = "")

ggplot(pred_df, aes(x = reorder(seg, fit),
                    y = fit, 
                    ymin = lwr, 
                    ymax = upr)) +
  geom_pointrange() + 
  ylab("Predicted Response Rate") +
  xlab("RFM Segments") +
  ggtitle("Predicted Response Rates by RFM segments")
