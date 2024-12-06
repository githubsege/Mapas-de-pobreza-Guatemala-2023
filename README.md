
# 📊 Mapas de Pobreza Guatemala 2023

Este proyecto proporciona el código fuente utilizado para la construcción de los mapas de pobreza a nivel municipal en Guatemala correspondiente al año 2023.

## 📋 Tabla de Contenidos

- [📖 Descripción](#-descripción)
- [🔧 Requisitos Previos](#-requisitos-previos)
- [⚙️ Instalación](#️-instalación)
- [🚀 Uso](#-uso)
- [📁 Estructura del Proyecto](#-estructura-del-proyecto)
- [🤝 Contribuciones](#-contribuciones)
- [📄 Licencia](#-licencia)
- [📞 Contacto](#-contacto)

## 📖 Descripción

El objetivo de este proyecto es facilitar el análisis de los índices de pobreza en Guatemala mediante la generación de mapas y visualizaciones que permitan una comprensión clara de la distribución geográfica de la pobreza en el país.

## 🔧 Requisitos Previos

Antes de comenzar, asegúrate de tener instalados los siguientes programas:

- [Stata](https://www.stata.com/) (versión 15 o superior)
- [Git](https://git-scm.com/)

## ⚙️ Instalación

Sigue estos pasos para configurar el proyecto en tu máquina local:

1. **Clona este repositorio**:

   ```bash
   git clone https://github.com/githubsege/Mapas-de-pobreza-Guatemala-2023.git
   ```

2. **Accede al directorio del proyecto**:

   ```bash
   cd Mapas-de-pobreza-Guatemala-2023
   ```

## 🚀 Uso

Para generar los mapas de pobreza, sigue estos pasos:

1. **Prepara los datos**: Asegúrate de que los archivos de datos necesarios se encuentren en la carpeta `01_Data`. Las bases de datos las puedes encontrar en la página web del [INE](https://www.ine.gob.gt/pobreza-menu/).

2. **Ejecuta los scripts de Stata**: Abre Stata y ejecuta los archivos `.do` ubicados en la carpeta `02_DoFiles` en el orden adecuado para procesar los datos y generar las visualizaciones.

## 📁 Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

```
Mapas-de-pobreza-Guatemala-2023/
│
├── 01_Data/
│   └── [Archivos de datos necesarios para el análisis]
│
├── 02_DoFiles/
│   └── [Scripts de Stata para procesar datos y generar mapas]
│
├── 03_Literatura/
│   └── [Documentos y referencias relacionadas con el proyecto]
│
├── 05_Figuras/
│   └── [Mapas y visualizaciones generadas]
│
└── README.md
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Si deseas colaborar, por favor sigue estos pasos:

1. Haz un fork del repositorio.
2. Crea una nueva rama para tu función o corrección: `git checkout -b feature/nueva-funcion`.
3. Realiza tus cambios y haz commit de los mismos: `git commit -m 'Agrega nueva función'`.
4. Haz push a la rama: `git push origin feature/nueva-funcion`.
5. Abre una Pull Request.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Para más detalles, consulta el archivo [LICENSE](LICENSE).

## 📞 Contacto

Para consultas o más información, por favor contacta a [Shorjan Estrada](mailto:shorjan.estrada).

