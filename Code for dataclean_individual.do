clear 
use 1990cencus.dta
gen age = 90 - age_y 

gen prefecture_code = int(prefect)
merge m:m prefecture_code age using saveload1.dta
keep if _merge == 3
drop _merge

gen edu_junior = 0
replace edu_junior = 1 if educ > 2 & edstatus == 2

gen edu_senior = 0
replace edu_senior = 1 if educ > 3 & edstatus == 2

gen edu_high = 0
replace edu_high = 1 if educ > 5 & edstatus == 2

gen unemploy = 0 
replace unemploy = 1 if unemp_st > 1

gen agriculture = 0 
replace agriculture = 1 if industry < 80 & industry != 60

gen nonagriculture = 0 
replace nonagriculture = 1 if industry > 80

gen industrywork = 0 
replace industrywork = 1 if industry < 663 & industry > 140

gen thirdsector = 0 
replace thirdsector = 1 if industry > 663

gen highskill = 0
replace highskill = 1 if occu == 71 | occu == 20 | occu == 35 | occu == 32 | occu == 864 | occu == 41 | occu == 34 | occu == 52 | occu == 91 | occu == 36 | occu == 17 | occu == 19 | occu == 44 | occu == 43 | occu == 738 | occu == 931 | occu == 62 | occu == 63 | occu == 966 | occu == 39 | occu == 964 | occu == 963 | occu == 145 | occu == 51

gen housekeeper = 0 
replace housekeeper = 1 if unemp_st == 2 & sex == 2

gen divorce = 0
replace divorce = 1 if marital == 4

gen total_ceb = ceb_m + ceb_f

gen moreson = 0
replace moreson = 1 if ceb_m > ceb_f



keep if age > 25 & age < 35

gen female = 0
replace female = 1 if sex == 2

save step1.dta, replace

use step1.dta,clear
global cohort edu_junior_age_mean edu_senior_age_mean edu_high_age_mean agriculture_age_mean industrywork_age_mean highskill_age_mean

global region edu_junior_meant edu_senior_meant edu_high_meant agriculture_meant industrywork_meant highskill_meant pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert
eststo clear
eststo: reghdfe unemploy contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe unemploy contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe unemploy contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Labor_Individual1.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 eststo clear
eststo: reghdfe agriculture contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe agriculture contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe agriculture contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Labor_Individual2.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 eststo clear
eststo: reghdfe industrywork contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe industrywork contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe industrywork contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Labor_Individual3.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 eststo clear
eststo: reghdfe thirdsector contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe thirdsector contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe thirdsector contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Labor_Individual4.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 eststo clear
eststo: reghdfe highskill contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe highskill contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe highskill contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)

esttab using "Labor_Individual5.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear
eststo: reghdfe edu_junior contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe edu_junior contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe edu_junior contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Edu_Individual1.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear
eststo: reghdfe edu_senior contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe edu_senior contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe edu_senior contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Edu_Individual2.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear
eststo: reghdfe edu_high contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe edu_high contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe edu_high contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Edu_Individual3.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear
eststo: reghdfe housekeeper contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe housekeeper contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe housekeeper contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Family_Individual1.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear
eststo: reghdfe divorce contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe divorce contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe divorce contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Family_Individual2.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear
eststo: reghdfe total_ceb contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe total_ceb contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe total_ceb contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Family_Individual3.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear
eststo: reghdfe moreson contraction_exponential $region if age > 25 & age < 35 & sex == 1, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe moreson contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe moreson contraction_exponential c.contraction_exponential#c.female female $region if age > 25 & age < 35 , a(prefect c.province_code#age age) cluster(prefect)
esttab using "Family_Individual4.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear

eststo: reghdfe housekeeper contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe divorce contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe total_ceb contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
eststo: reghdfe moreson contraction_exponential $region if age > 25 & age < 35 & sex == 2, a(prefect c.province_code#age age) cluster(prefect)
esttab using "Family_Individual.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

