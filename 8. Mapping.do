* 8. Maps
clear
cd "C:\Users\Hannah\Documents\Thesis\data\Map"
* ssc install spmap
* ssc install shp2dta
* ssc install mif2dta


* transforming shape file in stata words
clear
cd "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp"
spshape2dta CNTR_RG_10M_2020_3035, saving(another) replace
use "another"

* Preparing data for merge 
gen eu = 0 if EU_STAT == "F"
replace eu = 1 if EU_STAT == "T" 
replace eu = 1 if (CNTR_ID == "UK" | CNTR_ID == "CH" | CNTR_ID == "NO")
replace CNTR_ID = "GB" if CNTR_ID == "UK"
drop if eu == 0

keep _ID _CX _CY CNTR_ID NAME_ENGL FID 
rename CNTR_ID cntry
save mergeready.dta, replace

* Merging with existing data
clear
cd "C:\Users\Hannah\Documents\Thesis\data"
use "C:\Users\Hannah\Documents\Thesis\data\data0407.dta"
drop _merge

destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace
destring RDpcppp, replace
destring shareRD, replace

merge m:1 cntry using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\mergeready.dta"
* drop if _merge == 2 // those are the countries that I excluded from my sample 
drop _merge



* Obtaining betas
eststo inter_country_beta: reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp , abs(year) vce(cluster year industry_bins country) 
matrix coeff = e(b)
matrix list coeff
svmat coeff
drop coeff1-coeff18
drop coeff37-coeff42

rename coeff19 bBE
rename coeff20 bCH
rename coeff21 bCZ
rename coeff22 bDE
rename coeff23 bEE
rename coeff24 bES
rename coeff25 bFI
rename coeff26 bFR
rename coeff27 bGB
rename coeff28 bHU
rename coeff29 bIE
rename coeff30 bLT
rename coeff31 bNL
rename coeff32 bNO
rename coeff33 bPL
rename coeff34 bPT
rename coeff35 bSE
rename coeff36 bSI

global coeffs ///
bBE bCH bCZ bDE bEE bES bFI bFR bGB bHU bIE bLT bNL bNO bPL bPT bSE bSI

foreach c in $coeffs {
    local varname `c'
    local first_value = `varname'[1] // Get the value from the first row
    // Use the replace command to fill the variable with the first_value
    replace `varname' = `first_value'
}
 

gen betas = . 
replace betas = bBE if cntry == "BE"
replace betas = bCH if cntry == "CH"
replace betas = bCZ if cntry == "CZ"
replace betas = bDE if cntry =="DE"
replace betas = bEE if cntry == "EE"
replace betas = bES if cntry == "ES"
replace betas = bFI if cntry == "FI"
replace betas = bFR if cntry == "FR"
replace betas = bGB if cntry == "GB"
replace betas = bHU if cntry == "HU"
replace betas = bIE if cntry == "IE"
replace betas = bLT if cntry == "LT" 
replace betas = bNL if cntry == "NL"
replace betas = bNO if cntry == "NO"
replace betas = bPL if cntry == "PL"
replace betas = bPT if cntry == "PT"
replace betas = bSE if cntry == "SE"
replace betas = bSI if cntry == "SI"

drop bBE-bSI

* Creating Map of betas 
collapse (mean) betas _ID, by(cntry)

format(betas) %12.2f // change values displayed in the legend 

spmap betas using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn) ///
legend(pos(12) row(5) forcesize size(*0.75) ) 


* Creating map of share_heduc 
collapse (mean) share_heduc _ID, by(cntry)

format(share_heduc) %12.2f

spmap share_heduc using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn)  ///
legend(position(3) bplacement(neast) rowgap(1.5) ring(0)) ///
clm(b)



