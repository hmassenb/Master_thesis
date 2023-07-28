*******************
** Data cleaning **
*******************

clear all 
cd "C:\Users\Hannah\Documents\Thesis"
use "C:\Users\Hannah\Documents\Thesis\data\selected years selected\ESS-Data-Wizard-subset-2023-02-07.dta"
global ess "C:\Users\Hannah\Documents\Thesis\data"

* labelling 
rename brncntr birthplace
rename ctzcntr citizenship
rename facntr fa_samebirthplace
rename fbrncnt fa_birthplace
rename lnghoma language1
rename lnghomb language2
rename mbrncnt mo_birthplace
rename mocntr mo_samebirthplace
rename gndr sex
rename anctry1 ancestor1
rename anctry2 ancestor2
rename atncrse training
rename edufld educ_subject
rename edulvla highest_educa
rename edulvlb highest_educb
rename edulvlfa fa_higheduca
rename edulvlfb fa_higheducb
rename edulvlma mo_higheduca
rename edulvlmb mo_higheducb
rename eduyrs educ_year
rename eisced isced_higheduc
rename eiscedf fa_iscedhigheduc
rename eiscedm mo_iscedhigheduc
rename emplrel employment_type
rename hincsrca incomesource
rename hinctnta hh_netincome
rename isco08 occupation_typeb // since ESS 6
rename iscoco occupation_typea // until ESS 5

drop edition proddate dweight pspwght pweight anweight prob stratum psu pdwrkcr uemp12m uemp3m uemp5yr nacer11

*Discrimination variables
drop dscrage dscrdk dscrdsb dscretn dscrgnd dscrlng dscrna dscrnap dscrntn dscroth dscrrce dscrref dscrrlg dscrsex language1 language2 age ancestor1 ancestor2 training chldhhe chldhm crpdwk


drop hincfel mainact mnactic rtrd 

* Regional variables 
drop regionat regionbe regionbg regioach regioncy regioncz regioacz regiondk regioadk regionee regiones regioaes regioafi regionfr regiongb regiongr regioagr regionhr regionhu regionie regioaie regiobie regionil regionis regionit regionlt regionlu regionlv regionnl regionno regionpl regionpt regioapt regionro regionru regionse regionsi regionsk regiontr regionua regunit 

drop inwyr inwyye ipjbhin ipjbini ipjbprm ipjbscr ipjbtro ipjbwfm jbcoedu jbedyrs jblrn smblvjb truinwk uemp3y wkjbndm yrcremp jbintr jbstrs lotsgot lrnnew plprftr stfjb stflfsf stfsdlv smbtjoba stfjbot stfmjob

* not existent in my chosen years
drop jbtsktm netpay stdhrsw stdlvl stdmcdo trndnjb wkovrtm yrskdwk yrspdwk educ_subject mo_birthplace fa_birthplace

*********************************
** Time and country constraint
********************************* 
* Which countries are consistent essround >=6
tab  cntry essround
list cntry 
local drop_cntry ///
"AL" "AT" "BG" "CY" "DK" "GR" "HR" "IS" "IT" "LU" "LV" "ME" "RO" "RS" "RU" "SK" "TR" "UA" "XK" "IL"

drop if cntry == "AL" | cntry == "AT" | cntry == "BG"  | cntry == "CY"  | cntry ==  "DK" | cntry == "GR" | cntry == "HR" | cntry == "IS" | cntry == "IT"  | cntry == "LU" | cntry == "LV" | cntry == "ME" | cntry == "RO" | cntry == "RS" | cntry == "RU" | cntry == "SK" | cntry == "TR" | cntry == "UA"| cntry == "XK" | cntry == "IL"


save "$ess\data0702.dta", replace




* notes
/*
- highest educ and highest educ according to isced dont deliever same numbers maybe considering digging deeper in differences of that

- aggregating discri variable later on is dropped in the meantime 

- could be interesting to control for partner status in combi with kids? people who are alone with double responsibility 

- educ years > 12 != higher educ -> repetitioners!!

- dropping countries with low observations!
*/ 