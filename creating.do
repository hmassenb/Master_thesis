************************
** Creating variables **
************************

* educ related 

** ESS 1 - ESS 5
gen heduc = 0
replace heduc = 1 if essround <= 5 & highest_educa == 5


** ESS 6- ESS 9
replace heduc = 1 if essround >5 & highest_educb > 400 

*** 281225 no higher educ, 107286 higher educ

** Father merging
gen fa_heduc = 0 
replace fa_heduc = 1 if fa_higheduca == 5 // <=5
replace fa_heduc = 1 if fa_higheducb >= 600 // >5
replace fa_heduc = 0 if fa_higheducb >= 5555

** Mother merging
gen mo_heduc = 0 
replace mo_heduc = 1 if mo_higheduca == 5 // <=5
replace mo_heduc = 1 if mo_higheducb >= 600 // >5
replace mo_heduc = 0 if mo_higheducb >= 5555

