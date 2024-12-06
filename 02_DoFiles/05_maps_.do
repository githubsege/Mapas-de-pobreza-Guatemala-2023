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
**# PARTE 1: Importar shapefiles                                  			       
********************************************************************************
//Nivel Municipal
shp2dta using "$shape\gtm_adm_ocha_conred_2019_SHP\gtm_admbnda_adm2_ocha_conred_20190207.shp", data($shape\mun_level_db) ///
coor($shape\mun_level_coord) genid(id) replace

//Nivel Departamento
shp2dta using "$shape\gtm_adm_ocha_conred_2019_SHP\gtm_admbnda_adm1_ocha_conred_20190207.shp", data($shape\depto_level_db) ///
coor($shape\depto_level_coord) genid(id) replace

********************************************************************************
**# PARTE 2:  Mapas - Indicadores de pobreza                    			       
********************************************************************************
local indicators consumo fgt0 fgt1 fgt2 
foreach indi in `indicators' {		
	di "`indi'"	
	
	**# Mapas nivel municipal (SAE Fay-Harriot )
	use "$shape\mun_level_db.dta", clear
	rename *, lower

	//Crear nueva variable sin prefijo "GT"
	gen mun = subinstr(adm2_pcode, "GT", "", .)
	destring mun, replace	
	//Unir con estimacionaes
	merge 1:1 mun using "$output\FH_sae_`indi'.dta", keep(match)
	drop _merge

	//Cambio de formato para leer mejor
	format fh_mean %3.2f
		
	//Mapa
	spmap fh_mean using "$shape\mun_level_coord", id(id) fcolor(Reds2) ///
			  ocolor(gray ..) legt("`indi'") legstyle(2) legend(pos(5)) clnum(8) ///
			  line(data("$shape\depto_level_coord") size(medthin) color(black))  
	graph export "$figuras\map_mun_fh_`indi'.png", replace
	
}

	
**# Mapas nivel departamento (Directas)
	use "$input\direct.dta", clear
		keep if  area =="depto"
		drop nat mun
		tempfile direct
		save `direct'
	
	use "$shape\depto_level_db.dta", clear
		rename *, lower

		// Crear nueva variable sin prefijo "GT"
		gen depto = subinstr(adm1_pcode, "GT", "", .)
		destring depto, replace

		// Unir con estimaciones
		merge 1:m depto using "`direct'"

		// Cambio de formato para leer mejor
		format dir_mean %3.2f
		
		// Escoger un esquema 
		set scheme white_tableau
		
		// Generate cute color palettes
		colorpalette viridis, n(12) nograph reverse
		local colors `r(p)'

	levelsof indicator, local(indicators)	
		foreach indi in `indicators' {		
		di "`indi'"
		
		spmap dir_mean using "$shape\depto_level_coord" if indicator =="`indi'", id(id) fcolor(Reds2) ///
				legt("`indi'") legstyle(2) legend(pos(5)) clnum(8)    
		graph export "$figuras\map_depto_dir_`indi'.png", replace
	
	}

exit
	
