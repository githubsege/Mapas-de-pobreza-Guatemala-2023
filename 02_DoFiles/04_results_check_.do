/*******************************************************************************
* Project:         GUATEMALA - SAE Nivel Municipal + Proyecto con SEGEPLAN
* Sandra Segovia (ssegoviajuarez@worldbank.org)			 
*******************************************************************************/
set more off
clear all 
version     14
set matsize 10000
set seed    648743

********************************************************************************
**# PARTE 0: Importar poblacion asociado al Censo                          			       
********************************************************************************
**# Bookmark #1
use "$input\FHcensus_mun.dta", clear
	sum pop
	di r(sum) //14,857,534  ( es 17,237,068 en la Encovi, necesitamos ajuste?)
	
	keep pop mun depto
	
tempfile pops
save `pops'


********************************************************************************
**# PARTE 1: Importar resultados FH y estimaciones directas                               			       
********************************************************************************
// Importar estimaciones directas nivel depto
* Esto se hace con el proposito de evaluar 
use "$input/direct.dta", clear
	keep if area == "depto"

	// Creacion de intervalos de confianza
	cap gen u_ci = dir_mean+invnormal(0.975)*sqrt(dir_var)
	cap gen l_ci = dir_mean+invnormal(0.025)*sqrt(dir_var)
	
	keep depto indicator dir_mean l_ci* u_ci* 
	
	rename dir_mean direct // renombrar para no confundir con estimacion municipal

	decode depto, gen(depto_name)
	
	tempfile direct_depto
	save `direct_depto'

// Importar estimaciones directas nivel mun	
use "$input/direct.dta", clear
	keep if area == "mun"
	keep mun indicator dir_mean dir_var dir_cv

	tempfile direct_mun
	save `direct_mun'	
	
// Importar estimaciones FH municipal
*clear
*//Append all indicators
*append using "$output/FH_sae_consumo.dta" "$output/FH_sae_fgt0.dta" ///
			 "$output/FH_sae_fgt1.dta" "$output/FH_sae_fgt2.dta"

use "$output/FH_sae_$indi.dta", clear			 
	tempfile fh
	save `fh'		 
	
	// Unir con pop
	merge m:1 mun using `pops'
		drop if _m==2
		drop _m	
	
	// Unir con estimaciones Directas municipal (para evaluacion 2)
	merge 1:1 mun indicator using `direct_mun'
		drop if _m==2
		drop _m
	
	// Unir con estimaciones directas nivel depto
	merge m:1 depto indicator using `direct_depto'
		drop if _m==2
		drop _m

********************************************************************************
**# PARTE 2: Evaluacion FH vs Directas nivel Municipal
********************************************************************************	
	//See the improvement in precision
	
	//Fig 4: Direct vs Small Area Estimates (Left, point) (Right, SE)
	cap gen se=sqrt(dir_var)
	twoway (scatter fh_mean dir_mean) (line fh_mean fh_mean) if indicator == "$indi", ///
	graphregion(color(white)) ytitle(Fay-Herriot) xtitle(Direct estimate) /// 
	legend(off) name("fig4_right_$indi", replace)
	graph export "$figuras\fig4_right_$indi.png", as(png) replace

	twoway (scatter fh_se se) (line se se) if (indicator == "$indi" & se !=.) , ///
	graphregion(color(white)) ytitle(Fay-Herriot (rmse)) xtitle("Direct estimate (SE)") ///
	legend(off) name("fig4_left_$indi", replace)
	graph export "$figuras\fig4_left_$indi.png", as(png) replace

	graph combine fig4_right_$indi fig4_left_$indi, graphregion(color(white)) ///
		  title("Direct vs Small Area Estimates (Left, point) (Right, SE) for $indi") col(2) xsize(12)
	graph export "$figuras\fig4_$indi.png", as(png) replace width(1400) height(800)
	putexcel set "$res", sheet("fig4_$indi", replace) modify
	putexcel A1 = picture("$figuras\fig4_$indi.png")
		
	//Fig 5: Coefficientes de variacion vs fh_mean
	twoway (scatter fh_cv fh_mean) if indicator == "$indi" , graphregion(color(white)) ytitle(Fay-Herriot (CV)) xtitle(Fay-Herriot estimate) title("$indi") yline(20) legend(off) name("fig5_$indi", replace) 
	graph export "$figuras\fig5_$indi.png", as(png) replace 
	putexcel set "$res", sheet("fig5_$indi",replace) modify
	putexcel A1 = picture("$figuras\fig5_$indi.png")
	
********************************************************************************
**# PARTE 3: Evaluacion FH (agregados) vs Directas nivel Departamento
********************************************************************************	
label var depto "Departamento"
label def depto	1 "01. Guatemala" ///
				2 "02. El Progreso" ///
				3 "03. Sacatepéquez" ///
				4 "04. Chimaltenango" ///
				5 "05. Escuintla" ///
				6 "06. Santa Rosa" ///
				7 "07. Sololá" ///
				8 "08. Totonicapán" ///
				9 "09. Quetzaltenango" ///
				10 "10. Suchitepéquez" ///
				11 "11. Retalhuleu" ///
				12 "12. San Marcos" ///
				13 "13. Huehuetenango" ///
				14 "14. Quiché" ///
				15 "15. Baja Verapaz" ///
				16 "16. Alta Verapaz" ///
				17 "17. Petén" ///
				18 "18. Izabal" ///
				19 "19. Zacapa" ///
				20 "20. Chiquimula" ///
				21 "21. Jalapa" ///
				22 "22. Jutiapa" , modify
label val depto depto
cap drop depto_name
decode depto, gen(depto_name)
sort depto
preserve
	
	groupfunction [aw=pop] if indicator == "$indi", rawsum(pop) mean(fh_mean direct *_ci) ///
							first(depto) by(depto_name)
	sort depto
	//Figure 6: Aggregate Fay Herriot Estimates to Region Level and Direct Estimates' 95CI						 
	graph dot (asis) fh_mean u_ci l_ci, over(depto_name) marker(2, mcolor(red) msymbol(diamond)) ///
		  marker(3, mcolor(red) msymbol(diamond)) graphregion(color(white)) title("$indi") ///
	legend(order(1 "Fay Herriot" 2 "Direct estimate CI (95%)") cols(1)) 
	graph export "$figuras\fig6_$indi.png", as(png) replace
	putexcel set "$res", sheet("fig6_$indi",replace) modify
	putexcel A1 = picture("$figuras\fig6_$indi.png")  
	
	// Tabla con los valores presentados en la grafica anterior
	label var direct  "Directo" 
	label var fh_mean "Fay-Herriot" 
	label var u_ci "Upper bound" 
	label var l_ci "Lower bound" 
	
	keep depto_name direct l_ci u_ci fh_mean
	order depto_name direct l_ci u_ci fh_mean
	
	//Cambio de formato para leer mejor
	format direct l_ci u_ci fh_mean %4.3f
	export excel using "$res", sheet("tab2_$indi") first(variable) sheetreplace
restore

********************************************************************************	
**#  PARTE 4: Tabla con todos los indicadores para todos los municipios
********************************************************************************	
sort depto mun
keep if indicator =="$indi"
gen muncode = mun
order indicator depto muncode mun pop fh_mean 

keep indicator depto muncode mun pop fh_mean fh_se fh_cv
gen numpoor = pop*fh_mean if "$indi" == "fgt0"

*gen u_ci_fh = min(1,fh_mean+invnormal(0.975)*fh_se)
*gen l_ci_fh = max(0,fh_mean+invnormal(0.025)*fh_se)

gen u_ci_fh = fh_mean + invnormal(0.975) * fh_se 
gen l_ci_fh = fh_mean - invnormal(0.975) * fh_se

//Indicate significantly more or less poor than deptos
gen sig_diff = "Significantly more poor than the region average" if l_ci_fh>u_ci & "$indi" == "fgt0"
replace sig_diff = "Significantly less poor than the region average" if u_ci_fh<l_ci & "$indi" == "fgt0"

order indicator depto muncode mun pop fh_mean fh_se l_ci u_ci numpoor 

//Cambio de formato para leer mejor
format fh_mean fh_se l_ci u_ci %4.3f
export excel using "$res", sheet("tab3_$indi") first(variable) sheetreplace






