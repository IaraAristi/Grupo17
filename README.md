# Grupo17
Integrantes:  
Aristimuño Iara (IaraAristi)  
Dominguez Luana (Lu-Dominguez)  
Lopardo Tomas (Tomasl07)  
Rico Agustina (agussrico)

# Sistema de Gestión para Institución Sol Norte

Este proyecto implementa una base de datos relacional que permite gestionar de forma integral la actividad de la Institución Sol Norte. Se modelan los procesos principales administración de socios e inscripciones, actividades, facturación, reintegros, gestión de invitados, seguridad basada en roles y encriptación de datos sensibles.

## 🗂️ Archivos SQL

### 🔢 Orden de ejecución

| Archivo SQL                  | Descripción                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `00_CreacionDeTablasyBDD.sql`   | Creación de la base de datos, esquemas y todas las tablas necesarias.           |
| `01_SPImportacionDeTablas.sql` | Procedimientos almacenados para importar datos desde archivos CSV.         |
| `02_EjecucionDeImportaciones.sql` | Ejecución secuencial de los SP de importación. |
| `03_CargarTablas.sql`           | SP para cargas o actualizaciones específicas de datos.                    |
| `04_SPCreateAlterDelete.sql`         | SP para inserciones, modificaciones y borrado de datos.              |
| `05_RellenarTablas.sql`         | Inserción manual de datos clave y ejecución de SP auxiliares.              |
| `06_Reportes.sql`               | Creación de procedimientos almacenados para reportes estadísticos.                 |
| `07_EjecucionesReportes.sql`    | Ejecución de los reportes generados.                           |
| `08_Seguridad&roles.sql`        | Creación de usuarios, roles, asignación de permisos y encriptación.           |
| `09_EjecucionesSeguridadyRoles.sql`    | Ejecución de desencriptación.                           |

## ⚙️ Instrucciones de ejecución

1. **Ejecutar en orden** los archivos del `00` al `08`.
2. Los archivos `00`, `01`, `03`, `04`, `06` y `08` pueden ejecutarse completos.
3. Los archivos `02`, `05`, `07` y `09` deben ejecutarse sección por sección, según delimitadores `----`.
4. **Siempre verificar** que se esté trabajando sobre la base `Com2900G17`. En caso contrario, ejecutar:
   ```sql
   USE Com2900G17
   GO

## 📄 Archivos CSV

- Los archivos `.csv` necesarios para la carga inicial deben guardarse en una **misma carpeta local**.
- **Recomendamos ubicar la carpeta en el Escritorio**, para facilitar el acceso y acortar la ruta de importación.
- En la ejecución de los procedimientos de importación (archivo `02_EjecucionDeImportaciones.sql`), se debe especificar la ruta con el parámetro `@rutaArchivo`, siguiendo este formato:
  
  ```sql
  EXEC club.ImportarSocios @rutaArchivo = 'C:\MiCarpeta\Datos Socios.csv'
