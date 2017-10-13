// Better structure
// If I want to change SE, for example, I can do so ONCE
// If I want to add a country or outcome variable, I do so ONCE, Ecuador95
local countries Albania05 Bangladesh00
local outcome ln_tot_wge_d tot_hrsweek
local cntl1 edu age age_sq
local cntl2 i.industry
local cntl3 i.occupation
local se robust

foreach c in `countries' {
	use "./work/`c'_job_work.dta", clear
    foreach dep in `outcome' {
        reg `dep' `cntl1', vce(`se')
        reg `dep' `cntl1' `cntl2', vce(`se')
        reg `dep' `cntl1' `cntl2' `cntl3', vce(`se')
    }
}
