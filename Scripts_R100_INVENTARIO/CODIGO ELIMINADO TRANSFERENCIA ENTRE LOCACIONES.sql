-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	PARA MOVER DESDE LA PANTALLA DE INVENTARIO DE MHI(A-B) A MQU
-- //	
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_MHI_A_MQU]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MHI_A_MQU]
GO

CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MHI_A_MQU]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],				--	LOCACION #4		MHI
	@PP_K_LOCACION_DESTINO			[INT],				--	LOCACION #6		MQU
	@PP_K_INVENTARIO				[INT],
	@PP_SERIE_NO					[VARCHAR](50),
	@PP_K_TIPO_MOVIMIENTO			[INT],
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4)		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_K_FOLIO				INT
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)
			,@VP_K_FOLIO_ORIGEN			INT
			,@VP_K_ORDEN_TRABAJO_ORIGEN	INT
--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	@VP_K_FOLIO_ORIGEN			=INVENTARIO.K_FOLIO,
			@VP_K_ORDEN_TRABAJO_ORIGEN	=K_ORDEN_TRABAJO
	FROM	INVENTARIO
	INNER JOIN FOLIO ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM 
	AND		K_LOCACION				=@PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				=@PP_LOTE_PEARL
	AND		K_ENTREGA				=@PP_K_ENTREGA				
	AND		K_STATUS_INVENTARIO		=20
	AND		K_INVENTARIO			=@PP_K_INVENTARIO
	AND		SERIE_NO				=@PP_SERIE_NO
	AND		INVENTARIO.L_BORRADO<>1

	IF @VP_K_FOLIO_ORIGEN IS NULL
	BEGIN
		SET @VP_MENSAJE='Folio Origen no encontrado...Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
--=====================================================================================================================================
	--====		SE CREA EL FOLIO PARA EL MATERIAL
		DECLARE @VP_F_DATE_FOLIO	DATE = GETDATE()
		EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										-- ===========================
										--@PP_K_ITEM,		
										6,	--@PP_K_LOCACION,	[A4GLIdentity]=4 (MHI)/107(RW0)/6(MQU)		DE: {[DATA_02].[dbo].[IMLOCFIL_SQL]}
										0,	--@PP_K_ORDEN_TRABAJO,	DEFAULT=0
										'A',--@PP_TIPO, 
										-- =========================
										@VP_F_DATE_FOLIO,
										-- ==========================
										--@PP_CANTIDAD_RECIBIDA,
										@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT

--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS, ES LA CANTIDAD DISPONIBLE DEL MATERIAL EN LA TABLA DE INVENTARIO.
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	CANTIDAD_RECIBIDA
									FROM	INVENTARIO
									WHERE	K_ITEM					=@PP_K_ITEM
									AND		LOTE_PEARL				=@PP_LOTE_PEARL
									AND		K_ENTREGA				=@PP_K_ENTREGA
									AND		SERIE_NO				=@PP_SERIE_NO
									AND		K_INVENTARIO			=@PP_K_INVENTARIO
									AND		K_STATUS_INVENTARIO		=20
									AND		INVENTARIO.L_BORRADO<>1					)
											
			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
				
			
			IF @PP_CANTIDAD_MOVIMIENTO > 0
				BEGIN
					IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
							BEGIN
							SET @VP_MENSAJE='La cantidad movimiento no pude mayor a la cantidad disponible. ['+CONVERT(VARCHAR(10),@PP_SERIE_NO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
							END
						ELSE
							BEGIN
								SET @VP_QTY_MOVIMIENTO = @PP_CANTIDAD_MOVIMIENTO
							END
				END
--=====================================================================================================================================
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
												,@VP_K_ORDEN_TRABAJO_ORIGEN
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												,@VP_QTY_MOVIMIENTO	
												,@PP_K_TIPO_MOVIMIENTO

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													-- ===========================
													,@PP_K_INVENTARIO				,@PP_K_ITEM						
													,@PP_K_TIPO_MOVIMIENTO			,@PP_LOTE_PEARL
													,@PP_SERIE_NO
													-- ============================	
													,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
													,@VP_K_ORDEN_TRABAJO_ORIGEN
													-- ============================	
													,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
													,@VP_K_ORDEN_TRABAJO_DESTINO
													-- ============================	
													,@VP_QTY_MOVIMIENTO
--=====================================================================================================================================
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@VP_K_FOLIO
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_INVENTARIO			=@PP_K_INVENTARIO
		AND		SERIE_NO				=@PP_SERIE_NO
		AND		K_STATUS_INVENTARIO =	20	
		AND		INVENTARIO.L_BORRADO<>1

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El Folio no puede ser actualizado...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
--=====================================================================================================================================		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION
									WHERE	K_ITEM		=@PP_K_ITEM	
									AND		K_LOCACION	=@PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL	=@PP_LOTE_PEARL			)
		
		--==========================================================================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==========================================================================================				
		IF @VP_EXISTE_LOCACION=0
		BEGIN
			--============================================================================
			--======================================INSERTAR EL INVENTARIO_LOCACION
			--============================================================================
			EXECUTE	[dbo].[PG_IN_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
		END
		ELSE
		BEGIN
			EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
														,'SUMAR'
		END

		--== SE ACTUALIZA LA LOCACIÓN ORIGEN
		EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,@PP_K_LOCACION_ORIGEN		,@PP_K_ITEM
													,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
													,'RESTAR'
--=====================================================================================================================================
--=====================================================================================================================================	
-- /////////////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	PARA MOVER MATERIAL DESDE LA PANTALLA DE INVENTARIO DE MQU A MHI
-- // 
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_MQU_A_MHI]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MQU_A_MHI]
GO

CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MQU_A_MHI]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],
	@PP_K_LOCACION_DESTINO			[INT],
	@PP_K_INVENTARIO				[INT],
	@PP_SERIE_NO					[VARCHAR](50),
	@PP_K_TIPO_MOVIMIENTO			[INT],
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4)		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.

AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_K_FOLIO				INT
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)

			,@VP_K_FOLIO_ORIGEN			INT
			,@VP_K_ORDEN_TRABAJO_ORIGEN	INT
--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	@VP_K_FOLIO_ORIGEN			=INVENTARIO.K_FOLIO,
			@VP_K_ORDEN_TRABAJO_ORIGEN	=K_ORDEN_TRABAJO
	FROM	INVENTARIO
	INNER JOIN FOLIO ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM 
	AND		K_LOCACION				=@PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				=@PP_LOTE_PEARL
	AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
	AND		K_ENTREGA				=@PP_K_ENTREGA
	AND		K_STATUS_INVENTARIO =	20
	AND		INVENTARIO.L_BORRADO<>1
--=====================================================================================================================================
	--====		SE VERIFICA QUE EXISTA UN FOLIO BASE PARA EL MATERIAL
	--			PRIMERO BUSCAR EN INVENTARIO SI HAY UN K_LOCACION=4 Y TIPO 'B' ASIGNADO AL ITEM
	SET @VP_K_FOLIO= ISNULL(	(SELECT TOP(1)	--*,
										INVENTARIO.K_FOLIO
								FROM	INVENTARIO
								INNER JOIN FOLIO	ON	INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
								WHERE	K_ITEM		=@PP_K_ITEM
								AND		K_LOCACION	=4		--	4=MHI	/		107= RW0
								AND		TIPO		='B'
								AND		INVENTARIO.L_BORRADO<>1
								ORDER BY K_FOLIO DESC),0)

		IF @VP_K_FOLIO=0
		BEGIN
			--============================================================================
			--	REALIZA EL INSERT PARA OBTENER EL FOLIO ASIGNADO AL INGRESAR A INVENTARIO.
			DECLARE @VP_F_DATE_FOLIO	DATE = GETDATE()
			EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											-- ===========================
											--@PP_K_ITEM,		
											4,	--@PP_K_LOCACION,	[A4GLIdentity]=4 (MHI)		DE: {[DATA_02].[dbo].[IMLOCFIL_SQL]}
											0,	--@PP_K_ORDEN_TRABAJO,	DEFAULT=0
											'B',--@PP_TIPO, 
											-- =========================
											@VP_F_DATE_FOLIO,--@PP_F_DATE_FOLIO,
											-- ==========================
											--@PP_CANTIDAD_RECIBIDA,
											@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT
		END	

--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	CANTIDAD_RECIBIDA
									FROM	INVENTARIO
									WHERE	K_ITEM					=@PP_K_ITEM
									AND		LOTE_PEARL				=@PP_LOTE_PEARL
									AND		K_ENTREGA				=@PP_K_ENTREGA
									AND		SERIE_NO				=@PP_SERIE_NO
									AND		K_INVENTARIO			=@PP_K_INVENTARIO
									AND		K_STATUS_INVENTARIO		=20
									AND		INVENTARIO.L_BORRADO<>1					)
											
			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
				
			
			IF @PP_CANTIDAD_MOVIMIENTO > 0
				BEGIN
					IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
							BEGIN
							SET @VP_MENSAJE='La cantidad movimiento no pude mayor a la cantidad disponible. ['+CONVERT(VARCHAR(10),@PP_SERIE_NO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
							END
						ELSE
							BEGIN
								SET @VP_QTY_MOVIMIENTO = @PP_CANTIDAD_MOVIMIENTO
							END
				END
--=====================================================================================================================================
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
													,@PP_K_ITEM						,@PP_LOTE_PEARL
													,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
													,@VP_K_ORDEN_TRABAJO_ORIGEN
													,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
													,@VP_K_ORDEN_TRABAJO_DESTINO
													,@VP_QTY_MOVIMIENTO	
													,@PP_K_TIPO_MOVIMIENTO

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													-- ===========================
													,@PP_K_INVENTARIO				,@PP_K_ITEM						
													,@PP_K_TIPO_MOVIMIENTO			,@PP_LOTE_PEARL
													,@PP_SERIE_NO
													-- ============================	
													,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
													,@VP_K_ORDEN_TRABAJO_ORIGEN
													-- ============================	
													,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
													,@VP_K_ORDEN_TRABAJO_DESTINO
													-- ============================	
													,@VP_QTY_MOVIMIENTO
--=====================================================================================================================================
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@VP_K_FOLIO
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_STATUS_INVENTARIO =	20	
		AND		INVENTARIO.L_BORRADO<>1

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El Folio no puede ser actualizado...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
--=====================================================================================================================================
		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION
									WHERE	K_ITEM		=@PP_K_ITEM	
									AND		K_LOCACION	=@PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL	=@PP_LOTE_PEARL			)
		
		--==========================================================================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==========================================================================================				
		IF @VP_EXISTE_LOCACION=0
		BEGIN
			--============================================================================
			--======================================INSERTAR EL INVENTARIO_LOCACION
			--============================================================================
			EXECUTE	[dbo].[PG_IN_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
		END
		ELSE
		BEGIN
			EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
														,'SUMAR'
		END

		--== SE ACTUALIZA LA LOCACIÓN ORIGEN
		EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,@PP_K_LOCACION_ORIGEN		,@PP_K_ITEM
													,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
													,'RESTAR'
--=====================================================================================================================================
--=====================================================================================================================================	
-- /////////////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	PARA MOVER MATERIAL DESDE MHI A CUALQUIER LOCACIÓN QUE NO SEA MHI
-- //	
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_MHI_A_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MHI_A_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MHI_A_LOCACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],				--	LOCACION #4		MHI
	@PP_K_LOCACION_DESTINO			[INT],				--	LOCACION DIFERENTE A	#6		MQU
	@PP_K_INVENTARIO				[INT],
	@PP_SERIE_NO					[VARCHAR](50),
	@PP_K_TIPO_MOVIMIENTO			[INT],
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4)		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_K_FOLIO				INT
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)
			,@VP_K_FOLIO_ORIGEN			INT
			,@VP_K_ORDEN_TRABAJO_ORIGEN	INT
			,@VP_K_FOLIO_TIPO			VARCHAR(5)
--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	@VP_K_FOLIO_ORIGEN			=INVENTARIO.K_FOLIO
			,@VP_K_ORDEN_TRABAJO_ORIGEN	=K_ORDEN_TRABAJO
			,@VP_K_FOLIO_TIPO			=TIPO
	FROM	INVENTARIO
	INNER JOIN FOLIO ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM 
	AND		K_LOCACION				=@PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				=@PP_LOTE_PEARL
	AND		K_ENTREGA				=@PP_K_ENTREGA				
	AND		K_STATUS_INVENTARIO		=20
	AND		K_INVENTARIO			=@PP_K_INVENTARIO
	AND		SERIE_NO				=@PP_SERIE_NO
	AND		INVENTARIO.L_BORRADO<>1

	IF @VP_K_FOLIO_ORIGEN IS NULL
	BEGIN
		SET @VP_MENSAJE='Folio Origen no encontrado...Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
--=====================================================================================================================================
	--	SE VERIFICA LA LOCACIÓN ORIGEN DEL MATERIAL, SI SE ENCUENTRA EN MHI DE TIPO A, SÓLO SE HACE UN CAMBIO DE LOCACIÓN.

	IF @VP_K_FOLIO_TIPO = 'A'
	BEGIN
		SET @VP_K_FOLIO	=	@VP_K_FOLIO_ORIGEN
	END
	ELSE
	BEGIN
		--====		SE CREA EL FOLIO PARA EL MATERIAL
		DECLARE @VP_F_DATE_FOLIO	DATE = GETDATE()
		EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										-- ===========================
										--@PP_K_ITEM,		
										@PP_K_LOCACION_DESTINO,	--@PP_K_LOCACION,	[A4GLIdentity]=4 (MHI)/107(RW0)/6(MQU)		DE: {[DATA_02].[dbo].[IMLOCFIL_SQL]}
										0,	--@PP_K_ORDEN_TRABAJO,	DEFAULT=0
										'A',--@PP_TIPO, 
										-- =========================
										@VP_F_DATE_FOLIO,
										-- ==========================
										--@PP_CANTIDAD_RECIBIDA,
										@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT
	END
--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS, ES LA CANTIDAD DISPONIBLE DEL MATERIAL EN LA TABLA DE INVENTARIO.
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	CANTIDAD_RECIBIDA
									FROM	INVENTARIO
									WHERE	K_ITEM					=@PP_K_ITEM
									AND		LOTE_PEARL				=@PP_LOTE_PEARL
									AND		K_ENTREGA				=@PP_K_ENTREGA
									AND		SERIE_NO				=@PP_SERIE_NO
									AND		K_INVENTARIO			=@PP_K_INVENTARIO
									AND		K_STATUS_INVENTARIO		=20
									AND		INVENTARIO.L_BORRADO<>1					)
											
			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
				
			
			IF @PP_CANTIDAD_MOVIMIENTO > 0
				BEGIN
					IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
							BEGIN
							SET @VP_MENSAJE='La cantidad movimiento no pude mayor a la cantidad disponible. ['+CONVERT(VARCHAR(10),@PP_SERIE_NO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
							END
						ELSE
							BEGIN
								SET @VP_QTY_MOVIMIENTO = @PP_CANTIDAD_MOVIMIENTO
							END
				END
--=====================================================================================================================================
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
												,@VP_K_ORDEN_TRABAJO_ORIGEN
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												,@VP_QTY_MOVIMIENTO	
												,@PP_K_TIPO_MOVIMIENTO

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													-- ===========================
													,@PP_K_INVENTARIO				,@PP_K_ITEM						
													,@PP_K_TIPO_MOVIMIENTO			,@PP_LOTE_PEARL
													,@PP_SERIE_NO
													-- ============================	
													,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
													,@VP_K_ORDEN_TRABAJO_ORIGEN
													-- ============================	
													,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
													,@VP_K_ORDEN_TRABAJO_DESTINO
													-- ============================	
													,@VP_QTY_MOVIMIENTO
--=====================================================================================================================================
	IF @VP_K_FOLIO_TIPO = 'A'
	BEGIN
		UPDATE	INVENTARIO
		SET		
				K_USUARIO_CAMBIO	=@PP_K_USUARIO_ACCION
				,F_CAMBIO			=GETDATE()
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_INVENTARIO			=@PP_K_INVENTARIO
		AND		SERIE_NO				=@PP_SERIE_NO
		AND		K_STATUS_INVENTARIO =	20	
		AND		INVENTARIO.L_BORRADO<>1

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se pudó actualizar la fecha de cambio...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

	END
	ELSE
	BEGIN
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@VP_K_FOLIO
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_INVENTARIO			=@PP_K_INVENTARIO
		AND		SERIE_NO				=@PP_SERIE_NO
		AND		K_STATUS_INVENTARIO =	20	
		AND		INVENTARIO.L_BORRADO<>1

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El Folio no puede ser actualizado [IV]...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
	END
--=====================================================================================================================================		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION
									WHERE	K_ITEM		=@PP_K_ITEM	
									AND		K_LOCACION	=@PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL	=@PP_LOTE_PEARL			)
		
		--==========================================================================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==========================================================================================				
		IF @VP_EXISTE_LOCACION=0
		BEGIN
			--============================================================================
			--======================================INSERTAR EL INVENTARIO_LOCACION
			--============================================================================
			EXECUTE	[dbo].[PG_IN_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
		END
		ELSE
		BEGIN
			EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
														,'SUMAR'
		END

		--== SE ACTUALIZA LA LOCACIÓN ORIGEN
		EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,@PP_K_LOCACION_ORIGEN		,@PP_K_ITEM
													,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
													,'RESTAR'
--=====================================================================================================================================
	-- SE ACTUALIZA LA LOCACIÓN DEL FOLIO DE TIPO A CON LA NUEVA LOCACIÓN ASIGNADA
	IF @VP_K_FOLIO_TIPO = 'A'
	BEGIN
		UPDATE	FOLIO
		SET
				K_LOCACION	=	@PP_K_LOCACION_DESTINO
		WHERE	K_FOLIO		=	@VP_K_FOLIO
		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El Folio no puede ser actualizado [FO]...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
	END
--=====================================================================================================================================	
-- /////////////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	PARA MOVER MATERIAL DESDE LOCACIÓN A LOCACIÓN 
-- //	QUE NO SEA MHI O MQU
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],				--	LOCACION DIFERENTE A	MHI O MQU
	@PP_K_LOCACION_DESTINO			[INT],				--	LOCACION DIFERENTE A	MQU O MHI
	@PP_K_INVENTARIO				[INT],
	@PP_SERIE_NO					[VARCHAR](50),
	@PP_K_TIPO_MOVIMIENTO			[INT],
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4)		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.
--	,@PP_K_FOLIO_INSERTADO			[INT]			OUTPUT
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_K_FOLIO				INT
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)
			,@VP_K_FOLIO_ORIGEN			INT
			,@VP_K_ORDEN_TRABAJO_ORIGEN	INT
--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	@VP_K_FOLIO_ORIGEN			=INVENTARIO.K_FOLIO
			,@VP_K_ORDEN_TRABAJO_ORIGEN	=K_ORDEN_TRABAJO
	FROM	INVENTARIO
	INNER JOIN FOLIO ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM 
	AND		K_LOCACION				=@PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				=@PP_LOTE_PEARL
	AND		K_ENTREGA				=@PP_K_ENTREGA				
	AND		K_STATUS_INVENTARIO		=20
	AND		K_INVENTARIO			=@PP_K_INVENTARIO
	AND		SERIE_NO				=@PP_SERIE_NO
	AND		INVENTARIO.L_BORRADO<>1

	IF @VP_K_FOLIO_ORIGEN IS NULL
	BEGIN
		SET @VP_MENSAJE='Folio Origen no encontrado...Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
--=====================================================================================================================================
		--====		SE CREA EL FOLIO PARA EL MATERIAL
		DECLARE @VP_F_DATE_FOLIO	DATE = GETDATE()
		EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										-- ===========================
										--@PP_K_ITEM,		
										@PP_K_LOCACION_DESTINO,	--@PP_K_LOCACION,	[A4GLIdentity]=4 (MHI)/107(RW0)/6(MQU)		DE: {[DATA_02].[dbo].[IMLOCFIL_SQL]}
										0,	--@PP_K_ORDEN_TRABAJO,	DEFAULT=0
										'A',--@PP_TIPO, 
										-- =========================
										@VP_F_DATE_FOLIO,
										-- ==========================
										--@PP_CANTIDAD_RECIBIDA,
										@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT
	
--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS, ES LA CANTIDAD DISPONIBLE DEL MATERIAL EN LA TABLA DE INVENTARIO.
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	CANTIDAD_RECIBIDA
									FROM	INVENTARIO
									WHERE	K_ITEM					=@PP_K_ITEM
									AND		LOTE_PEARL				=@PP_LOTE_PEARL
									AND		K_ENTREGA				=@PP_K_ENTREGA
									AND		SERIE_NO				=@PP_SERIE_NO
									AND		K_INVENTARIO			=@PP_K_INVENTARIO
									AND		K_STATUS_INVENTARIO		=20
									AND		INVENTARIO.L_BORRADO<>1					)
											
			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
				
			
			IF @PP_CANTIDAD_MOVIMIENTO > 0
				BEGIN
					IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
							BEGIN
							SET @VP_MENSAJE='La cantidad movimiento no pude ser mayor a la cantidad disponible. ['+CONVERT(VARCHAR(10),@PP_SERIE_NO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
							END
						ELSE
							BEGIN
								SET @VP_QTY_MOVIMIENTO = @PP_CANTIDAD_MOVIMIENTO
							END
				END
--=====================================================================================================================================
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
												,@VP_K_ORDEN_TRABAJO_ORIGEN
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												,@VP_QTY_MOVIMIENTO	
												,@PP_K_TIPO_MOVIMIENTO

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													-- ===========================
													,@PP_K_INVENTARIO				,@PP_K_ITEM						
													,@PP_K_TIPO_MOVIMIENTO			,@PP_LOTE_PEARL
													,@PP_SERIE_NO
													-- ============================	
													,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
													,@VP_K_ORDEN_TRABAJO_ORIGEN
													-- ============================	
													,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
													,@VP_K_ORDEN_TRABAJO_DESTINO
													-- ============================	
													,@VP_QTY_MOVIMIENTO
--=====================================================================================================================================
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@VP_K_FOLIO
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_INVENTARIO			=@PP_K_INVENTARIO
		AND		SERIE_NO				=@PP_SERIE_NO
		AND		K_STATUS_INVENTARIO =	20	
		AND		INVENTARIO.L_BORRADO<>1

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El Folio no puede ser actualizado [IV]...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
--=====================================================================================================================================		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION
									WHERE	K_ITEM		=@PP_K_ITEM	
									AND		K_LOCACION	=@PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL	=@PP_LOTE_PEARL			)
		
		--==========================================================================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==========================================================================================				
		IF @VP_EXISTE_LOCACION=0
		BEGIN
			--============================================================================
			--======================================INSERTAR EL INVENTARIO_LOCACION
			--============================================================================
			EXECUTE	[dbo].[PG_IN_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
		END
		ELSE
		BEGIN
			EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
														,'SUMAR'
		END

		--== SE ACTUALIZA LA LOCACIÓN ORIGEN
		EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,@PP_K_LOCACION_ORIGEN		,@PP_K_ITEM
													,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
													,'RESTAR'
--=====================================================================================================================================
--=====================================================================================================================================	
-- /////////////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	PARA MOVER MATERIAL A FOLIO EXISTENTE
-- //	
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_FOLIO_EXISTENTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_FOLIO_EXISTENTE]
GO

CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_FOLIO_EXISTENTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],
	@PP_K_LOCACION_DESTINO			[INT],
	@PP_K_INVENTARIO				[INT],
	@PP_SERIE_NO					[VARCHAR](50),
	@PP_K_TIPO_MOVIMIENTO			[INT],
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4)		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_K_FOLIO				INT
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)
			,@VP_K_FOLIO_ORIGEN			INT
			,@VP_K_ORDEN_TRABAJO_ORIGEN	INT
--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	@VP_K_FOLIO_ORIGEN			=INVENTARIO.K_FOLIO
			,@VP_K_ORDEN_TRABAJO_ORIGEN	=K_ORDEN_TRABAJO
	FROM	INVENTARIO
	INNER JOIN FOLIO ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM 
	AND		K_LOCACION				=@PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				=@PP_LOTE_PEARL
	AND		K_ENTREGA				=@PP_K_ENTREGA				
	AND		K_STATUS_INVENTARIO		=20
	AND		K_INVENTARIO			=@PP_K_INVENTARIO
	AND		SERIE_NO				=@PP_SERIE_NO
	AND		INVENTARIO.L_BORRADO<>1

	IF @VP_K_FOLIO_ORIGEN IS NULL
	BEGIN
		SET @VP_MENSAJE='Folio Origen no encontrado...Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
--=====================================================================================================================================
		--====		SE CREA EL FOLIO PARA EL MATERIAL
		DECLARE @VP_F_DATE_FOLIO	DATE = GETDATE()
		EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										-- ===========================
										--@PP_K_ITEM,		
										@PP_K_LOCACION_DESTINO,	--@PP_K_LOCACION,	[A4GLIdentity]=4 (MHI)/107(RW0)/6(MQU)		DE: {[DATA_02].[dbo].[IMLOCFIL_SQL]}
										0,	--@PP_K_ORDEN_TRABAJO,	DEFAULT=0
										'A',--@PP_TIPO, 
										-- =========================
										@VP_F_DATE_FOLIO,
										-- ==========================
										--@PP_CANTIDAD_RECIBIDA,
										@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT
	
--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS, ES LA CANTIDAD DISPONIBLE DEL MATERIAL EN LA TABLA DE INVENTARIO.
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	CANTIDAD_RECIBIDA
									FROM	INVENTARIO
									WHERE	K_ITEM					=@PP_K_ITEM
									AND		LOTE_PEARL				=@PP_LOTE_PEARL
									AND		K_ENTREGA				=@PP_K_ENTREGA
									AND		SERIE_NO				=@PP_SERIE_NO
									AND		K_INVENTARIO			=@PP_K_INVENTARIO
									AND		K_STATUS_INVENTARIO		=20
									AND		INVENTARIO.L_BORRADO<>1					)
											
			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
				
			
			IF @PP_CANTIDAD_MOVIMIENTO > 0
				BEGIN
					IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
							BEGIN
							SET @VP_MENSAJE='La cantidad movimiento no pude mayor a la cantidad disponible. ['+CONVERT(VARCHAR(10),@PP_SERIE_NO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
							END
						ELSE
							BEGIN
								SET @VP_QTY_MOVIMIENTO = @PP_CANTIDAD_MOVIMIENTO
							END
				END
--=====================================================================================================================================
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
												,@VP_K_ORDEN_TRABAJO_ORIGEN
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												,@VP_QTY_MOVIMIENTO	
												,@PP_K_TIPO_MOVIMIENTO

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													-- ===========================
													,@PP_K_INVENTARIO				,@PP_K_ITEM						
													,@PP_K_TIPO_MOVIMIENTO			,@PP_LOTE_PEARL
													,@PP_SERIE_NO
													-- ============================	
													,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
													,@VP_K_ORDEN_TRABAJO_ORIGEN
													-- ============================	
													,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
													,@VP_K_ORDEN_TRABAJO_DESTINO
													-- ============================	
													,@VP_QTY_MOVIMIENTO
--=====================================================================================================================================
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@VP_K_FOLIO
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_INVENTARIO			=@PP_K_INVENTARIO
		AND		SERIE_NO				=@PP_SERIE_NO
		AND		K_STATUS_INVENTARIO =	20	
		AND		INVENTARIO.L_BORRADO<>1

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El Folio no puede ser actualizado [IV]...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
--=====================================================================================================================================		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION
									WHERE	K_ITEM		=@PP_K_ITEM	
									AND		K_LOCACION	=@PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL	=@PP_LOTE_PEARL			)
		
		--==========================================================================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==========================================================================================				
		IF @VP_EXISTE_LOCACION=0
		BEGIN
			--============================================================================
			--======================================INSERTAR EL INVENTARIO_LOCACION
			--============================================================================
			EXECUTE	[dbo].[PG_IN_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
		END
		ELSE
		BEGIN
			EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
														,'SUMAR'
		END

		--== SE ACTUALIZA LA LOCACIÓN ORIGEN
		EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,@PP_K_LOCACION_ORIGEN		,@PP_K_ITEM
													,@PP_LOTE_PEARL				,@VP_QTY_MOVIMIENTO
													,'RESTAR'
--=====================================================================================================================================
--=====================================================================================================================================	
-- /////////////////////////////////////////////////////////////////////
GO

-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
--	EL CÓDIGO DE AQUÍ HACIA ABAJO SE EN CONTRABA EN EL CURSOR

			--		@PP_TIPO_ACCION_FRONT = 2		PARA MOVER DE MHI-B/A	A MQU
			ELSE IF @PP_TIPO_ACCION_FRONT = 2
			BEGIN
				IF @PP_K_LC_ORI=4 AND @PP_K_LC_DES=6
				BEGIN
					EXECUTE [PG_PR_MOVIMIENTO_MHI_A_MQU]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV
				END
				ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[MHI-MQU]'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END
			
			--		@PP_TIPO_ACCION_FRONT = 3		PARA MOVER DE MQU		A	MHI	-	FOLIO BASE 
			ELSE IF @PP_TIPO_ACCION_FRONT = 3
			BEGIN
				IF @PP_K_LC_ORI=6 AND @PP_K_LC_DES = 4
				BEGIN
					EXECUTE [PG_PR_MOVIMIENTO_MQU_A_MHI]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV
				END
				ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[MQU-MHI]'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END

			-- =================================================================================================================================================================
			-- ===========
			-- ===========		ACCIONES DESDE LA PANTALLA DE INVENTARIO
			-- ===========
			-- =================================================================================================================================================================
			
			--		@PP_TIPO_ACCION_FRONT = 4		PARA MOVER DE MHI-B/A	A	LOCACIÓN DIFERENTE A MQU

			--		PAR MOVER MATERIAL A UN NUEVO FOLIO, SÓLO SE ACEPTA CUANDO EL ORIGEN ES MHI

			ELSE IF @PP_TIPO_ACCION_FRONT = 4
			BEGIN
				IF @PP_K_LC_ORI=4 AND @PP_K_LC_DES NOT IN (6)		--(4,6)
				BEGIN
					EXECUTE [PG_PR_MOVIMIENTO_MHI_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV
				END
				ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[MHIA-LOC]'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END
			



			--		@PP_TIPO_ACCION_FRONT = 5		PARA MOVER DE LOCACIÓN A LOCACIÓN DIFERENTE A MHI-MQU
			ELSE IF @PP_TIPO_ACCION_FRONT = 5
			BEGIN
				IF @PP_K_LC_ORI NOT IN (4,6) AND @PP_K_LC_DES NOT IN (4,6)
				BEGIN
					EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV
															--	,@PP_K_FOLIO_INSERTADO	=	@VP_K_FOLIO_INSERTADO	OUTPUT
				END
				ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[LOC-LOC]'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END
			--		@PP_TIPO_ACCION_FRONT = 6		PARA MOVER DE LOCACIÓN A MFP  (ACCION DEL BOTON SCRAP)
			ELSE IF @PP_TIPO_ACCION_FRONT = 6
			BEGIN
				
				IF @PP_K_LC_ORI IN(				
										SELECT	A4GLIDENTITY	--	,LOC
										FROM	IMLOCFIL_SQL
										WHERE	( LOC NOT LIKE 'G%' AND LOC NOT LIKE 'T%' AND LOC NOT LIKE 'MFP')		)			
				BEGIN
					EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,90		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV
															--	,@PP_K_FOLIO_INSERTADO	=	@VP_K_FOLIO_INSERTADO	OUTPUT
					
					--IF @VP_K_FOLIO_INSERTADO=''
					--BEGIN
					--	SET @VP_K_FOLIO_INSERTADO=@VP_K_FOLIO_INSERTADO
					--END
					--ELSE
					--BEGIN
					--	SET @VP_K_FOLIO_INSERTADO=	',' + @VP_K_FOLIO_INSERTADO
					--END
				END
				ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[SCRAP]'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END