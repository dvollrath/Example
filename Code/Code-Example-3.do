// What if there are unique characteristics to each country? 
// The original loops won't cover things
// Write a general program that can handle things

capture program drop run_reg
program run_reg 
    syntax [, name(string) lhs(string) x1(string) x2(string) x3(string) se(string)]

	use "./work/`name'_job_work.dta", clear
    foreach dep in `lhs' {
        reg `dep' `x1', vce(`se')
        reg `dep' `x1' `x2', vce(`se')
        reg `dep' `x1' `x2' `x3', vce(`se')
    }
end

// Now I have code to go through separate countries
local se ols // this is common to every regression

local name "Albania05"
local outcome ln_tot_wge_d 
local cntl1 edu age age_sq 
local cntl2 i.industry 
local cntl3 "" // no occupation controls

run_reg, name(`name') lhs(`outcome') x1(`cntl1') x2(`cntl2') x3(`cntl3') se(`se')

local name "Bangladesh00"
local outcome ln_tot_wge_d tot_hrsweek 
local cntl1 edu // no age data
local cntl2 i.industry 
local cntl3 i.occupation

run_reg, name(`name') lhs(`outcome') x1(`cntl1') x2(`cntl2') x3(`cntl3') se(`se')

// If I want to add a country, then I can set up a unique call for a new country
