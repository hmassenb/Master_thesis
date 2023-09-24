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

save readytomap.dta , replace 

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

**********************************
* Creating map of share_heduc 
**********************************
clear all
use readytomap

collapse (mean) share_heduc _ID, by(cntry)

format(share_heduc) %12.2f

spmap share_heduc using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn)  ///
legend(position(3) bplacement(neast) rowgap(1.5) ring(0)) ///
clm(b)

**********************************
* Creating map of country bins 
**********************************
clear all 
use readytomap

* label define Regions 1 "South" 2 "West" 3 "North" 4 "East"  5 "Islands"
gen coeff_bin = . 
replace coeff_bin = -.2085462 if country_bin == 1
replace coeff_bin = -.22607  if country_bin == 2
replace coeff_bin =  -.2560904  if country_bin == 3
replace coeff_bin = -.1353804  if country_bin == 4
replace coeff_bin = -.1827005  if country_bin == 5

collapse (mean) coeff_bin _ID, by(cntry) 
// collapse by(cntry) is crucial to get whole europe
format(coeff_bin) %12.2f

spmap coeff_bin using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn)  ///
clm(custom) clb(-0.35 -0.28 -0.22  -0.17 -0.11) legend(pos(12) row(5) forcesize size(*0.75) ) 



* Account for outliers in country bins
**********************************
clear all
use "C:\Users\Hannah\Documents\Thesis\data\readytomap.dta"
replace country_bin = 6 if cntry == "CH" 
replace country_bin = 6 if cntry ==  "NL"
replace country_bin = 7 if cntry == "PL"

label define Länder 1 "South" 2 "West" 3 "North" 4 "East"  5 "Islands" 6 "Swiss + Netherl" 7 "Poland"
label  values  country_bin Länder

reghdfe rti heduc#country_bin age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins year country)

gen coeff_bin = . 
replace coeff_bin = -.210733  if country_bin == 1
replace coeff_bin =  -.2081617 if country_bin == 2
replace coeff_bin = -.2560979  if country_bin == 3
replace coeff_bin =  -.135942   if country_bin == 4
replace coeff_bin =  -.1828413  if country_bin == 5
replace coeff_bin =   -.28732  if country_bin == 6
replace coeff_bin =  -.3483343  if country_bin == 7

collapse (mean) coeff_bin _ID, by(cntry) 
// collapse by(cntry) is crucial to get whole europe
format(coeff_bin) %12.2f

spmap coeff_bin using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn)  ///
clmethod(custom) clb(-0.35 -0.28 -0.22  -0.17 -0.11) legend(pos(12) row(5) forcesize size(*0.75) ) 

* Heterogeneity 
**********************************+
clear all
use "C:\Users\Hannah\Documents\Thesis\data\readytomap.dta"
* MEN
reghdfe rti heduc#country age mo_heduc birthplace hh_netincome share_heduc RDpcppp if sex == 1, abs(year) vce(cluster industry_bins year country)
matrix coeff = e(b)
matrix list coeff
svmat coeff
drop coeff1-coeff18
drop coeff37-coeff43

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
tab betas
* Creating Map of betas 
collapse (mean) betas _ID, by(cntry)
tab betas
format(betas) %12.2f // change values displayed in the legend 

spmap betas using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn) ///
legend(pos(12) row(5) forcesize size(*0.75) ) ///
clmethod(custom) clb(-0.43 -0.28 -0.22  -0.17 -0.10)

* WOMEN
**********************************+
clear all
use "C:\Users\Hannah\Documents\Thesis\data\readytomap.dta"
reghdfe rti heduc#country age mo_heduc birthplace hh_netincome share_heduc RDpcppp if sex == 2, abs(year) vce(cluster industry_bins year country)
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
tab betas

format(betas) %12.2f // change values displayed in the legend 

spmap betas using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn) ///
legend(pos(12) row(5) forcesize size(*0.75) ) ///
clmethod(custom) clb(-0.43 -0.28 -0.22  -0.17 -0.10)

* Differenz between men and women (calculated from excel since the betas are determined in two extra files and its late and copying was easier rn)

replace betas = -0.0073503 if cntry == "BE"
replace betas = 0.0171627 if cntry == "CH"
replace betas = -0.0016229 if cntry == "CZ"
replace betas = -0.0053889 if cntry == "DE"
replace betas = -0.0736103 if cntry == "EE"
replace betas = -0.0364856 if cntry == "ES"
replace betas = -0.1540047 if cntry == "FI"
replace betas = -0.0034761 if cntry == "FR"
replace betas = -0.0216579 if cntry == "GB"
replace betas = -0.0635207 if cntry == "HU"
replace betas = -0.1627177 if cntry == "IE"
replace betas = -0.1008019 if cntry == "LT"
replace betas = 0.1006693 if cntry == "NL"
replace betas = 0.0372782 if cntry == "NO"
replace betas = 0.0754405 if cntry == "PL"
replace betas = 0.0992929 if cntry == "PT"
replace betas = 0.0499241 if cntry == "SE"
replace betas = -0.0227682 if cntry == "SI"

format(betas) %12.2f // change values displayed in the legend 

spmap betas using "C:\Users\Hannah\Documents\Thesis\data\Map\second try\CNTR_RG_10M_2020_3035.shp\another_shp.dta" , ///
id(_ID) fcolor(RdYlGn) ///
legend(pos(12) row(5) forcesize size(*0.75) ) 



