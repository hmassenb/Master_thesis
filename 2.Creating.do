************************
** Creating variables **
************************
clear all
use "C:\Users\Hannah\Documents\Thesis\data\data0702.dta"
global ess "C:\Users\Hannah\Documents\Thesis\data"


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

drop if age > 60
}


* Creating Educ related 
{
** ESS 1 - ESS 5
gen heduc = 0
replace heduc = 1 if essround <= 5 & highest_educa == 5


** ESS 6- ESS 9
replace heduc = 1 if essround >5 & highest_educb > 400 

*** 281225 no higher educ, 107286 higher educ

** Father merging
gen fa_heduc = 0 
replace fa_heduc = 1 if fa_higheduca == 5 // <=5
replace fa_heduc = 1 if fa_higheducb >= 600 // >5
replace fa_heduc = 0 if fa_higheducb >= 5555

** Mother merging
gen mo_heduc = 0 
replace mo_heduc = 1 if mo_higheduca == 5 // <=5
replace mo_heduc = 1 if mo_higheducb >= 600 // >5
replace mo_heduc = 0 if mo_higheducb >= 5555
}


save "$ess\data1105.dta", replace

