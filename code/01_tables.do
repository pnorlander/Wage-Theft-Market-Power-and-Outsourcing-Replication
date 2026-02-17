	*===============================================================================
	* 01_tables.do
	* Generates Tables 1, 2, 3, 5, A.1-A.12
	*
	* Data files required:
	*   - data/master_db.dta (for Tables 1, 2, 5)
	*   - sters/.ster files (for Tables 3, A.1-A.12)
	*
	* PAPER TABLE MAPPING:
	*   Paper Table 1 = Descriptive Statistics
	*   Paper Table 2 = Wages, Skill Levels, Subcontractor Status (6 columns)
	*   Paper Table 3 = Log Violations (7 columns)
	*   Paper Table 5 = Marginal Effects (Panels A & B)
	*   Paper Table A.1 = Negative Binomial Regression
	*   Paper Table A.2 = Weighted Log Violations (Panel A: FE, Panel B: RE)
	*   Paper Table A.3 = Weighted Log Back Wages (Panel A: FE, Panel B: RE)
	*   Paper Table A.4 = Unweighted Log Back Wages (7 columns)
	*   Paper Table A.5 = Log Back Wages per Promised Wages (Panel A: FE, Panel B: RE)
	*   Paper Table A.6 = Log Back Wages/Promised Wages with HHI×Subcontractor (8 columns)
	*   Paper Table A.7 = Log Violations at Industry-CZ-Year level (8 columns)
	*   Paper Table A.8 = Log Violations at Occ-CZ-Year level (8 columns)
	*   Paper Table A.9 = Unweighted Log Violations (Panel A: FE, Panel B: RE)
	*   Paper Table A.10 = Log Violations with HHI×Subcontractor (8 columns)
	*   Paper Table A.11 = Unweighted Log Back Wages (Panel A: FE, Panel B: RE)
	*   Paper Table A.12 = Log Back Wages with HHI×Subcontractor (8 columns)
	*
	* STER File Naming Convention:
	*   - table2_col1.ster through table2_col6.ster (Wages, Skill Levels - Paper Table 2)
	*   - table3_col1.ster through table3_col7.ster (Log Violations - Paper Table 3)
	*   - tablea1_col1.ster through tablea1_col7.ster (Negative Binomial)
	*   - tablea2a_col1.ster through tablea2a_col4.ster (Weighted Log Violations - FE)
	*   - tablea2b_col1.ster through tablea2b_col4.ster (Weighted Log Violations - RE)
	*   - tablea3a_col1.ster through tablea3a_col4.ster (Weighted Log Back Wages - FE)
	*   - tablea3b_col1.ster through tablea3b_col4.ster (Weighted Log Back Wages - RE)
	*   - tablea4_col1.ster through tablea4_col7.ster (Unweighted Log Back Wages)
	*   - tablea5a_col1.ster through tablea5a_col4.ster (Log Back Wages/Promised Wages - FE)
	*   - tablea5b_col1.ster through tablea5b_col4.ster (Log Back Wages/Promised Wages - RE)
	*   - tablea6_col1.ster through tablea6_col8.ster (Log Back Wages/Promised Wages with HHI×Sub)
	*   - tablea7_col1.ster through tablea7_col8.ster (Log Violations at Industry-CZ-Year level)
	*   - tablea8_col1.ster through tablea8_col8.ster (Log Violations at Occ-CZ-Year level)
	*   - tablea9a_col1.ster through tablea9a_col4.ster (Unweighted Log Violations - FE)
	*   - tablea9b_col1.ster through tablea9b_col4.ster (Unweighted Log Violations - RE)
	*   - tablea10_col1.ster through tablea10_col8.ster (Log Violations with HHI×Sub)
	*   - tablea11a_col1.ster through tablea11a_col4.ster (Unweighted Log Back Wages - FE)
	*   - tablea11b_col1.ster through tablea11b_col4.ster (Unweighted Log Back Wages - RE)
	*   - tablea12_col1.ster through tablea12_col8.ster (Log Back Wages with HHI×Sub)
	*
	* Tables generated:
	*   - Table 1: Descriptive Statistics
	*   - Table 2: Wages, Skill Levels, and Subcontractor Status
	*   - Table 3: Effect of Labor Market Power on Log(Violations)
	*   - Table 5: Marginal Effects - Changes in Probability (PRE-GENERATED)
	*   - Table A.1: Negative Binomial Regression Results
	*   - Table A.2 Panel A: Weighted Regressions - Firm FE - Log(Violations)
	*   - Table A.2 Panel B: Weighted Regressions - Random Effects - Log(Violations)
	*   - Table A.3 Panel A: Weighted Regressions - Firm FE - Log(Back Wages)
	*   - Table A.3 Panel B: Weighted Regressions - Random Effects - Log(Back Wages)
	*   - Table A.4: Unweighted Regressions - Log(Back Wages)
	*   - Table A.5 Panel A: Firm FE - Log(Back Wages/Promised Wages)
	*   - Table A.5 Panel B: Random Effects - Log(Back Wages/Promised Wages)
	*   - Table A.6: Cell-level OLS with HHI×Subcontractor - Log(Back Wages/Promised Wages)
	*   - Table A.7: Cell-level OLS Log(Violations) at Industry-CZ-Year level
	*   - Table A.8: Cell-level OLS Log(Violations) at Occ-CZ-Year level
	*   - Table A.9 Panel A: Unweighted Firm FE - Log(Violations)
	*   - Table A.9 Panel B: Unweighted Random Effects - Log(Violations)
	*   - Table A.10: Cell-level OLS with HHI×Subcontractor - Log(Violations)
	*   - Table A.11 Panel A: Unweighted Firm FE - Log(Back Wages)
	*   - Table A.11 Panel B: Unweighted Random Effects - Log(Back Wages)
	*   - Table A.12: Cell-level OLS with HHI×Subcontractor - Log(Back Wages)
	*===============================================================================

	*-------------------------------------------------------------------------------
	* TABLE 1: DESCRIPTIVE STATISTICS
	*-------------------------------------------------------------------------------

	di "===== TABLE 1: DESCRIPTIVE STATISTICS ====="

	use "$data/master_db.dta", clear
	keep if category_set==3

	*--- PANEL A: Full Sample ---
	di "Panel A: Full Sample"
	estpost su viol logviol anyviol bw nbr_h1bs hhithreeyearavg subcontractor
	est sto panelA
	di "Full sample N = `e(N)'"

	*--- PANEL B: Fixed Effects Sample (firms with violations) ---
	di "Panel B: FE Sample"

	* Generate sample indicator for fixed effects estimation
	* (matches the sample used in firm FE regressions)
	egen company = group(name)
	replace viol=round(viol)
	xtset company
	qui xtnbreg viol hhithreeyearavg, fe
	gen sample=(e(sample)==1)

	estpost su viol logviol anyviol bw nbr_h1bs hhithreeyearavg subcontractor if sample==1
	est sto panelB
	di "FE sample N = `e(N)'"

	*--- Output Panel A ---
	esttab panelA using $tables/table1_panelA.tex, ///
	  cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3)) p50(fmt(3))") ///
	  title(Panel A: Full Sample) ///
	  substitute(mean Mean sd SD min Min max Max p50 Median) label replace

	*--- Output Panel B ---
	esttab panelB using $tables/table1_panelB.tex, ///
	  cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3)) p50(fmt(3))") ///
	  title(Panel B: Fixed Effects Sample) ///
	  substitute(mean Mean sd SD min Min max Max p50 Median) label replace

	*--- Combined Table 1 (both panels) ---
	* Create a combined LaTeX file with both panels
	file open table1 using "$tables/table1.tex", write replace
	file write table1 "\begin{table}[htbp]\centering" _n
	file write table1 "\caption{Descriptive Statistics}" _n
	file write table1 _n
	file write table1 "% Panel A: Full Sample" _n
	file write table1 "\textbf{Panel A: Full Sample}" _n
	file write table1 "\vspace{0.5em}" _n
	file write table1 _n
	file write table1 "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
	file write table1 "\begin{tabular}{l*{1}{ccccc}}" _n
	file write table1 "\hline\hline" _n
	file write table1 "                    &        Mean&          SD&         Min&         Max&      Median\\" _n
	file write table1 "\hline" _n

	* Get Panel A statistics (using detail option to get median via r(p50))
	qui su viol, detail
	file write table1 "Violations          &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su logviol, detail
	file write table1 "Violations Intensity          &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su anyviol, detail
	file write table1 "\% of Cells with any Violations&" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su bw, detail
	file write table1 "Back Wages          &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su nbr_h1bs, detail
	file write table1 "Number of H-1Bs     &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su hhithreeyearavg, detail
	file write table1 "HHI                 &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su subcontractor, detail
	file write table1 "Subcontractor       &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n

	qui count
	local panelA_N = r(N)
	file write table1 "\hline" _n
	file write table1 "Observations        &" %12.0fc (`panelA_N') "&            &            &            &            \\" _n
	file write table1 "\hline" _n
	file write table1 "\end{tabular}" _n
	file write table1 _n
	file write table1 "\vspace{1em}" _n
	file write table1 _n
	file write table1 "% Panel B: Fixed Effects Sample" _n
	file write table1 "\textbf{Panel B: Fixed Effects Sample (Firms with Violations)}" _n
	file write table1 "\vspace{0.5em}" _n
	file write table1 _n
	file write table1 "\begin{tabular}{l*{1}{ccccc}}" _n
	file write table1 "\hline\hline" _n
	file write table1 "                    &        Mean&          SD&         Min&         Max&      Median\\" _n
	file write table1 "\hline" _n

	* Get Panel B statistics (using detail option to get median via r(p50))
	qui su viol if sample==1, detail
	file write table1 "Violations          &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su logviol if sample==1, detail
	file write table1 "Violations Intensity         &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su anyviol if sample==1, detail
	file write table1 "\% of Cells with any Violations&" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su bw if sample==1, detail
	file write table1 "Back Wages          &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su nbr_h1bs if sample==1, detail
	file write table1 "Number of H-1Bs     &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su hhithreeyearavg if sample==1, detail
	file write table1 "HHI                 &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n
	qui su subcontractor if sample==1, detail
	file write table1 "Subcontractor       &" %12.3f (`r(mean)') "&" %12.3f (`r(sd)') "&" %12.3f (`r(min)') "&" %12.3f (`r(max)') "&" %12.3f (`r(p50)') "\\" _n

	qui count if sample==1
	local panelB_N = r(N)
	file write table1 "\hline" _n
	file write table1 "Observations        &" %12.0fc (`panelB_N') "&            &            &            &            \\" _n
	file write table1 "\hline\hline" _n
	file write table1 "\end{tabular}" _n
	file write table1 _n
	file write table1 "\end{table}" _n
	file close table1

	di "Table 1 saved to: $tables/table1.tex"
	di "  Panel A (Full Sample): N = `panelA_N'"
	di "  Panel B (FE Sample): N = `panelB_N'"
	di ""

	*-------------------------------------------------------------------------------
	* TABLE 2: WAGES, SKILL LEVELS, AND SUBCONTRACTOR STATUS
	*
	* DV: Wage (in dollars)
	* IVs: HHI category (Moderate/High vs Low), Skill level (2-4 vs 1), Log(H-1Bs), Subcontractor
	* Fixed Effects vary by column:
	*   Col 1: No FE, no clustering
	*   Col 2: Year FE, cluster by CZ
	*   Col 3: Occupation FE, cluster by CZ
	*   Col 4: Commuting Zone FE, cluster by CZ
	*   Col 5: Year + CZ FE, cluster by CZ
	*   Col 6: Year + Occupation FE, cluster by CZ
	*-------------------------------------------------------------------------------

	di "===== TABLE 2: WAGES, SKILL LEVELS, SUBCONTRACTOR STATUS ====="
	di ""
	di "Loading from .ster files (using subcontractor_2019 variable)..."
	di ""

	estimates clear

	* Load from pre-computed .ster files
	di "Loading Table 2 from sters/"

	est use "$sters/table2_col1.ster"
	est sto t2_1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CommuteZone "N"

	est use "$sters/table2_col2.ster"
	est sto t2_2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CommuteZone "N"

	est use "$sters/table2_col3.ster"
	est sto t2_3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommuteZone "N"

	est use "$sters/table2_col4.ster"
	est sto t2_4
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CommuteZone "Y"

	est use "$sters/table2_col5.ster"
	est sto t2_5
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CommuteZone "Y"

	est use "$sters/table2_col6.ster"
	est sto t2_6
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "N"

	* Output Table 2 - uses subcontractor_2019 variable, includes constant
	* Use drop() instead of keep() to ensure _cons is included
	esttab t2_1 t2_2 t2_3 t2_4 t2_5 t2_6 using "$tables/table2.tex", ///
		drop(1.hhicat 1.round_wage_level 0.subcontractor_2019) ///
		order(2.hhicat 3.hhicat 2.round_wage_level 3.round_wage_level 4.round_wage_level logimm 1.subcontractor_2019 _cons) ///
		coeflabels(2.hhicat "Moderate HHI" 3.hhicat "High HHI" ///
				   2.round_wage_level "Skill Level 2" 3.round_wage_level "Skill Level 3" ///
				   4.round_wage_level "Skill Level 4" logimm "Log(H-1Bs)" ///
				   1.subcontractor_2019 "Subcontractor" _cons "Constant") ///
		se star(* 0.1 ** 0.05 *** 0.01) ///
		stats(Year Occ CommuteZone N, fmt(%9.0fc) label("Year FE" "Occupation FE" "Commuting Zone FE" "Observations")) ///
		prehead("\begin{sidewaystable}\centering" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{Effect of Labor Market Concentration on Wages}" "\begin{tabular}{l*{6}{c}}" "\toprule") ///
		postfoot("\bottomrule" "\multicolumn{7}{l}{\footnotesize Dependent variable: Wage (dollars). Standard errors clustered by commuting zone in columns 2-6.}\\" "\multicolumn{7}{l}{\footnotesize Reference categories: Low HHI (<0.10), Skill Level 1, Lead Firm.}\\" "\multicolumn{7}{l}{\footnotesize \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" "\end{tabular}" "\end{sidewaystable}") ///
		nonumbers nonotes replace booktabs

	* Also output as RTF for compatibility
	esttab t2_1 t2_2 t2_3 t2_4 t2_5 t2_6 using "$tables/table2.rtf", ///
		drop(1.hhicat 1.round_wage_level 0.subcontractor_2019) ///
		order(2.hhicat 3.hhicat 2.round_wage_level 3.round_wage_level 4.round_wage_level logimm 1.subcontractor_2019 _cons) ///
		coeflabels(2.hhicat "Moderate HHI" 3.hhicat "High HHI" ///
				   2.round_wage_level "Skill Level 2" 3.round_wage_level "Skill Level 3" ///
				   4.round_wage_level "Skill Level 4" logimm "Log(H-1Bs)" ///
				   1.subcontractor_2019 "Subcontractor" _cons "Constant") ///
		se star(* 0.1 ** 0.05 *** 0.01) ///
		stats(Year Occ CommuteZone N, fmt(%9.0fc) label("Year FE" "Occupation FE" "Commuting Zone FE" "Observations")) ///
		title("Effect of Labor Market Concentration on Wages") ///
		mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
		replace

	di "Table 2 saved to: $tables/table2.tex and $tables/table2.rtf"
	di ""
	di "VERIFY: Subcontractor coefficient should be approximately -8500"
	di ""


	*-------------------------------------------------------------------------------
	* TABLE 3: EFFECT OF LABOR MARKET POWER ON LOG(VIOLATIONS)
	* Source: code/01a_run_regressions.do
	* Verified: All 7 columns match paper exactly (Feb 2026)
	*
	* NOTE: This is Paper Table 3 (not Table 2)
	*
	* STER files: table3_col1.ster through table3_col7.ster
	*
	* Original STER file names:
	*   Col 1: foiareg_3_logviol_8_hhi.ster (CZ+Occ+Year, HHI only)
	*   Col 2: foiareg_3_logviol_8_hhix.ster (CZ+Occ+Year, HHI×Sub interaction)
	*   Col 3: firmfeolslogviolD3wt1.ster (Firm FE, weighted)
	*   Col 4: firmfenonsubolslogviolC3wt1.ster (Lead firms, Occ FE only)
	*   Col 5: firmfenonsubolslogviolD3wt1.ster (Lead firms, full FE)
	*   Col 6: firmfesubolslogviolC3wt1.ster (Subcontractors, Occ FE only)
	*   Col 7: firmfesubolslogviolD3wt1.ster (Subcontractors, full FE)
	*-------------------------------------------------------------------------------

	di "===== TABLE 3: LOG(VIOLATIONS) REGRESSIONS ====="

	estimates clear

	* Column 1: CZ/Occ/Year FE, HHI only
	est use $sters/table3_col1.ster
	qui est replay
	est sto tabB1
	local CommuteZone "Y"
	local Occ "Y"
	local Year "Y"
	local Firm "N"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 2: CZ/Occ/Year FE, HHI x Subcontractor interaction
	est use $sters/table3_col2.ster
	qui est replay
	est sto tabB2
	local CommuteZone "Y"
	local Occ "Y"
	local Year "Y"
	local Firm "N"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 3: Firm FE, pooled
	est use $sters/table3_col3.ster
	qui est replay
	est sto tabB3
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 4: Lead Firms, Occ FE only
	est use $sters/table3_col4.ster
	qui est replay
	est sto tabB5
	local Year "N"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 5: Lead Firms, full FE
	est use $sters/table3_col5.ster
	qui est replay
	est sto tabB6
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 6: Subcontractors, Occ FE only
	est use $sters/table3_col6.ster
	qui est replay
	est sto tabB7
	local Year "N"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 7: Subcontractors, full FE
	est use $sters/table3_col7.ster
	qui est replay
	est sto tabB8
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Output formatting - use sidewaystable for 8-column table
	local title "THE EFFECT OF LABOR MARKET POWER AND SUBCONTRACTOR STATUS ON LOG(1 + VIOLATIONS PER 1000 H-1BS)"
	local rename "rename(hhithreeyearavg HHI 1.subcontractor Subcontractor 1.subcontractor#c.hhithreeyearavg SubcontractorXHHI logh1bs Log(H-1Bs))"
	local dropvars "drop(_cons *.year* *occ*) nobaselevels noomitted"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared chi2 Chi-Sq. _ \_ hhi HHI logh1bs Log(H-1Bs) ur\_rate URRate dep Dependence sub Subcontractor (mean) banana Per. banana table\_viol banana viol banana banana ) `postfoot'"

	estout tabB* using $tables/table3.tex, replace `dropvars' `rename' ///
	  order(HHI Subcontractor SubcontractorXHHI Log(H-1Bs)) `addons' ///
	  prefoot(\hline) stats(Year Occ CommuteZone Firm r2 p k_absorb N, fmt(%9.2gc %9.2f %9.2fc %9.2fc %9.2fc %9.0fc %9.0fc))

	di "Table 3 saved to: $tables/table3.tex"

	*-------------------------------------------------------------------------------
	* TABLE 4: IV REGRESSION - LOG(VIOLATIONS)
	* DV: Log(1+1000*(Violations/H1Bs))
	* Method: Instrumental Variables (2SLS)
	* Instrument: Lagged HHI from prior year
	*
	* Fixed Effects by Column:
	*   Col 1: No FE
	*   Col 2: Year FE
	*   Col 3: Occupation FE
	*   Col 4: Commuting Zone FE
	*   Col 5: Occ + CZ FE
	*   Col 6: Year + Occ FE
	*   Col 7: Year + CZ FE
	*   Col 8: Year + Occ + CZ FE
	*-------------------------------------------------------------------------------

	di "===== TABLE 4: IV REGRESSION - LOG(VIOLATIONS) ====="

	estimates clear

	* Load .ster files (verified to match paper)
	est use $sters/table4_col1.ster
	qui est replay
	est sto tabC1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CommuteZone "N"

	est use $sters/table4_col2.ster
	qui est replay
	est sto tabC2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CommuteZone "N"

	est use $sters/table4_col3.ster
	qui est replay
	est sto tabC3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommuteZone "N"

	est use $sters/table4_col4.ster
	qui est replay
	est sto tabC4
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CommuteZone "Y"

	est use $sters/table4_col5.ster
	qui est replay
	est sto tabC5
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommuteZone "Y"

	est use $sters/table4_col6.ster
	qui est replay
	est sto tabC6
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "N"

	est use $sters/table4_col7.ster
	qui est replay
	est sto tabC7
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CommuteZone "Y"

	est use $sters/table4_col8.ster
	qui est replay
	est sto tabC8
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "Y"

	* Output table - keep only key variables for IV regressions
	* Note: IV regressions don't include subcontractor as a variable
	esttab tabC* using "$tables/table4.tex", replace ///
		keep(hhithreeyearavg logh1bs) ///
		order(hhithreeyearavg logh1bs) ///
		coeflabels(hhithreeyearavg "HHI" logh1bs "Log(H-1Bs)") ///
		se star(* 0.1 ** 0.05 *** 0.01) ///
		stats(Year Occ CommuteZone N widstat jp, fmt(%9.2gc %9.2gc %9.2gc %9.0fc %9.2f %9.2f) label("Year FE" "Occupation FE" "Commuting Zone FE" "Observations" "Kleibergen-Paap F" "Hansen J p-value")) ///
		prehead("\begin{sidewaystable}[htbp]\centering" "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" "\caption{IV Regression: Effect of Labor Market Power on Log(Violations)}" "\begin{tabular}{l*{8}{c}}" "\toprule") ///
		postfoot("\bottomrule" "\multicolumn{9}{l}{\footnotesize Dependent variable: Log(1+1000*(Violations/H1Bs)). IV regression using lagged HHI as instrument.}\\" "\multicolumn{9}{l}{\footnotesize \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" "\end{tabular}" "\end{sidewaystable}") ///
		nonumbers nonotes booktabs

	di "Table 4 saved to: $tables/table4.tex"
	di ""
	di "VERIFY: HHI coefficients should be: -0.247, -0.230, -0.350, -0.257, -0.364, -0.304, -0.236, -0.308"
	di ""


	*-------------------------------------------------------------------------------
	* TABLE A1: NEGATIVE BINOMIAL REGRESSION
	*-------------------------------------------------------------------------------

	di "===== TABLE A1: NEGATIVE BINOMIAL REGRESSIONS ====="

	estimates clear

	* Column 1: Cell-level NB (nbreg) - CZ/Occ/Year FE, HHI only
	est use $sters/tablea1_col1.ster
	qui est replay
	est sto tabC1
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "Y"
	estadd local Firm "N"

	* Column 2: Cell-level NB (nbreg) - CZ/Occ/Year FE, with HHI×Sub interaction
	est use $sters/tablea1_col2.ster
	qui est replay
	est sto tabC2
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "Y"
	estadd local Firm "N"

	* Column 3: Firm FE NB (xtnbreg fe) - Pooled sample
	est use $sters/tablea1_col3.ster
	qui est replay
	est sto tabC3
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "N"
	estadd local Firm "Y"

	* Column 4: Lead firms pooled NB (nbreg) - Non-subcontractors
	* Note: This uses nbreg not xtnbreg, so it reports lnalpha
	est use $sters/tablea1_col4.ster
	qui est replay
	est sto tabC4
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommuteZone "N"
	estadd local Firm "Y"

	* Column 5: Lead firms FE NB (xtnbreg fe) - Non-subcontractors
	est use $sters/tablea1_col5.ster
	qui est replay
	est sto tabC5
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "N"
	estadd local Firm "Y"

	* Column 6: Subcontractors pooled NB (nbreg)
	* Note: This uses nbreg not xtnbreg, so it reports lnalpha
	est use $sters/tablea1_col6.ster
	qui est replay
	est sto tabC6
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommuteZone "N"
	estadd local Firm "Y"

	* Column 7: Subcontractors FE NB (xtnbreg fe)
	est use $sters/tablea1_col7.ster
	qui est replay
	est sto tabC7
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommuteZone "N"
	estadd local Firm "Y"

	* Output formatting - matches obes_dos/obes_pub_tables.do
	local title "THE EFFECT OF LABOR MARKET POWER AND SUBCONTRACTOR STATUS ON WAGE AND HOUR VIOLATIONS"
	local rename "rename(hhithreeyearavg HHI 1.subcontractor Subcontractor 1.subcontractor#c.hhithreeyearavg SubcontractorXHHI logh1bs Log(H-1Bs))"
	local dropvars "drop(_cons *cz90* *.year* *occ*) nobaselevels noomitted"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared chi2 Chi-Sq. _ \_ hhi HHI logh1bs Log(H-1Bs) lnalpha Log(alpha)) `postfoot'"

	estout tabC* using $tables/table_a1.tex, replace `dropvars' `rename' ///
	  order(HHI Subcontractor SubcontractorXHHI Log(H-1Bs)) `addons' ///
	  prefoot(\hline) stats(Year Occ CommuteZone Firm p N, fmt(%9.2gc %9.2gc %9.2gc %9.2gc %9.3f %9.0fc)) eform

	di "Table A1 saved to: $tables/table_a1.tex"

	*-------------------------------------------------------------------------------
	* TABLE 5: MARGINAL EFFECTS - CHANGES IN PROBABILITY
	*
	* Panel A: Change in Probability a Firm Ever Violates (company-level probit)
	* Panel B: Change in Probability a Firm Violates at t (panel probit)
	*
	* NOTE: Probit models are run in 01a_run_regressions.do and output .tex files directly.
	* The .tex files are pre-generated and just need to be included in the LaTeX document.
	*-------------------------------------------------------------------------------

	di "===== TABLE 5: MARGINAL EFFECTS ====="
	di "Pre-generated by 01a_run_regressions.do:"
	di "  - $tables/table5_panelA.tex"
	di "  - $tables/table5_panelB.tex"
	di "  - $tables/table5a.tex (combined)"
	di ""

	*-------------------------------------------------------------------------------
	* TABLE 6 (5b): MARGINAL EFFECTS - PROBABILITIES AT CRITICAL VALUES
	*
	* Panel A: Probability a Firm Ever Violates
	* Panel B: Probability a Firm Violates at time t
	*
	* NOTE: Probit models are run in 01a_run_regressions.do and output .tex files directly.
	*-------------------------------------------------------------------------------

	di "===== TABLE 6: PROBABILITIES AT CRITICAL VALUES ====="
	di "Pre-generated by 01a_run_regressions.do:"
	di "  - $tables/table5b_panelA.tex"
	di "  - $tables/table5b_panelB.tex"
	di ""

	*-------------------------------------------------------------------------------
	* TABLE A.2: WEIGHTED REGRESSIONS - LOG(VIOLATIONS)
	*
	* Panel A: Within Firm Ordinary Least Squares (Firm Fixed Effects)
	* Panel B: Between Firm Ordinary Least Squares (Pooled OLS)
	*
	* STER files: tablea2a_col1-4.ster (Panel A), tablea2b_col1-4.ster (Panel B)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.2: LOADING FROM PRE-COMPUTED .STER FILES ====="

	*-------------------------------------------------------------------------------
	* PANEL A: Within Firm Ordinary Least Squares (Firm Fixed Effects)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.2 PANEL A: WITHIN FIRM OLS (FIRM FE) ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea2a_col1.ster
	qui est replay
	est sto tabE1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea2a_col2.ster
	qui est replay
	est sto tabE2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea2a_col3.ster
	qui est replay
	est sto tabE3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local Firm "Y"

	est use $sters/tablea2a_col4.ster
	qui est replay
	est sto tabE4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local Firm "Y"

	* Output formatting for Panel A
	local title "Within Firm OLS: DV: Log(1+ 1000*(Violations/H1Bs))"
	local rename "rename(hhithreeyearavg HHI logh1bs log(H1Bs))"
	local keeps "HHI log(H1Bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{table})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabE* using $tables/table_a2_panelA.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ Firm r2 k_absorb N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc %9.0fc))

	di "Table A.2 Panel A saved to: $tables/table_a2_panelA.tex"

	*-------------------------------------------------------------------------------
	* PANEL B: Between Firm Ordinary Least Squares (Pooled OLS)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.2 PANEL B: BETWEEN FIRM OLS ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea2b_col1.ster
	qui est replay
	est sto tabF1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CommmutingZone "Y"

	est use $sters/tablea2b_col2.ster
	qui est replay
	est sto tabF2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CommmutingZone "Y"

	est use $sters/tablea2b_col3.ster
	qui est replay
	est sto tabF3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommmutingZone "Y"

	est use $sters/tablea2b_col4.ster
	qui est replay
	est sto tabF4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommmutingZone "Y"

	* Output formatting for Panel B - must rebuild prehead and addons with new title
	local title "Between Firm OLS: DV: Log(1+ 1000*(Violations/H1Bs))"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabF* using $tables/table_a2_panelB.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ CommmutingZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.2 Panel B saved to: $tables/table_a2_panelB.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.3: WEIGHTED REGRESSIONS - LOG(BACK WAGES)
	* STER files: tablea3a_col1-4.ster (Panel A), tablea3b_col1-4.ster (Panel B)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.3: LOADING FROM PRE-COMPUTED .STER FILES ====="

	*-------------------------------------------------------------------------------
	* PANEL A: Within Firm Ordinary Least Squares (Firm Fixed Effects)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.3 PANEL A: WITHIN FIRM OLS (FIRM FE) ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea3a_col1.ster
	qui est replay
	est sto tabG1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea3a_col2.ster
	qui est replay
	est sto tabG2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea3a_col3.ster
	qui est replay
	est sto tabG3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local Firm "Y"

	est use $sters/tablea3a_col4.ster
	qui est replay
	est sto tabG4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local Firm "Y"

	* Output formatting for Panel A
	local title "Within Firm OLS: DV: Log(1+1000*(Back Wages/H1Bs))"
	local rename "rename(hhithreeyearavg HHI logh1bs log(H1Bs))"
	local keeps "HHI log(H1Bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{table})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabG* using $tables/table_a3_panelA.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ Firm r2 k_absorb N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc %9.0fc))

	di "Table A.3 Panel A saved to: $tables/table_a3_panelA.tex"

	*-------------------------------------------------------------------------------
	* PANEL B: Between Firm Ordinary Least Squares (Pooled OLS)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.3 PANEL B: BETWEEN FIRM OLS ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea3b_col1.ster
	qui est replay
	est sto tabH1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CommmutingZone "Y"

	est use $sters/tablea3b_col2.ster
	qui est replay
	est sto tabH2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CommmutingZone "Y"

	est use $sters/tablea3b_col3.ster
	qui est replay
	est sto tabH3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CommmutingZone "Y"

	est use $sters/tablea3b_col4.ster
	qui est replay
	est sto tabH4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CommmutingZone "Y"

	local title "Between Firm OLS: DV: Log(1+1000*(Back Wages/H1Bs))"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabH* using $tables/table_a3_panelB.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ CommmutingZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.3 Panel B saved to: $tables/table_a3_panelB.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.4: UNWEIGHTED REGRESSIONS - LOG(BACK WAGES)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.4: UNWEIGHTED LOG(BACK WAGES) ====="

	estimates clear

	* Column 1: Random Effects OLS (Year+Occ+Firm)
	est use $sters/tablea4_col1.ster
	qui est replay
	est sto tabI1
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "N"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 2: CZ/Occ/Year with HHI x Subcontractor interaction
	est use $sters/tablea4_col2.ster
	qui est replay
	est sto tabI2
	local Year "Y"
	local Occ "Y"
	local CommuteZone "Y"
	local Firm "N"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 3: Fixed Effects OLS (Year+Occ+Firm)
	est use $sters/tablea4_col3.ster
	qui est replay
	est sto tabI3
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 4: Lead Firms, FE OLS, Occ only
	est use $sters/tablea4_col4.ster
	qui est replay
	est sto tabI5
	local Year "N"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 5: Lead Firms, FE OLS, Year+Occ
	est use $sters/tablea4_col5.ster
	qui est replay
	est sto tabI6
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 6: Subcontractors, FE OLS, Occ only
	est use $sters/tablea4_col6.ster
	qui est replay
	est sto tabI7
	local Year "N"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 7: Subcontractors, FE OLS, Year+Occ
	est use $sters/tablea4_col7.ster
	qui est replay
	est sto tabI8
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Output formatting
	local title "THE EFFECT OF LABOR MARKET POWER AND SUBCONTRACTOR STATUS ON LOG(1+ BACK WAGES PER 1000 H-1BS)"
	local rename "rename(hhithreeyearavg HHI 1.subcontractor Subcontractor 1.subcontractor#c.hhithreeyearavg SubcontractorXHHI logh1bs Log(H-1Bs))"
	local dropvars "drop(_cons *cz90* *.year* *occ*) nobaselevels noomitted"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared chi2 Chi-Sq. _ \_ hhi HHI logh1bs Log(H-1Bs) ur\_rate URRate dep Dependence sub Subcontractor (mean) banana Per. banana table\_viol banana viol banana banana ) `postfoot'"

	estout tabI* using $tables/table_a4.tex, replace `dropvars' `rename' ///
	  order(HHI Subcontractor SubcontractorXHHI Log(H-1Bs)) `addons' ///
	  prefoot(\hline) stats(Year Occ CommuteZone Firm r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.4 saved to: $tables/table_a4.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.5: WEIGHTED REGRESSIONS - LOG(BACK WAGES/PROMISED WAGES)
	*-------------------------------------------------------------------------------

	*-------------------------------------------------------------------------------
	* PANEL A: Within Firm Ordinary Least Squares (Firm Fixed Effects)
	*-------------------------------------------------------------------------------

	estimates clear

	* Column 1: Firm FE only (no year, no occ)
	di "Loading Panel A Column 1 from tablea5a_col1.ster"
	est use $sters/tablea5a_col1.ster
	qui est replay
	est sto tabJ1
	local Year "N"
	local Occ "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Column 2: Firm FE + Year
	di "Loading Panel A Column 2 from tablea5a_col2.ster"
	est use $sters/tablea5a_col2.ster
	qui est replay
	est sto tabJ2
	local Year "Y"
	local Occ "N"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Column 3: Firm FE + Occ
	di "Loading Panel A Column 3 from tablea5a_col3.ster"
	est use $sters/tablea5a_col3.ster
	qui est replay
	est sto tabJ3
	local Year "N"
	local Occ "Y"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Column 4: Firm FE + Year + Occ
	di "Loading Panel A Column 4 from tablea5a_col4.ster"
	est use $sters/tablea5a_col4.ster
	qui est replay
	est sto tabJ4
	local Year "Y"
	local Occ "Y"
	local Firm "Y"
	estadd local Firm "`Firm'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Output formatting for Panel A
	local title "Firm, Occupation Level: Within Firm OLS: DV: Log(1+1000*(Back Wages/Promised Wages))"
	local rename "rename(hhithreeyearavg HHI logh1bs log(H1Bs))"
	local keeps "HHI log(H1Bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{table})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabJ* using $tables/table_a5_panelA.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ Firm r2 k_absorb N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc %9.0fc))

	di "Table A.5 Panel A saved to: $tables/table_a5_panelA.tex"

	*-------------------------------------------------------------------------------
	* PANEL B: Between Firm Ordinary Least Squares (Pooled OLS with CZ clustering)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.5 PANEL B: BETWEEN FIRM OLS ====="

	estimates clear

	* Column 1: CZ FE only (no year, no occ)
	di "Loading Panel B Column 1 from tablea5b_col1.ster"
	est use $sters/tablea5b_col1.ster
	qui est replay
	est sto tabK1
	local Year "N"
	local Occ "N"
	local CZ "Y"
	estadd local CZ "`CZ'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Column 2: CZ FE + Year
	di "Loading Panel B Column 2 from tablea5b_col2.ster"
	est use $sters/tablea5b_col2.ster
	qui est replay
	est sto tabK2
	local Year "Y"
	local Occ "N"
	local CZ "Y"
	estadd local CZ "`CZ'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Column 3: CZ FE + Occ
	di "Loading Panel B Column 3 from tablea5b_col3.ster"
	est use $sters/tablea5b_col3.ster
	qui est replay
	est sto tabK3
	local Year "N"
	local Occ "Y"
	local CZ "Y"
	estadd local CZ "`CZ'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Column 4: CZ FE + Year + Occ
	di "Loading Panel B Column 4 from tablea5b_col4.ster"
	est use $sters/tablea5b_col4.ster
	qui est replay
	est sto tabK4
	local Year "Y"
	local Occ "Y"
	local CZ "Y"
	estadd local CZ "`CZ'"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"

	* Output formatting for Panel B - must rebuild prehead and addons with new title
	local title "Firm, Occupation Level: Between Firm OLS: DV: Log(1+1000*(Back Wages/Promised Wages))"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabK* using $tables/table_a5_panelB.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ CZ r2 N, fmt(%9.2gc %9.2gc %9.2gc %9.2gc %9.0fc) label("Year" "Occ" "Commuting Zone" "N"))

	di "Table A.5 Panel B saved to: $tables/table_a5_panelB.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.6: CELL-LEVEL OLS WITH HHI×SUBCONTRACTOR - LOG(BACK WAGES/PROMISED WAGES)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.6: CELL-LEVEL OLS LOG(BACK WAGES/PROMISED WAGES) ====="

	estimates clear

	* Load from pre-computed .ster files
	di "Loading Table A.6 from sters/"

	* Column 1: No FE
	est use $sters/tablea6_col1.ster
	qui est replay
	est sto tabL1
	local Year "N"
	local Occ "N"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 2: Year only
	est use $sters/tablea6_col2.ster
	qui est replay
	est sto tabL2
	local Year "Y"
	local Occ "N"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 3: Occ only
	est use $sters/tablea6_col3.ster
	qui est replay
	est sto tabL3
	local Year "N"
	local Occ "Y"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 4: CZ only
	est use $sters/tablea6_col4.ster
	qui est replay
	est sto tabL4
	local Year "N"
	local Occ "N"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 5: Occ + CZ
	est use $sters/tablea6_col5.ster
	qui est replay
	est sto tabL5
	local Year "N"
	local Occ "Y"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 6: Year + Occ
	est use $sters/tablea6_col6.ster
	qui est replay
	est sto tabL6
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 7: Year + CZ
	est use $sters/tablea6_col7.ster
	qui est replay
	est sto tabL7
	local Year "Y"
	local Occ "N"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Column 8: Year + Occ + CZ
	est use $sters/tablea6_col8.ster
	qui est replay
	est sto tabL8
	local Year "Y"
	local Occ "Y"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occ "`Occ'"
	estadd local CommuteZone "`CommuteZone'"

	* Output formatting
	local title "OLS Regression: Firm-Level, Year, Commuting Zone, and Occupation Defined Labor Market"
	local rename "rename(hhithreeyearavg HHI 1.subcontractor Subcontractor 1.subcontractor#c.hhithreeyearavg SubcontractorXHHI logh1bs log(nbrh1bs))"
	local keeps "HHI Subcontractor SubcontractorXHHI log(nbrh1bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{threeparttable} \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \begin{tablenotes} \item  \end{tablenotes} \end{threeparttable} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabL* using $tables/table_a6.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ CommuteZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.6 saved to: $tables/table_a6.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.7: CELL-LEVEL OLS - LOG(VIOLATIONS) - OCCUPATION-CZ-YEAR LEVEL
	*-------------------------------------------------------------------------------

	di "===== TABLE A.7: CELL-LEVEL OLS LOG(VIOLATIONS) - OCC-CZ-YEAR LEVEL ====="

	estimates clear

	* Load from pre-computed .ster files
	di "Loading Table A.7 from sters/"

	* Column 1: No FE
	est use $sters/tablea7_col1.ster
	qui est replay
	est sto tabM1
	local Year "N"
	local Occ "N"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 2: Year only
	est use $sters/tablea7_col2.ster
	qui est replay
	est sto tabM2
	local Year "Y"
	local Occ "N"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 3: Occ only
	est use $sters/tablea7_col3.ster
	qui est replay
	est sto tabM3
	local Year "N"
	local Occ "Y"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 4: CZ only
	est use $sters/tablea7_col4.ster
	qui est replay
	est sto tabM4
	local Year "N"
	local Occ "N"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 5: Occ + CZ
	est use $sters/tablea7_col5.ster
	qui est replay
	est sto tabM5
	local Year "N"
	local Occ "Y"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 6: Year + Occ
	est use $sters/tablea7_col6.ster
	qui est replay
	est sto tabM6
	local Year "Y"
	local Occ "Y"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 7: Year + CZ
	est use $sters/tablea7_col7.ster
	qui est replay
	est sto tabM7
	local Year "Y"
	local Occ "N"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 8: Year + Occ + CZ
	est use $sters/tablea7_col8.ster
	qui est replay
	est sto tabM8
	local Year "Y"
	local Occ "Y"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Occupation "`Occ'"
	estadd local CommutingZone "`CommuteZone'"

	* Output formatting
	local title "OLS Regression: Log(1+1000*(WHD Violations/H1Bs)): Firm-Level, Year, Commuting Zone, and Occupation Defined Labor Market"
	local rename "rename(hhithreeyearavg HHI logh1bs log(nbrh1bs))"
	local keeps "HHI log(nbrh1bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{threeparttable} \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \begin{tablenotes} \item  \end{tablenotes} \end{threeparttable} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabM* using $tables/table_a7.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occupation CommutingZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.7 saved to: $tables/table_a7.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.8: CELL-LEVEL OLS - LOG(VIOLATIONS) - INDUSTRY-CZ-YEAR LEVEL
	*-------------------------------------------------------------------------------

	di "===== TABLE A.8: CELL-LEVEL OLS LOG(VIOLATIONS) - INDUSTRY-CZ-YEAR LEVEL ====="

	estimates clear

	* Load from pre-computed .ster files
	di "Loading Table A.8 from sters/"

	* Column 1: No FE
	est use $sters/tablea8_col1.ster
	qui est replay
	est sto tabN1
	local Year "N"
	local Industry "N"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 2: Year only
	est use $sters/tablea8_col2.ster
	qui est replay
	est sto tabN2
	local Year "Y"
	local Industry "N"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 3: Industry only
	est use $sters/tablea8_col3.ster
	qui est replay
	est sto tabN3
	local Year "N"
	local Industry "Y"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 4: CZ only
	est use $sters/tablea8_col4.ster
	qui est replay
	est sto tabN4
	local Year "N"
	local Industry "N"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 5: Industry + CZ
	est use $sters/tablea8_col5.ster
	qui est replay
	est sto tabN5
	local Year "N"
	local Industry "Y"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 6: Year + Industry
	est use $sters/tablea8_col6.ster
	qui est replay
	est sto tabN6
	local Year "Y"
	local Industry "Y"
	local CommuteZone "N"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 7: Year + CZ
	est use $sters/tablea8_col7.ster
	qui est replay
	est sto tabN7
	local Year "Y"
	local Industry "N"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Column 8: Year + Industry + CZ
	est use $sters/tablea8_col8.ster
	qui est replay
	est sto tabN8
	local Year "Y"
	local Industry "Y"
	local CommuteZone "Y"
	estadd local Year "`Year'"
	estadd local Industry "`Industry'"
	estadd local CommutingZone "`CommuteZone'"

	* Output formatting
	local title "OLS Regression: Log(1+1000*(WHD Violations/H1Bs)): Firm-Level, Year, Commuting Zone, and Industry Defined Labor Market"
	local rename "rename(hhithreeyearavg HHI logh1bs log(nbrh1bs))"
	local keeps "HHI log(nbrh1bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{threeparttable} \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \begin{tablenotes} \item  \end{tablenotes} \end{threeparttable} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabN* using $tables/table_a8.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Industry CommutingZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.8 saved to: $tables/table_a8.tex"


	*-------------------------------------------------------------------------------
	* TABLE A.9: UNWEIGHTED FIRM-LEVEL REGRESSIONS - LOG(VIOLATIONS)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.9: LOADING FROM PRE-COMPUTED .STER FILES ====="

	*--- Panel A: Within Firm OLS (Firm Fixed Effects) - UNWEIGHTED ---

	di "===== TABLE A.9 PANEL A: WITHIN FIRM OLS (UNWEIGHTED) ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea9a_col1.ster
	qui est replay
	est sto tabO1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea9a_col2.ster
	qui est replay
	est sto tabO2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea9a_col3.ster
	qui est replay
	est sto tabO3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local Firm "Y"

	est use $sters/tablea9a_col4.ster
	qui est replay
	est sto tabO4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local Firm "Y"

	local title "Firm, Occupation Level: Within Firm OLS (Unweighted): DV: Log(1+ 1000*(Violations/H1Bs))"
	local rename "rename(hhithreeyearavg HHI logh1bs log(H1Bs))"
	local keeps "HHI log(H1Bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{table})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabO* using $tables/table_a9_panelA.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ Firm r2 k_absorb N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc %9.0fc))

	di "Table A.9 Panel A saved to: $tables/table_a9_panelA.tex"

	*--- Panel B: Between Firm OLS - UNWEIGHTED ---

	di "===== TABLE A.9 PANEL B: BETWEEN FIRM OLS (UNWEIGHTED) ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea9b_col1.ster
	qui est replay
	est sto tabP1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CZ "Y"

	est use $sters/tablea9b_col2.ster
	qui est replay
	est sto tabP2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CZ "Y"

	est use $sters/tablea9b_col3.ster
	qui est replay
	est sto tabP3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CZ "Y"

	est use $sters/tablea9b_col4.ster
	qui est replay
	est sto tabP4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CZ "Y"

	local title "Firm, Occupation Level: Between Firm OLS (Unweighted): DV: Log(1+ 1000*(Violations/H1Bs))"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabP* using $tables/table_a9_panelB.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ CZ r2 N, fmt(%9.2gc %9.2f %9.2f %9.0fc) label("Year" "Occ" "Commuting Zone" "R-Squared" "N"))

	di "Table A.9 Panel B saved to: $tables/table_a9_panelB.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.10: CELL-LEVEL OLS WITH HHI×SUBCONTRACTOR - LOG(VIOLATIONS)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.10: CELL-LEVEL OLS LOG(VIOLATIONS) WITH HHI×SUB ====="

	estimates clear

	* Load from pre-computed .ster files
	di "Loading Table A.10 from sters/"

	forvalues i = 1/8 {
		est use $sters/tablea10_col`i'.ster
		qui est replay
		est sto tabQ`i'

		if `i'==1 {
			local Year "N"
			local Occ "N"
			local CommuteZone "N"
		}
		if `i'==2 {
			local Year "Y"
			local Occ "N"
			local CommuteZone "N"
		}
		if `i'==3 {
			local Year "N"
			local Occ "Y"
			local CommuteZone "N"
		}
		if `i'==4 {
			local Year "N"
			local Occ "N"
			local CommuteZone "Y"
		}
		if `i'==5 {
			local Year "N"
			local Occ "Y"
			local CommuteZone "Y"
		}
		if `i'==6 {
			local Year "Y"
			local Occ "Y"
			local CommuteZone "N"
		}
		if `i'==7 {
			local Year "Y"
			local Occ "N"
			local CommuteZone "Y"
		}
		if `i'==8 {
			local Year "Y"
			local Occ "Y"
			local CommuteZone "Y"
		}

		estadd local Year "`Year'"
		estadd local Occupation "`Occ'"
		estadd local CommutingZone "`CommuteZone'"
	}

	local title "OLS Regression: Log(1+1000*(WHD Violations/H1Bs)): Firm-Level, Year, Commuting Zone, and Occupation Defined Labor Market"
	local rename "rename(hhithreeyearavg HHI 1.subcontractor Subcontractor 1.subcontractor#c.hhithreeyearavg SubcontractorXHHI logh1bs log(nbrh1bs))"
	local keeps "HHI Subcontractor SubcontractorXHHI log(nbrh1bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{threeparttable} \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \begin{tablenotes} \item  \end{tablenotes} \end{threeparttable} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabQ* using $tables/table_a10.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occupation CommutingZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.10 saved to: $tables/table_a10.tex"


	*-------------------------------------------------------------------------------
	* TABLE A.11: UNWEIGHTED FIRM-LEVEL REGRESSIONS - LOG(BACK WAGES)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.11: LOADING FROM PRE-COMPUTED .STER FILES ====="

	*--- Panel A: Within Firm OLS (Firm Fixed Effects) - UNWEIGHTED ---

	di "===== TABLE A.11 PANEL A: WITHIN FIRM OLS (UNWEIGHTED) ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea11a_col1.ster
	qui est replay
	est sto tabR1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea11a_col2.ster
	qui est replay
	est sto tabR2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local Firm "Y"

	est use $sters/tablea11a_col3.ster
	qui est replay
	est sto tabR3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local Firm "Y"

	est use $sters/tablea11a_col4.ster
	qui est replay
	est sto tabR4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local Firm "Y"

	local title "Firm, Occupation Level: Within Firm OLS (Unweighted): DV: Log(1+1000*(Back Wages/H1Bs))"
	local rename "rename(hhithreeyearavg HHI logh1bs log(H1Bs))"
	local keeps "HHI log(H1Bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \end{table})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabR* using $tables/table_a11_panelA.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ Firm r2 k_absorb N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc %9.0fc))

	di "Table A.11 Panel A saved to: $tables/table_a11_panelA.tex"

	*--- Panel B: Between Firm OLS (CZ Fixed Effects) - UNWEIGHTED ---

	di "===== TABLE A.11 PANEL B: BETWEEN FIRM OLS (UNWEIGHTED) ====="

	estimates clear

	* Load from pre-computed .ster files
	est use $sters/tablea11b_col1.ster
	qui est replay
	est sto tabS1
	estadd local Year "N"
	estadd local Occ "N"
	estadd local CZ "Y"

	est use $sters/tablea11b_col2.ster
	qui est replay
	est sto tabS2
	estadd local Year "Y"
	estadd local Occ "N"
	estadd local CZ "Y"

	est use $sters/tablea11b_col3.ster
	qui est replay
	est sto tabS3
	estadd local Year "N"
	estadd local Occ "Y"
	estadd local CZ "Y"

	est use $sters/tablea11b_col4.ster
	qui est replay
	est sto tabS4
	estadd local Year "Y"
	estadd local Occ "Y"
	estadd local CZ "Y"

	local title "Firm, Occupation Level: Between Firm OLS (Unweighted): DV: Log(1+1000*(Back Wages/H1Bs))"
	local prehead "prehead(\begin{table}\centering \caption{`title'}\centering\medskip \begin{tabular}{lccccc} \hline \hline) mlabels(none)"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabS* using $tables/table_a11_panelB.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occ CZ r2 N, fmt(%9.2gc %9.2f %9.2f %9.0fc) label("Year" "Occ" "Commuting Zone" "R-Squared" "N"))

	di "Table A.11 Panel B saved to: $tables/table_a11_panelB.tex"

	*-------------------------------------------------------------------------------
	* TABLE A.12: CELL-LEVEL OLS WITH HHI×SUBCONTRACTOR - LOG(BACK WAGES)
	*-------------------------------------------------------------------------------

	di "===== TABLE A.12: CELL-LEVEL OLS LOG(BACK WAGES) WITH HHI×SUB ====="

	estimates clear

	* Load from pre-computed .ster files
	di "Loading Table A.12 from sters/"

	forvalues i = 1/8 {
		est use $sters/tablea12_col`i'.ster
		qui est replay
		est sto tabT`i'

		if `i'==1 {
			local Year "N"
			local Occ "N"
			local CommuteZone "N"
		}
		if `i'==2 {
			local Year "Y"
			local Occ "N"
			local CommuteZone "N"
		}
		if `i'==3 {
			local Year "N"
			local Occ "Y"
			local CommuteZone "N"
		}
		if `i'==4 {
			local Year "N"
			local Occ "N"
			local CommuteZone "Y"
		}
		if `i'==5 {
			local Year "N"
			local Occ "Y"
			local CommuteZone "Y"
		}
		if `i'==6 {
			local Year "Y"
			local Occ "Y"
			local CommuteZone "N"
		}
		if `i'==7 {
			local Year "Y"
			local Occ "N"
			local CommuteZone "Y"
		}
		if `i'==8 {
			local Year "Y"
			local Occ "Y"
			local CommuteZone "Y"
		}

		estadd local Year "`Year'"
		estadd local Occupation "`Occ'"
		estadd local CommutingZone "`CommuteZone'"
	}

	local title "OLS Regression: Log(1+1000*(Back Wages/H1Bs)): Firm-Level, Year, Commuting Zone, and Occupation Defined Labor Market"
	local rename "rename(hhithreeyearavg HHI 1.subcontractor Subcontractor 1.subcontractor#c.hhithreeyearavg SubcontractorXHHI logh1bs log(nbrh1bs))"
	local keeps "HHI Subcontractor SubcontractorXHHI log(nbrh1bs)"
	local stuff "numbers label cells(b(fmt(a3) star) se(fmt(a3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)"
	local prehead "prehead(\begin{sidewaystable}\centering \caption{`title'}\centering\medskip \begin{threeparttable} \begin{tabular}{lcccccccc} \hline \hline) mlabels(none)"
	local postfoot "postfoot(\hline \hline \end{tabular} \begin{tablenotes} \item  \end{tablenotes} \end{threeparttable} \end{sidewaystable})"
	local addons "`prehead' style(tex) `stuff' substitute(r2 R-Squared _ \_) `postfoot'"

	estout tabT* using $tables/table_a12.tex, replace `rename' keep(`keeps') order(`keeps') `addons' ///
	  prefoot(\hline) stats(Year Occupation CommutingZone r2 N, fmt(%9.2gc %9.2f %9.2f %9.2f %9.0fc))

	di "Table A.12 saved to: $tables/table_a12.tex"


	di ""
	di "===== ALL TABLES GENERATED ====="
	di ""
	di "Tables generated:"
	di "  - Table 1: table1.tex (VERIFY against paper)"
	di "  - Table 2: table2.tex (Verified)"
	di "  - Table 3: table3.tex (Verified)"
	di "  - Table 5a: table5a.tex (Marginal Effects - Changes in Probability)"
	di "  - Table 5b: table5b_panelA.tex, table5b_panelB.tex (Probabilities at Critical Values)"
	di "  - Table A.1: table_a1.tex (Verified)"
	di "  - Table A.2 Panel A: table_a2_panelA.tex (Verified)"
	di "  - Table A.2 Panel B: table_a2_panelB.tex (Verified)"
	di "  - Table A.3 Panel A: table_a3_panelA.tex (Verified)"
	di "  - Table A.3 Panel B: table_a3_panelB.tex (Verified)"
	di "  - Table A.4: table_a4.tex (Verified)"
	di "  - Table A.5 Panel A: table_a5_panelA.tex (Verified)"
	di "  - Table A.5 Panel B: table_a5_panelB.tex (Verified)"
	di "  - Table A.6: table_a6.tex (Verified)"
	di "  - Table A.7: table_a7.tex (Verified)"
	di "  - Table A.8: table_a8.tex (Verified)"
	di "  - Table A.9: table_a9_panelA.tex, table_a9_panelB.tex (Verified)"
	di "  - Table A.10: table_a10.tex (Verified)"
	di "  - Table A.11: table_a11_panelA.tex, table_a11_panelB.tex (Verified)"
	di "  - Table A.12: table_a12.tex (Verified)"
	di ""

	* End of tables file
