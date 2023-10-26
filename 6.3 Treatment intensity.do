***************************
* Treatment intensity

clear all 
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta"
set scheme cleanplots

***************************

destring rti, replace 
destring RDpcppp, replace 

***************************
drop if isced_higheduc == 55


gen high_heduc67 = 0 
replace high_heduc67 = 1 if isced_higheduc >= 6

gen high_heduc7 = 0 
replace high_heduc7 = 1 if isced_higheduc >= 7

gen incremental_heduc = 0 if isced_higheduc < 5
replace incremental_heduc = 1 if isced_higheduc == 5
replace incremental_heduc = 2 if isced_higheduc == 6
replace incremental_heduc = 3 if isced_higheduc == 7

eststo inkremental: reghdfe rti i.incremental_heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year country) vce(cluster industry_bins country year) 

esttab inkremental using inkremental.tex, replace ///
b(4) se(4) 

coefplot inkremental, ///
	drop(_cons) vertical yline(0) ///
	xlab(1 "ISCED 5" 2 "ISCED 6" 3 "ISCED 7" 4 "Age" 5 "Gender" ///
	6 "Mo.Heduc" 7 "Birthplace" 8 "Income" 9 "Heduc %" 10 "R&D") ///
	col(green) mfcolor(green) msymbol(circle) ciopts(color(orange)) ///
	title("Regression results of treatment intensity")

coefplot heterosex, ///
	keep(1.heduc#1.sex 1.heduc#2.sex 0.heduc#1.sex 0.heduc#2.sex) ///
	baselevels vertical yline(0) mlab mlabcolor(black) ///
	title("Differences in genders importance of education") ///
	col(green) mfcolor(orange)  ciopts(color(orange))

	




* interacted with country -> very nice 
reghdfe rti incremental_heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 


