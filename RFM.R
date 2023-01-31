# Data generation
setwd("/Users/reign/Downloads")
install.packages("rfm")
library(dplyr)
library(ggplot2)
library(rfm)

rfm_data_orders %>%
  arrange(customer_id, order_date)

# Create Recency
df = rfm_data_orders %>%
  group_by(customer_id) %>%
  arrange(order_date) %>%
  filter(n()>1)%>%
  mutate(Recency = difftime(order_date, 
                            lag(order_date, n = 1), 
                            units = "days") ) %>%
  ungroup()


# Create Frequency & Monetary
df = df %>% 
  group_by(customer_id) %>%
  summarise(Recency = mean(as.numeric(Recency), na.rm = T), #결측치 제거하기
            Frequency = n(),#개수 합
            # Monetary = mean(revenue)
            Monetary = sum(revenue))

df %>% glimpse()


# Assign codes for each variable
# Check out: cut_interval, cut_number, cut_width

segment_num =3 
df = df %>% #cut_number: 그룹으로 나누는 함수다. 
  mutate(Recency_code = cut_number(Recency, n = segment_num, labels = seq(segment_num, 1)), #(최소, 최대) #작을수록 상위
         Frequency_code = cut_number(Frequency, n = segment_num, labels = seq(1,segment_num)), # 반대인지 check
         Monetary_code = cut_number(Monetary, n = segment_num, labels = seq(1,segment_num))) #F와 M은 클수록 상위

df %>% glimpse()

# Scoring the response rate of each group
df = df %>%
  group_by(Recency_code, Frequency_code, Monetary_code) %>% 
  #mutate(seg_id = cur_group_id()) %>%
  mutate(seg_id = paste(Recency_code, Frequency_code, Monetary_code, sep = "")) %>%   
  ungroup() #묶어서 연산 후 다시 풀기

df %>% count(seg_id) #그룹 나누기 



###############
# Visualizing##
###############

# heatmap
df = df %>%
  mutate(Recency_code = factor(Recency_code, levels = seq(1, segment_num)))

ggplot(df, aes(x = Frequency_code, y = Recency_code, fill = Monetary)) +
  geom_tile() +
  scale_fill_distiller(palette = "Blues", direction = 1)

# barchart
df %>% 
  group_by(seg_id) %>%
  summarise(Med_count = median(Recency)) %>%
  arrange(Med_count) %>%
  head() %>%
  ggplot(aes(x = reorder(seg_id, Med_count), y = Med_count)) +
  geom_bar(stat="identity")


df %>% 
  group_by(seg_id) %>%
  summarise(Med_count = median(Frequency)) %>%
  arrange(desc(Med_count)) %>%
  head() %>%
  ggplot(aes(x = reorder(seg_id, -Med_count), y = Med_count)) +
  geom_bar(stat="identity")


df %>% 
  group_by(seg_id) %>%
  summarise(Med_count = median(Monetary)) %>%
  arrange(desc(Med_count)) %>%
  head() %>%
  ggplot(aes(x = reorder(seg_id, -Med_count), y = Med_count)) +
  geom_bar(stat="identity")


ggplot(df, aes(Monetary_code)) +
  geom_bar(stat = "count", colour="white") +
  facet_grid(Recency_code ~ Frequency_code)


# Using rfm package tool
rfm_result <- rfm_table_order(
  data = rfm_data_orders,
  customer_id = customer_id,
  revenue = revenue,
  order_date = order_date,
  analysis_date = as.Date("2012/01/01")
)
rfm_heatmap(rfm_result) 
rfm_bar_chart(rfm_result)  
rfm_rm_plot(rfm_result) 
rfm_fm_plot(rfm_result) 
rfm_rf_plot(rfm_result) 

