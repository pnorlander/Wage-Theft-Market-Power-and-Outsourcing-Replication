*===============================================================================
* 03_tablea1_nbreg.do
* Table A.1: Negative Binomial Regressions
*
* WARNING: These regressions are computationally intensive.
* Each column may take 2-8+ hours to run.
*
* DV: viol (count of violations, rounded to integer)
* Key IV: hhithreeyearavg (HHI)
*
* Column structure (matches paper Appendix Table 1):
*   Col 1: Cell-level NB (nbreg), CZ+Occ+Year FE, HHI only - HAS lnalpha
*   Col 2: Cell-level NB (nbreg), CZ+Occ+Year FE, HHI×Subcontractor - HAS lnalpha
*   Col 3: Firm FE NB (xtnbreg fe), pooled sample, Year+Occ FE - NO lnalpha
*   Col 4: Lead firms pooled NB (nbreg), Year+Occ+CZ FE - HAS lnalpha
*   Col 5: Lead firms FE NB (xtnbreg fe vce(boot)), Year+Occ FE - NO lnalpha
*   Col 6: Subcontractors pooled NB (nbreg), Year+Occ+CZ FE - HAS lnalpha
*   Col 7: Subcontractors FE NB (xtnbreg fe vce(boot)), Year+Occ FE - NO lnalpha
*
* Note: Col 2 includes Subcontractor main effect + interaction. Cols 4-7 are split by subcontractor.
* Cols 5 and 7 use vce(boot) for bootstrap standard errors (matching original).
*
* Original STER file names (for reference):
*   Col 1: foianbr_3_viol_8_hhi.ster (nbreg)
*   Col 2: foianbr_3_viol_8_hhix.ster (nbreg)
*   Col 3: firmfextnbregviolD3wt2.ster (xtnbreg fe)
*   Col 4: firmbwnonsubnbrxtnbregviolD3wt2.ster (nbreg - "bw" = between/pooled)
*   Col 5: firmfenonsubxtnbregviolD3wt2.ster (xtnbreg fe)
*   Col 6: firmbwsubnbrxtnbregviolD3wt2.ster (nbreg - "bw" = between/pooled)
*   Col 7: firmfesubxtnbregviolD3wt2.ster (xtnbreg fe)
*===============================================================================

di ""
di "==============================================================================="
di "TABLE A.1: NEGATIVE BINOMIAL REGRESSIONS"
di "WARNING: This will take many hours to complete!"
di "==============================================================================="
di ""

timer clear
timer on 1

*===============================================================================
* COLUMNS 1-2: CELL-LEVEL NEGATIVE BINOMIAL
* Uses category_set == 3 (Firm-Occ-CZ-Year level)
* FE: CZ + Occupation + Year
*===============================================================================

use "$data/master_db.dta", clear
keep if category_set == 3

* Round violations to integer for count model
replace viol = round(viol)

di "===== COLUMN 1: Cell-level NB, HHI only ====="
di "Running: nbreg viol hhithreeyearavg logh1bs i.year i.occ2 i.cz90"

* Remove collinear variables
local ivs "hhithreeyearavg"
local spec "i.year i.occ2 i.cz90"
local rhs "`ivs' `spec'"
_rmcoll `rhs' logh1bs if viol > 0, expand

nbreg viol `r(varlist)' logh1bs, vce(cluster cz90) iter(20) difficult
est save $sters/tablea1_col1.ster, replace

di "Column 1 complete"
timer off 1
timer list 1
timer on 2

di "===== COLUMN 2: Cell-level NB, HHI×Subcontractor ====="
di "Running: nbreg viol hhithreeyearavg i.subcontractor c.hhithreeyearavg#i.subcontractor logh1bs i.year i.occ2 i.cz90"
di "Note: Lead firms (subcontractor=0) is the base/omitted category"

* Remove collinear variables - use ## for main effects + interaction
local ivs "hhithreeyearavg c.hhithreeyearavg##i.subcontractor"
local spec "i.year i.occ2 i.cz90"
local rhs "`ivs' `spec'"
_rmcoll `rhs' logh1bs if viol > 0, expand

nbreg viol `r(varlist)' logh1bs, vce(cluster cz90) iter(20) difficult
est save $sters/tablea1_col2.ster, replace

di "Column 2 complete"
timer off 2
timer list 2

*===============================================================================
* COLUMNS 3-7: FIRM-LEVEL NEGATIVE BINOMIAL (PANEL)
* Uses xtnbreg with firm fixed effects
* category_set == 3 (Firm-Occ-CZ-Year level)
*===============================================================================

use "$data/master_db.dta", clear
keep if category_set == 3

* Round violations to integer for count model
replace viol = round(viol)

* Create firm identifier
egen company = group(name)
xtset company

timer on 3

di "===== COLUMN 3: Firm FE NB, pooled sample ====="
di "Running: xtnbreg viol hhithreeyearavg logh1bs i.year i.occ2, fe"

xtnbreg viol hhithreeyearavg logh1bs i.year i.occ2, fe iter(20) difficult
est save $sters/tablea1_col3.ster, replace

di "Column 3 complete"
timer off 3
timer list 3
timer on 4

di "===== COLUMN 4: Lead firms pooled NB (nbreg), Year+Occ+CZ FE ====="
di "Running: nbreg viol hhithreeyearavg logh1bs i.year i.occ2 i.cz90 if subcontractor==0"
di "Note: Uses nbreg (not xtnbreg) so lnalpha will be reported"

* Remove collinear variables for lead firms
_rmcoll hhithreeyearavg logh1bs i.year i.occ2 i.cz90 if subcontractor == 0 & viol > 0, expand
nbreg viol `r(varlist)' if subcontractor == 0, vce(cluster cz90) iter(20) difficult
est save $sters/tablea1_col4.ster, replace

di "Column 4 complete"
timer off 4
timer list 4
timer on 5

di "===== COLUMN 5: Lead firms FE NB (xtnbreg fe), Year+Occ FE ====="
di "Running: xtnbreg viol hhithreeyearavg logh1bs i.year i.occ2 if subcontractor==0, fe vce(boot)"
di "Note: Uses xtnbreg fe so NO lnalpha will be reported"

xtnbreg viol hhithreeyearavg logh1bs i.year i.occ2 if subcontractor == 0, fe vce(boot) iter(20) difficult
est save $sters/tablea1_col5.ster, replace

di "Column 5 complete"
timer off 5
timer list 5
timer on 6

di "===== COLUMN 6: Subcontractors pooled NB (nbreg), Year+Occ+CZ FE ====="
di "Running: nbreg viol hhithreeyearavg logh1bs i.year i.occ2 i.cz90 if subcontractor==1"
di "Note: Uses nbreg (not xtnbreg) so lnalpha will be reported"

* Remove collinear variables for subcontractors
_rmcoll hhithreeyearavg logh1bs i.year i.occ2 i.cz90 if subcontractor == 1 & viol > 0, expand
nbreg viol `r(varlist)' if subcontractor == 1, vce(cluster cz90) iter(20) difficult
est save $sters/tablea1_col6.ster, replace

di "Column 6 complete"
timer off 6
timer list 6
timer on 7

di "===== COLUMN 7: Subcontractors FE NB (xtnbreg fe), Year+Occ FE ====="
di "Running: xtnbreg viol hhithreeyearavg logh1bs i.year i.occ2 if subcontractor==1, fe vce(boot)"
di "Note: Uses xtnbreg fe so NO lnalpha will be reported"

xtnbreg viol hhithreeyearavg logh1bs i.year i.occ2 if subcontractor == 1, fe vce(boot) iter(20) difficult
est save $sters/tablea1_col7.ster, replace

di "Column 7 complete"
timer off 7
timer list 7

*===============================================================================
* SUMMARY
*===============================================================================

di ""
di "==============================================================================="
di "TABLE A.1 NEGATIVE BINOMIAL REGRESSIONS COMPLETE"
di "==============================================================================="
di ""
di "Files saved:"
di "  $sters/tablea1_col1.ster - Cell-level nbreg, HHI only (HAS lnalpha)"
di "  $sters/tablea1_col2.ster - Cell-level nbreg, HHI×Subcontractor (HAS lnalpha)"
di "  $sters/tablea1_col3.ster - Firm FE xtnbreg, pooled (NO lnalpha)"
di "  $sters/tablea1_col4.ster - Lead firms pooled nbreg (HAS lnalpha)"
di "  $sters/tablea1_col5.ster - Lead firms FE xtnbreg (NO lnalpha)"
di "  $sters/tablea1_col6.ster - Subcontractors pooled nbreg (HAS lnalpha)"
di "  $sters/tablea1_col7.ster - Subcontractors FE xtnbreg (NO lnalpha)"
di ""
di "Timing summary:"
timer list

* End of file
