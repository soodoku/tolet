global path ".."

use "${path}\data\SBM_panel_full.dta", clear

ren muslim_prop_gp2010 muslim_share2010

gen cross_samplev1 = 1 if covered==0 & post==0
egen cross_sample = min(cross_samplev1), by(familyid)
replace cross_sample = 0 if cross_sample==. | post==0
drop cross_samplev1

gen diff = muslim_share - muslim_share2010

label var muslim_share "Muslim share"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
label var muslim_share2010 "Muslim share 2010"

replace muslim_margin = muslim_margin/100
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(muslim_margin ))/bandwidth
reg covered muslim muslim_margin c.muslim#c.muslim_margin femalereservation c.femalereservation#c.muslim c.femalereservation#c.muslim_margin c.femalereservation#c.muslim#c.muslim_margin [pw=weight] if abs(muslim_margin) <= bandwidth & cross_sample==1, cluster(eleid)

keep if e(sample)==1

set scheme s1color

set more off
set seed 1234567
duplicates drop eleid, force
gen Z=muslim_margin
DCdensity Z, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) nograph
gen theta=r(theta)
gen se_theta=r(se)
gen t=theta/se_theta
tab t
tab theta
tab se_theta

*Overall:theta = .0133802;  se_theta = .0852058; t = .1570335

local zval = 1.96

local breakpoint 0
local cellmpname Xj
local cellvalname Yj
local evalname r0
local cellsmname fhat
local cellsmsename se_fhat
tempvar hi
quietly gen `hi' = `cellsmname' + `zval'*`cellsmsename'
tempvar lo
quietly gen `lo' = `cellsmname' - `zval'*`cellsmsename'

gen s = `cellsmname'
gen x = `evalname'
gen ciplus = `hi'
gen ciminus = `lo'
gen Nobs = `cellvalname'
replace runningvar2_norm_std = `cellmpname'

local bw = .1
local biginc = .02
local titlex = "Running Variable"
local titley = "Density"

twoway (connected s x if x>0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected s x if x<0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (scatter Nobs runningvar2_norm_std if abs(runningvar2_norm_std)<`bw', sort msize(vsmall) xline(0, lcolor(gs8) lpattern(dash)) mcolor(black)),  legend(off) graphregion(color(white)) xtitle(`titlex')  ytitle(`titley') xlabel(-`bw'(`biginc')`bw', labsize(*.9)) xsc(r(-`bw' `bw')) ylabel(, nogrid labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2))
graph export "$path\output\mcrary_plot_dcdensity_hindumuslim.eps", as(eps) preview(on) replace