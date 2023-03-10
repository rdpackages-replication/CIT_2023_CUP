**----------------------------------------------------------------------------**
** A Practical Introduction to Regression Discontinuity Designs: Extensions
** Authors: Matias D. Cattaneo, Nicolás Idrobo and Rocío Titiunik
** Last update: 2023-01-21
**----------------------------------------------------------------------------**
** SOFTWARE WEBSITE: https://rdpackages.github.io/
**----------------------------------------------------------------------------**
** TO INSTALL STATA PACKAGES:
** net install rdrobust, ///
**	from("https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata") replace
**
** net install rdlocrand, ///
**	from("https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata") replace
**
** net install rddensity, ///
**	from("https://raw.githubusercontent.com/rdpackages/rddensity/master/stata") replace
**
** net install rdmulti, ///
**	from("https://raw.githubusercontent.com/rdpackages/rdmulti/master/stata") replace
**
** net install rdpower, ///
**	from("https://raw.githubusercontent.com/rdpackages/rdpower/master/stata") replace
**
** net install lpdensity, ///
**		from("https://raw.githubusercontent.com/nppackages/lpdensity/master/stata") replace
**
** ssc install mmerge
**----------------------------------------------------------------------------**

clear
clear all
clear matrix
cap log close
set more off

***********************************************************
***********************************************************
***********************************************************
********* Section 5: Multi-Dimensional RD Designs *********
********* Geographic Empirical Application        *********
***********************************************************
***********************************************************
***********************************************************

**------------------**
** Loading the data **
**------------------**
use "CIT_2023_CUP_multiscore-geo.dta", clear

**--------------------------------------------------------**
** Table 5.3                                              **
** Descriptive statistics for the Keele and Titiunik data **
**--------------------------------------------------------**
# delimit ;
	global sumstats "e2008g treated latitude longitude age black hisp dem
		female dist1 dist2 dist3 perp_dist";
# delimit cr
matrix define R = J(13, 6, .)
local k = 1
foreach x of global sumstats {
	local label_`k': variable label `x'
	summarize `x', detail

	matrix R[`k', 1] = r(mean)
	matrix R[`k', 2] = r(p50)
	matrix R[`k', 3] = r(sd)
	matrix R[`k', 4] = r(min)
	matrix R[`k', 5] = r(max)
	matrix R[`k', 6] = r(N)
	local k = `k' + 1
}

preserve
	clear
	local t = `k' - 1
	svmat R
	gen R0 = ""
	forvalues k = 1 / `t' {
		replace R0 = "`label_`k''" if _n == `k'
	}
	order R0
	save "outputs/Vol-2-STATA_kt_descstats.dta", replace
restore

* Multiplying distances by -1 for control units
foreach x of varlist dist1 dist2 dist3 perp_dist {
	replace `x'=(-1)*`x' if treated==0
}

**----------------------------------------------**
** Figure 5.7                                   **
** Treated and control areas in a geographic RD **
**----------------------------------------------**
global b1_lon = -74.61789
global b1_lat =  40.32489
global b2_lon = -74.60335
global b2_lat =  40.32037
global b3_lon = -74.59191
global b3_lat =  40.31497	
  
twoway (scatter longitude latitude if treated == 0, ///
			msize(tiny) mcolor(ebblue) msymbol(O) ///
			ytitle("Longitude") xtitle("Latitude")) ///
       (scatter longitude latitude if treated == 1, ///
       		msize(tiny) mcolor(cranberry) msymbol(O)) ///
	(line long_border lat_border, lcolor(black) lwidth(medthick)) ///
	(scatteri $b1_lon $b1_lat, msize(medlarge) mcolor(black) msymbol(O)) ///
	(scatteri $b2_lon $b2_lat, msize(medlarge) mcolor(black) msymbol(T)) ///	   
    (scatteri $b3_lon $b3_lat, msize(medlarge) mcolor(black) msymbol(S)), ///
	graphregion(color(white)) ylabel(,angle(0) nogrid) ///
	legend(order(1 2 3 4 5 6) lab(1 "Control") lab(2 "Treated") ///
		lab(3 "Boundary") lab(4 "b1") lab(5 "b2") lab(6 "b3") ///
		position(4) ring(0) col(2) region(lwidth(none)) size(small) ///
		symxsize(0.025in))
graph export "outputs\Vol-2-kt-GeoRD-plot.pdf", as(pdf) replace   

**--------------------------------------------------------**
** Figure 5.8                                             **
** Histograms of chordal distance for control and treated **
**--------------------------------------------------------**
gen disCho_b2=abs(dist2)

* Panel a: Treated observations
twoway (histogram disCho_b2 if treated==1, freq colo(ebblue%60)), ///
	graphregion(color(white)) ylabel(,angle(0) nogrid format(%12.0fc)) ///
	xtitle("Chordal distance to b2")

* Panel b: Control observations
twoway (histogram disCho_b2 if treated==0, freq colo(ebblue%60)), ///
	graphregion(color(white)) ylabel(,angle(0) nogrid format(%12.0fc)) ///
	xtitle("Chordal distance to b2")

**-----------------------------------**
** Snippet 5.12                      **
** Using rdrobust with respect to b2 **
**-----------------------------------**
sjlog using "outputs/Vol-2-STATA_kt_rdrobust_cutoff2", replace
	rdrobust e2008g dist2
sjlog close, replace logfile smclfile

**------------------------------------------**
** Snippet 5.13                             **
** Using rdms and the three boundary points **
**------------------------------------------**
sjlog using "outputs/Vol-2-STATA_kt_rdms_basic", replace
	rdms e2008g latitude longitude treat, cvar(lat_cutoff long_cutoff) 
sjlog close, replace logfile smclfile

**-------------------------------------------**
** Snippet 5.14                              **
** Using rdms and the perpendicular distance **
**-------------------------------------------**
sjlog using "outputs/Vol-2-STATA_kt_rdms_perpdist", replace
	rdms e2008g latitude longitude treat, cvar(lat_cutoff long_cutoff) xnorm(perp_dist)
sjlog close, replace logfile smclfile

**-----------------------------------------------**
** Snippet 5.15                                  **
** Using rdrobust and the perpendicular distance **
**-----------------------------------------------**
sjlog using "outputs/Vol-2-STATA_kt_rdrobust_perpdist", replace
	rdrobust e2008g perp_dist
sjlog close, replace logfile smclfile

*------------------------------------------------------------------------------*
clear all
