*cap ssc inst sxpose
global dirpath = "C:\Users\Vinicius\Desktop\RA_Chico\data"
*global dirpath = "C:\Dropbox\_My articles\cheaptalk\data"


cap log close
log using "C:\Users\Vinicius\Desktop\RA_Chico", replace
clear
foreach k in 7 8 9 10 11 12 {
  append using "$dirpath\input\session`k'\raw_session`k'.dta"
}
drop participate nprofit*

rename message msg_out
rename aux_mess msg_in
rename contribution contr
rename publicgood project
rename sumc gr_contr

*gen avg_time = (timeokcommuni + timeokcontrib)/2
gen byte year_course = 1 if AnoC == "1o ano"
replace year_course = 2 if AnoC == "2o ano"
replace year_course = 3 if AnoC == "3o ano"
replace year_course = 4 if AnoC == "4o ano"
replace year_course = 5 if year_course == .
gen byte gender_female = gender != "Masculino"

rename curso course
replace course = "Buss" if substr(course,1,3) == "Adm"
replace course = "Econ" if substr(course,1,3) == "Eco"
replace course = "Law" if substr(course,1,3) == "Dir"
replace course = "Socio" if substr(course,1,2) == "Ci"
replace course = "Hist" if substr(course,1,3) == "His"
replace course = "Math" if substr(course,1,3) == "Mat"

keep session period group subject value msg_out msg_in contr gr_contr project profit gender_female course year_course


* append with 2008 data
preserve
use "$dirpath/input/cheap_talk_data2008.dta", clear
gen profit = earning 
gen     course = "Buss" if business == 1
replace course = "Econ" if economics == 1
replace course = "Law" if law == 1
replace course = "Socio" if socio == 1
replace course = "Hist" if history == 1
gen byte year_course = 1 if first_year == 1
replace  year_course = 2 if second_year == 1
replace  year_course = 3 if third_year == 1
replace  year_course = 4 if fourth_year == 1


keep session period group subject value msg_out msg_in contr gr_contr project profit gender_female course year_course
saveold "$dirpath/temp/tmp_cheap_talk_data2008_tomerge.dta", replace
restore

append using "$dirpath/temp/tmp_cheap_talk_data2008_tomerge.dta"

sort session subject 
egen idsubject = group(session subject)
sort session period group subject 
egen idgroup = group(session period group)

order session period idgr idsub 

egen gr_value = sum(value), by(idgroup)
gen gr_excess_contr = gr_contr - 100 if project == 1
replace gr_excess_contr = gr_contr if project == 0

encode course, gen(student_course)
drop course

gen byte treatment = session
recode treatment  (4 5 11 12 = 0) (1 6 7 10 = 1) (2 3 8 9 = 2)
label variable treatment "0 no comm, 1 binary, 2 fine comm"

qui replace msg_in  = . if treat == 0 
qui replace msg_out = . if treat == 0 

*generating variable for payoff
bysort session period group: gen payoff = sum(profit)
label variable payoff "Group Payoff"
replace payoff = 999 if payoff == profit & group == group[_n+1]
replace payoff = payoff[_n+1] if payoff == 999

compress
saveold "$dirpath/output/cheap_talk_workfile.dta", replace

log close
*END
