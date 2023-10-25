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
drop(_cons)


* interacted with country -> very nice 
reghdfe rti incremental_heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 


