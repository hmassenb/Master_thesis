* Bridging new
clear all
global onetnew "C:\Users\Hannah\Documents\Thesis\data\Onetnew"

//insert the path to your crosswalks directory.
global crosswalks "C:\Users\Hannah\Documents\Thesis\all about merge and prep task"

//Insert path for all final datasets which are ready to use
global ess "C:\Users\Hannah\Documents\Thesis\data"

MAYBE ADDING ABILITY SHEET SINCE ACEMOGLUS CLASSIFICATION CONSIDERS 1.A which is probably in the Ability file 
*import excel using "$onetnew\\Occupation Data.xlsx", firstrow clear
*	rename *, lower // lower makes all letters small
*save "$onetnew\\occupation.dta", replace

*import excel using "$onetnew\\Work Activities.xlsx", firstrow clear
*	rename *, lower // lower makes all letters small
*save "$onetnew\\Work Activities.dta", replace

*import excel using "$onetnew\\Work Context.xlsx", firstrow clear
*	rename *, lower // lower makes all letters small
*save "$onetnew\\Work Context.dta", replace


clear all
use "$onetnew\occupation"  
* rename  ONETSOCCode onetsoccode

append using "$onetnew\Work Context.dta", keep(scaleid datavalue onetsoccode elementid)
append using "$onetnew\Work Activities.dta", keep(scaleid datavalue onetsoccode elementid)

//keep only the needed measurements 
keep if scaleid=="IM" | scaleid=="CX" // importance ranking "Not Important" (1) to "Extremely Important" (5)

drop title description
drop scaleid

//simplify values and names
rename datavalue score
replace elementid=subinstr(elementid, ".", "", 5) // Deletes dots between elementid values

//reshape so that each ONET-SOC code has one observation with all task measures 
reshape wide score, i(onetsoccode) j(elementid) string
//simplify names
renpfix score t_ // replace all "score" with t_ 

save "$onetnew\transformed_soc10.dta", replace


{
//some correction for the calculation of task contents (scale reversion of selected items) DONT KNOW YET WHAT THIS DO
* gen t_4C3b8_rev=6-t_4C3b8
* gen t_4C1a2l_rev=6-t_4C1a2l
* gen t_4C2a3_rev=6-t_4C2a3
* foreach var in t_4A4a4 t_4A4a5 t_4A4a8 t_4A4b5 t_4A1b2 t_4A3a2 t_4A3a3 t_4A3a4 t_4A3b4 t_4A3b5 {
*	gen `var'_rev = 6-`var'
}

clear all
use "$onetnew\transformed_soc10.dta"
sort onetsoccode
rename onetsoccode soc10
*replace soc10=subinstr(soc10, ".", "", .)
gen soc10_short = substr(soc10, 1, strpos(soc10, ".")-1) //here soc on rhs as var soc10_short just got created 
replace soc10_short = subinstr(soc10_short, "-", "", .) // just replacing existing soc10_short without the hyphen

save "$onetnew\soc10NEW.dta", replace


//from SOC 10 to ISCO-08
use "$onetnew\soc10.dta", clear
destring soc10_short, replace
drop soc10
rename soc10_short soc10
	joinby soc10 using "$crosswalks\soc10_isco08.dta" 
	collapse (mean) t_*, by(isco08) // only one isco left with multiple tasks
	
*renpfix t_ ""
	
save "$ess\isco08.dta", replace