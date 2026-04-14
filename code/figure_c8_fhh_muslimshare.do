*Figure C8
global path ".."

use "$path\data\gp_final.dta", clear

twoway lpolyci female_prop muslim_share, graphregion(color(white)) clcolor(black) xtitle("Muslim Household Share")  ytitle("Female Headed Household Share") xlabel(0(.2)1, labsize(*.9)) xsc(r(0 1)) ysc(r(0 .05)) ylabel(0(.01).05) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2)) legend(off)
graph export "${path}\output\fhh_mshare.eps", as(eps) preview(on) replace