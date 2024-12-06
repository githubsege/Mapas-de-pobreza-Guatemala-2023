cap log close
log using "$output\modelo_$indi", replace
/*******************************************************************************
* Project:         GUATEMALA - SAE Nivel Municipal + Proyecto con SEGEPLAN
* Sandra Segovia (ssegoviajuarez@worldbank.org)		
* Based on Guidelines  for Poverty Mapping (Corral, Molina, Cojocaru, Segovia)	 
*******************************************************************************/
set more off
clear all

version 15
set matsize 8000
set seed 648743
********************************************************************************
**#					PARTE 1: Importar covariables
********************************************************************************
use "$input\FHcensus_mun.dta", clear
// Normalizar covariables
unab covars: mun_* depto_*
	foreach x of local covars {
		qui: sum `x'
		replace `x' = (`x' - r(mean))/r(sd)
	}

	
	// Crear un loop para etiquetar variables automáticamente
	foreach var of varlist mun_* {
		local newname = substr("`var'", 5, .)  // Eliminar los primeros 4 caracteres ("mun_")
		label var `var' "`newname' (nivel mun)"
	}
	foreach var of varlist depto_* {
		local newname = substr("`var'", 7, .)  // Eliminar los primeros 4 caracteres ("mun_")
		label var `var' "`newname' (nivel depto)"
	}

		
	tempfile census
	save `census', replace

	//importar estimaciones directas	
	use "$input\direct.dta", clear
		
		keep if indicator == "$indi" & area == "mun"
		keep mun num_psu N N_hhsize popw hhw mean dir_* zero		
		merge 1:1 mun using `census'
		drop _merge

********************************************************************************
**#					PARTE 2: Seleccion del modelo
********************************************************************************

********************************************************************************
**# Identifcar coeficientes diferentes a 0	
********************************************************************************		
	
	// Drop por dimensiones, causando estimaciones>1
	drop depto_tot_* mun_tot_* 
	drop mun_jefe_secundaria mun_p_secundaria 
		
	//Crear un macro  para almacenar variables con coeficientes diferentes de cero
	unab vars: mun_* depto_*  
	reg dir_mean `vars' 
	local vars_no_cero ""
	foreach var of varlist `vars' {
		// Verificar si el coeficiente no es cero
		if _b[`var'] != 0 {
			local vars_no_cero "`vars_no_cero' `var'"
		}
	}

	//Mostrar covariables con coeficientes diferentes de cero
	glo vars_no_cero `vars_no_cero'
	macro list 	 vars_no_cero
	di `: list sizeof global( vars_no_cero)' 
	
	// Ver modelo con covariables vars_no_cero
	fhsae dir_mean $vars_no_cero, revar(dir_var) method(fh) 

********************************************************************************		
**# Remover variables no significativas (primer round)
********************************************************************************
	
	local hhvars $vars_no_cero
	//Remover variables no significativas
	forval z= 0.8(-0.05)0.05{
		qui: fhsae dir_mean `hhvars', revar(dir_var) method(fh) nonegative
		mata: bb=st_matrix("e(b)")
		mata: se=sqrt(diagonal(st_matrix("e(V)")))
		mata: zvals = bb':/se
		mata: st_matrix("min",min(abs(zvals)))
		local zv = (-min[1,1])
		if (2*normal(`zv')<`z') exit	
		foreach x of varlist `hhvars'{
			local hhvars1
			qui: fhsae dir_mean `hhvars', revar(dir_var) method(fh) nonegative
			qui: test `x' 
			if (r(p)>`z'){
				local hhvars1
				foreach yy of local hhvars{
					if ("`yy'"=="`x'") dis ""
					else local hhvars1 `hhvars1' `yy'
				}
			}
			else local hhvars1 `hhvars'
			local hhvars `hhvars1'		
		}
	}	

	//Mostrar covariables postsign
	global postsign `hhvars'
	macro list 	postsign
	di `: list sizeof global(postsign)'  

	// Ver modelo con covariables postsign
	fhsae dir_mean ${postsign}, revar(dir_var) method(fh)


********************************************************************************
**# Remover variables con VIF>5 
********************************************************************************
			
	//Checar VIF
	reg dir_mean $postsign, r
	gen touse = e(sample)
	gen weight = 1
	mata: ds = _f_stepvif("$postsign","weight",5,"touse") 
			
	global postvif `vifvar'
	macro list 	postvif
	di `: list sizeof global(postvif)'  

	//Ver modelo con covariables postvif
	fhsae dir_mean ${postvif}, revar(dir_var) method(fh)
	
********************************************************************************		
**# Remover variables no significativas (segundo round)
********************************************************************************

	local hhvars $postvif
	//Remover variables no significativas
	forval z= 0.8(-0.05)0.0001{
		qui:fhsae dir_mean `hhvars', revar(dir_var) method(reml) precision(1e-10)
		mata: bb=st_matrix("e(b)")
		mata: se=sqrt(diagonal(st_matrix("e(V)")))
		mata: zvals = bb':/se
		mata: st_matrix("min",min(abs(zvals)))
		local zv = (-min[1,1])
		if (2*normal(`zv')>=`z'){
			foreach x of varlist `hhvars'{
				local hhvars1
				qui: fhsae dir_mean `hhvars', revar(dir_var) method(reml) precision(1e-10)
				qui: test `x' 
				if (r(p)>`z'){
					local hhvars1
					foreach yy of local hhvars{
						if ("`yy'"=="`x'") dis ""
						else local hhvars1 `hhvars1' `yy'
					}
				}
				else local hhvars1 `hhvars'
				local hhvars `hhvars1'		
			}
		}
	}
	
	//Mostrar covariables finales
	global last `hhvars'
	macro list 	last
	di `: list sizeof global(last)'  
	
********************************************************************************	
**# Obtener estimaciones Fay-Herriot	
********************************************************************************	

	fhsae dir_mean  $last, revar(dir_var) method(chandra) fh(fh_mean) area(fh_area) ///
	fhse(fh_se) fhcv(fh_cv) gamma(fh_gamma) out noneg precision(1e-13) 

	// Exportar Regresion del modelo final
	etable, title("Tabla 1: Regresion indicator $indi") ///
	mstat(N, label("Number of observations ")) ///
	mstat(r2_a, label("Adjusted R-squared")) /// 
	mstat(r2, label("R-squared")) ///
	mstat(sigma2u, label("")) ///
	mstat(F_beta, label("F statistic ")) ///
	showstars showstarsnote ///
	note("Notas: ") notestyles(font(Calibri, size(10) italic)) ///
	export("$res", sheet("tab1_$indi") modify cell(A1))
	
	//Check normal errors
	predict xb
		
	//Definir efectos del modelo  // debe ser igual a la variable fh_area con el metodo Chandra
	gen u_d = fh_mean - xb
	lab var u_d "FH area effects"
		
	//Definir residuales del modelo 
	gen e_d = dir_mean - fh_mean
	lab var e_d "FH errors"
		
	//Fig 1: Fay-Herriot Residual Plots (Histogramas)
	histogram u_d, normal graphregion(color(white))  ///
				   leg(off) legend(pos(2) ring(0) col(1)) name("fig1_right_$indi", replace)
	graph export "$figuras\fig1_left_$indi.png", as(png) replace
		
	histogram e_d, normal graphregion(color(white)) name("fig1_left_$indi", replace)
	graph export "$figuras\fig1_right_$indi.png", as(png) replace
		
	graph combine fig1_right_$indi fig1_left_$indi, graphregion(color(white)) ///
	title("Residuales $indi (Histograma)") col(2) xsize(12)
	graph export "$figuras\fig1_$indi.png", as(png) replace width(1400) height(800)
	putexcel set "$res", sheet("fig1_$indi", replace) modify
	putexcel A1 = picture("$figuras\fig1_$indi.png")
	
	//Fig 2: Fay-Herriot Residual Plots (Q-Q Plot)
	qnorm u_d, graphregion(color(white)) name("fig2_right_$indi", replace)
	graph export "$figuras\fig2_right_$indi.png", as(png) replace
		
	qnorm e_d, graphregion(color(white)) name("fig2_left_$indi", replace)
	graph export "$figuras\fig2_left_$indi.png", as(png) replace
		
	graph combine fig2_right_$indi fig2_left_$indi, graphregion(color(white)) ///
	title("Residuales $indi (Q-Q)") col(2) xsize(12)
	graph export "$figuras\fig2_$indi.png", as(png) replace width(1400) height(800)
	putexcel set "$res", sheet("fig2_$indi", replace) modify
	putexcel A1 = picture("$figuras\fig2_$indi.png")
		
	//Fig 3: Direct vs Small Area Estimates (Left, point) (Right, SE)
	cap gen se=sqrt(dir_var)
	twoway (scatter fh_mean dir_mean) (line fh_mean fh_mean), ///
	graphregion(color(white)) ytitle(Fay-Herriot) xtitle(Direct estimate) /// 
	legend(off) name("fig3_right_$indi", replace)
	graph export "$figuras\fig3_right_$indi.png", as(png) replace

	twoway (scatter fh_se se) (line se se), ///
	graphregion(color(white)) ytitle(Fay-Herriot (rmse)) xtitle("Direct estimate (SE)") ///
	legend(off) name("fig3_left_$indi", replace)
	graph export "$figuras\fig3_left_$indi.png", as(png) replace

	graph combine fig3_right_$indi fig3_left_$indi, graphregion(color(white)) ///
		  title("Direct vs Small Area Estimates (Left, point) (Right, SE) for $indi") col(2) xsize(12)
	graph export "$figuras\fig3_$indi.png", as(png) replace width(1400) height(800)
	putexcel set "$res", sheet("fig3_$indi", replace) modify
	putexcel A1 = picture("$figuras\fig3_$indi.png")
		
	//Coefficients of variation
	twoway (scatter fh_cv fh_mean), graphregion(color(white)) ///
	ytitle(Fay-Herriot (CV)) xtitle(Fay-Herriot estimate) title("$indi") yline(20) legend(off) 
	graph export "$figuras\cv_$indi.png", as(png) replace
	
	cap gen dir_cv = (sqrt(dir_var)/dir_mean)*100
	sum dir_cv fh_cv
		
	gen cv_menor20_dir = (dir_cv<20) if dir_mean !=. 
	gen cv_menor20_fh  = (fh_cv<20)
	
	//Check results
	sum fh_*
	sum dir_*
	sum cv_* 

	keep depto mun fh_* 
	gen indicator = "$indi"	

save "$output\FH_sae_$indi.dta", replace
	
cap log close		

