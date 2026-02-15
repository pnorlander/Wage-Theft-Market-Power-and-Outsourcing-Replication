*===============================================================================
* MASTER REPLICATION FILE
* Paper: Wage Theft, Market Power, and Outsourcing: The Case of H-1B Workers
*
* This file orchestrates the full replication of all tables and figures.
*
* REPLICATION OPTIONS:
*   Option A (Default): Use pre-computed .ster files for fast table generation
*   Option B (Full): Run all regressions from scratch (set run_regressions = 1)
*
* To run full replication from scratch:
*   1. Set local run_regressions = 1 below
*   2. WARNING: This may take several hours (negative binomial with FE is slow)
*
* TABLES GENERATED:
*   Main: Table 1 (Descriptives), Table 2 (Wages), Table 3 (Log Violations),
*         Table 4 (IV), Table 5 (Marginal Effects), Table 6 (Probabilities)
*   Appendix: Tables A.1-A.12
*
* FIGURES GENERATED:
*   Figure 1 (Network Graph - pre-generated, see PRECOMPUTED_FILES.md)
*   Figure 2a (Wage Density), Figure 2b (Probability vs Wage)
*   Figure 3 (HHI Bar Chart), Figure 4 (Violations Intensity), Figure 5 (Probabilities)
*===============================================================================

clear all
set more off
set matsize 10000

*-------------------------------------------------------------------------------
* REPLICATION OPTIONS
*-------------------------------------------------------------------------------
* Set to 1 to run all regressions from scratch
* Set to 0 to use pre-computed .ster files (default, fast)
*-------------------------------------------------------------------------------
local run_regressions = 0

*-------------------------------------------------------------------------------
* SET PATHS - User should modify $root to match their system
*-------------------------------------------------------------------------------
* Option 1: Set root to the replication_package directory
global root "."

* Option 2: If running from parent directory, uncomment below:
* global root "replication_package"

* Derived paths (do not modify)
global data "$root/data"
global code "$root/code"
global output "$root/output"
global tables "$output/tables"
global figures "$output/figures"
global sters "$root/sters"

*-------------------------------------------------------------------------------
* INSTALL REQUIRED PACKAGES (uncomment if not installed)
*-------------------------------------------------------------------------------
* ssc install estout, replace
* ssc install reghdfe, replace
* ssc install ppmlhdfe, replace
* ssc install nwcommands, replace
* ssc install ivreg2, replace
* ssc install xtivreg2, replace

*-------------------------------------------------------------------------------
* START LOG
*-------------------------------------------------------------------------------
log using "$root/replication_log.txt", replace text

di "==============================================================================="
di "REPLICATION PACKAGE"
di "Paper: Wage Theft, Market Power, and Outsourcing: The Case of H-1B Workers"
di "Started: $S_DATE $S_TIME"
di "==============================================================================="
di ""

if `run_regressions' == 1 {
    di "MODE: Full replication (running all regressions)"
    di "WARNING: This may take several hours"
}
else {
    di "MODE: Using pre-computed .ster files (fast)"
    di "To run regressions from scratch, set run_regressions = 1 in 00_master.do"
}
di ""

*-------------------------------------------------------------------------------
* STEP 1: RUN REGRESSIONS (OPTIONAL - skip if using pre-computed .ster files)
*-------------------------------------------------------------------------------
if `run_regressions' == 1 {
    di "=============================================="
    di "STEP 1: Running all regressions..."
    di "=============================================="
    di ""
    do "$code/01a_run_regressions.do"
}
else {
    di "=============================================="
    di "STEP 1: Skipping regressions (using pre-computed .ster files)"
    di "=============================================="
    di ""
}

*-------------------------------------------------------------------------------
* STEP 2: GENERATE TABLES (from .ster files)
*-------------------------------------------------------------------------------
di "=============================================="
di "STEP 2: Generating tables..."
di "=============================================="
di ""
do "$code/01_tables.do"

*-------------------------------------------------------------------------------
* STEP 3: GENERATE FIGURES
*-------------------------------------------------------------------------------
di "=============================================="
di "STEP 3: Generating figures..."
di "=============================================="
di ""
do "$code/02_figures.do"

*-------------------------------------------------------------------------------
* SUMMARY
*-------------------------------------------------------------------------------
di ""
di "==============================================================================="
di "REPLICATION COMPLETE"
di "==============================================================================="
di ""
di "Output files saved to:"
di "  Tables: $tables"
di "  Figures: $figures"
di ""
di "Main Tables:"
di "  - Table 1: table1.tex (Descriptive Statistics)"
di "  - Table 2: table2.tex (Wages, Skill Levels)"
di "  - Table 3: table3.tex (Log Violations)"
di "  - Table 4: table4.tex (IV Regressions)"
di "  - Table 5: table5a.tex (Marginal Effects)"
di "  - Table 6: table5b_panelA.tex, table5b_panelB.tex (Probabilities)"
di ""
di "Appendix Tables:"
di "  - Table A.1: table_a1.tex (Negative Binomial)"
di "  - Table A.2: table_a2_panelA.tex, table_a2_panelB.tex"
di "  - Table A.3: table_a3_panelA.tex, table_a3_panelB.tex"
di "  - Table A.4: table_a4.tex"
di "  - Table A.5: table_a5_panelA.tex, table_a5_panelB.tex"
di "  - Table A.6: table_a6.tex"
di "  - Table A.7: table_a7.tex"
di "  - Table A.8: table_a8.tex"
di "  - Table A.9: table_a9_panelA.tex, table_a9_panelB.tex"
di "  - Table A.10: table_a10.tex"
di "  - Table A.11: table_a11_panelA.tex, table_a11_panelB.tex"
di "  - Table A.12: table_a12.tex"
di ""
di "Figures:"
di "  - Figure 1: fig1_network.pdf (pre-generated)"
di "  - Figure 2a: fig2a_kdensity.pdf"
di "  - Figure 2b: fig2b_prob_viol.pdf"
di "  - Figure 3: fig3_hhibar.pdf"
di "  - Figure 4: fig4_viol_intensity.pdf"
di "  - Figure 5: fig5_probs.pdf"
di ""
di "To compile LaTeX document:"
di "  cd $root"
di "  pdflatex replication_paper.tex"
di "  pdflatex replication_paper.tex"
di ""
di "Finished: $S_DATE $S_TIME"
di "==============================================================================="

log close

* End of master file
