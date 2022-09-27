*** Code description: 
** Clean and create separate .dta files from the original MSA excel files

* Housekeeping
clear all

* Keep only if aggregated at the county, 6-digit NAICS level
* Keep variables of interest
* Makes data a more manageable size
* Save all as .dta files

forvalues i = 1990/2021{
	import delimited using originalcsv/`i'.q1-q4.singlefile.csv
	keep if agglvl_code == 78
	keep area_fips industry_code year qtr qtrly_estabs month1_emplvl month2_emplvl month3_emplvl total_qtrly_wages taxable_qtrly_wages qtrly_contributions avg_wkly_wage 
	save quarterlydta/`i'qtr.dta, replace
	clear
}

exit, STATA clear
