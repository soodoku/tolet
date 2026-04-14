global path ".."
use "${path}\data\SBM beneficiaries with gp details compressed.dta", clear
drop if eleid==.
egen pop = sum(1), by(eleid)
drop if pop<10
drop pop
drop if subcategory==3

drop invpop
egen invpop = sum(1), by(eleid)
replace invpop = 1/invpop
keep if covered15_16==0 & abs(muslim_margin)<=10
ren covered16_17 covered
ren womenreservation femalereservation

*Table C20: Close election between Muslim and Hindu sarpanch contestant
replace bandwidth = 10
replace weight_bw = invpop*(bandwidth-abs(muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_election.tex", replace
summ covered if e(sample)==1 & muslim_margin<=0
replace bandwidth = 7.5
replace weight_bw = invpop*(bandwidth-abs( muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_election.tex", append
summ covered if e(sample)==1 & muslim_margin<=0
replace bandwidth = 5
replace weight_bw = invpop*(bandwidth-abs( muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_election.tex", append see tex
summ covered if e(sample)==1 & muslim_margin<=0

*Table C22: Close election controlling for runningvar
replace bandwidth = 10
replace weight_bw = invpop*(bandwidth-abs(muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin runningvar2_norm_std c.runningvar2_norm_std#c.femalereservation [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_robust.tex", replace
summ covered if e(sample)==1 & muslim_margin<=0
replace bandwidth = 7.5
replace weight_bw = invpop*(bandwidth-abs( muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin runningvar2_norm_std c.runningvar2_norm_std#c.femalereservation [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_robust.tex", append
summ covered if e(sample)==1 & muslim_margin<=0
replace bandwidth = 5
replace weight_bw = invpop*(bandwidth-abs( muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin runningvar2_norm_std c.runningvar2_norm_std#c.femalereservation [pw=weight] if abs(muslim_margin) <= bandwidth, cluster(eleid)
outreg2 using "${path}\output\close_robust.tex", append see tex
summ covered if e(sample)==1 & muslim_margin<=0