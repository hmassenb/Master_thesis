********************
** 7. CONVERGENCE ANALYSIS
********************
* DONT MAKE EASY THINGS HARD!!! <3
************************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis\tables"
set scheme plotplain

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
* RTI 
egen avgrti = mean(rti), by(country year)
gen avgrti2018 = avgrti if year == 2018
egen avgrti2018_country = mean(avgrti2018), by(country)
replace avgrti2018 = avgrti2018_country

gen avgrti2012 = avgrti if year == 2012
egen avgrti2012_country = mean(avgrti2012), by(country)
replace avgrti2012 = avgrti2012_country

gen growth = (avgrti2018 - avgrti2012) / 6  

twoway scatter  growth avgrti2012, ///
mlab(country) msymbol(smcircle) ///
ytitle("Average rate of change (2012 - 2018)") xtitle("RTI in 2012") ///
xline(0) || lfit growth avgrti2012 

reg growth avgrti2012 shareRD share_heduc i.country, robust

reghdfe growth avgrti2012 shareRD share_heduc, abs(country) vce(cluster industry_bins country) resid // -0,048
predict resid, residuals 

* twoway scatter resid avgrti2012, mlab(country)

separate growth, by(country_bin) veryshortlabel
twoway scatter growth? avgrti2012, ///
	mlabel(country) mlab(country country country country country) ///
	msymbol(vsmcircle vsmcircle vsmcircle vsmcircle vsmcircle) ///
	legend(on) mcolor( green green*0.5 gold*0.8  orange*0.8 red*0.7) ///
	mlabsize(vsmall vsmall vsmall vsmall vsmall vsmall) ///
	xlab(#10) ylab(#5) ///
	ytitle("Average rate of change (2012 - 2018)") xtitle("RTI 2012") /// 
	|| lfit  growth avgrti2012, lcol(black*0.6) lpattern(solid) ///
	title("Dynamics over time") ///
	legend( size(small) pos(6) row(1))

*************************
* SIGMA 
*************
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

egen overall_mean_rti = mean(mean_RTI) , by(year)
egen overall_sd_rti = sd(sd_RTI), by(year)

replace overall_mean_rti = overall_mean_rti *-1

* Calculate the sigma ratio
gen sigma_ratio = overall_sd_rti / overall_mean_rti  // *-1 to avoid confusion with negative and negative, easier to interpret it on a positive scale
twoway scatter sigma_ratio year, title("Sigma convergence") 




{
** Unconditional
************************
reg growth avgrti2012
//  coef -.0009616 , corr 0,00
predict uncondi_resid, residuals 
predict fitted

* Singular countries 
twoway scatter uncondi_resid avgrti2012, ///
 msymbol(smcircle) mlab(country) legend(off) ///
xlab(#10) ylab(#10) ytitle("Growth  of RTI") xtit("RTI 2012") ///
|| lfit uncondi_resid avgrti2012, title("Unconditional Beta Convergence")

* Country binned version
separate uncondi_resid, by(country_bin) veryshortlabel
twoway scatter uncondi_resid? avgrti2012, ///
 msymbol(smcircle) mcolor(green orange blue red yellow) legend(on) ///
xlab(#10) ylab(#10) ytitle("Growth  of RTI") xtit("RTI 2012") ///
|| lfit uncondi_resid avgrti2012, title("Unconditional Beta Convergence")


* residuals, y and y hat result in the same graph! 
twoway scatter growth avgrti2012, ///
mlabel(country) msymbol(smcircle) legend(off) ///
xlab(#10) ylab(#10) ytitle("Growth  of RTI") xtit("RTI 2012") ///
|| lfit growth avgrti2012 , title("Unconditional Beta Convergence")

twoway scatter fitted avgrti2012, ///
mlabel(country) msymbol(smcircle) ///
xlab(#10) ylab(#10) ytitle("Growth  of RTI") xtit("RTI 2012") ///
|| lfit fitted avgrti2012 , title("Unconditional Beta Convergence")
*/

** Conditional
********************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis\tables"
set scheme s1mono
drop if _merge==1
destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace
destring RDpcppp, replace
destring shareRD, replace

egen avgrti = mean(rti), by(country year)
gen avgrti2018 = avgrti if year == 2018
egen avgrti2018_country = mean(avgrti2018), by(country)
replace avgrti2018 = avgrti2018_country

gen avgrti2012 = avgrti if year == 2012
egen avgrti2012_country = mean(avgrti2012), by(country)
replace avgrti2012 = avgrti2012_country

gen growth = (avgrti2018 - avgrti2012) / 6 // thats growth rate

reghdfe growth avgrti2012 shareRD share_heduc i.industry_bins i.country i.year  , noabs vce(cluster country year industry_bins) resid
// ceof .2027119 , corr  0.0868
predict condi_resid, residuals 
egen resid = mean(condi_resid), by(country) // to reduce four obs to only one obs per country


twoway scatter resid avgrti2012, ///
mlabel(country) msymbol(smcircle) legend(off) ///
xlab(#10) ylab(#5) ytitle("Growth of RTI") xtitle("RTI 2012") /// 
|| lfit resid avgrti2012 , title("Conditional Beta Convergence") 

separate resid, by(country_bin) veryshortlabel
twoway scatter resid? avgrti2012, ///
 msymbol(smcircle) mlab(country country country country country) mcolor(green orange blue red yellow) legend(on) ///
xlab(#10) ylab(#10) ytitle("Growth  of RTI") xtit("RTI 2012") ///
|| lfit resid avgrti2012, title("Conditional Beta Convergence")



scatter resid mpg, ylabel(0(5000)15000, labels labsize(vsmall) angle(horizontal))
corr resid avgrti2012




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




* Descriptive graphs of created variables here
twoway bar growth country
