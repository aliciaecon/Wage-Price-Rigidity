* Housekeeping
clear all

* Import file
use VG_2016/VZ_state_quarterly.dta

* Date variables
gen quarter = quarter(dofq(quarterly_date))
gen year = year(dofq(quarterly_date))

* Plot state minimum wage markup from federal
gen min_minus_fed = mean_mw - mean_fed_mw
line min_minus_fed quarterly_date, by(stateabb)
