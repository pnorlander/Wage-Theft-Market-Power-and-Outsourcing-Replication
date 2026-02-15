*===============================================================================
* 02_figures.do
* Generates Figures 1, 2 (Panels A & B), 3, 4, and 5
*
* Data files required:
*   - master_db.dta (comprehensive dataset with all merged data)
*   - h1b_2019_match_clients.dta (for Figure 1 - NOT included due to size, 3.1 GB)
*
* NOTE: Before running, run prepare_replication_data.do in the parent directory
*       to create the comprehensive master_db.dta with:
*       - Prevailing wage data (for Figure 2 Panel A & B)
*       - Wage level data (for Figure 4)
*       - All derived variables
*
* Figures generated:
*   - Figure 1: Network Graph of Silicon Valley Outsourcing (PRE-GENERATED)
*   - Figure 2 Panel A: Kernel Density of Wage Premium
*   - Figure 2 Panel B: Probability of Violation as Function of Wage Premium
*   - Figure 3: HHI Bar Chart by Violation Category
*   - Figure 4: Violations Intensity by HHI, Subcontractor, and Skill Level
*   - Figure 5: Probability a Firm Has a Violation (4-panel)
*===============================================================================

di "===== GENERATING FIGURES ====="
di ""

*-------------------------------------------------------------------------------
* FIGURE 1: NETWORK GRAPH
* Source: dos/Network analysis.do lines 154-208
* Verified: Visual match to paper
*
* NOTE: The source data file (h1b_2019_match_clients.dta) is 3.1 GB and not
* included in the replication package. The pre-generated figure is provided.
*-------------------------------------------------------------------------------

di "===== FIGURE 1: NETWORK GRAPH ====="
di "Pre-generated figure: $figures/fig1_network.pdf"
di "NOTE: Source data (3.1 GB) not included. Figure pre-generated."
di ""

/* Code for Figure 1 (requires h1b_2019_match_clients.dta - not included):

use "[path_to]/h1b_2019_match_clients.dta", clear

keep if case_status=="CERTIFIED"
destring total_worker_positions, replace

* Clean client names for key firms
foreach var in "GOOGLE" "CSTDELOITTE" "IITHCL" "IITTECHMAHINDRA" "IITINFOSYS" "IITWIPRO" "IITCOGNIZANT" "INTEL" "IITLARSEN" "INTUIT" "IITTATA" "APPLE" "ADOBESYS" {
  replace client_name="" if(name=="`var'" & client_name=="`var'")
}

collapse (rawsum) total_worker_positions nbr_immigrants, by(name client_name)

* Define Silicon Valley firms
gen silicon=0
replace silicon=1 if inlist(name, "GOOGLE", "CSTDELOITTE", "IITHCL", "IITTECHMAHINDRA")
replace silicon=1 if inlist(name, "IITINFOSYS", "IITWIPRO", "IITCOGNIZANT", "INTEL", "IITLARSEN", "INTUIT", "IITTATA", "APPLE", "ADOBESYS")

gen clients=0
replace clients=1 if inlist(client_name, "GOOGLE", "CSTDELOITTE", "IITHCL", "IITTECHMAHINDRA", "")
replace clients=1 if inlist(client_name, "IITINFOSYS", "IITWIPRO", "IITCOGNIZANT", "INTEL", "IITLARSEN", "INTUIT", "IITTATA", "APPLE", "ADOBESYS")

keep if silicon==1 & clients==1

* Create network (requires nwcommands package)
nwfromedge client_name name nbr_immigrants

* Define node attributes
gen color="Lead Firms"
replace color="Subcontractors" if inlist(_nodelab, "CSTDELOITTE", "IITHCL", "IITTECHMAHINDRA", "IITINFOSYS", "IITWIPRO", "IITCOGNIZANT", "IITLARSEN", "IITTATA")

gen h1bsize=0
replace h1bsize=28850 if _nodelab=="GOOGLE"
replace h1bsize=47983 if _nodelab=="CSTDELOITTE"
replace h1bsize=31749 if _nodelab=="IITHCL"
replace h1bsize=22619 if _nodelab=="IITTECHMAHINDRA"
replace h1bsize=114568 if _nodelab=="IITINFOSYS"
replace h1bsize=65732 if _nodelab=="IITWIPRO"
replace h1bsize=170144 if _nodelab=="IITCOGNIZANT"
replace h1bsize=23012 if _nodelab=="INTEL"
replace h1bsize=24143 if _nodelab=="IITLARSEN"
replace h1bsize=3520 if _nodelab=="INTUIT"
replace h1bsize=88785 if _nodelab=="IITTATA"
replace h1bsize=20350 if _nodelab=="APPLE"
replace h1bsize=2487 if _nodelab=="ADOBESYS"

gen violator=0
replace violator=1 if inlist(_nodelab, "IITHCL", "IITTECHMAHINDRA", "IITINFOSYS", "IITWIPRO", "IITCOGNIZANT", "IITLARSEN", "APPLE")

* Clean labels
replace _nodelab="HCL" if _nodelab=="IITHCL"
replace _nodelab="TATA" if _nodelab=="IITTATA"
replace _nodelab="WIPRO" if _nodelab=="IITWIPRO"
replace _nodelab="INFOSYS" if _nodelab=="IITINFOSYS"
replace _nodelab="COGNIZANT" if _nodelab=="IITCOGNIZANT"
replace _nodelab="LARSEN & TOUBRO" if _nodelab=="IITLARSEN"
replace _nodelab="TECH MAHINDRA" if _nodelab=="IITTECHMAHINDRA"
replace _nodelab="DELOITTE" if _nodelab=="CSTDELOITTE"
replace _nodelab="ADOBE" if _nodelab=="ADOBESYS"

* Plot network
nwplot network, label(_nodelab) layout(mds) scheme(s2mono) size(h1bsize) nodefactor(5) ///
  symbol(color, symbolpalette(O D)) color(violator, colorpalette(green%20 red%20)) ///
  edgecolorpalette(gray%10) legendopt(off) labelopt(mlabsize(medium) mlabcolor(black))

graph export "$figures/fig1_network.pdf", replace

*/

*-------------------------------------------------------------------------------
* FIGURE 2 PANEL A: KERNEL DENSITY OF WAGE PREMIUM
* Source: insheet_aug_25.do lines 195-237
* Verified: Visual match to paper
*
* This figure shows the kernel density of wage premium (wage - prevailing wage)
* by subcontractor status. Uses the adjusted wage premium (diff_adj) which
* applies the $60k floor for subcontractors.
*
* REQUIRES: diff_adj variable (created by prepare_replication_data.do)
*-------------------------------------------------------------------------------

di "===== FIGURE 2 PANEL A: KERNEL DENSITY OF WAGE PREMIUM ====="

use "$data/master_db.dta", clear

* Restrict to observations with wage premium data and years after 2005
drop if diff_adj == .
keep if year > 2005
di "Observations with wage premium data (post-2005): " _N

* Figure 2 Panel A: Kernel density with $60k floor adjustment for subcontractors
kdensity diff_adj [aw=nbr_h1bs] if subcontractor==0 & inrange(diff_adj, -10000, 35000), ///
    addplot(kdensity diff_adj [aw=nbr_h1bs] if subcontractor==1 & inrange(diff_adj, -10000, 35000)) ///
    saving("$figures/fig2a_kdensity.gph", replace) ///
    legend(ring(0) pos(2) label(1 "Lead Firms") label(2 "Subcontractors")) ///
    bwidth(5000) title("") xtitle("Wage Premium over Prevailing Wage") ///
    xlabel(-10000 "-10k" 0 "0" 10000 "10k" 20000 "20k" 30000 "30k") ///
    xline(0) xscale(r(-10000 35000)) note("")

graph export "$figures/fig2a_kdensity.pdf", replace

di "Figure 2 Panel A saved to: $figures/fig2a_kdensity.pdf"
di ""

*-------------------------------------------------------------------------------
* FIGURE 2 PANEL B: PROBABILITY OF VIOLATION AS FUNCTION OF WAGE PREMIUM
* Source: insheet_aug_25.do lines 213-224
* Verified: Visual match to paper
*
* This figure shows Pr(Violation) on the y-axis against Wage Premium
* (wage minus prevailing wage) on the x-axis, with separate lines for
* Lead Firms vs Subcontractors.
*
* REQUIRES: diff_adj variable (created by running prepare_replication_data.do
*           in the parent directory first)
*-------------------------------------------------------------------------------

di "===== FIGURE 2 PANEL B: PROBABILITY OF VIOLATION ====="

use "$data/master_db.dta", clear

* Use the adjusted wage premium (with $60k floor for subcontractors)
* diff_adj = wage - prevailing_wage_1, or wage - 60000 if PW < 60000 for subs

* Restrict to observations with wage premium data
drop if diff_adj == .
di "Observations with wage premium data: " _N

* Run probit with cubic polynomial in wage premium
qui probit anyviol i.subcontractor c.diff_adj##c.diff_adj##c.diff_adj i.year [pw=nbr_h1bs], vce(robust)

* Generate marginal predictions
margins, at(diff_adj=(-10000(2500)45000) subcontractor=(0(1)1)) vsquish post asobserved noestimcheck

* Plot
marginsplot, ///
    xlabel(-10000 "-10k" 0 "0" 10000 "10k" 20000 "20k" 30000 "30k" 40000 "40k") ///
    legend(pos(6) col(2) order(4 "Subcontractor" 3 "Lead Firm")) ///
    plot1opts(lpattern(".")) plot2opts(lpattern("l")) ///
    xtitle("Wage Premium over Prevailing Wage") ///
    ytitle("Pr(Violation)") ///
    title("") ///
    saving("$figures/fig2b_prob_viol.gph", replace)

graph export "$figures/fig2b_prob_viol.pdf", replace

di "Figure 2 Panel B saved to: $figures/fig2b_prob_viol.pdf"
di ""

*-------------------------------------------------------------------------------
* FIGURE 3: HHI BAR CHART BY VIOLATION CATEGORY
* Source: dos/descriptives.do lines 117-143
* Verified: Visual match to paper
*-------------------------------------------------------------------------------

di "===== FIGURE 3: HHI BAR CHART ====="

use "$data/master_db.dta", clear
keep if category_set==3

* Create violation categories
gen violcat=0
replace violcat=3 if viol==0
replace violcat=2 if viol>0 & viol<5
replace violcat=1 if viol>5

lab def violcat 1 "0" 2 "1-5" 3 ">5"
lab val violcat violcat
lab var violcat "Violations"

* Unweighted version (matches paper)
preserve
collapse (mean) hhithreeyearavg ur_rate, by(violcat subcontractor)
reshape wide hhithreeyearavg ur_rate, i(violcat) j(subcontractor)

graph hbar (mean) hhithreeyearavg0 hhithreeyearavg1, ///
  over(violcat, relabel(1 ">5 Violations" 2 "1-5 Violations" 3 "0 Violations")) ///
  ytitle("Average HHI. Monopsony=1") ///
  legend(label(1 "Lead Firms") label(2 "Subcontractors"))

graph export "$figures/fig3_hhibar.pdf", replace
restore

di "Figure 3 saved to: $figures/fig3_hhibar.pdf"

*-------------------------------------------------------------------------------
* FIGURE 5: PROBABILITY A FIRM HAS A VIOLATION
* Source: obes_dos/obes_firm_quits.do lines 183-370
* Verified: Visual match to paper
*
* This figure is a 4-panel combination showing:
*   - Top-left: Pr(Ever Violate) - Unweighted (company level)
*   - Top-right: Pr(Ever Violate) - Weighted (company level)
*   - Bottom-left: Pr(Violation at time t) - Unweighted (panel level)
*   - Bottom-right: Pr(Violation at time t) - Weighted (panel level)
*
* X-axis: HHI (0 to 1)
* Y-axis: Probability
* Lines: Lead Firm (solid) vs Subcontractor (dashed)
*-------------------------------------------------------------------------------

di "===== FIGURE 5: PROBABILITY A FIRM HAS A VIOLATION ====="

use "$data/master_db.dta", clear
keep if category_set==3

set scheme plotplain

egen company = group(name)

* Collapse to firm-year panel
collapse (rawsum) nbr_h1bs (rawsum) viol (mean) hhithreeyearavg ur_rate subcontractor [fw=fw_h1bs], by(company year)

gen fw_h1bs=round(nbr_h1bs)
gen logh1bs=log(nbr_h1bs)

xtset company year

replace viol = round(viol)
replace viol = 1 if viol!=. & viol>0

* Panel restrictions (firms with at least 3 years)
gen run = .
bysort company: replace run = cond(L.run == ., 1, L.run +1)
bysort company: egen maxrun = max(run)
drop if maxrun<3
tsfill, full

* Handle spell structure
tsspell, f(L.maxrun ==.)

bysort company _spell: egen maxspell = max(run)
foreach var in nbr_h1bs hhithreeyearavg ur_rate subcontractor fw_h1bs logh1bs {
  replace `var'=. if maxspell!=maxrun
}

*--- Panel-level: Pr(Violation at time t) ---
xtset company year

* Unweighted
qui probit viol L.c.hhithreeyearavg#L.c.hhithreeyearavg#L.c.hhithreeyearavg##i.subcontractor L.logh1bs i.year, vce(robust)
margins, at(L.hhithreeyearavg=(0(.1)1) subcontractor=(0(1)1)) vsquish post
marginsplot, legend(pos(6) col(2) order(4 "Subcontractor" 3 "Lead Firm")) ///
  plot1opts(lpattern(".")) plot2opts(lpattern("l")) ///
  xtitle(HHI at t-1) ytitle("Pr(Violation at time t)") title("") ///
  saving("$figures/viol_pro.gph", replace)

* Weighted
qui probit viol L.c.hhithreeyearavg#L.c.hhithreeyearavg#L.c.hhithreeyearavg##i.subcontractor L.logh1bs i.year [fw=L.fw_h1bs], vce(robust)
margins, at(L.hhithreeyearavg=(0(.1)1) subcontractor=(0(1)1)) vsquish post
marginsplot, legend(pos(6) col(2) order(4 "Subcontractor" 3 "Lead Firm")) ///
  plot1opts(lpattern(".")) plot2opts(lpattern("l")) ///
  xtitle(HHI at t-1) ytitle("Pr(Violation at time t)") title("") ///
  saving("$figures/viol_pro_wt.gph", replace)

*--- Company-level: Pr(Ever Violate) ---
* Collapse to company level
bysort company: egen everviol = max(viol)
collapse (max) everviol (rawsum) nbr_h1bs (mean) hhithreeyearavg ur_rate subcontractor [fw=fw_h1bs], by(company)

rename everviol viol
lab var viol "Ever Violates"
gen logh1bs=log(nbr_h1bs)
replace nbr_h1bs=round(nbr_h1bs)
replace viol=1 if viol>1

* Unweighted
qui probit viol c.hhithreeyearavg#c.hhithreeyearavg#c.hhithreeyearavg##i.subcontractor logh1bs, vce(robust)
margins, at(hhithreeyearavg=(0(.1)1) subcontractor=(0(1)1)) vsquish post
marginsplot, legend(pos(6) col(2) order(4 "Subcontractor" 3 "Lead Firm")) ///
  plot1opts(lpattern(".")) plot2opts(lpattern("l")) ///
  xtitle(HHI) ytitle("Pr(Ever Violate)") title("") ///
  saving("$figures/viol_pro_co.gph", replace)

* Weighted
qui probit viol c.hhithreeyearavg#c.hhithreeyearavg#c.hhithreeyearavg##i.subcontractor logh1bs [fw=nbr_h1bs], vce(robust)
margins, at(hhithreeyearavg=(0(.1)1) subcontractor=(0(1)1)) vsquish post
marginsplot, legend(pos(6) col(2) order(4 "Subcontractor" 3 "Lead Firm")) ///
  plot1opts(lpattern(".")) plot2opts(lpattern("l")) ///
  xtitle(HHI) ytitle("Pr(Ever Violate)") title("") ///
  saving("$figures/viol_pro_co_wt.gph", replace)

*--- Combine into 4-panel figure ---

graph combine "$figures/viol_pro_co.gph" "$figures/viol_pro_co_wt.gph" "$figures/viol_pro.gph" "$figures/viol_pro_wt.gph"
graph export "$figures/fig5_probs.pdf", replace

di "Figure 5 saved to: $figures/fig5_probs.pdf"

*-------------------------------------------------------------------------------
* FIGURE 4: AVERAGE VIOLATIONS INTENSITY BY HHI, SUBCONTRACTOR, AND SKILL LEVEL
* Source: 2019_find_pay_rates.do lines 351-354
* Verified: Visual match to paper
*
* This figure shows a horizontal bar chart of mean violations intensity
* by HHI category (Low, Moderate, High), subcontractor status (Lead vs Sub),
* and skill level (Low Skill vs High Skill).
*
* REQUIRES: low_skill and hhicat variables (created by prepare_replication_data.do)
*-------------------------------------------------------------------------------

di "===== FIGURE 4: VIOLATIONS INTENSITY BY SKILL LEVEL ====="

use "$data/master_db.dta", clear

* Restrict to observations with skill level data
drop if low_skill == .
di "Observations with skill level data: " _N

* Set scheme
set scheme plotplainblind

    * Create proper labels for the figure
    * low_skill: 0 = High Skill, 1 = Low Skill
    label define skill_lbl 0 "High Skill" 1 "Low Skill", replace
    label values low_skill skill_lbl

    * subcontractor_2019: 0 = Lead Firm, 1 = Subcontractor (from 2019 data)
    label define sub_lbl 0 "Lead Firm" 1 "Subcontractor", replace
    label values subcontractor_2019 sub_lbl

    * hhicat: 1 = Low, 2 = Moderate, 3 = High
    label define hhi_lbl 1 "Low HHI" 2 "Moderate HHI" 3 "High HHI", replace
    label values hhicat hhi_lbl

    * Generate Figure 4: Violations intensity by skill level, subcontractor, HHI
    * ORDER matches original paper: over(low_skill) over(subcontractor) over(hhicat)
    * - Innermost (bars): skill level (High Skill vs Low Skill)
    * - Middle: subcontractor status (Lead Firm vs Subcontractor)
    * - Outermost: HHI category (Low, Moderate, High - descending puts High at top)
    * NOTE: Uses subcontractor_2019 to match original methodology
    graph hbar (mean) logviol, ///
        over(low_skill) over(subcontractor_2019) over(hhicat, descending) ///
        ytitle("Mean Violations Intensity") ///
        legend(order(1 "High Skill" 2 "Low Skill") position(3))

graph export "$figures/fig4_viol_intensity.pdf", replace

di "Figure 4 saved to: $figures/fig4_viol_intensity.pdf"
di ""
di "===== FIGURE GENERATION COMPLETE ====="
di ""
di "Figures generated/available:"
di "  - $figures/fig1_network.pdf (Pre-generated - source data 3.1 GB, contact author)"
di "  - $figures/fig2a_kdensity.pdf (Generated - requires diff_adj variable)"
di "  - $figures/fig2b_prob_viol.pdf (Generated - requires diff_adj variable)"
di "  - $figures/fig3_hhibar.pdf (Generated from master_db.dta)"
di "  - $figures/fig4_viol_intensity.pdf (Generated - requires low_skill variable)"
di "  - $figures/fig5_probs.pdf (Generated from master_db.dta)"
di ""
di "Figures NOT included:"
di "  - Figure 6: Theoretical Model Diagram (manually created, not Stata-generated)"
di "              Contact corresponding author for this figure."
di ""
di "NOTE: Run prepare_replication_data.do first to create comprehensive master_db.dta"
di "      with all merged data and derived variables."
di ""

* End of figures file
