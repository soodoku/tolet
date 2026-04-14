global path ".."
use "${path}\data\SBM beneficiaries with gp details compressed.dta", clear
egen pop = sum(1), by(eleid)
drop if pop<10
drop pop
drop if subcategory==3
keep if covered15_16!=. & abs(muslim_margin)<=10

ren muslim_prop_gp2015 muslim_share
ren muslim_prop_gp2010 muslim_share2010

ren womenreservation femalereservation

label var muslim_share "Muslim share"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
	
egen temp = mean( femalereservation2010), by(eleid)
egen temp2 = min( temp), by(eleid)
replace femalereservation2010 = temp2

drop temp temp2

egen temp = mean( diff), by(eleid)
egen temp2 = min( temp), by(eleid)
replace diff = temp2

keep eleid muslim_share femalereservation2010 femalereservation diff muslim_margin


duplicates drop

merge 1:1 eleid using "${path}\data\final election caste sbm.dta"

*Table C21: Covariate Balance Table Close Elections
*Panel A
replace bandwidth = 10
replace weight_bw = (bandwidth-abs(muslim_margin ))/bandwidth
reg tot_new muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", replace
replace bandwidth = 7.5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg tot_new muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg tot_new muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append

foreach var in primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop femalereservation2010 femalereservation muslim_share {
foreach i of numlist 1/3 {
replace bandwidth = 12.5 - 2.5*`i'

replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg `var' muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
}
}

replace bandwidth = 10
replace weight_bw = (bandwidth-abs(muslim_margin ))/bandwidth
reg diff muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 7.5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg diff muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg diff muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append

*Panel B: Pre-treatment Outcome
replace bandwidth = 10
replace weight_bw = (bandwidth-abs(muslim_margin ))/bandwidth
reg covered_13_14_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 7.5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg covered_13_14_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg covered_13_14_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append


replace bandwidth = 10
replace weight_bw = (bandwidth-abs(muslim_margin ))/bandwidth
reg covered_14_15_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 7.5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg covered_14_15_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg covered_14_15_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append


replace bandwidth = 10
replace weight_bw = (bandwidth-abs(muslim_margin ))/bandwidth
reg covered_15_16_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 7.5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg covered_15_16_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append
replace bandwidth = 5
replace weight_bw = (bandwidth-abs( muslim_margin ))/bandwidth
reg covered_15_16_to_uncovered muslim muslim_margin c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_balance.tex", append see tex