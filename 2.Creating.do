************************
** Creating variables **
************************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0702.dta" // From 1.Cleaning
cd "C:\Users\Hannah\Documents\Thesis\data"


gen year = 99999
replace year = 2004 if essround == 2
replace year = 2006 if essround == 3
replace year = 2008 if essround == 4
replace year = 2010 if essround == 5
replace year = 2012 if essround == 6
replace year = 2014 if essround == 7
replace year = 2016 if essround == 8
replace year = 2018 if essround == 9

** Creating age
{
drop if yrbrn == .a 
drop if yrbrn == .b
* drop if rtrd == 1, weirdly there exist individuals that are already retired even though they are born until 2003????

gen age = year - yrbrn

drop if age > 60 // dropping people who drop out of labor market
drop if age < 25 // dropping people who have not entered labor market
}


* Creating heduc related 
gen heduc = 0
replace heduc = 1 if isced_higheduc >= 5

** Father heduc
gen fa_heduc = 0 
replace fa_heduc = 1 if fa_higheducb >= 500 
replace fa_heduc = 0 if fa_higheducb >= 5000

** Mother heduc
gen mo_heduc = 0 
replace mo_heduc = 1 if mo_higheducb >= 500
replace mo_heduc = 1 if mo_higheducb >= 5000

** Creating country numeric identifier 
egen country = group(cntry)
labmask country, values(cntry)

* creating age groups 
gen age_groups = . 
replace age_groups = 1 if age <= 35 //27%
replace age_groups = 2 if age > 36 & age <= 50 //41%
replace age_groups = 3 if age > 50 // 31%

** Creating change of RTI (2012-2018)
// within country, within occu? 
* egen


save data0702i, replace

