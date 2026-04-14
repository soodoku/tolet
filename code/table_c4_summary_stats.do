*Table C4
global path ".."
use "$path\data\SBM beneficiaries with gp details compressed.dta", clear
egen pop = sum(1), by(eleid)
drop if pop<10
drop if subcategory==3
drop if eleid==.

ren muslim_prop_gp2015 muslim_share
ren muslim_prop_gp2010 muslim_share2010

ren womenreservation femalereservation

label var muslim_share "Muslim share"
label var femalereservation "Female reservation"
label var diff "$\Delta$ Muslim share"
label var muslim_share2010 "Muslim share 2010"

duplicates drop eleid, force

keep eleid muslim_share muslim_share2010 femalereservation2010 femalereservation diff muslim_margin

merge 1:1 eleid using "${path}\data\final election caste sbm.dta"

summ tot_new primaryschool_proportion_5km middleschool_proportion_5km secondaryschool_proportion_5km tapwater_proportion closedrainage_proportion wastedisposal_proportion allweatherroad_proportion domesticpower_proportion percentirrigated_gp female_prop apl_prop femalereservation2010 femalereservation muslim_share2010 muslim_share covered_13_14_to_uncovered covered_14_15_to_uncovered covered_15_16_to_uncovered covered_16_17_to_uncovered

// twoway lpolyci female_prop muslim_share if abs(runningvar2_norm_std) <=0.1, graphregion(color(white)) clcolor(black) xtitle("Muslim Household Share")  ytitle("Female Headed Household Share") xlabel(0(.2)1, labsize(*.9)) xsc(r(0 1)) ysc(r(0 .05)) ylabel(0(.01).05) ylabel(, labsize(*.9)) ysc(titlegap(2)) xsc(titlegap(2)) legend(off)