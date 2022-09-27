# The Micro Phillips Curve

This folder contains the code and data for the ongoing project _The Micro Phillips Curve_.

## Current contents
* _/Shocks/QCEW_: Data files and code creating a Bartik instrument for area wage growth constructed using QCEW data from 1990-2021. The instrument is:
$$\text{wage shock in MSA } m = \sum_i \text{employment  share in occupation } o \text{ and MSA } m \times \text{national wage growth}_o$$
Different versions of the instrument include all combinations of wages measured both annually and weekly, and employment share calculated using the share of employees in occupation $o$ and the share of the wage bill of occupation $o$.
* _/Shocks/SalesTax_: Data files and code on state sales taxes from 2000-2022, currently missing years 2001, 2002, 2005, and 2009.
* _/Shocks/Unions_: Data files on union coverage density, union membership density, and all unionization cases from 1984-2022.
* _/Shocks/MinWage/VG_2016_: Historical minimum wage data from 1974-2016. Includes substate data for 34 localities starting in 2004. Data from Vaghul and Zipperer (2016).
* _/Shocks/Archive/OES_: Archived Bartik instrument constructed using OES data. Dropped as the BLS discourages using the OES as a time series.

## To do
* Get in touch with the NLRB and ask about the availability of data on EINs, votes for/against, and unionization successes/failures. If the data is available, submit a FOIA request.
* Find sales tax data for missing years.
* Run some exploratory analyses on sales tax data to determine how to use this data as a shock.
* Check Compustat for available data concerning trade and exchange rates.
