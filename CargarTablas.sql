USE Com2900G17
GO

--Cargar categoria de socio en Socio
-- ================================================
-- Nombre: USP_ActualizarCategoriaSociosPorEdad
-- Descripci�n: Actualiza la columna Categoria_Socio en la tabla Socios
--              bas�ndose en la fecha de nacimiento del socio y las reglas
--              definidas en la tabla Categoria_Socios.
-- Fecha Creaci�n: 2025-06-22
-- ================================================
CREATE OR ALTER PROCEDURE ddbba.ActualizarCategoriaSociosPorEdad
AS
BEGIN
    -- Desactivar el conteo de filas afectadas para mejorar el rendimiento
    SET NOCOUNT ON;

    -- Iniciar una transacci�n para asegurar la atomicidad de la operaci�n
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE s
        SET s.codCat = cs.codCat
        FROM
            ddbba.socio AS s
        JOIN
            (
                -- Subconsulta para calcular la edad actual de cada socio
                SELECT
                    ID_Socio,
                    fechaNac,
                    -- Calcula la edad en a�os completos (para SQL Server)
                    DATEDIFF(year, fechaNac, GETDATE()) -
                    CASE
                        WHEN MONTH(fechaNac) > MONTH(GETDATE()) OR
                             (MONTH(fechaNac) = MONTH(GETDATE()) AND DAY(fechaNac) > DAY(GETDATE()))
                        THEN 1
                        ELSE 0
                    END AS EdadActual
                FROM
                    ddbba.socio
                WHERE
                    fechaNac IS NOT NULL
            ) AS s_edad ON s.ID_Socio = s_edad.ID_Socio
        JOIN
            ddbba.catSocio AS cs ON s_edad.EdadActual >= cs.edad_desde
                                    AND (s_edad.EdadActual <= cs.edad_hasta OR cs.edad_hasta IS NULL)
        WHERE
            s.fechaNac IS NOT NULL; -- Solo actualiza a socios con fecha de nacimiento

        -- Confirmar la transacci�n si todo fue bien
        COMMIT TRANSACTION;

        PRINT 'La actualizaci�n de la categor�a de socios se complet� exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, revertir la transacci�n
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capturar y mostrar informaci�n del error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

        PRINT 'Ocurri� un error durante la actualizaci�n de la categor�a de socios. La transacci�n fue revertida.';
    END CATCH;
END;
GO
