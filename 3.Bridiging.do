/*
*******************************
Hardy, W., Keister, R. and Lewandowski, P. (2018). Educational upgrading, structural change and the task composition of jobs in Europe. Economics Of Transition 26.
For details, you can find the paper here: https://onlinelibrary.wiley.com/doi/full/10.1111/ecot.12145
*******************************

*******************************
Other Notes
* The code below was last run for the 20.1 O*NET dataset release (2015).
* Parts of the code are based on the do-files provided on the website of David Autor (http://economics.mit.edu/faculty/dautor/data/acemoglu) and his measures of task content.
* The initial conversion to .dta format might be different for previous years (that are not in .xlsx), but should pose no problems.
*******************************
*/


//insert the path to your .xlsx O*NET data directory. Files required for the derivation of task content items:

* Work Activities.xlsx
* Work Context.xlsx
//downloaded from: https://www.onetcenter.org/database.html . 
global source "C:\Users\Hannah\Documents\Thesis\all about merge and prep task\required for merge"

//insert the path to your crosswalks directory.
global crosswalks "C:\Users\Hannah\Documents\Thesis\all about merge and prep task"

//insert the path for your output files (the do-file will create several .dta files along the way - one for each classification).
global output "C:\Users\Hannah\Documents\Thesis\all about merge and prep task"


{
//save the data in .dta format.
*import excel using "$source\\Abilities.xlsx", firstrow clear
*	rename *, lower
*save "$source\\Abilities.dta", replace

*import excel using "$source\\Skills.xlsx", firstrow clear
*	rename *, lower
*save "$source\\Skills.dta", replace
}

*already done
{
clear all	
import excel using "$source\\Work Activities.xlsx", firstrow clear
	rename *, lower // lower makes all letters small
save "$source\\Work Activities.dta", replace

import excel using "$source\\Work Context.xlsx", firstrow clear
rename *, lower
save "$source\\Work Context.dta", replace

import excel using "C:\Users\Hannah\Documents\Thesis\all about merge and prep task\required for merge\Occupation Data.xlsx", firstrow clear
rename *, lower
save "$source\\occupation.dta", replace
}
//append the prepared O*NET data, but only the needed variables!! I have added all so far probably not necessary!!!!

clear all
use "$source\occupation"  
* rename  ONETSOCCode onetsoccode

{
*append using "$source\Abilities.dta", keep(scaleid datavalue onetsoccode elementid)
*append using "$source\Skills.dta", keep(scaleid datavalue onetsoccode elementid)
}

append using "$source\Work Context.dta", keep(scaleid datavalue onetsoccode elementid)
append using "$source\Work Activities.dta", keep(scaleid datavalue onetsoccode elementid)

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

save "$source\transformed_soc10.dta"



//some correction for the calculation of task contents (scale reversion of selected items) DONT KNOW YET WHAT THIS DO
* gen t_4C3b8_rev=6-t_4C3b8
* gen t_4C1a2l_rev=6-t_4C1a2l
* gen t_4C2a3_rev=6-t_4C2a3
* foreach var in t_4A4a4 t_4A4a5 t_4A4a8 t_4A4b5 t_4A1b2 t_4A3a2 t_4A3a3 t_4A3a4 t_4A3b4 t_4A3b5 {
*	gen `var'_rev = 6-`var'
*}

clear all
use "$source\transformed_soc10.dta"
sort onetsoccode
rename onetsoccode soc10
*replace soc10=subinstr(soc10, ".", "", .)
gen soc10_short = substr(soc10, 1, strpos(soc10, ".")-1) //here soc on rhs as var soc10_short just got created 
replace soc10_short = subinstr(soc10_short, "-", "", .) // just replacing existing soc10_short without the hyphen

save "$output\soc10.dta", replace


//from SOC 10 to ISCO-08
use "$output\soc10.dta", clear
destring soc10_short, replace
drop soc10
rename soc10_short soc10
	joinby soc10 using "$crosswalks\soc10_isco08.dta" 
	collapse (mean) t_*, by(isco08) // only one isco left with multiple tasks
	
*renpfix t_ ""
	
save "$output\isco08.dta", replace




******************************************************************************************************************************************************
* Crosswalk from isco88 to isco08
** Destring the variables which are used to joinby since they are stringed

use "$crosswalks\isco88_soc00"
destring isco88, replace
save "$crosswalks\isco88_soc00_destring.dta", replace 

use "$crosswalks\soc00_soc10", clear
destring soc2000, replace
rename soc2000 soc00
rename soc2010 soc10
destring soc10, replace
save "$crosswalks\soc00_soc10_destring.dta", replace

use "$crosswalks\soc10_isco08", clear
destring soc10, replace
save "$crosswalks\soc10_isco08_destring.dta", replace

use "$crosswalks\"

global ess "C:\Users\Hannah\Documents\Thesis\data"
clear all
use "$ess\cleandata.dta"


gen isco88 = occupation_typea
drop if isco88 == .a 
drop if isco88 == .b
drop if isco88 == .c
drop if isco88 == .d

replace isco

destring isco88, replace
	joinby isco88 using "$crosswalks\isco88_soc00_destring.dta" 
isco88 to soc00 
soc00 to soc10
soc 10 to isco08


















