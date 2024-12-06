cap log close
log using "$output\direct", replace
/*******************************************************************************
* Project:         GUATEMALA - SAE Nivel Municipal + Proyecto con SEGEPLAN
* Sandra Segovia (ssegoviajuarez@worldbank.org)			 
* Estimadores Directos
*******************************************************************************/
set more off
clear all 
version     14 
set matsize 10000
set seed    648743
set type double, permanently 



* Frames allow you to simultaneously store multiple datasets in memory
frame reset
* More intuitive name to current default frame
frame rename default this_survey
* Create new frame where we are gonna store our results
frame create results

********************************************************************************
**# Estimadores directos                                     			       
********************************************************************************

// Abrir encuesta (solo seccion de agregado de consumo)
use "$raw\Encovi2023\35.ENCOVI.2023_Agregado.Consumo.dta", clear

	//Renombrar todas las variables en minusculas para mayor facilidad
	rename *, lower
	
	keep depto mupio dominio region area upm no_hogar ///
		 factor personas agreg3 linea_extrema ///
		 linea_total 
	
	
	//Factor de expansión de hogares con agregado de consumo
	rename factor hhw
	sum hhw,d	 // has to sum up to ~4,064,261
	return list
	di  r(sum)	
	
	// Tamano de hogar
	rename personas hhsize
	
	//Factor de expansión de personas 
	gen popw = hhw*hhsize  
	sum popw,d	 // has to sum up to 17,237,068
	return list
	di  r(sum)	 

	//Consumo
	rename agreg3 consumo
	
	//Crear identificadores para el area (municipio)
	//Guatemala está dividida en 22 departamentos, 340 municipios
	rename mupio mun
	gen dcode = depto
	gen mcode = mun
	
	rename no_hogar hhid
	rename upm psu
	recode area (1 = 1 "urbano") (2 = 0 "rural"), gen(urban)
	
	keep hhw popw hhsize consumo depto mun dominio region urban psu ///
		 linea_* hhid dcode mcode

	//Calcular FGTs
	forval a=0/2{
		gen fgt`a' = (consumo<linea_total)*(1-consumo/(linea_total))^`a' if !missing(consumo)
	}
	
	//Chequeo rapido de las tasas 
	sum fgt0 [aw=popw] //.5604126
	sum fgt0 [aw=popw] if urban==1 // urbano .4665527
	sum fgt0 [aw=popw] if urban==0 // rural  .6637295
	
	*gen fgt0_ext = (consumo  < linea_extrema) if !missing(consumo)
	*sum fgt0_ext [aw=popw] // .162366
	*sum fgt0_ext [aw=popw] if urban==1 // urbano .0879438 
	*sum fgt0_ext [aw=popw] if urban==0 // rural  .2442867


	// Contar observations para los diferentes niveles
	gen N = 1 			   	//# de Hogares
	gen N_hhsize = hhsize  	//# de Individuos
	egen num_psu = tag(region depto mun psu)  // # de PSUs
	egen num_mun = tag(region depto mun)      // # de Municipios  

	// Diseno muestral
	svyset psu [pw=popw], strata(depto) 
	
	// Generalizar proceso. 
	// Nota: Usar proporcion o media nos da los mismos resultados (excepto en 
	// los intervalos de confianza (diff en milesimas) pero esos los podemos modificar posteriormente), con la ventaja,
	// que podemos generalizar el proceso para calculo de diferentes indicadores
	// en este caso, calcularemos FGT0, FGT1, FGT2 e Ingreso medio

	**# Bookmark #1
	* Change to original frame
	frame change this_survey
	gen nat = 0
	la def nat 0 "Guatemala", modify
	la val nat nat 
	local weight "popw"
	unab variables: consumo fgt*
	local areas nat depto mun
	foreach var of local variables {	
		foreach area in `areas' {
		
			* Create a new frame for each outcome variable
			frame change this_survey
			frame copy this_survey to_collapse, replace
			frame change to_collapse	
			********************************************************************
			di "`area'"
			di "`var'"
				
			* Mean estimate of outcome variable 
			svy: mean `var', over(`area')
			
			* Extract estimates and their variance
			mata: `var' = st_matrix("e(b)")
			mata: `var' = `var'[1..`e(N_over)']'
			mata: `var'_var = st_matrix("e(V)")
			mata: `var'_var = diagonal(`var'_var)[1..`e(N_over)']
			
			
			groupfunction [aw =`weight'], rawsum(`weight' N hhw N_hhsize num_mun num_psu) ///
			mean(`var') by(`area') 

			sort `area'
			* Pull results from Mata to Stata
			getmata dir_`var' = `var' dir_`var'_var = `var'_var, force	 
			replace dir_`var'_var = . if dir_`var'_var == 0
			replace dir_`var' = . if missing(dir_`var'_var)
		
			* Renaming vars 
			gen indicator	= "`var'"
			rename  `var' mean
			gen area 	= "`area'"	
			gen area_val = `area' 
			*drop "`area'"
			rename dir_`var' dir_mean
			rename dir_`var'_var dir_var
			
			* Coefficent of variation
			gen dir_cv = sqrt(dir_var)/dir_mean*100
			
			* Clean and save all the appended results
			tempfile justcollapsed
			save `justcollapsed', replace
			frame results: append using `justcollapsed', force
				
			* Back to original dataset
			frame change this_survey 
		}
	}

	
	
* See results
frame change results

gen zero = dir_mean //original variable with direct estimates


order area area_val nat depto mun 
order indicator mean dir_mean dir_var dir_cv, last

* Save / export data 
save "$input\direct.dta", replace
export excel using "$output\sae_results.xlsx", firstrow(variables) ///
			 sheet("direct", replace) keepcellfmt 

cap log close			 
exit