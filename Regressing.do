**********************
***** Regressing ****
**********************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis"

******************************
* destring variables
drop if _merge==1
destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace

****************************************
statsby, by(country): reg heduc age fa_heduc birthplace
reg heduc fa_heduc mo_heduc birthplace  dscrgrp fa_samebirthplace mo_samebirthplace, cluster(cntry) 
reg heduc fa_heduc sex birthplace citizenship dscrgrp fa_samebirthplace mo_samebirthplace c.incomesource, cluster(cntry) 

*******************************************
reghdfe rti heduc age mo_heduc, absorb(cntry year nacer2)
* to save estimates include in bracket of absorb in front of variable (newvar=absvar) but accord. manual saved fe can be misleading 

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
	
	
*********
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

    






