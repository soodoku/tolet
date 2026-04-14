global path ".."

use "${path}\data\SBM_panel_full.dta", clear

gen fhh_reservation = femalereservation*female

label variable mshare_reservation "Female reservation*Muslim share"
label variable femalereservation "Female reservation"

keep if abs(runningvar2_norm_std)<=.12

forvalues i = 0/20 {
replace bandwidth = (`i'+4)*.005
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female (femalereservation fhh_reservation = femaleinstrument c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
estimates store coef`i'
}

forvalues i = 0/20 {
replace bandwidth = (`i'+4)*.005
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female (femalereservation fhh_reservation = femaleinstrument c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
estimates store coefmuslim`i'
}

coefplot coef0 coef1 coef2 coef3 coef4 coef5 coef6 coef7 coef8 coef9 coef10 coef11 coef12 coef13 coef14 coef15 coef16 coef17 coef18 coef19 coef20, keep(fhh_reservation) mcolor(black) msymbol(circle) msize(*.8) ciopts(color(black)) vertical graphregion(color(white)) ytitle(% Uncovered Households Covered 2016-17) legend(off) aseq swapnames groups(coef0=".020" coef1=".025" coef2=".030" coef3=".035" coef4=".040" coef5=".045" coef6=".050" coef7=".055" coef8=".060" coef9=".065" coef10=".070" coef11=".075" coef12=".080" coef13=".085" coef14=".090" coef15=".095" coef16=".100" coef17=".105" coef18=".110" coef19=".115" coef20=".120", angle(45)) xlabel("") ylabel(-.1(0.1).7,labsize(vsmall)) yscale(range(-.1(0.1).7))

graph export "${path}\output\coefplot_heterogeneity_nonmuslim_fhh.eps", as(eps) preview(on) replace

coefplot coefmuslim0 coefmuslim1 coefmuslim2 coefmuslim3 coefmuslim4 coefmuslim5 coefmuslim6 coefmuslim7 coefmuslim8 coefmuslim9 coefmuslim10 coefmuslim11 coefmuslim12 coefmuslim13 coefmuslim14 coefmuslim15 coefmuslim16 coefmuslim17 coefmuslim18 coefmuslim19 coefmuslim20, keep(fhh_reservation) mcolor(black) msymbol(circle) msize(*.8) ciopts(color(black)) vertical graphregion(color(white)) ytitle(% Uncovered Households Covered 2016-17) legend(off) aseq swapnames groups(coefmuslim0=".020" coefmuslim1=".025" coefmuslim2=".030" coefmuslim3=".035" coefmuslim4=".040" coefmuslim5=".045" coefmuslim6=".050" coefmuslim7=".055" coefmuslim8=".060" coefmuslim9=".065" coefmuslim10=".070" coefmuslim11=".075" coefmuslim12=".080" coefmuslim13=".085" coefmuslim14=".090" coefmuslim15=".095" coefmuslim16=".100" coefmuslim17=".105" coefmuslim18=".110" coefmuslim19=".115" coefmuslim20=".120", angle(45)) xlabel("") ylabel(-.1(0.1).7,labsize(vsmall)) yscale(range(-.1(0.1).7))

graph export "${path}\output\coefplot_heterogeneity_muslim_fhh.eps", as(eps) preview(on) replace