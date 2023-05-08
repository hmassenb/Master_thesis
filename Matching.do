**************
** Matching **
***************
************************

* From now on saving datasets in data!
global ess "C:\Users\Hannah\Documents\Thesis\data"
clear all
use "$ess\cleandata.dta"






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
teffects psmatch (occu_risk) (heduc X )