clear
use survey56-64.dta

merge m:m province age using province_contraction.dta
keep if _merge == 3
drop _merge

merge m:m province age using province_age.dta
keep if _merge == 3
drop _merge

global province_age edu_junior_age_mean edu_senior_age_mean edu_high_age_mean agriculture_age_mean industrywork_age_mean highskill_age_mean


//////////////////////////



clear
use 2000survey56-64.dta
drop age
gen age = age2000 -10

merge m:m province age using province_contraction.dta
keep if _merge == 3
drop _merge

merge m:m province age using province_age.dta
keep if _merge == 3
drop _merge

global province_age edu_junior_age_mean edu_senior_age_mean edu_high_age_mean agriculture_age_mean industrywork_age_mean highskill_age_mean

gen unhealth = 0
replace unhealth = 1 if f1 > 2

logit unhealth contraction_exponential $province_age age b2 c18_a e6_a


global individual age b2 c18_a c18_b e6_a unhealth
gen county = province*100 + shi_xian

////政治
eststo clear 
gen vote = 0
replace vote = 1 if d1_a == 1

reghdfe vote contraction_exponential
reghdfe vote contraction_exponential $province_age
reghdfe vote contraction_exponential $province_age $individual
eststo: logit vote contraction_exponential $province_age $individual
logit vote contraction_exponential c.contraction_exponential#c.agriculture_mean $province_age $individual

gen party = 0
replace party = 1 if d11_a == 2

reghdfe party contraction_exponential
reghdfe party contraction_exponential $province_age
reghdfe party contraction_exponential $province_age $individual
eststo: logit party contraction_exponential $province_age $individual
logit party contraction_exponential c.contraction_exponential#c.agriculture_mean $province_age $individual

gen womanhigh = 0
replace womanhigh = 1 if i3_h < 3

reghdfe womanhigh contraction_exponential
reghdfe womanhigh contraction_exponential $province_age 
reghdfe womanhigh contraction_exponential $province_age $individual
eststo: logit womanhigh contraction_exponential $province_age $individual
logit womanhigh contraction_exponential c.contraction_exponential#c.agriculture_mean $province_age $individual

///
gen womanleader = 0
replace womanleader = 1 if d4_a == 1

reghdfe womanleader contraction_exponential
reghdfe womanleader contraction_exponential $province_age 
reghdfe womanleader contraction_exponential $province_age $individual
eststo: logit womanleader contraction_exponential $province_age $individual
logit womanleader contraction_exponential c.contraction_exponential#c.agriculture_mean $province_age $individual

gen union = 0
replace union = 1 if d2_a == 1 | d2_b == 1 | d2_c == 1 | d2_d == 1 | d2_e == 1

reghdfe union contraction_exponential
reghdfe union contraction_exponential $province_age 
reghdfe union contraction_exponential $province_age $individual
eststo: logit union contraction_exponential $province_age $individual

gen act = 0
replace act = 1 if d3_a == 1 | d3_b == 1 | d3_c == 1

reghdfe act contraction_exponential
reghdfe act contraction_exponential $province_age 
reghdfe act contraction_exponential $province_age $individual
eststo: logit act contraction_exponential $province_age $individual

esttab using "Women_political.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) pr2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace


/////家庭
gen equalfamily = 0
replace equalfamily = 1 if  e8_b == 2 | e8_b == 3 

reghdfe equalfamily contraction_exponential
reghdfe equalfamily contraction_exponential $province_age
reghdfe equalfamily contraction_exponential $province_age $individual
eststo: logit equalfamily contraction_exponential $province_age $individual

///初婚
eststo clear

reghdfe e2_1 contraction_exponential $province_age
eststo:reghdfe e2_1 contraction_exponential $province_age $individual
///初生
reghdfe e6_c contraction_exponential   
reghdfe e6_c contraction_exponential $province_age
eststo: reghdfe e6_c contraction_exponential $province_age $individual

gen goodfamily = 0
replace goodfamily = 1 if i5_b < 3

reghdfe goodfamily contraction_exponential
reghdfe goodfamily contraction_exponential $province_age 
reghdfe goodfamily contraction_exponential $province_age $individual
reghdfe i5_b contraction_exponential $province_age $individual if i5_b < 6
eststo: logit goodfamily contraction_exponential $province_age $individual

gen violate = 0
replace violate = 1 if i8_a == 1

reghdfe violate contraction_exponential
reghdfe violate contraction_exponential $province_age 
reghdfe violate contraction_exponential $province_age $individual
eststo: logit violate contraction_exponential $province_age $individual

gen menhouse = 0
replace menhouse = 1 if i3_i < 3

reghdfe menhouse contraction_exponential
reghdfe menhouse contraction_exponential $province_age 
reghdfe menhouse contraction_exponential $province_age $individual
reghdfe i3_i contraction_exponential $province_age $individual if i3_i < 6
eststo: logit menhouse contraction_exponential $province_age $individual

esttab using "Women_family.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) pr2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
///////////////////Social Concepts////////////////////////////
///
eststo clear

gen mansocial = 0
replace mansocial = 1 if i3_a < 3

reghdfe mansocial contraction_exponential
reghdfe mansocial contraction_exponential $province_age 
reghdfe mansocial contraction_exponential $province_age $individual
eststo: logit mansocial contraction_exponential $province_age $individual
margins, dydx(contraction_exponential) atmeans 

///
gen feelequal = 0
replace feelequal = 1 if i4 == 1

reghdfe feelequal contraction_exponential
reghdfe feelequal contraction_exponential $province_age 
reghdfe feelequal contraction_exponential $province_age $individual
eststo: logit feelequal contraction_exponential $province_age $individual
margins, dydx(contraction_exponential) atmeans 


///
gen manability = 0
replace manability = 1 if i3_b < 3

reghdfe manability contraction_exponential
reghdfe manability contraction_exponential $province_age 
reghdfe manability contraction_exponential $province_age $individual
reghdfe i3_b contraction_exponential $province_age $individual if i3_b < 6
eststo: logit manability contraction_exponential $province_age $individual
margins, dydx(contraction_exponential) atmeans 

///
gen womanface = 0
replace womanface = 1 if i3_g < 3

reghdfe womanface contraction_exponential
reghdfe womanface contraction_exponential $province_age 
reghdfe womanface contraction_exponential $province_age $individual
eststo: logit womanface contraction_exponential $province_age $individual
margins, dydx(contraction_exponential) atmeans 

gen marrygood = 0
replace marrygood = 1 if i3_c < 3

reghdfe marrygood contraction_exponential
reghdfe marrygood contraction_exponential $province_age 
reghdfe marrygood contraction_exponential $province_age $individual
eststo: logit marrygood contraction_exponential $province_age $individual

gen childwoman = 0
replace childwoman = 1 if i3_d < 3

reghdfe childwoman contraction_exponential
reghdfe childwoman contraction_exponential $province_age 
reghdfe childwoman contraction_exponential $province_age $individual
eststo: logit childwoman contraction_exponential $province_age $individual

gen womanless = 0
replace womanless = 1 if i3_e < 3

reghdfe womanless contraction_exponential
reghdfe womanless contraction_exponential $province_age 
reghdfe womanless contraction_exponential $province_age $individual
eststo: logit womanless contraction_exponential $province_age $individual

esttab using "Women_Social.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) pr2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
