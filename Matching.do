**************
** Matching **
***************
************************

* From now on saving datasets in data!
global ess "C:\Users\Hannah\Documents\Thesis\data"
clear all
use "$ess\categorizeddata.dta"


things to consider{
** within industry!
** within year!
** within country!

* 1. sex, meduc, age migration background (citizenship, father/mother born, ancestry)
*2. sex, age 
*what else? 
*dscrgrp belongs to discriminated group within country -> unclear how consitutes
}

********************************
****** Propensity matching ***** https://www.stata.com/manuals/teteffectsintro.pdf#teteffectsintro
*********************************
tabstat mo_iscedhigheduc sex citizenship age, by(heduc) stat(mean median sd min max n) col(stat) long

by t, sort : summarize  mo_iscedhigheduc sex citizenship age
ttest ratio, by(heduc)

egen double_cluster=group(cntry nacer2)
regress ratio heduc sex age mo_iscedhigheduc , vce(cluster double_cluster)

*********
** ATE ** 
*********
* Estimate by default ATE using logit model 
teffects psmatch (ratio) (heduc sex)

* Estimate ATE (by default) using a probit model
teffects psmatch (y) (t x1 x2, probit)

*********
** ATT ** 
*********
* Estimate ATT and logit model
teffects psmatch (y) (t x1 x2), atet 

* Estimate ATT and probit model
teffects psmatch (y) (t x1 x2, probit), atet 

*************
* Postestimation: use  gen(match)
**********************************

* For example: We need to estimate the ATT using logit model
* Generating a id variable: 
gen id =_n
sort id

* Por exemplo, suponha que deseja calcular o ATT usando o logit
teffects psmatch (y) (t x1 x2), atet gen(match) 


* Generating the Propensity Score (PS)
**************************************

* Usando o comando PREDICT para mostrar o propensy score (p)
predict ps0 ps1, ps

*sort ps1
* Mostre a descrição dos dados
des
* Calculando os resultados potenciais 
predict y0 y1, po


* Resumo dos resultados
tebalance summarize  

* Distribuição do PS
tebalance density 

* Box-plot da distribuição
tebalance box


gen dt_att = 1 if ps1_att > 0.5
recode dt_att .= 0
tab dt_att

pstest bolsa trabalho horas_estudo sexo rend_perc idade, raw treated(dt_att)


plot pms ps1_att

* ATE - LOGIT
teffects psmatch (med) (bolsa trabalho horas_estudo sexo rend_perc idade, logit), ate nn(1) gen(match_ate)
predict ps0_ate ps1_ate, ps

* ATE Com o psmatch2
*psmatch2 t x1 x2, out(y) logit ate
psmatch2 bolsa trabalho horas_estudo sexo rend_perc idade, out(med) logit ate


*plot pms ps1_ate

tebalance summarize  
tebalance density 
tebalance box

*gen dt_ate = 1 if ps1_ate > 0.5
*recode dt_ate .= 0
*tab dt_att


*gen ob=_n
*sort ob
*predict y0 y1, po



* POSESTIMATION: final
*********************

* https://www.stata.com/manuals/teteffectspostestimation.pdf#teteffectspostestimation
teffects psmatch (med) (bolsa trabalho horas_estudo sexo rend_perc idade, probit), atet nn(1)
teffects overlap
tebalance summarize    // Covariate balance summary: compare means and variances in raw and balanced data
tebalance density    // density: kernel density plots for raw and balanced data tebalance density idade
tebalance box   // BOX-PLOT:  box plots for each treatment level for balanced data

teffects psmatch (ratio) (heduc sex mo_iscedhigheduc)


