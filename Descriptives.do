******************
** Descriptives **
******************
clear all
global ess "C:\Users\Hannah\Documents\Thesis\data"
use "$ess\data0407.dta" // from 4.2 Tasking Mihaylov table
cd  "C:\Users\Hannah\Documents\Thesis\tables"
set scheme plotplain

* Destringing
destring rti, replace
destring nra, replace
destring nrm, replace
destring nri, replace
destring rc, replace
destring rm, replace

* Distribution of higher educ 
{
	
graph bar heduc, over(cntry, sort(heduc) descending) 


tabstat heduc citizenship, by(cntry) stat(mean sd) col(varia) nototal
tabout heduc citizenship  using tablecitizenship.tex, replace ///
 style(tex) 

tabout heduc citizenship sex mo_heduc country using table1.tex, replace ///
style(tex)   ///

 
tab heduc, summarize(sex age mo_iscedhigheduc nacer2 )
tabstat heduc rti, by(country) stat(mean sd)

* Distribution of RTI 
destring rti, replace

graph bar rti, over(cntry) by(year) 
tabstat  rti, by(heduc) statistics(n mean sd min p25 med p75 max) columns(stat) 
** Boxplot
graph box rti, by(heduc)

* Kdensity 
** General 
twoway ///
  (kdensity rti if heduc == 0, mcolor(blue) legend(label(1 "no higher education"))) ///
  (kdensity rti if heduc == 1, mcolor(red) legend(label(2 "higher education")) ///
  xtitle("RTI") ytitle("Kdensity RTI") ///
  title(Distribution of RTI depending on education level))
  
  
* splitted into years
** 2012 
twoway ///
  (kdensity rti if heduc == 0, mcolor(blue) legend(label(1 "no higher education"))) ///
  (kdensity rti if heduc == 1, mcolor(red) legend(label(2 "higher education")) ///
  legend(off) ///
  xtitle("RTI") ytitle("Kdensity RTI") ///
  title(2012) ///
  name(rti2012, replace))

** 2014
twoway ///
  (kdensity rti if heduc == 0, mcolor(blue) legend(label(1 "no higher education"))) ///
  (kdensity rti if heduc == 1, mcolor(red) legend(label(2 "higher education")) ///
  legend(off) ///
  xtitle("RTI") ytitle("Kdensity RTI") ///
  title(2014)  ///
  name(rti2014, replace))
  
** 2016
twoway ///
  (kdensity rti if heduc == 0, mcolor(blue) legend(label(1 "no higher education"))) ///
  (kdensity rti if heduc == 1, mcolor(red) legend(label(2 "higher education")) ///
  legend(off) ///
  xtitle("RTI") ytitle("Kdensity RTI") ///
  title(2016)  ///
  name(rti2016, replace))

** 2018
twoway ///
  (kdensity rti if heduc == 0, mcolor(blue) legend(label(1 "no higher education"))) ///
  (kdensity rti if heduc == 1, mcolor(red) legend(label(2 "higher education")) ///
  legend(off) ///
  xtitle("RTI") ytitle("Kdensity RTI") ///
  title(2018)  ///
  name(rti2018, replace))
  
cd "C:\Users\Hannah\Documents\Thesis\graphs" 
  twoway ///
  kdensity rti if year == 2012, legend(label(1 "2012")) || ///
  kdensity rti if year == 2014, legend(label(2 "2014"))  || ///
  kdensity rti if year == 2016, legend(label(3 "2016"))  || ///
  kdensity rti if year == 2018, legend(label(4 "2018")) 
  save rtioveryears.pdf

grc1leg rti2012 rti2014 rti2016 rti2018 , row(2) title(Distribtution of RTI across education level over years) 


sort country
twoway line avg_rti heduc, by(country)
graph hbar avg_rti, by(country) over(heduc)
corr rti heduc
}
 
 
 
* Occuption composition within industries 
graph bar rti, over(nacer2) by(year)
  
**************************************************
cd  "C:\Users\Hannah\Documents\Thesis\tables"
summarize age sex nacer2 mo_heduc rti nra nri nrm rc rm  
estpost summarize age sex nacer2 mo_heduc rti nra nri rc rm nrm 
eststo total


summarize  age sex nacer2 mo_heduc rti nra nri nrm rc rm if heduc == 0
estpost summarize age sex nacer2 mo_heduc rti nra nri rc rm nrm if heduc == 0
eststo nonhigh
local nonhigh

summarize  age sex nacer2 mo_heduc rti nra nri nrm rc rm if heduc == 1
estpost summarize age sex nacer2 mo_heduc rti nra nri nrm rc rm  if heduc == 1
eststo high 
local higheducation


// Calculate the difference between high and non-high means
global cov ///
age sex nacer2 mo_heduc rti nra nri nrm rc rm

foreach var in $cov{
	egen mean_`var'_1 = mean(`var') if heduc == 1
	egen mean_`var'_0 = mean(`var') if heduc == 0
	replace mean_`var'_1= mean_`var'_1[_n-1] if mean_`var'_1==.
	replace mean_`var'_1= mean_`var'_1[_n+1] if mean_`var'_1==.
	replace mean_`var'_0= mean_`var'_0[_n-1] if mean_`var'_0==.
	replace mean_`var'_0= mean_`var'_0[_n+1] if mean_`var'_0==.
}

foreach var in $cov{
		gen diff_mean_`var' = mean_`var'_1 - mean_`var'_0
}

global diffmeancov ///
diff_mean_age diff_mean_sex diff_mean_nacer2 diff_mean_mo_heduc diff_mean_rti diff_mean_nra diff_mean_nri diff_mean_nrm diff_mean_rc diff_mean_rm

summarize  $diffmeancov
estpost summarize $diffmeancov
eststo diff
local diff

// Now use esttab to create the table with the new difference row
esttab total nonhigh high diff using descri.tex, replace ///
	cells("mean(fmt(%6.2f))") label ///
    mtitles("Total" "Non-High" "High" "Difference") ///
    title("Comparison of Means") ///
    stats(N  labels("Observations")) ///
    nonum



*********************************
graph hbar rti, over(nacer2, label(labsize(tiny))) bargap(1000) 
tab nacer2 if rti > 0
tab isco08 if rti > 0

probit 
