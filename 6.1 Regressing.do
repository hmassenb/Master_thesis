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
**** Base Model 
*************************
*  OLS
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
** Fixed Effects 
*****************
eststo fecountry: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country) vce(cluster industry_bins year country) resid

eststo feyear: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins year country) resid

eststo fecountryyear: reghdfe rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year country) resid
predict resid3, residuals
corr(resid3 heduc) // corr 0,0
*qnorm resid3, title("distribution of residuals") 


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
	
* margins country, dydx(heduc) atmeans noestimcheck post // non signi countries: LT, IE, HU, ES 
* marginsplot, ///
*	yline(0) ///
*	title("Marginsplot of heduc#country")




graph box rti, over(country) over(heduc)

*************
* Coefplot file https://repec.sowi.unibe.ch/stata/coefplot/getting-started.html
eststo inter_country: reghdfe rti country#heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 

coefplot inter_country, ///
drop(_cons age sex mo_heduc hh_netincome citizenship share_heduc birthplace RDpcppp) ///
 yline(0) title("Regression results for each country") vertical sort ///
coeflab(,truncate(2)) xlabel(, angle())  

********************************************
* COUNTRY BIN 
eststo inter_countrybin: reghdfe rti heduc#country_bin age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 

esttab inter_countrybin using heduc#countrybin.tex, replace ///
	nogaps label  /// 
	keep(1.heduc#1.country_bin 1.heduc#2.country_bin 1.heduc#3.country_bin 1.heduc#4.country_bin 1.heduc#5.country_bin  ///
	age mo_heduc birthplace hh_netincome share_heduc RDpcppp ) ///
	title(Coefficients) ///
	b(4) se(4)
	
margins country_bin, dydx(heduc)  noestimcheck post 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#country_bin") // not sure if marginsplot makes sense here? I think boxplot maybe reflect better as marginsplot might work better after an actual binary model 
	
graph box rti, over(heduc) over(country_bin) 


* HETEROGENEITIES
*********************************
* MATCHING STILL!!!!
*************************************
***** SEX  
eststo sex: reghdfe rti heduc#sex age mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster industry_bins country year)  
margins sex, dydx(heduc) atmeans noestimcheck post 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#sex")
graph box rti, over(sex) over(heduc)



* AGE
eststo age: reghdfe rti heduc#age_groups sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year) 
margins age_groups, dydx(heduc)  noestimcheck post 
marginsplot, ///
	yline(0) ///
	title("Marginsplot of heduc#age")
graph box rti, over(age_groups) over(heduc) title("Age Heterogeneity")

* HH INCOME
eststo income: reghdfe rti heduc#hh_netincome sex age mo_heduc birthplace  share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year) 
margins hh_netincome, dydx(heduc)  noestimcheck post 
marginsplot, ///
	yline(0)   nolab ///
	title("Marginsplot of heduc#income")
	
graph box rti, over(hh_netincome) over(heduc) ///
title("Income Heterogeneity") nolab 

* DISCRI 
eststo discri: reghdfe rti heduc#dscrgrp hh_netincome sex age mo_heduc birthplace  share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year) 
margins dscrgrp, dydx(heduc)  noestimcheck post 
marginsplot, ///
	yline(0)   nolab ///
	title("Marginsplot of heduc#discri")
	
graph box rti, over(dscrgrp) over(heduc) title("Discrimination Heterogeneity")

* MIGRATION 
eststo migra: reghdfe rti heduc#citizenship hh_netincome sex age mo_heduc birthplace  share_heduc RDpcppp, abs(country year) vce(cluster industry_bins year) 
margins citizenship, dydx(heduc)  noestimcheck post 
marginsplot, ///
	yline(0)   nolab ///
	title("Marginsplot of heduc#citizen")
	
graph box rti, over(citizenship) over(heduc)

twoway kdensity rti if citizenship == 1, col(cranberry) || kdensity rti if citizenship == 2


* Mulit level estimation 
mixed rti heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp || country: || year:


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



