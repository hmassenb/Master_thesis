*******************
** Data cleaning **
*******************

clear all 
cd "C:\Users\Hannah\Documents\Thesis"
use "C:\Users\Hannah\Documents\Thesis\data\selected years selected\ESS-Data-Wizard-subset-2023-02-07.dta"


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

drop edition proddate dweight pspwght pweight anweight prob stratum psu pdwrkcr uemp12m uemp3m uemp5yr

*Discrimination variables
drop dscrage dscrdk dscrdsb dscretn dscrgnd dscrlng dscrna dscrnap dscrntn dscroth dscrrce dscrref dscrrlg dscrsex language1 language2 age ancestor1 ancestor2 training chldhhe chldhm crpdwk


drop hincfel mainact mnactic rtrd 

* Regional variables 
drop regionat regionbe regionbg regioach regioncy regioncz regioacz regiondk regioadk regionee regiones regioaes regioafi regionfr regiongb regiongr regioagr regionhr regionhu regionie regioaie regiobie regionil regionis regionit regionlt regionlu regionlv regionnl regionno regionpl regionpt regioapt regionro regionru regionse regionsi regionsk regiontr regionua regunit 

drop inwyr inwyye ipjbhin ipjbini ipjbprm ipjbscr ipjbtro ipjbwfm jbcoedu jbedyrs jblrn smblvjb truinwk uemp3y wkjbndm yrcremp jbintr jbstrs lotsgot lrnnew plprftr stfjb stflfsf stfsdlv smbtjoba stfjbot stfmjob


************************************************
!!!!!!!!!!!!!!!!!!!!!!!!!!!!
STOPPED HERE 
gen age = 0
replace age = ESS ROUND (YEAR) - Birthyear
drop if yrbrn < 1980 // people have 20 years after joining labor force where they are still more flexible ADOPTING IT TO EACH YEAR AND ALLOWING FOR UP TO 45 years


drop if yrbrn == .a 
drop if yrbrn == .b
* drop if rtrd == 1, weirdly there exist individuals that are already retired even though they are born until 2003????


save data0702.dta, replace


* categorization




* notes
/*
- highest educ and highest educ according to isced dont deliever same numbers maybe considering digging deeper in differences of that

- aggregating discri variable later on is dropped in the meantime 

- could be interesting to control for partner status in combi with kids? people who are alone with double responsibility 

- educ years > 12 != higher educ -> repetitioners!!

- dropping countries with low observations!
*/ 