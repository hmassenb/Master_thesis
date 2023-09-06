*********************
** 2. Regressions **
*********************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis"
set scheme s1mono

******************************
* destring variables
drop if _merge==1
destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace
destring RDpcppp, replace
destring shareRD, replace

* Why necessary 
eststo fecountryyear: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year country) resid
predict resid_basemodel, residuals
qnorm resid_basemodel, title("distribution of residuals") 


************************
** RTI Bin 
******************
* Binary 
***********
gen binary_rti = 0 
replace binary_rti = 1 if rti == -1 
// 38% are -1

************************
* Binary but minus vs posi
******************
gen plusminus_rti = 0 
replace plusminus_rti = 1 if rti < 0
// 76% are in the negative range 

****************************
* in the middle 
gen rti09 = 0 
replace rti09 = 1 if rti <= -0.8
//  43.63% are treated now 

******************************


* Binary dependent var 
logit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, robust
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot // heduc strongest positive impact s.t. outcome variable is 1 
eststo rti

* Logit with fe
*******************
xtset country
xtlogit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.country i.year 

* beta reg [0,1]
*******************
gen rti2 = rti/2 +0.5
betareg rti2 heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp 

* meqrlogit  https://www.stata.com/manuals14/memeqrlogit.pdf https://rips-irsp.com/articles/10.5334/irsp.90
*******************

probit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot // heduc only one with strongest negative impact
eststo rti

* Binary but minus vs posi 
logit plusminus_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, robust
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot 

* In the middle 
logit rti09 heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, robust
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot 


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

