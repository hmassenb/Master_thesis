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
use "$ess\data1105.dta" // From 2. Creating
drop if essround <6
rename occupation_typeb isco08, replace

merge m:1 isco08 using "$ess\Mihaylov"
* 14819 not merge from master file 
	* CH, DE, GB, IE above 1000 missing
drop if _merge==1
save "$ess\data0407.dta", replace
