/*Entrega 5:Conjunto de pruebas.Creación de Stored Procedures para inserción, modificación y eliminación de datos y registros de las tablas.
Fecha de entrega: 01/07/2025
Número de comisión: 2900
Número de grupo: 17
Materia: Bases de datos aplicadas
Alumnos:Aristimuño,Iara Belén DNI:45237225 
		Domínguez,Luana Milena DNI:46362353
		Lopardo, Tomás Matías DNI: 45495734
		Rico, Agustina Micaela DNI: 46028153
*/

Use Com2900G17;
GO

--SOCIOS
--Permite el agregado de un socio 
CREATE OR ALTER PROCEDURE socio.AgregarSocio
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

    DECLARE @ultimoNro INT;
    DECLARE @nuevoNroSocio CHAR(7);

    -- Obtener el último número y sumarle 1
    SELECT @ultimoNro = 
        ISNULL(MAX(CAST(SUBSTRING(nroSocio, 4, LEN(nroSocio)) AS INT)), 1233) + 1
    FROM socio.socio;

    -- Armar el nuevo nroSocio con formato SN-####
    SET @nuevoNroSocio = 'SN-' + RIGHT('0000' + CAST(@ultimoNro AS VARCHAR), 4);

    -- Insertar el socio con número generado
    INSERT INTO socio.socio (
        nroSocio, dni, nombre, apellido, telContacto, email, fechaNac,
        telEmergencia, nombreObraSoc, numeroObraSoc, telObraSoc, estado,
        codCat, codTutor, codInscripcion, codGrupoFamiliar
    )
    VALUES (
        @nuevoNroSocio, @dni, @nombre, @apellido, @telContacto, @email, @fechaNac,
        @telEmergencia, @nombreObraSoc, @numeroObraSoc, @telObraSoc, @estado,
        @codCat, @codTutor, @codInscripcion, @codGrupoFamiliar
    );

    PRINT 'Socio agregado correctamente con nroSocio: ' + @nuevoNroSocio;
END;
GO

--Permite eliminar un socio
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

--Permite actualizar un atributo del socio
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


--TARIFARIOS
--Permite agregar una tarifa a la tabla actividad
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

--Permite agregar una tarifa a la tabla categoria de socio
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


--Permite modificar una tarifa a la tabla actividad
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

--Permite modificar una tarifa a la tabla categoria de socio
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

--Permite eliminar una tarifa a la tabla actividad
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

--Permite elimiar una tarifa a la tabla categoria de socio
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

--Permite a un socio ver sus cuotas pagas, su estado y el de su grupo familiar(si tiene)
CREATE PROCEDURE socio.VerPagosYEstado
    @nroSocio CHAR(7)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idSocio INT;
    DECLARE @idGrupoFamiliar INT;
    DECLARE @rolGrupo VARCHAR(20);

    -- Obtener ID del socio y grupo
    SELECT @idSocio = ID_socio, @idGrupoFamiliar = codGrupoFamiliar
    FROM socio.socio
    WHERE nroSocio = @nroSocio;

    IF @idSocio IS NULL
    BEGIN
        RAISERROR('Socio no encontrado', 16, 1);
        RETURN;
    END
    -- Determinar rol del socio en el grupo familiar
    IF @idGrupoFamiliar IS NULL
    BEGIN
        -- Ver si alguien lo tiene como responsable de pago
        IF EXISTS (
            SELECT 1
            FROM socio.socio
            WHERE codGrupoFamiliar = @idSocio
        )
            SET @rolGrupo = 'Responsable';
        ELSE
            SET @rolGrupo = 'Sin grupo';
    END
    ELSE
        SET @rolGrupo = 'Miembro';
    -- Mostrar estado del socio
    SELECT 
        S.nroSocio,
        S.nombre,
        S.apellido,
        S.estado AS estadoSocio,
        GR.nroSocio AS nroSocioResponsable,
        GR.nombre AS nombreResponsable,
        @rolGrupo AS rolEnGrupo
    FROM socio.socio S
    LEFT JOIN socio.socio GR ON S.codGrupoFamiliar = GR.ID_socio
    WHERE S.ID_socio = @idSocio;

    -- Mostrar pagos realizados del grupo (si aplica)
    SELECT 
        S.nroSocio,
        S.nombre,
        S.apellido,
        PF.Fecha_Pago,
        PF.montoTotal,
        PF.medioPago
    FROM socio.socio S
    INNER JOIN tesoreria.pagoFactura PF ON S.ID_socio = PF.codSocio
    WHERE 
        PF.estadoPago = 'R' AND (
            S.ID_socio = @idSocio OR
            S.codGrupoFamiliar = @idSocio OR
            S.codGrupoFamiliar = @idGrupoFamiliar
        )
    ORDER BY PF.Fecha_Pago DESC;
END;
GO

--Permite a un socio agregar a otro a un grupo familiar
CREATE PROCEDURE socio.AgregarSocioAGrupoFamiliar
    @nroSocioResponsabledePago CHAR(7),       -- Socio que es responsable del grupo
    @nroSocioAAgregar CHAR(7)         -- Socio que se desea agregar
AS
BEGIN
    DECLARE @idResponsabledePago INT;

    -- Obtener el ID del socio referente
    SELECT @idResponsabledePago = ID_socio
    FROM socio.socio
    WHERE nroSocio = @nroSocioResponsabledePago;

    IF @idResponsabledePago IS NULL
    BEGIN
        RAISERROR('Socio referente no encontrado', 16, 1);
        RETURN;
    END

    -- Asignar al grupo familiar
    UPDATE socio.socio
    SET codGrupoFamiliar = @idResponsabledePago
    WHERE nroSocio = @nroSocioAAgregar;

    -- Mostrar grupo actualizado
    SELECT nroSocio, nombre, apellido
    FROM socio.socio
    WHERE codGrupoFamiliar = @idResponsabledePago;
END;
GO

--Permite a un socio quitar a otro a un grupo familiar
CREATE PROCEDURE socio.QuitarSocioDeGrupoFamiliar
    @nroSocioResponsabledePago CHAR(7),       -- Socio que representa al grupo
    @nroSocioAQuitar CHAR(7)          -- Socio que se desea quitar
AS
BEGIN
    DECLARE @idResponsabledePago INT;

    -- Obtener el ID del socio referente
    SELECT @idResponsabledePago = ID_socio
    FROM socio.socio
    WHERE nroSocio = @nroSocioResponsabledePago;

    IF @idResponsabledePago IS NULL
    BEGIN
        RAISERROR('Socio referente no encontrado', 16, 1);
        RETURN;
    END

    -- Quitar del grupo familiar (solo si pertenece al grupo del referente)
    UPDATE socio.socio
    SET codGrupoFamiliar = NULL
    WHERE nroSocio = @nroSocioAQuitar AND codGrupoFamiliar = @idResponsabledePago;

    -- Mostrar grupo actualizado
    SELECT nroSocio, nombre, apellido
    FROM socio.socio
    WHERE codGrupoFamiliar = @idResponsabledePago;
END;
GO

--Permite buscar a un socio por su nombre si se lo quiere invitar
CREATE PROCEDURE socio.BuscarSociosPorNombre
    @nombreBusqueda VARCHAR(50)
AS
BEGIN
    SELECT s.nroSocio, s.nombre, s.apellido
    FROM socio.socio s
    WHERE s.nombre LIKE '%' + @nombreBusqueda + '%';
END;
GO

--Permite que un socio invite a otro a la pileta
CREATE PROCEDURE socio.InvitarASocio
    @nroSocioInvitante CHAR(7),
    @nroSocioInvitado CHAR(7)
AS
BEGIN
    INSERT INTO socio.invitacionPileta (nroSocioInvitante, nroSocioInvitado)
    VALUES (@nroSocioInvitante, @nroSocioInvitado);
END;
GO
----------------------------------------------------
