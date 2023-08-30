**********************
***** Regressing ****
**********************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis\tables"
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
**** All cov reg 
*************************
* Only OLS
eststo ols: reg rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp

matrix list e(V)
estat vce, correlation 

* Heterosk robust std errors
** Single cluster
eststo cluster_nacer1: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster industry_bins) // still signi on the 1% level, effect slightly larger

eststo cluster_year: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster year)

eststo cluster_country: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country)

eststo cluster_countrybin: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country_bin) // more permissive clustering (coarser groups) result in still on 1% signi result and magnitude slightly increases also with industry clusters


** Multiple cluster

eststo cluster_countryyear: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country year)

** ALL cluster
eststo cluster_3doublebin: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country_bin year industry_bins) // 10% signi

eststo cluster_3onebin: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, noabs vce(cluster country year industry_bins) // 10% signi

**************
* Cluster table for appendix 
esttab ols cluster_nacer1 cluster_year cluster_country cluster_countrybin cluster_countryyear cluster_3onebin cluster_3doublebin ///
 using cluster.tex, replace ///
 nogaps compress ///
 b(4) se(4)

********************************

*****************
** Fixed effects as well
*****************
eststo fecountry: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country) vce(cluster industry_bins year country) resid

eststo feyear: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins year country) resid

eststo fecountryyear: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year country) resid3
* predict resid3, residuals
qnorm resid3, title("distribution of residuals") 


eststo feindustrybins: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(industry_bins) vce(cluster industry_bins year country) resid

eststo fe_all: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year industry_bins) vce(cluster industry_bins year country) resid

* FE table for appendix 
esttab ols fecountry feyear fecountryyear fe_all  ///
	using fe.tex, replace ///
	nogaps compress ///
	b(4) se(4) ///
	addnotes(p{\linewidth} "(1) OLS, (2) country fixed 	effects, (3) year fixed effects, (4) country and yea fixed effects, (5) country, year and industry fixed 	effects")
 

* Table with different models
esttab ols cluster_3onebin fecountry feyear fecountryyear  using inkrementalreg.tex, replace ///
	mtitle("OLS" "Clustering" "Country FE" "Year FE" "Country-Year FE") ///
	title("Inkremental regression ") ///
	se(4) b(4) /// 
	compress


*********************************************




************************
**** Interaction 
*************************
* SEX 
eststo sex: reghdfe rti heduc#sex age mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster industry_bins country year)  nocons

esttab sex using interactsex.tex, replace
gen sexinter = 0 
replace sexinter = 0.13 if heduc==0 & sex==2 
replace sexinter = -0.203 if heduc== 1 & sex==1 
replace sexinter = -0.0985 if heduc == 1 & sex == 2
graph bar, over(sexinter)
*********************************
** Stopped here byreperesnting differences across sex

margins sex, dydx(heduc) atmeans noestimcheck post 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#sex")
	

* COUNTRY
eststo inter_country: reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 

bysort country heduc: count // smallest country#heduc = 808obs

esttab inter_country using heduc#country.tex, replace ///
	nogaps label  /// 
	keep(1.heduc#1.country 1.heduc#2.country 1.heduc#3.country 1.heduc#4.country ///
	1.heduc#5.country 1.heduc#6.country 1.heduc#7.country ///
	1.heduc#8.country 1.heduc#9.country 1.heduc#10.country ///
	1.heduc#11.country 1.heduc#12.country 1.heduc#13.country ///
	1.heduc#14.country 1.heduc#15.country 1.heduc#16.country ///
	1.heduc#17.country 1.heduc#18.country age mo_heduc birthplace hh_netincome share_heduc RDpcppp ) ///
	title(Coefficients) ///
	b(4) se(4)
	
margins country, dydx(heduc) atmeans noestimcheck post // non signi countries: LT, IE, HU, ES 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#country")
	
* COUNTRY BIN 
eststo inter_countrybin: reghdfe rti heduc#country_bin age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 

esttab inter_countrybin using heduc#countrybin.tex, replace ///
	nogaps label  /// 
	keep(1.heduc#1.country_bin 1.heduc#2.country_bin 1.heduc#3.country_bin 1.heduc#4.country_bin ///
	1.heduc#5.country_bin age mo_heduc birthplace hh_netincome share_heduc RDpcppp ) ///
	title(Coefficients) ///
	b(4) se(4)
	
margins country_bin, dydx(heduc)  noestimcheck post 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#country_bin")

	

* AGE
eststo age: reghdfe rti heduc#age_groups sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster nacer2 year) resid


* HH INCOME
eststo income: reghdfe rti heduc#hh_netincome sex age mo_heduc birthplace  share_heduc RDpcppp, abs(country year) vce(cluster nacer2 year) resid



* DISCRI 
eststo discri: reghdfe rti heduc#dscrgrp hh_netincome sex age mo_heduc birthplace  share_heduc RDpcppp, abs(country year) vce(cluster nacer2 year) resid


* MIGRATION 
eststo migra: reghdfe rti heduc#citizenship hh_netincome sex age mo_heduc birthplace  share_heduc RDpcppp, abs(country year) vce(cluster nacer2 year) resid


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




