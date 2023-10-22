*********************
** 2. Regressions **
*********************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis"
set scheme cleanplots



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
 logit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp  i.country i.year, vce(cluster country)

* atmeans = effect computed at the average of the covariates "Avg individual"
eststo logit : margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post  // heduc coeff .1487569 
marginsplot, ///
	title("Marginal effects of coefficients with Logit model") ///
	yline(0)  ytitle("Pr(heduc=1)") /// // heduc strongest positive impact s.t. outcome variable is 1 
	xlabel(1 "Heduc" 2 "Age" 3 "Gender" 4 "Mothers educ" 5 "Birthplace" 6 "HH income" 7 "Share heduc" 8 "R&D", angle(45))

	
 logit binary_rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp  i.country i.year, vce(cluster country)
eststo logit : margins, dydx(heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp) post  // heduc coeff  .1428394
marginsplot, ///
	title("Marginal effects of coefficients with Logit model") ///
	yline(0)  ytitle("Pr(heduc=1)") /// // heduc strongest positive impact s.t. outcome variable is 1 
	xlabel(1 "Heduc" 2 "Age" 3 "Gender" 4 "Mothers educ" 5 "Birthplace" 6 "HH income" 7 "Share heduc" 8 "R&D", angle(45))
	
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

*********************
* quantil regression 
*********************
ssc install grqreg, replace 

xi: qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc ///
RDpcppp i.year i.country, vce(robust) quantile(0.25) // not nice as not very continous outcome variable 

 eststo fifty: qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, vce(robust) quantile(0.5)
grqreg heduc,  ci ols 

eststo sevenfive: qreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.year i.country, vce(robust) quantile(0.75)

* Bootstrap
bsqreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.year i.country, quantile(0.25) reps(100) 


* simulteanous qreg estimating all quantiles at once
sqreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp , quant(0.25 0.50 0.75)
grqreg heduc, quantiles(0.25 0.50 0.75) // quantile option only after sqreg!

* limited dependent var qreg
ldvqreg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp i.country i.year , ll(-1) ul(1) q(25 50 75)

* Table for model specification 
esttab ols fecountryyear logit fifty using robustness.tex, replace ///
b(4) se(4)

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

* HETEROGENEITY BY SEX
sum  heduc mo_heduc age birthplace hh_netincome  rti nra nri nrm rc rm if sex == 2
estpost sum  heduc mo_heduc age birthplace hh_netincome  rti nra nri nrm rc rm if sex == 2
eststo female 
local female

sum  heduc mo_heduc age birthplace hh_netincome  rti nra nri nrm rc rm if sex == 1
estpost sum  heduc mo_heduc age birthplace hh_netincome  rti nra nri nrm rc rm if sex == 1
eststo male 
local male

global cov ///
heduc mo_heduc age birthplace hh_netincome  rti nra nri nrm rc rm 

foreach var in $cov{
	egen mean_`var'_1 = mean(`var') if sex == 2
	egen mean_`var'_0 = mean(`var') if sex == 1
	replace mean_`var'_1= mean_`var'_1[_n-1] if mean_`var'_1==.
	replace mean_`var'_1= mean_`var'_1[_n+1] if mean_`var'_1==.
	replace mean_`var'_0= mean_`var'_0[_n-1] if mean_`var'_0==.
	replace mean_`var'_0= mean_`var'_0[_n+1] if mean_`var'_0==.
}

foreach var in $cov{
		gen diff_mean_`var' = mean_`var'_1 - mean_`var'_0
}

global diffmeancov ///
diff_mean_heduc diff_mean_age diff_mean_mo_heduc diff_mean_birthplace diff_mean_hh_netincome diff_mean_rti diff_mean_nra diff_mean_nri diff_mean_nrm diff_mean_rc diff_mean_rm

summarize  $diffmeancov
estpost summarize $diffmeancov
eststo diff
local diff

* Table of sex 
esttab female male diff using heterogen_sex.tex, replace ///
	cells("mean(fmt(%9.4f))") ///
	collab("Female" "Male" "Difference") ///
    title("Descriptive Statistics by Sex") 
	
eststo heterosex: reghdfe rti heduc#sex age mo_heduc birthplace ///
	hh_netincome shareRD share_heduc, ///
	absorb(country year) vce(cluster country year industry_bins)
	
esttab heterosex using heterosex.tex, replace ///
	b(4) se(4)
	
coefplot heterosex, ///
	keep(1.heduc#1.sex 1.heduc#2.sex 0.heduc#1.sex 0.heduc#2.sex) ///
	baselevels vertical yline(0) mlab mlabcolor(black) ///
	xlab(1 "Men no Heduc" 2 "Women no Heduc" 3 "Men Heduc" 4 "Women Heduc") ///
	title("Differences in genders importance of education") ///
	col(green) mfcolor(green)  ciopts(color(orange))

* Maybe easier to digest 
twoway kdensity rti if sex == 1 & heduc == 1,  || ///
        kdensity rti if sex == 2 & heduc == 1, || ///
        kdensity rti if sex == 1 & heduc == 0, col(orange) || ///
        kdensity rti if sex == 2 & heduc == 0, col(green)  ///
        legend(order( 1 "Men heduc" 2 "Women heduc" 3 "Men not heduc" 4 "Women not hedu") ///
		pos(6) row(1)) ///
		ytitle("Density RTI") ///
		title("Differences of RTI across education level and gender")
		
		
		
************************************************************
** Table with coefficients per sex and each country 
************************************************************
eststo countrymen: reghdfe rti heduc#country age mo_heduc birthplace hh_netincome shareRD share_heduc ///
	if sex == 1, ///
	absorb(year) vce(cluster country year industry_bins)
	
eststo countrywomen: reghdfe rti heduc#country age mo_heduc birthplace hh_netincome shareRD share_heduc ///
	if sex == 2, ///
	absorb(year) vce(cluster country year industry_bins)

esttab countrymen countrywomen using countrysex.tex, ///
	nogaps label  /// 
	keep(1.heduc#1.country 1.heduc#2.country 1.heduc#3.country 1.heduc#4.country ///
	1.heduc#5.country 1.heduc#6.country 1.heduc#7.country ///
	1.heduc#8.country 1.heduc#9.country 1.heduc#10.country ///
	1.heduc#11.country 1.heduc#12.country 1.heduc#13.country ///
	1.heduc#14.country 1.heduc#15.country 1.heduc#16.country ///
	1.heduc#17.country 1.heduc#18.country age mo_heduc birthplace hh_netincome share_heduc shareRD ) ///
	title(Coefficients) ///
	b(4) se(4)

*************************
* MATCHING SEX	
* https://medium.com/@thestataguide/propensity-score-matching-in-stata-ba77178e4611
*************************
teffects psmatch (rti) (sex heduc mo_heduc age_groups birthplace hh_netincome country year) ///
 , gen(nn) // .1063726 

predict ps*, ps // * enable saving for each level of sex (women vs men)
predict po*, po 
predict te ,te // super cool store te for each i

sum te
tebalance summarize
tebalance density rti, legend(row(1) pos(6))

* twoway kdensity te if sex == 1 || kdensity te if sex == 2 ///
* , legend(order( 1 "TE men" 2 "TE women")) // difference in treatment effect 

twoway kdensity ps1 || kdensity ps2
twoway kdensity po0 || kdensity po1


tebalance density
twoway kdensity po0 || kdensity po1 || ///
	kdensity rti if sex == 1 || kdensity rti if sex == 2, ///
	legend(order( 1 "Matched men" 2 "Matched women" 3 "Unmatched men" 4 "Unmatched women"))

graph bar po1 || bar po2


gen heduc_labels = ""
replace heduc_labels = "No higher education" if heduc == 0
replace heduc_labels = "Higher education" if heduc == 1
	
graph bar rti,  over(sex)  over(heduc_labels) ///
	blabel(bar) title("Differences of RTI across gender and education level") 	///
	b1title("Level of Education") ytitle("Mean of RTI") asyvars  ///
	 bar(1, bcolor(orange)) bar(2, bcolor(green)) ///
	 legend(pos(6) row(1))
	  
 di -0.422123 + 0.297194 // -.124929
 di -0.654591 + 0.543279 // -.111312

{
* Mean median comparison
egen median=median(rti), by(heduc sex)
egen mean = mean(rti), by(heduc sex)
estpost tabstat mean median
tab mean heduc if sex == 1
tab mean heduc if sex == 2

* Boxplot sex heduc rti 
graph box rti, over(sex) over(heduc) ///
bar(1, color(green)) bar(2, color(orange)) ascategory asyvars medtype(line,) title("RTI based on sex and education level") legend(pos(6) row(1))
// median: men(heduc = -1, no heduc = -0,6) women(heduc = -.5432793, no heduc = -0.5)
// mean: men(heduc =  -.6545912, no heduc = -.422123) women(heduc =-.8181819, no heduc =  -.2971935)


* Industry analysis by sex
egen mean_rti = mean(rti), by(sex industry_bins)

twoway scatter mean_rti industry_bins if sex == 1 & heduc == 1, col(darkblue)|| scatter mean_rti industry_bins if sex == 2 & heduc == 1, col(cranberry) connect

twoway bar mean_rti industry_bins if sex == 1 & heduc == 1, bcol(blue)|| bar mean_rti industry_bins if sex == 2 & heduc == 1, bcol(cranberry) title("Difference in RTI within Industry") legend(order(1 "Men" 2 "Female"))

onewayplot mean_rti if sex==2, by(industry_bins) ytitle("") stack ms(oh) msize(tiny) width(20)
twoway bar mean_rti industry_bins if sex == 1, col(blue%1) || bar mean_rti industry_bins if sex ==2, col(cranberry%40) 
}

* propensity score 
teffects psmatch (rti) (sex heduc age mo_heduc hh_netincome birthplace  country year, logit ) //.1091003  difference women are worse off
teoverlap 
tebalance box 

** Nearest neighbor
teffects nnmatch  (rti heduc age mo_heduc hh_netincome birthplace country year) (sex)  // .1130791  
teffects nnmatch  (rti heduc age mo_heduc hh_netincome birthplace country year) (sex), caliper(0.2) osample(unmatched)
teffects nnmatch (rti heduc age mo_heduc hh_netincome birthplace country year) (sex) if !unmatched, caliper(0.2)


** regression adjustment
teffects ra  (rti heduc age mo_heduc hh_netincome birthplace country year) (sex)  //  .1117791

 * RA 
 ****************************
eststo fem:  reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp  if sex == 2 , abs(country year) vce(cluster industry_bins country year)
eststo masc:  reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp  if sex == 1 , abs(country year) vce(cluster industry_bins country year)
twoway line fem heduc || line masc heduc

* eststo fem_indu:  reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp industry_bins if sex == 2 , abs(country year) vce(cluster industry_bins country year)
* eststo masc_indu: reghdfe rti heduc  age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp industry_bins if sex == 1 , abs(country year) vce(cluster industry_bins country year)
// .0111037 women have a 0,0111 higher importance of heduc 
* table RA
esttab fem masc using ra_hetero_sex.tex, replace ///
drop(sex) b(4) se(4)

* heduc#sex#country
eststo doubleinteracted: reghdfe rti heduc#sex#country age mo_heduc birthplace hh_netincome share_heduc RDpcppp industry_bins, abs(year) vce(cluster industry_bins country year)
regsave // Using the betas computing difference in excel simply

****************************
* hh netincome
***********************
* only income
eststo income_inter: reghdfe rti heduc#hh_netincome mo_heduc age birthplace sex RDpcppp share_heduc, absorb(country year) vce(cluster industry_bins year country) nocons

esttab income_inter using income_hetero.tex, replace ///
	keep(1.heduc#1.hh_netincome 1.heduc#2.hh_netincome 1.heduc#3.hh_netincome 1.heduc#4.hh_netincome 	 1.heduc#5.hh_netincome ///
	1.heduc#6.hh_netincome 1.heduc#7.hh_netincome 1.heduc#8.hh_netincome 1.heduc#9.hh_netincome 1.heduc#10.hh_netincome)
	
coefplot income_inter, ///
	drop(_cons age sex mo_heduc share_heduc birthplace RDpcppp share_heduc) ///
	yline(0) title("Breakdown of RTI by household income") ///
	vertical mcol(orange) mfcol(orange) ciopts(lcolor(green)) m(circle) ///
	xlab(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") ///
	xtitle("Deciles of household income") ytitle("RTI") ///
	keep(1.heduc#1.hh_netincome 1.heduc#2.hh_netincome 1.heduc#3.hh_netincome 1.heduc#4.hh_netincome 1.heduc#5.hh_netincome ///
	1.heduc#6.hh_netincome 1.heduc#7.hh_netincome 1.heduc#8.hh_netincome 1.heduc#9.hh_netincome 1.heduc#10.hh_netincome) ///
	baselevels

******************************************************
* main graph diverging behavior depending on heduc

egen mean_rti = mean(rti) , by(hh_netincome heduc)
 
twoway scatter mean_rti hh_netincome if heduc == 0, col(green) fcol(green) || ///
scatter mean_rti hh_netincome if heduc == 1, col(orange) fcol(orange) msymbol(X) ///
	title("Difference in RTI across income and education") ///
	legend(order(1 "No tertiary education" 2 "With tertiary education") nobox ///
	 pos(6) row(1)) ytitle("Mean of RTI")

* how many obs I have per decentile depending on heduc
hist hh_netincome , freq by(heduc)

forval i=1/10{
    local colors "`colors' bar(`i', color(green*`=(`i'/7)'))"
}
graph bar rti, over(hh_netincome) bar(1, col(green*0.7)) ///
asyvars `colors' title("RTI over income decentiles") ///
legend(pos(3) row(10) nobox ///
order(1 "1st" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th" 6 "6th" 7 "7th" 8 "8th" 9 "9th" 10 "10th" ))

	
	
****************************
* Income and Sex 
****************************
eststo income_inter: reghdfe rti heduc#hh_netincome#sex mo_heduc age birthplace sex RDpcppp share_heduc, absorb(country year) vce(cluster industry_bins year country) nocons
	
esttab income_inter using income_heterosex.tex, replace ///
keep(1.heduc#1.hh_netincome#1.sex 1.heduc#2.hh_netincome#1.sex 1.heduc#3.hh_netincome#1.sex 1.heduc#4.hh_netincome#1.sex 1.heduc#5.hh_netincome#1.sex ///
	1.heduc#6.hh_netincome#1.sex 1.heduc#7.hh_netincome#1.sex 1.heduc#8.hh_netincome#1.sex 1.heduc#9.hh_netincome#1.sex 1.heduc#10.hh_netincome#1.sex 1.heduc#1.hh_netincome#2.sex 1.heduc#2.hh_netincome#2.sex 1.heduc#3.hh_netincome#2.sex 1.heduc#4.hh_netincome#2.sex 1.heduc#5.hh_netincome#2.sex ///
	1.heduc#6.hh_netincome#2.sex 1.heduc#7.hh_netincome#2.sex 1.heduc#8.hh_netincome#2.sex 1.heduc#9.hh_netincome#2.sex 1.heduc#10.hh_netincome#2.sex )


coefplot income_inter, ///
	drop(_cons age sex mo_heduc share_heduc birthplace RDpcppp share_heduc) ///
	yline(0) title("Interaction between household income and education") ///
	vertical  `colors' ///
	xlab(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10") ///
	xtitle("Decentile of household income") ytitle("RTI") ///
	keep(1.heduc#1.hh_netincome#1.sex 1.heduc#2.hh_netincome#1.sex 1.heduc#3.hh_netincome#1.sex 1.heduc#4.hh_netincome#1.sex 1.heduc#5.hh_netincome#1.sex ///
	1.heduc#6.hh_netincome#1.sex 1.heduc#7.hh_netincome#1.sex 1.heduc#8.hh_netincome#1.sex 1.heduc#9.hh_netincome#1.sex 1.heduc#10.hh_netincome#1.sex 1.heduc#1.hh_netincome#2.sex 1.heduc#2.hh_netincome#2.sex 1.heduc#3.hh_netincome#2.sex 1.heduc#4.hh_netincome#2.sex 1.heduc#5.hh_netincome#2.sex ///
	1.heduc#6.hh_netincome#2.sex 1.heduc#7.hh_netincome#2.sex 1.heduc#8.hh_netincome#2.sex 1.heduc#9.hh_netincome#2.sex 1.heduc#10.hh_netincome#2.sex ) ///
	baselevels  by(sex, cols(1) order(-1 2) vertical)
* Difference between men and women is consistently across centiles
	
graph bar rti, over(hh_netincome, label(angle(45))) ///
by(heduc, title("RTI for men and women across income decentiles")) ///
bar(1, fcolor(green)) bar(2, fcolor(orange)) ///
ascategory asyvars ytitle("Mean of RTI") legend(row(1))



***************************************************


* Migration 
*****************
teffects psmatch (rti) (birthplace heduc mo_heduc age_groups  sex country year) // -.0276267   

graph bar  rti,  over(birthplace) over(heduc) blabel(bar) title("Differences of RTI across education level and birthplace") b1title("Education Level") ytitle("Mean of RTI")

// Perform propensity score matching using teffects
{
	
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


}


