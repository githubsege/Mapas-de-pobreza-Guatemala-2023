/*******************************************************************************
* Project:         GUATEMALA - SAE Nivel Municipal + Proyecto con SEGEPLAN
* Sandra Segovia (ssegoviajuarez@worldbank.org)			 
*******************************************************************************/
set more off
clear all 
version     14 
set matsize 10000
set seed    648743
set rmsg on
********************************************************************************
**#					PARTE 1: Base Hogar
********************************************************************************	

use "$raw\Censo2018\Hogar.dta", clear

	//Renombrar variables geograficas / locacion
	rename municipio mun
	rename departamento depto
	recode area (1 = 1 "urbano") (2 = 0 "rural"), gen(urban)
	
	* ID hogar
	
	
	* Tipo de vivienda
	/* PCH1	9	¿La vivienda que ocupa este hogar es:
	1	Propia pagada totalmente
	2	Propia pagándola a plazos
	3	Alquilada
	4	Cedida o prestada
	5	Propiedad comunal
	6	Otra condición
    */
	gen tipo_viv = pch1
	* Nota: variable categorica. No colapsar / agregar
	
	* Propietario 
	/*
	PCH2	10	¿La persona propietaria de esta vivienda es:
	PCH3	11	¿La persona que toma las principales decisiones en el hogar es:
	1	Hombre
	2	Mujer
	3	Ambos
	9	No declarado
	*/
	destring pch2 pch3, replace
	gen propieta = pch2
	gen tipo_jefe = pch3
	* Nota: variable categorica. No colapsar / agregar

	* Agua de consumo de tuberia
	/* PCH4	12	¿De dónde obtiene principalmente el agua para consumo del hogar?
	1	Tubería red dentro de la vivienda
	2	Tubería red fuera de la vivienda, pero en el terreno
	3	Chorro público
	4	Pozo perforado público o privado
	5	Agua de lluvia
	6	Río
	7	Lago
	8	Manantial o nacimiento
	9	Camión o tonel
	10	Otro
	*/
	recode pch4  (1/2= 1 "Si") (3/10 = 0 "No") , gen(agua_tub) 
	
	* Sanitario / Inodoro
	/* PCH5	13	¿Qué tipo de servicio sanitario tiene este hogar?
	1	Inodoro conectado a red de drenajes
	2	Inodoro conectado a fosa séptica
	3	Excusado lavable
	4	Letrina o pozo ciego
	5	No tiene
	*/
	recode pch5  (1/2= 1 "Si") (3/5 = 0 "No") , gen(inodoro) 
	
	* Sanitario privado
	/* PCH6	14	¿El servicio sanitario es de:
	1	Uso exclusivo del hogar
	2	Uso compartido con otros hogares
	*/
	destring pch6,replace
	recode pch6 (1 = 1 "Si") (2 = 0 "No") , gen(bano_priv) 
	
	* Drenaje
	/* PCH7	15	¿Cómo se deshace de las aguas grises, por ejemplo, 
	la que utilizó para lavar ropa, trastos o bañarse?
	1	Conectado a red de drenajes
	2	Sin red de drenajes
	*/
	recode pch7  (1 = 1 "Si") (2 = 0 "No") , gen(drenaje) 
	
	* Electricidad
	/* PCH8	16	¿De qué tipo de alumbrado dispone principalmente el hogar?
	1	Red de energía eléctrica
	2	Panel solar / eólico
	3	Gas corriente
	4	Candela
	5	Otro
	*/
	recode pch8  (1 = 1 "Si") (2/5 = 0 "No") , gen(electricidad) 
	
	* Bienes 
	/* PCH9_A	17	¿Cuenta este hogar con radio?
	PCH9_B	18	¿Cuenta este hogar con estufa?
	PCH9_C	19	¿Cuenta este hogar con televisor?
	PCH9_D	20	¿Cuenta este hogar con servicio de cable?
	PCH9_E	21	¿Cuenta este hogar con refrigeradora?
	PCH9_F	22	¿Cuenta este hogar con tanque o depósito de agua?
	PCH9_G	23	¿Cuenta este hogar con lavadora de ropa?
	PCH9_H	24	¿Cuenta este hogar con computadora?
	PCH9_I	25	¿Cuenta este hogar con servicio de internet?
	PCH9_J	26	¿Cuenta este hogar con temazcal o tuj?
	PCH9_K	27	¿Cuenta este hogar con sistema de agua caliente?
	PCH9_L	28	¿Cuenta este hogar con moto?
	PCH9_M	29	¿Cuenta este hogar con carro?
	*/
	
		// Recodificar para convertir a dummies
		foreach v of varlist pch9_* {
				recode `v' (1 = 1 ) (2 = 0)
				}				
		sum pch9_*
		
		// Renombrar variables como bienes
		ren pch9_a	radio
		ren pch9_b	estufa
		ren pch9_c	tv
		ren pch9_d	tvcable
		ren pch9_e	refri
		ren pch9_f	tanque_agua
		ren pch9_g	lavadora
		ren pch9_h	compu
		ren pch9_i	internet
		ren pch9_j	temazcal
		ren pch9_k	agua_caliente
		ren pch9_l	moto
		ren pch9_m	carro
	
	* Recoleccion de basura
	/* PCH10	30	¿Cómo elimina la mayor parte de la basura en el hogar?
	1	Servicio municipal
	2	Servicio privado
	3	La queman
	4	La entierran
	5	La tiran en un río, quebrada o mar
	6	La tiran en cualquier lugar
	7	Abonera / reciclaje
	8	Otro
	*/
	recode pch10 (1/2 = 1 "Si") (3/8 = 0 "No"), gen(basura_rec) 

	* Numero de duartos y habitaciones
	/*
	PCH11	31	¿De cuántos cuartos dispone este hogar?
	PCH12	32	Del total de los cuartos, ¿cuántos utiliza como dormitorios?
	*/
	destring pch11 pch12, replace
	gen tot_cuartos = pch11
	gen tot_dorms = pch12
	* Nota: variables continuas.
	
	* Cocina
	/* PCH13	33	¿Dispone el hogar de un cuarto exclusivo para cocinar?
	1	Sí
	2	No
	*/
	recode pch13  (1 = 1 "Si") (2 = 0 "No") , gen(cocina) 
	
	* Gas
	/* PCH14	34	¿Cuál es la fuente principal que utiliza el hogar para cocinar?
	1	Gas propano
	2	Leña
	3	Electricidad
	4	Carbón
	5	Gas corriente
	6	Otra fuente
	7	No cocina
	*/
	recode pch14  (1 3 = 1 "Si") (2 4 5 6 7 = 0 "No") (9 = .), gen(gas) 
	* Nota: electricidad esta categorizada como gas. 
	
	* Casa recibe remesas
	/* PCH15	35	¿Recibe remesas con regularidad por parte de personas que 
	viven en el extranjero?
	1	Sí
	2	No
	*/
	
	recode pch15  (1  = 1 "Si") (2 = 0 "No"), gen(remesa) 
	
	* Migrante en el hogar
	/* PEI1	36	A partir del año 2002, ¿alguna persona que pertenecía a 
	este hogar, se fue a vivir a otro país y aún no ha regresado?
	1	Sí
	2	No
	*/
	recode pei1  (1  = 1 "Si") (2  = 0 "No"), gen(migra) 
	
	* Numero de migrantes
	/* PEI2	38	¿Cuál es el total de personas que se fueron y aún no han regresado?
	PEI2_E	39	Total de emigrantes con sexo, edad y año de partida reportado
	*/
	destring pei2, replace
	gen tot_migra = pei2 
	replace tot_migra = 0 if pei2 == .

	// Quedarnos con las variables que acabamos de crear
	keep depto mun urban num_vivienda num_hogar radio-carro ///
		 tipo_viv-tot_migra
	
	count //3,275,931
	
	sum
	/*
	Observations:     3,275,931                  
		Variables:            34     

	*/	
		
	/*
		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
		   depto |  3,275,931    9.543875    6.681773          1         22
			 mun |  3,275,931    962.2949    668.1174        101       2217
	num_vivienda |  3,275,931     1734742     1167914          1    5075297
	   num_hogar |  3,275,931    1.037626    .2395854          1         10
		   radio |  3,275,931    .6533846     .475892          0          1
	-------------+---------------------------------------------------------
		  estufa |  3,275,931    .9937404    .0788696          0          1
			  tv |  3,275,931    .7051171    .4559902          0          1
		 tvcable |  3,275,931    .5453613    .4979382          0          1
		   refri |  3,275,931    .4844608    .4997585          0          1
	 tanque_agua |  3,275,931    .2377373    .4256975          0          1
	-------------+---------------------------------------------------------
		lavadora |  3,275,931    .1995924    .3996941          0          1
		   compu |  3,275,931    .2126473    .4091803          0          1
		internet |  3,275,931    .1725525      .37786          0          1
		temazcal |  3,275,931    .0963973    .2951354          0          1
	agua_calie~e |  3,275,931    .1402023    .3471968          0          1
	-------------+---------------------------------------------------------
			moto |  3,275,931    .2274184     .419165          0          1
		   carro |  3,275,931    .2380838    .4259107          0          1
		   urban |  3,275,931    .5762432    .4941529          0          1
		tipo_viv |  3,275,931    1.511025     1.02284          1          6
		propieta |  2,627,179    1.719794    1.228637          1          9
	-------------+---------------------------------------------------------
	   tipo_jefe |  3,275,931    2.377582    1.192251          1          9
		agua_tub |  3,275,931    .7379108     .439771          0          1
		 inodoro |  3,275,931    .5555877    .4969005          0          1
	   bano_priv |  3,119,004     .888786     .314397          0          1
		 drenaje |  3,275,931    .4906859    .4999133          0          1
	-------------+---------------------------------------------------------
	electricidad |  3,275,931    .8813543    .3233711          0          1
	  basura_rec |  3,275,931    .4185268    .4933175          0          1
	 tot_cuartos |  3,275,931    2.628485     1.60867          1         20
	   tot_dorms |  3,275,931    1.935763    1.095087          1         18
		  cocina |  3,275,931    .7072942    .4550046          0          1
	-------------+---------------------------------------------------------
			 gas |  3,275,931    .4479612    .4972847          0          1
		  remesa |  3,275,931    .0848788    .2787013          0          1
		   migra |  3,275,931    .0595187    .2365929          0          1
	   tot_migra |  3,275,931    .0919033     .441914          0         19
	r; t=1.24 14:02:53
	*/

compress
save "$temp\temp_hogares.dta", replace



********************************************************************************
**#					PARTE 2: Base Vivienda
********************************************************************************		
//Vivienda
use "$raw\censo2018\Vivienda.dta", clear

	//Renombrar variables geograficas / locacion
	rename municipio mun
	rename departamento depto
	recode area (1 = 1 "urbano") (2 = 0 "rural"), gen(urban)
	
	// Nota usar solo ocupadas
	/* 
	PCV1	¿El tipo de la vivienda es:
	1	Casa formal
	2	Apartamento
	3	Cuarto de casa de vecindad (palomar)
	4	Rancho
	5	Vivienda improvisada
	6	Otro tipo de vivienda particular
	9	Particular no especificada
	10	Vivienda colectiva
	11	Sin vivienda
	
	PCV4	¿La condición de la vivienda es?
	1	Ocupada
	2	Ocupada de uso temporal
	3	Desocupada
	4	Moradores ausentes / rechazo total
	*/

	destring pcv4, replace
	gen tipo_viv_aux  = pcv1
	gen cond_viv = pcv4
	
	* Vivienda tiene paredes adecuadoas
	/* PCV2	¿Cuál es el material predominante en las paredes exteriores?
	1	Ladrillo
	2	Block
	3	Concreto
	4	Adobe
	5	Madera
	6	Lámina Metalica
	7	Bajareque
	8	Lepa, palo o caña
	9	Material de desecho
	10	Otro
	99	No especificado
	*/
	tab pcv2,missing
	recode pcv2  (1/3 = 1 "Si") ( 4/10 = 0 "No") (99 = 0 "No") , gen(pared_adec) 
	tab pared_adec
	
	* Vivienda tiene techo adecuado
	/* PCV3	¿Cuál es el material predominante en el techo?
	1	Concreto
	2	Lámina Metálica
	3	Asbesto cemento
	4	Teja
	5	Paja, palma o similar
	6	Material de desecho
	7	Otro
	9	No especificado
	*/
	destring pcv3, replace
	tab pcv3,missing
	recode pcv3  (1 3 = 1 "Si") ( 2 4 5 6 7 9 = 0 "No") , gen(techo_adec) 
	tab techo_adec
	
	* Vivienda tiene piso
	/* PCV5    ¿Cuál es el material predominante en el piso?
	1	Ladrillo cerámico
	2	Ladrillo de cemento
	3	Ladrillo de barro
	4	Torta de cemento
	5	Parqué/vinil
	6	Madera
	7	Tierra
	8	Otro
	*/
	tab pcv5,missing
	recode pcv5  (1 2 3 4 5 6 = 1 "Si") ( 7 8  = 0 "No"), gen(piso_adec) 
	tab piso_adec
		
	keep depto mun urban num_vivienda tipo_viv_aux cond_viv *_adec

	count //3,943,431
	
	sum
	/*
	 Observations:     3,943,431                  
		Variables:             9            

	*/	

	/*
		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
		   depto |  3,943,431    9.665837    6.625513          1         22
			 mun |  3,943,431    974.5706    662.5461        101       2217
	num_vivienda |  3,943,431     2554305     2094871          1    7001388
		   urban |  3,943,431    .5613031    .4962278          0          1
	tipo_viv_aux |  3,943,431    1.174476    .8629429          1         11
	-------------+---------------------------------------------------------
		cond_viv |  3,942,042    1.382335    .8022078          1          4
	  pared_adec |  3,943,085    .6474575    .4777618          0          1
	  techo_adec |  3,943,085    .2382987    .4260428          0          1
	   piso_adec |  3,180,638    .7315881    .4431332          0          1
	*/
	
compress	
save "$temp\temp_vivienda.dta", replace
		
		
		
		
********************************************************************************
**#			PARTE 3: Base Personas 
********************************************************************************	
use "$raw\censo2018\Personas.dta", clear
	
	rename pcp1 pid // ID persona
	rename municipio mun
	rename departamento depto
	recode area (1 = 1 "urbano") (2 = 0 "rural"), gen(urban)
	
	* Tamano del hogar (hhsize)
	gen pt = 1
	egen tot_miembros = sum(pt), by(num_vivienda num_hogar)
	drop pt
	
	// Caracteristicas demograficas basicas
	* Jefe de hogar
	/* PCP5	9	¿Qué parentesco o relación tiene con la jefa o el jefe del hogar?
	1	Jefe o jefa de hogar
	2	Esposa(o) o pareja
	3	Hija o hijo
	4	Hijastra(o)
	5	Nuera o yerno
	6	Nieta o nieto
	7	Hermana o hermano
	8	Madre o padre
	9	Suegra suegro
	10	Cuñada o cuñado
	11	Otra(o) pariente
	12	Empleada(o) doméstica(o)
	13	Pensionista o huésped
	14	Otra(o) no pariente
	15	Vivienda colectiva / en situacion de calle
	*/
	gen jefe = (pcp5==1)
	
	* Sexo
	/* PCP6	10	¿Sexo de la persona?
	1	Hombre
	2	Mujer
	*/
	recode pcp6 (1 = 1 "hombre") (2 = 0 "mujer"), gen(hombre)
	
	* Edad
	/* PCP7	11	¿Cuántos años cumplidos tiene? */
	gen edad = pcp7 
	* Edad del jefe de hogar
	
	* Mas categorias de edad
	gen menor15 = edad<15 if edad~=.
	gen anciano = edad>=65 if edad~=.
	gen adulto   = (!menor15 & ! anciano) if edad~=. // (15,64) ~ 9,091,281 
	
	* Certificado de nacimiento
	/*	PCP9	12	¿Tiene Fe de edad o está inscrito en el RENAP?
	1	Sí
	2	No
	9	No declarado
	*/
	recode pcp9 (1 = 1 "Si") (2 9 = 0 "No"), gen(certif)
	
	/* PCP10	13	¿En qué municipio y departamento o país nació?
	1	Aquí
	2	En otro Mpio, Depto o país
	9	No declarado
	PCP10_B	14	Departamento de nacimiento
	LUGNACGEO	15	Municipio de nacimiento
	PCP10_C	16	País de nacimiento
	PCP10_D	17	Año de llegada al país
	PCP11	18	¿En qué municipio y departamento o país residía habitualmente en abril 2013?
	1	No había nacido
	2	Aquí
	3	En otro Mpio, Depto o país
	9	No declarado
	PCP11_B	19	Departamento de residencia en abril de 2013
	RESCINGEO	20	Municipio de residencia en abril de 2013
	PCP11_C	21	País de residencia en abril de 2013
	*/
	* Nota: Proporcion de Extranjeros es menor al 1%. No agregar.
	
	
	//Origen y lenguas
	* Origen - crear dummy para cada categoria
	/*	PCP12	22	Según su origen o historia,¿cómo se considera o auto identifica?
	1	Maya
	2	Garífuna
	3	Xinka
	4	Afrodescendiente/Creole/Afromestizo
	5	Ladina (o)
	6	Extranjera (o)
	*/
	tab pcp12, missing
	recode pcp12 (1/3 = 1 "Si") (4/6 = 0 "No"), gen(indigena)
	
	/* PCP13	23	¿A qué comunidad lingüística pertenece?
	1	Achi
	2	Akateka
	3	Awakateka
	4	Ch'orti'
	5	Chalchiteka
	6	Chuj
	7	Itza'
	8	Ixil
	9	Jakalteko/Popti'
	10	K'iche'
	11	Kaqchiquel
	12	Mam
	13	Mopan
	14	Poqomam
	15	Poqomchi'
	16	Q'anjob'al
	17	Q'eqchi'
	18	Sakapulteka
	19	Sipakapense
	20	Tektiteka
	21	Tz'utujil
	22	Uspanteka
	*/
	*tab pcp13,missing
	* Nota: Muchos missings. No agregar.

	/* PCP14 24	¿Utiliza regularmente ropa o traje maya, garífuna, 
	afrodescendiente o xinka?
	1	Sí
	2	No 
	*/
	*tab pcp14,missing
	* Nota: Muchos missings. No agregar.

	* Primera lengua es espanol
	/* PCP15	25	¿Cuál es el idioma en el que aprendió a hablar?
	1	Achí
	2	Akateko
	3	Awakateko
	4	Ch'orti'
	5	Chalchiteko
	6	Chuj
	7	Itza'
	8	Ixil
	9	Jakalteko/Popti'
	10	K'iche'
	11	Kaqchiquel
	12	Mam
	13	Mopan
	14	Poqomam
	15	Poqomchi'
	16	Q'anjob'al
	17	Q'eqchi'
	18	Sakapulteko
	19	Sipakapense
	20	Tektiteko
	21	Tz'utujil
	22	Uspanteko
	23	Xinka
	24	Garífuna
	25	Español
	26	Inglés
	27	Señas
	28	Otro idioma
	98	No habla
	*/
	destring pcp15, replace
	gen materna_esp = (pcp15==25)
	

	/*
	PCP16_A	26	¿Tiene alguna dificultad para ver?
	PCP16_B	27	¿Tiene alguna dificultad para oír?
	PCP16_C	28	¿Tiene alguna dificultad para caminar o subir escaleras?
	PCP16_D	29	¿Tiene alguna dificultad para recordar o concentrarse?
	PCP16_E	30	¿Tiene alguna dificultad para el cuidado personal o para vestirse?
	PCP16_F	31	¿Tiene alguna dificultad para comunicarse?
	1	No, sin dificultad
	2	Sí, con algo de dificultad
	3	Sí, con mucha dificultad
	4	No puede
	9	No declarado
	*/
	* Nota: Variables muy ruidosas y subjetivas. No agregar.
	
	

* Educacion ********************************************************************

	/* NIVGRADO	77	Nivel y grado de estudio
	10	Ninguna
	20	Preprimaria
	31	1ero Primaria
	32	2do Primaria
	33	3ero Primaria
	34	4to Primaria
	35	5to Primaria
	
	36	6to Primaria
	41	1ero Basico
	42	2do  Basico
	43	3ero Basico
	44	4to Diversificado
	45	5to Diversificado
	
	46	6to Diversificado y 7mo Diversificado
	51	1er Licenciatura
	52	2do Licenciatura
	53	3ero Licenciatura
	54	4to Licenciatura
	
	55	5to Licenciatura y 6to Licenciatura
	61	1er Maestria
	62	2do Maestria
	71	1er Doctorado
	72	2do  Doctorado

	ANEDUCA	78	Años de Estudio
	
	PCP17_A	32	¿Cuál fue el nivel de estudios más alto que aprobó?
	1	Ninguno
	2	Preprimaria
	3	Primaria
	4	Nivel medio (básico y diversificado)
	5	Licenciatura
	6	Maestría
	7	Doctorado
	
    PCP17_B	33	¿Cuál fue el grado de estudios más alto que aprobó? 
	*/
	destring pcp17_a pcp17_b, replace
	destring nivgrado, replace
	
	gen edu_nivel = .	
	replace edu_nivel = 1 if (inrange(nivgrado,10,35) & edad>= 7) // menos de primaria
	replace edu_nivel = 2 if (inrange(nivgrado,36,45) & edad>= 7) // primaria
	replace edu_nivel = 3 if (inrange(nivgrado,46,54) & edad>= 7) // media /secundaria
	replace edu_nivel = 4 if (inrange(nivgrado,55,72) & edad>= 7) // terciaria
	
	tab edu_nivel, gen(edu)
	rename edu1 menos_prim
	rename edu2 primaria
	rename edu3 secundaria
	rename edu4 terciaria
	
	* Asistencia a escuela
	/*
	PCP18	34	Durante el ciclo escolar 2018,¿asiste a un establecimiento 
	educativo a estudiar?
	1	Sí
	2	No
	*/
	gen asiste = (pcp18 == 1) if edad>= 7
	

	* Escuela privada
	/* PCP19	35	¿El establecimiento educativo al que asiste en este año es:
	1	Público
	2	Privado
	3	Municipal
	4	Cooperativa
	*/
	destring pcp19, replace
	gen edu_priv = (pcp19==2) if (edad>= 7 & asiste ==1)	
	
	/* PCP20	36	¿En qué municipio y departamento o país estudia?
	1	Aquí
	2	En otro Mpio, Depto o país
	9	No declarado
	PCP20_B	37	Departamento donde estudia
	ESTUDIAGEO	38	Municipio donde estudia
	PCP20_C	39	País donde estudia
	*/

	/*
	PCP21	40	¿Cuál es la causa principal por la que no asiste a un 
	establecimiento educativo en este año?
	1	Falta de dinero
	2	Tiene que trabajar
	3	No hay escuela, instituto o universidad
	4	Los padres / pareja no quieren
	5	Quehaceres del hogar
	6	No le gusta / no quiere ir
	7	Ya terminó sus estudios
	8	Enfermedad o discapacidad
	9	Falta de maestro
	10	Embarazo
	11	Se casó o se unió
	12	Algún tipo de violencia
	13	Cambio de residencia
	14	Enseñan en otro idioma
	15	Cuidado de personas
	16	Los padres consideran que aún no tiene la edad
	17	Otra causa
	99	No declarado
	*/

	* Alfabetismo
	/* PCP22	41	¿Sabe leer y escribir?
	1	Sí
	2	No
	*/
	gen alfabeto = (pcp22 == 1) if edad>= 7

	
	/*
	PCP23_A	42	¿En qué idioma sabe leer y escribir? Idioma 1
	PCP23_B	43	¿En qué idioma sabe leer y escribir? Idioma 2
	PCP23_C	44	¿En qué idioma sabe leer y escribir? Idioma 3
	PCP24	45	Además del idioma en el que aprendió a hablar,
	¿sabe hablar otro idioma?
	1	Sí
	2	No
	PCP25_A	46	¿En qué otro idioma sabe hablar? Idioma 1
	PCP25_B	47	¿En qué otro idioma sabe hablar? Idioma 2
	PCP25_C	48	¿En qué otro idioma sabe hablar? Idioma 3
	*/
	* Nota: muchas opciones , no agregar.

	
	 *Al menos un integrante del hogar usa de celular, compu, internet
	/*	
	PCP26_A	49	En los últimos tres meses,¿ha usado celular?
	PCP26_B	50	En los últimos tres meses,¿ha usado computadora?
	PCP26_C	51	En los últimos tres meses,¿ha usado internet?
	*/
	destring pcp26_* , replace
	gen uso_celular = (pcp26_a == 1)
	gen uso_compu = (pcp26_b == 1)
	gen uso_internet = (pcp26_c == 1)
	
	
* Ocupacion y empleo ***********************************************************

	* En el censo definidas para 7 o mas anios
	* Restringir edad >= 15 (oficial) o [15,64] ?
	
	/*
	PEA	79	Población económicamente activa
	POCUPA	80	Personas Ocupadas
	PDESOC	81	Personas Desocupadas
	MIGRA_VIDA	82	Migrante y no migrante (migración de toda la vida) 
	MIGRA_REC	83	Migrante y no migrante (migración reciente)
	PEI	84	Población económicamente inactiva
	*/
	
	destring pea pocupa pdesoc migra_vida migra_rec pei, replace

	recode migra_vida  (1 = 1 ) (2 = 0) 
	recode migra_rec   (1 = 1 ) (2 = 0) 
	recode pea (1 = 1 ) (. = 0) 
	recode pei (1 = 1 ) (. = 0) 
	gen ocupa = (pocupa ==1)
	gen desocupa = (pdesoc==1)
	drop pocupa pdesoc

	
	/* PCP27	52	¿Trabajó durante la semana pasada?
	1	Sí
	2	No
	9	No declarado
	*/


	/* PCP28	53	¿Qué hizo durante la semana pasada:
	1	No trabajó, pero tiene trabajo (vacaciones, licencia, enfermedad, 
	mal tiempo, falta de insumos, etc.)
	2	Participó o ayudó en actividades agropecuarias
	3	Elaboró o ayudó a elaborar productos alimenticios (tortillas,
	pan, tamales, o tostadas) para la venta
	4	Elaboró o ayudó a elaborar artículos como sombreros, canastos, 
	artesanías y muebles para la venta
	5	Elaboró o ayudó a hilar, tejer o coser artículos para la venta
	6	Participó o ayudó en actividades comerciales o de servicios
	7	No trabajó
	*/

	/* PCP29	54	Si no trabajó,¿qué fue lo que hizo durante la semana pasada:
	1	Buscó trabajo y trabajó antes
	2	Buscó trabajo por primera vez
	3	Únicamente estudió
	4	Unicamente vivió de su renta o jubilación
	5	Quehaceres del hogar (barrer, planchar, lavar, cocinar)
	6	Cuidado de personas
	7	Cargo comunitario
	8	Otra actividad no remunerada
	9	No declarado
	*/

	/*
	PCP30_2D	55	Ocupación 2 dígitos
	PCP30_1D	56	Ocupación 1 digito
	*/

	/* PCP31_D	57	Categoría ocupacional
	1	Patrona(o) o empleador(a)
	
	2	Cuenta propia con local
	3	Cuenta propia sin local
	
	4	Empleada(o) pública(o)
	5	Empleada(o) privada(o)
	6	Empleada(o) doméstica(o)
	
	7	Familiar no renumerado
	9	No declarado
	*/
	
	destring pcp31_d, replace
	
	gen ocupacion = .
	replace ocupacion = 1 if pcp31_d ==1
	replace ocupacion = 2 if inrange(pcp31_d,2,3) 
	replace ocupacion = 3 if inrange(pcp31_d,4,6) 
	replace ocupacion = 4 if inrange(pcp31_d,7,9) 
	
	gen patrono    = (ocupacion == 1) 
	gen cuentaprop = (ocupacion == 2) 
	gen asalariado = (ocupacion == 3) 
	gen norenumera = (ocupacion == 4) 
	
	
	/*
	PCP32_2D	58	Actividad 2 dígitos
	PCP32_1D	59	Actividad 1 dígito
	*/

	/*
	PCP33	60	¿En qué municipio y departamento trabaja o trabajó?
	1	Aquí
	2	En otro Mpio, Depto o país
	9	No declarado

	PCP33_B	61	Departamento donde trabaja o trabajó	
	TRABAJAGEO	62	Municipio donde trabaja o trabajó
	PCP33_C	63	País donde trabaja o trabajó
	*/

	* Otras vars demograficas **************************************************

	/* PCP34	64	¿Cuál es su estado conyugal actual?
	1	Soltera(o)
	2	Unida(o)
	3	Casada(o)
	4	Separada(o) de una unión libre
	5	Separada(o) de un matrimonio
	6	Divorciada(o)
	7	Viuda(o)
	*/
	destring pcp34,replace
	gen casado = (pcp34==3) 
	
	
	/*
	PCP35_A	65	¿Cuántas hijas e hijos nacidos vivos ha tenido? Total
	PCP35_B	66	¿Cuántas hijas e hijos nacidos vivos ha tenido? Mujeres
	PCP35_C	67	¿Cuántas hijas e hijos nacidos vivos ha tenido? Hombres
	PCP36_A	68	¿Cuántos de sus hijas e hijos están vivos actualmente? Total
	PCP36_B	69	¿Cuántos de sus hijas e hijos están vivos actualmente? Mujeres
	PCP36_C	70	¿Cuántos de sus hijas e hijos están vivos actualmente? Hombres
	99	No declarado
	9999	No declarado
	
	PCP37	71	¿A qué edad tuvo su primera hija o hijo nacido vivo?
	PCP38_A	72	Día de nacimiento de su última hija(o) nacida(o) viva(o)
	PCP38_B	73	Mes de nacimiento de su última hija(o) nacida(o) viva(o)
	PCP38_C	74	Año de nacimiento de su última hija(o) nacida(o) viva(o)
	
	PCP39	75	¿Está viva(o) su última(o) hija(o) nacida(o) viva(o)?
	1	Sí
	2	No
	*/
	/* VIVEHABGEO	76	Departamento y municipio de residencia habitual */
	* Demasiadas valores

	keep depto mun urban num_vivienda num_hogar urban tot_* uso_* jefe ///
		 hombre edad menor15 anciano adulto certif indigena materna_esp ///
		 menos_prim primaria secundaria terciaria asiste edu_priv alfabeto ///
		 patrono cuentaprop asalariado norenumera ocupa pea pei casado
	
	sum
	/*	 
	    Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
		   depto | 14,901,286    9.923402    6.513748          1         22
			 mun | 14,901,286    1000.433    651.3471        101       2217
	num_vivienda | 14,901,286     1773362     1138505          1    7001388
	   num_hogar | 14,901,286    1.030972    .2162989          1         10
			 pea | 14,901,286    .3429241    .4746864          0          1
	-------------+---------------------------------------------------------
			 pei | 14,901,286    .4865006    .4998178          0          1
		   urban | 14,901,286    .5385111    .4985147          0          1
	tot_miembros | 14,901,286    9.673168    112.3223          1       4842
			jefe | 14,901,286    .2198422    .4141396          0          1
		  hombre | 14,901,286    .4847297    .4997668          0          1
	-------------+---------------------------------------------------------
			edad | 14,901,286    26.49333    19.90534          0        124
		 menor15 | 14,901,286    .3337111    .4715379          0          1
		 anciano | 14,901,286    .0561884    .2302853          0          1
		  adulto | 14,901,286    .6101004    .4877273          0          1
		  certif | 14,901,286    .9768565    .1503592          0          1
	-------------+---------------------------------------------------------
		indigena | 14,901,286    .4356133     .495837          0          1
	 materna_esp | 14,901,286    .6367798    .4809275          0          1
	  menos_prim | 12,528,937    .4965794    .4999883          0          1
		primaria | 12,528,937    .3706979    .4829917          0          1
	  secundaria | 12,528,937    .1034661    .3045667          0          1
	-------------+---------------------------------------------------------
	   terciaria | 12,528,937    .0292566    .1685249          0          1
		  asiste | 12,528,937    .2874056    .4525524          0          1
		edu_priv |  3,600,887    .2609377     .439146          0          1
		alfabeto | 12,528,937    .8153139    .3880427          0          1
	 uso_celular | 14,901,286    .5202753    .4995888          0          1
	-------------+---------------------------------------------------------
	   uso_compu | 14,901,286    .1761373     .380937          0          1
	uso_internet | 14,901,286    .2465545    .4310051          0          1
		   ocupa | 14,901,286    .3334304    .4714388          0          1
		 patrono | 14,901,286    .0148116    .1207983          0          1
	  cuentaprop | 14,901,286    .1078754     .310223          0          1
	-------------+---------------------------------------------------------
	  asalariado | 14,901,286    .1758295     .380675          0          1
	  norenumera | 14,901,286    .0408163    .1978644          0          1
		  casado | 14,901,286     .248378    .4320722          0          1 
	*/
	
	* Variables JEFE ***********************************************************

	local vars hombre edad menor15 anciano adulto certif indigena materna_esp ///
			   menos_prim primaria secundaria terciaria asiste edu_priv alfabeto ///
			   patrono cuentaprop asalariado norenumera ocupa pea pei casado
				 
	foreach x of local vars {
		gen jefe_`x'= `x' if jefe==1
		*ereplace jefe_`x' = max(jefe_`x'), by(num_vivienda num_hogar)
	}
		
	local vars hombre edad menor15 anciano adulto certif indigena materna_esp 			 
	foreach x of local vars {
		egen double p_`x' = mean(`x'), by(num_vivienda num_hogar)
		
	}
	
	* Edad promedio en el hogar
	egen double edad_hogar = mean(edad), by(num_vivienda num_hogar)
	
	* Tasa de dependecia	
	gen notrabajo = (edad <= 14 | edad >= 65)
	egen double p_dependencia = mean(notrabajo), by(num_vivienda num_hogar)

	
	
	* Porcentajes pero solo para poblacion mayor o igual a 7
	egen double sum_7omas = sum(edad>= 7), by(num_vivienda num_hogar)
	sum sum_7omas // 8.676916

	local vars menos_prim primaria secundaria terciaria asiste edu_priv alfabeto ///
			   patrono cuentaprop asalariado norenumera ocupa pea pei casado
				 
	foreach x of local vars {
		egen double p_`x' = sum(`x'), by(num_vivienda num_hogar)
		replace  p_`x'= p_`x'/sum_7omas
	}
	
	
	drop sum_*
	
	
	// Quedarnos con las variables que acabamos de crear
	keep if jefe==1
	keep depto mun urban num_vivienda num_hogar urban tot_* uso_* ///
		 edad_hogar jefe_* p_* 
		 	 
	sum	 
	
	/*
	
		Variable |        Obs        Mean    Std. dev.       Min        Max
	-------------+---------------------------------------------------------
		   depto |  3,275,931    9.543875    6.681773          1         22
			 mun |  3,275,931    962.2949    668.1174        101       2217
	num_vivienda |  3,275,931     1734742     1167914          1    5075297
	   num_hogar |  3,275,931    1.037626    .2395854          1         10
		   urban |  3,275,931    .5762432    .4941529          0          1
	-------------+---------------------------------------------------------
	tot_miembros |  3,275,931    4.535362    2.343367          1         41
	 uso_celular |  3,275,931    .7709967    .4201914          0          1
	   uso_compu |  3,275,931     .177947    .3824682          0          1
	uso_internet |  3,275,931    .2755852    .4468087          0          1
	 jefe_hombre |  3,275,931    .7565196    .4291827          0          1
	-------------+---------------------------------------------------------
	   jefe_edad |  3,275,931    46.06992    15.91925         12        124
	jefe_menor15 |  3,275,931     .000094    .0096959          0          1
	jefe_anciano |  3,275,931    .1483856    .3554819          0          1
	 jefe_adulto |  3,275,931    .8515204    .3555748          0          1
	 jefe_certif |  3,275,931    .9766057    .1511522          0          1
	-------------+---------------------------------------------------------
	jefe_indig~a |  3,275,931    .3935687    .4885412          0          1
	jefe_mater~p |  3,275,931    .7063464    .4554352          0          1
	jefe_menos~m |  3,275,931    .4975666    .4999942          0          1
	jefe_prima~a |  3,275,931    .3457182    .4756019          0          1
	jefe_secun~a |  3,275,931    .1101897    .3131262          0          1
	-------------+---------------------------------------------------------
	jefe_terci~a |  3,275,931    .0465254      .21062          0          1
	 jefe_asiste |  3,275,931    .0282723    .1657497          0          1
	jefe_edu_p~v |     92,618    .5662074    .4955999          0          1
	jefe_alfab~o |  3,275,931    .7685238     .421776          0          1
	jefe_patrono |  3,275,931    .0409249    .1981162          0          1
	-------------+---------------------------------------------------------
	jefe_cuent~p |  3,275,931    .2866987    .4522196          0          1
	jefe_asala~o |  3,275,931    .3440195    .4750475          0          1
	jefe_noren~a |  3,275,931    .0582002    .2341218          0          1
	  jefe_ocupa |  3,275,931     .719966    .4490156          0          1
		jefe_pea |  3,275,931    .7314357    .4432128          0          1
	-------------+---------------------------------------------------------
		jefe_pei |  3,275,931    .2620403    .4397445          0          1
	 jefe_casado |  3,275,931    .5187096    .4996499          0          1
		p_hombre |  3,275,931    .4830147    .2219751          0          1
		  p_edad |  3,275,931    29.97381    15.55446        3.8        115
	   p_menor15 |  3,275,931    .2837948    .2330122          0          1
	-------------+---------------------------------------------------------
	   p_anciano |  3,275,931    .0892497    .2273364          0          1
		p_adulto |  3,275,931    .6269555    .2586078          0          1
		p_certif |  3,275,931    .9752589    .1039551          0          1
	  p_indigena |  3,275,931    .3830748    .4748933          0          1
	p_materna_~p |  3,275,931    .6830179    .3994978          0          1
	-------------+---------------------------------------------------------
	  edad_hogar |  3,275,931    29.97381    15.55446        3.8        115
	p_dependen~a |  3,275,931    .3730445    .2586078          0          1
	p_menos_prim |  3,275,931     .476978    .3600059          0          1
	  p_primaria |  3,275,931    .3710891    .3200901          0          1
	p_secundaria |  3,275,931    .1151709    .2291943          0          1
	-------------+---------------------------------------------------------
	 p_terciaria |  3,275,931     .036762    .1453274          0          1
		p_asiste |  3,275,931    .2436908    .2444239          0          1
	  p_edu_priv |  3,275,931    .0698725    .1609594          0          1
	  p_alfabeto |  3,275,931    .8159025    .2798576          0          1
	   p_patrono |  3,275,931    .0194767    .0937895          0          1
	-------------+---------------------------------------------------------
	p_cuentaprop |  3,275,931    .1378851    .2211238          0          1
	p_asalariado |  3,275,931    .2260111     .269791          0          1
	p_norenumera |  3,275,931    .0469764    .1353493          0          1
		 p_ocupa |  3,275,931    .4228772    .2849262          0          1
		   p_pea |  3,275,931    .4340712    .2842971          0          1
	-------------+---------------------------------------------------------
		   p_pei |  3,275,931     .553146    .2868754          0          1
		p_casado |  3,275,931    .3118547     .341528          0          1

	*/
	

// Guardar base persona pero ya a nivel hogar
compress	
save "$temp\temp_personas.dta", replace
	

	
********************************************************************************
**#					PARTE 4: Unir bases de datos
********************************************************************************
use "$temp\temp_hogares.dta", clear

	// Unir con base temporal vivienda
	merge m:1 num_vivienda using  "$temp\temp_vivienda.dta"
	keep if _merge == 3
	drop _merge
	drop cond_viv tipo_viv_aux tipo_viv tipo_jefe propieta 

	// Unir con base temporal personas (ya nivel hogar)
	merge 1:1 num_vivienda num_hogar using  "$temp\temp_personas.dta"
	keep if _merge == 3
	drop _merge

	//Deshacernos de variables con pocas observaciones o valores extremos
	d, varlist
	local vars `r(varlist)'  
	unab  omit: depto mun num_vivienda num_hogar tot_* jefe_edad edad_hogar
	local binarias:  list vars - omit
	sum `binarias'

	
	foreach x of varlist  `binarias' {
	qui: sum `x'
	if (r(Var) > 0 & r(mean) >= .1 & r(mean) <= .9 /*& r(N) > 0.9*`aux'*/) {
		local binarias_elegibles  `binarias_elegibles' `x'
		}
		else {
			drop `x'
		}
	}

	// Sacar logaritmo a variables continuas
	unab cont: tot_* edad_hogar jefe_edad
	foreach x of local cont {
		gen ln_`x' = log(`x')
	}
	

	// Colapsar variables continuas y binarias a nivel municipal y departamento 
	d, varlist
	local vars `r(varlist)'  
	unab  omit: depto mun num_vivienda num_hogar
	local covars:  list vars - omit
	di "`covars'"
	
	gen pop = tot_miembros
	gen hogares = 1

	
	// Primero calculamos promedios a nivel depto y guardamos como archivo temporal
	preserve
	groupfunction, mean(`covars') by(depto)
		rename * depto_*
		rename depto_depto depto
		
		tempfile depto_level
		save `depto_level'
	restore

	// Ahora a nivel municipal
	groupfunction, mean(`covars') rawsum(hogares pop) by(depto mun)
		
	rename * mun_*
	rename mun_hogares  hogares
	rename mun_pop 		pop
	rename mun_depto    depto
	rename mun_mun      mun

	//Mergeamos con el archivo temporal nivel depto
	merge m:1 depto using `depto_level'
	drop _merge
	order mun depto hogares pop
	
/*
 Observations:           340                  
    Variables:           142   

. sum

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         mun |        340    1119.859    582.5576        101       2217
       depto |        340        11.1    5.825536          1         22
     hogares |        340    9635.091    16831.81        545     243014
         pop |        340    43698.63     66543.7       2365     910815
   mun_radio |        340     .620199    .1225006   .3042247   .8935989
-------------+---------------------------------------------------------
      mun_tv |        340    .6577504    .2016152   .0982321   .9737397
 mun_tvcable |        340    .4962809    .1926601   .0754842   .8756757
   mun_refri |        340    .4065363    .2025681    .035923   .8439183
mun_tanque~a |        340     .193227    .1277797   .0069661   .7118171
mun_lavadora |        340    .1214141    .1162407   .0013615   .5555491
-------------+---------------------------------------------------------
   mun_compu |        340    .1460625     .101079   .0131833   .5424704
mun_internet |        340    .0955247    .0988423   .0034037   .5513808
mun_agua_c~e |        340    .0964722    .1233283   .0008962   .7161484
    mun_moto |        340    .2150356    .1325321   .0201991   .6738207
   mun_carro |        340    .1895318    .1104855   .0146052   .6020942
-------------+---------------------------------------------------------
   mun_urban |        340    .4410228    .2960543   .0147728          1
mun_agua_tub |        340    .7561505    .1997763   .0765334   .9944954
 mun_inodoro |        340    .4963247    .2713446   .0071174   .9922918
mun_bano_p~v |        340    .8934056    .0542211   .6849296   .9845387
 mun_drenaje |        340    .4180584    .2758485   .0101143   .9898051
-------------+---------------------------------------------------------
mun_electr~d |        340    .8730137    .1418637   .2286249   .9957738
mun_basura~c |        340    .3223246    .2745551   .0029847    .987388
mun_tot_cu~s |        340    2.503365    .4272423   1.505703   3.907973
mun_tot_do~s |        340     1.86941    .2418781    1.35278   2.601054
  mun_cocina |        340    .7016422    .1782014   .1050332   .9734486
-------------+---------------------------------------------------------
     mun_gas |        340    .3100006    .2490391   .0091233   .9644575
mun_tot_mi~a |        340    .1196656     .119942   .0104012   .6833898
mun_pared_~c |        340    .6103027    .2335484   .0570707   .9811214
mun_techo_~c |        340    .1619221    .1431243   .0027839   .7308806
mun_piso_a~c |        340    .7050592    .2013828   .1377808    .985348
-------------+---------------------------------------------------------
mun_tot_mi~s |        340    4.668364    .6758772   3.375602    7.03016
mun_uso_ce~r |        340    .7517307    .0831494   .4407772   .9158224
mun_uso_co~u |        340    .1143229    .0891354   .0115725   .5095166
mun_uso_in~t |        340    .2069411    .1153025   .0258019   .6225366
mun_jefe_h~e |        340    .7673555     .052253   .5686881   .9176561
-------------+---------------------------------------------------------
mun_jefe_e~d |        340     46.1656    2.100852   41.22715   52.30103
mun_jefe_~no |        340     .152165    .0346651   .0912726   .2657937
mun_jefe~lto |        340    .8477252    .0346614   .7342063   .9084921
mun_jefe_i~a |        340    .4668373    .3946005   .0032196          1
mun_jefe_m~p |        340    .6492247    .3839307   .0039399   .9966079
-------------+---------------------------------------------------------
mun_jefe_m~m |        340    .5773693    .1560052   .1713399   .9131313
mun_je~maria |        340    .3074798    .0998449   .0727273   .5511651
mun_jefe_s~a |        340    .0919452    .0495978    .010211   .2937956
mun_jefe_e~v |        340    .5248501    .1241261          0          1
mun_jefe~eto |        340     .727128    .1288695   .3456123   .9586732
-------------+---------------------------------------------------------
mun_jefe_c~p |        340    .2929436    .1292878    .019573   .6762414
mun_jef~iado |        340    .3118597    .1253487   .0357915    .640367
mun_jefe_o~a |        340    .6971731    .1117927   .2298458   .9008341
mun_jefe_pea |        340    .7072399    .1108583   .2380158   .9031511
mun_jefe_pei |        340    .2873129    .1102874   .0949954   .7494789
-------------+---------------------------------------------------------
mun_jefe_c~o |        340    .5247785    .1040696   .2853885   .8071124
mun_p_hombre |        340     .483471    .0164648   .4147951   .5219746
mun_p_men~15 |        340    .2984738    .0492046     .19107   .4087677
mun_p_adulto |        340    .6109751    .0391623   .5029397     .70843
mun_p_indi~a |        340    .4577803    .3959314    .003239   .9985103
-------------+---------------------------------------------------------
mun_p_mate~p |        340    .6319375    .3378893   .0054874   .9473547
mun_edad_h~r |        340     29.4564    2.733702   23.54883   37.03302
mun_p_depe~a |        340    .3890249    .0391623     .29157   .4970603
mun_p_meno~m |        340    .5363982    .1222682   .2106489   .8180359
mun_p_prim~a |        340    .3457747    .0691095   .1609418   .5073021
-------------+---------------------------------------------------------
mun_p_secu~a |        340    .0991076    .0494869   .0111591   .2909375
mun_p_asiste |        340    .2351508    .0259622   .1467625   .3053242
mun_p_alfa~o |        340    .7844118    .0970567   .4966684    .962439
mun_p_cuen~p |        340    .1374916    .0550087   .0143987    .346594
mun_p_asal~o |        340    .1956775    .0776017   .0212943   .3590144
-------------+---------------------------------------------------------
 mun_p_ocupa |        340    .3919414    .0808426   .1184184   .6192042
   mun_p_pea |        340    .4011057     .081734   .1248306   .6258489
   mun_p_pei |        340    .5881819    .0825122   .3708048   .8505747
mun_p_casado |        340    .3109951    .0657334   .1334351    .546554
mun_ln_t~tos |        340    .7524464    .1767963   .2761786   1.227872
-------------+---------------------------------------------------------
mun_ln_to~ms |        340    .4917761    .1218131    .204526    .806278
mun_ln_tot~a |        340    .2998259    .0956853   .0495105   .9601009
mun_ln_t~ros |        340    1.398823    .1393443   1.064242   1.820791
mun_ln_eda~r |        340    3.266145    .0905722   3.061898   3.491434
mun_ln_jef~d |        340    3.770936    .0462327   3.653274   3.899685
-------------+---------------------------------------------------------
 depto_radio |        340    .6315994    .0905992   .4692225   .7963772
    depto_tv |        340    .6671899    .1545578    .278626   .9451918
depto_tvca~e |        340    .5086173    .1333586   .2108813   .7633145
 depto_refri |        340    .4257884    .1485535   .1545661   .7637502
depto_tanq~a |        340    .2043998    .0644461   .1101724   .3809068
-------------+---------------------------------------------------------
depto_lava~a |        340    .1413512     .095838   .0444667   .4572122
 depto_compu |        340    .1651949    .0808447   .0908223   .4391779
depto_inte~t |        340    .1187827    .0816927   .0418148   .4155886
depto_agua~e |        340    .1153179    .0984952   .0160209    .322268
  depto_moto |        340    .2208869    .0888143   .0778408   .4463353
-------------+---------------------------------------------------------
 depto_carro |        340    .1988471    .0820437   .0721089   .4302212
 depto_urban |        340    .5044417    .1758748   .2799739   .9221591
depto_agua~b |        340    .7253193    .1192384   .4528335   .9314425
depto_inod~o |        340    .5020277    .1919095   .1926144   .9052321
depto_bano~v |        340    .8914358    .0317562   .8276147   .9321424
-------------+---------------------------------------------------------
depto_dren~e |        340    .4309049    .1990514   .0901243   .8703081
depto_elec~d |        340    .8755193    .1144867   .4891659   .9899687
depto_basu~c |        340    .3335507    .1994087   .1019992   .8524314
depto_to~tos |        340    2.544575    .2622903    2.14062   3.134177
depto_tot~ms |        340    1.896382    .1657386   1.626498   2.227526
-------------+---------------------------------------------------------
depto_cocina |        340    .7036877    .0856398   .5157874    .872166
   depto_gas |        340    .3469912    .2014844   .1046573   .8887457
depto_tot_~a |        340    .1093518    .0636605   .0248242   .2470966
depto_pare~c |        340    .6177039    .1749178   .3131799   .8769637
depto_tech~c |        340    .1802711    .1187319   .0246448    .531306
-------------+---------------------------------------------------------
depto_piso~c |        340    .7076912    .1450902   .3598181   .9259713
depto_to~ros |        340    4.656465    .4938506   3.945728   5.566727
depto_uso_~r |        340    .7522429    .0553518   .6039064   .8777461
depto_uso_~u |        340    .1321151    .0729459   .0701412   .3884754
depto_uso_~t |        340    .2231423    .0859321   .1181516   .5134098
-------------+---------------------------------------------------------
depto_jefe~e |        340    .7642182    .0320823   .7078005   .8536284
depto_jefe~d |        340    46.08851    1.286598   43.07633   48.33337
depto_jef~no |        340    .1496742    .0206055   .1172884   .1943614
depto_je~lto |        340    .8502227    .0205982   .8055529   .8825913
depto_jef~na |        340    .4510454    .2969852   .0161039   .9792596
-------------+---------------------------------------------------------
depto_jef~sp |        340    .6652566      .30701   .1181679   .9891493
depto_jefe~m |        340    .5546448    .1198741   .2468908   .7270391
d~e_primaria |        340    .3136515    .0783209   .1970758   .4773864
depto_jefe.. |        340    .1008082    .0264659   .0592158    .157766
depto_jefe~v |        340    .5438599     .053702   .4344779   .6343356
-------------+---------------------------------------------------------
depto_je~eto |        340    .7364304    .0986685   .5513782   .9264017
depto_jef~op |        340    .2965821    .0776174   .1621933   .4768129
depto_j~iado |        340    .3169593    .0771984   .2157511   .4661596
depto_jef~pa |        340    .7048141    .0589284   .5963681   .8191693
depto_jef~ea |        340    .7152456    .0585937   .6059703   .8293424
-------------+---------------------------------------------------------
depto_jefe~i |        340    .2785804    .0588486   .1569894    .390422
depto_j~sado |        340     .525649    .0725062   .3989265   .6809618
depto_p_ho~e |        340    .4829935    .0105705   .4598433    .502152
depto_p_m~15 |        340    .2951575    .0360262   .2249645   .3527144
depto_p_ad~o |        340    .6156917    .0282986   .5757491   .6781894
-------------+---------------------------------------------------------
depto_p_in~a |        340    .4415625    .2974547   .0150846   .9763142
depto_p_ma~p |        340    .6450254    .2702631     .15522   .9211058
depto_edad~r |        340    29.51575    1.918055   25.98285   32.76965
depto_p_de~a |        340    .3843083    .0282986   .3218106   .4242509
depto_p_me~m |        340    .5205204    .0924418   .2776886    .656679
-------------+---------------------------------------------------------
depto_p_pr~a |        340    .3481547    .0531227    .267616   .4672274
depto_p_se~a |        340     .106494    .0273762   .0641853   .1634148
depto_p_as~e |        340    .2377077    .0123019   .2179347   .2687313
depto_p_al~o |        340    .7911513    .0731723     .66167    .937128
depto_p_cu~p |        340    .1401897    .0269168   .0921658   .2052084
-------------+---------------------------------------------------------
depto_p_as~o |        340    .2023275    .0539275   .1311467   .3352092
depto_p_oc~a |        340    .4014203    .0504645   .3148678   .5181467
 depto_p_pea |        340    .4110506    .0522488   .3221311   .5347982
 depto_p_pei |        340    .5770776    .0547653    .444606   .6643842
depto_p_ca~o |        340    .3127315    .0412192   .2365075    .405758
-------------+---------------------------------------------------------
depto_ln~tos |        340    .7633769    .1050113   .5788984   .9783754
depto_ln_~ms |        340    .5025706    .0822133   .3457418   .6578132
depto_ln_t~a |        340    .2977152    .0424778   .2317011   .3857857
depto_ln~ros |        340    1.397349    .1050015   1.243518   1.576681
depto_ln_e~r |        340    3.269088    .0636423   3.151889   3.386072
-------------+---------------------------------------------------------
depto_ln_j~d |        340    3.769524    .0286078   3.695454   3.81517

*/

	
compress
save "$input\FHcensus_mun.dta", replace
