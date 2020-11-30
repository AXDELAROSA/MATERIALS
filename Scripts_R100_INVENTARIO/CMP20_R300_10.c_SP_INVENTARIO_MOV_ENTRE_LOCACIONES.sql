-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20200926
-- ////////////////////////////////////////////////////////////// 

 --USE [DATA_02]
USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // 
-- // 
-- // 
-- //	STORED PROCEDURE ---> PROCESO PARA EL MOVIMIENTO ENTRE LOCACIONES
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	ESTE SP SE EJECUTA CUANDO SE GENERA UN NUEVO FOLIO TIPO 'A' PARA LA LOCACIÓN MHI, ES PARA APARTAR MATERIAL A UN NUEVO FOLIO
-- //	ANTES DE ASIGNAR A NUEVA LOCACIÓN.
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_MHIB_A_MHIA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MHIB_A_MHIA]
GO
--		 EXECUTE [dbo].[PG_PR_MOVIMIENTO_MHIB_A_MHIA]	0,139, '00296-00001',1,82,201000001,104,4,1
CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_MHIB_A_MHIA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],				--	LOCACION #4		MHI	TIPO B
	@PP_K_LOCACION_DESTINO			[INT],				--	LOCACION #4		MHI TIPO A
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
	-- =============================================================================
	--	SE GENERA UN NUEVO FOLIO PARA EL MATERIAL. COMO SERÁ DE TIPO MHI SE ASIGNA DE TIPO A
	DECLARE @VP_F_DATE_FOLIO	DATE = GETDATE()
	EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
									-- ===========================
									--@PP_K_ITEM,		
									@PP_K_LOCACION_DESTINO,
									0,	
									'A',--@PP_TIPO, 
									-- =========================
									@VP_F_DATE_FOLIO,
									-- ==========================
									@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO	OUTPUT
	
	--UPDATE	INVENTARIO
	--SET		
	--		K_FOLIO=@VP_K_FOLIO	
	--WHERE	K_ITEM					=@PP_K_ITEM
	--AND		LOTE_PEARL				=@PP_LOTE_PEARL
	--AND		K_ENTREGA				=@PP_K_ENTREGA
	--AND		K_STATUS_INVENTARIO		=20
	--AND		K_INVENTARIO			=@PP_K_INVENTARIO
	--AND		SERIE_NO				=@PP_SERIE_NO
	--AND		INVENTARIO.L_BORRADO<>1

	--IF @@ROWCOUNT = 0
	--BEGIN
	--	SET @VP_MENSAJE='El Folio no puede ser actualizado...Verificar'
	--	RAISERROR (@VP_MENSAJE, 16, 1 )
	--END		
	
--=====================================================================================================================================
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
	AND		K_STATUS_INVENTARIO		=20
	AND		K_INVENTARIO			=@PP_K_INVENTARIO
	AND		SERIE_NO				=@PP_SERIE_NO
	AND		INVENTARIO.L_BORRADO<>1

	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='El Folio no puede ser actualizado...Verificar'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END		
--=====================================================================================================================================		
-- /////////////////////////////////////////////////////////////////////
GO


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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTOS_LOCACIONES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTOS_LOCACIONES]
GO
--	PRUEBAS2
--		 EXECUTE [dbo].[PG_PR_MOVIMIENTOS_LOCACIONES]	0,139, 1,70 ,4,4, '00320-00001',1,201000001,1,'121534151',100		-- MHIB - MHIA		


--	EXECUTE [dbo].[PG_PR_MOVIMIENTOS_LOCACIONES] 1,139,  '1' , '70' , '4' , '4' , '00320-00001/00320-00001/00320-00001' , '1/1/1' , '201000001/201000001/201000001' , '3/2/1' , '45451534/124165151/121534151' , '100.00/100.00/100.00' 



CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTOS_LOCACIONES]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_ACCION_FRONT		INT,
	@PP_K_ITEM					INT,
	@PP_K_LC_ORI				INT,
	@PP_K_LC_DES				INT,

	@PP_ARRAY_K_ORDE			[NVARCHAR](MAX), -- [VARCHAR](50),
	@PP_ARRAY_K_ENTR			[NVARCHAR](MAX), -- [INT],
-----------------------------	@PP_ARRAY_K_ITEM			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_LOTE_P			[NVARCHAR](MAX), -- [INT],
-----------------------------	@PP_ARRAY_LC_ORI			[NVARCHAR](MAX), -- [INT],
-----------------------------	@PP_ARRAY_LC_DES			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_K_INVE			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_SERIEN			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_QTY_MV			[NVARCHAR](MAX) -- [DECIMAL](19,4)
AS			
DECLARE @VP_MENSAJE				VARCHAR(500) = ''
		,@VP_POS_K_ORDE			INT		
		,@VP_POS_K_ENTR			INT
		,@VP_POS_K_ITEM			INT
		,@VP_POS_LOTE_P			INT
		,@VP_POS_LC_ORI			INT
		,@VP_POS_LC_DES			INT
		,@VP_POS_K_INVE			INT
		,@VP_POS_SERIEN			INT
		,@VP_POS_QTY_MV			INT
		,@VP_VAL_K_ORDE			VARCHAR(500)
		,@VP_VAL_K_ENTR			VARCHAR(500)
-----------------------------		,@VP_VAL_K_ITEM			VARCHAR(500)
		,@VP_VAL_LOTE_P			VARCHAR(500)
-----------------------------		,@VP_VAL_LC_ORI			VARCHAR(500)
-----------------------------		,@VP_VAL_LC_DES			VARCHAR(500)
		,@VP_VAL_K_INVE			VARCHAR(500)
		,@VP_VAL_SERIEN			VARCHAR(500)
		,@VP_VAL_QTY_MV			VARCHAR(500)
		
		,@VP_K_FOLIO_INSERTADO	NVARCHAR(MAX)
BEGIN TRANSACTION 
BEGIN TRY
	--	K_		D_INVENTARIO_MOVIMIENTO_TIPO	S_INV
	--	5		REGISTRO EN SISTEMA				REGSIS		NO APLICA EN EL MOVIMIENTO DEL FRONT, SE HACE EN INSPECCIÓN
	--	10		ENTRADA X LIBERACIÓN			ENXLIB		NO APLICA EN EL MOVIMIENTO DEL FRONT, SE HACE EN INSPECCIÓN
	--	20		TRANSFERENCIA A LOCACIÓN		TRXLOC		
	--	30		FOLIO NUEVO						FOLNEW
	--	40		TRANSFERENCIA A ORDEN			TRXORD
	--	50		TRANSFERENCIA A FOLIO			TRXFOL
	--	60		DEVOLUCIÓN						DVOLUC
	--	70		ISSUE OUT						ISSOUT
	--	80		REIMPRESIÓN						REIMPR
	--	90		FOLIO SCRAP						FOLSCR
	
	
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_K_ORDE			= @PP_ARRAY_K_ORDE	+ '/'
	SET	@PP_ARRAY_K_ENTR			= @PP_ARRAY_K_ENTR	+ '/'	
-----------------------------	SET	@PP_ARRAY_K_ITEM			= @PP_ARRAY_K_ITEM	+ '/'
	SET	@PP_ARRAY_LOTE_P			= @PP_ARRAY_LOTE_P	+ '/'
-----------------------------	SET	@PP_ARRAY_LC_ORI			= @PP_ARRAY_LC_ORI	+ '/'
-----------------------------	SET	@PP_ARRAY_LC_DES			= @PP_ARRAY_LC_DES	+ '/'
	SET	@PP_ARRAY_K_INVE			= @PP_ARRAY_K_INVE	+ '/'
	SET	@PP_ARRAY_SERIEN			= @PP_ARRAY_SERIEN	+ '/'
	SET	@PP_ARRAY_QTY_MV			= @PP_ARRAY_QTY_MV	+ '/'

	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_K_ORDE) <> 0
		BEGIN
			SELECT @VP_POS_K_ORDE	=	patindex('%/%' , @PP_ARRAY_K_ORDE		)
			SELECT @VP_POS_K_ENTR	=	patindex('%/%' , @PP_ARRAY_K_ENTR		)
-----------------------------			SELECT @VP_POS_K_ITEM	=	patindex('%/%' , @PP_ARRAY_K_ITEM		)
			SELECT @VP_POS_LOTE_P	=	patindex('%/%' , @PP_ARRAY_LOTE_P		)
-----------------------------			SELECT @VP_POS_LC_ORI	=	patindex('%/%' , @PP_ARRAY_LC_ORI		)
-----------------------------			SELECT @VP_POS_LC_DES	=	patindex('%/%' , @PP_ARRAY_LC_DES		)
			SELECT @VP_POS_K_INVE	=	patindex('%/%' , @PP_ARRAY_K_INVE		)
			SELECT @VP_POS_SERIEN	=	patindex('%/%' , @PP_ARRAY_SERIEN		)
			SELECT @VP_POS_QTY_MV	=	patindex('%/%' , @PP_ARRAY_QTY_MV		)

			--Buscamos la posicion del primer registro y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VAL_K_ORDE		= LEFT(@PP_ARRAY_K_ORDE		, @VP_POS_K_ORDE		- 1)
			SELECT @VP_VAL_K_ENTR		= LEFT(@PP_ARRAY_K_ENTR		, @VP_POS_K_ENTR		- 1)
-----------------------------			SELECT @VP_VAL_K_ITEM		= LEFT(@PP_ARRAY_K_ITEM		, @VP_POS_K_ITEM		- 1)
			SELECT @VP_VAL_LOTE_P		= LEFT(@PP_ARRAY_LOTE_P		, @VP_POS_LOTE_P		- 1)
-----------------------------			SELECT @VP_VAL_LC_ORI		= LEFT(@PP_ARRAY_LC_ORI		, @VP_POS_LC_ORI		- 1)
-----------------------------			SELECT @VP_VAL_LC_DES		= LEFT(@PP_ARRAY_LC_DES		, @VP_POS_LC_DES		- 1)
			SELECT @VP_VAL_K_INVE		= LEFT(@PP_ARRAY_K_INVE		, @VP_POS_K_INVE		- 1)
			SELECT @VP_VAL_SERIEN		= LEFT(@PP_ARRAY_SERIEN		, @VP_POS_SERIEN		- 1)
			SELECT @VP_VAL_QTY_MV		= LEFT(@PP_ARRAY_QTY_MV		, @VP_POS_QTY_MV		- 1)

			-- ============================================================================================================
			--	SE VERIFICA EL @PP_TIPO_MOVIMIENTO AL QUE PERTENECE LA ACCIÓN DEL BOTÓN  DEL FRONT.

			--		SE MANDA LLAMAR CON EL RB_NUEVO_FOLIO

			--	@PP_TIPO_ACCION_FRONT = 1		PARA MOVER DE MHI-B		A MHI-A, MOVIMIENTO ENTRE LA MISMA LOCACIÓN
			IF  @PP_TIPO_ACCION_FRONT = 1
			BEGIN
				IF @PP_K_LC_ORI=4 AND @PP_K_LC_DES=4
				BEGIN
					EXECUTE [PG_PR_MOVIMIENTO_MHIB_A_MHIA]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,30		--FOLIO NUEVO	/	FOLNEW		-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV
				END
				ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[A-B]'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END
			
			--		SE MANDA LLAMAR CON EL RB_FOLIO_EXISTENTE

			--	@PP_TIPO_ACCION_FRONT = 2		PARA MOVER MATERIAL A UN FOLIO EXISTENTE
			IF  @PP_TIPO_ACCION_FRONT = 2
			BEGIN
				DECLARE @VP_LOCACION_DESTINO_DE_FOLIO	INT
						,@VP_FOLIO_CON_REGISTROS		INT
				SELECT	@VP_LOCACION_DESTINO_DE_FOLIO=K_LOCACION
				FROM	FOLIO
				WHERE	K_FOLIO=@PP_K_LC_DES

				IF @VP_LOCACION_DESTINO_DE_FOLIO=0 OR @VP_LOCACION_DESTINO_DE_FOLIO IS NULL
				BEGIN
					SET @VP_MENSAJE='No se encontró locación para el FOLIO destino.[Fol-LOC]'
					RAISERROR (@VP_MENSAJE, 16, 1 )				
				END

				SELECT	@VP_FOLIO_CON_REGISTROS=COUNT(K_INVENTARIO)	
				FROM	INVENTARIO 
				WHERE	K_FOLIO=@PP_K_LC_DES

				IF @VP_FOLIO_CON_REGISTROS=0 OR @VP_FOLIO_CON_REGISTROS IS NULL
				BEGIN
					SET @VP_MENSAJE='No se encontró material asignado al FOLIO destino.[Fol-INV]'
					RAISERROR (@VP_MENSAJE, 16, 1 )		
				END
			END

--			--		@PP_TIPO_ACCION_FRONT = 2		PARA MOVER DE MHI-B/A	A MQU
--			ELSE IF @PP_TIPO_ACCION_FRONT = 2
--			BEGIN
--				IF @PP_K_LC_ORI=4 AND @PP_K_LC_DES=6
--				BEGIN
--					EXECUTE [PG_PR_MOVIMIENTO_MHI_A_MQU]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
--															-- ======================================================
--															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
--															,@PP_K_ITEM			,@VP_VAL_LOTE_P
--															,@PP_K_LC_ORI		,@PP_K_LC_DES
--															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
--															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
--															,@VP_VAL_QTY_MV
--				END
--				ELSE
--				BEGIN
--					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[MHI-MQU]'
--					RAISERROR (@VP_MENSAJE, 16, 1 )
--				END
--			END
--			
--			--		@PP_TIPO_ACCION_FRONT = 3		PARA MOVER DE MQU		A	MHI	-	FOLIO BASE 
--			ELSE IF @PP_TIPO_ACCION_FRONT = 3
--			BEGIN
--				IF @PP_K_LC_ORI=6 AND @PP_K_LC_DES = 4
--				BEGIN
--					EXECUTE [PG_PR_MOVIMIENTO_MQU_A_MHI]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
--															-- ======================================================
--															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
--															,@PP_K_ITEM			,@VP_VAL_LOTE_P
--															,@PP_K_LC_ORI		,@PP_K_LC_DES
--															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
--															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
--															,@VP_VAL_QTY_MV
--				END
--				ELSE
--				BEGIN
--					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[MQU-MHI]'
--					RAISERROR (@VP_MENSAJE, 16, 1 )
--				END
--			END
--
--			-- =================================================================================================================================================================
--			-- ===========
--			-- ===========		ACCIONES DESDE LA PANTALLA DE INVENTARIO
--			-- ===========
--			-- =================================================================================================================================================================
--			
--			--		@PP_TIPO_ACCION_FRONT = 4		PARA MOVER DE MHI-B/A	A	LOCACIÓN DIFERENTE A MQU
--
--			--		PAR MOVER MATERIAL A UN NUEVO FOLIO, SÓLO SE ACEPTA CUANDO EL ORIGEN ES MHI
--
--			ELSE IF @PP_TIPO_ACCION_FRONT = 4
--			BEGIN
--				IF @PP_K_LC_ORI=4 AND @PP_K_LC_DES NOT IN (6)		--(4,6)
--				BEGIN
--					EXECUTE [PG_PR_MOVIMIENTO_MHI_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
--															-- ======================================================
--															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
--															,@PP_K_ITEM			,@VP_VAL_LOTE_P
--															,@PP_K_LC_ORI		,@PP_K_LC_DES
--															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
--															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
--															,@VP_VAL_QTY_MV
--				END
--				ELSE
--				BEGIN
--					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[MHIA-LOC]'
--					RAISERROR (@VP_MENSAJE, 16, 1 )
--				END
--			END
--			
--
--
--
--			--		@PP_TIPO_ACCION_FRONT = 5		PARA MOVER DE LOCACIÓN A LOCACIÓN DIFERENTE A MHI-MQU
--			ELSE IF @PP_TIPO_ACCION_FRONT = 5
--			BEGIN
--				IF @PP_K_LC_ORI NOT IN (4,6) AND @PP_K_LC_DES NOT IN (4,6)
--				BEGIN
--					EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
--															-- ======================================================
--															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
--															,@PP_K_ITEM			,@VP_VAL_LOTE_P
--															,@PP_K_LC_ORI		,@PP_K_LC_DES
--															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
--															,20		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
--															,@VP_VAL_QTY_MV
--															--	,@PP_K_FOLIO_INSERTADO	=	@VP_K_FOLIO_INSERTADO	OUTPUT
--				END
--				ELSE
--				BEGIN
--					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[LOC-LOC]'
--					RAISERROR (@VP_MENSAJE, 16, 1 )
--				END
--			END
--			--		@PP_TIPO_ACCION_FRONT = 6		PARA MOVER DE LOCACIÓN A MFP  (ACCION DEL BOTON SCRAP)
--			ELSE IF @PP_TIPO_ACCION_FRONT = 6
--			BEGIN
--				
--				IF @PP_K_LC_ORI IN(				
--										SELECT	A4GLIDENTITY	--	,LOC
--										FROM	IMLOCFIL_SQL
--										WHERE	( LOC NOT LIKE 'G%' AND LOC NOT LIKE 'T%' AND LOC NOT LIKE 'MFP')		)			
--				BEGIN
--					EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
--															-- ======================================================
--															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
--															,@PP_K_ITEM			,@VP_VAL_LOTE_P
--															,@PP_K_LC_ORI		,@PP_K_LC_DES
--															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
--															,90		--TRANSFERENCIA A LOCACIÓN	/ TRXLOC	-- MOVIMIENTO_TIPO
--															,@VP_VAL_QTY_MV
--															--	,@PP_K_FOLIO_INSERTADO	=	@VP_K_FOLIO_INSERTADO	OUTPUT
--					
--					--IF @VP_K_FOLIO_INSERTADO=''
--					--BEGIN
--					--	SET @VP_K_FOLIO_INSERTADO=@VP_K_FOLIO_INSERTADO
--					--END
--					--ELSE
--					--BEGIN
--					--	SET @VP_K_FOLIO_INSERTADO=	',' + @VP_K_FOLIO_INSERTADO
--					--END
--				END
--				ELSE
--				BEGIN
--					SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[SCRAP]'
--					RAISERROR (@VP_MENSAJE, 16, 1 )
--				END
--			END


			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_ORDE		= STUFF(@PP_ARRAY_K_ORDE		, 1, @VP_POS_K_ORDE , '')
			SELECT @PP_ARRAY_K_ENTR		= STUFF(@PP_ARRAY_K_ENTR		, 1, @VP_POS_K_ENTR , '')
-----------------------------			SELECT @PP_ARRAY_K_ITEM		= STUFF(@PP_ARRAY_K_ITEM		, 1, @VP_POS_K_ITEM , '')
			SELECT @PP_ARRAY_LOTE_P		= STUFF(@PP_ARRAY_LOTE_P		, 1, @VP_POS_LOTE_P , '')
-----------------------------			SELECT @PP_ARRAY_LC_ORI		= STUFF(@PP_ARRAY_LC_ORI		, 1, @VP_POS_LC_ORI , '')
-----------------------------			SELECT @PP_ARRAY_LC_DES		= STUFF(@PP_ARRAY_LC_DES		, 1, @VP_POS_LC_DES , '')
			SELECT @PP_ARRAY_K_INVE		= STUFF(@PP_ARRAY_K_INVE		, 1, @VP_POS_K_INVE	, '')
			SELECT @PP_ARRAY_SERIEN		= STUFF(@PP_ARRAY_SERIEN		, 1, @VP_POS_SERIEN , '')
			SELECT @PP_ARRAY_QTY_MV		= STUFF(@PP_ARRAY_QTY_MV		, 1, @VP_POS_QTY_MV , '')
		END
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Mover] el registro: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_FOLIO_INSERTADO	 AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO