* 4.2 Tasking data with Mihaylov

//Insert path for all final datasets which are ready to use
global ess "C:\Users\Hannah\Documents\Thesis\data"
global onetnew "C:\Users\Hannah\Documents\Thesis\data\Onetnew"

****************************************************

clear all 
import excel using "C:\Users\Hannah\Documents\Thesis\data\Mihaylov.xlsx", firstrow clear
rename *, lower // lower makes all letters small
save "$ess\\Mihaylov.dta", replace


clear all
use "$ess\data0702i.dta" // From 2. Creating
drop if essround <6
rename occupation_typeb isco08, replace

merge m:1 isco08 using "$ess\Mihaylov"
* 14819 not merge from master file 
	* CH, DE, GB, IE above 1000 missing
* Quality check when, where and what is missing - pattern?
tab isco08 year if _merge==1
tab country year if _merge==1

tab isco08 heduc if _merge==1 // 
tab isco08 if _merge==1 // over 100 unmatched:  Process control technicians not elsewhe, Sales workers not elsewhere classified, Domestic, hotel and office cleaners and, Manufacturing labourers, Clerical support workers, Teaching professionals, Services managers not elsewhere classif, Stationary plant and machine operators
* twoway kdensity isco08 if _merge == 1 || kdensity isco08 if _merge==3
// almost identical but in middle field ~ 5000 different



drop if _merge==1





save "$ess\data0407.dta", replace
