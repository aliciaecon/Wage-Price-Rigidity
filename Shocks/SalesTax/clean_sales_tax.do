* Housekeeping
clear all

forvalues s = 2021/2022{
	import excel using original_data/state_sales_tax_4.xlsx, sheet("`s'") cellrange(B9)
	drop C E G I
	rename B state
	rename D sales_trate
	rename F food_exempt
	rename H prescrip_exempt
	rename J nonprescrip_exempt
	drop if missing(sales_trate)
	gen year = `s'
	save salestaxdta/`s'salestax.dta, replace
	clear
}

forvalues s = 2013/2020{
	import excel using original_data/state_sales_tax_4.xlsx, sheet("`s'") cellrange(A9)
	drop B D F H
	rename A state
	rename C sales_trate
	rename E food_exempt
	rename G prescrip_exempt
	rename I nonprescrip_exempt
	drop if missing(sales_trate)
	gen year = `s'
	save salestaxdta/`s'salestax.dta, replace
	clear
}

import excel using original_data/state_sales_tax_4.xlsx, sheet("2012") cellrange(A8)
rename A state
rename B sales_trate
rename C food_exempt
rename D prescrip_exempt
rename E nonprescrip_exempt
drop if missing(sales_trate)
gen year = 2012
save salestaxdta/2012salestax.dta, replace
clear

import excel using original_data/state_sales_tax_4.xlsx, sheet("2011") cellrange(A7)
rename A state
rename B sales_trate
rename C food_exempt
rename D prescrip_exempt
rename E nonprescrip_exempt
drop if missing(sales_trate)
gen year = 2011
save salestaxdta/2011salestax.dta, replace
clear

foreach s in 2010 2008 2007{
	import excel using original_data/state_sales_tax_4.xlsx, sheet("`s'") cellrange(A6)
	rename A state
	rename B sales_trate
	rename C food_exempt
	rename D prescrip_exempt
	rename E nonprescrip_exempt
	drop if missing(sales_trate)
	gen year = `s'
	save salestaxdta/`s'salestax.dta, replace
	clear
}

import excel using original_data/state_sales_tax_4.xlsx, sheet("2006") cellrange(A11)
rename A state
rename B sales_trate
rename C food_exempt
rename D prescrip_exempt
rename E nonprescrip_exempt
drop if missing(sales_trate)
gen year = 2006
save salestaxdta/2006salestax.dta, replace
clear

* Note: Slightly different variables for pre-2006 years
foreach s in 2004 2003 2000{
	import excel using original_data/state_sales_tax_4.xlsx, sheet("`s'") cellrange(A7:E53)
	rename A state
	rename B food_exempt
	rename C sales_trate
	rename D max_local_rate
	rename E max_statelocal_rate
	drop if missing(sales_trate)
	gen year = `s'
	save salestaxdta/`s'salestax_original.dta, replace
	clear
}

* Create new dta files for pre-2006 years
* Fill in 0 taxes for missing states
* Fill in missing values for prescription exemptions
* Create new dataset containing missing states
use salestaxdta/2020salestax.dta
keep if missing(food_exempt)
drop if state == "Alaska"
save salestaxdta/append.dta, replace
* Now edit the year files
foreach s in 2004 2003 2000{
	use salestaxdta/`s'salestax_original.dta
	drop max_local_rate
	drop max_statelocal_rate
	gen prescrip_exempt = ""
	gen nonprescrip_exempt = ""
	append using salestaxdta/append.dta
	replace year = `s'
	save salestaxdta/`s'salestax.dta, replace
	clear
}

* Create new dta file from the missing data
import excel using missing_data/MissingData.xlsx, firstrow case(lower)
* Clean up some missing values
replace food_exempt = "Exempt" if food_exempt == "*"
replace food_exempt = "Taxable" if food_exempt == ""
replace prescrip_exempt = "Exempt" if prescrip_exempt == "*" 
replace prescrip_exempt = "Taxable" if prescrip_exempt == "" 
replace nonprescrip_exempt = "Exempt" if nonprescrip_exempt == "*" 
replace nonprescrip_exempt = "Taxable" if nonprescrip_exempt == "" 
save salestaxdta/missing_salestax.dta, replace
clear


* Merge 2000-2022 data (missing years 2009, 2005, 2002, 2001)
append using salestaxdta/2000salestax.dta salestaxdta/2003salestax.dta
append using salestaxdta/2004salestax.dta
forvalues i = 2006/2008{
	append using salestaxdta/`i'salestax.dta 
}
forvalues i = 2010/2022{
	append using salestaxdta/`i'salestax.dta 
}
append using salestaxdta/missing_salestax.dta
* Clean up state names
gen state_new = strtrim(regexs(0)) if regexm(state, "[a-zA-Z ]+")
drop state
rename state_new state
replace state = "District of Columbia" if state == "District Of Columbia"
* Clean up 0s for the state tax rate
replace sales_trate = word(sales_trate, 1)
replace sales_trate = "0" if regexm(sales_trate, "[a-zA-Z ]+")
replace sales_trate = "0" if regexm(sales_trate, "-")
destring sales_trate, replace

* Fix some California and Virginia rates for consistency; add in 
* state-wide local tax
replace sales_trate = sales_trate + 1 if state == "Virginia" & year == 2000
replace sales_trate = sales_trate + 1 if state == "Virginia" & year == 2003
replace sales_trate = sales_trate + 1 if state == "Virginia" & year == 2004
replace sales_trate = sales_trate + 1 if state == "Virginia" & year == 2006
replace sales_trate = sales_trate + 1.25 if state == "California" & year == 2000
replace sales_trate = sales_trate + 1.25 if state == "California" & year == 2003
replace sales_trate = sales_trate + 1.25 if state == "California" & year == 2004
replace sales_trate = sales_trate + 1 if state == "California" & year == 2006


save merged_data/2000-2022salestax.dta, replace




