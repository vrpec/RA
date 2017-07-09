*cap ssc inst sxpose
*global dirpath = "C:\Users\francisco.costa\Dropbox\_My articles\cheaptalk\data"
global dirpath = "C:\Dropbox\_My articles\cheaptalk\data"
cd "C:\Users\Vinicius\Desktop\RA_Chico"

* OLD CODES:  /old/cheap_talk_do2011.do
* EXAMPLE OF WRITING FUNCTIONS (table) and table in latex:  /old/_example_table_function.do
* For layout and relevant info in notes, check the recent AEJs and GEB papers in the /literature folder

cap log close
log using "data_analysis.log", replace
use "cheap_talk_workfile.dta", clear
set more off 
ssc install clustse    
ssc install clusterbs
ssc install unique
* *****************
* Descriptive stats

* Time series by treatment: project, group contr: check old code
* Figure 3
foreach var of varlist gr_contr project gr_excess_contr {
bysort period treatment : egen mean_`var' = mean(`var')
 
	foreach num of numlist 0 1 2 { 
	gen mean_`var'_`num' = mean_`var' if treatment == `num'
	}
label variable mean_`var'_0 "No Communication"
label variable mean_`var'_1 "Binary Communication"
label variable mean_`var'_2 "Refined Communication"

} 

graph twoway line mean_gr_contr_* period if subject == 1, lp(solid dash longdash) lc(eltblue edkblue emidblue) scheme(s1color) title("Average group contribution along periods") ytitle("Average Group Contribution") xtitle("Period") 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotLineContributions_byPeriod.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotLineContributions_byPeriod.pdf", replace

graph twoway line mean_project_* period if subject == 1, lp(solid dash longdash) lc(eltblue edkblue emidblue) scheme(s1color) title("Percentage of projects implemented along periods") ytitle("% of Projects Implemented") xtitle("Period") 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotLineProjects_byPeriod.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotLineProjects_byPeriod.pdf", replace

graph twoway line mean_gr_excess_contr_* period if subject == 1, lp(solid dash longdash) lc(eltblue edkblue emidblue) scheme(s1color) title("Average excess contribution along periods") ytitle("Average Excess Contribution") xtitle("Period") 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotLineExcess_byPeriod.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotLineExcess_byPeriod.pdf", replace

* Treatment tables with avg and sd truncating periods: table (project, excess contribution, payoff, % zero contr)
* Table 1


sort session period group 

gen group_aux  = group[_n]!=group[_n-1]
qui gen psample = 1
gen auxp = period 
replace auxp = period - 15 if auxp > 15
egen idxt = group(session group auxp)
tsset idxt period
*tab idxt period
ttest project == 0 if bin == 0 & ref == 0

foreach var of varlist project gr_excess_contr payoff value {

matrix input TableMean_`var' = (999,999,999\999,999,999\999,999,999\999,999,999\999,999,999\999,999,999\999,999,999\999,999,999\999,999,999\999,999,999\999,999,999)
matrix colnames TableMean_`var' = "Full sample" "[6-25]" "[11-25]" 
matrix rownames TableMean_`var' = "Mean NC" "(se)" "Mean Bin" "(se)" "Mean Ref" "(se)" "N" "pval NC=Bin" "pval NC=Ref" "pval Bin=Ref" "N"

} 

foreach var of varlist project gr_excess_contr payoff {
local auxcol = 0
foreach i in 0 5 10 {
	qui replace psample = period > `i'
	local auxcol = `auxcol' + 1
	
	mean `var' if psample & treatment ==0 & group_aux==1	, vce(cluster session)
	mat TableMean_`var'[1  ,`auxcol'] = _b[`var']	
	mat TableMean_`var'[1+1,`auxcol'] = _se[`var']
	mean `var' if psample & treatment ==1 & group_aux==1				, vce(cluster session)
	mat TableMean_`var'[3  ,`auxcol'] = _b[`var']	
	mat TableMean_`var'[3+1,`auxcol'] = _se[`var']
	mean `var' if psample & treatment ==2 & group_aux==1				, vce(cluster session)
	mat TableMean_`var'[5  ,`auxcol'] = _b[`var']	
	mat TableMean_`var'[5+1,`auxcol'] = _se[`var']
	mat TableMean_`var'[7 ,`auxcol'] = e(N)
	
}

}







**figure 4 as in the paper and with 20 bins and by treatment
* Fgure 4 but with density by treatment
* Figure 4 but with 20 bins
* Contribution densities (share of zero contr) and kdensity of contr>0
gen psample = period > 5
gen treatment_label = treatment
label define treatmentLabel 0 "No Communication" 1 "Binary Communication" 2 "Refined Communication"
label values treatment_label treatmentLabel
label variable contr "Contribution"

foreach i in 0 1 2 {
local name : label treatmentLabel `i' 
di "`name'" 
graph twoway kdensity contr if psample & treatment_label == `i', title("`name'") legend(off) xtitle("Contribution") ytitle("Density") lcolor(edkblue) fcolor( emidblue ) scheme(s1color) 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensity_`name'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensity_`name'.pdf", replace

graph twoway kdensity contr if psample & treatment_label == `i', kernel(gaus) title("`name'") legend(off) xtitle("Contribution") ytitle("Density") lcolor(edkblue) fcolor( emidblue ) scheme(s1color) 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensity_Normal_`name'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensity_Normal_`name'.pdf", replace

graph twoway kdensity contr if contr >0 & psample & treatment_label == `i', title("`name'") legend(off) xtitle("Contribution") ytitle("Density") lcolor(edkblue) fcolor( emidblue ) scheme(s1color) 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensityGreaterZero_`name'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensityGreaterZero_`name'.pdf", replace

graph twoway kdensity contr if contr > 0 & psample & treatment_label == `i', kernel(gaus) title("`name'") legend(off) xtitle("Contribution") ytitle("Density") lcolor(edkblue) fcolor( emidblue ) scheme(s1color) 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensityGreaterZero_Normal_`name'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotKdensityGreaterZero_Normal_`name'.pdf", replace

foreach x in 8  20 {


graph twoway histogram contr if psample & treatment_label == `i', title("`name'") legend(off) lcolor(edkblue) fcolor( emidblue ) scheme(s1color)  bin(`x') percent 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_`name'_`x'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_`name'_`x'.pdf", replace


}
}

* Figure A1
cd "C:\Users\Vinicius\Desktop\RA_Chico"

kdensity value if (period > 5) & msg_out == 0 & treatment == 1 , title("Message sent : No") addplot((kdensity value if period > 5 & msg_out == 0 & treatment ==2)) xtitle("Value") ytitle("Density") lcolor(edkblue) fcolor( emidblue ) scheme(s1color) legend(on order(1 "BC" 2 "RC") rows(1))
graph save "FigureA1_Kdensity_Yes.gph", replace
graph export "FigureA1_Kdensity_Yes.pdf", replace
kdensity value if (period > 5) & msg_out != 0 & treatment == 1 , title("Message sent : Yes") addplot((kdensity value if period > 5 & msg_out != 0 & treatment ==2)) xtitle("Value") ytitle("Density") lcolor(edkblue) fcolor( emidblue ) scheme(s1color) legend(on order(1 "BC" 2 "RC") rows(1))
graph save "FigureA1_Kdensity_No.gph", replace
graph export "FigureA1_Kdensity_No.pdf", replace

graph combine "FigureA1_Kdensity_Yes.gph" "FigureA1_Kdensity_No.gph" , ycommon scheme(s1color)
graph save "FigureA1.gph" , replace
graph export "FigureA1.pdf", replace
graph export "FigureA1.png", replace

* Figure 6 (with differrent comm histories) but with 20 bins

gen psample = period > 5
gen msg_out_yes = (msg_out == 2 | msg_out==3)
gen msg_in_yes = (msg_in ==2 | msg_out ==3)

foreach x in 8 20 {


histogram contr if psample & treatment ==1 & msg_out ==1 & msg_in ==1, title("Binary Communication") subtitle("After history (Yes,Yes)") xtitle(Contribution) legend(off) lcolor(edkblue) fcolor( emidblue ) scheme(s1color)  bin(`x') percent 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_BinaryCommunication_YY_`x'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_BinaryCommunication_YY_`x'.pdf", replace

histogram contr if psample & treatment ==1 & (msg_out !=1 | msg_in !=1) , title("Binary Communication") subtitle("After history different than (Yes,Yes)") xtitle(Contribution) legend(off) lcolor(edkblue) fcolor( emidblue ) scheme(s1color)  bin(`x') percent 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_BinaryCommunication_!YY_`x'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_BinaryCommunication_!YY_`x'.pdf", replace

graph combine "PlotHist_BinaryCommunication_YY_`x'.gph" "PlotHist_BinaryCommunication_!YY_`x'.gph", ycommon scheme(s1color)
graph save "PlotHist_BinaryCommunication_`x'.gph", replace
graph export "PlotHist_BinaryCommunication_`x'.pdf", replace
graph export "PlotHist_BinaryCommunication_`x'.png", replace


histogram contr if psample & treatment ==2 & msg_out_yes ==1 & msg_in_yes ==1, title("Refined Communication") subtitle("After history (Yes,Yes)") xtitle(Contribution) legend(off) lcolor(edkblue) fcolor( emidblue ) scheme(s1color)  bin(`x') percent 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_RefinedCommunication_YY_`x'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_RefinedCommunication_YY_`x'.pdf", replace

histogram contr if psample & treatment ==2 & (msg_out_yes !=1 | msg_in_yes !=1) , title("Refined Communication") subtitle("After history different than (Yes,Yes)") xtitle(Contribution) legend(off) lcolor(edkblue) fcolor( emidblue ) scheme(s1color)  bin(`x') percent 
graph save "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_RefinedCommunication_!YY_`x'.gph", replace
graph export "C:\Users\Vinicius\Desktop\RA_Chico\PlotHist_RefinedCommunication_!YY_`x'.pdf", replace

graph combine "PlotHist_RefinedCommunication_YY_`x'.gph" "PlotHist_RefinedCommunication_!YY_`x'.gph", ycommon scheme(s1color)
graph save "PlotHist_RefinedCommunication_`x'.gph", replace
graph export "PlotHist_RefinedCommunication_`x'.pdf", replace
graph export "PlotHist_RefinedCommunication_`x'.png", replace

}


gen comm_histories =0 
replace comm_histories = 1 if treatment ==2 & ((msg_out == 0 & msg_in ==1 | msg_out == 1 & msg_in ==0))
replace comm_histories = 2 if treatment ==2 & ((msg_out == 0 & msg_in ==2 | msg_out == 2 & msg_in ==0))
replace comm_histories = 3 if treatment ==2 & ((msg_out == 0 & msg_in ==3 | msg_out == 3 & msg_in ==0))
replace comm_histories = 4 if treatment ==2 & ((msg_out == 1 & msg_in ==1 | msg_out == 1 & msg_in ==1))
replace comm_histories = 5 if treatment ==2 & ((msg_out == 1 & msg_in ==2 | msg_out == 2 & msg_in ==1))
replace comm_histories = 6 if treatment ==2 & ((msg_out == 1 & msg_in ==3 | msg_out == 3 & msg_in ==1))
replace comm_histories = 7 if treatment ==2 & ((msg_out == 2 & msg_in ==2 | msg_out == 2 & msg_in ==2))
replace comm_histories = 8 if treatment ==2 & ((msg_out == 2 & msg_in ==3 | msg_out == 3 & msg_in ==2))
replace comm_histories = 9 if treatment ==2 & ((msg_out == 3 & msg_in ==3 | msg_out == 3 & msg_in ==3))

label define commHistories 0 "After history ( [0,25), [0,25) ) " 1 "After history ( [0,25), [25, 50) )" 2 "After history ( [0,25), [50,75) ) " 3 "After history ( [0,25) , [75,100] )" 4 "After history ( [25,50), [25,50) )" 5 "After history ( [25,50), [50,75) )" 6 "After history ( [25,50), [75,100] )" 7 "After history ( [50,75) , [50,75) )" 8 "After history ( [50,75) , [75,100] )" 9 "After history ( [75,100] , [75,100] )"

foreach i of numlist 0/9 {

local name : label commHistories `i'
histogram contr if psample & comm_histories == `i' , title("Refined Communication") subtitle("`name'") xtitle(Contribution) legend(off) lcolor(edkblue) fcolor( emidblue ) scheme(s1color)  bin(20) percent

graph save "PlotHist_RefinedCommunication_CommHist_`i'.gph", replace
graph export "PlotHist_RefinedCommunication_CommHist_`i'.pdf", replace

}

graph combine "PlotHist_RefinedCommunication_CommHist_0.gph" "PlotHist_RefinedCommunication_CommHist_1.gph" "PlotHist_RefinedCommunication_CommHist_2.gph" "PlotHist_RefinedCommunication_CommHist_3.gph" "PlotHist_RefinedCommunication_CommHist_4.gph" "PlotHist_RefinedCommunication_CommHist_5.gph" "PlotHist_RefinedCommunication_CommHist_6.gph" "PlotHist_RefinedCommunication_CommHist_7.gph" "PlotHist_RefinedCommunication_CommHist_8.gph" "PlotHist_RefinedCommunication_CommHist_9.gph" , ycommon scheme(s1color)
graph save "PlotHist_RefinedCommunication_CommHist.gph", replace
graph export "PlotHist_RefinedCommunication_CommHist.pdf", replace
graph export "PlotHist_RefinedCommunication_CommHist.png", replace



* Message pattern by value: 
* Figure 5
cd "C:\Users\Vinicius\Desktop\RA_Chico"
gen psample = period > 5
gen str message_out_binary = "Message sent: Yes" if treatment==1 & msg_out ==1 
replace message_out_binary = "Message sent: No" if treatment ==1 & msg_out == 0

gen str message_out_refined = "Message sent: [0,25)" if treatment==2 & msg_out == 0 
replace message_out_refined = "Message sent: [25,50)" if treatment ==2 & msg_out == 1
replace message_out_refined = "Message sent: [50,75)" if treatment==2 & msg_out == 2
replace message_out_refined = "Message sent: [75,100]" if treatment == 2 & msg_out ==3 

histogram value if psample & treatment==1 ,  by(message_out_binary) by(, title("Binary Communication", position(12) ))  xtitle(Value) xlabel(0(25)100)  width(25) percent  lcolor(edkblue) fcolor( emidblue ) scheme(s1color)
graph save "PlotHist_Value_BinaryCommunication.gph", replace
graph export "PlotHist_Value_BinaryCommunication.pdf", replace
graph export "PlotHist_Value_BinaryCommunication.png", replace



histogram value if psample & treatment==2 ,  by(message_out_refined)  by(, title("Refined Communication", position(12) )) xtitle(Value) xlabel(0(25)100)  width(25) percent  lcolor(edkblue) fcolor( emidblue ) scheme(s1color)
graph save "PlotHist_Value_RefinedCommunication.gph", replace
graph export "PlotHist_Value_RefinedCommunication.pdf", replace
graph export "PlotHist_Value_RefinedCommunication.png", replace
* Formal Tests: 

* Mean equality test: graphs (value, project, payoff, excess contribution)
* Figure with avg and 95% confidence interval bars
* Table 2
gen group_aux = group[_n]!=group[_n-1]
gen bin = treatment==1
gen ref = treatment ==2 
gen nc = treatment == 0 

gen psample = period

foreach var of varlist project gr_excess_contr payoff value {
local auxcol = 0 

foreach i in 0 5 10 {

	qui replace psample = period > `i'
	local auxcol = `auxcol' + 1
	
	ranksum `var' if psample & ref==0 & group_aux==1 , by(bin) porder
	mat TableMean_`var'[8  ,`auxcol'] = ttail(r(N_1) + r(N_2) , abs(r(z)))
	
	ranksum `var' if psample & bin==0 & group_aux==1 , by(ref) porder
	mat TableMean_`var'[9  ,`auxcol'] = ttail(r(N_1) + r(N_2) , abs(r(z)))
	
	ranksum `var' if psample & nc==0 & group_aux==1 , by(bin) porder
	mat TableMean_`var'[10 ,`auxcol'] = 2*ttail(r(N_1) + r(N_2) , abs(r(z)))
	mat TableMean_`var'[11,`auxcol'] = r(N_1) + r(N_2)
	
}

}

estout matrix(TableMean_project) using "C:\Users\Vinicius\Desktop\RA_Chico\TableMeanProject.csv", replace delimiter (",")
estout matrix(TableMean_gr_excess_contr) using "C:\Users\Vinicius\Desktop\RA_Chico\TableMeanExcess.csv", replace delimiter(",")
estout matrix(TableMean_payoff) using "C:\Users\Vinicius\Desktop\RA_Chico\TableMeanPayoff.csv", replace delimiter(",")
estout matrix(TableMean_value) using "C:\Users\Vinicius\Desktop\RA_Chico\TableMeanValue.csv", replace delimiter(",")



* TABLE
*Regression Contr sensitive to message in conditional on value and message sent
gen value_low = value < 50
gen value_type = 0
replace value_type = 1 if value < 25
replace value_type = 2 if value >=25 & value < 50
replace value_type = 3 if value >=50 & value < 75
replace value_type = 4 if value >=75
gen msg_in1 = treatment==2 & msg_in >=2

tsset idsubject period

*Binary 
foreach i of numlist 0 1 {
foreach j of numlist 0 1 {

xtreg contr msg_in value if period > 5 & treatment== 1 & msg_out==`i' & value_low == `j', re vce(cluster session)

}
}

*Refined

foreach z of numlist 1 2 3 4 {

xtreg contr msg_in1 value if period > 5 & treatment == 2 & msg_out < 2 & value_type == `z', re vce(cluster session)
xtreg contr msg_in1 value if period > 5 & treatment == 2 & msg_out >= 2 & value_type == `z', re vce(cluster session)
}



drop value_low value_type msg_in1

* Redo Table 3 with single regresison
* create dummies: val>50; msg_out 'Yes'; msg_in 'Yes'
* Run contr on val(dummies) msg_out msg_in
* + interacting: val>50 x msg_out; val>50 x msg_in; msg_out x msg_in; val>50 x msg_out x msg_in

gen val_high = value > 50
gen msg_out_1 = msg_out ==1 & treatment ==1
gen msg_in_1 = msg_in == 1 & treatment== 1
gen msg_out_2 = (msg_out ==2 | msg_out ==3) & treatment ==2
gen msg_in_2 = (msg_in == 2|msg_in==3) & treatment== 2

foreach i of numlist 1 2 {
xtreg contr val_high msg_out_`i' msg_in_`i' if treatment==`i' & period > 5, re vce(cluster session)
xtreg contr val_high##(msg_out_`i' msg_in_`i') if treatment==`i' & period > 5, re vce(cluster session)
xtreg contr val_high##(msg_out_`i'##msg_in_`i') if treatment==`i' & period > 5, re vce(cluster session)
}

drop val_high msg_out_* msg_in_*
* Regression group level (cluster by session-period): contribution and profit - as variaveis no grupo level sao gr_contr  payoff gr_excess_contr , controle pode ser gr_value
gen group_aux = group[_n]!=group[_n-1]

foreach var of varlist gr_contr gr_excess_contr payoff {
cgmreg `var' bin ref if group_aux ==1 , cluster(session period)

}

* Regression individual level (cluster by session-period): contribution and profit
* FIGURE coefplot
* - controling by value
* - controling by 10tokens bins of value (int(value/10)) - se fizer o cluster original nao funciona. 
* - period FE - para fazer isso nao da para cluster(session period).
* - year FE
* - course FE - tira significancia de ref
* - gender FE - nao tenho essa variavel na minha base de dados.
* - wildcluster bootsrap by session
* - all the above

use "C:\Users\Vinicius\Desktop\RA_Chico\data\output\cheap_talk_workfile_withGender.dta" 
cd "C:\Users\Vinicius\Desktop\RA_Chico"
 

gen value_token = int(value/10)
replace value_token = 9 if value_token ==10
label var bin "Binary Communication"
label var ref "Refined Communication"
label var value "Value"



foreach var of varlist contr profit {

cgmreg `var' bin ref value , cluster(session period)
outreg2 using "Reg_indiv_level_`var'_cluster.tex" , keep(bin ref value) replace ctitle(" ") nocons label addtext(Students year FE , No , Students course FE , No , Gender FE, No)
estimates store NoFE

xi: cgmreg `var' bin ref value i.year_course, cluster(session period)
outreg2 using "Reg_indiv_level_`var'_cluster.tex" , keep(bin ref value) append ctitle(" ") nocons label addtext(Students year FE , Yes , Students course FE , No, Gender FE, No) 
estimates store YearFE

xi: cgmreg `var' bin ref value i.student_course, cluster(session period)
outreg2 using "Reg_indiv_level_`var'_cluster.tex" , keep(bin ref value) append ctitle(" ") nocons  label addtext(Students year FE , No , Students course FE , Yes, Gender FE, No) 
estimates store CourseFE

xi: cgmreg `var' bin ref value i.gender_female , cluster(session period)
outreg2 using "Reg_indiv_level_`var'_cluster.tex", keep(bin ref value)   append ctitle(" ") nocons  label addtext(Students year FE , No , Students course FE , No, Gender FE, Yes) 
estimates store GenderFE

xi: cgmreg `var' bin ref value i.year_course i.student_course i.gender_female , cluster(session period)
outreg2 using "Reg_indiv_level_`var'_cluster.tex" , keep(bin ref value) append ctitle(" ") nocons label addtext(Students year FE , Yes , Students course FE , Yes, Gender FE, Yes) 
estimates store FE



xi: cgmreg `var' bin ref value i.period, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE.tex" , keep(bin ref value) replace nocons label addtext(Students year FE , No , Students course FE , No, Gender FE, No) 
estimates store No_FE
 
 
xi: cgmreg `var' bin ref value i.year_course i.period , cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE.tex" , keep(bin ref value) append nocons label addtext(Students year FE , Yes , Students course FE , No, Gender FE, No) 
estimates store Year_FE

xi: cgmreg `var' bin ref value i.student_course i.period, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE.tex" , keep(bin ref value) append nocons  label addtext(Students year FE , No , Students course FE , Yes, Gender FE, No)
estimates store Course_FE


xi: cgmreg `var' bin ref value i.gender_female i.period, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE.tex" , keep(bin ref value) append nocons  label addtext(Students year FE , No , Students course FE , No, Gender FE, Yes)
estimates store Gender_FE

xi: cgmreg `var' bin ref value i.year_course i.student_course i.gender_female i.period, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE.tex" , keep(bin ref value) append nocons label addtext(Students year FE , Yes , Students course FE , Yes, Gender FE, Yes) 
estimates store FE_


xi: cgmreg `var' bin ref  i.value_token i.period, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE_token.tex" , keep(bin ref _Ivalue_tok_*) append nocons label addtext(Students year FE , No , Students course FE , No)

xi: cgmreg `var' bin ref  i.value_token i.period i.year_course, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE_token.tex" , keep(bin ref value _Ivalue_tok_*) append nocons label addtext(Students year FE , Yes , Students course FE , No)

xi: cgmreg `var' bin ref  i.value_token i.period i.student_course, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE_token.tex" , keep(bin ref value _Ivalue_tok_*) append nocons label addtext(Students year FE , No , Students course FE , Yes)

xi: cgmreg `var' bin ref i.value_token i.period i.gender_female, cluster(session)

xi: cgmreg `var' bin ref  i.value_token i.period i.year_course i.student_course i.gender_female, cluster(session)
outreg2 using "Reg_indiv_level_`var'_FE_token.tex" , keep(bin ref value _Ivalue_tok_*) append nocons label addtext(Students year FE , Yes , Students course FE , Yes)
}


coefplot NoFE || YearFE || CourseFE || GenderFE || FE , keep(bin ref) yline(0) vertical bycoef  

coefplot No_FE || Year_FE || Course_FE || Gender_FE || FE_ , keep(bin ref) yline(0) vertical bycoef 
* Table A1
* - wildcluster bootsrap by session
preserve
sort session period group 
keep if group[_n]!=group[_n-1]
gen bin = treatment ==1
gen ref = treatment ==2
qui gen psample = 1
gen auxp = period 
replace auxp = period - 15 if auxp > 15
egen idxt = group(session group auxp)
tsset idxt period



foreach var of varlist gr_excess_contr payoff {
foreach i in 0 5 10 {
qui replace psample = period > `i'



xtlogit project bin ref if psample , re vce(cluster session)
xtlogit project bin ref if psample , re vce(boot, reps(400) seed(10101)) cluster(session)
testparm bin ref , equal


xtreg `var' bin ref if psample, re vce(cluster session)
xtreg `var' bin ref if psample, re vce(boot, reps(400) seed(10101)) cluster(session)

}
}



**Wild bootstrap - pkg for that is given by clustse (https://ideas.repec.org/c/boc/bocode/s457989.html)

*ssc install clustse    
*ssc install clusterbs
* ver http://jee3.web.rice.edu/cluster-paper.pdf - p.12: "Note that this procedure (wild cluster bootstrap) depends on
* the estimates of the residuals \hat{\epsilon}, and is therefore unsuited for GLM models with non-standard residuals (e.g. probit)."
*- clustse does not work with random effects or time series models at this time.
*CAT (cluster-adjusted bootstrap t statistic) does not work because there is no variation in bin and ref inside the clusters. 

gen auxp = period 
replace auxp = period - 15 if auxp > 15
egen idxt_boot = group(group auxp)


cgmwildboot gr_excess_contr bin ref , cluster(session) bootcluster(session) null(0 0) 
clustse
clusterbs pairs method
restore
* Kolmogorov test 
* Table A2 ** # observation is different than the paper. 

gen msg_out_yes = (msg_out == 2 | msg_out==3)
gen msg_in_yes = (msg_in ==2 | msg_in ==3)

ksmirnov contr if period > 5 & contr > 0 & (treatment == 0 | bin &(msg_out!=1|msg_in!=1)), by(bin)
ksmirnov contr if period > 5 & contr > 0 & (treatment == 0 | ref &(msg_out_yes!=1|msg_in_yes!=1)), by(ref)
ksmirnov contr if period > 5 & contr > 0 & (treatment == 0 | (bin & msg_out & msg_in)), by(bin)
ksmirnov contr if period > 5 & contr > 0 & (treatment == 0 | (ref & msg_out_yes & msg_in_yes)) , by(ref)
ksmirnov contr if period > 5 & contr > 0 & (bin & msg_out & msg_in | ref & msg_out_yes & msg_in_yes) , by(bin)



*Table A3

gen zero_contribution = contr == 0
gen non_zero_contr = contr
replace non_zero_contr =. if non_zero_contr ==0

matrix input TableMean_Zerocontr = (999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999\999,999,999,999,999,999,999,999,999)
matrix colnames TableMean_Zerocontr = "Full sample" "[6-25]" "[11-25]" 
matrix rownames TableMean_Zerocontr = "Mean NC" "(se)" "Mean Bin" "(se)" "Mean Ref" "(se)" "N" "pval NC=Bin" "pval NC=Ref" "pval Bin=Ref" "N"



local auxcol_1 = 0

qui gen psample = 1

foreach i in 0 5 10 {
local auxcol_2 =0
qui replace psample = period > `i'
local auxcol_1 = `auxcol_1' + 1

	foreach var of varlist non_zero_contr zero_contribution  {
	local auxcol_2 = `auxcol_2' + 1 

	
	mean `var' if psample & treatment ==0	, vce(cluster session)	
	mat TableMean_Zerocontr[1  ,3*(`auxcol_1'-1) +`auxcol_2'] = _b[`var']
	mat TableMean_Zerocontr[1, 3*(`auxcol_1')]  = e(N)
	mat TableMean_Zerocontr[1+1,3*(`auxcol_1'-1) +`auxcol_2'] = _se[`var']
	mat TableMean_Zerocontr[3+1, 3*(`auxcol_1')]  = .
	
	
	mean `var' if psample & bin & msg_out & msg_in				, vce(cluster session)
	mat TableMean_Zerocontr[3  ,3*(`auxcol_1'-1) +`auxcol_2'] = _b[`var']	
	mat TableMean_Zerocontr[3, 3*(`auxcol_1')]  = e(N)
	mat TableMean_Zerocontr[3+1,3*(`auxcol_1'-1) +`auxcol_2'] = _se[`var']
	mat TableMean_Zerocontr[3+1, 3*(`auxcol_1')]  = .
	
	mean `var' if psample & bin & (msg_out !=1|msg_in !=1)			, vce(cluster session)
	mat TableMean_Zerocontr[5  ,3*(`auxcol_1'-1) +`auxcol_2'] = _b[`var']
	mat TableMean_Zerocontr[5, 3*(`auxcol_1')]  = e(N)
	mat TableMean_Zerocontr[5+1,3*(`auxcol_1'-1) +`auxcol_2'] = _se[`var']
	mat TableMean_Zerocontr[5+1, 3*(`auxcol_1')]  = .
	
	mean `var' if psample & ref & msg_out_yes & msg_in_yes				, vce(cluster session)
	mat TableMean_Zerocontr[7  ,3*(`auxcol_1'-1) +`auxcol_2'] = _b[`var']	
	mat TableMean_Zerocontr[7, 3*(`auxcol_1')]  = e(N)
	mat TableMean_Zerocontr[7+1,3*(`auxcol_1'-1) +`auxcol_2'] = _se[`var']
	mat TableMean_Zerocontr[7+1, 3*(`auxcol_1')]  = .
	
	mean `var' if psample & ref & (msg_out_yes !=1|msg_in_yes !=1)			, vce(cluster session)
	mat TableMean_Zerocontr[9  ,3*(`auxcol_1'-1) +`auxcol_2'] = _b[`var']
	mat TableMean_Zerocontr[9, 3*(`auxcol_1')]  = e(N)
	mat TableMean_Zerocontr[9+1,3*(`auxcol_1'-1) +`auxcol_2'] = _se[`var']
	mat TableMean_Zerocontr[9+1, 3*(`auxcol_1')]  = .

	}
	}
	
estout matrix(TableMean_Zerocontr) using "C:\Users\Vinicius\Desktop\RA_Chico\TableMean_Zerocontr.csv", replace delimiter(",")

log close
*END
