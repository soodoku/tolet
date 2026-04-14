clear all
global path ".."
use "$path\data\final election caste sbm.dta", clear

*Figure C3: Muslim Household Share Histogram
hist muslimpropgp_censusadj_new, xtitle("Muslim Household Share") ytitle("Density") legend(off) graphregion(color(white)) bgcolor(white) color(gs8) lcolor(black) lwidth(thin)
graph export "$path\output\muslim_share_hist.eps", as(eps) preview(on) replace
