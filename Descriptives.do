******************
** Descriptives **
******************

global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta"


/*tabstat sex age mo_iscedhigheduc nacer2 citizenship dscrgrp incomesource, ///
 by(heduc) ///
 stat(mean sd) ///
 col(stat) ///
 long
 
 
 */


graph bar heduc, over(cntry) sort(heduc)
graph bar rti, over(cntry)
 
 
tabstat heduc citizenship, ///
 by(cntry) ///
 stat(mean sd) /// 
 col(varia)
 
tab heduc, summarize(sex age mo_iscedhigheduc nacer2 )
tabstat heduc rti, by(country) stat(mean sd)

corr rti heduc

reg rti  heduc country heduc#country age sex citizenship, vce(cluster country)

twoway kdensity rti  if heduc == 0, mcol(blue) || kdensity rti  if heduc == 1, mcol(red)

sort country
twoway line avg_rti heduc, by(country)
graph hbar avg_rti, by(country) over(heduc)
 
**************************************************
summarize age sex rti nra nri nrm rc rm  
estpost summarize age sex rti nra nri rc rm nrm 
eststo total

summarize  age sex rti nra nri nrm rc rm if heduc == 0
estpost summarize age sex rti nra nri rc rm nrm if heduc == 0
eststo nonhigh

estpost summarize age sex rti nra nri nrm rc rm  if heduc == 1
eststo high

esttab total nonhigh high using table2.tex, replace main(mean  %6.2f) aux(sd)
