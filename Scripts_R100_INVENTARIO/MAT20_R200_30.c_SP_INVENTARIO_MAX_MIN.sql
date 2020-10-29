-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO_MAXIMOS/MINIMOS
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20201022
-- ////////////////////////////////////////////////////////////// 

 USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO_MIN_MAX]
GO
--	SELECT * FROM		[COMPRAS].[dbo].ITEM WHERE K_CLASS_ITEM=2
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_MIN_MAX] 0,139, '',-1	
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_MIN_MAX] 0,139, '',128
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25),
	@PP_K_VENDOR					INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_LI_N_REGISTROS		INT =5000
	-- ///////////////////////////////////////////
	-- =========================================		
	DECLARE @VP_K_FOLIO				INT
	EXECUTE [BD_GENERAL].DBO.[PG_RN_OBTENER_ID_X_REFERENCIA]			
								@PP_BUSCAR,	@OU_K_ELEMENTO = @VP_K_FOLIO	OUTPUT
	-- =========================================		
	SELECT		TOP (@VP_LI_N_REGISTROS)
				-- =============================
				K_ITEM
				,D_ITEM
				,CANTIDAD_MINIMA
				,CANTIDAD_MAXIMA
				,PART_NUMBER_ITEM_VENDOR
				,PART_NUMBER_ITEM_PEARL
				,D_VENDOR
				-- =============================	
	FROM		[COMPRAS].[dbo].ITEM
	INNER JOIN  [COMPRAS].[dbo].VENDOR ON VENDOR.K_VENDOR=ITEM.K_VENDOR
				-- =============================
	WHERE		(	ITEM.K_ITEM=@VP_K_FOLIO
				OR	D_ITEM					LIKE '%'+@PP_BUSCAR+'%'		)
				-- =============================
	AND			(@PP_K_VENDOR=-1	OR	@PP_K_VENDOR=ITEM.K_VENDOR)
				-- =============================
	AND			K_CLASS_ITEM=2
	AND			ITEM.L_BORRADO<>1
	ORDER BY	D_ITEM	DESC
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_INVENTARIO_MIN_MAX]
GO
--		 EXECUTE [dbo].[PG_SK_INVENTARIO_MIN_MAX] 0,139,70
--		 EXECUTE [dbo].[PG_SK_INVENTARIO_MIN_MAX] 0,139,180
--		 EXECUTE [dbo].[PG_SK_INVENTARIO_MIN_MAX] 0,139,181
CREATE PROCEDURE [dbo].[PG_SK_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM						INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		TOP (1)
				-- =============================
				K_ITEM
				,D_ITEM
				,CANTIDAD_MINIMA
				,CANTIDAD_MAXIMA
				,PART_NUMBER_ITEM_VENDOR
				,PART_NUMBER_ITEM_PEARL
				,D_VENDOR
				,ITEM.K_VENDOR
				-- =============================	
	FROM		[COMPRAS].[dbo].ITEM
	INNER JOIN  [COMPRAS].[dbo].VENDOR ON VENDOR.K_VENDOR=ITEM.K_VENDOR
				-- =============================
	WHERE		ITEM.K_ITEM=@PP_K_ITEM
	AND			K_CLASS_ITEM=2
	AND			ITEM.L_BORRADO<>1
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT LOG MIN_MAX
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]
GO
--			SELECT * FROM [COMPRAS].[dbo].LOG_INVENTARIO_MIN_MAX
CREATE PROCEDURE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM							[INT],
	-- ===========================
	@PP_CANTIDAD_MINIMA_NUEVA			[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA_NUEVA			[DECIMAL](19,4),
	@PP_CANTIDAD_MINIMA					[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
	--============================================================================
	--======================================INSERTAR EL LOG
	--============================================================================
		INSERT INTO [COMPRAS].[dbo].LOG_INVENTARIO_MIN_MAX
			(	[K_ITEM]
				-- ============================
				,[CANTIDAD_MINIMA_NUEVA]
				,[CANTIDAD_MAXIMA_NUEVA]
				,[CANTIDAD_MINIMA]	
				,[CANTIDAD_MAXIMA]
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA]			)
		VALUES	
			(	@PP_K_ITEM						
				-- ===========================
				,@PP_CANTIDAD_MINIMA_NUEVA		
				,@PP_CANTIDAD_MAXIMA_NUEVA		
				,@PP_CANTIDAD_MINIMA				
				,@PP_CANTIDAD_MAXIMA
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE()	  )

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El registro no fue insertado[L].'
			RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		END			
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZA LOS MIN_MAX DEL ITEM
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO_MIN_MAX]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO_MIN_MAX]
GO
--		 EXECUTE [dbo].[PG_UP_INVENTARIO_MIN_MAX] 0,139, 70 , '500' , '5000' 
CREATE PROCEDURE [dbo].[PG_UP_INVENTARIO_MIN_MAX]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM							[INT],
	-- ===========================
	@PP_CANTIDAD_MINIMA					[DECIMAL](19,4),
	@PP_CANTIDAD_MAXIMA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE		VARCHAR(500) = ''
			,@VP_MINIMA		DECIMAL (19,4)
			,@VP_MAXIMA     DECIMAL (19,4)
BEGIN TRANSACTION 
BEGIN TRY

		SELECT	@VP_MINIMA=CANTIDAD_MINIMA
				,@VP_MAXIMA=CANTIDAD_MAXIMA
		FROM	[COMPRAS].[dbo].ITEM
		WHERE	K_ITEM=@PP_K_ITEM
		AND		K_CLASS_ITEM=2
		AND		ITEM.L_BORRADO<>1	
	--============================================================================
	--======================================ACTUALIZAR MAX_MINIMOS
	--============================================================================
		UPDATE [COMPRAS].[dbo].ITEM
		SET
			[CANTIDAD_MINIMA]		= @PP_CANTIDAD_MINIMA				
			,[CANTIDAD_MAXIMA]		= @PP_CANTIDAD_MAXIMA			
		WHERE	K_ITEM=@PP_K_ITEM
		AND		K_CLASS_ITEM=2
		AND		ITEM.L_BORRADO<>1
		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El registro no fue actualizado...[I]'
			RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		END

	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE [dbo].[PG_IN_LOG_INVENTARIO_MIN_MAX]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														-- ===========================
														,@PP_K_ITEM				
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
		SET		@VP_MENSAJE = 'No es posible realizar la acción: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ITEM AS CLAVE	
-- /////////////////////////////////////////////////////////////////////
GO

---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////