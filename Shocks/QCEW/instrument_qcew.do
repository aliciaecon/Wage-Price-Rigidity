** Code description:
** Merge .dta QCEW files
** Generate instrument

* Housekeeping
clear all

** Merge
append using quarterlydta/1990qtr.dta quarterlydta/1991qtr.dta 
forvalues i = 1992/2021{
	append using quarterlydta/`i'qtr.dta 
}
save mergeddta/full_data.dta, replace

program define construct_instrument
	use mergeddta/full_data.dta
	* Drop unused variables
	drop taxable_qtrly_wages qtrly_contributions qtrly_estabs
	
	** Create some useful variables
	gen avg_emplvl = (month1_emplvl + month2_emplvl + month3_emplvl)/3
	drop month1_emplvl month2_emplvl month3_emplvl
	*Year quarter marker
	gen first_month = 1 + ((qtr - 1) * 3)
	gen yrqtr = qofd(mdy(first_month, 1, year))
	format %tq yrqtr
	drop year qtr
	* Interacted variables
	* Area x industry
	gen area_ind = area_fips + "_" + industry_code
	* Area x year-quarter
	tostring(yrqtr), gen(yrqtr_temp)
	gen area_yq = area_fips + "_" + yrqtr_temp
	* Industry x year
	gen ind_yq = industry_code + "_" + yrqtr_temp
	
	** Handle options
	* Mean wage by option type
	if $opt_wage == 1{
		gen tot_wage = total_qtrly_wages
	}
	if $opt_wage == 2{
		gen tot_wage = avg_emplvl * avg_wkly_wage
	}
	* Share of employment in each occupation, if we choose this to interact with
	if $opt_interact == 1{
		bysort area_yq: egen tot_emp_area = total(avg_emplvl)
		gen frac_occ = avg_emplvl / tot_emp_area
	}
	* Share of wage bill in each FIPS, if we choose this to interact with
	if $opt_interact == 2{
		bysort area_yq: egen tot_wage_area = total(tot_wage)
		gen frac_occ = tot_wage / tot_wage_area
	}

	* Construct instrument
	* Current average wages, not including the MSA of interest
	* (Mean annual wages)
	* Weight by # people in each occupation x year x msa
	bysort ind_yq: egen ind_wage_total = total(tot_wage) 
	gen ind_wage_no_self = ind_wage_total - tot_wage
	* Divide by total employment in each occupation x year 
	bysort ind_yq: egen emp_ind_yq = total(avg_emplvl)
	gen avg_wage_no_self = ind_wage_no_self / (emp_ind_yq - avg_emplvl)

	* Occupation wage growth from previous year (national, excluding MSA of interest)
	gen area_ind_clean = subinstr(area_ind, "_", "",.)
	egen long area_ind_id = group(area_ind_clean)

	* Handle duplicates: Take the entry with the highest average employment
	gsort area_ind_id yrqtr -avg_emplvl
	duplicates drop area_ind_id yrqtr, force

	* Create time series
	xtset area_ind_id yrqtr, quarterly
	sort area_ind_id yrqtr
	gen wage_growth = (avg_wage_no_self - L.avg_wage_no_self)/L.avg_wage_no_self

	* Construct instrument
	gen share_x_growth = frac_occ * wage_growth
	bysort area_yq: egen instrument = total(share_x_growth)

	* Drop missings
	drop if share_x_growth == .

	* Keep variables of interest
	keep area_fips yrqtr instrument

	* Drop duplicates
	duplicates drop

	* Save
	* Define different titles
	if $opt_interact == 1{
		local s1 = "empshare"
	}
	if $opt_interact == 2{
		local s1 = "wageshare"
	}

	if $opt_wage == 1{
		local s2 = "qtrly"
	}
	if $opt_wage == 2{
		local s2 = "hrly"
	}
	save instrument/instrument_`s1'_`s2'.dta, replace
end

* Define some options 
* opt_wage: Quarterly or hourly wages
* 1: Average quarterly wages
* 2: Average hourly wages

* opt_interact: How to weight industry wage changes
* 1: Interacting industry x FIPS wage changes by FIPS employment shares
* 2: Interacting industry x FIPS wage changes by FIPS wage bill shares

* Loop through all combinations of the options
forvalues x = 1/2{
	forvalues y = 1/2{
		global opt_wage = `x'
		global opt_interact = `y'
		construct_instrument
		clear
	}
}

exit, STATA clear

