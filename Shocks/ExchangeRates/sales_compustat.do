** Code description:
** Generate fraction of foreign sales for companies in Compustat

* Housekeeping
clear all

* Read in data
use compustat.dta

* Keep unique observations only
keep if srcdate == datadate

* Create date-company identifier
tostring(srcdate), replace
gen id_date = cik + "_" + srcdate

* Reformat some variables
destring(geotp), replace
replace sales = 0 if sales == .
replace salexg = 0 if salexg == .

* Domestic exports: Exports from the domestic segment
bysort id_date: egen domestic_exports = total(salexg [geotp == 2]) 

* Domestic sales = domestic segment sales - exports
bysort id_date: egen domestic_segment = total(sales [geotp == 2]) 
bysort id_date: gen domestic_sales = domestic_segment - domestic_exports

* Foreign sales = foreign segment sales + exports
bysort id_date: egen foreign_segment = total(sales [geotp == 3]) 
bysort id_date: gen foreign_sales = foreign_segment + domestic_exports

* Keep identifying information and sales data
keep cik datadate domestic_sales foreign_sales domestic_exports

* Generate foreign sales ratio
gen foreign_ratio = foreign_sales / (foreign_sales + domestic_sales)

* Drop if foreign_ratio > 1 (some sort of data error?)
drop if foreign_ratio > 1

* Drop duplicates
duplicates drop

* save
save sales_location.dta, replace
