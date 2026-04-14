global path ".."

set scheme s1color
use "$path/data/final election caste sbm.dta", clear
graph twoway (lpolyci muslim muslimpropgp_censusadj_new if womenreservation == 0 & ///
			 abs(runningvar2_norm_std) <= 0.1, clcolor(black) clw(thick) ciplot(rline)) ///
			 (lpolyci muslim muslimpropgp_censusadj_new if womenreservation == 1 & ///
			 abs(runningvar2_norm_std) <= 0.1, clcolor(gs8) clw(thick) lp(dash) ciplot(rline)), ///
			 xtitle("Muslim Share") ytitle("Sarpanch is Muslim") graphregion(fcolor(white) ///
			 lcolor(white)) ylabel(,nogrid) legend(order(2 4) label(2 "Not Women Reserved") label(4 "Women Reserved"))

graph export "$path/output/muslimsarpanch_muslimshare.png", as(png) name("Graph") replace	 
