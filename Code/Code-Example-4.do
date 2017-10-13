// Better structure
// If I want to change SE, for example, I can do so ONCE
// If I want to add a country or outcome variable, I do so ONCE, Ecuador95
local countries Albania05 Bangladesh00
local outcome ln_tot_wge_d tot_hrsweek
local cntl1 edu age age_sq
local cntl2 i.industry
local cntl3 i.occupation
local se robust

// Add in storing estimates, and writing to output tables for use in Latex
foreach c in `countries' {
	estimates clear
	local j = 1
	use "./work/`c'_job_work.dta", clear
    foreach dep in `outcome' {
        reg `dep' `cntl1', vce(`se')
		estimates store out`j'
		local j = `j' + 1
        reg `dep' `cntl1' `cntl2', vce(`se')
		estimates store out`j'
		local j = `j' + 1
        reg `dep' `cntl1' `cntl2' `cntl3', vce(`se')
		estimates store out`j'
		local j = `j' + 1
    }
	estout out? using "./drafts/tab_reg_`c'.tex", replace style(tex) ///
		cells(b(fmt(3)) se(par fmt(3))) stats(r2 N, fmt(%9.2f %9.0g) labels("R-squared" "Observations")) ///
		keep(edu) label mlabels(none) collabels(none) prefoot("\addlinespace")
}
