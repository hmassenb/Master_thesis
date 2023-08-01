**********************
***** Regressing ****
**********************
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

************************
**** All cov reg 
*************************

eststo reg1: reg rti heduc age sex mo_heduc birthplace hh_netincome

eststo reg2: reg rti heduc age sex mo_heduc birthplace hh_netincome nacer2  // nacers absorbs a lot! almost -0,1

eststo reg3: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome nacer2, abs(country year)

eststo reg4: reghdfe rti heduc age sex mo_heduc birthplace  industry_bins , abs(country year) vce(cluster year nacer2)
matrix list e(V)
estat vce, correlation


************************
**** All cov reg + interaction 
*************************
eststo reg5: reghdfe rti heduc heduc#sex age sex mo_heduc birthplace hh_netincome , abs(country year) vce(cluster year)

eststo reg5: reghdfe rti heduc heduc#country age sex mo_heduc birthplace hh_netincome , absorb(year) vce(cluster year)

eststo reg7: reghdfe rti heduc heduc#industry_bins age sex mo_heduc birthplace hh_netincome , abs(country year) vce(cluster year)

{
********************
**** heduc#sex
*************************
eststo reg4: reg rti heduc  age  mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp
// in contrast to male with no education women with no heduc have RTI  0,11 higher and male with education have -0,215 vs female with heduc have -0.107 lower RTI 

eststo reg4fe:reghdfe rti heduc heduc#sex age  mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, absorb(country) vce(cluster nacer2 year)

********************
***** heduc#age_groups (2.Creating)
****************************************
eststo reg5: reg rti heduc heduc#age_groups sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp
// effect gets stronger for oldest age group

eststo reg5fe: reghdfe rti heduc heduc#age_groups sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, absorb(country) vce(cluster nacer2 year)

*************************
***** heduc#country 
*************************
eststo reg6: reg rti heduc heduc#country age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, coeflegend

* margins country, dydx(heduc) atmeans noestimcheck post
* marginsplot
* coefplot reg4, /// 
	*keep(1.heduc#2.country 1.heduc#3.country 1.heduc#4.country ///
	*1.heduc#5.country 1.heduc#6.country 1.heduc#7.country ///
	*1.heduc#8.country 1.heduc#9.country 1.heduc#10.country ///
	*1.heduc#11.country 1.heduc#12.country 1.heduc#13.country ///
	*1.heduc#14.country 1.heduc#15.country 1.heduc#16.country ///
	*1.heduc#17.country 1.heduc#18.country 1.heduc#1b.country) /// 
	*title(Coefficients) ///
	*levels(90) xtitle("Coefficients") legend(size(vsmall)) 

* ylabel("CH" "CZ" "DE" "EE" "ES" "FI" "FR" "GB" "HU" "IE" "LT" "NL" "NO" "PL" "PT" "SE" "SI") ///

eststo reg6fe: reghdfe rti heduc heduc#country age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, noabsorb vce(cluster nacer2 year)

*************************
***** heduc#year 
*************************
eststo reg7: reg rti heduc heduc#year age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, coeflegend

*************************
eststo reg7fe: reghdfe rti heduc heduc#year age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, absorb(country) vce(cluster nacer2 year)
// over time no clear trend


*************************
***** heduc#nacer2 // way to many industries to be clear
*************************
eststo reg8: reg rti heduc heduc#nacer2 age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp
margins nacer2, dydx(heduc) atmeans noestimcheck post
marginsplot

eststo reg8fe: reghdfe rti heduc heduc#nacer2 age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, absorb(country) vce(cluster nacer2 year)
margins nacer2, dydx(heduc) atmeans noestimcheck post
marginsplot






* no fe
esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7  using 7reg.tex, replace ///
mtitle("very basic" "basic" "all covar" "#sex" "#age_groups" "#country" "#year" "#nacer")

* fe
esttab reg1fe reg2fe reg3fe reg4fe reg5fe reg6fe reg7fe  using 7regfe.tex , replace ///
mtitle("very basic" "basic" "all covar" "#sex" "#age_groups" "#country" "#year" "#nacer")

}


***********************
** By year estimation
***********************
{
* 2012
eststo e2012: reghdfe rti country##heduc age sex mo_heduc if year == 2012, absorb(country) vce(cluster nacer2 country) coeflegend
*mat list e(b) 
*local bage=_b[country##heduc]
*dis `country##heduc'

margins country, dydx(heduc) atmeans noestimcheck post
quietly marginsplot, recast(line) name(graph12, replace) title("2012") yline(-0.2)

* 2014
eststo e2014: reghdfe rti country##heduc age sex mo_heduc if year == 2014, absorb(country) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph14, replace) title("2014") yline(-0.2)

* 2016
eststo e2016: reghdfe rti country##heduc age sex mo_heduc if year == 2016, absorb(country) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph16, replace) title("2016") yline(-0.2)

* 2018
eststo e2018: reghdfe rti country##heduc age sex mo_heduc if year == 2018, absorb(country) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph18, replace) title("2018") yline(-0.2)

* Marginsplot 
graph combine graph12 graph14 graph16 graph18, row(2) title("Effect of higher education across countries")

* Coefplot
// is again in contrast to Belgium not quit fond of that approach
coefplot e2012 e2014 e2016 e2018, /// 
	keep(2.country#1.heduc 3.country#1.heduc 4.country#1.heduc ///
	5.country#1.heduc 6.country#1.heduc 7.country#1.heduc ///
	8.country#1.heduc 9.country#1.heduc 10.country#1.heduc ///
	11.country#1.heduc 12.country#1.heduc 13.country#1.heduc ///
	14.country#1.heduc 15.country#1.heduc 16.country#1.heduc ///
	17.country#1.heduc 18.country#1.heduc) /// 
	levels(90) xtitle("Coefficients") legend(size(vsmall)) ///   
	 title(Coefficients)

* boxplot to detect outliers
global betasofcountries ///
	2.country#1.heduc 3.country#1.heduc 4.country#1.heduc ///
	5.country#1.heduc 6.country#1.heduc 7.country#1.heduc ///
	8.country#1.heduc 9.country#1.heduc 10.country#1.heduc ///
	11.country#1.heduc 12.country#1.heduc 13.country#1.heduc ///
	14.country#1.heduc 15.country#1.heduc 16.country#1.heduc ///
	17.country#1.heduc 18.country#1.heduc
	
	
******************
* Trying to extract betas into new var
gen betas = . 
levelsof country, local(countrycodes) //18
foreach countrycode of local countrycodes {
    replace betas = 
    local beta_value = r(mean)
    replace betas = `beta_value' if country == "`countrycode'"
}


twoway box heduc year, over(country)

*regression table 
esttab e2012 e2014 e2016 e2018 using reg2.tex, ///
	label nonumbers mtitles("2012" "2014" "2016" "2018") ///
    cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))  ///
	keep(2.country#1.heduc 3.country#1.heduc 4.country#1.heduc ///
	5.country#1.heduc 6.country#1.heduc 7.country#1.heduc ///
	8.country#1.heduc 9.country#1.heduc 10.country#1.heduc ///
	11.country#1.heduc 12.country#1.heduc 13.country#1.heduc ///
	14.country#1.heduc 15.country#1.heduc 16.country#1.heduc ///
	17.country#1.heduc 18.country#1.heduc) ///
    title("Regression displaying coefficients for each country") replace 
	
}

***********************************************
** Sigma Convergence 
************************
gen se=.
eststo sigma2012: reghdfe rti heduc age sex mo_heduc if year == 2012, absorb(country) vce(cluster nacer2 country) 
replace se = _se[heduc] if year == 2012

eststo sigma2014: reghdfe rti heduc age sex mo_heduc if year == 2014, absorb(country) vce(cluster nacer2 country) 
replace se = _se[heduc] if year == 2014

eststo sigma2016: reghdfe rti heduc age sex mo_heduc if year == 2016, absorb(country) vce(cluster nacer2 country) 
replace se = _se[heduc] if year == 2016

eststo sigma2018: reghdfe rti heduc age sex mo_heduc if year == 2018, absorb(country) vce(cluster nacer2 country) 
replace se = _se[heduc] if year == 2018
tab se

twoway scatter se year

    






