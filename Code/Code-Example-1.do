// Poor structure, everything is hard-coded
// If I want to change the SE or controls, I must do so SIX TIMES
// If I want to add countries, I must copy/paste all the regression commands
use "./work/Albania05_job_work.dta", clear

reg ln_tot_wge_d edu age age_sq, robust
reg ln_tot_wge_d edu age age_sq i.industry, robust
reg ln_tot_wge_d edu age age_sq i.industry i.occupation, robust

reg tot_hrsweek edu age age_sq, robust
reg tot_hrsweek edu age age_sq i.industry, robust
reg tot_hrsweek edu age age_sq i.industry i.occupation, robust

use "./work/Bangladesh00_job_work.dta", clear

reg ln_tot_wge_d edu age age_sq, robust
reg ln_tot_wge_d edu age age_sq i.industry, robust
reg ln_tot_wge_d edu age age_sq i.industry i.occupation, robust

reg tot_hrsweek edu age age_sq, robust
reg tot_hrsweek edu age age_sq i.industry, robust
reg tot_hrsweek edu age age_sq i.industry i.occupation, robust

// Extra new code
reg tot_hrsweek edu age age_sq, robust
reg tot_hrsweek edu age age_sq i.industry, robust
reg tot_hrsweek edu age age_sq i.industry i.occupation, robust
