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

******************************
*Generating Second Stage Plot*
******************************

use "${path}\data\mccrary_plot.dta", clear

bysort eleid: gen sno = _n

summ muslim_share if sno==1, d

replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth

*Low Mshare
ivregress 2sls covered runningvar2_norm_std c.runningvar2_norm_std#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std (femalereservation  = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0 & muslim_share<.5, cluster(eleid)


margins, at(runningvar2_norm_std=(-.1(.0005)0) femalereservation=0 femaleinstrument=0) saving(file1, replace)
margins, at(runningvar2_norm_std=(0(.0005).1) femalereservation=1 femaleinstrument=1) saving(file2, replace)

*High Mshare
ivregress 2sls covered runningvar2_norm_std c.runningvar2_norm_std#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std (femalereservation  = femaleinstrument) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0 & muslim_share>=.5, cluster(eleid)

margins, at(runningvar2_norm_std=(-.1(.0005)0) femalereservation=0 femaleinstrument=0) saving(file3, replace)
margins, at(runningvar2_norm_std=(0(.0005).1) femalereservation=1 femaleinstrument=1) saving(file4, replace)


use file1, clear
gen muslim_share=0
save file1, replace
use file2, clear
gen muslim_share=0
save file2, replace
use file3, clear
gen muslim_share=1
save file3, replace
use file4, clear
gen muslim_share=1
save file4, replace

use "${path}\data\mccrary_plot.dta", clear
gen bin10=.
	foreach X of num 0(.0025).1 {
		di "`X'"
		replace bin=(-`X'+(.00125)) if (runningvar2_norm_std>=-`X' & runningvar2_norm_std<(-`X'+.0025) & runningvar2_norm_std<0)
		replace bin=(`X'+(.00125)) if (runningvar2_norm_std>`X' & runningvar2_norm_std<=(`X'+.0025))
	}
tab bin10
drop if bin10==.

gen mshare=0 if muslim_share<0.5
replace mshare= 1 if muslim_share>=.5

collapse (mean) covered runningvar2_norm_std, by(bin10 mshare)
	
append using file1
append using file2
append using file3
append using file4

ren _at2 x
ren _margin s
ren _ci_ub ciplus
ren _ci_lb ciminus
set scheme s1color
twoway (connected s x if x>0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x>0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x>0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected s x if x<0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x<0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x<0 & muslim_share==0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (scatter  covered runningvar2_norm_std if mshare==0, sort msize(small) mcolor(black)),  xline(0, lcolor(gs8) lpattern(dash)) legend(off) graphregion(color(white)) xtitle("Running Variable")  ytitle("Toilet Construction in 2016-2017") xlabel(-.1(.1).1, labsize(*.9)) xsc(r(-.1 .1)) ysc(r(-.1 .5)) ylabel(0(.1)1) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2))
graph export "${path}\output\rd_plot_second10_msharelow_50threshold_quad.eps", as(eps) preview(on) replace

twoway (connected s x if x>0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x>0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x>0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected s x if x<0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) (connected ciplus x if x<0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (connected ciminus x if x<0 & muslim_share==1, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) (scatter  covered runningvar2_norm_std if mshare==1, sort msize(small) mcolor(black)),  xline(0, lcolor(gs8) lpattern(dash)) legend(off) graphregion(color(white)) xtitle("Running Variable")  ytitle("Toilet Construction in 2016-2017") xlabel(-.1(.1).1, labsize(*.9)) xsc(r(-.1 .1)) ysc(r(-.1 .5)) ylabel(0(.1)1) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2))
graph export "${path}\output\rd_plot_second10_msharehigh_50threshold_quad.eps", as(eps) preview(on) replace

erase file1.dta
erase file2.dta
erase file3.dta
erase file4.dta
erase "${path}\data\mccrary_plot.dta"