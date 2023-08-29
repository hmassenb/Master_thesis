*********************
** 2. Regressions **
*********************
* Binary dependent var 
logit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, robust
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot // heduc only one with strongest negative impact
eststo rti

probit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot // heduc only one with strongest negative impact
eststo rti


* quantil regression 
*********************
ssc install grqreg, replace 
grqreg, cons ci ols olsci list seed(10101) reps(400) scale (1.1) // cool graph but have to adopt it still to my context

quietly bsqreg ltotexp suppins totchr age female  white, quantile (.50) reps(400)  

sqreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, q(.25 .50 .75)

centile ltotexp, centile(5 50 95)

centile ltotexp, centile(10(10)90)

qplot ltotexp, recast(line) scale (1.5)

qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp

qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile(.9)



** Inkremental building of quantile table 
quietly regress rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp
estimates store OLS 

quietly qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile (.25) 
estimates store QR_25 

quietly qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile (.50) 
estimates store QR_50

quietly qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile (.75)
estimates store QR_75

set seed 10101
quietly bsqreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quant(.50) reps(400)
estimates store BSQR_50

estimates table OLS QR_25 QR_50 QR_75 



quietly regress ltotexp suppins totchr age female white 
estat hettest suppins totchr age female white, iid

