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

* 2012
eststo est2012: reghdfe rti country##heduc age sex mo_heduc if year == 2012, absorb(country, savefe) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph12, replace) title("2012") yline(-0.2)

* 2014
eststo est2014: reghdfe rti country##heduc age sex mo_heduc if year == 2014, absorb(country) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph14, replace) title("2014") yline(-0.2)

* 2016
eststo est2016: reghdfe rti country##heduc age sex mo_heduc if year == 2016, absorb(country) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph16, replace) title("2016") yline(-0.2)

* 2018
eststo est2018: reghdfe rti country##heduc age sex mo_heduc if year == 2018, absorb(country) vce(cluster nacer2 country) 

margins country, dydx(heduc) atmeans noestimcheck post
marginsplot, recast(line) name(graph18, replace) title("2018") yline(-0.2)

graph combine graph12 graph14 graph16 graph18, row(2) title("Effect of higher education across countries")


**** Current ideas/hopes 
* sumhdfe
* esttab but with if heduc == 1 
* estfe


* Prepare estimates for -estout-
estfe  est2012 est2014 est2016 est2018
esttab est2012 est2014 est2016 est2018
* Run estout/esttab
	esttab . model* , indicate("Length Controls=length" `r(indicate_fe)')
		
* Return stored estimates to their previous state
	estfe . model*, restore
esttab est2012 est2014 est2016 est2018 using allcountriesreg.tex, ///
coeflegend(country##heduc )  ///
label nonumbers mtitles("2012" "2014" "2016" "2018")

foreach cou in country {
	gen `country_heduc' = `country'##heduc if heduc == 1
}


esttab _all
Big data tip If you perform commands (esp. tests, regressions) only on
subsets of the data, drop the obs you don't use as early as possible in your
code. If you loop over subsets, use preserve and then drop instead of the
command with an if condition.





// Export the selected results to LaTeX using esttab with coeflegend() option
esttab, coeflegend label nonumbers mtitles("2012" "2014" "2016" "2018") ///
    cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))  ///
    title("Comparison of Means") replace ///
    caption("Your table caption here.") ///
    booktabs
	
esttab, coefvars(country##heduc) label nonumbers mtitles("2012" "2014" "2016" "2018") ///
    cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))  ///
    title("Comparison of Means") replace ///
    caption("Your table caption here.") ///
    booktabs




esttab est2012 est2014 est2016 est2018 using table1.tex, replace ///
label nonumbers mtitles("2012" "2014" "2016" "2018")  




reghdfe rti country##heduc age mo_heduc if year==2012, noabsorb vce(cluster cntry) 
margins country, dydx(heduc) atmeans noestimcheck
marginsplot


