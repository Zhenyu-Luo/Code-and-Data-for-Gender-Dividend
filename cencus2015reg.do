clear
use pop_panel_with_estimation.dta
gen contraction_linear = (estimated_pop_linear - pop_pro) / estimated_pop_linear
gen contraction_exponential = (estimated_pop_exponential - pop_pro) / estimated_pop_exponential

replace contraction_linear = 0 if contraction_linear == .
replace contraction_exponential = 0 if contraction_exponential == .

drop estimated_pop_linear estimated_pop_exponential

gen gen2_birth = 1990 - age + 23 
xtset prefecture_code age

gen impact = 0.115 * contraction_exponential + 0.106 * l.contraction_exponential + 0.092 * l.l.contraction_exponential + 0.078 * l.l.l.contraction_exponential + 0.069 * l.l.l.l.contraction_exponential + 0.103 * f.contraction_exponential + 0.083 * f.f.contraction_exponential + 0.057 * f.f.f.contraction_exponential + 0.028 * f.f.f.f.contraction_exponential 

keep prefecture_code impact gen2_birth
save gen2_impact.dta, replace
//////////////////////

clear
use cencus2015.dta
destring M2, replace force
rename M2 county_code
destring M34, replace force
rename M34 sex
gen prefecture_code = int( county_code / 100 )

rename M35 gen2_birth
keep if gen2_birth > 1977 & gen2_birth < 1989
merge m:m prefecture_code gen2_birth using gen2_impact.dta
keep if _merge == 3
drop _merge

gen prefect = prefecture_code
merge m:m prefect using controls.dta
keep if _merge == 3
drop _merge

gen province_code = int(prefecture_code / 100)

destring M51, replace force
destring M52, replace force
reghdfe M51 impact if sex == 2, a(gen2_birth prefecture_code)

gen edu_junior = 0
replace edu_junior = 1 if M51 > 2 & M52 == 2

gen edu_senior = 0
replace edu_senior = 1 if M51 > 4 & M52 == 2

gen edu_high = 0
replace edu_high = 1 if M51 > 5 & M52 == 2

gen edu_gra = 0
replace edu_gra = 1 if M51 > 7

gen female = 0
replace female = 1 if sex == 2

global prefect_con pre_sex_ratio temp pop_densit nightlight wheat_suit rice_suita terrain clan_density river marketization post_sex_ratio

destring M70, replace force
replace M70 = 0 if M70 == . 



reghdfe edu_junior impact gen2_birth, a(prefecture_code)
reghdfe edu_junior impact c.impact#c.female female gen2_birth, a(prefecture_code)
logit edu_junior impact gen2_birth $prefect_con if sex == 1
logit edu_junior impact gen2_birth $prefect_con if sex == 2
logit edu_junior impact c.impact#c.female gen2_birth $prefect_con

reghdfe edu_senior impact gen2_birth, a(prefecture_code)
reghdfe edu_senior impact c.impact#c.female gen2_birth , a(prefecture_code)
logit edu_senior impact gen2_birth $prefect_con if sex == 1
logit edu_senior impact gen2_birth $prefect_con if sex == 2
logit edu_senior impact c.impact#c.female gen2_birth $prefect_con

reghdfe edu_high impact gen2_birth, a(prefecture_code)
reghdfe edu_high impact c.impact#c.female gen2_birth , a(prefecture_code)
logit edu_high impact gen2_birth $prefect_con if sex == 1
logit edu_high impact gen2_birth $prefect_con if sex == 2
logit edu_high impact c.impact#c.female gen2_birth $prefect_con

destring M56, replace force
gen agri = 0
replace agri = 1 if M56 < 60

reghdfe agri impact gen2_birth, a(prefecture_code)
reghdfe agri impact c.impact#c.female gen2_birth, a(prefecture_code)
logit agri impact gen2_birth $prefect_con if sex == 1
logit agri impact gen2_birth $prefect_con if sex == 2
logit agri impact c.impact#c.female gen2_birth $prefect_con

gen indu = 0
replace indu = 1 if M56 > 60 & M56 < 510

reghdfe indu impact gen2_birth, a(prefecture_code)
reghdfe indu impact c.impact#c.female gen2_birth, a(prefecture_code)
logit indu impact gen2_birth $prefect_con if sex == 1
logit indu impact gen2_birth $prefect_con if sex == 2
logit indu impact c.impact#c.female gen2_birth $prefect_con

gen serv = 0
replace serv = 1 if M56 > 510


destring M63, replace force
gen unwork = 0
replace unwork = 1 if M63 != . 

reghdfe unwork impact gen2_birth , a(prefecture_code)
reghdfe unwork impact c.impact#c.female gen2_birth, a(prefecture_code)
logit unwork impact gen2_birth $prefect_con if sex == 1
logit unwork impact gen2_birth $prefect_con if sex == 2
logit unwork impact c.impact#c.female gen2_birth $prefect_con

bysort gen2_birth prefecture_code: egen edu_junior_agemean = mean(edu_junior)
bysort gen2_birth prefecture_code: egen edu_senior_agemean = mean(edu_senior)
bysort gen2_birth prefecture_code: egen edu_high_agemean = mean(edu_high)

bysort gen2_birth prefecture_code: egen agri_agemean = mean(agri)
bysort gen2_birth prefecture_code: egen indu_agemean = mean(indu)
bysort gen2_birth prefecture_code: egen unwork_agemean = mean(unwork)

bysort prefecture_code: egen edu_junior_mean = mean(edu_junior)
bysort prefecture_code: egen edu_senior_mean = mean(edu_senior)
bysort prefecture_code: egen edu_high_mean = mean(edu_high)

bysort prefecture_code: egen agri_mean = mean(agri)
bysort prefecture_code: egen indu_mean = mean(indu)
bysort prefecture_code: egen unwork_mean = mean(unwork)

global cohort_con edu_junior_agemean edu_senior_agemean edu_high_agemean agri_agemean indu_agemean unwork_agemean 
global prefect_con pre_sex_ratio temp pop_densit nightlight wheat_suit rice_suita terrain clan_density river marketization post_sex_ratio edu_junior_mean edu_senior_mean edu_high_mean agri_mean indu_mean unwork_mean

eststo clear

*eststo: logit edu_junior impact gen2_birth M70 $prefect_con if sex == 2
*eststo: logit edu_junior impact gen2_birth M70 $prefect_con if sex == 1
*reghdfe edu_junior impact gen2_birth if sex == 2, a(prefecture_code)

eststo: logit edu_senior impact gen2_birth M70 $prefect_con if sex == 1
eststo: logit edu_senior impact gen2_birth M70 $prefect_con if sex == 2
reghdfe edu_senior impact gen2_birth if sex == 2, a(prefecture_code)

eststo: logit edu_high impact gen2_birth M70 $prefect_con if sex == 1
eststo: logit edu_high impact gen2_birth M70 $prefect_con if sex == 2
reghdfe edu_high impact gen2_birth if sex == 2, a(prefecture_code)

eststo: logit edu_gra impact gen2_birth M70 $prefect_con if sex == 1
eststo: logit edu_gra impact gen2_birth M70 $prefect_con if sex == 2
reghdfe edu_gra impact gen2_birth if sex == 2, a(prefecture_code)

esttab using "Generation.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) pr2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear
*eststo: logit agri impact gen2_birth M70 $prefect_con if sex == 2
*eststo: logit agri impact gen2_birth M70 $prefect_con if sex == 1
*reghdfe agri impact gen2_birth if sex == 2, a(prefecture_code)

eststo: logit indu impact gen2_birth M70 $prefect_con if sex == 1
eststo: logit indu impact gen2_birth M70 $prefect_con if sex == 2
reghdfe indu impact gen2_birth if sex == 2, a(prefecture_code)

eststo: logit serv impact gen2_birth M70 $prefect_con if sex == 1
eststo: logit serv impact gen2_birth M70 $prefect_con if sex == 2
reghdfe serv impact gen2_birth if sex == 2, a(prefecture_code)

eststo: logit unwork impact gen2_birth M70 $prefect_con if sex == 1
eststo: logit unwork impact gen2_birth M70 $prefect_con if sex == 2
reghdfe unwork impact gen2_birth if sex == 2, a(prefecture_code)

esttab using "Generation.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) pr2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
////////////////////////

clear
use cencus2015.dta
destring M2, replace force
rename M2 county_code
destring M34, replace force
rename M34 sex
gen prefecture_code = int( county_code / 100 )

rename M35 gen2_birth
keep if gen2_birth > 1977 & gen2_birth < 1989

destring M51, replace force
destring M52, replace force

gen edu_junior = 0
replace edu_junior = 1 if M51 > 2 & M52 == 2

gen edu_senior = 0
replace edu_senior = 1 if M51 > 4 & M52 == 2

gen edu_high = 0
replace edu_high = 1 if M51 > 5 & M52 == 2

bysort prefect: egen edu_junior_mean = mean(edu_junior)
bysort prefect: egen edu_senior_mean = mean(edu_senior)
bysort prefect: egen edu_high_mean = mean(edu_high)

bysort gen2_birth prefecture_code: egen edu_junior_agemean = mean(edu_junior)
bysort gen2_birth prefecture_code: egen edu_senior_agemean = mean(edu_senior)
bysort gen2_birth prefecture_code: egen edu_high_agemean = mean(edu_high)

bysort gen2_birth prefecture_code sex: egen edu_junior_agesex_mean = mean(edu_junior)
bysort gen2_birth prefecture_code sex: egen edu_senior_agesex_mean = mean(edu_senior)
bysort gen2_birth prefecture_code sex: egen edu_high_agesex_mean = mean(edu_high)

gen edu_junior_agesex_manmean1 = edu_junior_agesex_mean if sex == 1
gen edu_junior_agesex_womanmean1 = edu_junior_agesex_mean if sex == 2

gen edu_senior_agesex_manmean1 = edu_senior_agesex_mean if sex == 1
gen edu_senior_agesex_womanmean1 = edu_senior_agesex_mean if sex == 2

gen edu_high_agesex_manmean1 = edu_high_agesex_mean if sex == 1
gen edu_high_agesex_womanmean1 = edu_high_agesex_mean if sex == 2

bysort gen2_birth prefecture_code: egen edu_high_agesex_manmean = max(edu_high_agesex_manmean1)
bysort gen2_birth prefecture_code: egen edu_high_agesex_womanmean = max(edu_high_agesex_womanmean1)

bysort gen2_birth prefecture_code: egen edu_junior_agesex_manmean = max(edu_junior_agesex_manmean1)
bysort gen2_birth prefecture_code: egen edu_junior_agesex_womanmean = max(edu_junior_agesex_womanmean1)

bysort gen2_birth prefecture_code: egen edu_senior_agesex_manmean = max(edu_senior_agesex_manmean1)
bysort gen2_birth prefecture_code: egen edu_senior_agesex_womanmean = max(edu_senior_agesex_womanmean1)

keep gen2_birth prefecture_code edu_junior_mean edu_senior_mean edu_high_mean ///
edu_junior_agemean edu_senior_agemean edu_high_agemean ///
edu_high_agesex_manmean edu_high_agesex_womanmean edu_junior_agesex_manmean edu_junior_agesex_womanmean edu_senior_agesex_manmean edu_senior_agesex_womanmean 
duplicates drop

merge m:m prefecture_code gen2_birth using gen2_impact.dta
keep if _merge == 3
drop _merge

gen prefect = prefecture_code
merge m:m prefect using controls.dta
keep if _merge == 3
drop _merge

gen edu_junior_meant = edu_junior_mean * gen2_birth
gen edu_senior_meant = edu_senior_mean * gen2_birth
gen edu_high_meant = edu_high_mean * gen2_birth

gen pre_sex_ratiot = pre_sex_ratio * gen2_birth
gen tempt = temp * gen2_birth
gen pop_densitt = pop_densit * gen2_birth
gen nightlightt = nightlight * gen2_birth
gen wheat_suitt = wheat_suit * gen2_birth
gen rice_suitat = rice_suita * gen2_birth
gen terraint = terrain * gen2_birth
gen clan_densityt = clan_density * gen2_birth
gen rivert = river * gen2_birth

global edu_junior_meant edu_senior_meant edu_high_meant region pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert edu_junior_meant edu_senior_meant edu_high_meant

reghdfe edu_junior_agesex_womanmean impact edu_junior_agemean edu_senior_agemean edu_high_agemean $region , a(gen2_birth prefecture_code)
reghdfe edu_senior_agesex_womanmean impact edu_junior_agemean edu_senior_agemean edu_high_agemean $region , a(gen2_birth prefecture_code)
reghdfe edu_high_agesex_womanmean impact edu_junior_agemean edu_senior_agemean edu_high_agemean $region , a(gen2_birth prefecture_code)



