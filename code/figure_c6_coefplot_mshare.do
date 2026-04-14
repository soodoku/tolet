global path ".."

use "${path}\data\SBM_panel_full.dta", clear

label variable mshare_reservation "Female reservation*Muslim share"
label variable femalereservation "Female reservation"

keep if abs(runningvar2_norm_std)<=.12

forvalues i = 0/20 {
replace bandwidth = (`i'+4)*.005
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation mshare_reservation  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
estimates store coef`i'
}

*Figure C6 (Panel a)
coefplot coef0 coef1 coef2 coef3 coef4 coef5 coef6 coef7 coef8 coef9 coef10 coef11 coef12 coef13 coef14 coef15 coef16 coef17 coef18 coef19 coef20, keep(femalereservation) mcolor(black) msymbol(circle) msize(*.8) ciopts(color(black)) vertical graphregion(color(white)) ytitle(% Uncovered Households Covered 2016-17) legend(off) aseq swapnames groups(coef0=".020" coef1=".025" coef2=".030" coef3=".035" coef4=".040" coef5=".045" coef6=".050" coef7=".055" coef8=".060" coef9=".065" coef10=".070" coef11=".075" coef12=".080" coef13=".085" coef14=".090" coef15=".095" coef16=".100" coef17=".105" coef18=".110" coef19=".115" coef20=".120", angle(45)) xlabel("") ylabel(-.2(0.2)1.4,labsize(vsmall)) yscale(range(-.2(0.2)1.4))

graph export "${path}\output\coefplot_heterogeneity_nonmuslim.eps", as(eps) preview(on) replace

*Figure C6 (Panel b)
coefplot coef0 coef1 coef2 coef3 coef4 coef5 coef6 coef7 coef8 coef9 coef10 coef11 coef12 coef13 coef14 coef15 coef16 coef17 coef18 coef19 coef20, keep(mshare_reservation) mcolor(black) msymbol(circle) msize(*.8) ciopts(color(black)) vertical graphregion(color(white)) ytitle(% Uncovered Households Covered 2016-17) legend(off) aseq swapnames groups(coef0=".020" coef1=".025" coef2=".030" coef3=".035" coef4=".040" coef5=".045" coef6=".050" coef7=".055" coef8=".060" coef9=".065" coef10=".070" coef11=".075" coef12=".080" coef13=".085" coef14=".090" coef15=".095" coef16=".100" coef17=".105" coef18=".110" coef19=".115" coef20=".120", angle(45)) xlabel("") ylabel(-.2(0.2)1.4,labsize(vsmall)) yscale(range(-.2(0.2)1.4))

graph export "${path}\output\coefplot_heterogeneity_muslim.eps", as(eps) preview(on) replace