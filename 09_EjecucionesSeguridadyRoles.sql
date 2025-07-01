USE Com2900G17;
GO
--COMANDOS PARA EJECUTAR EL PROCEDURE:
EXEC club.DesencriptarEmpleado @password = 'Hola123';

--COMANDO PARA MOSTRAR LAS TABLAS
SELECT 
    ID_empleado,
    dni,
    nombre,
    apellido,
    fechaNac,
    telContacto,
    telEmergencia
FROM club.Empleado;

SELECT 
    ID_empleado,
    dni_enc,
    nombre_enc,
    apellido_enc,
    fechaNac_enc,
    telContacto_enc,
    telEmergencia_enc
FROM club.Empleado;