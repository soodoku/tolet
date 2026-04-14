global path ".."

use "$path/data/reds_femalehead_polparticipation.dta", clear

*Table C3 - Columns 3 4
reghdfe meeting_attendance headfemale muslim age age_sq schooling_years schooling_years_sq SC ST if sex == 1 & age >= 18 & castegroup <= 2, a(villageid_numeric) cl(villageid_numeric)
outreg2 using "$path/output/femalehead_polparticipation.tex", replace
summ meeting_attendance if e(sample)==1
reghdfe party_active headfemale muslim age age_sq schooling_years schooling_years_sq SC ST if sex == 1 & age >= 18 & castegroup <= 2, a(villageid_numeric) cl(villageid_numeric)
outreg2 using "$path/output/femalehead_polparticipation.tex", append
summ party_active if e(sample)==1
reghdfe meeting_attendance headfemale muslim muslim_headfemale age age_sq schooling_years schooling_years_sq SC ST if sex == 1 & age >= 18 & castegroup <= 2, a(villageid_numeric) cl(villageid_numeric)
outreg2 using "$path/output/femalehead_polparticipation.tex", append
summ meeting_attendance if e(sample)==1
reghdfe party_active headfemale muslim muslim_headfemale age age_sq schooling_years schooling_years_sq SC ST if sex == 1 & age >= 18 & castegroup <= 2, a(villageid_numeric) cl(villageid_numeric)
outreg2 using "$path/output/femalehead_polparticipation.tex", append see tex label
summ party_active if e(sample)==1
