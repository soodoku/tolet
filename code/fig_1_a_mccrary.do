*Figure 1(a)
clear all

global path ".."
use "$path\data\SBM beneficiaries with gp details_final.dta", clear
drop invpop
egen invpop = sum(1), by(eleid)
replace invpop = 1/invpop

replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered16_17 runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (female_new = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth, cluster(eleid)

keep if e(sample)==1

set scheme s1color

set more off
set seed 1234567
duplicates drop eleid, force
gen Z=runningvar2_norm_std
DCdensity Z, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) nograph

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
graph export "$path\output\mcrary_plot_dcdensity.eps", as(eps) preview(on) replace

