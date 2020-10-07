-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20200926
-- ////////////////////////////////////////////////////////////// 

 USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO]
GO
--		 EXECUTE [dbo].[PG_LI_INVENTARIO] 0,139,'',-1,-1,-1,null,null
--		 EXECUTE [dbo].[PG_LI_INVENTARIO] 0,139, '' , -1 , -1 , '2020-06-08' , '2020-10-01'
--		 EXECUTE [dbo].[PG_LI_INVENTARIO] 0,139,  '' , -1 , -1 , '2020/09/01' , '2020/09/29' 
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25),
	@PP_K_VENDOR					INT,
	@PP_K_LOCACION					INT,
	@PP_F_INIT						DATE,
	@PP_F_FINISH					DATE
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
				INVENTARIO.F_DATE_INVENTARIO
				,D_VENDOR
				,D_ITEM
				,D_STATUS_INVENTARIO
				,S_STATUS_INVENTARIO
				,D_PIEL_CLASIFICACION as D_CLASIFICACION
				,S_PIEL_CLASIFICACION as S_CLASIFICACION
				,loc
				,K_LOCACION
				,INVENTARIO.*
				-- =============================	
	FROM		INVENTARIO
	INNER JOIN	FOLIO									ON FOLIO.K_FOLIO=INVENTARIO.K_FOLIO
	INNER JOIN 	IMLOCFIL_SQL							ON IMLOCFIL_SQL.A4GLIdentity=FOLIO.K_LOCACION
	INNER JOIN	[COMPRAS_Pruebas].[dbo].ITEM			ON INVENTARIO.K_ITEM=ITEM.K_ITEM
	INNER JOIN 	[COMPRAS_Pruebas].[dbo].VENDOR			ON VENDOR.K_VENDOR=ITEM.K_VENDOR
				-- =============================
	INNER JOIN 	STATUS_INVENTARIO			ON STATUS_INVENTARIO.K_STATUS_INVENTARIO=INVENTARIO.K_STATUS_INVENTARIO
	INNER JOIN 	PIEL_CLASIFICACION			ON PIEL_CLASIFICACION.K_PIEL_CLASIFICACION=INVENTARIO.K_CLASIFICACION
				-- =============================
	WHERE		(	INVENTARIO.K_INVENTARIO=@VP_K_FOLIO
				OR	INVENTARIO.LOTE_VENDOR				LIKE '%'+@PP_BUSCAR+'%'
				OR	INVENTARIO.LOTE_PEARL				LIKE '%'+@PP_BUSCAR+'%'
				OR	C_INVENTARIO						LIKE '%'+@PP_BUSCAR+'%'
				OR	D_ITEM								LIKE '%'+@PP_BUSCAR+'%'		)
				-- =============================
	AND			( @PP_F_INIT IS NULL		OR	@PP_F_INIT<=F_DATE_INVENTARIO)
	AND			( @PP_F_FINISH IS NULL		OR	@PP_F_FINISH>=F_DATE_INVENTARIO)
				-- =============================
	AND			( @PP_K_LOCACION	=-1		OR	FOLIO.K_LOCACION=@PP_K_LOCACION )
	AND			( @PP_K_VENDOR		=-1		OR	ITEM.K_VENDOR=@PP_K_VENDOR )
				-- =============================
	AND			INVENTARIO.L_BORRADO<>1
	ORDER BY	K_STATUS_INVENTARIO, INVENTARIO.F_DATE_INVENTARIO	DESC
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_INVENTARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_INVENTARIO]
GO
-- EXECUTE [dbo].[PG_SK_INVENTARIO] 0,139,6
CREATE PROCEDURE [dbo].[PG_SK_INVENTARIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INVENTARIO				INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		TOP (1)
	D_VENDOR
				,D_ITEM
				,D_STATUS_INVENTARIO
				,S_STATUS_INVENTARIO
				,D_PIEL_CLASIFICACION
				,S_PIEL_CLASIFICACION
				,INVENTARIO.*
				-- =============================	
	FROM		INVENTARIO
	INNER JOIN	FOLIO									ON FOLIO.K_FOLIO=INVENTARIO.K_FOLIO
	INNER JOIN 	IMLOCFIL_SQL							ON IMLOCFIL_SQL.A4GLIdentity=FOLIO.K_LOCACION
	INNER JOIN	[COMPRAS_Pruebas].[dbo].ITEM			ON INVENTARIO.K_ITEM=ITEM.K_ITEM
	INNER JOIN 	[COMPRAS_Pruebas].[dbo].VENDOR			ON VENDOR.K_VENDOR=ITEM.K_VENDOR
				-- =============================
	INNER JOIN 	STATUS_INVENTARIO			ON STATUS_INVENTARIO.K_STATUS_INVENTARIO=INVENTARIO.K_STATUS_INVENTARIO
	INNER JOIN 	PIEL_CLASIFICACION			ON PIEL_CLASIFICACION.K_PIEL_CLASIFICACION=INVENTARIO.K_CLASIFICACION
				-- =============================
	WHERE		INVENTARIO.K_INVENTARIO=@PP_K_INVENTARIO
	AND			INVENTARIO.L_BORRADO<>1		
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT PRIMERO EL FOLIO, SE OBTIENE EL VALOR INSERTADO Y SE ASIGNA EN LA TABLA DE INVENTARIO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_IN_FOLIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
--	@PP_K_ITEM								[INT],
	@PP_K_LOCACION							[INT],
	@PP_K_ORDEN_TRABAJO						[INT],
--	@PP_K_TIPO							[INT],
	@PP_TIPO								[VARCHAR] (50),
	-- ===========================
	@PP_F_DATE_FOLIO						[DATE],
	-- ============================
--	@PP_CANTIDAD_RECIBIDA					[DECIMAL](19,4),
	@PP_K_FOLIO_INSERTADO					INT				OUTPUT
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
	DECLARE @VP_K_FOLIO						INT
--BEGIN TRANSACTION 
--BEGIN TRY
		-- /////////////////////////////////////////////////////////////////////
		--	EL ID SE ASIGNA POR IDENTITY, OBTENER EL RESULTADO DE LA OPERACIÓN EN CASO DE REQUERIRLO.
	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================INSERTAR EL FOLIO
	--============================================================================
		INSERT INTO FOLIO
			(	--[K_ITEM]				
				[K_LOCACION]			
				,[K_ORDEN_TRABAJO]		
				,[TIPO]					
				-- =====================
				,[F_DATE_FOLIO]			
				-- =====================
				--,[CANTIDAD_RECIBIDA]		
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	--@PP_K_ITEM						
				@PP_K_LOCACION					
				,@PP_K_ORDEN_TRABAJO				
				,@PP_TIPO						
				-- ===========================
				,@PP_F_DATE_FOLIO				
				-- ============================
				--,@PP_CANTIDAD_RECIBIDA			
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )
						
			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='The record was not inserted.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END
			ELSE
				BEGIN
					SELECT @VP_K_FOLIO=SCOPE_IDENTITY()

					IF @VP_K_FOLIO=NULL
					BEGIN
						--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
						SET @VP_MENSAJE='The IDENTITY assign value was failed.'
						RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
					END
				END
	END

	IF @VP_MENSAJE=''
	BEGIN
		SET @PP_K_FOLIO_INSERTADO=@VP_K_FOLIO
	END	
-- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	/* Ocurrió un error, deshacemos los cambios*/ 
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'Not is possible [Insert] at [INVENTARIO]: ' + @VP_MENSAJE 
--	END
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PO_TEMPORAL AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT	SE MANDA LAMAR DESDE RECIBO_BPO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_RECIBO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_RECIBO]
GO

CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_RECIBO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM								[INT],
	-- ===========================
	@PP_K_CLASIFICACION						[INT],
	@PP_K_STATUS_INVENTARIO					[INT],
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO				[VARCHAR](50),
	@PP_K_DETAILS_BPO_RECIBO				[INT],
	-- ===========================
	@PP_LOTE_VENDOR							[VARCHAR](50),
	@PP_LOTE_PEARL							[INT],
	@PP_LOTE_NUMERO_CONSECUTIVO				[INT],
	-- ===========================
	@PP_F_DATE_INVENTARIO					[DATE],
	@PP_C_INVENTARIO						[VARCHAR](255),
	-- ============================
	@PP_CANTIDAD_RECIBIDA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
	DECLARE @VP_K_FOLIO						INT		-- ES UNA VARIABLE DE RETORNO, PARA ASIGNAR EL FOLIO INSERTADO.
	DECLARE @VP_K_LOTE						INT		-- PARA VERIFICAR EL LOTE
	--DECLARE @VP_LOTE_PEARL					INT		-- PARA ASIGNAR EL LOTE PEARL
	--DECLARE @VP_LOTE_NUMERO_CONSECUTIVO		INT		-- PARA ASIGNAR EL CONSECUTIVO DEL LOTE PEARL
--BEGIN TRANSACTION 
--BEGIN TRY
	IF @VP_MENSAJE=''
	BEGIN
	--	PRIMERO BUSCAR EN INVENTARIO SI HAY UN K_LOCACION=4 Y TIPO 'B' ASIGNADO AL ITEM
	SET @VP_K_FOLIO= ISNULL(	(SELECT TOP(1)	--*,
										INVENTARIO.K_FOLIO
								FROM	INVENTARIO
								INNER JOIN FOLIO	ON	INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
								WHERE	K_ITEM=@PP_K_ITEM
								AND		K_LOCACION=4
								AND		TIPO='B'
								ORDER BY K_FOLIO DESC),0)

		IF @VP_K_FOLIO=0
		BEGIN
			--============================================================================
			--	REALIZA EL INSERT PARA OBTENER EL FOLIO ASIGNADO AL INGRESAR A INVENTARIO.
			EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											-- ===========================
											--@PP_K_ITEM,		
											4,	--@PP_K_LOCACION,	[A4GLIdentity]=4 (MHI)		DE: {[DATA_02].[dbo].[IMLOCFIL_SQL]}
											0,	--@PP_K_ORDEN_TRABAJO,	DEFAULT=0
											'B',--@PP_TIPO, 
											-- =========================
											@PP_F_DATE_INVENTARIO,--@PP_F_DATE_FOLIO,
											-- ==========================
											--@PP_CANTIDAD_RECIBIDA,
											@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT
		END
	END

		-- /////////////////////////////////////////////////////////////////////
		--	EL ID SE ASIGNA POR IDENTITY, OBTENER EL RESULTADO DE LA OPERACIÓN EN CASO DE REQUERIRLO.
	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================INSERTAR EL INVENTARIO
	--============================================================================
		INSERT INTO INVENTARIO
			(	[K_ITEM]					
				,[K_FOLIO]					
				-- =========================
				,[K_CLASIFICACION]			
				,[K_STATUS_INVENTARIO]		
				-- =========================
				,[K_ORDEN_COMPRA_PEDIDO]		
				,[K_DETAILS_BPO_RECIBO]		
				-- =========================
				,[LOTE_VENDOR]				
				,[LOTE_PEARL]				
				,[LOTE_NUMERO_CONSECUTIVO]	
				-- =========================
				,[F_DATE_INVENTARIO]			
				,[C_INVENTARIO]				
				-- =========================
				,[CANTIDAD_RECIBIDA]						
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_ITEM					
				,@VP_K_FOLIO					
				-- =========================
				,@PP_K_CLASIFICACION			
				,@PP_K_STATUS_INVENTARIO		
				-- =========================
				,@PP_K_ORDEN_COMPRA_PEDIDO	
				,@PP_K_DETAILS_BPO_RECIBO	
				-- =========================
				,@PP_LOTE_VENDOR				
				,@PP_LOTE_PEARL				
				,@PP_LOTE_NUMERO_CONSECUTIVO	
				-- =========================
				,@PP_F_DATE_INVENTARIO		
				,@PP_C_INVENTARIO			
				-- =========================
				,@PP_CANTIDAD_RECIBIDA
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='The record was not inserted.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END				
	END
	
-- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	/* Ocurrió un error, deshacemos los cambios*/ 
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'Not is possible [Insert] at [INVENTARIO]: ' + @VP_MENSAJE 
--	END
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ITEM AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_MOVIMIENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_MOVIMIENTO]
GO

CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_MOVIMIENTO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LOCACION							[INT],
	-- ===========================
	@PP_K_INVENTARIO_MOVIMIENTO_TIPO		[INT],
	-- ===========================
	@PP_LOTE_PEARL							[INT],
	-- ===========================
	@PP_CANTIDAD_MOVIMIENTO					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
--BEGIN TRANSACTION 
--BEGIN TRY

	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================INSERTAR EL MOVIMIENTO_INVENTARIO
	--============================================================================
		INSERT INTO MOVIMIENTO_INVENTARIO
			(	[K_LOCACION]					
				,[K_INVENTARIO_MOVIMIENTO_TIPO]
				-- =========================
				,[LOTE_PEARL]				
				-- =========================
				,[CANTIDAD_RECIBIDA]						
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_LOCACION
				,@PP_K_INVENTARIO_MOVIMIENTO_TIPO
				-- =========================	
				,@PP_LOTE_PEARL				
				-- =========================
				,@PP_CANTIDAD_MOVIMIENTO
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='El movimiento no fue insertado.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END				
	END
	
-- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	/* Ocurrió un error, deshacemos los cambios*/ 
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'Not is possible [Insert] at [INVENTARIO]: ' + @VP_MENSAJE 
--	END
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ITEM AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_LOCACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LOCACION					[INT],
	@PP_K_ITEM						[INT],
	-- ===========================
	@PP_LOTE_PEARL					[INT],
	-- ===========================
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
--BEGIN TRANSACTION 
--BEGIN TRY

	IF @VP_MENSAJE=''
	BEGIN
	--============================================================================
	--======================================INSERTAR EL MOVIMIENTO_INVENTARIO
	--============================================================================
		INSERT INTO MOVIMIENTO_INVENTARIO
			(	[K_LOCACION]					
				,[K_ITEM]
				-- =========================
				,[LOTE_PEARL]				
				-- =========================
				,[CANTIDAD_RECIBIDA]						
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_LOCACION
				,@PP_K_ITEM
				-- =========================	
				,@PP_LOTE_PEARL				
				-- =========================
				,@PP_CANTIDAD_MOVIMIENTO
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='El movimiento no fue insertado.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END				
	END
	
-- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	/* Ocurrió un error, deshacemos los cambios*/ 
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'Not is possible [Insert] at [INVENTARIO]: ' + @VP_MENSAJE 
--	END
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ITEM AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO




---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> UPDATE / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO]
--GO
----       EXECUTE [dbo].[PG_UP_INVENTARIO] 0, 139,												
--CREATE PROCEDURE [dbo].[PG_UP_INVENTARIO]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_INVENTARIO						[INT],
--	@PP_K_ITEM								[INT],
--	@PP_K_FOLIO								[INT],
--	-- ===========================
--	@PP_K_CLASIFICACION						[INT],
--	@PP_K_STATUS_INVENTARIO					[INT],
--	-- ===========================
--	@PP_K_ORDEN_COMPRA_PEDIDO				[VARCHAR](50),
--	@PP_K_DETAILS_BPO_RECIBO				[INT],
--	-- ===========================
--	@PP_LOTE_VENDOR							[VARCHAR](50),
--	@PP_LOTE_PEARL							[INT],
--	@PP_LOTE_NUMERO_CONSECUTIVO				[INT],
--	-- ===========================
--	@PP_F_DATE_INVENTARIO					[DATE],
--	@PP_C_INVENTARIO						[VARCHAR](255),
--	-- ============================
--	@PP_CANTIDAD_RECIBIDA					[DECIMAL](19,4)
--AS			
--DECLARE @VP_MENSAJE				VARCHAR(300) = ''
--BEGIN TRANSACTION 
--BEGIN TRY
--	-- /////////////////////////////////////////////////////////////////////
--	--IF @VP_MENSAJE=''
--	--BEGIN
--	--	EXECUTE [dbo].[PG_RN_INVENTARIO_UPDATE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--	--													@PP_K_INVENTARIO, @PP_K_PO_TEMPORAL,
--	--													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
--	--END
--	-- /////////////////////////////////////////////////////////////////////
--	IF @VP_MENSAJE=''
--	BEGIN
--		UPDATE	INVENTARIO
--		SET		
--				[K_ITEM]							= @PP_K_ITEM	
--				,[K_FOLIO]							= @PP_K_FOLIO					
--				-- ============================	-- ============================
--				,[K_CLASIFICACION]					= @PP_K_CLASIFICACION			
--				,[K_STATUS_INVENTARIO]				= @PP_K_STATUS_INVENTARIO		
--				-- ============================	-- ============================
--				,[K_ORDEN_COMPRA_PEDIDO]			= @PP_K_ORDEN_COMPRA_PEDIDO	
--				,[K_DETAILS_BPO_RECIBO]				= @PP_K_DETAILS_BPO_RECIBO	
--				-- ============================-- ============================
--				,[LOTE_VENDOR]						= @PP_LOTE_VENDOR				
--				,[LOTE_PEARL]						= @PP_LOTE_PEARL				
--				,[LOTE_NUMERO_CONSECUTIVO]			= @PP_LOTE_NUMERO_CONSECUTIVO	
--				-- ============================-- ============================
--				,[F_DATE_INVENTARIO]				= @PP_F_DATE_INVENTARIO		
--				,[C_INVENTARIO]						= @PP_C_INVENTARIO			
--				-- ============================-- =============================
--				,[CANTIDAD_RECIBIDA]				= @PP_CANTIDAD_RECIBIDA		
--				-- ============================		= -- ============================
--				,[F_CAMBIO]							= GETDATE()
--				,[K_USUARIO_CAMBIO]					= @PP_K_USUARIO_ACCION
--		WHERE	[K_INVENTARIO]=@PP_K_INVENTARIO
--		IF @@ROWCOUNT = 0
--			BEGIN
--				SET @VP_MENSAJE='The record was not updated. [INV#'+CONVERT(VARCHAR(10),@PP_K_INVENTARIO)+']'
--				RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
--			END
--	END
		
	
---- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'Not is possible [Update] at [INVENTARIO]: ' + @VP_MENSAJE 
--	END

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INVENTARIO AS CLAVE
--	-- //////////////////////////////////////////////////////////////	
--GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////
----	EXECUTE [dbo].[PG_DL_INVENTARIO] 0,139,380,2,2
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_INVENTARIO]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_DL_INVENTARIO]
--GO
--CREATE PROCEDURE [dbo].[PG_DL_INVENTARIO]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_INVENTARIO				INT
--AS
--DECLARE @VP_MENSAJE				VARCHAR(300) = ''
--BEGIN TRANSACTION 
--BEGIN TRY
----/////////////////////////////////////////////////////////////
----	IF @VP_MENSAJE=''
----	BEGIN
----		EXECUTE [dbo].[PG_RN_INVENTARIO_DELETE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
----													@PP_K_INVENTARIO,  @PP_K_PO_TEMPORAL,
----													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
----	END
--	--////////////////////////////////////////////////////////////
--	IF @VP_MENSAJE=''
--	BEGIN		
--		UPDATE	INVENTARIO
--		SET		
--				[L_BORRADO]				= 1,
--				[K_STATUS_INVENTARIO]	= 0,
--				-- ====================
--				[F_BAJA]				= GETDATE(), 
--				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
--		WHERE	K_INVENTARIO=@PP_K_INVENTARIO

--		IF @@ROWCOUNT = 0
--			BEGIN
--				SET @VP_MENSAJE='The record was not updated. [INV#'+CONVERT(VARCHAR(10),@PP_K_INVENTARIO)+']'
--			END
--	END
---- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	

--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'Not is possible [Deleted] at [INVENTARIO]: ' + @VP_MENSAJE 
--	END

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INVENTARIO AS CLAVE
--	-- //////////////////////////////////////////////////////////////	
--GO



---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////