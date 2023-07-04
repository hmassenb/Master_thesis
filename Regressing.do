* regressing


reg heduc age fa_heduc birthplace
reg heduc fa_heduc mo_heduc birthplace  dscrgrp fa_samebirthplace mo_samebirthplace, cluster(cntry) 


reg heduc fa_heduc sex birthplace citizenship dscrgrp fa_samebirthplace mo_samebirthplace c.incomesource, cluster(cntry) 

logit heduc fa_heduc mo_heduc birthplace dscrgrp, cluster(cntry) 
margins heduc fa_heduc mo_heduc birthplace dscrgrp
* father/ mother same birthplace non signi
// when including age mo_heduc and fa_heduc get dropped?


clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta"
drop if _merge==1

global yrcntry ///
cntry#year
 reg rti heduc, vce(cluster yrcntry)
 
 
 reghdfe for twoway absorbed fixed effects