********************
** 7. CONVERGENCE ANALYSIS
********************
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

* SIGMA CONVERGENCE 
// nice formula for sigma : 
// https://www.tandfonline.com/doi/pdf/10.1080/1331677X.2022.2142814
************************
egen mean_RTI = mean(rti), by(year country)
egen sd_RTI = sd(rti), by(year country)

egen overall_mean_rti = mean(mean_RTI), by(year)
egen overall_sd_rti = sd(sd_RTI), by(year)

* Calculate the sigma ratio
gen sigma_ratio = overall_sd_rti / overall_mean_rti
replace sigma_ratio = sigma_ratio 

twoway scatter sigma_ratio year, title("Sigma convergence") 


* BETA CONVERGENCE
************************
* RTI 
** Unconditional
egen avgrti = mean(rti), by(country year)
gen avgrti2018 = avgrti if year == 2018
egen avgrti2018_country = mean(avgrti2018), by(country)
replace avgrti2018 = avgrti2018_country

gen avgrti2012 = avgrti if year == 2012
egen avgrti2012_country = mean(avgrti2012), by(country)
replace avgrti2012 = avgrti2012_country

gen growth = (avgrti2018 - avgrti2012) / 6 // thats growth rate


reg growth avgrti2012
twoway scatter growth avgrti2012, mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit growth avgrti2012 , title("Unconditional Beta-Convergence")

** Conditional
reg growth avgrti2012 shareRD share_heduc
predict condi_resid, residuals
sum condi_resid

twoway scatter condi_resid avgrti2012, mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit condi_resid avgrti2012 , title("Conditional Beta-Convergence") 


* Log version 
{
* generating dependent var (growth rate)
gen diff_avgrti = avgrti2018 - avgrti2012
gen logdiff_avgrti = log(diff_avgrti)
* Creating right hand side 
local constant = abs(0.1218751) + 0.001  // Adjust 0.001 
gen shifted_avgrti = diff_avgrti + `constant'
gen log_transformed_variable = log(shifted_avgrti)

local constant = 0.6214027 +0.001
gen shifted_rti12 = avgrti2012 + `constant'
gen logavgrti12 = log(shifted_rti12)
 
reg log_transformed_variable  logavgrti12
twoway scatter log_transformed_variable logavgrti12, mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) // really not nice two outliers the rest is clustered in a nuage withouth any pattern of correlation

reg shifted_avgrti shifted_rti12
twoway scatter shifted_avgrti shifted_rti12, mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit shifted_avgrti shifted_rti12
}



********************************************
* Change of rti based on initial heduc share level 
egen share_heduc12 = total(share_heduc) if year == 2012
egen educ12 = total(share_heduc12), by(country)

reg growth educ12

twoway scatter growth educ12, mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit growth avgrti2012




*****************************************************
** BETAS 
{
* 2012
eststo inter_country12: reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp if year == 2012, noabs vce(cluster industry_bins country) 

matrix coeff = e(b)
matrix list coeff
svmat coeff
drop coeff1-coeff18
drop coeff37-coeff44

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
 
gen betas12 = . 
replace betas12 = bBE if cntry == "BE"
replace betas12 = bCH if cntry == "CH"
replace betas12 = bCZ if cntry == "CZ"
replace betas12 = bDE if cntry =="DE"
replace betas12 = bEE if cntry == "EE"
replace betas12 = bES if cntry == "ES"
replace betas12 = bFI if cntry == "FI"
replace betas12 = bFR if cntry == "FR"
replace betas12 = bGB if cntry == "GB"
replace betas12 = bHU if cntry == "HU"
replace betas12 = bIE if cntry == "IE"
replace betas12 = bLT if cntry == "LT" 
replace betas12 = bNL if cntry == "NL"
replace betas12 = bNO if cntry == "NO"
replace betas12 = bPL if cntry == "PL"
replace betas12 = bPT if cntry == "PT"
replace betas12 = bSE if cntry == "SE"
replace betas12 = bSI if cntry == "SI"

drop bBE-bSI

* 2018
eststo inter_country18: reghdfe rti heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp if year == 2018, noabs vce(cluster industry_bins country) 
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
 


gen betas18 = . 
replace betas18 = bBE if cntry == "BE"
replace betas18 = bCH if cntry == "CH"
replace betas18 = bCZ if cntry == "CZ"
replace betas18 = bDE if cntry =="DE"
replace betas18 = bEE if cntry == "EE"
replace betas18 = bES if cntry == "ES"
replace betas18 = bFI if cntry == "FI"
replace betas18 = bFR if cntry == "FR"
replace betas18 = bGB if cntry == "GB"
replace betas18 = bHU if cntry == "HU"
replace betas18 = bIE if cntry == "IE"
replace betas18 = bLT if cntry == "LT" 
replace betas18 = bNL if cntry == "NL"
replace betas18 = bNO if cntry == "NO"
replace betas18 = bPL if cntry == "PL"
replace betas18 = bPT if cntry == "PT"
replace betas18 = bSE if cntry == "SE"
replace betas18 = bSI if cntry == "SI"

drop bBE-bSI
drop _est_inter_country18 _est_inter_country12

* log version 
gen diff = betas18 - betas12 + 1
gen logdiff = log(diff)
replace logdiff = logdiff *-1

gen shifted_betas12 = betas12 + 1
gen log_shifted_betas12 = log(shifted_betas12)
replace log_shifted_betas12 = log_shifted_betas12*-1

reg logdiff log_shifted_betas12
twoway scatter logdiff log_shifted_betas12, mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit logdiff log_shifted_betas12


* average growth rate
gen growth_betas = (betas18 - betas12) / 6
reg growth_betas betas12
twoway scatter growth_betas betas12 , mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit growth_betas betas12

* absolute change
gen diff2 = betas18 - betas12 
reg diff2 betas12
twoway scatter diff2 betas12 , mlabel(country) msymbol(smcircle) xlab(#10) ylab(#10) || lfit diff2 betas12, title("Unconditional Beta-convergence of Coefficient")

