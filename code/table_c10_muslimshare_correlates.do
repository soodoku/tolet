*Table C10

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

egen pop = sum(1), by(eleid)

label var muslim_share2015 "Muslim share 2015"
label var muslim_share2010 "Muslim share 2010"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
label var female "Female Headed Household"

keep eleid muslim_share2015 muslim_share2010 femalereservation2010 femalereservation2015 diff runningvar2_norm_std
duplicates drop
merge 1:1 eleid using "${path}\data\final election caste sbm.dta"

replace female_new = femalereservation2015

foreach var in  tot_new {
regress `var' muslim_share2015 if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\muslimeshare_correlates.xls", replace
}

foreach var in  primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop {
regress `var' muslim_share2015 if abs(runningvar2_norm_std) <= bandwidth & _merge==3
outreg2 using "${path}\output\muslimeshare_correlates.xls", append
}