-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20200926
-- ////////////////////////////////////////////////////////////// 

--	USE [DATA_02]
USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_VALIDACION_LOCACION_ORIGEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_VALIDACION_LOCACION_ORIGEN]
GO
--		 EXECUTE [dbo].[PG_VALIDACION_LOCACION_ORIGEN]	
CREATE PROCEDURE [dbo].[PG_VALIDACION_LOCACION_ORIGEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LC_ORI					INT
AS
DECLARE @VP_MENSAJE						VARCHAR(500) = ''		

	IF @PP_K_LC_ORI NOT IN(	SELECT	A4GLIDENTITY
							FROM	IMLOCFIL_SQL
							WHERE	LOC  IN (	'MHI'	,'MIT'	,'MQU'	,'MRD'	,'MCT'	,'MFP'	)
							UNION
							SELECT	A4GLIDENTITY
							FROM	IMLOCFIL_SQL
							WHERE	LOC NOT LIKE 'T%'	AND LOC NOT LIKE 'G%'	)
	BEGIN
		SET @VP_MENSAJE='Proporcione una Locación origen válida para la transferencia....[B-A]'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_VALIDACION_LOCACION_DESTINO_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_VALIDACION_LOCACION_DESTINO_X_FOLIO]
GO
--		 EXECUTE [dbo].[PG_VALIDACION_LOCACION_DESTINO_X_FOLIO]
CREATE PROCEDURE [dbo].[PG_VALIDACION_LOCACION_DESTINO_X_FOLIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LC_DESTINO				INT
AS
DECLARE @VP_MENSAJE						VARCHAR(500) = ''

	IF @PP_K_LC_DESTINO NOT IN(	SELECT	A4GLIDENTITY
							FROM	IMLOCFIL_SQL
							WHERE	LOC  IN (	'MHI'	,'MIT'	,'MQU'	,'MRD'	,'MCT'	,'MFP'	)
							UNION
							SELECT	A4GLIDENTITY
							FROM	IMLOCFIL_SQL
							WHERE	LOC NOT LIKE 'T%'	AND LOC NOT LIKE 'G%'	)
	BEGIN
		SET @VP_MENSAJE='Proporcione una Locación destino válida para la transferencia....[MTG]'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
GO


-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_VALIDACION_SALIDA_MQU]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_VALIDACION_SALIDA_MQU]
GO
--		 EXECUTE [dbo].[PG_VALIDACION_SALIDA_MQU]
CREATE PROCEDURE [dbo].[PG_VALIDACION_SALIDA_MQU]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT
	-- ===========================
AS
DECLARE @VP_MENSAJE						VARCHAR(500) = ''		,@VP_USUARIO_QC_VALIDO		INT
-- /////////////////////////////////////////////////////
	 SELECT		@VP_USUARIO_QC_VALIDO		=	COUNT(K_GRUPO_APROBADOR)
	 FROM		BD_GENERAL.DBO.[GRUPO_APROBADOR]
	 WHERE		K_USUARIO					= @PP_K_USUARIO_ACCION
	 AND		D_GRUPO_APROBADOR			= 'AUTORIZAR SALIDA MQU'
	 AND		K_ESTATUS_GRUPO_APROBADOR	= 1 -- ACTIVO
	 AND		K_TIPO_GRUPO_APROBADOR		= 21 --  MQU SALIDA
	 
	 IF @VP_USUARIO_QC_VALIDO = NULL OR @VP_USUARIO_QC_VALIDO = 0
	 BEGIN 
		IF  @PP_K_USUARIO_ACCION <> 139
		BEGIN
			SET @VP_MENSAJE='No es posible realizar la transferencia: Usuario NO AUTORIZADO...'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
	 END  
	GO


-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_VALIDACION_EXISTE_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_VALIDACION_EXISTE_ORDEN]
GO
--		 EXECUTE [dbo].[PG_VALIDACION_EXISTE_ORDEN]	0,139,82,25,89086
--		 EXECUTE [dbo].[PG_VALIDACION_EXISTE_ORDEN]	0,139,70,24,89086
--		 EXECUTE [dbo].[PG_VALIDACION_EXISTE_ORDEN]	0,139,67,24,89086

--		 EXECUTE [dbo].[PG_VALIDACION_EXISTE_ORDEN]	0,139,67,25,89086
CREATE PROCEDURE [dbo].[PG_VALIDACION_EXISTE_ORDEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM						INT,
	@PP_K_FOLIO						INT,
	@PP_ORDEN_NO					VARCHAR(10)
AS
DECLARE		@VP_MENSAJE								VARCHAR(500) = ''		
			,@VP_EXISTE_COMBINACION_ITEM_FOLIO		INT
			,@VP_ORDEN_EXISTE_PEARL					INT
			,@VP_ORDEN_EXISTE_INVENTARIO			INT								
			,@VP_TIPO_FOLIO							VARCHAR(10)
			,@VP_ORDEN_FOLIO						INT
			,@VP_FOLIO_EXISTE_EN					INT
BEGIN TRANSACTION 
BEGIN TRY
	-- ///////////////////////////////////////////
	SELECT	@VP_EXISTE_COMBINACION_ITEM_FOLIO = COUNT(K_INVENTARIO) 
	FROM	DATA_02.DBO.INVENTARIO
	WHERE	K_FOLIO		= @PP_K_FOLIO
	AND		K_ITEM		= @PP_K_ITEM
	
	IF @VP_EXISTE_COMBINACION_ITEM_FOLIO =0
	BEGIN
		SET @VP_MENSAJE = 'El FOLIO no se encuentra asignado al ITEM. Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
	-- ///////////////////////////////////////////
	-- NO SE PUEDE TRANSFERIR A UNA ORDEN DIRECTAMENTE DESDE EL FOLIO BASE.
	SELECT	@VP_TIPO_FOLIO		= TIPO
			,@VP_ORDEN_FOLIO	= K_ORDEN_TRABAJO
	FROM	FOLIO
	WHERE	K_FOLIO=	@PP_K_FOLIO

	IF @VP_TIPO_FOLIO = 'B'
	BEGIN
		SET @VP_MENSAJE = 'No se puede transferir desde el Folio Base. Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
	IF @VP_ORDEN_FOLIO = @PP_ORDEN_NO
	BEGIN
		SET @VP_MENSAJE = 'El FOLIO ya se encuentra agregado a la orden destino. Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
		
	-- ///////////////////////////////////////////
	-- SE VERIFICA QUE EXISTA LA ORDEN EN EL SISTEMA PEARL.
	SELECT  @VP_ORDEN_EXISTE_PEARL		= COUNT(jobno)
	FROM	DATA_02.DBO.CCJOBHDR_SQL
	INNER	JOIN DATA_02.DBO.IMLOCFIL_SQL ON CCJOBHDR_SQL.machine = IMLOCFIL_SQL.loc_desc
	WHERE	LTRIM(RTRIM(JOBNO)) = @PP_ORDEN_NO
	
	-- SI EXISTE, SE VERIFICA QUE NO EXISTA AGREGADO A UN FOLIO DE INVENTARIO.
	IF @VP_ORDEN_EXISTE_PEARL <= 0
	BEGIN
		SET @VP_MENSAJE='El número de ORDEN no existe... Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
	IF @PP_K_SISTEMA_EXE = 0
	BEGIN
		SELECT	@VP_ORDEN_EXISTE_INVENTARIO		= COUNT(FOLIO.K_FOLIO)
		FROM	DATA_02.DBO.INVENTARIO
		INNER JOIN DATA_02.DBO.FOLIO		ON  INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
		WHERE	K_ORDEN_TRABAJO	= @PP_ORDEN_NO
		AND		K_ITEM			= @PP_K_ITEM
	END
	ELSE
	BEGIN
		SELECT	@VP_ORDEN_EXISTE_INVENTARIO		= COUNT(FOLIO.K_FOLIO)
		FROM	DATA_02.DBO.INVENTARIO
		INNER JOIN DATA_02.DBO.FOLIO		ON  INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
		WHERE	K_ORDEN_TRABAJO	= @PP_ORDEN_NO
		AND		K_ITEM			= @PP_K_ITEM
	END

	--IF @VP_ORDEN_EXISTE_INVENTARIO >= 2
	--BEGIN
	--	SET @VP_MENSAJE = 'La orden se encuentra asignada a dos o más FOLIO del mismo ITEM. Es necesario notificar a SISTEMAS... Notifique'
	--	RAISERROR (@VP_MENSAJE, 16, 1 )
	--END

	IF @VP_ORDEN_EXISTE_INVENTARIO >= 1
	BEGIN
		SELECT	@VP_FOLIO_EXISTE_EN		= FOLIO.K_FOLIO
		FROM	DATA_02.DBO.INVENTARIO
		INNER JOIN DATA_02.DBO.FOLIO		ON  INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
		WHERE	K_ORDEN_TRABAJO	= @PP_ORDEN_NO
		AND		K_ITEM			= @PP_K_ITEM

		IF @VP_FOLIO_EXISTE_EN IS NULL OR @VP_FOLIO_EXISTE_EN = 0
		BEGIN
			SET @VP_MENSAJE = 'No se obtuvieron resultados de la consulta.'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

		SET @VP_MENSAJE = 'La orden ya tiene un FOLIO asignado. Deseas mover el material seleccionado al folio [ '+ CONVERT(VARCHAR(10),@VP_FOLIO_EXISTE_EN) +' ]'
		SET @PP_K_FOLIO = -1
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	--SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET	@VP_MENSAJE = 'No es posible [Mover] el registro. ' + @VP_ERROR_TRANS
	END
--	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_FOLIO_DESTINO	 AS CLAVE
	SELECT @VP_MENSAJE AS MENSAJE, @PP_K_FOLIO AS CLAVE, @VP_FOLIO_EXISTE_EN	AS FOLIO_DESTINO
	-- //////////////////////////////////////////////////////////////

GO
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
--		 EXECUTE [dbo].[PG_PR_MOVIMIENTO_MHIB_A_MHIA]	
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
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4),		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.
	@PP_K_FOLIO_DESTINO				[INT]
AS
DECLARE @VP_MENSAJE						VARCHAR(500) = ''		,@VP_LOCACION_ORIGEN_BD		INT
		,@VP_QTY_MOVIMIENTO				DECIMAL(19,4)			,@VP_K_FOLIO_ORIGEN			INT
		,@VP_K_ORDEN_TRABAJO_ORIGEN		INT						,@VP_TIPO_FOLIO_ORIGEN		VARCHAR(3)

--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	@VP_K_FOLIO_ORIGEN			= INVENTARIO.K_FOLIO,
			@VP_LOCACION_ORIGEN_BD		= FOLIO.K_LOCACION,
			@VP_K_ORDEN_TRABAJO_ORIGEN	= K_ORDEN_TRABAJO,
			@VP_TIPO_FOLIO_ORIGEN		= TIPO
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

	-- SE VERIFICA QUE EL FOLIO ORIGEN CUENTE CON UN FOLIO ASIGNADO, EN ESTE CASO DEBE SER EL BASE.
	IF @VP_K_FOLIO_ORIGEN IS NULL OR @VP_K_FOLIO_ORIGEN=0
	BEGIN
		SET @VP_MENSAJE='Folio Origen [0] no encontrado...Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
	-- SE VERIFICA NUEVAMENTE LA LOCACIÓN ORIGEN YA QUE EL SISTEMA NO CUENTA CON UN PROCESO DE BLOQUEO DE REGISTROS, Y SE PUEDE DAR EL CASO
	-- QUE DOS USUARIOS REALICEN EL MOVIEMIENTO AL MISMO TIEMPO.
	IF @VP_LOCACION_ORIGEN_BD <> 4
	BEGIN
		SET @VP_MENSAJE='El registro seleccionado #ID_INVENTARIO[' + CONVERT(VARCHAR(10),@PP_K_INVENTARIO) + '] no tiene una locación correcta, Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
	-- SE VERIFICA QUE EL TIPO DEL FOLIO ORIGEN NO SEA IGUAL AL TIPO DESTINO
	IF @VP_TIPO_FOLIO_ORIGEN = 'A'
	BEGIN
		SET @VP_MENSAJE='El registro seleccionado #ID_INVENTARIO[' + CONVERT(VARCHAR(10),@PP_K_INVENTARIO) + '] ya se encuentra en la locación específicada, Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
--=====================================================================================================================================
	---- =============================================================================	
	--UPDATE	INVENTARIO
--=====================================================================================================================================
--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@PP_K_FOLIO_DESTINO
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
											
	IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO<=0
	BEGIN
		SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0. [SERIE#] ' + CONVERT(VARCHAR(10),@PP_SERIE_NO)
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END		
	
	IF @PP_CANTIDAD_MOVIMIENTO > 0
		BEGIN
			IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
					BEGIN
					SET @VP_MENSAJE='La cantidad movimiento no pude ser mayor a la cantidad disponible. [SERIE#] ' + CONVERT(VARCHAR(10),@PP_SERIE_NO)
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
											,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
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
												,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												-- ============================	
												,@VP_QTY_MOVIMIENTO

--=====================================================================================================================================
	UPDATE	INVENTARIO
	SET		
			K_FOLIO=@PP_K_FOLIO_DESTINO	
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
--=====================================================================================================================================		
--=====================================================================================================================================		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		DECLARE @VP_EXISTE_LOCACION		INT
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
--=====================================================================================================================================	
-- /////////////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //	PARA MOVER MATERIAL DE UNA LOCACIÓN A OTRA, CUANDO ES MOVIMIENTO POR REGISTRO.
-- //	LOS MOVIMIENTOS NO PUEDEN VENIR DE UNA LOCACIÓN BASE DEBEN SER DE UNA LOCACIÓN MHI-A
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]
GO
--		 EXECUTE [dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]
CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]
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
	@PP_CANTIDAD_MOVIMIENTO			[DECIMAL](19,4),		--	ESTA CANTIDAD ES PARA ENVIAR PARCIALES A OTRAS LOCACIONES.
	@PP_K_FOLIO_DESTINO				[INT],
	@PP_K_ORDEN_TRABAJO_DESTINO		[INT] = -1
AS
DECLARE @VP_MENSAJE						VARCHAR(500) = ''		,@VP_LOCACION_ORIGEN_BD		INT
		,@VP_QTY_MOVIMIENTO				DECIMAL(19,4)			,@VP_K_FOLIO_ORIGEN			INT
		,@VP_K_ORDEN_TRABAJO_ORIGEN		INT						,@VP_TIPO_FOLIO_ORIGEN		VARCHAR(3)

--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO Y VALIDACIONES
	SELECT	@VP_K_FOLIO_ORIGEN			= INVENTARIO.K_FOLIO,
			@VP_LOCACION_ORIGEN_BD		= FOLIO.K_LOCACION,
			@VP_K_ORDEN_TRABAJO_ORIGEN	= K_ORDEN_TRABAJO,
			@VP_TIPO_FOLIO_ORIGEN		= TIPO	
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

	-- SE VERIFICA QUE EL FOLIO ORIGEN CUENTE CON UN FOLIO ASIGNADO, EN ESTE CASO DEBE SER EL BASE.
	IF @VP_K_FOLIO_ORIGEN IS NULL OR @VP_K_FOLIO_ORIGEN=0
	BEGIN
		SET @VP_MENSAJE='Folio Origen [0] no encontrado...Verifique'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END

	-- SE VERIFICA NUEVAMENTE LA LOCACIÓN ORIGEN YA QUE EL SISTEMA NO CUENTA CON UN PROCESO DE BLOQUEO DE REGISTROS, Y SE PUEDE DAR EL CASO
	-- QUE DOS USUARIOS REALICEN EL MOVIEMIENTO AL MISMO TIEMPO.
	IF @VP_LOCACION_ORIGEN_BD <> @PP_K_LOCACION_ORIGEN
	BEGIN
		SET @VP_MENSAJE='El registro seleccionado #ID_INVENTARIO[' + + CONVERT(VARCHAR(10),@PP_K_INVENTARIO) + '] no tiene una locación correcta[BD], Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END

	-- SE VERIFICA QUE EL TIPO DEL FOLIO ORIGEN NO VENGA DESDE EL FOLIO BASE
	IF @VP_TIPO_FOLIO_ORIGEN = 'B'
	BEGIN
		SET @VP_MENSAJE='El registro seleccionado #ID_INVENTARIO[' + + CONVERT(VARCHAR(10),@PP_K_INVENTARIO) + '] no puede moverse desde un Folio Base, Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END

	-- /////////////////////////////////////////////////////  
	IF @PP_K_LOCACION_ORIGEN = 6
	BEGIN
		EXECUTE	[PG_VALIDACION_SALIDA_MQU]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
											-- ===========================		 
		
		IF @PP_K_LOCACION_ORIGEN	=	@PP_K_LOCACION_DESTINO
		BEGIN
			SET @VP_MENSAJE='No es posible transferir de (MQU) a (MQU) #ID_INVENTARIO[' + + CONVERT(VARCHAR(10),@PP_K_INVENTARIO) + '], Verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

	END

	IF @PP_K_LOCACION_ORIGEN = 4 AND @PP_K_LOCACION_DESTINO = 4
	BEGIN
		SET @VP_MENSAJE='No es posible transferir material entre la misma locación (ALMACEN[MHI]) #ID_INVENTARIO[' + + CONVERT(VARCHAR(10),@PP_K_INVENTARIO) + '], Verifique...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
--=====================================================================================================================================
	---- =============================================================================	
	--UPDATE	INVENTARIO
--=====================================================================================================================================
--=====================================================================================================================================
		-- SE OBTIENE LA ORDEN DE COMPRA DESTINO PARA LOS LOGS
		DECLARE @VP_K_ORDEN_TRABAJO_DESTINO		INT			
		
		IF @PP_K_ORDEN_TRABAJO_DESTINO = -1
		BEGIN
			SELECT	@VP_K_ORDEN_TRABAJO_DESTINO=K_ORDEN_TRABAJO
			FROM	FOLIO
			WHERE	K_FOLIO=@PP_K_FOLIO_DESTINO
		END
		ELSE
		BEGIN
			SET		@VP_K_ORDEN_TRABAJO_DESTINO = @PP_K_ORDEN_TRABAJO_DESTINO
		END
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
											
	IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO<=0
	BEGIN
		SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0. [SERIE#] ' + CONVERT(VARCHAR(10),@PP_SERIE_NO)
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END		
	
	IF @PP_CANTIDAD_MOVIMIENTO > 0
		BEGIN
			IF @PP_CANTIDAD_MOVIMIENTO > @VP_QTY_MOVIMIENTO
					BEGIN
					SET @VP_MENSAJE='La cantidad movimiento no pude ser mayor a la cantidad disponible. [SERIE#] ' + CONVERT(VARCHAR(10),@PP_SERIE_NO)
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
											,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
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
												,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												-- ============================	
												,@VP_QTY_MOVIMIENTO

--=====================================================================================================================================
	--IF @PP_K_ORDEN_TRABAJO_DESTINO = -1
	--BEGIN
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@PP_K_FOLIO_DESTINO	
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
	--END
	--ELSE
	--BEGIN
		UPDATE	FOLIO
		SET
			K_LOCACION			= @PP_K_LOCACION_DESTINO
			,K_ORDEN_TRABAJO	= @VP_K_ORDEN_TRABAJO_DESTINO
		WHERE	K_FOLIO			= @PP_K_FOLIO_DESTINO
		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se pudo asignar la orden al FOLIO...Verificar'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END		
	--END
--=====================================================================================================================================		
--=====================================================================================================================================		
--=====================================================================================================================================		
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		DECLARE @VP_EXISTE_LOCACION		INT
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
--=====================================================================================================================================	


-- /////////////////////////////////////////////////////////////////////
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_REGISTROS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_REGISTROS]
GO
--	PRUEBAS
--		 EXECUTE [DBO].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_REGISTROS] 0,139, '1' , '67' , '4' , '4' , '2/2' , '3/1' , '20003/20001' , '8/4' , '112520/1541541' , '1,000.00/500.00'
CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_REGISTROS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_ACCION_FRONT		INT,
	@PP_K_ITEM					INT,
	@PP_K_LC_ORI				INT,
	@PP_K_LC_DES				INT,	--	@PP_K_LC_DES:	CUANDO EL MOVIMIENTO ES A UN FOLIO EXISTENTE SE RECIBE EL FOLIO INGRESADO Y NO LA LOCACIÓN DESTINO. DEL FOLIO SE OBTIENE LA LOCACIÓN CORRESPONDIENTE.
	@PP_ARRAY_K_ORDE			[NVARCHAR](MAX), -- [VARCHAR](50),
	@PP_ARRAY_K_ENTR			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_LOTE_P			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_K_INVE			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_SERIEN			[NVARCHAR](MAX), -- [INT],
	@PP_ARRAY_QTY_MV			[NVARCHAR](MAX) -- [DECIMAL](19,4)
AS			
DECLARE @VP_MENSAJE					VARCHAR(500) = ''
		,@VP_POS_K_ORDE				INT					,@VP_POS_K_ENTR				INT					,@VP_POS_K_ITEM				INT					
		,@VP_POS_LOTE_P				INT					,@VP_POS_LC_ORI				INT					,@VP_POS_LC_DES				INT
		,@VP_POS_K_INVE				INT					,@VP_POS_SERIEN				INT					,@VP_POS_QTY_MV				INT
		,@VP_VAL_K_ORDE				VARCHAR(500)		,@VP_VAL_K_ENTR				VARCHAR(500)		,@VP_VAL_LOTE_P				VARCHAR(500)		
		,@VP_VAL_K_INVE				VARCHAR(500)		,@VP_VAL_SERIEN				VARCHAR(500)		,@VP_VAL_QTY_MV				VARCHAR(500)
		,@VP_K_FOLIO_DESTINO		VARCHAR(10)
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
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
--	VALIDACIONES ESPECIFICAS
	
	IF  @PP_TIPO_ACCION_FRONT IN (1,2)
	BEGIN		
		-- ESTA VALIDACIÓN LA HACÍA EN EL FRONT, SE MOVIÓ AL BACK, PARA MEJOR FUNCIONABILIDAD.
		EXECUTE	[dbo].[PG_VALIDACION_LOCACION_ORIGEN]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_K_LC_ORI
	END


	-- =============================================================================
	-- ========		PARA OBTENER EL FOLIO DESTINO DE ACUERDO AL TIPO DE MOVIMIENTO
	-- =============================================================================
	--	PARA GENERAR EL NUEVO FOLIO PARA LOS ITEM QUE SE MOVERAN DE MHI-A PARA MHI-B
	IF  @PP_TIPO_ACCION_FRONT = 1
	BEGIN
		--	SE GENERA UN NUEVO FOLIO PARA EL MATERIAL. COMO SERÁ DE TIPO MHI-B SE ASIGNA DE TIPO MHI-A
		DECLARE @VP_F_DATE_FOLIO			DATE = GETDATE()

		EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										-- ===========================	
										@PP_K_LC_DES,	--@PP_K_LOCACION_DESTINO,
										0,	
										'A',--@PP_TIPO, 
										-- =========================
										@VP_F_DATE_FOLIO,
										-- ==========================
										@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO_DESTINO	OUTPUT
	END
	ELSE IF @PP_TIPO_ACCION_FRONT = 2
	BEGIN
		--	PARA VERIFICAR LA LOCACIÓN DEL FOLIO DESTINO
		DECLARE @VP_LOCACION_DESTINO_DE_FOLIO	INT

		SELECT	@VP_LOCACION_DESTINO_DE_FOLIO=K_LOCACION
		FROM	FOLIO
		WHERE	K_FOLIO=@PP_K_LC_DES		-- CUANDO ES ESTE TIPO DE ACCIÓN SE RECIBE DEL FRONT EL FOLIO Y NO LA LOCACIÓN.
						
			IF @VP_LOCACION_DESTINO_DE_FOLIO=0 OR @VP_LOCACION_DESTINO_DE_FOLIO IS NULL
			BEGIN
				SET @VP_MENSAJE='No se encontró locación para el FOLIO destino.[Fol-LOC]'
				RAISERROR (@VP_MENSAJE, 16, 1 )				
			END

		-- SE REALIZA UNA REASIGNACIÓN DE VALORES PARA ENVIAR LAS MISMAS VARIABLES EN EL MOVIMIENTO
		SET @VP_K_FOLIO_DESTINO	= @PP_K_LC_DES
		SET @PP_K_LC_DES		= @VP_LOCACION_DESTINO_DE_FOLIO
	END

-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_K_ORDE			= @PP_ARRAY_K_ORDE	+ '/'
	SET	@PP_ARRAY_K_ENTR			= @PP_ARRAY_K_ENTR	+ '/'	
	SET	@PP_ARRAY_LOTE_P			= @PP_ARRAY_LOTE_P	+ '/'
	SET	@PP_ARRAY_K_INVE			= @PP_ARRAY_K_INVE	+ '/'
	SET	@PP_ARRAY_SERIEN			= @PP_ARRAY_SERIEN	+ '/'
	SET	@PP_ARRAY_QTY_MV			= @PP_ARRAY_QTY_MV	+ '/'
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_K_ORDE) <> 0
	BEGIN
		SELECT @VP_POS_K_ORDE	=	patindex('%/%' , @PP_ARRAY_K_ORDE		)
		SELECT @VP_POS_K_ENTR	=	patindex('%/%' , @PP_ARRAY_K_ENTR		)
		SELECT @VP_POS_LOTE_P	=	patindex('%/%' , @PP_ARRAY_LOTE_P		)
		SELECT @VP_POS_K_INVE	=	patindex('%/%' , @PP_ARRAY_K_INVE		)
		SELECT @VP_POS_SERIEN	=	patindex('%/%' , @PP_ARRAY_SERIEN		)
		SELECT @VP_POS_QTY_MV	=	patindex('%/%' , @PP_ARRAY_QTY_MV		)

		--Buscamos la posicion del primer registro y obtenemos los caracteres hasta esa posicion
		SELECT @VP_VAL_K_ORDE		= LEFT(@PP_ARRAY_K_ORDE		, @VP_POS_K_ORDE		- 1)
		SELECT @VP_VAL_K_ENTR		= LEFT(@PP_ARRAY_K_ENTR		, @VP_POS_K_ENTR		- 1)
		SELECT @VP_VAL_LOTE_P		= LEFT(@PP_ARRAY_LOTE_P		, @VP_POS_LOTE_P		- 1)
		SELECT @VP_VAL_K_INVE		= LEFT(@PP_ARRAY_K_INVE		, @VP_POS_K_INVE		- 1)
		SELECT @VP_VAL_SERIEN		= LEFT(@PP_ARRAY_SERIEN		, @VP_POS_SERIEN		- 1)
		SELECT @VP_VAL_QTY_MV		= LEFT(@PP_ARRAY_QTY_MV		, @VP_POS_QTY_MV		- 1)

		-- ========================================================================================================================================================================================================================
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
														,30					--	30		FOLIO NUEVO						FOLNEW		-- MOVIMIENTO_TIPO
														,@VP_VAL_QTY_MV		,@VP_K_FOLIO_DESTINO
			END
			ELSE
			BEGIN
				SET @VP_MENSAJE='Movimiento no permitido, desde el botón seleccionado.[B-A]'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
		END
		-- ============================================================================================================
		-- ============================================================================================================
		-- ============================================================================================================
		--		SE MANDA LLAMAR CON EL RB_FOLIO_EXISTENTE
		--	@PP_TIPO_ACCION_FRONT = 2		PARA MOVER MATERIAL A UN FOLIO EXISTENTE
		ELSE IF  @PP_TIPO_ACCION_FRONT = 2
		BEGIN
			EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
															-- ======================================================
															,@VP_VAL_K_ORDE		,@VP_VAL_K_ENTR
															,@PP_K_ITEM			,@VP_VAL_LOTE_P
															,@PP_K_LC_ORI		,@PP_K_LC_DES
															,@VP_VAL_K_INVE		,@VP_VAL_SERIEN		
															,50					--	50		TRANSFERENCIA A FOLIO			TRXFOL		-- MOVIMIENTO_TIPO
															,@VP_VAL_QTY_MV		,@VP_K_FOLIO_DESTINO			

		END
		-- ============================================================================================================
		-- ============================================================================================================
		-- ============================================================================================================
		ELSE
		BEGIN
			SET @VP_MENSAJE='La acción no generó ningún valor.'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
		
		--Reemplazamos lo procesado con nada con la funcion stuff
		SELECT @PP_ARRAY_K_ORDE		= STUFF(@PP_ARRAY_K_ORDE		, 1, @VP_POS_K_ORDE , '')
		SELECT @PP_ARRAY_K_ENTR		= STUFF(@PP_ARRAY_K_ENTR		, 1, @VP_POS_K_ENTR , '')
		SELECT @PP_ARRAY_LOTE_P		= STUFF(@PP_ARRAY_LOTE_P		, 1, @VP_POS_LOTE_P , '')
		SELECT @PP_ARRAY_K_INVE		= STUFF(@PP_ARRAY_K_INVE		, 1, @VP_POS_K_INVE	, '')
		SELECT @PP_ARRAY_SERIEN		= STUFF(@PP_ARRAY_SERIEN		, 1, @VP_POS_SERIEN , '')
		SELECT @PP_ARRAY_QTY_MV		= STUFF(@PP_ARRAY_QTY_MV		, 1, @VP_POS_QTY_MV , '')
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
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
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_FOLIO_DESTINO	 AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- ================================================================================================================================================
-- ================================================================================================================================================
-- ================================================================================================================================================
-- ================================================================================================================================================



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_FOLIO]
GO
--	PRUEBAS
--		 EXECUTE [DBO].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_FOLIO] 0,139, '1' , '67' , '4' , '4' , '2/2' , '3/1' , '20003/20001' , '8/4' , '112520/1541541' , '1,000.00/500.00'
CREATE PROCEDURE [dbo].[PG_PR_MOVIMIENTO_ENTRE_LOCACION_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_ACCION_FRONT		INT,
	@PP_K_ITEM					INT,
	@PP_K_LC_ORI				INT,
	@PP_K_LC_DES				INT,	--	@PP_K_LC_DES:	CUANDO EL MOVIMIENTO ES A UNA ORDEN EXISTENTE SE RECIBE LA ORDEN Y NO LA LOCACIÓN DESTINO. DE LA ORDEN SE OBTIENE LA LOCACIÓN CORRESPONDIENTE.
										--	MOVIMIENTO QUE SOLICITA LA VALIDACIÓN DEL USUARIO PARA MOVER A ORDEN EXISTENTE, RECIBE EL FOLIO
	@PP_K_FOLIO_ORIGEN			INT,
	@PP_K_ORDEN_TRABAJO			INT =-1
AS			
DECLARE @VP_MENSAJE					VARCHAR(500) = ''
		,@VP_K_FOLIO_DESTINO		VARCHAR(10)
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
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
--	VALIDACIONES ESPECIFICAS
	
	IF  @PP_TIPO_ACCION_FRONT IN (1,2)
	BEGIN		
		-- ESTA VALIDACIÓN LA HACÍA EN EL FRONT, SE MOVIÓ AL BACK, PARA MEJOR FUNCIONABILIDAD.
		EXECUTE	[dbo].[PG_VALIDACION_LOCACION_ORIGEN]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_K_LC_ORI
	END


	-- =============================================================================
	-- ========		PARA OBTENER EL FOLIO DESTINO DE ACUERDO AL TIPO DE MOVIMIENTO
	-- =============================================================================
	--	PARA GENERAR EL NUEVO FOLIO PARA LOS ITEM QUE SE MOVERAN A MESA, GERBER O MHI
	IF  @PP_TIPO_ACCION_FRONT = 1
	BEGIN
		--	SÓLO SE PUEDE MOVER EL MATERIAL DE UN FOLIO A MESA, GERBER O MHI
		EXECUTE	[dbo].[PG_VALIDACION_LOCACION_DESTINO_X_FOLIO]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
																-- ===========================
																@PP_K_LC_DES

		----	SE GENERA UN NUEVO FOLIO PARA EL MATERIAL. SE ASIGNA DE TIPO MHI-A
		--DECLARE @VP_F_DATE_FOLIO			DATE = GETDATE()
		--
		--EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--								-- ===========================	
		--								@PP_K_LC_DES,	--@PP_K_LOCACION_DESTINO,
		--								0,	
		--								'A',--@PP_TIPO, 
		--								-- =========================
		--								@VP_F_DATE_FOLIO,
		--								-- ==========================
		--								@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO_DESTINO	OUTPUT
		SET @VP_K_FOLIO_DESTINO = @PP_K_FOLIO_ORIGEN
	END
	-- CUANDO SE REALIZA EL MOVIMIENTO POR ORDEN:
	-- SI LA ORDEN NO EXISTE AGREGADA A UN FOLIO, SE MUEVE TODO EL FOLIO A LA LOCACIÓN ASIGNADA Y SE LE ASIGNA LA ORDEN_TRABAJO
	-- CUANDO EXISTA LA ORDEN AGREGADA A UN FOLIO, SE TRANSFIERE POR LOCACIÓN
	ELSE IF @PP_TIPO_ACCION_FRONT = 2
	BEGIN
		DECLARE @VP_LOCACION_DE_LA_ORDEN	INT
				,@VP_ORDEN_DESTINO			INT
		
		SELECT  @VP_LOCACION_DE_LA_ORDEN	= IMLOCFIL_SQL.A4GLIdentity
		FROM	DATA_02.DBO.CCJOBHDR_SQL
		INNER	JOIN DATA_02.DBO.IMLOCFIL_SQL ON CCJOBHDR_SQL.machine = IMLOCFIL_SQL.loc_desc
		WHERE	LTRIM(RTRIM(JOBNO)) = @PP_K_LC_DES	-- CUANDO ES POR ORDEN EN ESTA VARIABLE VIENE EL NÚMERO DE ORDEN DESTINO Y NO LA LOCACIÓN.
		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se encontró la locación de la orden [CCJOBHDR].'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

		SET		@VP_K_FOLIO_DESTINO	= @PP_K_FOLIO_ORIGEN
		SET		@VP_ORDEN_DESTINO	= @PP_K_LC_DES
		SET		@PP_K_LC_DES		= @VP_LOCACION_DE_LA_ORDEN
	END
	ELSE IF @PP_TIPO_ACCION_FRONT = 3
	BEGIN
		DECLARE @VP_LOCACION_DESTINO_DE_FOLIO	INT			,@VP_ORDEN_TRABAJO_DESTINO	INT
		--	PARA VERIFICAR LA LOCACIÓN DE LA ORDEN DESTINO
		SELECT	@VP_LOCACION_DESTINO_DE_FOLIO	= K_LOCACION
				,@VP_ORDEN_TRABAJO_DESTINO		= K_ORDEN_TRABAJO
		FROM	FOLIO
		WHERE	K_FOLIO=@PP_K_LC_DES		-- CUANDO ES ESTE TIPO DE ACCIÓN SE RECIBE DEL FRONT EL FOLIO Y NO LA LOCACIÓN.
					
		IF @VP_LOCACION_DESTINO_DE_FOLIO=0 OR @VP_LOCACION_DESTINO_DE_FOLIO IS NULL
		BEGIN
			SET @VP_MENSAJE='Movimiento no permitido.'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

		IF @PP_K_ORDEN_TRABAJO	<>	@VP_ORDEN_TRABAJO_DESTINO
		BEGIN
			SET @VP_MENSAJE='No coinciden las órdenes de trabajo.'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

		SET		@VP_K_FOLIO_DESTINO	= @PP_K_LC_DES						--@PP_K_FOLIO_ORIGEN
		SET		@VP_ORDEN_DESTINO	= @VP_ORDEN_TRABAJO_DESTINO			--@PP_K_LC_DES
		SET		@PP_K_LC_DES		= @VP_LOCACION_DESTINO_DE_FOLIO		--@VP_LOCACION_DE_LA_ORDEN


	END
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
DECLARE  @VP_CU_K_ORDE				VARCHAR(500)		,@VP_CU_K_ENTR				VARCHAR(500)		,@VP_CU_LOTE_P				VARCHAR(500)		
		,@VP_CU_K_INVE				VARCHAR(500)		,@VP_CU_SERIEN				VARCHAR(500)		,@VP_CU_QTY_MV				VARCHAR(500)

DECLARE CU_OBTENER_REGISTROS			CURSOR LOCAL FOR
	SELECT	K_ORDEN_COMPRA_PEDIDO	,K_ENTREGA			,LOTE_PEARL
			,K_INVENTARIO			,SERIE_NO			,CANTIDAD_RECIBIDA		
	FROM	INVENTARIO
	INNER JOIN FOLIO ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM
	AND		INVENTARIO.L_BORRADO	<> 1
	AND		K_STATUS_INVENTARIO		= 20
	AND		INVENTARIO.K_FOLIO		= @PP_K_FOLIO_ORIGEN
	
	OPEN	CU_OBTENER_REGISTROS
		FETCH NEXT FROM CU_OBTENER_REGISTROS INTO	@VP_CU_K_ORDE	,@VP_CU_K_ENTR	,@VP_CU_LOTE_P		,@VP_CU_K_INVE	,@VP_CU_SERIEN	,@VP_CU_QTY_MV
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			
			IF @PP_TIPO_ACCION_FRONT IN( 1,3 )
			BEGIN
				EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
																-- ======================================================
																,@VP_CU_K_ORDE		,@VP_CU_K_ENTR
																,@PP_K_ITEM			,@VP_CU_LOTE_P
																,@PP_K_LC_ORI		,@PP_K_LC_DES
																,@VP_CU_K_INVE		,@VP_CU_SERIEN		
																,50					--	20		TRANSFERENCIA A LOCACIÓN		TRXLOC		-- MOVIMIENTO_TIPO
																,@VP_CU_QTY_MV		,@VP_K_FOLIO_DESTINO
			END
			ELSE IF @PP_TIPO_ACCION_FRONT = 2
			BEGIN
				EXECUTE [PG_PR_MOVIMIENTO_LOCACION_A_LOCACION]	@PP_K_SISTEMA_EXE	,@PP_K_USUARIO_ACCION
																	-- ======================================================
																	,@VP_CU_K_ORDE		,@VP_CU_K_ENTR
																	,@PP_K_ITEM			,@VP_CU_LOTE_P
																	,@PP_K_LC_ORI		,@PP_K_LC_DES
																	,@VP_CU_K_INVE		,@VP_CU_SERIEN		
																	,40					--	40		TRANSFERENCIA A ORDEN			TRXORD		-- MOVIMIENTO_TIPO
																	,@VP_CU_QTY_MV		,@VP_K_FOLIO_DESTINO
																	,@VP_ORDEN_DESTINO
			END
		--==============================================================
		FETCH NEXT FROM CU_OBTENER_REGISTROS INTO	@VP_CU_K_ORDE	,@VP_CU_K_ENTR	,@VP_CU_LOTE_P		,@VP_CU_K_INVE	,@VP_CU_SERIEN	,@VP_CU_QTY_MV
		END
	CLOSE		CU_OBTENER_REGISTROS
	DEALLOCATE	CU_OBTENER_REGISTROS		
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
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
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_FOLIO_DESTINO	 AS CLAVE, @PP_TIPO_ACCION_FRONT AS TIPO_ACCION, @VP_ORDEN_DESTINO AS ORDEN_DESTINO
	-- //////////////////////////////////////////////////////////////
GO