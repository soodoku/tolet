global path ".."

use "${path}\data\SBM_panel.dta", clear

replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)

keep if e(sample)==1
g Nobs=1
save "${path}\data\mccrary_plot.dta", replace

*Generating Plots
use "${path}\data\mccrary_plot.dta", clear

bysort eleid: gen sno = _n

replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)

margins, at(runningvar2_norm_std=(-.1(.0005)0) femalereservation=0 femaleinstrument=0 muslim_share = 0) saving(file1, replace)
margins, at(runningvar2_norm_std=(0(.0005).1) femalereservation=1 femaleinstrument=1 muslim_share=0) saving(file2, replace)
margins, at(runningvar2_norm_std=(-.1(.0005)0) femalereservation=0 femaleinstrument=0 muslim_share = 1) saving(file3, replace)
margins, at(runningvar2_norm_std=(0(.0005).1) femalereservation=1 femaleinstrument=1 muslim_share=1) saving(file4, replace)

use "${path}\data\mccrary_plot.dta", clear
gen bin10=.
	foreach X of num 0(.01).1 {
		di "`X'"
		replace bin=(-`X'+(.005)) if (runningvar2_norm_std>=-`X' & runningvar2_norm_std<(-`X'+.01) & runningvar2_norm_std<0)
		replace bin=(`X'+(.005)) if (runningvar2_norm_std>`X' & runningvar2_norm_std<=(`X'+.01))
	}
tab bin10
drop if bin10==.

gen mshare=0 if muslim_share<.5
replace mshare= 1 if muslim_share>=.5

collapse (mean) covered runningvar2_norm_std, by(bin10 mshare)
	
append using file1
append using file2
append using file3
append using file4

ren _at2 muslim_share

ren _at3 x
ren _margin s
ren _ci_ub ciplus
ren _ci_lb ciminus
set scheme s1color

*Figure C4, Panel A
twoway (connected s x if x>0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x>0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x>0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected s x if x<0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x<0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x<0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)),  xline(0, lcolor(gs8) lpattern(dash)) legend(off) graphregion(color(white)) xtitle("Running Variable")  ytitle("Toilet Construction in 2016-2017") xlabel(-.1(.1).1, labsize(*.9)) xsc(r(-.1 .1)) ysc(r(0 .5)) ylabel(0(.1).5) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2))
graph export "${path}\output\rd_plot_second10_msharelow.eps", as(eps) preview(on) replace

*Figure C4, Panel B
twoway (connected s x if x>0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x>0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x>0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected s x if x<0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x<0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x<0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)),  xline(0, lcolor(gs8) lpattern(dash)) legend(off) graphregion(color(white)) xtitle("Running Variable")  ytitle("Toilet Construction in 2016-2017") xlabel(-.1(.1).1, labsize(*.9)) xsc(r(-.1 .1)) ysc(r(0 .4)) ylabel(0(.1).5) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2))
graph export "${path}\output\rd_plot_second10_msharehigh.eps", as(eps) preview(on) replace

erase file1.dta
erase file2.dta
erase file3.dta
erase file4.dta
erase "${path}\data\mccrary_plot.dta"