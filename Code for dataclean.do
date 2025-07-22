
/////////////////import data//////////////////////////
*****************************************************************
clear 
use 1990cencus.dta
gen num = 1
*****************
bysort prefect: egen pop_sample = sum(num)
keep prefect pop_sample
duplicates drop
save pop_sample.dta

/////////////////////生成1956年以前出生的性别比，控制变量///////////////

clear 
use 1990cencus.dta
gen age = 90 - age_y 
keep if age > 34 & age < 42

gen male = 0
replace male =1 if sex == 1
gen female = 1 - male
bysort prefect: egen pop_male = sum(male)
bysort prefect: egen pop_female = sum(female)
keep prefect pop_male pop_female
duplicates drop

gen pre_sex_ratio = pop_male / pop_female
drop pop_male pop_female
save 1956ratio.dta, replace

clear 
use 1990cencus.dta
gen age = 90 - age_y 
keep if age < 26

gen male = 0
replace male =1 if sex == 1
gen female = 1 - male
bysort prefect: egen pop_male = sum(male)
bysort prefect: egen pop_female = sum(female)
keep prefect pop_male pop_female
duplicates drop

gen post_sex_ratio = pop_male / pop_female
drop pop_male pop_female
save 1965ratio.dta, replace

clear 
use 1990cencus.dta
gen age = 90 - age_y 
keep if age < 42
gen male = 0
replace male =1 if sex == 1
gen female = 1 - male
bysort prefect age: egen pop_male_age = sum(male)
bysort prefect age: egen pop_female_age = sum(female)
keep prefect age pop_male_age pop_female_age
duplicates drop

gen sex_ratio_age = pop_male_age / pop_female_age
drop pop_male_age pop_female_age
save sex_ratio.dta, replace

/////////////////人口结构损失数据///////////////////
clear 
use 1990cencus.dta
gen num = 1
gen age = 90 - age_y //生成年龄
bysort prefect age: egen pop_age_sum = sum(num)
bysort prefect: egen pop_sum = sum(num)
gen pop_pro = pop_age_sum / pop_sum //生成各年龄占比

drop if age < 0

/////////////////导出年龄结构数据/////////////////
keep age prefect pop_pro
duplicates drop

gen prefecture_code = int(prefect)
drop prefect

save pop_panel.dta, replace
////////省级别/////////////////
clear 
use 1990cencus.dta
gen num = 1

keep if sex == 2

gen age = 90 - age_y 
bysort province age: egen pop_age_sum = sum(num)
bysort province: egen pop_sum = sum(num)
gen pop_pro = pop_age_sum / pop_sum 

drop if age < 0

keep age province pop_pro
duplicates drop

gen province_code = int(province)
drop province

save pop_panel_province.dta, replace

/////////////////////生成女性的年龄结构数据/////////////////
clear 
use 1990cencus.dta
gen num = 1

keep if sex == 2

gen age = 90 - age_y 
bysort prefect age: egen pop_age_sum = sum(num)
bysort prefect: egen pop_sum = sum(num)
gen pop_pro = pop_age_sum / pop_sum 

drop if age < 0

keep age prefect pop_pro
duplicates drop

gen prefecture_code = int(prefect)
drop prefect

save pop_panel_woman.dta, replace

/////////////////////生成男性的年龄结构数据/////////////////

clear 
use 1990cencus.dta
gen num = 1

keep if sex == 1

gen age = 90 - age_y 
bysort prefect age: egen pop_age_sum = sum(num)
bysort prefect: egen pop_sum = sum(num)
gen pop_pro = pop_age_sum / pop_sum 

drop if age < 0

keep age prefect pop_pro
duplicates drop

gen prefecture_code = int(prefect)
drop prefect

save pop_panel_man.dta, replace

///////////////////////////////////////////////////////////////////////
/////////////////////接下来计算出生队列收缩率，需要使用Python代码//////
///////////////////////////////////////////////////////////////////////
//////////////////////////python处理后，手动拼接///////////////////////
///////////////////////////////////////////////////////////////////////
////////////////////得到文件：pop_panel_with_estimation.dta////////////
///////////////////////////////////////////////////////////////////////

////////////////生成核心的output variables/////////////////////////////

clear 
use 1990cencus.dta
gen num = 1
gen age = 90 - age_y
 
//////////////////受教育情况
gen illiterate = 0 
replace illiterate = 1 if (educ == 1 | educ == 0) & edstatus == 2

gen edu_primary = 0
replace edu_primary = 1 if educ > 1 & edstatus == 2

gen edu_junior = 0
replace edu_junior = 1 if educ > 2 & edstatus == 2

gen edu_senior = 0
replace edu_senior = 1 if educ > 3 & edstatus == 2

gen edu_high = 0
replace edu_high = 1 if educ > 5 & edstatus == 2

///////////////////////辍学情况

gen drop_primary = 0
replace drop_primary = 1 if educ > 1 & edstatus != 2

gen drop_junior = 0
replace drop_junior = 1 if educ > 2 & edstatus != 2

gen drop_senior = 0
replace drop_senior = 1 if educ > 3 & edstatus != 2

gen drop_high = 0
replace drop_high = 1 if educ > 5 & edstatus != 2
////////////////////////it面板数据生成
bysort prefect: egen illiterate_mean = mean(illiterate)
bysort prefect: egen edu_primary_mean = mean(edu_primary)
bysort prefect: egen edu_junior_mean = mean(edu_junior)
bysort prefect: egen edu_senior_mean = mean(edu_senior)
bysort prefect: egen edu_high_mean = mean(edu_high)
bysort prefect: egen drop_primary_mean = mean(drop_primary)
bysort prefect: egen drop_junior_mean = mean(drop_junior)
bysort prefect: egen drop_senior_mean = mean(drop_senior)
bysort prefect: egen drop_high_mean = mean(drop_high)

bysort prefect age: egen illiterate_age_mean = mean(illiterate)
bysort prefect age: egen edu_primary_age_mean = mean(edu_primary)
bysort prefect age: egen edu_junior_age_mean = mean(edu_junior)
bysort prefect age: egen edu_senior_age_mean = mean(edu_senior)
bysort prefect age: egen edu_high_age_mean = mean(edu_high)
bysort prefect age: egen drop_primary_age_mean = mean(drop_primary)
bysort prefect age: egen drop_junior_age_mean = mean(drop_junior)
bysort prefect age: egen drop_senior_age_mean = mean(drop_senior)
bysort prefect age: egen drop_high_age_mean = mean(drop_high)

bysort prefect age sex: egen illiterate_agesex_mean = mean(illiterate)
bysort prefect age sex: egen edu_primary_agesex_mean = mean(edu_primary)
bysort prefect age sex: egen edu_junior_agesex_mean = mean(edu_junior)
bysort prefect age sex: egen edu_senior_agesex_mean = mean(edu_senior)
bysort prefect age sex: egen edu_high_agesex_mean = mean(edu_high)
bysort prefect age sex: egen drop_primary_agesex_mean = mean(drop_primary)
bysort prefect age sex: egen drop_junior_agesex_mean = mean(drop_junior)
bysort prefect age sex: egen drop_senior_agesex_mean = mean(drop_senior)
bysort prefect age sex: egen drop_high_agesex_mean = mean(drop_high)

gen illiterate_agesex_manmean1 = illiterate_agesex_mean if sex == 1
gen illiterate_agesex_womanmean1 = illiterate_agesex_mean if sex == 2

gen edu_primary_agesex_manmean1 = edu_primary_agesex_mean if sex == 1
gen edu_primary_agesex_womanmean1 = edu_primary_agesex_mean if sex == 2

gen edu_junior_agesex_manmean1 = edu_junior_agesex_mean if sex == 1
gen edu_junior_agesex_womanmean1 = edu_junior_agesex_mean if sex == 2

gen edu_senior_agesex_manmean1 = edu_senior_agesex_mean if sex == 1
gen edu_senior_agesex_womanmean1 = edu_senior_agesex_mean if sex == 2

gen edu_high_agesex_manmean1 = edu_high_agesex_mean if sex == 1
gen edu_high_agesex_womanmean1 = edu_high_agesex_mean if sex == 2

gen drop_primary_agesex_manmean1 = drop_primary_agesex_mean if sex == 1
gen drop_primary_agesex_womanmean1 = drop_primary_agesex_mean if sex == 2

gen drop_junior_agesex_manmean1 = drop_junior_agesex_mean if sex == 1
gen drop_junior_agesex_womanmean1 = drop_junior_agesex_mean if sex == 2

gen drop_senior_agesex_manmean1 = drop_senior_agesex_mean if sex == 1
gen drop_senior_agesex_womanmean1 = drop_senior_agesex_mean if sex == 2

gen drop_high_agesex_manmean1 = drop_high_agesex_mean if sex == 1
gen drop_high_agesex_womanmean1 = drop_high_agesex_mean if sex == 2

bysort prefect age: egen illiterate_agesex_manmean = max(illiterate_agesex_manmean1)
bysort prefect age: egen illiterate_agesex_womanmean = max(illiterate_agesex_womanmean1)

bysort prefect age: egen edu_primary_agesex_manmean = max(edu_primary_agesex_manmean1)
bysort prefect age: egen edu_primary_agesex_womanmean = max(edu_primary_agesex_womanmean1)

bysort prefect age: egen edu_junior_agesex_manmean = max(edu_junior_agesex_manmean1)
bysort prefect age: egen edu_junior_agesex_womanmean = max(edu_junior_agesex_womanmean1)

bysort prefect age: egen edu_senior_agesex_manmean = max(edu_senior_agesex_manmean1)
bysort prefect age: egen edu_senior_agesex_womanmean = max(edu_senior_agesex_womanmean1)

bysort prefect age: egen edu_high_agesex_manmean = max(edu_high_agesex_manmean1)
bysort prefect age: egen edu_high_agesex_womanmean = max(edu_high_agesex_womanmean1)

bysort prefect age: egen drop_primary_agesex_manmean = max(drop_primary_agesex_manmean1)
bysort prefect age: egen drop_primary_agesex_womanmean = max(drop_primary_agesex_womanmean1)

bysort prefect age: egen drop_junior_agesex_manmean = max(drop_junior_agesex_manmean1)
bysort prefect age: egen drop_junior_agesex_womanmean = max(drop_junior_agesex_womanmean1)

bysort prefect age: egen drop_senior_agesex_manmean = max(drop_senior_agesex_manmean1)
bysort prefect age: egen drop_senior_agesex_womanmean = max(drop_senior_agesex_womanmean1)

bysort prefect age: egen drop_high_agesex_manmean = max(drop_high_agesex_manmean1)
bysort prefect age: egen drop_high_agesex_womanmean = max(drop_high_agesex_womanmean1)

//////////////////////就业程度数据//////////////////////////////////
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

bysort prefect: egen unemploy_mean = mean(unemploy)
bysort prefect: egen agriculture_mean = mean(agriculture)
bysort prefect: egen nonagriculture_mean = mean(nonagriculture)
bysort prefect: egen industrywork_mean = mean(industrywork)
bysort prefect: egen thirdsector_mean = mean(thirdsector)
bysort prefect: egen highskill_mean = mean(highskill)

bysort prefect age: egen unemploy_age_mean = mean(unemploy)
bysort prefect age: egen agriculture_age_mean = mean(agriculture)
bysort prefect age: egen nonagriculture_age_mean = mean(nonagriculture)
bysort prefect age: egen industrywork_age_mean = mean(industrywork)
bysort prefect age: egen thirdsector_age_mean = mean(thirdsector)
bysort prefect age: egen highskill_age_mean = mean(highskill)

bysort prefect age sex: egen unemploy_agesex_mean = mean(unemploy)
bysort prefect age sex: egen agriculture_agesex_mean = mean(agriculture)
bysort prefect age sex: egen nonagriculture_agesex_mean = mean(nonagriculture)
bysort prefect age sex: egen industrywork_agesex_mean = mean(industrywork)
bysort prefect age sex: egen thirdsector_agesex_mean = mean(thirdsector)
bysort prefect age sex: egen highskill_agesex_mean = mean(highskill)

gen unemploy_agesex_manmean1 = unemploy_agesex_mean if sex == 1
gen unemploy_agesex_womanmean1 = unemploy_agesex_mean if sex == 2

gen agriculture_agesex_manmean1 = agriculture_agesex_mean if sex == 1
gen agriculture_agesex_womanmean1 = agriculture_agesex_mean if sex == 2

gen nonagriculture_agesex_manmean1 = nonagriculture_agesex_mean if sex == 1
gen nonagriculture_agesex_womanmean1 = nonagriculture_agesex_mean if sex == 2

gen industrywork_agesex_manmean1 = industrywork_agesex_mean if sex == 1
gen industrywork_agesex_womanmean1 = industrywork_agesex_mean if sex == 2

gen thirdsector_agesex_manmean1 = thirdsector_agesex_mean if sex == 1
gen thirdsector_agesex_womanmean1 = thirdsector_agesex_mean if sex == 2

gen highskill_agesex_manmean1 = highskill_agesex_mean if sex == 1
gen highskill_agesex_womanmean1 = highskill_agesex_mean if sex == 2

bysort prefect age: egen unemploy_agesex_manmean = max(unemploy_agesex_manmean1)
bysort prefect age: egen unemploy_agesex_womanmean = max(unemploy_agesex_womanmean1)

bysort prefect age: egen agriculture_agesex_manmean = max(agriculture_agesex_manmean1)
bysort prefect age: egen agriculture_agesex_womanmean = max(agriculture_agesex_womanmean1)

bysort prefect age: egen nonagriculture_agesex_manmean = max(nonagriculture_agesex_manmean1)
bysort prefect age: egen nonagriculture_agesex_womanmean = max(nonagriculture_agesex_womanmean1)

bysort prefect age: egen industrywork_agesex_manmean = max(industrywork_agesex_manmean1)
bysort prefect age: egen industrywork_agesex_womanmean = max(industrywork_agesex_womanmean1)

bysort prefect age: egen thirdsector_agesex_manmean = max(thirdsector_agesex_manmean1)
bysort prefect age: egen thirdsector_agesex_womanmean = max(thirdsector_agesex_womanmean1)

bysort prefect age: egen highskill_agesex_manmean = max(highskill_agesex_manmean1)
bysort prefect age: egen highskill_agesex_womanmean = max(highskill_agesex_womanmean1)

//////////////////////婚姻，家庭与生育/////////////////////////////

gen housekeeper = 0 
replace housekeeper = 1 if unemp_st == 2 & sex == 2

gen divorce = 0
replace divorce = 1 if marital == 4

gen total_ceb = ceb_m + ceb_f

bysort prefect: egen housekeeper_mean = mean(housekeeper)
bysort prefect: egen divorce_mean = mean(divorce)
bysort prefect: egen total_ceb_mean = mean(total_ceb)
bysort prefect: egen ceb_m_mchild_mean = mean(ceb_m)
bysort prefect: egen ceb_f_smchild_mean = mean(ceb_f)

bysort prefect age sex: egen housekeeper_agesex_mean = mean(housekeeper)
bysort prefect age sex: egen divorce_agesex_mean = mean(divorce)
bysort prefect age sex: egen total_ceb_agesex_mean = mean(total_ceb)
bysort prefect age sex: egen ceb_m_agesex_mean = mean(ceb_m)
bysort prefect age sex: egen ceb_f_agesex_mean = mean(ceb_f)

gen housekeeper_agesex_womanmean1 = housekeeper_agesex_mean if sex == 2
gen divorce_agesex_womanmean1 = divorce_agesex_mean if sex == 2
gen total_ceb_agesex_womanmean1 = total_ceb_agesex_mean if sex == 2
gen ceb_m_agesex_womanmean1 = ceb_m_agesex_mean if sex == 2
gen ceb_f_agesex_womanmean1 = ceb_f_agesex_mean if sex == 2

bysort prefect age: egen housekeeper_agesex_womanmean = max(housekeeper_agesex_womanmean1)
bysort prefect age: egen divorce_agesex_womanmean = max(divorce_agesex_womanmean1)
bysort prefect age: egen total_ceb_agesex_womanmean = max(total_ceb_agesex_womanmean1)
bysort prefect age: egen ceb_m_agesex_womanmean = max(ceb_m_agesex_womanmean1)
bysort prefect age: egen ceb_f_agesex_womanmean = max(ceb_f_agesex_womanmean1)

//////////////////////生成面板数据/////////////////////////
keep age prefect ///
illiterate_mean edu_primary_mean edu_junior_mean edu_senior_mean edu_high_mean drop_primary_mean drop_junior_mean drop_senior_mean drop_high_mean ///
illiterate_age_mean edu_primary_age_mean edu_junior_age_mean edu_senior_age_mean edu_high_age_mean drop_primary_age_mean drop_junior_age_mean drop_senior_age_mean drop_high_age_mean ///
edu_primary_agesex_manmean edu_primary_agesex_womanmean edu_junior_agesex_manmean edu_junior_agesex_womanmean edu_senior_agesex_manmean edu_senior_agesex_womanmean edu_high_agesex_manmean edu_high_agesex_womanmean illiterate_agesex_manmean illiterate_agesex_womanmean ///
drop_primary_agesex_manmean drop_primary_agesex_womanmean drop_junior_agesex_manmean drop_junior_agesex_womanmean drop_senior_agesex_manmean drop_senior_agesex_womanmean drop_high_agesex_manmean drop_high_agesex_womanmean ///
unemploy_mean agriculture_mean nonagriculture_mean industrywork_mean thirdsector_mean highskill_mean ///
unemploy_age_mean agriculture_age_mean nonagriculture_age_mean industrywork_age_mean thirdsector_age_mean highskill_age_mean ///
unemploy_agesex_manmean unemploy_agesex_womanmean agriculture_agesex_manmean agriculture_agesex_womanmean nonagriculture_agesex_manmean nonagriculture_agesex_womanmean industrywork_agesex_manmean industrywork_agesex_womanmean thirdsector_agesex_manmean thirdsector_agesex_womanmean highskill_agesex_manmean highskill_agesex_womanmean ///
housekeeper_mean divorce_mean total_ceb_mean ceb_m_mchild_mean ceb_f_smchild_mean ///
housekeeper_agesex_womanmean divorce_agesex_womanmean total_ceb_agesex_womanmean ceb_m_agesex_womanmean ceb_f_agesex_womanmean 

duplicates drop
drop if age < 0

save pref_age_micro.dta, replace
///////////生成省变量/////////////////////
clear
use controls.dta
sum pop_densit nightlight pre_sex_ratio clan_density temp terrain river rice_suita wheat_suit, detail
tabstat pop_densit nightlight pre_sex_ratio clan_density temp terrain river rice_suita wheat_suit, ///
    stat(mean median sd min max n) col(s)

	
//////////生成画地图用的严重程度///////////////////////////////////	
clear	
use pop_panel_with_estimation.dta
gen contraction_linear = (estimated_pop_linear - pop_pro) / estimated_pop_linear
gen contraction_exponential = (estimated_pop_exponential - pop_pro) / estimated_pop_exponential

replace contraction_linear = 0 if contraction_linear == .
replace contraction_exponential = 0 if contraction_exponential == .

drop estimated_pop_linear estimated_pop_exponential

bysort prefecture_code: egen Sum_contraction = sum(contraction_exponential)

keep prefecture_code Sum_contraction
duplicates drop
save contraction_formap.dta, replace
	

	
	
clear
use pref_age_micro.dta
gen province_code = int(prefect / 100) 

////////////////合并outcome和解释变量///////////////////
merge m:m prefect using pop_sample.dta
drop _merge

////////////

gen prefecture_code = int(prefect)
merge m:m age prefecture_code using pop_panel_with_estimation.dta
drop _merge


///////////////////生成解释变量的正确形式////////////////////////
gen contraction_linear = (estimated_pop_linear - pop_pro) / estimated_pop_linear
gen contraction_exponential = (estimated_pop_exponential - pop_pro) / estimated_pop_exponential

replace contraction_linear = 0 if contraction_linear == .
replace contraction_exponential = 0 if contraction_exponential == .

drop estimated_pop_linear estimated_pop_exponential

///////////////////生成孩子的性别比////////////////////////

gen kids_sexration_agesex_womanmean = ceb_m_agesex_womanmean / ceb_f_agesex_womanmean

////////////////合并男女各自的contraction//////////////////////////
merge m:m age prefecture_code using pop_panel_man_with_estimation.dta
drop _merge
gen contraction_linear_man = (estimated_pop_linear - pop_pro) / estimated_pop_linear
gen contraction_exponential_man = (estimated_pop_exponential - pop_pro) / estimated_pop_exponential

replace contraction_linear_man = 0 if contraction_linear_man == .
replace contraction_exponential_man = 0 if contraction_exponential_man == .

drop estimated_pop_linear estimated_pop_exponential

////////////////////////////////////////////////////

merge m:m age prefecture_code using pop_panel_woman_with_estimation.dta
drop _merge
gen contraction_linear_woman = (estimated_pop_linear - pop_pro) / estimated_pop_linear
gen contraction_exponential_woman = (estimated_pop_exponential - pop_pro) / estimated_pop_exponential

replace contraction_linear_woman = 0 if contraction_linear_woman == .
replace contraction_exponential_woman = 0 if contraction_exponential_woman == .

drop estimated_pop_linear estimated_pop_exponential

merge m:m prefect using controls.dta
drop _merge

merge m:m prefect age using sex_ratio.dta
drop if age < 0
drop _merge

drop if pop_sample < 6288

//////////////////////sum for contraction///////////////////////////

sort pop_sample
sum pop_sample, detail
***第一张表
sum contraction_linear contraction_linear_man contraction_linear_woman if age > 28 & age < 32, detail
sum contraction_exponential contraction_exponential_man contraction_exponential_woman if age > 28 & age < 32, detail

****第二张表

sum edu_junior_agesex_womanmean edu_senior_agesex_womanmean edu_high_agesex_womanmean drop_junior_agesex_womanmean drop_senior_agesex_womanmean drop_high_agesex_womanmean if age > 25 & age < 35

sum edu_junior_agesex_manmean edu_senior_agesex_manmean edu_high_agesex_manmean drop_junior_agesex_manmean drop_senior_agesex_manmean drop_high_agesex_manmean if age > 25 & age < 35

sum unemploy_agesex_womanmean agriculture_agesex_womanmean industrywork_agesex_womanmean thirdsector_agesex_womanmean highskill_agesex_womanmean if age > 25 & age < 35

sum unemploy_agesex_manmean agriculture_agesex_manmean industrywork_agesex_manmean thirdsector_agesex_manmean highskill_agesex_manmean if age > 25 & age < 35

sum divorce_agesex_womanmean housekeeper_agesex_womanmean total_ceb_agesex_womanmean kids_sexration_agesex_womanmean if age > 25 & age < 35, detail

sum edu_senior_age_mean edu_high_age_mean agriculture_age_mean industrywork_age_mean highskill_age_mean if age > 25 & age < 35, detail

sum edu_junior_mean edu_senior_mean edu_high_mean agriculture_mean industrywork_mean highskill_mean if age == 25, detail

/////////////////////////////baseline, education/////////////////////////////////////////////////

global cohort edu_junior_agesex_manmean edu_senior_agesex_manmean edu_high_agesex_manmean agriculture_agesex_manmean industrywork_agesex_manmean highskill_agesex_manmean

gen edu_junior_meant = edu_junior_mean * age
gen edu_senior_meant = edu_senior_mean * age
gen edu_high_meant = edu_high_mean * age
gen agriculture_meant = agriculture_mean * age
gen industrywork_meant = industrywork_mean * age
gen highskill_meant = highskill_mean * age

gen pre_sex_ratiot = pre_sex_ratio * age
gen tempt = temp * age
gen pop_densitt = pop_densit * age
gen nightlightt = nightlight * age
gen wheat_suitt = wheat_suit * age
gen rice_suitat = rice_suita * age
gen terraint = terrain * age
gen clan_densityt = clan_density * age
gen rivert = river * age

global region edu_junior_meant edu_senior_meant edu_high_meant agriculture_meant industrywork_meant highskill_meant pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert

gen conddrop_junior_agesex_womanmean = drop_junior_agesex_womanmean / edu_junior_agesex_womanmean
gen conddrop_senior_agesex_womanmean = drop_senior_agesex_womanmean / edu_senior_agesex_womanmean
gen conddrop_high_agesex_womanmean = drop_high_agesex_womanmean / edu_high_agesex_womanmean

**********************相对情况****************************

gen rela_edu_junior_agesex = edu_junior_agesex_womanmean / edu_junior_agesex_manmean
gen rela_edu_senior_agesex = edu_senior_agesex_womanmean / edu_senior_agesex_manmean
gen rela_edu_high_agesex = edu_high_agesex_womanmean / edu_high_agesex_manmean

gen conddrop_junior_agesex_manmean = drop_junior_agesex_manmean / edu_junior_agesex_manmean
gen conddrop_senior_agesex_manmean = drop_senior_agesex_manmean / edu_senior_agesex_manmean
gen conddrop_high_agesex_manmean = drop_high_agesex_manmean / edu_high_agesex_manmean

gen rela_drop_junior_agesex = conddrop_junior_agesex_womanmean / conddrop_junior_agesex_manmean
gen rela_drop_senior_agesex = conddrop_senior_agesex_womanmean / conddrop_senior_agesex_manmean
gen rela_drop_high_agesex = conddrop_high_agesex_womanmean / conddrop_high_agesex_manmean

gen dif_edu_junior_agesex = edu_junior_agesex_manmean - edu_junior_agesex_womanmean
gen dif_edu_senior_agesex = edu_senior_agesex_manmean - edu_senior_agesex_womanmean
gen dif_edu_high_agesex = edu_high_agesex_manmean - edu_high_agesex_womanmean
 
eststo clear

eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_edu_junior_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_junior_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_junior_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Edu_Junior.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear

eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_edu_senior_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_senior_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_senior_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Edu_Senior.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 eststo clear

eststo: reghdfe edu_high_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_edu_high_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_high_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_high_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Edu_High.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 
///////////////////////////////baseline, labor///////////////////////////////////////////////////////////////////

gen rela_unemploy_agesex = unemploy_agesex_womanmean / unemploy_agesex_manmean
gen rela_agriculture_agesex = agriculture_agesex_womanmean / agriculture_agesex_manmean
gen rela_industrywork_agesex = industrywork_agesex_womanmean / industrywork_agesex_manmean
gen rela_thirdsector_agesex = thirdsector_agesex_womanmean / thirdsector_agesex_manmean
gen rela_highskill_agesex = highskill_agesex_womanmean / highskill_agesex_manmean

gen dif_unemploy_agesex = unemploy_agesex_manmean - unemploy_agesex_womanmean
gen dif_agriculture_agesex = agriculture_agesex_manmean - agriculture_agesex_womanmean
gen dif_industrywork_agesex = industrywork_agesex_manmean - industrywork_agesex_womanmean
gen dif_thirdsector_agesex = thirdsector_agesex_manmean - thirdsector_agesex_womanmean 
gen dif_highskill_agesex = highskill_agesex_manmean - highskill_agesex_womanmean 

eststo clear 

eststo: reghdfe unemploy_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe unemploy_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe unemploy_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_unemploy_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_unemploy_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_unemploy_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Labor_unem.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear   
 
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_agriculture_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_agriculture_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_agriculture_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Labor_agri.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear  
 
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_industrywork_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_industrywork_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_industrywork_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Labor_indu.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 eststo clear  

eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_thirdsector_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_thirdsector_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_thirdsector_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
esttab using "Labor_thir.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

eststo clear   
 
eststo: reghdfe highskill_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe rela_highskill_agesex contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_highskill_agesex contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_highskill_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
esttab using "Labor_high.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace


 
 
eststo clear   
eststo: reghdfe dif_edu_junior_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe dif_edu_senior_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe dif_edu_high_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe dif_unemploy_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe dif_agriculture_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe dif_industrywork_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe dif_thirdsector_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe dif_highskill_agesex contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
esttab using "EduLabor_dif.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 ////////////////////////////////////////////////婚嫁家庭情况回归////////////////////////////////////
 
eststo clear 

eststo: reghdfe housekeeper_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe housekeeper_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe housekeeper_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe divorce_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe divorce_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe divorce_agesex_womanmean contraction_exponential $cohort if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Family_house_divorce_abso.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear 

eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe kids_sexration_agesex_womanmean contraction_exponential if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe kids_sexration_agesex_womanmean contraction_exponential $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe kids_sexration_agesex_womanmean contraction_exponential $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Family_child_abso.tex", star(* 0.1 ** 0.05 *** 0.01) b(4) se(4) ar2(4) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
////////////////////////////////////////////////////////////////异质性，更好的工业///////////////////////////////////////////////////////////////////
eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_agri.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
eststo clear 
eststo: reghdfe rela_edu_junior_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_senior_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_edu_high_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_agriculture_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_industrywork_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_thirdsector_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe rela_highskill_agesex contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.agriculture_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_rela_agri.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
egen agriculture50 = pctile(agriculture_mean), p(50)

gen agriculture_high = 0
replace agriculture_high = 1 if agriculture_mean > agriculture50
gen agriculture_low = 0
replace agriculture_low = 1 if agriculture_mean < agriculture50

eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean c.contraction_exponential#c.agriculture_low  c.contraction_exponential#c.agriculture_high $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_agri_class.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 
eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.industrywork_mean $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_industrywork.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 
egen industrywork50 = pctile(industrywork_mean), p(50)

gen industrywork_high = 0
replace industrywork_high = 1 if industrywork_mean > industrywork50
gen industrywork_low = 0
replace industrywork_low = 1 if industrywork_mean < industrywork50

eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe edu_senior_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe edu_high_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe agriculture_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe industrywork_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe thirdsector_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe highskill_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe total_ceb_agesex_womanmean c.contraction_exponential#c.industrywork_high c.contraction_exponential#c.industrywork_low $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_industrywork_class.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 
 
 
gen high_clan = 0
replace high_clan = 1 if clan_density > 0.0579
 
eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.clan_density $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 

esttab using "Hetero_clan.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.high_clan $cohort $region if age > 25 & age < 35, a(prefect age) cluster(province_code) 

esttab using "Hetero_highclan.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.marketization $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code) 
esttab using "Hetero_market.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 gen post_sex_ratio1 = post_sex_ratio - 1
 
  eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.post_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_postsex.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace
 
 gen pre_sex_ratio1 = pre_sex_ratio - 1
 
   eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential c.contraction_exponential#c.pre_sex_ratio1 $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Hetero_presex.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

/////////////////////////////////////////////稳健性，linear/////////////////////////////////
 
eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe edu_senior_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe edu_high_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe agriculture_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe industrywork_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe thirdsector_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe highskill_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

eststo: reghdfe total_ceb_agesex_womanmean contraction_linear $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)


esttab using "Robust_linear.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace  
 
///////////////////////////////////////////稳健性，模糊进入劳动力市场的时间////////////////////////////////////////////////


///直辖市，少民省 11 12 45 64 65 15 63 31 
///经济特区  4403 4405 3502
/// if !(province_code in (11, 12, 45, 64, 65, 15, 63, 31)) & !(prefecture_code in (4403, 4405, 3502))

 eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502) , a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential $cohort $region if (age > 25 & age < 35) & !(province_code == 11 | province_code == 12 | province_code == 45 | province_code == 64 | province_code == 65 | province_code == 15 | province_code == 63 | province_code == 31) & !(prefecture_code == 4403 | prefecture_code == 4405 | prefecture_code == 3502), a(prefect c.age#province_code age) cluster(province_code)

esttab using "Robust_exclude.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace  
 
/////////////////////////////////////////稳健性，排除直辖市和自治州///////////////////////////////////////////////
xtset prefect age

gen contraction_vague = 0.147395172 * l.contraction_exponential + 0.09656925 * l.l.contraction_exponential + 0.08386277 * l.l.l.contraction_exponential + 0.149936468 * contraction_exponential + 0.076238882 * f.f.f.contraction_exponential + 0.088945362 * f.f.contraction_exponential + 0.120711563 * f.contraction_exponential



 eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_vague $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Robust_vague.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace  
 
///////////////////////////////////////////////////稳健性，平行趋势检验/////////////////////////////////////////////////

 save saveload1.dta, replace

//////////////////////////////////////////////////////稳健性，19581962//////////////////////////////////////////
drop contraction_exponential contraction_linear
merge m:m age prefecture_code using pop_panel_with_estimation_19581962.dta
drop _merge
gen contraction_linear = (estimated_pop_linear - pop_pro) / estimated_pop_linear
gen contraction_exponential = (estimated_pop_exponential - pop_pro) / estimated_pop_exponential

replace contraction_linear = 0 if contraction_linear == .
replace contraction_exponential = 0 if contraction_exponential == .

drop estimated_pop_linear estimated_pop_exponential
 
eststo clear 
eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38,a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38,a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential $cohort $region if age > 22 & age < 38, a(prefect c.age#province_code age) cluster(province_code)

esttab using "Robust_5years.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace 


 //////////////////////////////平行趋势///////////////////////////
 
 clear
 use saveload1.dta, replace
 
bysort prefect: egen sum_severity_exponential = sum(contraction_exponential)
bysort prefect: egen sum_severity_linear = sum(contraction_linear)
foreach num of numlist 1950(1)1967{
gen agedummy_`num'= age == 1990 - `num' 
gen sum_severity_exponential_`num' = sum_severity_exponential * agedummy_`num'
gen sum_severity_linear_`num' = sum_severity_linear * agedummy_`num'
}

global cohort edu_junior_agesex_manmean edu_senior_agesex_manmean edu_high_agesex_manmean agriculture_agesex_manmean industrywork_agesex_manmean highskill_agesex_manmean
global region edu_junior_meant edu_senior_meant edu_high_meant agriculture_meant industrywork_meant highskill_meant pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert

eststo clear 
reghdfe sex_ratio_age sum_severity_exponential_* $cohort $region if age > 22 & age < 41, a(prefect c.age#province_code age) cluster(province_code)
eststo f1
coefplot f1,omitted keep(sum_severity_exponential_*) level(95) ///
vertical lcolor(gs6) mlcolor(gs6) mfcolor(gs6)  msize (*1.6) msymbol(Oh) c(l) ///
legend(off) scheme(s1mono) graphregion(margin(5 9 5 5)) ///
xlabel( 1 "1950" 3 "1952" 5 "1954" 7 "1956" 9 "1958" 11 "1960" 13 "1962" 15 "1964" 17 "1966") ///
xtitle("Birth Year") ytitle("Estimated Coefficient on SRB") ///
yline(0, lcolor(red) lwidth(*1.1)) ///
xline(9.5, lpattern(-)) ///
xline(12.5, lpattern(-)) ///
text( 0.16 8.3  ///
" Famine Period" ///
, place(se) box just(left) margin(l+4 t+1 b+1) width(34))

drop sum_severity_exponential_*
rename sum_severity_linear_* sum_severity_exponential_*

reghdfe sex_ratio_age sum_severity_exponential_* $cohort $region if age > 22 & age < 41, a(prefect c.age#province_code age) cluster(province_code)
eststo f2
coefplot f1 f2,omitted keep(sum_severity_exponential_*) level(95) ///
vertical lcolor(gs6) mlcolor(gs6) mfcolor(gs6)  msize (*1.6) msymbol(Oh) ///
legend(off) scheme(s1mono) graphregion(margin(5 9 5 5)) ///
xlabel( 1 "1950" 3 "1952" 5 "1954" 7 "1956" 9 "1958" 11 "1960" 13 "1962" 15 "1964" 17 "1966") ///
xtitle("Birth Year") ytitle("Estimated Coefficient on SRB") ///
yline(0, lcolor(red) lwidth(*1.1)) ///
xline(9.5, lpattern(-)) ///
xline(12.5, lpattern(-)) ///
text( 0.16 8.3  ///
" Famine Period" ///
, place(se) box just(left) margin(l+4 t+1 b+1) width(34))

///////////////////////////////////////////////////////////////////////////////
clear
use saveload1.dta, replace
bysort prefect: egen sum_severity_exponential = sum(contraction_exponential)
bysort prefect: egen sum_severity_linear = sum(contraction_linear)
foreach num of numlist 1950(1)1967{
gen agedummy_`num'= age == 1990 - `num' 
gen sum_severity_exponential_`num' = sum_severity_exponential * agedummy_`num'
gen sum_severity_linear_`num' = sum_severity_linear * agedummy_`num'
}

global cohort edu_junior_agesex_manmean edu_senior_agesex_manmean edu_high_agesex_manmean agriculture_agesex_manmean industrywork_agesex_manmean highskill_agesex_manmean
global region edu_junior_meant edu_senior_meant edu_high_meant agriculture_meant industrywork_meant highskill_meant pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert

eststo clear 
reghdfe rela_edu_junior_agesex sum_severity_exponential_* $cohort $region if age > 22 & age < 41, a(prefect c.age#province_code age) cluster(province_code)
eststo f1
coefplot f1,omitted keep(sum_severity_exponential_*) level(95) ///
vertical lcolor(gs6) mlcolor(gs6) mfcolor(gs6)  msize (*1.6) msymbol(Oh) c(l) ///
legend(off) scheme(s1mono) graphregion(margin(5 9 5 5)) ///
xlabel( 1 "1950" 3 "1952" 5 "1954" 7 "1956" 9 "1958" 11 "1960" 13 "1962" 15 "1964" 17 "1966") ///
xtitle("Birth Year") ytitle("Estimated Coefficient on SRB") ///
yline(0, lcolor(red) lwidth(*1.1)) ///
xline(9.5, lpattern(-)) ///
xline(12.5, lpattern(-)) ///
text( 0.16 8.3  ///
" Famine Period" ///
, place(se) box just(left) margin(l+4 t+1 b+1) width(34))

drop sum_severity_exponential_*
rename sum_severity_linear_* sum_severity_exponential_*

reghdfe rela_edu_junior_agesex sum_severity_exponential_* $cohort $region if age > 22 & age < 41, a(prefect c.age#province_code age) cluster(province_code)
eststo f2
coefplot f1 f2,omitted keep(sum_severity_exponential_*) level(90) ///
vertical lcolor(gs6) mlcolor(gs6) mfcolor(gs6)  msize (*1.6) msymbol(Oh) ///
legend(off) scheme(s1mono) graphregion(margin(5 9 5 5)) ///
xlabel( 1 "1950" 3 "1952" 5 "1954" 7 "1956" 9 "1958" 11 "1960" 13 "1962" 15 "1964" 17 "1966") ///
xtitle("Birth Year") ytitle("Estimated Coefficient on SRB") ///
yline(0, lcolor(red) lwidth(*1.1)) ///
xline(9.5, lpattern(-)) ///
xline(12.5, lpattern(-)) ///
text( 0.16 8.3  ///
" Famine Period" ///
, place(se) box just(left) margin(l+4 t+1 b+1) width(34))











clear
use saveload1.dta, replace
bysort prefect: egen sum_severity_exponential = sum(contraction_exponential)
bysort prefect: egen sum_severity_linear = sum(contraction_linear)
foreach num of numlist 1950(1)1967{
gen agedummy_`num'= age == 1990 - `num' 
gen sum_severity_exponential_`num' = sum_severity_exponential * agedummy_`num'
gen sum_severity_linear_`num' = sum_severity_linear * agedummy_`num'
}

global cohort edu_junior_agesex_manmean edu_senior_agesex_manmean edu_high_agesex_manmean agriculture_agesex_manmean industrywork_agesex_manmean highskill_agesex_manmean
global region edu_junior_meant edu_senior_meant edu_high_meant agriculture_meant industrywork_meant highskill_meant pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert


reghdfe sex_ratio_age sum_severity_exponential_* $cohort $region if age > 22 & age < 41, a(prefect age) 
eststo f1

 eststo clear 
 eststo: reghdfe edu_junior_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_junior_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_senior_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe edu_high_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35,a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe total_ceb_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
esttab using "Sexrationeffect_1.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

  eststo clear 
  eststo: reghdfe agriculture_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35,a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe agriculture_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe industrywork_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe thirdsector_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)
eststo: reghdfe highskill_agesex_womanmean sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35,a(prefect c.age#province_code age) cluster(province_code)

esttab using "Sexrationeffect_2.tex", star(* 0.1 ** 0.05 *** 0.01) b(3) se(3) ar2(3) title( \label{baseline}) ///
 mtitles("" "" "" "" "" "" "" "") replace

 
 graph box pop_pro if age > 23 & age < 37 , over(age) title("Distribution of pop_pro by Age") ytitle("pop_pro value") scheme(s1color)
 
 gen birth_year = 1990 - age
 
bysort birth_year: egen median_pop = median(pop_pro)

vioplot pop_pro if age > 23 & age < 37, over(birth_year) ///  
  xtitle("Birth Year", size(medium))  c(l) ///                  
  ytitle("Population Proportion", size(medium)) ///              
  lcolor(gs4) plotregion(color(white))    ///
  graphregion(color(white)) ///                         
  ylabel(, nogrid) ///        
  xline(5.5 8.5, lcolor(red) lpattern(dash)) ///        
  text(0.04 4.7 "Famine Period", placement(se) box just(left) margin(l+9 t+1 b+1) width(34)) ///
  legend(off)                                            


///////////////////////////////////工具变量/////////////////////////////////////////////


gen contraction_exponential_diff = contraction_exponential_woman - contraction_exponential_man

global cohort edu_junior_agesex_manmean edu_senior_agesex_manmean edu_high_agesex_manmean agriculture_agesex_manmean industrywork_agesex_manmean highskill_agesex_manmean
global region edu_junior_meant edu_senior_meant edu_high_meant agriculture_meant industrywork_meant highskill_meant pre_sex_ratiot tempt pop_densitt nightlightt wheat_suitt rice_suitat terraint clan_densityt rivert

reghdfe contraction_exponential_diff contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

reghdfe sex_ratio_age contraction_exponential  $cohort $region if age > 25 & age < 35, a(prefect c.age#province_code age) cluster(province_code)

twoway scatter contraction_exponential_diff contraction_exponential if age > 28 & age < 32

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////平衡性检验///////////////////////////////////////

keep edu_junior_mean edu_senior_mean edu_high_mean agriculture_mean industrywork_mean highskill_mean total_ceb_mean prefect sum_severity_exponential sum_severity_linear pre_sex_ratio temp pop_densit nightlight wheat_suit rice_suita terrain clan_density river province_code
duplicates drop

norm edu_junior_mean edu_senior_mean edu_high_mean agriculture_mean industrywork_mean highskill_mean total_ceb_mean pre_sex_ratio temp pop_densit nightlight wheat_suit rice_suita terrain clan_density river, method(zee)

eststo clear  

rename zee_edu_junior_mean Junior_Education
rename zee_edu_senior_mean Senior_Education
rename zee_edu_high_mean College_Education
rename zee_agriculture_mean Agricultural_Proportion
rename zee_industrywork_mean Manufactural_Proportion
rename zee_highskill_mean Proficient_Proportion
rename zee_total_ceb_mean Fertility
rename zee_pre_sex_ratio Previous_SRB
rename zee_temp Average_Temperature
rename zee_pop_densit Population_Density
rename zee_nightlight Night_Light_Density
rename zee_wheat_suit Soil_Suitablity_for_Wheat
rename zee_rice_suita Soil_Suitablity_for_Rice 
rename zee_terrain Terrain_Roughness 
rename zee_clan_density Clan_Per_Capita
rename zee_river River_Length 
 
reg sum_severity_exponential Junior_Education Senior_Education College_Education Agricultural_Proportion Manufactural_Proportion Proficient_Proportion Night_Light_Density Fertility Previous_SRB Population_Density Clan_Per_Capita Average_Temperature Soil_Suitablity_for_Wheat Soil_Suitablity_for_Rice Terrain_Roughness River_Length, a(province_code)
est store Exponential

reg sum_severity_linear Junior_Education Senior_Education College_Education Agricultural_Proportion Manufactural_Proportion Proficient_Proportion Night_Light_Density Fertility Previous_SRB Population_Density Clan_Per_Capita Average_Temperature Soil_Suitablity_for_Wheat Soil_Suitablity_for_Rice Terrain_Roughness River_Length, a(province_code)
est store Linear



	
coefplot Exponential, bylabel("{bf:Survival Model}") ///
	|| Linear, bylabel("{bf:Linear Model}") ///
	drop(_cons) nolabel levels(95)  ///
    scheme(s1mono) xline(0) ///
	headings(Junior_Education  = "{bf:Educational and Economic}" ///
	Fertility  = "{bf:Social and Demographic}" ///
	Average_Temperature = "{bf:Geographic}" )

	
clear
use saveload1.dta, replace
keep edu_junior_mean edu_senior_mean edu_high_mean agriculture_mean industrywork_mean highskill_mean total_ceb_mean prefect pre_sex_ratio temp pop_densit nightlight wheat_suit rice_suita terrain clan_density river province_code age contraction_exponential contraction_linear
duplicates drop

norm edu_junior_mean edu_senior_mean edu_high_mean agriculture_mean industrywork_mean highskill_mean total_ceb_mean pre_sex_ratio temp pop_densit nightlight wheat_suit rice_suita terrain clan_density river, method(zee)

eststo clear  

rename zee_edu_junior_mean Junior_Education
rename zee_edu_senior_mean Senior_Education
rename zee_edu_high_mean College_Education
rename zee_agriculture_mean Agricultural_Proportion
rename zee_industrywork_mean Manufactural_Proportion
rename zee_highskill_mean Proficient_Proportion
rename zee_total_ceb_mean Fertility
rename zee_pre_sex_ratio Previous_SRB
rename zee_temp Average_Temperature
rename zee_pop_densit Population_Density
rename zee_nightlight Night_Light_Density
rename zee_wheat_suit Soil_Suitablity_for_Wheat
rename zee_rice_suita Soil_Suitablity_for_Rice 
rename zee_terrain Terrain_Roughness 
rename zee_clan_density Clan_Per_Capita
rename zee_river River_Length 
	
reghdfe contraction_exponential Agricultural_Proportion if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store Agri

reghdfe contraction_exponential Manufactural_Proportion if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store Manu

reghdfe contraction_exponential Night_Light_Density if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store NightLight

reghdfe contraction_exponential Population_Density if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store PopDensity

reghdfe contraction_exponential Previous_SRB if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store SRB

reghdfe contraction_exponential Clan_Per_Capita if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store Clan

reghdfe contraction_exponential Soil_Suitablity_for_Wheat if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store Wheat

reghdfe contraction_exponential Soil_Suitablity_for_Rice if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store Rice

reghdfe contraction_exponential Terrain_Roughness if age > 28 & age < 32, a(i.province_code#i.age) cluster(province_code)
est store Terrain

coefplot ///
    Agri Manu NightLight ///
    PopDensity SRB Clan ///
    Wheat Rice Terrain, ///
    drop(_cons) levels(95) ///
    scheme(s1color) ///
    xline(0) ///
    legend(off) ///
    msymbol(O) mcolor(black) ciopts(color(gs8)) ///
	headings(Agricultural_Proportion  = "{bf:Economic}" ///
	Population_Density  = "{bf:Social and Demographic}" ///
	Soil_Suitablity_for_Wheat = "{bf:Geographic}" )



	



				
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
