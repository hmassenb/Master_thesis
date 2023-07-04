************************
** Creating variables **
************************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0702.dta"

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

** Creating country averages of RTI depending on heduc 

save "$ess\data1105.dta", replace

