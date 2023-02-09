## Evaluating customer value

고겍가치를 평가하는 일은 매우 중요합니다.

1. 효율적인 자원 투입

효율적인 운영은 한정된 자원을 통해 최선의 결과를 이끌어내는 것을 의미합니다.

단순한 판매수익, 영업수익만이 언제나 큰 이윤을 의미하는 것은 아닙니다.

금전적인 비용, 인력 등 자원의 투입 또한 이윤을 결정짓는 중요한 요소이죠.

고객들의 가치를 계산하여 세분화하는 것은 우리가 어디에 자원을 집중해야만 하는 지를 알려줄 수 있습니다.

2. 고객관계관리(CRM)

오늘날의 시장은 정보량이 증가함에 따라 소비자들의 구매전환이 매우 자주, 쉽게 일어납니다.

이러한 측면에서 기업은 "가치있는 고객"들과 관계를 맺고, 그 관계를 굳히는 것이 중요하다는 것을 깨닫게 된 것이죠.

이에 어떤 고객이 우리에게 큰 이윤을 가져다 줄 잠재력을 가지고 있는 가, 그 가치를 평가하는 것은 매우 중요합니다.
__________

1.CLV(고객 생애 가치) computation

CLV

r = response rate

(churn rate = 1 - r)

d = discount rate

p is the average profit the customers will contribute in every period(mean)

CLV = (1+d)*p/d+c

__________

2.RFM

Recency, Frequency, Monetary

it is one of the good ways to evaluate "customers"

RFM Package in R & Targeting (same way as clv)

__________
reference

M = profit contribution margin

E(Z) = expected order amount given that the customer responds to the campaign

r = predicted response probability (Because of it, sometimes CLV is considered as a uncertain method)

C / m * E(Z) is the break-even response probability
expected profit = M × E(Z) × r − C

