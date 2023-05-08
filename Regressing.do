* regressing


reg heduc age fa_heduc birthplace
reg heduc fa_heduc mo_heduc birthplace  dscrgrp fa_samebirthplace mo_samebirthplace, cluster(cntry) 


reg heduc fa_heduc sex birthplace citizenship dscrgrp fa_samebirthplace mo_samebirthplace c.incomesource, cluster(cntry) 

logit heduc fa_heduc mo_heduc birthplace dscrgrp, cluster(cntry) 
margins heduc fa_heduc mo_heduc birthplace dscrgrp
* father/ mother same birthplace non signi
// when including age mo_heduc and fa_heduc get dropped?