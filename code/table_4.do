global path ".."

use "$path/data/reds_femalehead_mechanism.dta", clear

*Table 4
reghdfe approached_pradhan_women headfemale womenreserved womenres_headfemale age age_sq totalland_v1 totalhh SCproportion if sex == 1 & age >= 18 & muslim == 0 & issuefaced_women == 1 & castegroup <= 2, a(districtid_num) cl(villageid_numeric)
outreg2 using "$path/output/mechanism_women.tex", replace
summ approached_pradhan_women if e(sample)==1
reghdfe approached_pradhan_women headfemale womenreserved womenres_headfemale age age_sq totalland_v1 totalhh SCproportion if sex == 1 & age >= 18 & muslim == 1 & issuefaced_women == 1 & castegroup <= 2, a(districtid_num) cl(villageid_numeric)
outreg2 using "$path/output/mechanism_women.tex", append
summ approached_pradhan_women if e(sample)==1
reghdfe approached_pradhan_women headfemale womenreserved womenres_headfemale age age_sq totalland_v1 totalhh SCproportion if sex == 1 & age >= 18 & muslim == 0 & issuefaced_women == 1 & castegroup <= 2 & north == 1, a(districtid_num) cl(villageid_numeric) 
outreg2 using "$path/output/mechanism_women.tex", append
summ approached_pradhan_women if e(sample)==1
reghdfe approached_pradhan_women headfemale womenreserved womenres_headfemale age age_sq totalland_v1 totalhh SCproportion if sex == 1 & age >= 18 & muslim == 1 & issuefaced_women == 1 & castegroup <= 2 & north == 1, a(districtid_num) cl(villageid_numeric)
outreg2 using "$path/output/mechanism_women.tex", append see tex label
summ approached_pradhan_women if e(sample)==1
