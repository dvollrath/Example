******************************************************************************
*										
*                         Eberhardt and Vollrath (2016)							
*              				 Agricultural Convergence					
*					       		Data Preparation			
*													
******************************************************************************

global path "/users/dietz/dropbox/project/AgConverge"
global do "$path/Code"
global data "$path/Data"
global graphfolder "$path/Drafts"
global output "$path/Work"

******************************************************************************
*                         Import, reshape, and prepare USDA data					
******************************************************************************
clear

// Source data is from USDA
// https://apps.fas.usda.gov/psdonline/psdDownload.aspx
// "All Commodities (CSV Format)" last updated 4/22/2016
import delimited "$data/psd_alldata.csv"
save "$output/psd_alldata.dta", replace

// Drop several variables that will be useless to us
drop month // Reporting/harvest month
drop attribute_description // text version of attributes (we have codebook)
drop unit_description // text version of units (we have codebook)
drop unit_id // we cannot separately track this in dataset

// Reshape data from long to wide
// We want country/year/crop rows, with separate variables for each attribute
reshape wide value, i(commodity_code country_name market_year) j(attribute_id)
save "$output/psd_alldata_wide.dta", replace

// This dataset has all commodities
// Strip down to just the grains and pulses we want to evaluate
keep if commodity_code>400000 & commodity_code<543000

// Rename applicable variables and drop those not applicable
rename value4 area_harvest
rename value20 stock_begin
rename value28 production
rename value57 imports
rename value81 imports_TY
rename value84 imports_TY_US
rename value86 supply_total
rename value88 exports
rename value113 exports_TY
rename value125 dom_consumption
rename value130 dom_consumption_feed
rename value176 stock_end
rename value178 distribution_total
rename value184 yield_usda
rename value192 fsi_consumption
drop value* // get rid of remaining variables no associated with grains/pulses

// Yield calculations
// USDA provides a yield, but it is not always consistent with their production/area information
gen yield_raw = production/area_harvest

pwcorr yield_raw yield_usda, sig // just to see the high correlation, but imperfect

// Generate WB Codes for countries so that we can link to FAO population data
// USDA does not separately track EU countries, so "EU-15" is the combination values for that group
rename country_name country
rename market_year year
qui do "$do/A_wbcode.do"
drop if wbcode=="" // get rid of countries that cannot be coded

gen eu15=0 // flag variable to distinguish data sources

save "$output/psd_grains_wide.dta", replace

******************************************************************************
*                         Import, reshape, and prepare European Data					
******************************************************************************

// Open and incorporate European data on EU-15 ONLY - PSD has the data on other Euro countries
foreach source in apro_acs_a apro_acs_h { // two source files - one through 1999, one 2000-2016
	// Open stata file
	clear
	import delimited "$data/`source'.tsv"
	
	// Set max year by which file used
	local year_max = 1999
	if "`source'" == "apro_acs_a" {
		local year_max = 2016
	}
	// Pull numeric information out of all variables
	local year = `year_max' + 1
	foreach var of varlist _all { // for all variables
		qui egen num`var' = sieve(`var'), char(0123456789.) // get only numeric chars from data
		qui destring num`var', replace // destring the resulting numeric characters
		qui rename num`var' num`year' // rename numeric variable with year
		local year = `year' - 1
	}
	drop if _n==1 // now get rid of first row header
	local year = `year_max' + 1
	drop num`year' // gets rid of numeric variable associated with identifier variable

	rename v1 euraw // this is string coding of identifiers
	drop v* // this gets rid of all the string versions of data variables
	
	// Generate useful codings
	split euraw, parse(,) // separate information in euraw
	rename euraw1 eu_crop_code // EU crop code
	rename euraw2 eu_msr_code // EU measure
	rename euraw3 country_code // EU country/geographic group
	drop euraw 

	// Put in country, crop, measure rows
	reshape long num, i(country_code eu_crop_code eu_msr_code) j(year)
	// Put in country, crop. year rows
	reshape wide num, i(country_code eu_crop_code year) j(eu_msr_code) string

	save "$output/`source'.dta", replace
}

// Append the datasets
append using "$output/apro_acs_a.dta"
save "$output/apro_acs_all.dta", replace

// Generate comparable variables for Europe
drop numHU numMA // no matches in USDA
rename numAR area_harvest // measured in 1000 HA's
rename numYI yield_usda // measured in kg/ha
rename numPR production // measured in 1000 MT's
replace production = 1000*production // convert 1000MT to MT
gen yield_raw = production/(1000*area_harvest) // now in MT/HA, as in PSD

quietly { // create empty variables to match USDA dataset
	gen stock_begin = . 
	gen imports = .
	gen imports_TY = .
	gen imports_TY_US = .
	gen supply_total = .
	gen exports = .
	gen exports_TY = .
	gen dom_consumption = .
	gen dom_consumption_feed = .
	gen stock_end = .
	gen distribution_total = .
	gen fsi_consumption = .
	gen market_year = .
}

qui do "$do/A_eucode.do" // translate EU ISO3166 codes to country names

qui do "$do/A_wbcode.do" // translate country names to WB codes

drop if wbcode=="" // no ability to translate - EU aggregates
gen eu15=0 // flag to identify countries in this group
replace eu15=1 if inlist(wbcode,"AUT","BEL","DNK","FIN","FRA","DEU")
replace eu15=1 if inlist(wbcode,"GRC","IRL","ITA","LUX","NLD","PRT")
replace eu15=1 if inlist(wbcode,"ESP","SWE","GBR")
keep if eu15==1 // use only the EU-15 countries

quietly { // assign crop codes to match PSD data
	gen commodity_code = .
	gen commodity_description = ""
	replace commodity_code = 410000 if eu_crop_code=="C1100" // Wheat
	replace commodity_description = "Wheat" if eu_crop_code=="C1100"
	replace commodity_code = 422110 if eu_crop_code=="C2000" // EU "Rice", PSD "Rice, milled"
	replace commodity_description = "Rice, Milled" if eu_crop_code=="C2000"
	replace commodity_code = 430000 if eu_crop_code=="C1300" // Barley
	replace commodity_description = "Barley" if eu_crop_code=="C1300"
	replace commodity_code = 440000 if eu_crop_code=="C1500" // EU "Grain maize and corn-cob mix", PSD "Corn"
	replace commodity_description = "Corn" if eu_crop_code=="C1500"
	replace commodity_code = 451000 if eu_crop_code=="C1210" // Rye
	replace commodity_description = "Rye" if eu_crop_code=="C1210"
	replace commodity_code = 452000 if eu_crop_code=="C1410" // Oats
	replace commodity_description = "Oats" if eu_crop_code=="C1410"
	replace commodity_code = 459200 if eu_crop_code=="C1700" // Sorghum
	replace commodity_description = "Sorghum" if eu_crop_code=="C1700"
	// Millet is not included because in EU it is under an aggregated category
	// Mixed Grain is not included because in EU there is no corresponding category
}

keep if commodity_code~=. // drop all observations from crops/products not matching PSD data
drop eu_crop_code // not necessary

save "$output/apro_acs_all.dta", replace
// Recreate the EU15 data using EU data to confirm levels are comparable
preserve
	collapse(sum) area_harvest production, by(commodity_code year)
	gen yield_raw_check = production/(1000*area_harvest)
	rename area_harvest area_harvest_eu15
	rename production production_eu15
	gen wbcode = "E15"
	save "$output/psd_grains_eu15check.dta", replace
restore

******************************************************************************
*             Combine USDA and European Data, Check Consistency				
******************************************************************************

append using "$output/psd_grains_wide.dta"
save "$output/psd_grains_final.dta", replace // final dataset that holds full sample

// Merge back the EU15 aggregates to compare to PSD aggregates
merge 1:1 wbcode commodity_code year using "$output/psd_grains_eu15check.dta"
drop _merge

levelsof commodity_code, local(crop_code) // get all the crop codes available in dataset
foreach c of local crop_code { // for each crop
	di "Commodity code: " (`c')
	// PSD only has limited years, so look only at years with PSD data
	pwcorr yield_raw_check yield_raw if commodity_code==`c' & wbcode=="E15" & yield_raw~=. // look at correlation of yields
	summ yield_raw_check yield_raw if commodity_code==`c' & wbcode=="E15" & yield_raw~=. // look at levels of yields, range
}

drop if wbcode=="E15" // above analysis confirms PSD E15 is very close to our E15 aggregate, so drop
drop area_harvest_eu15 production_eu15 yield_raw_check // drop variables, not necessary

// Create last variables used in regressions
egen country_id = group(wbcode) // create numeric country ID
egen country_crop_id = group(country_id commodity_code) // generates unique country/crop ID
egen crop_year_id = group(commodity_code year) // generates unique crop/year ID
gen ln_yield = ln(yield_raw)

// Drop Mixed Grain category
drop if commodity_code == 459900 // drop "Mixed Grain" category, small sample, unclear composition

save "$output/psd_grains_final.dta", replace // final dataset that holds full sample

******************************************************************************
*             Merge FAO Population Data				
******************************************************************************
merge m:1 wbcode year using "$data/fao-pop-all-long.dta", keep(match master) nogen

save "$output/psd_grains_final.dta", replace // final dataset that holds full sample

******************************************************************************
*             Merge FAO GAEZ data			
******************************************************************************
merge m:1 wbcode commodity_code using "$output/fao-gaez-all-long.dta", keep(match master) nogen

drop if avg_i==.

save "$output/psd_grains_final.dta", replace // final dataset that holds full sample

******************************************************************************
*             Denote Balanced Panel Observations		
******************************************************************************
gen balanced = 0
levelsof country_crop_id, local(country_crop_code)
foreach c of local country_crop_code { // look at each individual country/crop panel
	qui summ year if ln_yield~=. & country_crop_id==`c' // get information on which years have data
	qui replace balanced = 1 if country_crop_id==`c' & ln_yield~=. /// for this country/crop ID, obs with values
		& r(min)<=1961 & r(max)>=2015 /// but only if it has sufficient range
		& r(N)==r(max)-r(min)+1 /// and only if it has no gaps
		& year>=1961 & year<=2015 // and only if it is exactly in this time range
}

save "$output/psd_grains_final.dta", replace // final dataset that holds full sample
