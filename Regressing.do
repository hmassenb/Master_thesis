* regressing

clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking mihaylov table
cd "C:\Users\Hannah\Documents\Thesis"


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
* to save estimates include in bracket of absorb in front of variable (newvar=absvar) but accord. manual saved fe can be misleading 

* robust might yield inconsistent results if time and i factor are fixed by fe in panel, but maybe use just cluster does the same without that issue
save data1207regressing, replace

* 2012
reghdfe rti country##heduc age mo_heduc if year == 2012, absorb(cntry) vce(cluster nacer2 cntry) 
eststo est2012
margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph12, replace) title("2012")

* 2014
reghdfe rti country##heduc age mo_heduc if year == 2014, absorb(cntry) vce(cluster nacer2 cntry) 
eststo est2014
margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph14, replace) title("2014")

* 2016
reghdfe rti country##heduc age mo_heduc if year == 2016, absorb(cntry) vce(cluster nacer2 cntry) 
eststo est2016
margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph16, replace) title("2016")

* 2018
reghdfe rti country##heduc age mo_heduc if year == 2018, absorb(cntry) vce(cluster nacer2 cntry) 
eststo est2018
margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph18, replace) title("2018")

graph combine graph12 graph14 graph16 graph18, row(2) title("Effect of higher education across countries")






esttab est2012 est2014 est2016 est2018 using table1.tex, replace ///
label nonumbers mtitles("2012" "2014" "2016" "2018")  




reghdfe rti country##heduc age mo_heduc if year==2012, noabsorb vce(cluster cntry) 
margins country, dydx(heduc) atmeans noestimcheck
marginsplot


