* Housekeeping
clear all

* Import file
use merged_data/2000-2022salestax.dta

* First, look at the data at levels
* Histogram
histogram sales_trate

* Plot time series of national aggregate
bysort year: egen avg_national_tax = mean(sales_trate)
scatter avg_national_tax year

* Plot time series, state level
scatter sales_trate year, by(state)

*---------
* Next, look at the data on changes in the rates
xtset year
sort state year
by state: gen tax_lag1 = sales_trate[_n-1]
gen tax_change = sales_trate - tax_lag1
* Clear up approximation errors
replace tax_change = 0 if abs(tax_change) < 0.001
gen changed = tax_change != 0

save merged_data/2000-2022taxchanges.dta

* Keep only states that have some changes
by state: egen only_first = total(changed)
drop if only_first == 1
drop only_first
scatter sales_trate year, by(state)

* Drop entries with no changes
drop if tax_change == 0

* Drop 2000, starting year (no change)
drop if year == 2000

* Plot number of changes per year
sort year
by year: egen total_changed = total(changed)
line total_changed year

* Plot change percent by year, size of point = count of that change
bysort year tax_change: gen change_freq = _N
scatter tax_change year [aw=change_freq], msymbol(Oh)

*------
* Merge in Joe's state inflation rates (annual means)
clear
import delimited original_data/statecpi_beta.csv

* Get annual means
bysort year state: egen avg_pi = mean(pi)
bysort year state: egen avg_pi_t = mean(pi_t)
bysort year state: egen avg_pi_nt = mean(pi_nt)
drop pi pi_t pi_nt quarter
drop if year < 2000

* Merge
merge 1:1 state year using merged_data/2000-2022taxchanges.dta
save merged_data/2000-2022taxandpi.dta

* Regression
encode state, gen(state_code)
xtset state_code year

* Regress on percent of tax change
eststo: xtreg avg_pi tax_change i.year, fe robust
eststo: xtreg avg_pi_t tax_change i.year, fe robust
eststo: xtreg avg_pi_nt tax_change i.year, fe robust

* Regress on changes up and down
eststo: xtreg avg_pi change_up change_down i.year, fe robust
eststo: xtreg avg_pi_t change_up change_down i.year, fe robust
eststo: xtreg avg_pi_nt change_up change_down i.year, fe robust

* esttab using plots/inflation_changes, replace

