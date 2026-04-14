clear all
set maxvar 10000

global path ".."
global nfhs_results "$path\output"
global data "$path\data"

use "$data\IAHR71FL.DTA", clear
rename hv025 sector
rename sh36 caste
rename sh34 religion
rename hv005 weight
rename hv024 state
rename hv205 toilet_type

generate toilet_d=1
replace toilet_d=0 if toilet_type==30 | toilet_type==31

keep if sector==2

keep shdistri toilet_d state weight

collapse toilet_d [pw=weight], by( state shdistri )
export excel using "$data\data_toilet_nfhs.xlsx", sheetreplace firstrow(variables)

*Figure C1
import excel "$data\matching_district_nfhs_admin.xlsx", sheet("final") firstrow clear
keep if state_name_census2011=="Uttar Pradesh"
twoway (scatter propensity_toilet nfhs_toilet, mcolor(gs8)) (lfit propensity_toilet nfhs_toilet, lcolor(black)), ytitle(Administrative data) xtitle(NFHS-4) graphregion(color(white)) legend(off)
graph export "$nfhs_results\nfhs_admin_data_scatter_fit_UP.pdf", as(pdf) replace

corr propensity_toilet nfhs_toilet

****************************************************
*Table C3
use "$data\IAIR71FL.DTA", clear
rename v025 sector
rename s116 caste
replace caste=. if caste==8
rename v130 religion
rename v133 edu_years
rename v150 head

rename v151 sex_head
rename v012 age
rename v021 village
rename v024 state

rename v743a decision_health
rename v743b decision_hhpurchases
rename v743d decision_visits
rename s928a allow_market
rename s928b allow_health
rename s928c allow_out

foreach var in decision_health decision_hhpurchases decision_visits head allow_market allow_health allow_out {
gen `var'_d=`var'
}

foreach var in decision_health decision_hhpurchases decision_visits {
replace `var'_d=0 if `var'_d>1 & `var'_d<=6 & `var'_d!=.
}

foreach var in allow_market allow_health allow_out {
replace `var'_d=0 if `var'==2
}

replace head_d=0 if head>1 & head<=999 & head!=.

label values sex_head .
replace sex_head=0 if sex_head==1
replace sex_head=1 if sex_head==2

gen muslim=religion
replace muslim=0 if (religion==1 | religion >=3) & religion!=.
replace muslim=1 if muslim==2


gen age_sq=age^2
gen edu_sq=edu_years^2
gen sex_head_mus=sex_head*muslim
gen head_mus=head_d*muslim
*sector 2 is rural*

label variable decision_health_d "Decision(health)" 
label variable decision_hhpurchases_d "Decision(purchases)"
label variable decision_visits_d "Decision(visits)"
label variable allow_market_d "Allow(market)"
label variable allow_health_d "Allow(health)"
label variable allow_out_d "Allow(outside)"

label variable sex_head "Female Head HH"
label variable head_d "Head"
label variable age "Age"
label variable age_sq "Age square"
label variable edu_years "Education"
label variable edu_sq "Education square"

label variable muslim "Muslim"
label variable head_mus "Head*Muslim"
label variable sex_head_mus "Female Head HH*Muslim"

egen decision_d=rowtotal(decision_health_d decision_hhpurchases_d decision_visits_d), miss
replace decision_d=1 if decision_d>1 & decision_d!=.
egen allow_d=rowtotal(allow_market_d allow_health_d allow_out_d), miss
replace allow_d=1 if allow_d>1 & allow_d!=.

capture erase "$nfhs_results/decision_making_main.tex"
capture erase "$nfhs_results/decision_making_main.txt"

*Table C3 (columns 1-2, Panel A)
foreach var in decision_d allow_d {
reghdfe `var' sex_head age age_sq edu_years edu_sq i.religion i.caste if sector==2 & religion<3, absorb(village) cluster(village)
estimates store `var'_est_main
outreg2 using "$nfhs_results/decision_making_main.tex", keep(sex_head age age_sq edu_years edu_sq) label dec(3) append tex
}

mean decision_d if sector==2
mean allow_d if sector==2

*Table C3 (column 1-2, panel B)
capture erase "$nfhs_results/decision_making_het_main.tex"
capture erase "$nfhs_results/decision_making_het_main.txt"
foreach var in decision_d allow_d {
reghdfe `var' sex_head sex_head_mus age age_sq edu_years edu_sq muslim i.caste if sector==2 & religion<3, absorb(village) cluster(village)
estimates store `var'_est_het_main
outreg2 using "$nfhs_results/decision_making_het_main.tex", keep(sex_head sex_head_mus age age_sq edu_years edu_sq muslim) label dec(3) append tex
}


*Table C16
use "$data\IAHR71FL.DTA", clear
rename hv219 sex_head
label values sex_head .
replace sex_head=0 if sex_head==1
replace sex_head=1 if sex_head==2

rename hv115_01 ms_01
tab ms_01 if sex_head==1 [aw=hv005]

rename hv270 wealth_index
rename sh34 religion
replace religion=5 if religion>=5 

rename sh36 caste
gen caste_new=caste
replace caste=. if caste==8 


rename hv009 hh_members
rename hv025 sector

rename hv021 village
rename hv024 state

recode wealth_index (2=1) (3/5=0), gen(poor) 

gen muslim=religion
replace muslim=0 if (religion==1 | religion >=3) & religion!=.
replace muslim=1 if muslim==2

foreach var in hv108_01 hv108_02 hv108_03 hv108_04 hv108_05 hv108_06 hv108_07 hv108_08 hv108_09 hv108_10 hv108_11 hv108_12 hv108_13 hv108_14 hv108_15 hv108_16 hv108_17 hv108_18 hv108_19 hv108_20 hv108_21 hv108_22 hv108_23 hv108_24 hv108_25 hv108_26 hv108_27 hv108_28 hv108_29 hv108_30 hv108_31 hv108_32 hv108_33 hv108_34 hv108_36 hv108_37 hv108_38 hv108_39 hv108_40 hv108_41 {
replace `var'=. if `var'>20
}

egen avg_education_members=rowmean(hv108_01 hv108_02 hv108_03 hv108_04 hv108_05 hv108_06 hv108_07 hv108_08 hv108_09 hv108_10 hv108_11 hv108_12 hv108_13 hv108_14 hv108_15 hv108_16 hv108_17 hv108_18 hv108_19 hv108_20 hv108_21 hv108_22 hv108_23 hv108_24 hv108_25 hv108_26 hv108_27 hv108_28 hv108_29 hv108_30)

foreach var in hv105_01 hv105_02 hv105_03 hv105_04 hv105_05 hv105_06 hv105_07 hv105_08 hv105_09 hv105_10 hv105_11 hv105_12 hv105_13 hv105_14 hv105_15 hv105_16 hv105_17 hv105_18 hv105_19 hv105_20 hv105_21 hv105_22 hv105_23 hv105_24 hv105_25 hv105_26 hv105_27 hv105_28 hv105_29 hv105_30 {
replace `var'=. if `var'>95
}

egen avg_age_members=rowmean(hv105_01 hv105_02 hv105_03 hv105_04 hv105_05 hv105_06 hv105_07 hv105_08 hv105_09 hv105_10 hv105_11 hv105_12 hv105_13 hv105_14 hv105_15 hv105_16 hv105_17 hv105_18 hv105_19 hv105_20 hv105_21 hv105_22 hv105_23 hv105_24 hv105_25 hv105_26 hv105_27 hv105_28 hv105_29 hv105_30)


foreach var in hv105_01 hv105_02 hv105_03 hv105_04 hv105_05 hv105_06 hv105_07 hv105_08 hv105_09 hv105_10 hv105_11 hv105_12 hv105_13 hv105_14 hv105_15 hv105_16 hv105_17 hv105_18 hv105_19 hv105_20 hv105_21 hv105_22 hv105_23 hv105_24 hv105_25 hv105_26 hv105_27 hv105_28 hv105_29 hv105_30 hv105_31 hv105_32 hv105_33 {
gen child_`var'=1 if `var'>=0 & `var'<=14 & `var'!=.
gen old_`var'=1 if `var'>=60 & `var'<=150 & `var'!=.
replace child_`var'=0 if child_`var'==.
replace old_`var'=0 if old_`var'==.
}

egen child_members=rowtotal(child_hv105_01 child_hv105_02 child_hv105_03 child_hv105_04 child_hv105_05 child_hv105_06 child_hv105_07 child_hv105_08 child_hv105_09 child_hv105_10 child_hv105_11 child_hv105_12 child_hv105_13 child_hv105_14 child_hv105_15 child_hv105_16 child_hv105_17 child_hv105_18 child_hv105_19 child_hv105_20 child_hv105_21 child_hv105_22 child_hv105_23 child_hv105_24 child_hv105_25 child_hv105_26 child_hv105_27 child_hv105_28 child_hv105_29 child_hv105_30 child_hv105_31 child_hv105_32 child_hv105_33)

egen old_members=rowtotal(old_hv105_01 old_hv105_02 old_hv105_03 old_hv105_04 old_hv105_05 old_hv105_06 old_hv105_07 old_hv105_08 old_hv105_09 old_hv105_10 old_hv105_11 old_hv105_12 old_hv105_13 old_hv105_14 old_hv105_15 old_hv105_16 old_hv105_17 old_hv105_18 old_hv105_19 old_hv105_20 old_hv105_21 old_hv105_22 old_hv105_23 old_hv105_24 old_hv105_25 old_hv105_26 old_hv105_27 old_hv105_28 old_hv105_29 old_hv105_30 old_hv105_31 old_hv105_32 old_hv105_33)

gen child_prop=child_members/hh_members
gen old_prop=old_members/hh_members

*********************************
*Table C16 (panel A)
reghdfe poor sex_head if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2.tex", keep(sex_head) label dec(3) replace
reghdfe avg_education_members sex_head if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2.tex", keep(sex_head) label dec(3) append
reghdfe hh_members sex_head if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2.tex", keep(sex_head) label dec(3) append
reghdfe avg_age_members sex_head if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2.tex", keep(sex_head) label dec(3) append
reghdfe child_prop sex_head if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2.tex", keep(sex_head) label dec(3) append
reghdfe old_prop sex_head if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2.tex", keep(sex_head) see label dec(3) append

*Table C16 (panel B)
reghdfe poor sex_head i.sex_head##i.muslim if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2_mus.tex", keep(sex_head 1.sex_head#1.muslim 1.muslim) label dec(3) replace
reghdfe avg_education_members sex_head i.sex_head##i.muslim if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2_mus.tex", keep(sex_head 1.sex_head#1.muslim 1.muslim) label dec(3) append
reghdfe hh_members sex_head i.sex_head##i.muslim if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2_mus.tex", keep(sex_head 1.sex_head#1.muslim 1.muslim) label dec(3) append
reghdfe avg_age_members sex_head i.sex_head##i.muslim if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2_mus.tex", keep(sex_head 1.sex_head#1.muslim 1.muslim) label dec(3) append
reghdfe child_prop sex_head i.sex_head##i.muslim if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2_mus.tex", keep(sex_head 1.sex_head#1.muslim 1.muslim) label dec(3) append
reghdfe old_prop sex_head i.sex_head##i.muslim if sector==2, absorb(village) cluster(village)
outreg2 using "$nfhs_results/female_head_2_mus.tex", keep(sex_head 1.sex_head#1.muslim 1.muslim) see label dec(3) append


