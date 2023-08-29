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
destring RDpcppp, replace
destring shareRD, replace

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
* interaction of all country##heduc
{
global betasofcountries ///
	2.country#1.heduc 3.country#1.heduc 4.country#1.heduc ///
	5.country#1.heduc 6.country#1.heduc 7.country#1.heduc ///
	8.country#1.heduc 9.country#1.heduc 10.country#1.heduc ///
	11.country#1.heduc 12.country#1.heduc 13.country#1.heduc ///
	14.country#1.heduc 15.country#1.heduc 16.country#1.heduc ///
	17.country#1.heduc 18.country#1.heduc
	
	*keep(1.heduc#2.country 1.heduc#3.country 1.heduc#4.country ///
	*1.heduc#5.country 1.heduc#6.country 1.heduc#7.country ///
	*1.heduc#8.country 1.heduc#9.country 1.heduc#10.country ///
	*1.heduc#11.country 1.heduc#12.country 1.heduc#13.country ///
	*1.heduc#14.country 1.heduc#15.country 1.heduc#16.country ///
	*1.heduc#17.country 1.heduc#18.country 1.heduc#1b.country) /// 
	*title(Coefficients) ///
	*levels(90) xtitle("Coefficients") legend(size(vsmall)) 
}


************************
**** All cov reg 
*************************
* Only OLS
eststo reg1: reg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp

matrix list e(V)
estat vce, correlation 

* Heterosk robust std errors
eststo cluster_nacer1: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster industry_bins) // still signi on the 1% level, effect slightly larger

eststo cluster_nacer2: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster nacer2)

eststo cluster_year: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster year)

eststo cluster_country: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country)

eststo cluster_country: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country_bin) // more permissive clustering (coarser groups) result in still on 1% signi result and magnitude slightly increases also with industry clusters

eststo reg4: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country year)

eststo reg4: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country_bin year industry_bins) // 10% signi

eststo reg4: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country year industry_bins) // 10% signi

eststo reg4: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country year nacer2)

* 1 + 2 + fixed effects
eststo reg3: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster nacer2 year country) resid




* predict resid3, residuals
qnorm resid3, title("distribution of residuals") 


* Table with different models
esttab reg1 reg2 reg3  using 0408reg.tex, replace ///
	mtitle("OLS" "Robust" "2+Fixed effects") ///
	label ///
	title("Stepwise base regression ")


*********************************************




************************
**** Interaction 
*************************
eststo reg5: reghdfe rti heduc#sex age mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country) vce(cluster nacer2 year) resid
esttab reg5 using interactsex.tex, 

eststo reg6: reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster nacer2 year)
// not sure about fixed effects here 
bysort country heduc: count // smallest country#heduc = 808obs
esttab reg6 using heduc#country.tex, replace ///
	nogaps label  /// 
	keep(1.heduc#1.country 1.heduc#2.country 1.heduc#3.country 1.heduc#4.country ///
	1.heduc#5.country 1.heduc#6.country 1.heduc#7.country ///
	1.heduc#8.country 1.heduc#9.country 1.heduc#10.country ///
	1.heduc#11.country 1.heduc#12.country 1.heduc#13.country ///
	1.heduc#14.country 1.heduc#15.country 1.heduc#16.country ///
	1.heduc#17.country 1.heduc#18.country age mo_heduc birthplace hh_netincome share_heduc RDpcppp ) ///
	title(Coefficients)
	
margins country, dydx(heduc) atmeans noestimcheck post // non signi countries: LT, IE, HU, ES 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#country")


*************************
***** heduc#nacer2 // way to many industries to be clear
*************************
{
 eststo reg2: reg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp nacer2 // nacers absorbs a lot! almost -0,1

eststo reg8: reg rti heduc heduc#nacer2 age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp
margins nacer2, dydx(heduc) atmeans noestimcheck post
marginsplot

eststo reg8fe: reghdfe rti heduc heduc#nacer2 age sex mo_heduc birthplace citizenship mo_samebirthplace hh_netincome dscrgrp, absorb(country) vce(cluster nacer2 year)
margins nacer2, dydx(heduc) atmeans noestimcheck post
marginsplot

* solut: created bins
eststo reg7: reghdfe rti heduc#industry_bins age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country) vce(cluster nacer2 year) 
}

***********************
** By year estimation
***********************
* 2012
eststo e2012:  reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp if year==2012, noabs vce(cluster nacer2)
margins country, dydx(heduc) atmeans noestimcheck post 
marginsplot, ///
	yline(0) ///
	title(" 2012") ///
	 name(graph12, replace) ///
	 yline(0) xlabel(, labsize(small))

* 2014
eststo e2014:  reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp if year==2014, noabs vce(cluster nacer2)
margins country, dydx(heduc) atmeans noestimcheck post 
marginsplot, ///
	yline(0) ///
	title(" 2014") ///
	 name(graph14, replace) ///
	 yline(0) xlabel(, labsize(small))


* 2016
eststo e2016:  reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp if year==2016, noabs vce(cluster nacer2)
margins country, dydx(heduc) atmeans noestimcheck post 
marginsplot, ///
	yline(0) ///
	title(" 2016") ///
	 name(graph16, replace) ///
	 yline(0) xlabel(, labsize(small))


* 2018
eststo e2018:  reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp if year==2018, noabs vce(cluster nacer2)
margins country, dydx(heduc) atmeans noestimcheck post 
marginsplot, ///
	yline(0) ///
	title(" 2018") ///
	 name(graph18, replace) ///
	 yline(0) xlabel(, labsize(small))
	 
	 
* Marginsplot (marginal )
graph combine graph12 graph14 graph16 graph18, ///
	row(2) title("Effect of higher education across countries") 

******************************************
* regression table finalment 
******************************************
esttab reg6 e2012 e2014 e2016 e2018 using reg2.tex, ///
	label nonumbers mtitles("All" "2012" "2014" "2016" "2018") ///
    cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))  ///
	keep(1.heduc#1.country 1.heduc#2.country 1.heduc#3.country ///
	1.heduc#4.country 1.heduc#5.country 1.heduc#6.country ///
	1.heduc#7.country  1.heduc#8.country 1.heduc#9.country ///
	1.heduc#10.country 1.heduc#11.country 1.heduc#12.country ///
	1.heduc#13.country 1.heduc#14.country 1.heduc#15.country ///
	1.heduc#16.country 1.heduc#17.country 1.heduc#18.country ///
	age mo_heduc birthplace hh_netincome share_heduc RDpcppp ) ///
    title("Regression displaying coefficients for each country") replace 
	








***********************************************
** Sigma Convergence 
************************
{
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

    
}





