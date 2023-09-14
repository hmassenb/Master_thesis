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

eststo m1: margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post  // heduc coeff  .1428394
marginsplot 

eststo m2: margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post atmeans // heduc coeff .1487569 
marginsplot, title("Marginal effects of coefficients with Logit model") yline(0) // heduc strongest positive impact s.t. outcome variable is 1 

esttab m1 m2 using binarymodel.tex 


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

qplot rti 


/*
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
*/

* MATCHING 
*******************
* Nearest neighbour 
drop unmatched

eststo before: tabstat rti heduc mo_heduc age_groups birthplace country year , by(sex)
eststo after: 
esttab before 

* way to long
* psmatch2 rti , mahalanobis(sex) outcome(heduc mo_heduc age_groups birthplace country year) llr bwidth(2) caliper(0.5)  ate


teffects psmatch (rti) (sex heduc mo_heduc age_groups birthplace country year) // .1137957 
 graph bar  rti,  over(sex)  over(heduc) blabel(bar) title("Differences of RTI across education level and sex") b1title("Education Level") ytitle("Mean of RTI")
 di -0.422123 + 0.297194 // -.124929
 di -0.654591 + 0.543279 // -.111312
 
 * RA 
eststo fem:  reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp  if sex == 2 , abs(country year) vce(cluster industry_bins country year)
eststo masc:  reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp  if sex == 1 , abs(country year) vce(cluster industry_bins country year)

eststo fem_indu:  reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp industry_bins if sex == 2 , abs(country year) vce(cluster industry_bins country year)
eststo masc_indu: reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp industry_bins if sex == 1 , abs(country year) vce(cluster industry_bins country year)
// .0111037 women have a 0,0111 higher importance of heduc 
* table RA
esttab fem masc fem_indu masc_indu using ra_hetero_sex.tex, replace ///
drop(sex) b(4) se(4)

egen mean_rti = mean(rti), by(sex industry_bins)

twoway scatter mean_rti industry_bins if sex == 1 & heduc == 1, col(darkblue)|| scatter mean_rti industry_bins if sex == 2 & heduc == 1, col(cranberry) connect

twoway bar mean_rti industry_bins if sex == 1 & heduc == 1, bcol(blue)|| bar mean_rti industry_bins if sex == 2 & heduc == 1, bcol(cranberry) title("Difference in RTI within Industry") legend(order(1 "Men" 2 "Female"))

onewayplot mean_rti if sex==2, by(industry_bins) ytitle("") stack ms(oh) msize(tiny) width(20)
twoway bar mean_rti industry_bins if sex == 1, col(blue%1) || bar mean_rti industry_bins if sex ==2, col(cranberry%40) 



teffects nnmatch (rti heduc country year) (sex), caliper(.05) osample(unmatched) nn(1)

tebalance summarize (rti) (sex heduc age mo_heduc  hh_netincome country year)
tebalance box sex

_pctile rti, percentiles(50)
graph box rti, over(sex) over(heduc) 



* propensity score 
* sex
teffects psmatch (rti) (sex heduc age mo_heduc hh_netincome country year, logit ) // 0,112719 difference women are worse off
teoverlap 
tebalance box 


* hh netincome
gen inc_bin = 1 if hh_netincome > 5
replace inc_bin = 0 if hh_netincome <= 5
teffects psmatch (rti) (inc_bin heduc age mo_heduc sex country year, logit ) //  -.043182  difference women are worse off

eststo income_inter: reghdfe rti heduc#hh_netincome mo_heduc age birthplace sex RDpcppp share_heduc, absorb(country year) vce(cluster industry_bins year country) nocons
coefplot income_inter, ///
	drop(_cons age sex mo_heduc share_heduc birthplace RDpcppp share_heduc) ///
	yline(0) title("Interaction between household income and education") ///
	vertical ///
	xlab(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") ///
	xtitle("Decentile of household income") ytitle("RTI") ///
	keep(1.heduc#1.hh_netincome 1.heduc#2.hh_netincome 1.heduc#3.hh_netincome 1.heduc#4.hh_netincome 1.heduc#5.hh_netincome ///
	1.heduc#6.hh_netincome 1.heduc#7.hh_netincome 1.heduc#8.hh_netincome 1.heduc#9.hh_netincome 1.heduc#10.hh_netincome) ///
	baselevels
	
graph bar rti, over(hh_netincome, label(angle(45)))  by(heduc, title("RTI for men and women across income decentiles")) ///
bar(1, fcolor(green)) bar(2, fcolor(orange)) ascategory asyvars ytitle("Mean of RTI") legend(row(1))


egen mean_rti = mean(rti) , by(hh_netincome heduc)

twoway scatter mean_rti hh_netincome if heduc == 0, col(green) ///
|| scatter mean_rti hh_netincome if heduc == 1, col(orange) ///
title("Difference in RTI across income and education") ///
legend(order(1 "No tertiary education" 2 "With tertiary education"))



// Perform propensity score matching using teffects
teffects psmatch (RTI) ///
  (mo_heduc heduc age sex hh_netincome country year, logit), ///
  method(knn) caliper(0.05) common

// Check balance with standardized differences
teffects psmatch (RTI) ///
  (mo_heduc heduc age sex hh_netincome country year, logit), ///
  method(knn) caliper(0.05) common check

// Display summary statistics of covariates before and after matching
summarize mo_heduc heduc age sex hh_netincome country year ///
  if teffects_common == 1, detail
summarize mo_heduc heduc age sex hh_netincome country year ///
  if teffects_common == 0, detail


tebalance density sex
tebalance density rti 

tebalance box sex, treatment(matched_var) common





