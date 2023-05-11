* Tasking using newest data
//Insert path for all final datasets which are ready to use
global ess "C:\Users\Hannah\Documents\Thesis\data"
global onetnew "C:\Users\Hannah\Documents\Thesis\data\Onetnew"
*new source downloaded at https://www.onetcenter.org/database.html

clear all
use "$ess\data1105.dta" // From 2. Creating

iscogen isco08 = isco08(occupation_typea), from(isco88) // only 55 went unmatched
replace isco08 = occupation_typeb if essround >5
drop if isco08 == .
drop if isco08 == .a  
drop if isco08 == .b 
drop if isco08 == .c 
drop if isco08 == .d 
* 23260 obs had been dropped
* 65809 obs left

* merge with prepared "$output\isco08.dta"
merge m:1 isco08 using "$ess\isco08.dta"
tab essround _merge
drop if _merge == 1 // 11228 get dropped and still same pattern that until essround 6 way more unmatched

sort essround // pattern that unmatched esspecially in essround <6 

save "$ess\datatask.dta", replace


clear all 
use "$ess\datatask.dta"

{
* Tasks used by acemoglu & autor (2011) and what it is 
*1) non-routine (analytical):
*Analyzing data or information (4.A.2.a.4), Thinking Creatively (4.A.2.b.2), Interpreting the Meaning of Information for Others (4.A.4.a.1)  

*2) non-routine analytical (interpersonal):
*Establishing and Maintaining Interpersonal Relationships(4.A.4.a.4),	Guiding, Directing, and Motivating Subordinates (4.A.4.b.4), Coaching and Developing Others (4.A.4.b.5)
		
*3) Routine cognitive: 
*Importance of Repeating Same Tasks (4.C.3.b.7),	Importance of Being Exact or Accurate (4.C.3.b.4), Structured versus Unstructured Work(4.C.3.b.8)
		
*4) Routine manual: 
*Pace Determined by Speed of Equipment (4.C.3.d.3),	Controlling Machines and Processes(4.A.3.a.3),	Spend Time Making Repetitive Motions(4.C.2.d.1.i )
		
*5) Non-routine manual: 
*Operating Vehicles, Mechanized Devices, or Equipment (4.A.3.a.4),	Spend Time Using Your Hands to Handle, Control, or Feel Objects, Tools, or Controls(4.C.2.d.1.g),	1.A.2.a.2 replace with 4.A.3.a.2 = Handling an moving objects 
}


global basevar ///
essround idno cntry birthplace citizenship dscrgrp fa_samebirthplace fa_birthplace mo_birthplace mo_samebirthplace sex educ_subject highest_educa highest_educb fa_higheduca fa_higheducb mo_higheduca mo_higheducb educ_year isced_higheduc fa_iscedhigheduc mo_iscedhigheduc employment_type incomesource hh_netincome tporgwk wkhct wkhtot nacer11 nacer2 region jbtsktm netpay stdhrsw stdlvl stdmcdo trndnjb wkovrtm yrskdwk yrspdwk lrnntlf plinsoc yrbrn age heduc fa_heduc mo_heduc isco08 


keep $basevar t_4A2a4 t_4A2b2 t_4A4a1 t_4A4a4 t_4A4b4 t_4A4b5 t_4C3b7 t_4C3b4 t_4C3b8 t_4C3d3 t_4A3a3 t_4C2d1i t_4A3a4 t_4C2d1g t_4A3a2 


* creating a variable which display the average of importance of the task for this occupation. However, I worry about the averaging effect, but might look into ace's 2011 what they did
gen NRA = 0 // non-routine analytical 
replace NRA = (t_4A2a4 + t_4A2b2 + t_4A4a1)/ 3

gen NRI = 0 // non-routine interpersonal
replace NRI = (t_4A4a4 + t_4A4b4 + t_4A4b5)/ 3

gen RC = 0 // Routine cognitive 
replace RC = (t_4C3b7 + t_4C3b4 + t_4C3b8)/ 3

gen RM = 0 // Routine manual
replace RM = (t_4C3d3 + t_4A3a3 + t_4C2d1i) / 3

gen NRM = 0 // non-routine manual 
replace NRM = (t_4A3a4 + t_4C2d1g + t_4A3a2) / 3

* Acemoglu and Autor use standardized version p.1164 
egen NRA_std = std(NRA)
egen NRI_std = std(NRI)
egen RC_std = std(RC)
egen RM_std = std(RM)
egen NRM_std = std(NRM)


save "$ess\categorizeddata.dta", replace