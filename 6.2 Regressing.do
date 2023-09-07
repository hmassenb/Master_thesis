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
/*
gen plusminus_rti = 0 
replace plusminus_rti = 1 if rti < 0
// 76% are in the negative range 

****************************
* in the middle 
gen rti09 = 0 
replace rti09 = 1 if rti <= -0.8
//  43.63% are treated now 

******************************
*/

* Binary dependent var 
logit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.country i.year, vce(cluster year)
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post atmeans
marginsplot, title("Marginal effects of coefficients with Logit model") yline(0) // heduc strongest positive impact s.t. outcome variable is 1 
esttab logit


/*
gen rti_poisson = rti + 1.01
gen log_rtitransi = log(rti_poisson)
* OLS GLM
glm rti_poisson heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.year i.country, link()

glm rti_poisson heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp 
// damn effect is twice as large now 
// shifted values from -1,1 to 0,2 to get rid of neg value and enable poisson distribution would my var kinda look like
glm rti_poisson heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.year i.country, link(logit) cluster(country) rob


* meqrlogit  https://www.stata.com/manuals14/memeqrlogit.pdf https://rips-irsp.com/articles/10.5334/irsp.90
// mixed effect model contains RE and FE -> not sure about that
*******************
meqrlogit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp || country: || year:
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot // heduc only one with strongest negative impact



* probit 
probit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp
* average marginal effect
margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post 
marginsplot // heduc only one with strongest negative impact


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

*/ 

* quantil regression 
*********************
ssc install grqreg, replace 

xi: qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.country i.year, vce(robust)
grqreg heduc,  ci 
grqreg heduc, quantiles(0.25 0.50 0.75)


** Inkremental building of quantile table 
quietly regress rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp
estimates store OLS 

quietly qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile (.25) 
estimates store QR_25 

quietly qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile (.50) 
estimates store QR_50

quietly qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quantile (.75)
estimates store QR_75

quietly bsqreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, quant(.50) reps(400)
estimates store BSQR_50

estimates table OLS QR_25 QR_50 QR_75 

* MATCHING 
*******************

teffects nnmatch (rti heduc age mo_heduc birthplace hh_netincome)  (sex), caliper(.5) osample(unmatched)
















