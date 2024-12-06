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
**#			         PARTE 1: Preparar Bases ENCOVI 2023                        
********************************************************************************
/* En la carpea "raw" se debe crear una carpeta 
"Censo2018" para contener todos las bases de CENSO 2018, y además
"Encovi2023" para contener la base del Agregado de Consumo de la ENCOVI 2023

Este proceso convierte las bases en SPSS a STATA.  Sólo funciona en STATA 18 
*/

cd "$raw\Encovi2023"

// Verificación Base de ENCOVI 2023 - Agregado de Consumo
local file "$raw\Encovi2023\35.ENCOVI.2023_Agregado.Consumo.dta"

// Verifica si el archivo existe en el directorio completo
cap confirm file "`file'"
if !_rc {
    di "El archivo `file' existe en la carpeta"
} 
else {
    local file "$raw\Encovi2023\35.ENCOVI.2023_Agregado.Consumo.sav"
	cap confirm file "`file'"
	if !_rc {
		* Se prepara la base de datos "dta" para el agregado de consumo
		import spss using "35.ENCOVI.2023_Agregado.Consumo.sav", case(preserve) clear
		rename *, lower
		compress
		save "35.ENCOVI.2023_Agregado.Consumo.dta"
	}
	else {
		di "El archivo `file' no existe en la carpeta y no se puede continuar"
		exit
		exit
	}
}



********************************************************************************
**#		               	PARTE 2: Preparar Bases CENSO 2018                      
********************************************************************************

cd "$raw\Censo2018"

// Verificación Base de Censo 2018 - Viviendas
local file "$raw\Censo2018\Vivienda.dta"

// Verifica si el archivo existe en el directorio completo
cap confirm file "`file'"
if !_rc {
    di "El archivo `file' existe en la carpeta"
} 
else {
    local file "$raw\Censo2018\VIVIENDA_BDP.sav"
	cap confirm file "`file'"
	if !_rc {
		* Se prepara la base de datos "dta" para viviendas
		import spss using "VIVIENDA_BDP.sav", case(preserve) clear
		drop Long
		drop Lat
		rename *, lower
		compress
		save "Vivienda.dta"

	}
	else {
		di "El archivo `file' no existe en la carpeta y no se puede continuar"
		exit
		exit
	}
}


cd "$raw\Censo2018"

// Verificación Base de Censo 2018 - Hogar
local file "$raw\Censo2018\Hogar.dta"

// Verifica si el archivo existe en el directorio completo
cap confirm file "`file'"
if !_rc {
    di "El archivo `file' existe en la carpeta"
} 
else {
    local file "$raw\Censo2018\HOGAR_BDP.sav"
	cap confirm file "`file'"
	if !_rc {
		* Se prepara la base de datos "dta" de hogares
		import spss using "HOGAR_BDP.sav", case(preserve) clear
		drop LUGAR_POBLADO
		drop NOMBRE_LUGAR_POBLADO
		drop Long
		drop Lat
		rename *, lower
		compress
		save "Hogar.dta"
	}
	else {
		di "El archivo `file' no existe en la carpeta y no se puede continuar"
		exit
		exit
	}
}


cd "$raw\Censo2018"

// Verificación Base de Censo 2018 - Migración
local file "$raw\Censo2018\Migracion.dta"

// Verifica si el archivo existe en el directorio completo
cap confirm file "`file'"
if !_rc {
    di "El archivo `file' existe en la carpeta"
} 
else {
    local file "$raw\Censo2018\MIGRACION_BDP.sav"
	cap confirm file "`file'"
	if !_rc {
		* Se prepara la base de datos "dta" para migración
		import spss using "MIGRACION_BDP.sav", case(preserve) clear
		rename *, lower
		compress
		save "Migracion.dta"
	}
	else {
		di "El archivo `file' no existe en la carpeta y no se puede continuar"
		exit
		exit
	}
}


cd "$raw\Censo2018"

// Verificación Base de Censo 2018 - Personas
local file "$raw\Censo2018\Personas.dta"

// Verifica si el archivo existe en el directorio completo
cap confirm file "`file'"
if !_rc {
    di "El archivo `file' existe en la carpeta"
} 
else {
    local file "$raw\Censo2018\PERSONA_BDP.sav"
	cap confirm file "`file'"
	if !_rc {
		* Se prepara la base de datos "dta" para el agregado de consumo
		import spss using "PERSONA_BDP.sav", case(preserve) clear
		drop LUGAR_POBLADO
		drop NOMBRE_LUGAR_POBLADO
		drop Long
		drop Lat
		rename *, lower
		compress
		save "Personas.dta"
	}
	else {
		di "El archivo `file' no existe en la carpeta y no se puede continuar"
		exit
		exit
	}
}

exit
