*********
* Treatment intensity

gen high_heduc = 0 
replace high_heduc = 1 if isced_higheduc >= 7

* Base model 
reghdfe rti high_heduc age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year country) vce(cluster industry_bins country year) 

* interacted with country -> very nice 
reghdfe rti high_heduc#country age sex mo_heduc birthplace hh_netincome share_heduc RDpcppp, abs(year) vce(cluster industry_bins country year) 


