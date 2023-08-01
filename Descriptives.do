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
  
************************
** Descriptive table 
**************************
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

*****************************
** Industry related
graph bar, over(industry, label(labsize(tiny))) by(country)
graph bar, over(industry_bin, label(labsize(tiny))) by(country)
destring industry_bins, replace 
graph bar rti, over(industry_bins)

graph hbar rti, over(nacer2, label(labsize(tiny))) bargap(1000) 
twoway kdensity nacer2 if rti > 0, col("red")|| kdensity nacer2 if rti < -0.5 ///
, title("Distribution of industry dependent on rti value") ///
note("red: RTI > 0, grey: RTI < -0.5")



******************************
** Based on reg7 reg7fe where sex and country seem to display largest impact
********************************
twoway kdensity rti if sex == 2, by(country) col("blue")|| kdensity rti if sex == 1, by(country) col("orange")


set scheme s2color

twoway (kdensity rti if cntry == "BE") || ///
(kdensity rti if cntry == "CH") || ///
(kdensity rti if cntry == "CZ") || ///
(kdensity rti if cntry == "DE") || ///
(kdensity rti if cntry == "EE") || ///
(kdensity rti if cntry == "ES") || ///
(kdensity rti if cntry == "FI") || ///
(kdensity rti if cntry == "FR") || ///
(kdensity rti if cntry == "GB") || ///
(kdensity rti if cntry == "HU") || ///
(kdensity rti if cntry == "IE") || ///  
(kdensity rti if cntry == "LT") || ///
(kdensity rti if cntry == "NL") || ///
(kdensity rti if cntry == "PL") || ///
(kdensity rti if cntry == "NO") || ///
(kdensity rti if cntry == "PT") || ///
(kdensity rti if cntry == "SE") || ///
(kdensity rti if cntry == "SI"), legend(order(1 "BE" 2 "CH" 3 "CZ" 4 "DE" 5 "EE" 6 "ES" 7 "FI" ///
8 "FR" 9 "GB" 10 "HU" 11 "IE" 12 "LT" 13 "NL" 14 "PL" 15 "NO" 16 "PT" 17 "SE" 18 "SI")) ///
title("RTI's distribution across countries")




legend(order(1 "BE" 2 "CH))

