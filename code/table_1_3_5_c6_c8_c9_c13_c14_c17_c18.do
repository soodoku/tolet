global path ".."

use "${path}\data\SBM_panel.dta", clear
label var muslim_share "Muslim share"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
label var female "Female Headed Household"

*Table 1: Effect of Female Reservation on Toilet Allocation
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
(femalereservation  = femaleinstrument) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\overall.tex", replace
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
(femalereservation  = femaleinstrument) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\overall.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
(femalereservation  = femaleinstrument) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\overall.tex", append see label tex(frag)
summ covered if e(sample)==1 &  runningvar2_norm_std<=0

*Table 3: Heterogenous Impact of Female Reservation on Toilet Allocation
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare.tex", replace
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare.tex", append see label tex(frag)
summ covered if e(sample)==1 &  runningvar2_norm_std<=0

*Table 5: Female Headed Hindu and Muslim Households
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female ///
c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female ///
(femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_femalehh.tex", replace
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
count if e(sample)==1 & female==1
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female ///
c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female ///
(femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_femalehh.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
count if e(sample)==1 & female==1
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female ///
c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female ///
(femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_femalehh.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
count if e(sample)==1 & female==1
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female ///
c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female ///
(femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_femalehh.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
count if e(sample)==1 & female==1
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female ///
c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female ///
(femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_femalehh.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
count if e(sample)==1 & female==1
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std female ///
c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female ///
(femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_femalehh.tex", append see label tex(frag)
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
count if e(sample)==1 & female==1

*****************
*APPENDIX TABLES*
*****************
*Table C6: First Stage
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage.tex", replace
summ femalereservation if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage.tex", append
summ femalereservation if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage.tex", append see label tex(frag)
summ femalereservation if e(sample)==1 &  runningvar2_norm_std<=0

*Table C8 (Panel A): First Stage Heterogeneity
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.muslim_share [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage_hetero.tex", replace
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.muslim_share [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage_hetero.tex", append
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg femalereservation femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.muslim_share [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage_hetero.tex", append see label tex(frag)

*Table C8 (Panel B): First Stage Heterogeneity mshare
gen female_mshare = femalereservation*muslim_share
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg female_mshare femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.muslim_share [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage_hetero_mshare.tex", replace
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg female_mshare femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.muslim_share [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage_hetero_mshare.tex", append
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
reg female_mshare femaleinstrument runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.muslim_share [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path\output\firststage_hetero_mshare.tex", append see label tex(frag)

*Table C9: Heterogenous Impact of Female Reservation on Toilet Allocation: quadratic running variables
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std c.runningvar2_norm_std#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.runningvar2_norm_std#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare_quadratic.tex", replace
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std c.runningvar2_norm_std#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.runningvar2_norm_std#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare_quadratic.tex", append
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std c.runningvar2_norm_std#c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share c.runningvar2_norm_std#c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.runningvar2_norm_std#c.muslim_share (femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare_quadratic.tex", append see label tex(frag)

*Table C13: No Heterogenous Impact of Female Reservation on Electing Muslim Leader
preserve
keep if post == 1 & covered201516 == 0
bysort eleid: gen sno = _n
replace bandwidth = .1
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls muslimsarpanch runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0 & sno == 1, vce(robust)
outreg2 using "$path/output/overall_muslimsarpanch_mshare.tex", replace
summ muslimsarpanch if e(sample)==1 & runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls muslimsarpanch runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0 & sno == 1, vce(robust)
outreg2 using "$path/output//overall_muslimsarpanch_mshare.tex", append
summ muslimsarpanch if e(sample)==1 & runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = (bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls muslimsarpanch runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share c.runningvar2_norm_std#c.muslim_share c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share ///
(femalereservation c.femalereservation#c.muslim_share  = femaleinstrument c.femaleinstrument#c.muslim_share) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0 & sno == 1, vce(robust)
outreg2 using "$path/output/overall_muslimsarpanch_mshare.tex", append see label tex(frag)
summ muslimsarpanch if e(sample)==1 & runningvar2_norm_std<=0
restore

*Table C14: Using difference in Muslim share to show heterogenous treatment effect is causal
label var muslim_share2010 "Muslim share 2010"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share2010 c.runningvar2_norm_std#c.muslim_share2010 c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share2010 ///
diff c.runningvar2_norm_std#c.diff c.femaleinstrument#c.runningvar2_norm_std#c.diff ///
(femalereservation c.femalereservation#c.muslim_share2010 c.femalereservation#c.diff  = femaleinstrument c.femaleinstrument#c.muslim_share2010 c.femaleinstrument#c.diff) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare_diff.tex", replace
summ covered if e(sample)==1 & runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share2010 c.runningvar2_norm_std#c.muslim_share2010 c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share2010 ///
diff c.runningvar2_norm_std#c.diff c.femaleinstrument#c.runningvar2_norm_std#c.diff ///
(femalereservation c.femalereservation#c.muslim_share2010 c.femalereservation#c.diff  = femaleinstrument c.femaleinstrument#c.muslim_share2010 c.femaleinstrument#c.diff) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare_diff.tex", append
summ covered if e(sample)==1 & runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std ///
muslim_share2010 c.runningvar2_norm_std#c.muslim_share2010 c.femaleinstrument#c.runningvar2_norm_std#c.muslim_share2010 ///
diff c.runningvar2_norm_std#c.diff c.femaleinstrument#c.runningvar2_norm_std#c.diff ///
(femalereservation c.femalereservation#c.muslim_share2010 c.femalereservation#c.diff  = femaleinstrument c.femaleinstrument#c.muslim_share2010 c.femaleinstrument#c.diff) ///
[pw=weight] if abs(runningvar2_norm_std) <= bandwidth & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_mshare_diff.tex", append see label tex(frag)
summ covered if e(sample)==1 & runningvar2_norm_std<=0

*Table C17: SC households
gen sc = 0
replace sc = 1 if subcategory == 5 | subcategory==6
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std sc ///
c.runningvar2_norm_std#c.sc c.femaleinstrument#c.runningvar2_norm_std#c.sc ///
(femalereservation c.femalereservation#c.sc = femaleinstrument c.femaleinstrument#c.sc) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_sc.tex", replace
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std sc ///
c.runningvar2_norm_std#c.sc c.femaleinstrument#c.runningvar2_norm_std#c.sc ///
(femalereservation c.femalereservation#c.sc = femaleinstrument c.femaleinstrument#c.sc) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_sc.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivregress 2sls covered runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std sc ///
c.runningvar2_norm_std#c.sc c.femaleinstrument#c.runningvar2_norm_std#c.sc ///
(femalereservation c.femalereservation#c.sc = femaleinstrument c.femaleinstrument#c.sc) [pw=weight] ///
if abs(runningvar2_norm_std) <= bandwidth & category==1 & post == 1 & covered201516 == 0, cluster(eleid)
outreg2 using "$path/output/overall_sc.tex", append see label tex(frag)
summ covered if e(sample)==1 &  runningvar2_norm_std<=0

*Table C18: Female Headed Household Panel
/*Specification similar to estimating: 

ivreghdfe [change] c.runningvar2_norm_std c.femaleinstrument#c.runningvar2_norm_std c.female c.runningvar2_norm_std#c.female c.femaleinstrument#c.runningvar2_norm_std#c.female (c.femalereservation c.femalereservation#c.female = femaleinstrument c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1 & post==1, cluster(eleid)

*/

preserve
gen temp = femalereservation if post==1
egen femalereservation2015 = min(temp), by(familyid)
replace femalereservation = . if post==1
drop temp
gen temp = femalereservation if post==0
drop femalereservation
egen femalereservation2010 = min(temp), by(familyid)
ren femalereservation2015 femalereservation
drop temp 

replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered post c.post#c.runningvar2_norm_std c.post#c.femaleinstrument#c.runningvar2_norm_std c.post#c.female c.post#c.runningvar2_norm_std#c.female c.post#c.femaleinstrument#c.runningvar2_norm_std#c.female (c.post#c.femalereservation c.post#c.femalereservation#c.female = c.post#c.femaleinstrument c.post#c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1, cluster(eleid) a(familyid)
outreg2 using "$path/output/overall_femalehh_panel.tex", replace
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered post c.post#c.runningvar2_norm_std c.post#c.femaleinstrument#c.runningvar2_norm_std c.post#c.female c.post#c.runningvar2_norm_std#c.female c.post#c.femaleinstrument#c.runningvar2_norm_std#c.female (c.post#c.femalereservation c.post#c.femalereservation#c.female = c.post#c.femaleinstrument c.post#c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1, cluster(eleid) a(familyid)
outreg2 using "$path/output/overall_femalehh_panel.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered post c.post#c.runningvar2_norm_std c.post#c.femaleinstrument#c.runningvar2_norm_std c.post#c.female c.post#c.runningvar2_norm_std#c.female c.post#c.femaleinstrument#c.runningvar2_norm_std#c.female (c.post#c.femalereservation c.post#c.femalereservation#c.female = c.post#c.femaleinstrument c.post#c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==0 & category==1, cluster(eleid) a(familyid)
outreg2 using "$path/output/overall_femalehh_panel.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .1
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered post c.post#c.runningvar2_norm_std c.post#c.femaleinstrument#c.runningvar2_norm_std c.post#c.female c.post#c.runningvar2_norm_std#c.female c.post#c.femaleinstrument#c.runningvar2_norm_std#c.female (c.post#c.femalereservation c.post#c.femalereservation#c.female = c.post#c.femaleinstrument c.post#c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1, cluster(eleid) a(familyid)
outreg2 using "$path/output/overall_femalehh_panel.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .075
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered post c.post#c.runningvar2_norm_std c.post#c.femaleinstrument#c.runningvar2_norm_std c.post#c.female c.post#c.runningvar2_norm_std#c.female c.post#c.femaleinstrument#c.runningvar2_norm_std#c.female (c.post#c.femalereservation c.post#c.femalereservation#c.female = c.post#c.femaleinstrument c.post#c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1, cluster(eleid) a(familyid)
outreg2 using "$path/output/overall_femalehh_panel.tex", append
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
replace bandwidth = .05
replace weight_bw = invpop*(bandwidth-abs(runningvar2_norm_std))/bandwidth
ivreghdfe covered post c.post#c.runningvar2_norm_std c.post#c.femaleinstrument#c.runningvar2_norm_std c.post#c.female c.post#c.runningvar2_norm_std#c.female c.post#c.femaleinstrument#c.runningvar2_norm_std#c.female (c.post#c.femalereservation c.post#c.femalereservation#c.female = c.post#c.femaleinstrument c.post#c.femaleinstrument#c.female) [pw=weight] if abs(runningvar2_norm_std) <= bandwidth & muslim_pred==1 & category==1, cluster(eleid) a(familyid)
outreg2 using "$path/output/overall_femalehh_panel.tex", append see label tex(frag)
summ covered if e(sample)==1 &  runningvar2_norm_std<=0
restore