global path ".."

use "$path\data\survey_sanitation_2014.dta", clear
gen od = g2_1_ == 2
replace od = . if g2_1_ == .
gen toiletuse = 1 if od == 0
replace toiletuse = 0 if od == 1

gen hindu = h1 == 1
gen muslim = h1 == 2
replace hindu = . if h1 == .
replace muslim = . if h1 == .
gen other = 1 if h1 != . & h1 != 1 & h1 != 2
replace other = 0 if h1 != . & other == .

gen huc = 1 if hindu == 1 & (h3 == 1 | h3 == 2)
replace huc = 0 if hindu == 0 | (hindu == 1 & h3 != 1 & h3 != 2)
gen hlc = 1 if hindu == 1 & h3 != 1 & h3 != 2
replace hlc = 0 if hindu == 0 | (hindu == 1 & (h3 == 1 | h3 == 2))

gen hobc = 1 if hindu == 1 & h3 == 3
replace hobc = 0 if hindu == 0 | (hindu == 1 & h3 != 3)
gen hsc = 1 if hindu == 1 & h3 == 4
replace hsc = 0 if hindu == 0 | (hindu == 1 & h3 != 4)


gen female = b1_2_ == 2
gen hlcfemale = hlc*female
gen muslimfemale = muslim*female
gen otherfemale = other*female

gen hscfemale = hsc*female
gen hobcfemale = hobc*female

egen vill_hh = concat(villagecode id), p("-")
encode vill_hh, gen(hhid)
drop vill_hh

gen latrine_pref1 = 1 if e13_N == 1
replace latrine_pref1 = 0 if e13_N != . & latrine_pref1 == .
gen latrine_pref2 = 1 if e13_N == 1 | e13_N == 2
replace latrine_pref2 = 0 if e13_N != . & latrine_pref2 == .
gen latrine_pref3 = 1 if e13_N == 1 | e13_N == 2 | e13_N == 3
replace latrine_pref3 = 0 if e13_N != . & latrine_pref3 == .

gen headhh = b1_3_ == 1
replace headhh = . if b1_3_ == .
gen headhh_female = headhh*female
gen headhh_muslimfemale = headhh*muslimfemale
gen headhh_muslim = headhh*muslim
bys id: egen femaleheaded_hh = max(headhh_female)
gen femaleheaded_muslim = femaleheaded_hh*muslim

bys villagecode: egen muslim_share = mean(muslim)

gen daughter = (female == 1 & b1_3_ == 3)
bys hhid: egen hasdaughter = max(daughter)
gen female_hasdaughter = female*hasdaughter

gen adultdaughter = (female == 1 & b1_3_ == 3 & b1_4_y_ >= 10)
bys hhid: egen hasadultdaughter = max(daughter)
gen female_hasadultdaughter = female*hasadultdaughter


label var hlc "Hindu Lower Caste"
label var muslim "Muslim"
label var other "Other"
label var female "Female"
label var hlcfemale "Hindu Lower Caste * Female"
label var muslimfemale "Muslim * Female"
label var otherfemale "Other * Female"
label var headhh "Head of HH"
label var headhh_female "Head of HH * Female"
label var headhh_muslim "Head of HH * Muslim"
label var headhh_muslimfemale "Head of HH * Muslim * Female"
label var femaleheaded_hh "Female Headed HH"
label var femaleheaded_muslim "Female Headed HH * Muslim"
label var hasdaughter "Family has Daughter"
label var female_hasdaughter "Female * Family has Daughter"
label var hasadultdaughter "Family has Daughter (10 y.o. and above)"
label var female_hasadultdaughter "Female * Family has Daughter (10 y.o. and above)"

label var female "Female"
reghdfe toiletuse female muslim c.female#c.muslim c.muslim_share#c.female c.muslim_share#c.muslim c.muslim_share#c.female#c.muslim ///
e11_a-e11_e e11_h e11_j e11_p e11_t if b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 1 & b2_3 != 1, a(villagecode e8) cl(villagecode)
outreg2 using "$path/output/toiletpref_muslimshare_hindu.tex", replace
summ toiletuse if e(sample)==1
reghdfe toiletuse female muslim c.female#c.muslim c.muslim_share#c.female c.muslim_share#c.muslim c.muslim_share#c.female#c.muslim ///
e11_a-e11_e e11_h e11_j e11_p e11_t if b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 1 & b2_3 != 1, a(hhid e8) cl(villagecode)
outreg2 using "$path/output/toiletpref_muslimshare_hindu.tex", append
summ toiletuse if e(sample)==1
reghdfe latrine_pref1 female muslim c.female#c.muslim c.muslim_share#c.female c.muslim_share#c.muslim c.muslim_share#c.female#c.muslim ///
e11_a-e11_e e11_h e11_j e11_p e11_t if b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & b2_3 != 1 & selected == 1, a(villagecode e8) cl(villagecode)
outreg2 using "$path/output/toiletpref_muslimshare_hindu.tex", append
summ latrine_pref1 if e(sample)==1
reghdfe latrine_pref2 female muslim c.female#c.muslim c.muslim_share#c.female c.muslim_share#c.muslim c.muslim_share#c.female#c.muslim ///
e11_a-e11_e e11_h e11_j e11_p e11_t if b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & b2_3 != 1 & selected == 1, a(villagecode e8) cl(villagecode)
outreg2 using "$path/output/toiletpref_muslimshare_hindu.tex", append
summ latrine_pref2 if e(sample)==1
reghdfe latrine_pref3 female muslim c.female#c.muslim c.muslim_share#c.female c.muslim_share#c.muslim c.muslim_share#c.female#c.muslim ///
e11_a-e11_e e11_h e11_j e11_p e11_t if b1_4_y_ >= 5 & b1_4_y_ <= 65 & g2_9 == 2 & b2_3 != 1 & selected == 1, a(villagecode e8) cl(villagecode)
outreg2 using "$path/output/toiletpref_muslimshare_hindu.tex", append see label tex(frag)
summ latrine_pref3 if e(sample)==1