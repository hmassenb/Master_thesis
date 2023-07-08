* regressing

clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
drop if _merge==1
destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace

reg heduc age fa_heduc birthplace
reg heduc fa_heduc mo_heduc birthplace  dscrgrp fa_samebirthplace mo_samebirthplace, cluster(cntry) 

reg heduc fa_heduc sex birthplace citizenship dscrgrp fa_samebirthplace mo_samebirthplace c.incomesource, cluster(cntry) 
 
reghdfe rti heduc age mo_heduc, absorb(cntry year nacer2)
* to save estimates include in bracket of absorb in front of variable (newvar=absvar)
* robust might yield inconsistent results if time and i factor are fixed by fe in panel, but maybe use just cluster does the same without that issue
reghdfe rti heduc age mo_heduc, absorb(cntry year) vce(cluster nacer2 cntry year)
eststo 
esttab 


logit heduc fa_heduc mo_heduc birthplace dscrgrp, cluster(cntry) 
margins heduc fa_heduc mo_heduc birthplace dscrgrp
* father/ mother same birthplace non signi
// when including age mo_heduc and fa_heduc get dropped?