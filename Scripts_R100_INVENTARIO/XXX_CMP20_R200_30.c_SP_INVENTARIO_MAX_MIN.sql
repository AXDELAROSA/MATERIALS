-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO_MAX_MIN
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	2020106
-- ////////////////////////////////////////////////////////////// 

 USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO_MIN_MAX]
GO
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_MIN_MAX] 0,139, '',-1
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25),
	@PP_K_LOCACION					INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_LI_N_REGISTROS		INT =5000
	-- ///////////////////////////////////////////
	-- =========================================		
	DECLARE @VP_K_FOLIO				INT
	EXECUTE [BD_GENERAL].DBO.[PG_RN_OBTENER_ID_X_REFERENCIA]			
								@PP_BUSCAR,	@OU_K_ELEMENTO = @VP_K_FOLIO	OUTPUT
	-- =========================================		
	IF @VP_MENSAJE=''
	BEGIN
	SELECT		TOP (@VP_LI_N_REGISTROS)
				-- =============================
				D_ITEM
				,INVENTARIO_MIN_MAX.*
				-- =============================	
	FROM		INVENTARIO_MIN_MAX
	INNER JOIN	[COMPRAS_Pruebas].[dbo].ITEM			ON INVENTARIO_MIN_MAX.K_ITEM=ITEM.K_ITEM
				-- =============================
	WHERE		(	INVENTARIO_MIN_MAX.K_INVENTARIO_MIN_MAX=@VP_K_FOLIO
				OR	D_ITEM								LIKE '%'+@PP_BUSCAR+'%'		)
				-- =============================
	AND			ITEM.L_BORRADO<>1
	AND			INVENTARIO_MIN_MAX.L_BORRADO<>1
	ORDER BY	D_ITEM	DESC
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_INVENTARIO_MIN_MAX]
GO
--		 EXECUTE [dbo].[PG_SK_INVENTARIO_MIN_MAX] 0,139,6
CREATE PROCEDURE [dbo].[PG_SK_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INVENTARIO_MIN_MAX		INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		TOP (1)
				-- =============================
				D_ITEM
				,INVENTARIO_MIN_MAX.*
				-- =============================	
	FROM		INVENTARIO_MIN_MAX
	INNER JOIN	[COMPRAS_Pruebas].[dbo].ITEM			ON INVENTARIO_MIN_MAX.K_ITEM=ITEM.K_ITEM
				-- =============================
	WHERE		INVENTARIO_MIN_MAX.K_INVENTARIO_MIN_MAX=@PP_K_INVENTARIO_MIN_MAX
	AND			INVENTARIO_MIN_MAX.L_BORRADO<>1		
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT LOG MIN_MAX
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]
GO

CREATE PROCEDURE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INVENTARIO_MIN_MAX		INT,
	@PP_K_ITEM							[INT],
	-- ===========================
	@PP_CANTIDAD_MINIMA_NUEVA			[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA_NUEVA			[DECIMAL](19,4),
	@PP_CANTIDAD_MINIMA					[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
	
	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================INSERTAR EL LOG
	--============================================================================
		INSERT INTO LOG_INVENTARIO_MIN_MAX
			(	[K_INVENTARIO_MIN_MAX]
				,[K_ITEM]
				-- ============================
				,[CANTIDAD_MINIMA_NUEVA]
				,[CANTIDAD_MAXIMA_NUEVA]
				,[CANTIDAD_MINIMA]	
				,[CANTIDAD_MAXIMA]
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA]			)
		VALUES	
			(	@PP_K_INVENTARIO_MIN_MAX
				,@PP_K_ITEM						
				-- ===========================
				,@PP_CANTIDAD_MINIMA_NUEVA		
				,@PP_CANTIDAD_MAXIMA_NUEVA		
				,@PP_CANTIDAD_MINIMA				
				,@PP_CANTIDAD_MAXIMA
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE()	  )

		IF @@ROWCOUNT = 0
		BEGIN
			--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
			SET @VP_MENSAJE='El registro no fue insertado[L].'
			RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		END
				
	END	
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT MIN_MAX
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_MIN_MAX]
GO

CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM							[INT],
	-- ===========================
	@PP_CANTIDAD_MINIMA					[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
	DECLARE @VP_K_INVENTARIO_MIN_MAX		INT
BEGIN TRANSACTION 
BEGIN TRY	
	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================INSERTAR MAX_MINIMOS
	--============================================================================
		INSERT INTO INVENTARIO_MIN_MAX
			(	[K_ITEM]
				-- ============================
				,[CANTIDAD_MINIMA]	
				,[CANTIDAD_MAXIMA]
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA]			)
		VALUES	
			(	@PP_K_ITEM						
				-- ===========================
				,@PP_CANTIDAD_MINIMA				
				,@PP_CANTIDAD_MAXIMA
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE()	  )

		IF @@ROWCOUNT = 0
		BEGIN
			--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
			SET @VP_MENSAJE='El registro no fue insertado...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		END
		ELSE
		BEGIN
			SELECT @VP_K_INVENTARIO_MIN_MAX=SCOPE_IDENTITY()

			IF @VP_K_INVENTARIO_MIN_MAX=NULL
			BEGIN
				--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
				SET @VP_MENSAJE='No se asignó valor al registro...'
				RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
			END
		END
				
	END

	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														-- ===========================
														,@VP_K_INVENTARIO_MIN_MAX			,@PP_K_ITEM				
														-- ==========================
														,@PP_CANTIDAD_MINIMA				,@PP_CANTIDAD_MAXIMA		
														,0									,0
	END
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar] el registro: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_INVENTARIO_MIN_MAX AS CLAVE	
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT MIN_MAX
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO_MIN_MAX]
GO

CREATE PROCEDURE [dbo].[PG_UP_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INVENTARIO_MIN_MAX			[INT],
	@PP_K_ITEM							[INT],
	-- ===========================
	@PP_CANTIDAD_MINIMA					[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
	DECLARE @VP_K_INVENTARIO_MIN_MAX		INT
BEGIN TRANSACTION 
BEGIN TRY	
	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================ACTUALIZAR MAX_MINIMOS
	--============================================================================
		UPDATE INVENTARIO_MIN_MAX
		SET
			[K_ITEM]				= @PP_K_ITEM						
			-- ====================== ===========================
			,[CANTIDAD_MINIMA]		= @PP_CANTIDAD_MINIMA				
			,[CANTIDAD_MAXIMA]		= @PP_CANTIDAD_MAXIMA
			-- ====================== ============================
			,[K_USUARIO_ALTA] 		= @PP_K_USUARIO_ACCION
			,[F_ALTA]				= GETDATE()
		WHERE	K_INVENTARIO_MIN_MAX=@PP_K_INVENTARIO_MIN_MAX
		
		IF @@ROWCOUNT = 0
		BEGIN
			--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
			SET @VP_MENSAJE='El registro no fue actualizado...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		END
				
	END

	IF @VP_MENSAJE=''
	BEGIN
		DECLARE @VP_MINIMA DECIMAL (19,4),	@VP_MAXIMA DECIMAL (19,4)

		SELECT	@VP_MINIMA=CANTIDAD_MINIMA,
				@VP_MAXIMA=CANTIDAD_MAXIMA
		FROM	INVENTARIO_MIN_MAX
		WHERE	K_INVENTARIO_MIN_MAX=@PP_K_INVENTARIO_MIN_MAX
		AND		K_ITEM=@PP_K_ITEM

		EXECUTE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														-- ===========================
														,@PP_K_INVENTARIO_MIN_MAX			,@PP_K_ITEM				
														-- ==========================
														,@PP_CANTIDAD_MINIMA				,@PP_CANTIDAD_MAXIMA		
														,@VP_MINIMA							,@VP_MAXIMA
	END
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar] el registro: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_INVENTARIO_MIN_MAX AS CLAVE	
-- /////////////////////////////////////////////////////////////////////
GO

---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////