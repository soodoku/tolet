global path ".."
use "${path}\data\SBM_panel.dta", clear

drop muslim_share2010 diff

gen temp = muslim_share if post==1
egen muslim_share2015 = min(temp), by(eleid)

drop temp
egen temp = mean(muslim_share) if post==0, by(eleid)
egen muslim_share2010 = min(temp), by(eleid)

drop temp
gen temp = femalereservation if post==1
egen femalereservation2015 = min(temp), by(eleid)

drop temp
egen temp = mean(femalereservation) if post==0, by(eleid)
egen femalereservation2010 = min(temp), by(eleid)

gen diff = muslim_share2015 - muslim_share2010


label var muslim_share2015 "Muslim share 2015"
label var muslim_share2010 "Muslim share 2010"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
label var female "Female Headed Household"

keep eleid muslim_share2015 muslim_share2010 femalereservation2010 femalereservation2015 diff runningvar2_norm_std
duplicates drop
merge 1:1 eleid using "${path}\data\final election caste sbm.dta"


*Table C11 (Panel A): Covariates balance

replace female_new = femalereservation2015
gen femalereservation = femalereservation2015
gen muslim_share = muslim_share2015

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls tot_new runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", replace
replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls tot_new runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", append
replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls tot_new runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", append

foreach var in primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop femalereservation2010 {

foreach i of numlist 1/3 {
replace bandwidth = .125 - .025*`i'
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls `var' runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", append
}
}

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls diff runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", append
replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls diff runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", append
replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls diff runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\balance_het.tex", append see tex

*Table C11 (Panel B): Pre-treatment outcome balance
replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_13_14_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", replace

replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_13_14_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_13_14_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_14_15_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_14_15_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_14_15_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_15_16_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_15_16_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append

replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered_15_16_to_uncovered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\pretreatmentoutcome_het.tex", append see tex