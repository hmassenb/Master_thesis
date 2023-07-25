
*********************
* Creating country averages for digitization values
*********************
clear all 
use data0702i

* string problem for further computations
destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace

** Creating country averages of RTI depending on heduc 
country ///
 BE  CH  CZ DE EE ES FI FR HU GB IE LT NL NO PL PT SE  SI 
         
levelsof heduc, local(levels)    
        
gen rti_avg = . 
gen nra_avg = . 
gen nrm_avg = . 
gen rc_avg = . 
gen rm_avg = . 

foreach cou in $country{
	foreach val of heduc{
	replace rti_avg = mean(rti) if country==`cou' & heduc==`val'
	replace nra_avg = mean(nra) if country==`cou' & heduc==`val'
	replace nrm_avg = mean(nrm) if country==`cou' & heduc==`val'
	replace nri_avg = mean(nri) if country==`cou' & heduc==`val'
	replace rc_avg = mean(rc)   if country==`cou' & heduc==`val'
	replace rm_avg = mean(rm)   if country==`cou' & heduc==`val'
}
}

save "$ess\data1105.dta", replace

