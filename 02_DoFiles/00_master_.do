/*******************************************************************************
* Project:         GUATEMALA - SAE Nivel Municipal + Proyecto con SEGEPLAN
* Sandra Segovia (ssegoviajuarez@worldbank.org)	
*
* Se debe ubicar las bases SPSS del CENSO en la carpeta Censo2018 dentro de $raw
* Se debe ubicar las bases SPSS de la ENCOVI en la carpeta Encovi2023 dentro de $raw
*
* Se ejecuta opcionalmente el 00_prepara_bases_ss     para preparar bases SPSS, 
* necesario sólo la primera vez, quitar el "*" para que lo ejecute
* Se ejecuta opcionalmente el 01_dataprep_encuesta_	para crear indicadores directos,
* quitar el "*" para que lo ejecute
* Se ejecuta opcionalmente el 05_maps_				para hacer los mapas (al final),
* quitar el "*" para que lo ejecute
*******************************************************************************/
set more off
clear all 
version     14
set matsize 10000
set seed    648743

********************************************************************************
**#					PART 0: Instalar paquetes necesarios
********************************************************************************
//Definir una lista de programas
local programas groupfunction fhsae ereplace shp2dta spmap sae

//Verificar existencia de cada programa
foreach prog of local programas {
    //Comprobar si el programa existe
    cap which `prog'
    
    //Si no existe, instalarlo
    if _rc {
        di "`prog' no está instalado. Instalando..."
        ssc install `prog'
    }
    else {
        di "`prog' ya está instalado."
    }
}

********************************************************************************
**#				PARTE 1: Directorios y macros
********************************************************************************

//Escoge el directorio / espacio en donde vayas a trabajar
global main "c:\Mapas de pobreza" 

// Crear estructura de folders
//Para los datos
cap mkdir  "$main\01_Data\raw"
cap mkdir  "$main\01_Data\input"
cap mkdir  "$main\01_Data\output"
cap mkdir  "$main\01_Data\temp"

//Para codigos y otros
cap mkdir  "$main\02_Dofiles"
cap mkdir  "$main\03_Literatura"
cap mkdir  "$main\04_Resultados"
cap mkdir  "$main\05_Figuras"

* Nota: Asegurate de depositar los datos de la ENCOVI y Censo en la carpeta de Datos antes de empezar

//Crear globales para folders para facil acceso
global raw	  	  "$main\01_Data\raw"
global input	  "$main\01_Data\input"
global temp		  "$main\01_Data\temp"
global output	  "$main\01_Data\output"
global shape	  "$main\01_Data\shapefiles"
global dofiles 	  "$main\02_Dofiles"
global resultados "$main\04_Resultados"
global figuras 	  "$main\05_Figuras"


// Excel File en donde se van a guardar los resultados
global res  "$output\resultados.xlsx"


********************************************************************************
**#							PARTE 2: Programas				       
********************************************************************************

// Preparación de datos para los cálculos
do "$dofiles\00_prepara_bases_"
do "$dofiles\01_dataprep_encuesta_.do"
do "$dofiles\02_dataprep_censo_.do"

//Para correr todos los indicadores 
local indicators fgt0 fgt1 fgt2 consumo
foreach indi of local indicators {	
	di "`indi'"
	global indi = "`indi'"
	noi di "$indi"
		do "$dofiles\03_FH_model_select_"
		do "$dofiles\04_results_check_"
}

* Elaboración de los mapas
do "$dofiles\05_maps_.do"	

// Nota: Si quieren correr solo un indicador
*global indi "fgt0"   // Escoger entre fgt0, fgt1, fgt2, o consumo


********************************************************************************
**#						PARTE 3: ......			       
********************************************************************************


	
exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1. 
2.
3.


Version Control: version 01
