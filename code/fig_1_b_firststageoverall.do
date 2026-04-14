global path ".."

use "${path}\data\SBM_panel.dta", clear

replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std (femalereservation  = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)

keep if e(sample)==1
g Nobs=1
save "${path}\data\mccrary_plot.dta", replace

*Figure 1(b), First Stage Plot

use "${path}\data\mccrary_plot.dta", clear
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
margins, at(runningvar2_norm_std=(-.1(.0005)0) femaleinstrument=0) saving(file1, replace)
margins, at(runningvar2_norm_std=(0(.0005).1) femaleinstrument=1) saving(file2, replace)

use "${path}\data\mccrary_plot.dta", clear
set scheme s1color
gen bin10=.
	foreach X of num 0(.01).1 {
		di "`X'"
		replace bin=(-`X'+(.005)) if (runningvar2_norm_std>=-`X' & runningvar2_norm_std<(-`X'+.01) & runningvar2_norm_std<0)
		replace bin=(`X'+(.005)) if (runningvar2_norm_std>`X' & runningvar2_norm_std<=(`X'+.01))
	}
	tab bin10
	drop if bin10==.
	
	collapse (mean) femalereservation runningvar2_norm_std , by(bin10)
	append using file1
	append using file2
	ren _at2 x
ren _margin s
ren _ci_ub ciplus
ren _ci_lb ciminus
	
twoway (connected s x if x>0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected s x if x<0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (scatter  femalereservation runningvar2_norm_std, sort msize(small) mcolor(black)),  xline(0, lcolor(gs8) lpattern(dash)) legend(off) graphregion(color(white)) xtitle("Running Variable")  ytitle("Female Reservation") xlabel(-.1(.1).1, labsize(*.9)) xsc(r(-.1 .1)) ysc(r(0 1)) ylabel(0(.2)1) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2))
graph export "${path}\output\rd_plotfirst10.eps", as(eps) preview(on) replace

erase file1.dta
erase file2.dta
erase "${path}\data\mccrary_plot.dta"
