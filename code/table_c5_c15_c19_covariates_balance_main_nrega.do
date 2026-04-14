global path ".."
use "${path}\data\SBM_panel.dta", clear

drop muslim_share2010 diff

gen temp = muslim_share if post==1
egen muslim_share2015 = min(temp), by(eleid)

drop temp
gen temp = femalereservation if post==1
egen femalereservation2015 = min(temp), by(eleid)

drop temp
egen temp = mean(femalereservation) if post==0, by(eleid)
egen femalereservation2010 = min(temp), by(eleid)

drop temp
egen temp = mean(muslim_share) if post==0, by(eleid)
egen muslim_share2010 = min(temp), by(eleid)

gen diff = muslim_share2015 - muslim_share2010

keep eleid muslim_share2015 femalereservation2010 femalereservation2015 runningvar2_norm_std muslim_share2010 diff
duplicates drop

merge 1:1 eleid using "${path}\data\final election caste sbm.dta"
keep if _merge == 3

label var muslim_share2015 "Muslim share 2015"
label var muslim_share2010 "Muslim share 2010"
label var diff "$\Delta$ Muslim share"
label var female "Female Headed Household"

*Table C5

*Panel A: Covariates balance
replace female_new = femalereservation2015

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls tot_new runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", replace
replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls tot_new runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", append
replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls tot_new runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", append

foreach var in primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop femalereservation2010 muslim_share2015 {

foreach i of numlist 1/3 {
replace bandwidth = .125 - .025*`i'
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls `var' runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if hhtotal!=0 & total_toilet_postsbm <= hhtotal & abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", append
}
}

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls diff runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", append
replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls diff runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", append
replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls diff runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance.tex", append see tex

*Panel B: Pre-treatment outcome balance
replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_13_14_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", replace

replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_13_14_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_13_14_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_14_15_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_14_15_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_14_15_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_15_16_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_15_16_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append

replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_15_16_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome.tex", append see tex

*Table C15: NREGA
ren femalereservation2015 femalereservation
ren muslim_share2015 muslim_share
gen dependent = .
replace dependent = 100*(Labour_exp_disbursed_Lakhs2016 + Material_exp_disbursed_Lakhs2016)/tot_new

replace bandwidth = .1
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (femalereservation = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp.tex", replace
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (femalereservation = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp.tex", append
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (femalereservation = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp.tex", append
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0

replace bandwidth = .1
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp.tex", append
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp.tex", append
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp.tex", append see tex
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0

*Table C19: Difference in Muslim Share
replace dependent = 100*(Labour_exp_disbursed_Lakhs2016 + Material_exp_disbursed_Lakhs2016)/tot_new
replace bandwidth = .1
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share2010 c.runningvar2_norm_std#c.muslim_share2010 c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share2010 diff c.runningvar2_norm_std#c.diff c.femaleinstrument#c.runningvar2_norm_std#c.diff (femalereservation c.femalereservation#c.muslim_share2010 c.femalereservation#c.diff  = femaleinstrument c.femaleinstrument#c.muslim_share2010 c.femaleinstrument#c.diff) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp het_diff.tex", replace
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share2010 c.runningvar2_norm_std#c.muslim_share2010 c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share2010 diff c.runningvar2_norm_std#c.diff c.femaleinstrument#c.runningvar2_norm_std#c.diff (femalereservation c.femalereservation#c.muslim_share2010 c.femalereservation#c.diff  = femaleinstrument c.femaleinstrument#c.muslim_share2010 c.femaleinstrument#c.diff) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp het_diff.tex", append
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = (bandwidth-abs( runningvar2_norm_std ))/bandwidth
ivregress 2sls dependent runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share2010 c.runningvar2_norm_std#c.muslim_share2010 c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share2010 diff c.runningvar2_norm_std#c.diff c.femaleinstrument#c.runningvar2_norm_std#c.diff (femalereservation c.femalereservation#c.muslim_share2010 c.femalereservation#c.diff  = femaleinstrument c.femaleinstrument#c.muslim_share2010 c.femaleinstrument#c.diff) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\NREGA gp het_diff.tex", append see tex
summ dependent if e(sample)==1 &  runningvar2_norm_std<=0