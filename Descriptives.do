******************
** Descriptives **
******************

clear all 
use "$ess\categorizeddata.dta"

drop if essround <6

tabstat sex isced_higheduc mo_iscedhigheduc, ///
 by(cntry) ///
 stat(mean sd) ///
 col(variables) 
 
 
 tabstat heduc citizenship, ///
 by(cntry) ///
 stat(mean sd) /// 
 col(varia)
 
