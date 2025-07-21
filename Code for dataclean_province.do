
////////////////生成核心的output variables/////////////////////////////

clear 
use 1990cencus.dta
gen num = 1
gen age = 90 - age_y
 
//////////////////受教育情况

gen edu_junior = 0
replace edu_junior = 1 if educ > 2 & edstatus == 2

gen edu_senior = 0
replace edu_senior = 1 if educ > 3 & edstatus == 2

gen edu_high = 0
replace edu_high = 1 if educ > 5 & edstatus == 2

////////////////////////面板数据生成

bysort province: egen edu_junior_mean = mean(edu_junior)
bysort province: egen edu_senior_mean = mean(edu_senior)
bysort province: egen edu_high_mean = mean(edu_high)

bysort province age: egen edu_junior_age_mean = mean(edu_junior)
bysort province age: egen edu_senior_age_mean = mean(edu_senior)
bysort province age: egen edu_high_age_mean = mean(edu_high)

//////////////////////就业程度数据//////////////////////////////////
gen agriculture = 0 
replace agriculture = 1 if industry < 80 & industry != 60

gen industrywork = 0 
replace industrywork = 1 if industry < 663 & industry > 140

gen highskill = 0
replace highskill = 1 if occu == 71 | occu == 20 | occu == 35 | occu == 32 | occu == 864 | occu == 41 | occu == 34 | occu == 52 | occu == 91 | occu == 36 | occu == 17 | occu == 19 | occu == 44 | occu == 43 | occu == 738 | occu == 931 | occu == 62 | occu == 63 | occu == 966 | occu == 39 | occu == 964 | occu == 963 | occu == 145 | occu == 51


bysort province: egen agriculture_mean = mean(agriculture)
bysort province: egen industrywork_mean = mean(industrywork)
bysort province: egen highskill_mean = mean(highskill)

bysort province age: egen agriculture_age_mean = mean(agriculture)
bysort province age: egen industrywork_age_mean = mean(industrywork)
bysort province age: egen highskill_age_mean = mean(highskill)

keep province age edu_junior_mean edu_senior_mean edu_high_mean edu_junior_age_mean edu_senior_age_mean edu_high_age_mean agriculture_mean industrywork_mean highskill_mean agriculture_age_mean industrywork_age_mean highskill_age_mean 
duplicates drop

save province_age.dta, replace

