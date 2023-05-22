******************
** Descriptives **
******************

Statistical test: 

https://stats.oarc.ucla.edu/stata/whatstat/what-statistical-analysis-should-i-usestatistical-analyses-using-stata/clear all 


***********************************************************************

global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\categorizeddata.dta"

drop if essround <6

tabstat sex age mo_iscedhigheduc nacer2 citizenship dscrgrp incomesource, ///
 by(heduc) ///
 stat(mean sd) ///
 col(stat) ///
 long
 
ttest mo_iscedhigheduc,by(heduc)
csgof nacer2
 
 
 tabstat heduc citizenship, ///
 by(cntry) ///
 stat(mean sd) /// 
 col(varia)
 
tab heduc, summarize(sex age mo_iscedhigheduc nacer2 )