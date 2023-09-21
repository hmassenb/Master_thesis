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

* creating industry variable st i can see numbers // https://ec.europa.eu/eurostat/documents/3859598/5902521/KS-RA-07-015-EN.PDF.pdf/dd5443f5-b886-40e4-920d-9df03590ff91?t=1414781457000
gen industry = nacer2
** numbers have no meaning!
gen industry_bins = .
replace industry_bins = 1 if industry <= 3 // A "Agriculture, forestry, fishing"
replace industry_bins = 2  if industry > 3 & industry <= 39 // BCDE "Manufacturing, mining and quarrying and other industry"
replace industry_bins = 3  if industry  > 39 & industry <= 43  // F "Construction"
replace industry_bins = 4  if industry  > 43 & industry <= 56 // GHI "Wholesale and retail trade, transportation and storage, accomodation and food service activities"
replace industry_bins = 5  if industry  > 56 & industry <= 63 // J "Information and communication"
replace industry_bins = 6  if industry  > 63 & industry <= 66 // K "Financial and insurance activities"
replace industry_bins = 7  if industry  > 66 & industry <= 68 // L "Real estate activities "
replace industry_bins = 8  if industry  > 68 & industry <= 82 // MN "Professional, scientific, technical, administration and support service activities"
replace industry_bins = 9  if industry > 82 & industry <= 88 // POQ "Public administration, defence, education, human health and social work activities "
replace industry_bins = 10 if industry > 88 & industry <= 93  //  RSTU "Arts and entertainment, Activities of households as employers; undifferentiated goods- and services-producing activities of households for own use, Activities of extra-territorial organisations and bodies"

************************
** Country bins 
**********************
gen country_bin = .
* south europe
replace country_bin = 1 if cntry == "ES" | cntry == "PT"

* west europe 
replace country_bin = 2 if cntry == "BE" | cntry == "DE" | cntry == "FR" | cntry == "NL" | cntry == "CH"

* north europe 
replace country_bin = 3 if cntry == "FI" | cntry == "SE" | cntry == "NO" 


* east europe
replace country_bin = 4 if cntry == "SI" | cntry == "HU" | cntry == "CZ" | cntry == "LT" | cntry == "EE" | cntry == "PL" 

* Islands
replace country_bin = 5  if cntry == "GB" | cntry == "IE"
* non EU
* replace country_bin = 5 if cntry == "CH"

label define Regions 1 "South" 2 "West" 3 "North" 4 "East"  5 "Islands"
label  values  country_bin Regions
save data0702ii.dta, replace


******************* 
** Adding share of heduc, investment 
**********************
* Preparing covariates data into dta 
clear all
import excel "C:\Users\Hannah\Documents\Thesis\data\additional covariates.xlsx", firstrow clear
keep country year share_heduc RDpcppp shareRD

des country year
rename country countryy
encode countryy, gen(country) // country is var i match on an transformed it into a long one instead of string
drop countryy
sort  country year

save covariates.dta, replace


* Merge covariate.dta with previously defined data data0702ii
clear all 
use data0702ii.dta
drop if year <2012

sort country year
merge m:1  country year  using covariates.dta, sorted // many unmatched since in this sample still the years 2004-2018 included

rename  _merge merge2creatingcovariates

save data0702i, replace