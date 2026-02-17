*===============================================================================
* 01a_run_regressions.do
* Runs all regressions and saves estimation results to .ster files
*
* This file ONLY runs regressions and saves results. Table generation is in
* 01_tables.do which loads these .ster files and exports LaTeX tables.
*
* To skip running regressions (use pre-computed .ster files):
* Comment out "do $code/01a_run_regressions.do" in 00_master.do
*
* Tables covered (in paper order):
*   - Table 2: Wages, Skill Levels, Subcontractor Status (6 cols)
*   - Table 3: Log Violations (7 cols)
*   - Table 4: IV Log Violations (8 cols)
*   - Table A.1: Negative Binomial (SKIPPED - computationally intensive)
*   - Table A.2: Weighted Log Violations (Panel A: FE 4 cols, Panel B: RE 4 cols)
*   - Table A.3: Weighted Log Back Wages (Panel A: FE 4 cols, Panel B: RE 4 cols)
*   - Table A.4: Unweighted Log Back Wages (7 cols)
*   - Table A.5: Log BW/PW (Panel A: FE 4 cols, Panel B: RE 4 cols)
*   - Table A.6: Log BW/PW with HHI×Sub (8 cols)
*   - Table A.7: Log Violations at Occ-CZ-Year level (8 cols)
*   - Table A.8: Log Violations at Industry-CZ-Year level (8 cols)
*   - Table A.9: Unweighted Log Violations (Panel A: FE 4 cols, Panel B: RE 4 cols)
*   - Table A.10: Log Violations with HHI×Sub (8 cols)
*   - Table A.11: Unweighted Log Back Wages (Panel A: FE 4 cols, Panel B: RE 4 cols)
*   - Table A.12: Log Back Wages with HHI×Sub (8 cols)
*
* NOTE: Tables 1, 5, 6 are generated directly in 01_tables.do (no .ster files)
*===============================================================================

di ""
di "==============================================================================="
di "RUNNING ALL REGRESSIONS - Saving to .ster files"
di "==============================================================================="
di ""

timer clear
timer on 1

*===============================================================================
* TABLE 2: WAGES, SKILL LEVELS, AND SUBCONTRACTOR STATUS
* DV: wage (wage offered)
* Key IVs: hhicat (HHI category), round_wage_level (skill level)
*
* Uses subcontractor_2019 (from 2019 wage level data merge) to match original
*===============================================================================

di "===== TABLE 2: WAGES, SKILL LEVELS (6 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3

* Table 2: Wages, Skill Levels
preserve
drop if round_wage_level == .
    di "Table 2: N with wage level data = " _N

    * Create FE group variables
    cap drop yr_cz_fes yr_occ_fes
    egen yr_cz_fes = group(year cz90)
    egen yr_occ_fes = group(year occ2)

    * Column 1: No FE
    reg wage i.hhicat i.round_wage_level logimm i.subcontractor_2019
    est save $sters/table2_col1.ster, replace

    * Column 2: Year FE
    areg wage i.hhicat i.round_wage_level logimm i.subcontractor_2019, absorb(year) vce(cluster cz90)
    est save $sters/table2_col2.ster, replace

    * Column 3: Occupation FE
    areg wage i.hhicat i.round_wage_level logimm i.subcontractor_2019, absorb(occ2) vce(cluster cz90)
    est save $sters/table2_col3.ster, replace

    * Column 4: CZ FE
    areg wage i.hhicat i.round_wage_level logimm i.subcontractor_2019, absorb(cz90) vce(cluster cz90)
    est save $sters/table2_col4.ster, replace

    * Column 5: Year + CZ FE
    areg wage i.hhicat i.round_wage_level logimm i.subcontractor_2019, absorb(yr_cz_fes) vce(cluster cz90)
    est save $sters/table2_col5.ster, replace

    * Column 6: Year + Occupation FE
    areg wage i.hhicat i.round_wage_level logimm i.subcontractor_2019, absorb(yr_occ_fes) vce(cluster cz90)
    est save $sters/table2_col6.ster, replace

restore
di "Table 2: 6 .ster files saved"

*===============================================================================
* TABLE 3: EFFECT OF LABOR MARKET POWER ON LOG(VIOLATIONS)
* DV: logviol = log(1 + 1000*(violations/H1Bs))
* Key IV: hhithreeyearavg (HHI)
* 7 columns: Cell-level (cols 1-2), Firm FE pooled (col 3),
*            Lead firms (cols 4-5), Subcontractors (cols 6-7)
*===============================================================================

di "===== TABLE 3: LOG VIOLATIONS (7 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3
egen company = group(name)

* Columns 1-2: Cell-level regressions with areg absorb(cz90)
areg logviol hhithreeyearavg logh1bs i.year i.occ2, absorb(cz90) vce(cluster cz90)
est save $sters/table3_col1.ster, replace

areg logviol hhithreeyearavg c.hhithreeyearavg#i.subcontractor i.subcontractor logh1bs i.year i.occ2, absorb(cz90) vce(cluster cz90)
est save $sters/table3_col2.ster, replace

* Columns 3-7: Firm FE regressions - UNWEIGHTED
areg logviol hhithreeyearavg logh1bs i.year i.occ2, absorb(company) vce(cluster cz90)
est save $sters/table3_col3.ster, replace

areg logviol hhithreeyearavg logh1bs i.occ2 if subcontractor==0, absorb(company) vce(cluster cz90)
est save $sters/table3_col4.ster, replace

areg logviol hhithreeyearavg logh1bs i.year i.occ2 if subcontractor==0, absorb(company) vce(cluster cz90)
est save $sters/table3_col5.ster, replace

areg logviol hhithreeyearavg logh1bs i.occ2 if subcontractor==1, absorb(company) vce(cluster cz90)
est save $sters/table3_col6.ster, replace

areg logviol hhithreeyearavg logh1bs i.year i.occ2 if subcontractor==1, absorb(company) vce(cluster cz90)
est save $sters/table3_col7.ster, replace

di "Table 3: 7 .ster files saved"

*===============================================================================
* TABLE 4: IV REGRESSION - LOG(VIOLATIONS)
* Instrument: iv2 = leave-one-out mean of HHI
* 8 columns with various FE specifications
*===============================================================================

di "===== TABLE 4: IV REGRESSIONS (8 columns) ====="

* Merge with iv_data to get instrument
capture drop _merge
merge m:1 cz90 occ2 year using "$data/iv_data.dta", keepusing(iv2)
drop if _merge == 2
drop _merge

* Check required packages are installed
which ivreg2
which xtivreg2

xtset cz90

    * Column 1: No FE
    ivreg2 logviol logh1bs (hhithreeyearavg = iv2), cluster(cz90)
    est save $sters/table4_col1.ster, replace

    * Column 2: Year FE
    ivreg2 logviol logh1bs i.year (hhithreeyearavg = iv2), cluster(cz90)
    est save $sters/table4_col2.ster, replace

    * Column 3: Occ FE
    ivreg2 logviol logh1bs i.occ2 (hhithreeyearavg = iv2), cluster(cz90)
    est save $sters/table4_col3.ster, replace

    * Column 4: CZ FE
    xi: xtivreg2 logviol logh1bs (hhithreeyearavg = iv2), fe cluster(cz90)
    est save $sters/table4_col4.ster, replace

    * Column 5: Occ+CZ FE
    xi: xtivreg2 logviol logh1bs i.occ2 (hhithreeyearavg = iv2), fe cluster(cz90)
    est save $sters/table4_col5.ster, replace

    * Column 6: Year+Occ FE
    ivreg2 logviol logh1bs i.year i.occ2 (hhithreeyearavg = iv2), cluster(cz90)
    est save $sters/table4_col6.ster, replace

    * Column 7: Year+CZ FE
    xi: xtivreg2 logviol logh1bs i.year (hhithreeyearavg = iv2), fe cluster(cz90)
    est save $sters/table4_col7.ster, replace

    * Column 8: Year+Occ+CZ FE
    xi: xtivreg2 logviol logh1bs i.year i.occ2 (hhithreeyearavg = iv2), fe cluster(cz90)
    est save $sters/table4_col8.ster, replace

di "Table 4: 8 .ster files saved"

*===============================================================================
* TABLE A.1: NEGATIVE BINOMIAL REGRESSIONS
* SKIPPED: Computationally intensive (8+ hours per column)
* Use pre-computed .ster files from parent sters/ directory
*===============================================================================

di "===== TABLE A.1: NEGATIVE BINOMIAL ====="
di "SKIPPING: Use pre-computed .ster files (nbreg takes 8+ hours per column)"

do "$code/03_tablea1_nbreg.do"

*===============================================================================
* TABLE A.2: WEIGHTED LOG(VIOLATIONS) - FIRM FE AND RE
* Panel A: Firm Fixed Effects (4 cols)
* Panel B: Random Effects / Pooled OLS (4 cols)
*===============================================================================

di "===== TABLE A.2: WEIGHTED LOG VIOLATIONS (8 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3
egen company = group(name)
cap drop fw_h1bs
gen fw_h1bs = round(nbr_h1bs)
xtset company

* Panel A: Firm Fixed Effects
areg logviol hhithreeyearavg logh1bs [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea2a_col1.ster, replace

areg logviol hhithreeyearavg logh1bs i.year [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea2a_col2.ster, replace

areg logviol hhithreeyearavg logh1bs i.occ2 [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea2a_col3.ster, replace

areg logviol hhithreeyearavg logh1bs i.year i.occ2 [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea2a_col4.ster, replace

* Panel B: Random Effects (Pooled OLS)
reg logviol hhithreeyearavg logh1bs [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea2b_col1.ster, replace

reg logviol hhithreeyearavg logh1bs i.year [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea2b_col2.ster, replace

reg logviol hhithreeyearavg logh1bs i.occ2 [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea2b_col3.ster, replace

reg logviol hhithreeyearavg logh1bs i.year i.occ2 [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea2b_col4.ster, replace

di "Table A.2: 8 .ster files saved"

*===============================================================================
* TABLE A.3: WEIGHTED LOG(BACK WAGES) - FIRM FE AND RE
*===============================================================================

di "===== TABLE A.3: WEIGHTED LOG BACK WAGES (8 columns) ====="

* Panel A: Firm Fixed Effects
areg logbw hhithreeyearavg logh1bs [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea3a_col1.ster, replace

areg logbw hhithreeyearavg logh1bs i.year [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea3a_col2.ster, replace

areg logbw hhithreeyearavg logh1bs i.occ2 [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea3a_col3.ster, replace

areg logbw hhithreeyearavg logh1bs i.year i.occ2 [fw=fw_h1bs], absorb(company) vce(cluster cz90)
est save $sters/tablea3a_col4.ster, replace

* Panel B: Random Effects (Pooled OLS)
reg logbw hhithreeyearavg logh1bs [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea3b_col1.ster, replace

reg logbw hhithreeyearavg logh1bs i.year [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea3b_col2.ster, replace

reg logbw hhithreeyearavg logh1bs i.occ2 [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea3b_col3.ster, replace

reg logbw hhithreeyearavg logh1bs i.year i.occ2 [fw=fw_h1bs], vce(cluster cz90)
est save $sters/tablea3b_col4.ster, replace

di "Table A.3: 8 .ster files saved"

*===============================================================================
* TABLE A.4: UNWEIGHTED LOG(BACK WAGES)
* 7 columns matching Table 3 structure
*===============================================================================

di "===== TABLE A.4: UNWEIGHTED LOG BACK WAGES (7 columns) ====="

* Column 1: CZ+Occ+Year FE
reg logbw hhithreeyearavg logh1bs i.year i.occ2 i.cz90, vce(cluster cz90)
est save $sters/tablea4_col1.ster, replace

* Column 2: with HHI×Sub interaction
reg logbw hhithreeyearavg c.hhithreeyearavg#i.subcontractor i.subcontractor logh1bs i.year i.occ2 i.cz90, vce(cluster cz90)
est save $sters/tablea4_col2.ster, replace

* Column 3: Firm FE
areg logbw hhithreeyearavg logh1bs i.year i.occ2, absorb(company) vce(cluster cz90)
est save $sters/tablea4_col3.ster, replace

* Columns 4-5: Lead Firms
areg logbw hhithreeyearavg logh1bs i.occ2 if subcontractor==0, absorb(company) vce(cluster cz90)
est save $sters/tablea4_col4.ster, replace

areg logbw hhithreeyearavg logh1bs i.year i.occ2 if subcontractor==0, absorb(company) vce(cluster cz90)
est save $sters/tablea4_col5.ster, replace

* Columns 6-7: Subcontractors
areg logbw hhithreeyearavg logh1bs i.occ2 if subcontractor==1, absorb(company) vce(cluster cz90)
est save $sters/tablea4_col6.ster, replace

areg logbw hhithreeyearavg logh1bs i.year i.occ2 if subcontractor==1, absorb(company) vce(cluster cz90)
est save $sters/tablea4_col7.ster, replace

di "Table A.4: 7 .ster files saved"

*===============================================================================
* TABLE A.5: LOG(BACK WAGES / PROMISED WAGES) - FIRM FE AND RE
*===============================================================================

di "===== TABLE A.5: LOG BW/PW (8 columns) ====="

* Panel A: Within Firm OLS (Firm FE with robust SE)
areg logbwpw hhithreeyearavg logh1bs, absorb(company) vce(robust)
est save $sters/tablea5a_col1.ster, replace

areg logbwpw hhithreeyearavg logh1bs i.year, absorb(company) vce(robust)
est save $sters/tablea5a_col2.ster, replace

areg logbwpw hhithreeyearavg logh1bs i.occ2, absorb(company) vce(robust)
est save $sters/tablea5a_col3.ster, replace

areg logbwpw hhithreeyearavg logh1bs i.year i.occ2, absorb(company) vce(robust)
est save $sters/tablea5a_col4.ster, replace

* Panel B: Between Firm OLS (xtreg RE)
xtreg logbwpw hhithreeyearavg logh1bs, re
est save $sters/tablea5b_col1.ster, replace

xtreg logbwpw hhithreeyearavg logh1bs i.year, re
est save $sters/tablea5b_col2.ster, replace

xtreg logbwpw hhithreeyearavg logh1bs i.occ2, re
est save $sters/tablea5b_col3.ster, replace

xtreg logbwpw hhithreeyearavg logh1bs i.year i.occ2, re
est save $sters/tablea5b_col4.ster, replace

di "Table A.5: 8 .ster files saved"

*===============================================================================
* TABLE A.6: LOG(BW/PW) WITH HHI×SUBCONTRACTOR (8 columns)
* Uses _rmcoll for CZ FE specifications to match original
*===============================================================================

di "===== TABLE A.6: LOG BW/PW WITH HHI×SUB (8 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3

local ivs "hhithreeyearavg c.hhithreeyearavg##i.subcontractor"

forvalues i = 1/8 {
    local fes ""
    if `i' == 2 | `i' >= 6 local fes "`fes' i.year"
    if `i' == 3 | `i' == 5 | `i' == 6 | `i' == 8 local fes "`fes' i.occ2"
    if `i' == 4 | `i' == 5 | `i' == 7 | `i' == 8 local fes "`fes' i.cz90"

    * Columns 2,6,7,8 use clustered SEs; columns 1,3,4,5 use robust SEs
    if inlist(`i', 2, 6, 7, 8) {
        local vce_opt "vce(cluster cz90)"
    }
    else {
        local vce_opt "vce(robust)"
    }

    local rhs "`ivs' `fes'"
    _rmcoll `rhs' if logbwpw > 0, expand
    reg logbwpw `r(varlist)' logh1bs, `vce_opt'
    est save $sters/tablea6_col`i'.ster, replace
}

di "Table A.6: 8 .ster files saved"

*===============================================================================
* TABLE A.7: LOG(VIOLATIONS) AT OCC-CZ-YEAR LEVEL (8 columns)
* Uses category_set == 2
*===============================================================================

di "===== TABLE A.7: OCC-CZ-YEAR LEVEL (8 columns) ====="

use "$data/master_db.dta", clear
count if category_set == 2
if r(N) > 0 {
    keep if category_set == 2

    local ivs "hhithreeyearavg"

    forvalues i = 1/8 {
        local fes ""
        if `i' == 2 | `i' >= 6 local fes "`fes' i.year"
        if `i' == 3 | `i' == 5 | `i' == 6 | `i' == 8 local fes "`fes' i.occ2"
        if `i' == 4 | `i' == 5 | `i' == 7 | `i' == 8 local fes "`fes' i.cz90"

        * Columns 2,6,7,8 use clustered SEs; columns 1,3,4,5 use robust SEs
        if inlist(`i', 2, 6, 7, 8) {
            local vce_opt "vce(cluster cz90)"
        }
        else {
            local vce_opt "vce(robust)"
        }

        local rhs "`ivs' `fes'"
        _rmcoll `rhs' if logviol > 0, expand
        reg logviol `r(varlist)' logh1bs, `vce_opt'
        est save $sters/tablea7_col`i'.ster, replace
    }
    di "Table A.7: 8 .ster files saved"
}
else {
    di "SKIPPING Table A.7: No category_set==2 data"
}

*===============================================================================
* TABLE A.8: LOG(VIOLATIONS) AT INDUSTRY-CZ-YEAR LEVEL (8 columns)
* Uses category_set == 1
*===============================================================================

di "===== TABLE A.8: INDUSTRY-CZ-YEAR LEVEL (8 columns) ====="

use "$data/master_db.dta", clear
count if category_set == 1
if r(N) > 0 {
    keep if category_set == 1

    local ivs "hhithreeyearavg"

    forvalues i = 1/8 {
        local fes ""
        if `i' == 2 | `i' >= 6 local fes "`fes' i.year"
        if `i' == 3 | `i' == 5 | `i' == 6 | `i' == 8 local fes "`fes' i.ind"
        if `i' == 4 | `i' == 5 | `i' == 7 | `i' == 8 local fes "`fes' i.cz90"

        * Columns 2,6,7,8 use clustered SEs; columns 1,3,4,5 use robust SEs
        if inlist(`i', 2, 6, 7, 8) {
            local vce_opt "vce(cluster cz90)"
        }
        else {
            local vce_opt "vce(robust)"
        }

        local rhs "`ivs' `fes'"
        _rmcoll `rhs' if logviol > 0, expand
        reg logviol `r(varlist)' logh1bs, `vce_opt'
        est save $sters/tablea8_col`i'.ster, replace
    }
    di "Table A.8: 8 .ster files saved"
}
else {
    di "SKIPPING Table A.8: No category_set==1 data"
}

*===============================================================================
* TABLE A.9: UNWEIGHTED LOG(VIOLATIONS) - FIRM FE AND RE
*===============================================================================

di "===== TABLE A.9: UNWEIGHTED LOG VIOLATIONS (8 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3
egen company = group(name)
xtset company

* Panel A: Firm Fixed Effects
areg logviol hhithreeyearavg logh1bs, absorb(company) vce(cluster cz90)
est save $sters/tablea9a_col1.ster, replace

areg logviol hhithreeyearavg logh1bs i.year, absorb(company) vce(cluster cz90)
est save $sters/tablea9a_col2.ster, replace

areg logviol hhithreeyearavg logh1bs i.occ2, absorb(company) vce(cluster cz90)
est save $sters/tablea9a_col3.ster, replace

areg logviol hhithreeyearavg logh1bs i.year i.occ2, absorb(company) vce(cluster cz90)
est save $sters/tablea9a_col4.ster, replace

* Panel B: Random Effects (Pooled OLS)
reg logviol hhithreeyearavg logh1bs, vce(cluster cz90)
est save $sters/tablea9b_col1.ster, replace

reg logviol hhithreeyearavg logh1bs i.year, vce(cluster cz90)
est save $sters/tablea9b_col2.ster, replace

reg logviol hhithreeyearavg logh1bs i.occ2, vce(cluster cz90)
est save $sters/tablea9b_col3.ster, replace

reg logviol hhithreeyearavg logh1bs i.year i.occ2 i.cz90, vce(cluster cz90)
est save $sters/tablea9b_col4.ster, replace

di "Table A.9: 8 .ster files saved"

*===============================================================================
* TABLE A.10: LOG(VIOLATIONS) WITH HHI×SUBCONTRACTOR (8 columns)
*===============================================================================

di "===== TABLE A.10: LOG VIOLATIONS WITH HHI×SUB (8 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3

local ivs "hhithreeyearavg c.hhithreeyearavg##i.subcontractor"

forvalues i = 1/8 {
    local fes ""
    if `i' == 2 | `i' >= 6 local fes "`fes' i.year"
    if `i' == 3 | `i' == 5 | `i' == 6 | `i' == 8 local fes "`fes' i.occ2"
    if `i' == 4 | `i' == 5 | `i' == 7 | `i' == 8 local fes "`fes' i.cz90"

    * Columns 2,6,7,8 use clustered SEs; columns 1,3,4,5 use robust SEs
    if inlist(`i', 2, 6, 7, 8) {
        local vce_opt "vce(cluster cz90)"
    }
    else {
        local vce_opt "vce(robust)"
    }

    local rhs "`ivs' `fes'"
    _rmcoll `rhs' if logviol > 0, expand
    reg logviol `r(varlist)' logh1bs, `vce_opt'
    est save $sters/tablea10_col`i'.ster, replace
}

di "Table A.10: 8 .ster files saved"

*===============================================================================
* TABLE A.11: UNWEIGHTED LOG(BACK WAGES) - FIRM FE AND RE
*===============================================================================

di "===== TABLE A.11: UNWEIGHTED LOG BACK WAGES (8 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3
egen company = group(name)
xtset company

* Panel A: Firm Fixed Effects
areg logbw hhithreeyearavg logh1bs, absorb(company) vce(cluster cz90)
est save $sters/tablea11a_col1.ster, replace

areg logbw hhithreeyearavg logh1bs i.year, absorb(company) vce(cluster cz90)
est save $sters/tablea11a_col2.ster, replace

areg logbw hhithreeyearavg logh1bs i.occ2, absorb(company) vce(cluster cz90)
est save $sters/tablea11a_col3.ster, replace

areg logbw hhithreeyearavg logh1bs i.year i.occ2, absorb(company) vce(cluster cz90)
est save $sters/tablea11a_col4.ster, replace

* Panel B: Random Effects (with CZ FE)
* Uses _rmcoll to remove collinear CZ dummies (same as original code)
local ivs "hhithreeyearavg logh1bs"

* Column 1: CZ FE only
local rhs1 "`ivs' i.cz90"
_rmcoll `rhs1' if logbw > 0, expand
reg logbw `r(varlist)', vce(cluster cz90)
est save $sters/tablea11b_col1.ster, replace

* Column 2: Year + CZ FE
local rhs2 "`ivs' i.year i.cz90"
_rmcoll `rhs2' if logbw > 0, expand
reg logbw `r(varlist)', vce(cluster cz90)
est save $sters/tablea11b_col2.ster, replace

* Column 3: Occ + CZ FE
local rhs3 "`ivs' i.occ2 i.cz90"
_rmcoll `rhs3' if logbw > 0, expand
reg logbw `r(varlist)', vce(cluster cz90)
est save $sters/tablea11b_col3.ster, replace

* Column 4: Year + Occ + CZ FE
local rhs4 "`ivs' i.year i.occ2 i.cz90"
_rmcoll `rhs4' if logbw > 0, expand
reg logbw `r(varlist)', vce(cluster cz90)
est save $sters/tablea11b_col4.ster, replace

di "Table A.11: 8 .ster files saved"

*===============================================================================
* TABLE A.12: LOG(BACK WAGES) WITH HHI×SUBCONTRACTOR (8 columns)
*===============================================================================

di "===== TABLE A.12: LOG BACK WAGES WITH HHI×SUB (8 columns) ====="

use "$data/master_db.dta", clear
keep if category_set == 3

local ivs "hhithreeyearavg c.hhithreeyearavg##i.subcontractor"

forvalues i = 1/8 {
    local fes ""
    if `i' == 2 | `i' >= 6 local fes "`fes' i.year"
    if `i' == 3 | `i' == 5 | `i' == 6 | `i' == 8 local fes "`fes' i.occ2"
    if `i' == 4 | `i' == 5 | `i' == 7 | `i' == 8 local fes "`fes' i.cz90"

    * Columns 2,6,7,8 use clustered SEs; columns 1,3,4,5 use robust SEs
    if inlist(`i', 2, 6, 7, 8) {
        local vce_opt "vce(cluster cz90)"
    }
    else {
        local vce_opt "vce(robust)"
    }

    local rhs "`ivs' `fes'"
    _rmcoll `rhs' if logbw > 0, expand
    reg logbw `r(varlist)' logh1bs, `vce_opt'
    est save $sters/tablea12_col`i'.ster, replace
}

di "Table A.12: 8 .ster files saved"

*===============================================================================
* TABLES 5 AND 6: PROBIT MODELS WITH MARGINAL EFFECTS
* Source: obes_dos/obes_firm_quits.do
*
* These tables require probit models with margins commands.
* Since margins, post replaces the estimation, we generate custom LaTeX output
*
* Table 5: Marginal Effects (Change in Probability)
*   Panel A: Probability a Firm Ever Violates (company-level)
*   Panel B: Probability a Firm Violates at time t (panel)
*
* Table 6: Probabilities at Critical Values
*   Panel A: Probability Ever Violates at HHI=0 vs HHI=1
*   Panel B: Probability Violates at t at HHI=0 vs HHI=1
*
* NOTE: Paper shows only 2 columns per table:
*   (1) Unweighted (with Log(H-1Bs) control)
*   (2) Population Weighted (with Log(H-1Bs) control)
*===============================================================================

di "===== TABLES 5 AND 6: PROBIT MODELS WITH MARGINAL EFFECTS ====="

use "$data/master_db.dta", clear
keep if category_set == 3

egen company = group(name)
cap drop fw_h1bs
gen fw_h1bs = round(nbr_h1bs)

* Collapse to firm-year level for panel probit (matching original obes_firm_quits.do)
collapse (rawsum) nbr_h1bs (rawsum) viol (mean) hhithreeyearavg subcontractor [fw=fw_h1bs], by(company year)

gen fw_h1bs = round(nbr_h1bs)
gen logh1bs = log(nbr_h1bs)

xtset company year

replace viol = round(viol)
replace viol = 1 if viol != . & viol > 0

gen run = .
bysort company: replace run = cond(L.run == ., 1, L.run + 1)
bysort company: egen maxrun = max(run)
bysort company: egen everviol = max(viol)

drop if maxrun < 3

tsfill, full

tsspell, f(L.maxrun == .)

* Set variables to missing for non-primary spells (matching original)
bysort company _spell: egen maxspell = max(run)
sort company year
foreach var in nbr_h1bs hhithreeyearavg subcontractor {
    replace `var' = . if maxspell != maxrun
}

* Create totpop for later
bysort company: egen totpop = total(nbr_h1bs)
replace totpop = round(totpop)

estimates clear

*===============================================================================
* PANEL B: Panel-level analysis (Probability a Firm Violates at time t)
*===============================================================================

di "Running Panel B regressions (panel-level probit)..."

* Store sample sizes for Panel B
qui count if !missing(viol, L.hhithreeyearavg, subcontractor, L.logh1bs)
local N_panelB_unwt = r(N)

qui count if !missing(viol, L.hhithreeyearavg, subcontractor, L.logh1bs, L.fw_h1bs) & L.fw_h1bs > 0
local N_panelB_wt_raw = r(N)

* Calculate weighted N (sum of weights)
qui sum L.fw_h1bs if !missing(viol, L.hhithreeyearavg, subcontractor, L.logh1bs, L.fw_h1bs) & L.fw_h1bs > 0
local N_panelB_wt = r(sum)

*--- Table 5 Panel B: Marginal effects ---
* Column 1: Unweighted with Log(H-1Bs) control
qui probit viol L.hhithreeyearavg i.subcontractor i.year L.logh1bs, vce(robust)
margins, dydx(L.hhithreeyearavg 1.subcontractor) post
local t5b_hhi_unwt = _b[L.hhithreeyearavg]
local t5b_hhi_se_unwt = _se[L.hhithreeyearavg]
local t5b_sub_unwt = _b[1.subcontractor]
local t5b_sub_se_unwt = _se[1.subcontractor]

* Column 2: Population Weighted with Log(H-1Bs) control
qui probit viol L.hhithreeyearavg i.subcontractor i.year L.logh1bs [fw=L.fw_h1bs], vce(robust)
margins, dydx(L.hhithreeyearavg 1.subcontractor) post
local t5b_hhi_wt = _b[L.hhithreeyearavg]
local t5b_hhi_se_wt = _se[L.hhithreeyearavg]
local t5b_sub_wt = _b[1.subcontractor]
local t5b_sub_se_wt = _se[1.subcontractor]

*--- Table 6 Panel B: Probabilities at critical values ---
* Column 1: Unweighted with Log(H-1Bs) control
* margins at() order: (HHI=0,SUB=0), (HHI=0,SUB=1), (HHI=1,SUB=0), (HHI=1,SUB=1)
* Paper row order: (SUB=0,HHI=0), (SUB=1,HHI=0), (SUB=0,HHI=1), (SUB=1,HHI=1)
qui probit viol L.hhithreeyearavg i.subcontractor i.year L.logh1bs, vce(robust)
margins, at(L.hhithreeyearavg=(0 1) subcontractor=(0 1)) vsquish post
local t6b_s0h0_unwt = _b[1._at]  // SUB=0, HHI=0
local t6b_s1h0_unwt = _b[2._at]  // SUB=1, HHI=0 (margins: HHI=0, SUB=1)
local t6b_s0h1_unwt = _b[3._at]  // SUB=0, HHI=1 (margins: HHI=1, SUB=0)
local t6b_s1h1_unwt = _b[4._at]  // SUB=1, HHI=1

* Column 2: Population Weighted with Log(H-1Bs) control
qui probit viol L.hhithreeyearavg i.subcontractor i.year L.logh1bs [fw=L.fw_h1bs], vce(robust)
margins, at(L.hhithreeyearavg=(0 1) subcontractor=(0 1)) vsquish post
local t6b_s0h0_wt = _b[1._at]  // SUB=0, HHI=0
local t6b_s1h0_wt = _b[2._at]  // SUB=1, HHI=0
local t6b_s0h1_wt = _b[3._at]  // SUB=0, HHI=1
local t6b_s1h1_wt = _b[4._at]  // SUB=1, HHI=1

di "Panel B complete. N(unweighted)=`N_panelB_unwt', N(weighted)=`N_panelB_wt'"

*===============================================================================
* PANEL A: Company-level analysis (Probability a Firm Ever Violates)
*===============================================================================

* Collapse to company level
collapse (rawsum) viol (rawsum) nbr_h1bs (mean) hhithreeyearavg subcontractor [fw=fw_h1bs], by(company)

gen logh1bs = log(nbr_h1bs)
replace nbr_h1bs = round(nbr_h1bs)
replace viol = 1 if viol > 1

di "Running Panel A regressions (company-level probit)..."

* Store sample sizes for Panel A
qui count if !missing(viol, hhithreeyearavg, subcontractor, logh1bs)
local N_panelA_unwt = r(N)

qui sum nbr_h1bs if !missing(viol, hhithreeyearavg, subcontractor, logh1bs)
local N_panelA_wt = r(sum)

*--- Table 5 Panel A: Marginal effects ---
* Column 1: Unweighted with Log(H-1Bs) control
qui probit viol hhithreeyearavg i.subcontractor logh1bs, vce(robust)
margins, dydx(hhithreeyearavg 1.subcontractor) post
local t5a_hhi_unwt = _b[hhithreeyearavg]
local t5a_hhi_se_unwt = _se[hhithreeyearavg]
local t5a_sub_unwt = _b[1.subcontractor]
local t5a_sub_se_unwt = _se[1.subcontractor]

* Column 2: Population Weighted with Log(H-1Bs) control
qui probit viol hhithreeyearavg i.subcontractor logh1bs [fw=nbr_h1bs], vce(robust)
margins, dydx(hhithreeyearavg 1.subcontractor) post
local t5a_hhi_wt = _b[hhithreeyearavg]
local t5a_hhi_se_wt = _se[hhithreeyearavg]
local t5a_sub_wt = _b[1.subcontractor]
local t5a_sub_se_wt = _se[1.subcontractor]

*--- Table 6 Panel A: Probabilities at critical values ---
* Column 1: Unweighted with Log(H-1Bs) control
* margins at() order: (HHI=0,SUB=0), (HHI=0,SUB=1), (HHI=1,SUB=0), (HHI=1,SUB=1)
* Paper row order: (SUB=0,HHI=0), (SUB=1,HHI=0), (SUB=0,HHI=1), (SUB=1,HHI=1)
qui probit viol hhithreeyearavg i.subcontractor logh1bs, vce(robust)
margins, at(hhithreeyearavg=(0 1) subcontractor=(0 1)) vsquish post
local t6a_s0h0_unwt = _b[1._at]  // SUB=0, HHI=0
local t6a_s1h0_unwt = _b[2._at]  // SUB=1, HHI=0 (margins: HHI=0, SUB=1)
local t6a_s0h1_unwt = _b[3._at]  // SUB=0, HHI=1 (margins: HHI=1, SUB=0)
local t6a_s1h1_unwt = _b[4._at]  // SUB=1, HHI=1

* Column 2: Population Weighted with Log(H-1Bs) control
qui probit viol hhithreeyearavg i.subcontractor logh1bs [fw=nbr_h1bs], vce(robust)
margins, at(hhithreeyearavg=(0 1) subcontractor=(0 1)) vsquish post
local t6a_s0h0_wt = _b[1._at]  // SUB=0, HHI=0
local t6a_s1h0_wt = _b[2._at]  // SUB=1, HHI=0
local t6a_s0h1_wt = _b[3._at]  // SUB=0, HHI=1
local t6a_s1h1_wt = _b[4._at]  // SUB=1, HHI=1

di "Panel A complete. N(unweighted)=`N_panelA_unwt', N(weighted)=`N_panelA_wt'"

*===============================================================================
* Generate formatted LaTeX tables matching the paper
*===============================================================================

* Helper function to add significance stars
capture program drop addstars
program define addstars, rclass
    args coef se
    local tstat = abs(`coef'/`se')
    if `tstat' >= 2.576 {
        return local stars "***"
    }
    else if `tstat' >= 1.96 {
        return local stars "**"
    }
    else if `tstat' >= 1.645 {
        return local stars "*"
    }
    else {
        return local stars ""
    }
end

*--- TABLE 5: Marginal Effects ---
di "Writing Table 5 (Marginal Effects)..."

* Format coefficients with stars for Table 5 Panel A
addstars `t5a_hhi_unwt' `t5a_hhi_se_unwt'
local t5a_hhi_unwt_stars "`r(stars)'"
addstars `t5a_hhi_wt' `t5a_hhi_se_wt'
local t5a_hhi_wt_stars "`r(stars)'"
addstars `t5a_sub_unwt' `t5a_sub_se_unwt'
local t5a_sub_unwt_stars "`r(stars)'"
addstars `t5a_sub_wt' `t5a_sub_se_wt'
local t5a_sub_wt_stars "`r(stars)'"

* Format coefficients with stars for Table 5 Panel B
addstars `t5b_hhi_unwt' `t5b_hhi_se_unwt'
local t5b_hhi_unwt_stars "`r(stars)'"
addstars `t5b_hhi_wt' `t5b_hhi_se_wt'
local t5b_hhi_wt_stars "`r(stars)'"
addstars `t5b_sub_unwt' `t5b_sub_se_unwt'
local t5b_sub_unwt_stars "`r(stars)'"
addstars `t5b_sub_wt' `t5b_sub_se_wt'
local t5b_sub_wt_stars "`r(stars)'"

* Write Table 5 Panel A
file open t5a using "$tables/table5_panelA.tex", write replace
file write t5a "\begin{table}[H]" _n
file write t5a "\centering" _n
file write t5a "\caption{Marginal Effects: Changes in Probability}" _n
file write t5a "\begin{tabular}{lcc}" _n
file write t5a "\hline \hline" _n
file write t5a " & \multicolumn{2}{c}{Panel \textit{A}: Change in Probability a Firm Ever Violates} \\\\" _n
file write t5a " & (1) & (2) \\\\" _n
file write t5a " & Unweighted & Population Weighted \\\\" _n
file write t5a "\hline" _n
file write t5a "\$HHI_f\$ & " %9.4g (`t5a_hhi_unwt') "`t5a_hhi_unwt_stars' & " %9.4g (`t5a_hhi_wt') "`t5a_hhi_wt_stars' \\\\" _n
file write t5a " & (" %9.4g (`t5a_hhi_se_unwt') ") & (" %9.4g (`t5a_hhi_se_wt') ") \\\\" _n
file write t5a "\$SUB_f\$ & " %9.4g (`t5a_sub_unwt') "`t5a_sub_unwt_stars' & " %9.4g (`t5a_sub_wt') "`t5a_sub_wt_stars' \\\\" _n
file write t5a " & (" %9.4g (`t5a_sub_se_unwt') ") & (" %9.4g (`t5a_sub_se_wt') ") \\\\" _n
file write t5a "N & " %12.0fc (`N_panelA_unwt') " & " %12.0fc (`N_panelA_wt') " \\\\" _n
file write t5a "\hline \hline" _n
file write t5a "\end{tabular}" _n
file write t5a "\end{table}" _n
file close t5a

* Write Table 5 Panel B
file open t5b using "$tables/table5_panelB.tex", write replace
file write t5b "\begin{table}[H]" _n
file write t5b "\centering" _n
file write t5b "\begin{tabular}{lcc}" _n
file write t5b "\hline" _n
file write t5b " & \multicolumn{2}{c}{Panel \textit{B}: Change in Probability a Firm Violates at \$t\$} \\\\" _n
file write t5b " & (1) & (2) \\\\" _n
file write t5b " & Unweighted & Population Weighted \\\\" _n
file write t5b "\hline" _n
file write t5b "\$HHI_{f,t-1}\$ & " %9.4g (`t5b_hhi_unwt') "`t5b_hhi_unwt_stars' & " %9.4g (`t5b_hhi_wt') "`t5b_hhi_wt_stars' \\\\" _n
file write t5b " & (" %9.4g (`t5b_hhi_se_unwt') ") & (" %9.4g (`t5b_hhi_se_wt') ") \\\\" _n
file write t5b "\$SUB_f\$ & " %9.4g (`t5b_sub_unwt') "`t5b_sub_unwt_stars' & " %9.4g (`t5b_sub_wt') "`t5b_sub_wt_stars' \\\\" _n
file write t5b " & (" %9.4g (`t5b_sub_se_unwt') ") & (" %9.4g (`t5b_sub_se_wt') ") \\\\" _n
file write t5b "N & " %12.0fc (`N_panelB_unwt') " & " %12.0fc (`N_panelB_wt') " \\\\" _n
file write t5b "\hline \hline" _n
file write t5b "\end{tabular}" _n
file write t5b "\end{table}" _n
file close t5b

di "Table 5 saved to: $tables/table5_panelA.tex and table5_panelB.tex"

*--- TABLE 6: Probabilities at Critical Values ---
di "Writing Table 6 (Probabilities at Critical Values)..."

* Write Table 6 Panel A
file open t6a using "$tables/table6_panelA.tex", write replace
file write t6a "\begin{table}[H]" _n
file write t6a "\centering" _n
file write t6a "\caption{Marginal Effects: Probabilities at Critical Values}" _n
file write t6a "\begin{tabular}{lcc}" _n
file write t6a "\hline \hline" _n
file write t6a " & \multicolumn{2}{c}{Panel \textit{A}: Probability a Firm Ever Violates} \\\\" _n
file write t6a " & (1) & (2) \\\\" _n
file write t6a " & Unweighted & Population Weighted \\\\" _n
file write t6a "\hline" _n
file write t6a "\$SUB_f = 0, \overline{HHI}_f = 0\$ & " %9.4g (`t6a_s0h0_unwt') " & " %9.4g (`t6a_s0h0_wt') " \\\\" _n
file write t6a "\$SUB_f = 1, \overline{HHI}_f = 0\$ & " %9.4g (`t6a_s1h0_unwt') " & " %9.4g (`t6a_s1h0_wt') " \\\\" _n
file write t6a "\$SUB_f = 0, \overline{HHI}_f = 1\$ & " %9.4g (`t6a_s0h1_unwt') " & " %9.4g (`t6a_s0h1_wt') " \\\\" _n
file write t6a "\$SUB_f = 1, \overline{HHI}_f = 1\$ & " %9.4g (`t6a_s1h1_unwt') " & " %9.4g (`t6a_s1h1_wt') " \\\\" _n
file write t6a "N & " %12.0fc (`N_panelA_unwt') " & " %12.0fc (`N_panelA_wt') " \\\\" _n
file write t6a "\hline \hline" _n
file write t6a "\end{tabular}" _n
file write t6a "\end{table}" _n
file close t6a

* Write Table 6 Panel B
file open t6b using "$tables/table6_panelB.tex", write replace
file write t6b "\begin{table}[H]" _n
file write t6b "\centering" _n
file write t6b "\begin{tabular}{lcc}" _n
file write t6b "\hline" _n
file write t6b " & \multicolumn{2}{c}{Panel \textit{B}: Probability a Firm Violates at \$t\$} \\\\" _n
file write t6b " & (1) & (2) \\\\" _n
file write t6b " & Unweighted & Population Weighted \\\\" _n
file write t6b "\hline" _n
file write t6b "\$SUB_f = 0, \overline{HHI}_{f,t-1} = 0\$ & " %9.4g (`t6b_s0h0_unwt') " & " %9.4g (`t6b_s0h0_wt') " \\\\" _n
file write t6b "\$SUB_f = 1, \overline{HHI}_{f,t-1} = 0\$ & " %9.4g (`t6b_s1h0_unwt') " & " %9.4g (`t6b_s1h0_wt') " \\\\" _n
file write t6b "\$SUB_f = 0, \overline{HHI}_{f,t-1} = 1\$ & " %9.4g (`t6b_s0h1_unwt') " & " %9.4g (`t6b_s0h1_wt') " \\\\" _n
file write t6b "\$SUB_f = 1, \overline{HHI}_{f,t-1} = 1\$ & " %9.4g (`t6b_s1h1_unwt') " & " %9.4g (`t6b_s1h1_wt') " \\\\" _n
file write t6b "N & " %12.0fc (`N_panelB_unwt') " & " %12.0fc (`N_panelB_wt') " \\\\" _n
file write t6b "\hline \hline" _n
file write t6b "\end{tabular}" _n
file write t6b "\end{table}" _n
file close t6b

di "Table 6 saved to: $tables/table6_panelA.tex and table6_panelB.tex"
di "Tables 5 and 6 complete"

*===============================================================================
* SUMMARY
*===============================================================================

timer off 1
qui timer list 1
local elapsed = r(t1)/60

di ""
di "==============================================================================="
di "ALL REGRESSIONS COMPLETE"
di "==============================================================================="
di ""
di "Total time: `elapsed' minutes"
di ""
di ".ster files saved to: $sters/"
di ""
di "Summary of .ster files created:"
di "  - Table 2: table2_col1-6.ster (6 files)"
di "  - Table 3: table3_col1-7.ster (7 files)"
di "  - Table 4: table4_col1-8.ster (8 files)"
di "  - Table A.1: SKIPPED (use pre-computed)"
di "  - Table A.2: tablea2a_col1-4.ster, tablea2b_col1-4.ster (8 files)"
di "  - Table A.3: tablea3a_col1-4.ster, tablea3b_col1-4.ster (8 files)"
di "  - Table A.4: tablea4_col1-7.ster (7 files)"
di "  - Table A.5: tablea5a_col1-4.ster, tablea5b_col1-4.ster (8 files)"
di "  - Table A.6: tablea6_col1-8.ster (8 files)"
di "  - Table A.7: tablea7_col1-8.ster (8 files)"
di "  - Table A.8: tablea8_col1-8.ster (8 files)"
di "  - Table A.9: tablea9a_col1-4.ster, tablea9b_col1-4.ster (8 files)"
di "  - Table A.10: tablea10_col1-8.ster (8 files)"
di "  - Table A.11: tablea11a_col1-4.ster, tablea11b_col1-4.ster (8 files)"
di "  - Table A.12: tablea12_col1-8.ster (8 files)"
di ""
di "NOTE: Tables 1, 5, 6 are generated directly in 01_tables.do (no .ster files)"
di ""

* End of regressions file
