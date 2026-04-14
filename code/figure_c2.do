global path ".."

use "$path\data\SBM beneficiaries with gp details compressed.dta", clear
egen blockmuslimhhcount = sum( muslim_pred), by( dist_block)
egen hhcount = sum(1), by( dist_block)

keep dist_block blockmuslimhhcount hhcount
duplicates drop
replace dist_block=upper(dist_block)
save "$path\data\block religion composition.dta", replace

use "$path\data\district tehsil block matching.dta", clear
ren districtname districtname_old
ren districtname_new districtname
egen dist_block = concat(districtname blockname), punct("_")
replace dist_block=upper(dist_block)
replace dist_block = "FAIZABAD_MAWAI" if dist_block == "FAIZABAD_MAVAI"
merge m:1 dist_block using "$path\data\block religion composition.dta"
drop _merge

ren districtname districtname_new
ren districtname_old districtname

replace districtname = upper(districtname)
replace subdistrictname = upper(subdistrictname)

merge m:1 districtname subdistrictname using "$path\data\census 2011 tehsil level religion"
drop _merge

egen weight = sum(1), by(blockcode)
replace weight = 1/weight

egen tehsilhhcount = sum( hhcount*weight), by( subdistrictcode)
egen tehsilmuslimhhcount = sum( blockmuslimhhcount*weight), by( subdistrictcode)
gen tehsilmuslimprop = tehsilmuslimhhcount/ tehsilhhcount
gen tehsilmuslimprop_adj = ( tehsilmuslimprop + .9739 - 1)/(.9739+.9691-1)
replace tehsilmuslimprop_adj = 0 if tehsilmuslimprop_adj<0

gen muslim_propcensus = censusmuslimpop/ censustotalpop

set scheme cleanplots

sort subdistrictcode

twoway (scatter tehsilmuslimprop_adj muslim_propcensus if subdistrictcode!=subdistrictcode[_n-1], mcolor(gs8)) (lfit tehsilmuslimprop_adj muslim_propcensus if subdistrictcode!=subdistrictcode[_n-1], lcolor(black)), xtitle("Muslim Population Share") ytitle("Estimated Muslim Household Share") legend(off) graphregion(color(white)) bgcolor(white)

graph export "$path\output\estimated_and_true_muslim_share_tehsil_lfit.eps", as(eps) name("Graph") preview(off) replace

corr muslim_propcensus tehsilmuslimprop_adj if subdistrictcode!=subdistrictcode[_n-1]
