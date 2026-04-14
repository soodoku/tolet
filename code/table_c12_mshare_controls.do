global path ".."

use "${path}\data\SBM_panel.dta", clear
label var muslim_share "Muslim share"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
label var female "Female Headed Household"

replace bandwidth = .1
keep if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0
merge m:1 eleid using "$path\data\final election caste sbm.dta"

*Table C12: Heterogenous Impact of Female Reservation on Toilet Allocation
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share tot_new primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop c.femalereservation#c.tot_new c.femalereservation#c.primaryschool_proportion_5km c.femalereservation#c.middleschool_proportion_5km c.femalereservation#c.secondaryschool_proportion_5km c.femalereservation#c.tapwater_proportion c.femalereservation#c.closedrainage_proportion c.femalereservation#c.wastedisposal_proportion c.femalereservation#c.allweatherroad_proportion c.femalereservation#c.domesticpower_proportion c.femalereservation#c.percentirrigated_gp c.femalereservation#c.female_prop c.femalereservation#c.apl_prop (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
summ covered if e(sample)==1 & runningvar2_norm_std<=0
outreg2 using "$path/output/overall_mshare_control.tex", replace
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share tot_new primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop c.femalereservation#c.tot_new c.femalereservation#c.primaryschool_proportion_5km c.femalereservation#c.middleschool_proportion_5km c.femalereservation#c.secondaryschool_proportion_5km c.femalereservation#c.tapwater_proportion c.femalereservation#c.closedrainage_proportion c.femalereservation#c.wastedisposal_proportion c.femalereservation#c.allweatherroad_proportion c.femalereservation#c.domesticpower_proportion c.femalereservation#c.percentirrigated_gp c.femalereservation#c.female_prop c.femalereservation#c.apl_prop (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
summ covered if e(sample)==1 & runningvar2_norm_std<=0
outreg2 using "$path/output/overall_mshare_control.tex", append
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share tot_new primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop c.femalereservation#c.tot_new c.femalereservation#c.primaryschool_proportion_5km c.femalereservation#c.middleschool_proportion_5km c.femalereservation#c.secondaryschool_proportion_5km c.femalereservation#c.tapwater_proportion c.femalereservation#c.closedrainage_proportion c.femalereservation#c.wastedisposal_proportion c.femalereservation#c.allweatherroad_proportion c.femalereservation#c.domesticpower_proportion c.femalereservation#c.percentirrigated_gp c.femalereservation#c.female_prop c.femalereservation#c.apl_prop (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
summ covered if e(sample)==1 & runningvar2_norm_std<=0
outreg2 using "$path/output/overall_mshare_control.tex", append see label tex(frag)