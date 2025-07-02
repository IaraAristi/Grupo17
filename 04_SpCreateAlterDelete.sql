Use Com2900G17;
GO

--agregar socio

CREATE OR ALTER PROCEDURE socio.AgregarSocio
    @nroSocio CHAR(7),
    @dni CHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @telContacto INT,
    @email VARCHAR(50),
    @fechaNac DATE,
    @telEmergencia INT,
    @nombreObraSoc VARCHAR(40),
    @numeroObraSoc VARCHAR(20),
    @telObraSoc CHAR(30),
    @estado CHAR(1),
    @codCat INT = NULL,
    @codTutor INT = NULL,
    @codInscripcion INT = NULL,
    @codGrupoFamiliar INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO socio.socio (
        nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
        telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado,
        codCat, codTutor, codInscripcion, codGrupoFamiliar
    )
    VALUES (
        @nroSocio, @dni, @nombre, @apellido, @telContacto, @email, @fechaNac,
        @telEmergencia, @nombreObraSoc, @numeroObraSoc, @telObraSoc, @estado,
        @codCat, @codTutor, @codInscripcion, @codGrupoFamiliar
    );

    PRINT 'Socio agregado correctamente.';
END;
GO

--eliminar socio

CREATE OR ALTER PROCEDURE socio.EliminarSocio
    @ID_socio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el socio existe
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'El socio no existe.';
        RETURN;
    END

    BEGIN TRY
        DELETE FROM socio.socio
        WHERE ID_socio = @ID_socio;

        PRINT 'Socio eliminado correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al intentar eliminar el socio. Es posible que esté referenciado en otras tablas (por ejemplo facturas, presentismo, etc).';
    END CATCH
END;
GO

--actualizar socio
CREATE OR ALTER PROCEDURE socio.ModificarAtributoSocio
    @ID_socio INT,
    @atributo SYSNAME,         -- nombre de columna
    @nuevoValor NVARCHAR(MAX)  -- valor como cadena
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia del socio
    IF NOT EXISTS (SELECT 1 FROM socio.socio WHERE ID_socio = @ID_socio)
    BEGIN
        PRINT 'Error: No existe un socio con ese ID.';
        RETURN;
    END

    -- Verificar que la columna exista y obtener info del tipo
    DECLARE @tipoDato NVARCHAR(128);
    DECLARE @longitud INT;
    DECLARE @tipoCompleto NVARCHAR(150);

    SELECT 
        @tipoDato = DATA_TYPE,
        @longitud = CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'socio' AND TABLE_NAME = 'socio' AND COLUMN_NAME = @atributo;

    IF @tipoDato IS NULL
    BEGIN
        PRINT 'Error: La columna especificada no existe.';
        RETURN;
    END

    -- Construir el tipo con longitud si es texto
    IF @tipoDato IN ('varchar', 'nvarchar', 'char', 'nchar')
    BEGIN
        IF @longitud = -1
            SET @tipoCompleto = @tipoDato + '(MAX)';
        ELSE
            SET @tipoCompleto = @tipoDato + '(' + CAST(@longitud AS NVARCHAR(10)) + ')';
    END
    ELSE
    BEGIN
        SET @tipoCompleto = @tipoDato;
    END

    -- Construir SQL dinámico con CAST a tipo correcto
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        UPDATE socio.socio
        SET ' + QUOTENAME(@atributo) + ' = CAST(@nuevoValor AS ' + @tipoCompleto + ')
        WHERE ID_socio = @id;
    ';

    BEGIN TRY
        EXEC sp_executesql 
            @sql,
            N'@id INT, @nuevoValor NVARCHAR(MAX)',
            @id = @ID_socio,
            @nuevoValor = @nuevoValor;

        PRINT 'Atributo actualizado correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar el atributo: ' + ERROR_MESSAGE();
    END CATCH
END;
GO



---Tarifarios

CREATE OR ALTER PROCEDURE club.AgregarTarifarioActividad
    @fechaVigenciaHasta DATE,
    @actividad VARCHAR(20),
    @costoActividad DECIMAL(7,2),
    @codAct INT
AS
BEGIN
    SET NOCOUNT ON;

    --verificar si existe la actividad
    IF NOT EXISTS (
        SELECT 1 FROM club.actDeportiva WHERE codAct = @codAct
    )
    BEGIN
        RAISERROR('La actividad especificada no existe.', 16, 1);
        RETURN;
    END;

    INSERT INTO club.TarifarioActividad (
        fechaVigenciaHasta,
        actividad,
        costoActividad,
        codAct
    )
    VALUES (
        @fechaVigenciaHasta,
        @actividad,
        @costoActividad,
        @codAct
    );

    PRINT 'Tarifa de actividad agregada correctamente.';
END;
GO

CREATE OR ALTER PROCEDURE club.AgregarTarifarioCatSocio
    @fechaVigenciaHasta DATE,
    @categoria VARCHAR(6),
    @costoMembresia DECIMAL(7,2),
    @catSocio INT
AS
BEGIN
    SET NOCOUNT ON;

    --verificar si existe la categoría
    IF NOT EXISTS (
        SELECT 1 FROM club.catSocio WHERE codCat = @catSocio
    )
    BEGIN
        RAISERROR('La categoría de socio especificada no existe.', 16, 1);
        RETURN;
    END;

    INSERT INTO club.TarifarioCatSocio (
        fechaVigenciaHasta,
        categoria,
        costoMembresia,
        catSocio
    )
    VALUES (
        @fechaVigenciaHasta,
        @categoria,
        @costoMembresia,
        @catSocio
    );

    PRINT 'Tarifa de categoría de socio agregada correctamente.';
END;
GO

--modificaciones

CREATE OR ALTER PROCEDURE club.ModificarTarifarioActividad
    @idCuotaAct INT,
    @fechaVigenciaHasta DATE,
    @actividad VARCHAR(20),
    @costoActividad DECIMAL(7,2),
    @codAct INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si existe el registro a modificar
    IF NOT EXISTS (
        SELECT 1 FROM club.TarifarioActividad WHERE idCuotaAct = @idCuotaAct
    )
    BEGIN
        RAISERROR('La tarifa de actividad especificada no existe.', 16, 1);
        RETURN;
    END;

    -- Verificar si existe la actividad
    IF NOT EXISTS (
        SELECT 1 FROM club.actDeportiva WHERE codAct = @codAct
    )
    BEGIN
        RAISERROR('La actividad especificada no existe.', 16, 1);
        RETURN;
    END;

    UPDATE club.TarifarioActividad
    SET fechaVigenciaHasta = @fechaVigenciaHasta,
        actividad = @actividad,
        costoActividad = @costoActividad,
        codAct = @codAct
    WHERE idCuotaAct = @idCuotaAct;

    PRINT 'Tarifa de actividad modificada correctamente.';
END;
GO



CREATE OR ALTER PROCEDURE club.ModificarTarifarioCatSocio
    @idCuotaCatSocio INT,
    @fechaVigenciaHasta DATE,
    @categoria VARCHAR(6),
    @costoMembresia DECIMAL(7,2),
    @catSocio INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si existe el registro a modificar
    IF NOT EXISTS (
        SELECT 1 FROM club.TarifarioCatSocio WHERE idCuotaCatSocio = @idCuotaCatSocio
    )
    BEGIN
        RAISERROR('La tarifa de categoría especificada no existe.', 16, 1);
        RETURN;
    END;

    -- Verificar si existe la categoria de socio
    IF NOT EXISTS (
        SELECT 1 FROM club.catSocio WHERE codCat = @catSocio
    )
    BEGIN
        RAISERROR('La categoría de socio especificada no existe.', 16, 1);
        RETURN;
    END;

    UPDATE club.TarifarioCatSocio
    SET fechaVigenciaHasta = @fechaVigenciaHasta,
        categoria = @categoria,
        costoMembresia = @costoMembresia,
        catSocio = @catSocio
    WHERE idCuotaCatSocio = @idCuotaCatSocio;

    PRINT 'Tarifa de categoría de socio modificada correctamente.';
END;
GO


--eliminaciones
CREATE OR ALTER PROCEDURE club.EliminarTarifarioActividad
    @idCuotaAct INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM club.TarifarioActividad WHERE idCuotaAct = @idCuotaAct
    )
    BEGIN
        RAISERROR('La tarifa de actividad especificada no existe.', 16, 1);
        RETURN;
    END;

    DELETE FROM club.TarifarioActividad
    WHERE idCuotaAct = @idCuotaAct;

    PRINT 'Tarifa de actividad eliminada correctamente.';
END;
GO


CREATE OR ALTER PROCEDURE club.EliminarTarifarioCatSocio
    @idCuotaCatSocio INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM club.TarifarioCatSocio WHERE idCuotaCatSocio = @idCuotaCatSocio
    )
    BEGIN
        RAISERROR('La tarifa de categoría especificada no existe.', 16, 1);
        RETURN;
    END;

    DELETE FROM club.TarifarioCatSocio
    WHERE idCuotaCatSocio = @idCuotaCatSocio;

    PRINT 'Tarifa de categoría de socio eliminada correctamente.';
END;
GO

