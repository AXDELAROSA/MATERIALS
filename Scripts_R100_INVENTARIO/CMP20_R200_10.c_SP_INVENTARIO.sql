-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20200926
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02pruebas]
USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
--					CONTENIDO DEL SP
--	[PG_LI_INVENTARIO_X_ITEM]
--	[PG_LI_INVENTARIO_X_FOLIO]
--	[PG_LI_FOLIO_BASE]
--	[PG_LI_INVENTARIO_BUSCAR_X_PARAMETROS]
--	[PG_SK_ITEM_X_FOLIO]
--	[PG_SK_LOCACION_DEL_FOLIO]
--	[PG_IN_FOLIO]
--	[PG_IN_MOVIMIENTO_X_REGISTRO]
--	[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]
--	[PG_IN_INVENTARIO_RECIBO]
--	[PG_IN_INVENTARIO_LOCACION]
--	[PG_UP_INVENTARIO_LOCACION]
--	[PG_IN_MOVIMIENTO_INVENTARIO]
--	[PG_SK_MIN_MAX_X_ITEM]
--	[PG_SK_FOLIO_NO_DOBLE]
--	[PG_UP_STATUS_INVENTARIO_INSPECCION]
--	[PG_IN_MOVIMIENTO_A_MHI]
--	[PG_IN_MOVIMIENTO_A_MQU]
--	[PG_IN_MOVIMIENTO_MQU_A_MHI]
--	[PG_IN_MOVIMIENTO_MHI_A_MQU]
--	[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- // MUESTRA LOS FOLIOS ASIGNADOS POR K_ITEM
-- // SE MANDA LLAMAR DESDE LA FORMA INVENTARIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO_X_ITEM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO_X_ITEM]
GO
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  70
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,87,   70
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  1507
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  1508
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  1867
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  1868
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  2212
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_ITEM] 1,139,  2213
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO_X_ITEM]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM						INT
AS
	-- =========================================
IF	@PP_K_USUARIO_ACCION	= 139
BEGIN
	-- //////////////////////////////////////////////////////////////////////////////////////
	SELECT		DISTINCT
				-- =============================	
				INVENTARIO.K_FOLIO
				,FOLIO.TIPO
				,( CASE WHEN LOC = 'MHI' THEN	'ALMACEN'
					ELSE	LOC	END
				 ) AS	LOC
				,K_LOCACION
				,K_ORDEN_TRABAJO AS ORDEN_TRABAJO
				-- =============================	
	FROM		INVENTARIO						(NOLOCK) 
	INNER JOIN	FOLIO							(NOLOCK) ON FOLIO.K_FOLIO=INVENTARIO.K_FOLIO
	INNER JOIN	COMPRAS.dbo.ITEM				(NOLOCK) ON INVENTARIO.K_ITEM=ITEM.K_ITEM	
	INNER JOIN	IMLOCFIL_SQL					(NOLOCK) ON FOLIO.K_LOCACION	= IMLOCFIL_SQL.A4GLIdentity
				-- =============================
				-- =============================
	WHERE		INVENTARIO.K_ITEM				= @PP_K_ITEM
	AND			INVENTARIO.K_STATUS_INVENTARIO	>= 20	-- [20]	= INSPECCIONADO
	AND			INVENTARIO.L_BORRADO			<> 1
	ORDER BY	K_FOLIO DESC
	-- //////////////////////////////////////////////////////////////////////////////////////
END
ELSE
BEGIN
	-- //////////////////////////////////////////////////////////////////////////////////////
			SELECT		DISTINCT
						-- =============================	
						INVENTARIO.K_FOLIO
						,FOLIO.TIPO
						,( CASE WHEN LOC = 'MHI' THEN	'ALMACEN'
							ELSE	LOC	END
						 ) AS	LOC
						,K_LOCACION
						,K_ORDEN_TRABAJO AS ORDEN_TRABAJO
						-- =============================	
			FROM		INVENTARIO				(NOLOCK) 
			INNER JOIN	FOLIO					(NOLOCK) ON FOLIO.K_FOLIO=INVENTARIO.K_FOLIO
			INNER JOIN	COMPRAS.dbo.ITEM		(NOLOCK) ON INVENTARIO.K_ITEM=ITEM.K_ITEM	
			INNER JOIN	IMLOCFIL_SQL			(NOLOCK) ON FOLIO.K_LOCACION=IMLOCFIL_SQL.A4GLIdentity
						-- =============================
						-- =============================
			WHERE		INVENTARIO.K_ITEM				= @PP_K_ITEM
			AND			INVENTARIO.K_STATUS_INVENTARIO	= 20	-- [20]	= INSPECCIONADO
			AND			FOLIO.K_LOCACION				= 4
			AND			INVENTARIO.L_BORRADO			<> 1
			ORDER BY	K_FOLIO DESC
	-- //////////////////////////////////////////////////////////////////////////////////////
END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //	MUESTRA LOS REGISTROS DE MATERIAL RECIBIDO ASIGNADOS AL FOLIO
-- //	SE MANDA LLAMAR DESDE LA PANTALLA DE INVENTARIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO_X_FOLIO]
GO
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_FOLIO] 0,139,3
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_X_FOLIO] 0,139,105
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO_X_FOLIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_FOLIO						INT
AS
	-- ///////////////////////////////////////////			
	SELECT	TOP (5000)
			K_ORDEN_COMPRA_PEDIDO
			,K_ENTREGA
			,INVENTARIO.K_ITEM
			,LOTE_PEARL
			,CANTIDAD_RECIBIDA												---	COLUMNA PARA QUITAR.
			,CANTIDAD_RECIBIDA				AS CANTIDAD_DISPONIBLE			
			,K_LOCACION
			,LOC
			,INVENTARIO.K_FOLIO
			,SERIE_NO
			,K_INVENTARIO
			-- ======================================================
			,UPPER(S_UNIT_OF_MEASURE)		AS S_UNIT_OF_MEASURE
			,( CASE
					WHEN PART_NUMBER_ITEM_PEARL IN ( 'MTWL10MM','MTWL06MM') THEN 'M2'
					WHEN TRADEMARK_ITEM = 'HILO'							THEN 'PZAS'
					ELSE '---'
				END ) AS UOM
			,( CASE
					WHEN PART_NUMBER_ITEM_PEARL IN ( 'MTWL10MM','MTWL06MM') THEN 'M2'
					WHEN TRADEMARK_ITEM = 'HILO'							THEN 'PZAS'
					ELSE '---'
				END ) AS UOM_CONVERSION
			,( CASE
					WHEN PART_NUMBER_ITEM_PEARL IN ( 'MTWL10MM','MTWL06MM') THEN    ROUND((CANTIDAD_RECIBIDA / 1.094),1)  * 1.5
					WHEN TRADEMARK_ITEM = 'HILO'							THEN    (CANTIDAD_RECIBIDA / 2)
					ELSE '0'
				END ) AS CONVERSION
			,( CASE
					WHEN PART_NUMBER_ITEM_PEARL IN ( 'MTWL10MM','MTWL06MM') THEN    ROUND((CANTIDAD_RECIBIDA / 1.094),1)  * 1.5
					WHEN TRADEMARK_ITEM = 'HILO'							THEN    (CANTIDAD_RECIBIDA / 2)
					ELSE '0'
				END ) AS CANTIDAD_CONVERSION
	FROM	INVENTARIO				(NOLOCK)  
	INNER JOIN FOLIO				(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	INNER JOIN IMLOCFIL_SQL			(NOLOCK) ON FOLIO.K_LOCACION=IMLOCFIL_SQL.A4GLIdentity
	INNER JOIN COMPRAS.dbo.ITEM		(NOLOCK) ON ITEM.K_ITEM = INVENTARIO.K_ITEM
	INNER JOIN BD_GENERAL.dbo.UNIT_OF_MEASURE (NOLOCK) ON ITEM.K_UNIT_OF_ITEM = UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
	WHERE	INVENTARIO.K_FOLIO				= @PP_K_FOLIO
	AND		INVENTARIO.K_STATUS_INVENTARIO	>= 20	-- [20]	= INSPECCIONADO
	AND		INVENTARIO.L_BORRADO			<> 1
	ORDER BY LOTE_PEARL, CANTIDAD_RECIBIDA
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL LISTADO DE LOS FOLIOS BASES
-- // SE MANDA LLAMAR DESDE LA FORMA INVENTARIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_FOLIO_BASE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_FOLIO_BASE]
GO
--		 EXECUTE [dbo].[PG_LI_FOLIO_BASE] 1,139,'B'
CREATE PROCEDURE [dbo].[PG_LI_FOLIO_BASE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_TIPO_FOLIO					VARCHAR(50)
AS
	-- ///////////////////////////////////////////
	-- =========================================
	-- =========================================
	DECLARE @VP_TA_CATALOGO	AS TABLE
			(	TA_K_CATALOGO		INT,
				TA_REGISTROS		INT,
				TA_PART_NUMBER		VARCHAR(500),
				TA_CANTIDAD			DECIMAL(19,2),
				TA_UOM				VARCHAR(500),
				TA_D_CATALOGO		VARCHAR(500),
				TA_TRADEMARK		VARCHAR(500),
				TA_MINIMA			INT,
				TA_MAXIMA			INT
			)	
			
	INSERT INTO	@VP_TA_CATALOGO
	SELECT	TOP(5000)
			K_FOLIO
			,COUNT(INVENTARIO.K_ITEM)	
			,PART_NUMBER_ITEM_PEARL
			,SUM(CANTIDAD_RECIBIDA)		--AS CANTIDAD_DISPONIBLE
			,UPPER(S_UNIT_OF_MEASURE)	--AS UOM
			--,D_ITEM					--
			,ITEM_DESC_1				--AS D_ITEM
			,TRADEMARK_ITEM
			,CANTIDAD_MINIMA
			,CANTIDAD_MAXIMA
	FROM	INVENTARIO			(NOLOCK)  
	INNER JOIN COMPRAS.DBO.ITEM	(NOLOCK)  ON	INVENTARIO.K_ITEM=ITEM.K_ITEM
	INNER JOIN BD_GENERAL.dbo.UNIT_OF_MEASURE	(NOLOCK) ON ITEM.K_UNIT_OF_ITEM = UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
	LEFT  JOIN DATA_02.DBO.IMITMIDX_SQL			(NOLOCK) ON IMITMIDX_SQL.UPC_CD = ITEM.K_ITEM
	WHERE	K_FOLIO IN (
						SELECT	K_FOLIO
						FROM	FOLIO		(NOLOCK) 
						WHERE	K_LOCACION	= 4
						AND		TIPO		= 'B'--@PP_TIPO_FOLIO
						)
	AND		INVENTARIO.K_STATUS_INVENTARIO >= 20	-- [20]	= INSPECCIONADO
	AND		INVENTARIO.L_BORRADO <> 1
	GROUP BY	K_FOLIO,	PART_NUMBER_ITEM_PEARL,	S_UNIT_OF_MEASURE,	ITEM_DESC_1,	TRADEMARK_ITEM, CANTIDAD_MINIMA,	CANTIDAD_MAXIMA

	SELECT	--*
			 TA_K_CATALOGO			AS K_FOLIO
			--,TA_REGISTROS			AS REGISTROS
			,TA_PART_NUMBER			AS PART_NUMBER_ITEM_PEARL
			,TA_CANTIDAD			AS CANTIDAD_DISPONIBLE
			,TA_UOM					AS S_UNIT_OF_MEASURE
			,TA_UOM					AS UOM						-- COLUMNA PARA QUITAR
			,TA_D_CATALOGO			AS D_ITEM
			,TA_TRADEMARK			AS TRADEMARK_ITEM
			,TA_MINIMA				AS CANTIDAD_MINIMA
			,TA_MAXIMA				AS CANTIDAD_MAXIMA
	-- ======================================================
	,( CASE
			WHEN TA_PART_NUMBER IN ( 'MTWL10MM','MTWL06MM')		THEN 'm2 / PZAS'
			WHEN TA_TRADEMARK = 'HILO'							THEN 'PZAS'
			ELSE '---'
		END ) AS UOM_CONVERSION
	,( CASE
			WHEN TA_PART_NUMBER IN ( 'MTWL10MM','MTWL06MM')		THEN	CONCAT(	FORMAT( ROUND((TA_CANTIDAD / 1.094),1)  * 1.5,'0.00'), ' / ', TA_REGISTROS )
			WHEN TA_TRADEMARK = 'HILO'							THEN    FORMAT( (TA_CANTIDAD / 2) , '0' )
			ELSE '0'
		END ) AS CANTIDAD_CONVERSION
	-- ======================================================
	FROM	@VP_TA_CATALOGO
-- /////////////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LA BUSQUEDA DE ITEM
-- // DE ACUERDO A LOS VALORES ENVIADOS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO_BUSCAR_X_PARAMETROS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO_BUSCAR_X_PARAMETROS]
GO
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_BUSCAR_X_PARAMETROS] 0,139,82,-1,-1,'',-1
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_BUSCAR_X_PARAMETROS] 1,139,-1,-1,-1,'11039383',-1
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO_BUSCAR_X_PARAMETROS] 
 @PP_K_SISTEMA_EXE   INT,  
 @PP_K_USUARIO_ACCION  INT,  
 -- ===========================  
 @PP_K_ITEM				[INT],
 @PP_K_LOTE				[INT],
 @PP_K_FOLIO			[INT],
 @PP_SERIE_NO			[VARCHAR](25),
 @PP_K_ORDEN			[INT]
AS    
 -- ///////////////////////////////////////////  
 -- ///////////////////////////////////////////  
--IF @PP_K_SISTEMA_EXE = 0 
--BEGIN
--	SELECT  DISTINCT  
--	  ISNULL(INVENTARIO.K_ITEM, '')			AS K_ITEM
--	  ,ISNULL(PART_NUMBER_ITEM_PEARL, '')	AS PART_NUMBER_ITEM_PEARL
--	  ,ISNULL(LOTE_PEARL, '')				AS LOTE_PEARL
--	  ,ISNULL(SERIE_NO, '')					AS SERIE_NO
--	  ,ISNULL(CANTIDAD_RECIBIDA, '')		AS CANTIDAD_RECIBIDA
--	  ,ISNULL(INVENTARIO.K_FOLIO, 0)		AS K_FOLIO
--	  -- =======================  
--	  ,ISNULL(K_LOCACION, '')				AS K_LOCACION
--	  ,ISNULL(LOC, '')						AS LOC
--	  ,ISNULL(K_ORDEN_TRABAJO, '')			AS K_ORDEN_TRABAJO
--	-- =======================  
--	FROM INVENTARIO							(NOLOCK)  
--	-- ======================= 
--	LEFT JOIN	FOLIO						(NOLOCK)  ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
--	INNER JOIN	COMPRAS_Pruebas.DBO.ITEM	(NOLOCK)  ON INVENTARIO.K_ITEM=ITEM.K_ITEM
--	INNER JOIN	IMLOCFIL_SQL				(NOLOCK)  ON FOLIO.K_LOCACION=IMLOCFIL_SQL.A4GLIdentity
--	WHERE	INVENTARIO.L_BORRADO<>1
--	AND		K_STATUS_INVENTARIO>=20
-- 	AND		( @PP_K_ITEM=-1					OR	INVENTARIO.K_ITEM		=	@PP_K_ITEM )
-- 	AND		( @PP_K_LOTE=-1					OR	INVENTARIO.LOTE_PEARL	=	@PP_K_LOTE )
--	AND		( @PP_K_FOLIO=-1				OR	INVENTARIO.K_FOLIO		=	@PP_K_FOLIO )
--	AND		( @PP_SERIE_NO=''				OR	INVENTARIO.SERIE_NO		=	@PP_SERIE_NO )
--	AND		( @PP_K_ORDEN=-1				OR	FOLIO.K_ORDEN_TRABAJO	=	@PP_K_ORDEN )
--END
--ELSE
--BEGIN
	SELECT  DISTINCT  
	  ISNULL(INVENTARIO.K_ITEM, '')			AS K_ITEM
	  ,ISNULL(PART_NUMBER_ITEM_PEARL, '')	AS PART_NUMBER_ITEM_PEARL
	  ,ISNULL(LOTE_PEARL, '')				AS LOTE_PEARL
	  ,ISNULL(SERIE_NO, '')					AS SERIE_NO
	  ,ISNULL(CANTIDAD_RECIBIDA, '')		AS CANTIDAD_DISPONIBLE
	  ,ISNULL(INVENTARIO.K_FOLIO, 0)		AS K_FOLIO
	  -- =======================  
	  ,ISNULL(K_LOCACION, '')				AS K_LOCACION
	  ,( CASE 
			WHEN	LOC = 'MHI' THEN	'ALMACEN'
			ELSE	LOC	
		END		) AS	LOC
	  --,ISNULL(LOC, '')						AS LOC
	  ,ISNULL(K_ORDEN_TRABAJO, '')			AS K_ORDEN_TRABAJO
	-- =======================  
	FROM INVENTARIO							(NOLOCK) 
	-- ======================= 
	LEFT JOIN	FOLIO						(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	INNER JOIN	COMPRAS.DBO.ITEM			(NOLOCK) ON INVENTARIO.K_ITEM=ITEM.K_ITEM
	INNER JOIN	IMLOCFIL_SQL				(NOLOCK) ON FOLIO.K_LOCACION=IMLOCFIL_SQL.A4GLIdentity
	WHERE	INVENTARIO.L_BORRADO<>1
	AND		K_STATUS_INVENTARIO>=20
 	AND		( @PP_K_ITEM=-1					OR	INVENTARIO.K_ITEM		=	@PP_K_ITEM )
 	AND		( @PP_K_LOTE=-1					OR	INVENTARIO.LOTE_PEARL	=	@PP_K_LOTE )
	AND		( @PP_K_FOLIO=-1				OR	INVENTARIO.K_FOLIO		=	@PP_K_FOLIO )
	AND		( @PP_SERIE_NO=''				OR	INVENTARIO.SERIE_NO		=	@PP_SERIE_NO )
	AND		( @PP_K_ORDEN=-1				OR	FOLIO.K_ORDEN_TRABAJO	=	@PP_K_ORDEN )
--END
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //	MUESTRA LOS REGISTROS DE MATERIAL RECIBIDO ASIGNADOS AL FOLIO
-- //	SE MANDA LLAMAR DESDE LA PANTALLA DE INVENTARIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ITEM_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ITEM_X_FOLIO]
GO
--		 EXECUTE [dbo].[PG_SK_ITEM_X_FOLIO] 1,87,2647
CREATE PROCEDURE [dbo].[PG_SK_ITEM_X_FOLIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_FOLIO						INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
			,@VP_K_ITEM			INT
	-- ///////////////////////////////////////////			
	IF	@PP_K_USUARIO_ACCION	= 139
	BEGIN
		SELECT	TOP(1)
				@VP_K_ITEM	=	K_ITEM
		FROM	INVENTARIO		(NOLOCK) 
		INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
		WHERE	INVENTARIO.K_FOLIO	= @PP_K_FOLIO
	END
	ELSE
	BEGIN
		SELECT	TOP(1)
				@VP_K_ITEM	=	K_ITEM
		FROM	INVENTARIO		(NOLOCK) 
		INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
		WHERE	INVENTARIO.K_FOLIO	= @PP_K_FOLIO
		AND		FOLIO.K_LOCACION	= 4
	END

		IF (@VP_K_ITEM IS NULL) OR (@VP_K_ITEM = 0)
		BEGIN
			SET @VP_MENSAJE='El [FOLIO] ya no se encuentra en (MHI)...['+CONVERT(VARCHAR(10),@PP_K_FOLIO)+']'
		END
				
	SELECT @VP_K_ITEM AS K_ITEM	, @VP_MENSAJE	AS MENSAJE
	-- ////////////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //	VERIFICA LA LOCACIÓN DEL FOLIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LOCACION_DEL_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_LOCACION_DEL_FOLIO]
GO
--		 EXECUTE [dbo].[PG_SK_LOCACION_DEL_FOLIO] 0,139,2228
CREATE PROCEDURE [dbo].[PG_SK_LOCACION_DEL_FOLIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_FOLIO						INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
			,@VP_K_LOCACION			INT
	-- ///////////////////////////////////////////			
	SELECT	TOP(1)
			@VP_K_LOCACION	=	K_LOCACION
--			K_LOCACION
	FROM	FOLIO		(NOLOCK) 
	WHERE	K_FOLIO		= @PP_K_FOLIO

	IF (@VP_K_LOCACION IS NULL) OR (@VP_K_LOCACION = 0)
	BEGIN
		SET @VP_MENSAJE='Locación del [FOLIO] no encontrada...Verifique ['+CONVERT(VARCHAR(10),@PP_K_FOLIO)+']'
		SET @VP_K_LOCACION = 0
	END
				
	SELECT @VP_K_LOCACION AS K_LOCACION	, @VP_MENSAJE	AS MENSAJE
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT PRIMERO EL FOLIO, SE OBTIENE EL VALOR INSERTADO Y SE ASIGNA EN LA TABLA DE INVENTARIO.
-- //	SE MANDA LLAMAR DESDE:	 [PG_IN_INVENTARIO_RECIBO]
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_IN_FOLIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LOCACION							[INT],
	@PP_K_ORDEN_TRABAJO						[INT],
	@PP_TIPO								[VARCHAR] (50),
	-- ===========================
	@PP_F_DATE_FOLIO						[DATE],
	-- ============================
--	@PP_CANTIDAD_RECIBIDA					[DECIMAL](19,4),
	@PP_K_FOLIO_INSERTADO					INT				OUTPUT
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
			,@VP_K_FOLIO					INT
		-- /////////////////////////////////////////////////////////////////////
		--	EL ID SE ASIGNA POR IDENTITY, OBTENER EL RESULTADO DE LA OPERACIÓN EN CASO DE REQUERIRLO.
	-- //////////////////////////////////////////////////////////////
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
				--SET @VP_MENSAJE='The record was not inserted.'
				SET @VP_MENSAJE='No se insertó el registro.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
		ELSE
			BEGIN
				SELECT @VP_K_FOLIO=SCOPE_IDENTITY()

				IF @VP_K_FOLIO=NULL
				BEGIN
					--SET @VP_MENSAJE='The IDENTITY assign value was failed.'
					SET @VP_MENSAJE='Error en la asignación de IDENTIDAD.'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
			END

	IF (SELECT	COUNT(K_FOLIO)		FROM	INVENTARIO	(NOLOCK) WHERE	K_FOLIO = @VP_K_FOLIO) > 0
	BEGIN
		SET @VP_MENSAJE='El folio ya se encuentra asignado, y no puede duplicarse... Verifique [' +CONVERT(VARCHAR(10),@VP_K_FOLIO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END

	SET @PP_K_FOLIO_INSERTADO=@VP_K_FOLIO
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT	PARA EL LOG POR REGISTRO
-- //	SE REALIZA DESDE QUE EL MATERIAL INGRESA A INVENTARIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]
GO

CREATE PROCEDURE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INVENTARIO						[INT] ,
	@PP_K_ITEM								[INT] ,
	@PP_K_INVENTARIO_MOVIMIENTO_TIPO		[INT] ,
	@PP_LOTE_PEARL							[INT] ,
	@PP_SERIE_NO							[VARCHAR](50),
	-- ============================	
	@PP_K_LOCACION_ORIGEN					[INT] ,
	@PP_K_FOLIO_ORIGEN						[INT] ,
	@PP_K_ORDEN_TRABAJO_ORIGEN				[INT] ,
	-- ============================	
	@PP_K_LOCACION_DESTINO					[INT] ,
	@PP_K_FOLIO_DESTINO						[INT] ,
	@PP_K_ORDEN_TRABAJO_DESTINO				[INT] ,
	-- ============================	
	@PP_CANTIDAD_MOVIMIENTO					[DECIMAL] (19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
-- /////////////////////////////////////////////////////////////////////
--============================================================================
	INSERT INTO INVENTARIO_MOVIMIENTO_X_REGISTRO
		(	[K_INVENTARIO]					,[K_ITEM]									
			,[K_INVENTARIO_MOVIMIENTO_TIPO]	,[LOTE_PEARL]
			,[SERIE_NO]
			-- ============================	
			,[K_LOCACION_ORIGEN]			,[K_FOLIO_ORIGEN]								
			,[K_ORDEN_TRABAJO_ORIGEN]						
			-- ============================	
			,[K_LOCACION_DESTINO]			,[K_FOLIO_DESTINO]								
			,[K_ORDEN_TRABAJO_DESTINO]						
			-- ============================	
			,[CANTIDAD_MOVIMIENTO]
			-- ===========================
			,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
			[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
	VALUES	
		(	@PP_K_INVENTARIO						,@PP_K_ITEM								
			,@PP_K_INVENTARIO_MOVIMIENTO_TIPO		,@PP_LOTE_PEARL	
			,@PP_SERIE_NO						
			-- ============================	
			,@PP_K_LOCACION_ORIGEN					,@PP_K_FOLIO_ORIGEN						
			,@PP_K_ORDEN_TRABAJO_ORIGEN				
			-- ============================	
			,@PP_K_LOCACION_DESTINO					,@PP_K_FOLIO_DESTINO						
			,@PP_K_ORDEN_TRABAJO_DESTINO				
			-- ============================	
			,@PP_CANTIDAD_MOVIMIENTO				
			-- ============================
			,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
			0, NULL, NULL  )

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El movimiento x registro no fue insertado...Verifique ['+CONVERT(VARCHAR(10),@PP_K_INVENTARIO)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT	PARA EL LOG POR REGISTRO
-- //	SE REALIZA DESDE QUE EL MATERIAL INGRESA A INVENTARIO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]
GO

CREATE PROCEDURE [dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO				[VARCHAR](50),
	@PP_K_ITEM								[INT],
	@PP_LOTE_PEARL							[INT],
	@PP_K_ENTREGA							[INT],
	@PP_K_LOCACION_ORIGEN					[INT],
	@PP_K_FOLIO_ORIGEN						[INT],
	@PP_K_ORDEN_TRABAJO_ORIGEN				[INT],
	@PP_K_LOCACION_DESTINO					[INT],
	@PP_K_FOLIO_DESTINO						[INT],
	@PP_K_ORDEN_TRABAJO_DESTINO				[INT],
	@PP_K_INVENTARIO_MOVIMIENTO_TIPO		[INT]
AS			
-- /////////////////////////////////////////////////////////////////////
	DECLARE	 @VP_CU_K_INVENTARIO					INT
			,@VP_CU_CANTIDAD_MOVIMIENTO				DECIMAL (19,4)
			,@VP_CU_SERIE_NO						VARCHAR (50)
	
	DECLARE CU_OBTENER_REGISTROS			CURSOR LOCAL FOR
		SELECT	K_INVENTARIO	,CANTIDAD_RECIBIDA		,SERIE_NO
		FROM	INVENTARIO		(NOLOCK) 
		WHERE	K_ITEM					= @PP_K_ITEM
		AND		LOTE_PEARL				= @PP_LOTE_PEARL
		AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
		AND		K_ENTREGA				= @PP_K_ENTREGA
		AND		INVENTARIO.L_BORRADO<>1
		AND		K_INVENTARIO IN (
							SELECT	K_INVENTARIO
							FROM	INVENTARIO	(NOLOCK)  
							INNER JOIN FOLIO	(NOLOCK)  ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
							WHERE	K_ITEM					=@PP_K_ITEM
							AND		K_LOCACION				=@PP_K_LOCACION_ORIGEN
							AND		LOTE_PEARL				=@PP_LOTE_PEARL
							--AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
							AND		K_ENTREGA				=@PP_K_ENTREGA
							AND		INVENTARIO.L_BORRADO<>1				)
	
	OPEN	CU_OBTENER_REGISTROS
		FETCH NEXT FROM CU_OBTENER_REGISTROS INTO @VP_CU_K_INVENTARIO	,@VP_CU_CANTIDAD_MOVIMIENTO	,@VP_CU_SERIE_NO
		WHILE @@FETCH_STATUS = 0
		BEGIN	
		
			--============================================================================
			EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														-- ===========================
														,@VP_CU_K_INVENTARIO				,@PP_K_ITEM						
														,@PP_K_INVENTARIO_MOVIMIENTO_TIPO	,@PP_LOTE_PEARL
														,@VP_CU_SERIE_NO
														-- ============================	
														,@PP_K_LOCACION_ORIGEN			,@PP_K_FOLIO_ORIGEN
														,@PP_K_ORDEN_TRABAJO_ORIGEN
														-- ============================	
														,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
														,@PP_K_ORDEN_TRABAJO_DESTINO
														-- ============================	
														,@VP_CU_CANTIDAD_MOVIMIENTO			
				
		--==============================================================
		FETCH NEXT FROM CU_OBTENER_REGISTROS INTO @VP_CU_K_INVENTARIO	,@VP_CU_CANTIDAD_MOVIMIENTO	,@VP_CU_SERIE_NO
		END
	CLOSE		CU_OBTENER_REGISTROS
	DEALLOCATE	CU_OBTENER_REGISTROS		
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT	SE MANDA LAMAR DESDE RECIBO_BPO
-- //	INSERTA UN REGISTRO EN LA TABLA INVENTARIO, DESPUES DE RECIBIR MATERIAL 
-- //	DE UNA ORDEN DE COMPRA DE BPO_PEDIDO
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
	@PP_SERIE_NO							[VARCHAR](50),
	@PP_LOTE_VENDOR							[VARCHAR](50),
	@PP_LOTE_PEARL							[INT],
	@PP_LOTE_NUMERO_CONSECUTIVO				[INT],
	@PP_ENTREGA_NO							[INT],
	-- ===========================
	@PP_F_DATE_INVENTARIO					[DATE],
	@PP_C_INVENTARIO						[VARCHAR](255),
	-- ============================
	@PP_CANTIDAD_RECIBIDA					[DECIMAL](19,4)
AS			
	DECLARE @VP_MENSAJE						VARCHAR(500) = ''
			,@VP_K_FOLIO					INT		-- ES UNA VARIABLE DE RETORNO, PARA ASIGNAR EL FOLIO INSERTADO.
			,@VP_K_LOTE						INT		-- PARA VERIFICAR EL LOTE
			,@VP_EXISTE_SERIE				INT		-- PARA VERIFICAR QUE NO EXISTA LA SERIE
			,@VP_K_INVENTARIO				INT		-- PARA OBTENER EL VALOR DEL ID INSERTADO
	
	IF (	SELECT	COUNT(SERIE_NO)
			FROM	INVENTARIO		(NOLOCK)
			WHERE	K_ITEM				= @PP_K_ITEM
			AND		LOTE_VENDOR			= @PP_LOTE_VENDOR
			AND		SERIE_NO			= @PP_SERIE_NO
			AND		INVENTARIO.L_BORRADO <> 1		)	>0	
	BEGIN
		SET @VP_MENSAJE='La serie ['+ @PP_SERIE_NO	+'] ya fue ingresada.'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	-- /////////////////////////////////////////////////////////////////////	
	--	PRIMERO BUSCAR EN INVENTARIO SI HAY UN K_LOCACION=4 Y TIPO 'B' ASIGNADO AL ITEM
	SET @VP_K_FOLIO= ISNULL(	(SELECT TOP(1)
										INVENTARIO.K_FOLIO
								FROM	INVENTARIO	(NOLOCK)  
								INNER JOIN FOLIO	(NOLOCK) ON	INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
								WHERE	K_ITEM			= @PP_K_ITEM
								AND		K_LOCACION		= 4		--	4=MHI	/		107= RW0
								AND		TIPO			= 'B'
								AND		INVENTARIO.L_BORRADO<>1
								ORDER BY K_FOLIO DESC),0)

		-- SI NO SE ENCUENTRA EL FOLIO SE LE ASIGNA UNO NUEVO.
		IF @VP_K_FOLIO=0
		BEGIN

			--	SE BUSCA LA EXISTENCIA DEL FOLIO BASE PARA EL ITEM.			
			SELECT	@VP_K_FOLIO		= K_FOLIO
			FROM	FOLIO			(NOLOCK) 
			WHERE	K_ITEM_BASE		= @PP_K_ITEM

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

					UPDATE	FOLIO
					SET		K_ITEM_BASE	= @PP_K_ITEM
					WHERE	K_FOLIO		= @VP_K_FOLIO
					
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El folio de Almacen no fue asignado, [' + CONVERT(VARCHAR(50),@VP_K_FOLIO) + ']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END				
				END
		END
	-- /////////////////////////////////////////////////////////////////////
	--	EL ID SE ASIGNA POR IDENTITY, OBTENER EL RESULTADO DE LA OPERACIÓN EN CASO DE REQUERIRLO.
	-- //////////////////////////////////////////////////////////////
	--============================================================================
	--======================================INSERTAR EL INVENTARIO
	--============================================================================
		INSERT INTO INVENTARIO
			(	[K_ITEM]					,[K_FOLIO]					
				-- =========================
				,[K_CLASIFICACION]			,[K_STATUS_INVENTARIO]		
				-- =========================
				,[K_ORDEN_COMPRA_PEDIDO]	,[K_DETAILS_BPO_RECIBO]
				,[K_ENTREGA]
				-- =========================
				,[SERIE_NO]					,[LOTE_VENDOR]
				,[LOTE_PEARL]				,[LOTE_NUMERO_CONSECUTIVO]
				-- =========================
				,[F_DATE_INVENTARIO]		,[C_INVENTARIO]				
				-- =========================
				,[CANTIDAD_RECIBIDA]						
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_ITEM					,@VP_K_FOLIO					
				-- =========================
				,@PP_K_CLASIFICACION		,@PP_K_STATUS_INVENTARIO		
				-- =========================
				,@PP_K_ORDEN_COMPRA_PEDIDO	,@PP_K_DETAILS_BPO_RECIBO
				,@PP_ENTREGA_NO
				-- =========================
				,@PP_SERIE_NO				,@PP_LOTE_VENDOR				
				,@PP_LOTE_PEARL				,@PP_LOTE_NUMERO_CONSECUTIVO	
				-- =========================
				,@PP_F_DATE_INVENTARIO		,@PP_C_INVENTARIO			
				-- =========================
				,@PP_CANTIDAD_RECIBIDA
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El registro no fue Insertado.'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END				
			ELSE
				BEGIN
					SELECT @VP_K_INVENTARIO=SCOPE_IDENTITY()

					IF @VP_K_INVENTARIO=NULL
					BEGIN
						--SET @VP_MENSAJE='The IDENTITY assign value was failed.'
						SET @VP_MENSAJE='Error en la asignación de IDENTIDAD [INV].'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
				END
	
	-- /////////////////////////////////////////////////////////////////////
	--	INSERTAR LOS MOVIMIENTOS POR REGISTRO
	-- //////////////////////////////////////////////////////////////	
	EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												-- ===========================
												,@VP_K_INVENTARIO					,@PP_K_ITEM						
												,5									,@PP_LOTE_PEARL
												,@PP_SERIE_NO
												-- ============================	
												,0									,0					--	K_LOCACION_ORIGEN	,K_FOLIO_ORIGEN
												,0														--	K_ORDEN_TRABAJO_ORIGEN
												-- ============================	
												,4									,@VP_K_FOLIO		--	K_LOCACION_ORIGEN	,K_FOLIO_ORIGEN
												,0														--	K_ORDEN_TRABAJO_ORIGEN
												-- ============================	
												,@PP_CANTIDAD_RECIBIDA			
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE LOCACIÓN
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_LOCACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LOCACION_DESTINO			[INT],
	@PP_K_ITEM						[INT],
	-- ===========================
	@PP_LOTE_PEARL					[INT],
	-- ===========================
	@PP_QTY_MOVIMIENTO				[DECIMAL](19,4)
AS
DECLARE @VP_MENSAJE					VARCHAR(500) = ''
--============================================================================
--======================================INSERTAR EL INVENTARIO_LOCACION
--============================================================================
	INSERT INTO INVENTARIO_LOCACION
		(	[K_LOCACION]
			,[K_ITEM]
			-- =========================
			,[LOTE_PEARL]
			-- =========================
			,[CANTIDAD_DISPONIBLE]
			-- ===========================
			,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
			[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
	VALUES	
		(	@PP_K_LOCACION_DESTINO
			,@PP_K_ITEM
			-- =========================	
			,@PP_LOTE_PEARL				
			-- =========================
			,@PP_QTY_MOVIMIENTO
			-- ============================
			,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
			0, NULL, NULL  )

		IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El movimiento locación no fue insertado.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE LOCACIÓN
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_UP_INVENTARIO_LOCACION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LOCACION					[INT],		
	@PP_K_ITEM						[INT],
	-- ===========================
	@PP_LOTE_PEARL					[INT],
	-- ===========================
	@PP_QTY_MOVIMIENTO				[DECIMAL](19,4),
	@PP_SUMA_O_RESTA				[VARCHAR](50)
AS
DECLARE @VP_MENSAJE					VARCHAR(500) = ''
--============================================================================
--======================================ACTUALIZAR EL INVENTARIO_LOCACION
--============================================================================
	IF @PP_SUMA_O_RESTA='SUMAR'
	BEGIN
			UPDATE	INVENTARIO_LOCACION
			SET		
					CANTIDAD_DISPONIBLE	=(CANTIDAD_DISPONIBLE +		@PP_QTY_MOVIMIENTO	)
					,K_USUARIO_CAMBIO	= @PP_K_USUARIO_ACCION
					,F_CAMBIO			= GETDATE()
			WHERE	K_ITEM		=@PP_K_ITEM	
			AND		K_LOCACION	=@PP_K_LOCACION
			AND		LOTE_PEARL	=@PP_LOTE_PEARL

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El movimiento locación no fue actualizado.[SUM# '+CONVERT(VARCHAR(10),@PP_K_LOCACION)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
	END
	ELSE IF @PP_SUMA_O_RESTA='RESTAR'
	BEGIN
			UPDATE	INVENTARIO_LOCACION
			SET		
					CANTIDAD_DISPONIBLE=(CANTIDAD_DISPONIBLE-@PP_QTY_MOVIMIENTO)
					,K_USUARIO_CAMBIO	= @PP_K_USUARIO_ACCION
					,F_CAMBIO			= GETDATE()
			WHERE	K_ITEM		=@PP_K_ITEM	
			AND		K_LOCACION	=@PP_K_LOCACION
			AND		LOTE_PEARL	=@PP_LOTE_PEARL
			
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El movimiento locación no fue actualizado.[RST# '+CONVERT(VARCHAR(10),@PP_K_LOCACION)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END


			IF	(	SELECT	CANTIDAD_DISPONIBLE
					FROM	INVENTARIO_LOCACION		(NOLOCK) 
					WHERE	K_ITEM					= @PP_K_ITEM	
					AND		K_LOCACION				= @PP_K_LOCACION
					AND		LOTE_PEARL				= @PP_LOTE_PEARL	)		<	0
			BEGIN
				SET @VP_MENSAJE='La cantidad disponible no puede ser menor a 0.[RST# '+CONVERT(VARCHAR(10),@PP_K_LOCACION)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
	END
-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MOVIMIENTO_INVENTARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]
GO

CREATE PROCEDURE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO			VARCHAR(50),
	@PP_K_ENTREGA						INT,
	@PP_K_ITEM							INT,
	@PP_LOTE_PEARL						INT,
	-- ===========================
	@PP_K_LOCACION_ORIGEN				INT,
	@PP_K_FOLIO_ORIGEN					INT,
	@PP_K_ORDEN_ORIGEN					INT,
	-- ===========================
	@PP_K_LOCACION_DESTINO				INT,
	@PP_K_FOLIO_DESTINO					INT,
	@PP_K_ORDEN_DESTINO					INT,
	-- ===========================
	@PP_QTY_MOVIMIENTO					DECIMAL(19,4),
	@PP_K_INVENTARIO_MOVIMIENTO_TIPO	INT
AS			
DECLARE @VP_MENSAJE					VARCHAR(500) = ''
		,@VP_QTY_ORIGEN				DECIMAL(19,4)
		,@VP_QTY_DESTINO			DECIMAL(19,4)

	IF @PP_K_INVENTARIO_MOVIMIENTO_TIPO NOT IN (5, 10 )
		BEGIN
		SET @VP_QTY_ORIGEN=ISNULL((	SELECT	CANTIDAD_DISPONIBLE
								FROM	INVENTARIO_LOCACION		(NOLOCK) 
								WHERE	K_ITEM					= @PP_K_ITEM	
								AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
								AND		LOTE_PEARL				= @PP_LOTE_PEARL				),0)
		END
	ELSE
		BEGIN
			SET @VP_QTY_ORIGEN=0
		END

	SET @VP_QTY_DESTINO=ISNULL((	SELECT	CANTIDAD_DISPONIBLE
							FROM	INVENTARIO_LOCACION		(NOLOCK) 
							WHERE	K_ITEM					= @PP_K_ITEM	
							AND		K_LOCACION				= @PP_K_LOCACION_DESTINO
							AND		LOTE_PEARL				= @PP_LOTE_PEARL				),0)
													
	--==============================================
	--	REALIZA EL INSERT EN LA TABLA DE INVENTARIO_MOVIMIENTO
	--==============================================				
		--============================================================================
		--======================================INSERTAR EL MOVIMIENTO_INVENTARIO
		--============================================================================
		INSERT INTO INVENTARIO_MOVIMIENTO
			(	[K_LOCACION_ORIGEN]	
				,[K_LOCACION_DESTINO]
				,[K_INVENTARIO_MOVIMIENTO_TIPO]
				-- =========================
				,[K_ITEM]
				,[LOTE_PEARL]				
				-- =========================
				,[CANTIDAD_MOVIMIENTO]
				,[CANTIDAD_ORIGEN]
				,[CANTIDAD_DESTINO]
				-- ===========================
				,[K_FOLIO_ORIGEN]
				,[K_ORDEN_TRABAJO_ORIGEN]
				,[K_FOLIO_DESTINO]
				,[K_ORDEN_TRABAJO_DESTINO]
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_LOCACION_ORIGEN						--	DEBE SER # 107=	RW0
				,@PP_K_LOCACION_DESTINO						--	PUEDE SER MHI (4) / MQU (6)
				,@PP_K_INVENTARIO_MOVIMIENTO_TIPO			--	@PP_K_INVENTARIO_MOVIMIENTO_TIPO	= 'ENTRADA X LIBERACION'
				-- =========================	
				,@PP_K_ITEM
				,@PP_LOTE_PEARL				
				-- =========================
				,@PP_QTY_MOVIMIENTO
				,@VP_QTY_ORIGEN
				,@VP_QTY_DESTINO
				-- ============================
				,@PP_K_FOLIO_ORIGEN	
				,@PP_K_ORDEN_ORIGEN	
				-- ==================
				,@PP_K_FOLIO_DESTINO	
				,@PP_K_ORDEN_DESTINO	
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='[TRX] no insertada.'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END				
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VERIFICAR MAXIMOS MINIMOS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_MIN_MAX_X_ITEM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_MIN_MAX_X_ITEM]
GO

CREATE PROCEDURE [dbo].[PG_SK_MIN_MAX_X_ITEM]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ITEM						[INT]
AS	
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_MAX_MIN_X_ITEM			DECIMAL(19,4)

IF @PP_K_SISTEMA_EXE = 0
BEGIN
	SET	@VP_MAX_MIN_X_ITEM			= ISNULL((	SELECT	CANTIDAD_MINIMA
												FROM	COMPRAS_Pruebas.dbo.ITEM	(NOLOCK) 
												WHERE	K_ITEM=@PP_K_ITEM	),-1)
END
ELSE
BEGIN
	SET	@VP_MAX_MIN_X_ITEM			= ISNULL((	SELECT	CANTIDAD_MINIMA
												FROM	COMPRAS.dbo.ITEM		(NOLOCK) 
												WHERE	K_ITEM					= @PP_K_ITEM	),-1)
END
	
	IF @VP_MAX_MIN_X_ITEM<=0
	BEGIN
		SET @VP_MENSAJE='El [ITEM] #'+CONVERT(VARCHAR(10),@PP_K_ITEM)+ ', no tiene un registro de Mínimos/Máximos en el sistema. Verificar...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VERIFICAR QUE NO SE TENGAN SELECCIONADOS 
-- //	DOS FOLIOS EN UNA MISMA RECEPCIÓN DE MATERIAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_FOLIO_NO_DOBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_FOLIO_NO_DOBLE]
GO

CREATE PROCEDURE [dbo].[PG_SK_FOLIO_NO_DOBLE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT]
AS	
	DECLARE @VP_MENSAJE		VARCHAR(500) = ''
	IF	(		SELECT	COUNT(DISTINCT(INVENTARIO.K_FOLIO))
				FROM	INVENTARIO			(NOLOCK) 
				WHERE	K_ITEM					= @PP_K_ITEM
				AND		LOTE_PEARL				= @PP_LOTE_PEARL
				AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
				AND		K_ENTREGA				= @PP_K_ENTREGA
				AND		INVENTARIO.L_BORRADO<>1									)	>	1
	BEGIN
		SET @VP_MENSAJE='Dos o más Folios seleccionados.'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END				
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZAR EL ESTATUS A INSPECCIONADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_STATUS_INVENTARIO_INSPECCION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_STATUS_INVENTARIO_INSPECCION]
GO

CREATE PROCEDURE [dbo].[PG_UP_STATUS_INVENTARIO_INSPECCION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT]
AS	
DECLARE @VP_MENSAJE		VARCHAR(500)=''
	-- SE ACTUALIZA EL ESTATUS DE LA TABLA INVENTARIO DEL MATERIAL QUE HA SIDO INSPECCIONADO.
	-- ESTATUS INVENTARIO:		#00 SIN DEFINIR	/	#10 PREREGISTRADO	/	#20 INSPECCIONADO
	DECLARE @VP_ESTATUS_ACTUAL	INT

		SELECT	@VP_ESTATUS_ACTUAL=K_STATUS_INVENTARIO
		FROM	INVENTARIO			(NOLOCK) 
		WHERE	K_ITEM					= @PP_K_ITEM
		AND		LOTE_PEARL				= @PP_LOTE_PEARL
		AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
		AND		K_ENTREGA				= @PP_K_ENTREGA
		AND		INVENTARIO.L_BORRADO<>1

	IF @VP_ESTATUS_ACTUAL IS NULL
	BEGIN
		SET @VP_MENSAJE='El registro no fue encontrado.'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	ELSE IF @VP_ESTATUS_ACTUAL<> 10
	BEGIN
		SET @VP_MENSAJE='El registro no puede ser modificado.'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	ELSE
	BEGIN
		UPDATE INVENTARIO
		SET		
				K_STATUS_INVENTARIO=20
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		INVENTARIO.L_BORRADO<>1

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El movimiento no fue modificado.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
	END

GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- //	PARA LOS REGISTROS QUE VAN PARA MHI (4)
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MOVIMIENTO_A_MHI]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MOVIMIENTO_A_MHI]
GO
--		 EXECUTE [dbo].[PG_IN_MOVIMIENTO_A_MHI] 0,139, 1,1,70,40001,4,4
CREATE PROCEDURE [dbo].[PG_IN_MOVIMIENTO_A_MHI]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],
	@PP_K_LOCACION_DESTINO			[INT]
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)
--=====================================================================================================================================
			-- OBTENER EL FOLIO Y LA ORDEN DE TRABAJO PARA LAS TABLAS DE LOGS
			DECLARE @VP_K_FOLIO					INT = -1
					,@VP_K_ORDEN_TRABAJO		INT
			
			SELECT	TOP(1)
					@VP_K_FOLIO=(INVENTARIO.K_FOLIO)
					,@VP_K_ORDEN_TRABAJO=K_ORDEN_TRABAJO
			FROM	INVENTARIO		(NOLOCK)  
			INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
			WHERE	K_ITEM					= @PP_K_ITEM
			AND		LOTE_PEARL				= @PP_LOTE_PEARL
			AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
			AND		K_ENTREGA				= @PP_K_ENTREGA
			AND		INVENTARIO.L_BORRADO<>1
			ORDER BY INVENTARIO.K_FOLIO DESC
--=====================================================================================================================================
	--==================================================================================
	--		OBTENEMOS EL TOTAL EN LA TABLA INVENTARIO_LOCACION
	--==================================================================================
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO, QUE ES EL ORIGEN PARA TODOS LOS REGISTROS QUE SE ESTÁN INSPECCIONANDO.
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	SUM(CANTIDAD_RECIBIDA)
									FROM	INVENTARIO		(NOLOCK) 
									WHERE	K_ITEM					= @PP_K_ITEM 
									AND		LOTE_PEARL				= @PP_LOTE_PEARL
									AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
									AND		K_ENTREGA				= @PP_K_ENTREGA
									AND		K_STATUS_INVENTARIO		= 10	
									AND		INVENTARIO.L_BORRADO<>1		)

			IF (@VP_QTY_MOVIMIENTO IS NULL) OR (@VP_QTY_MOVIMIENTO=0)
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
--=====================================================================================================================================
--=====================================================================================================================================
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,4								,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO
												,@VP_QTY_MOVIMIENTO	
												,10

		EXECUTE [dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
															,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ITEM						
															,@PP_LOTE_PEARL					,@PP_K_ENTREGA				
															,4								,@VP_K_FOLIO	-- LOCACIÓN ORIGEN SIEMPRE ES MHI
															,@VP_K_ORDEN_TRABAJO
															,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO	-- DESTINO
															,@VP_K_ORDEN_TRABAJO
															,10	--@PP_K_INVENTARIO_MOVIMIENTO_TIPO
--=====================================================================================================================================
--=====================================================================================================================================
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION		(NOLOCK) 
									WHERE	K_ITEM					= @PP_K_ITEM
									AND		K_LOCACION				= @PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL				= @PP_LOTE_PEARL )
		
		--==============================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL 
		--	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==============================================				
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
	
--=====================================================================================================================================
--=====================================================================================================================================	
	-- SE ACTUALIZA EL ESTATUS DE LA TABLA INVENTARIO DEL MATERIAL QUE HA SIDO INSPECCIONADO.
	EXECUTE [dbo].[PG_UP_STATUS_INVENTARIO_INSPECCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														-- ===========================
														,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA			
														,@PP_K_ITEM						,@PP_LOTE_PEARL

	-- VERIFICA QUE NO VENGAN DOS FOLIOS POR LOTE
	EXECUTE [dbo].[PG_SK_FOLIO_NO_DOBLE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
											-- ===========================
											,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA			
											,@PP_K_ITEM						,@PP_LOTE_PEARL
-- //////////////////////////////////////////////////////////////
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- //	PARA LOS REGISTROS QUE VAN PARA MQU (6)
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MOVIMIENTO_A_MQU]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MOVIMIENTO_A_MQU]
GO

CREATE PROCEDURE [dbo].[PG_IN_MOVIMIENTO_A_MQU]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],
	@PP_K_LOCACION_DESTINO			[INT]
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
			,@VP_K_FOLIO				INT
			,@VP_EXISTE_LOCACION		INT
			,@VP_QTY_MOVIMIENTO			DECIMAL(19,4)

			,@VP_K_FOLIO_ORIGEN			INT
			,@VP_K_ORDEN_TRABAJO_ORIGEN	INT
--=====================================================================================================================================
	--	SE OBTIENEN LOS DATOS PARA EL LOG DE MOVIMIENTOS X REGISTRO
	SELECT	TOP(1)
			@VP_K_FOLIO_ORIGEN			=INVENTARIO.K_FOLIO,
			@VP_K_ORDEN_TRABAJO_ORIGEN	=K_ORDEN_TRABAJO
	FROM	INVENTARIO		(NOLOCK)  
	INNER JOIN FOLIO		(NOLOCK)  ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					= @PP_K_ITEM 
	AND		K_LOCACION				= 4		-- LOC_ORIGEN SIEMPRE ES MHI
	AND		LOTE_PEARL				= @PP_LOTE_PEARL
	AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
	AND		K_ENTREGA				= @PP_K_ENTREGA
	AND		K_STATUS_INVENTARIO		= 10
	AND		INVENTARIO.L_BORRADO<>1
	ORDER BY INVENTARIO.K_FOLIO		DESC
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
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO	= K_ORDEN_TRABAJO
		FROM	FOLIO		(NOLOCK) 
		WHERE	K_FOLIO		= @VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	--==================================================================================
	--		OBTENEMOS EL TOTAL EN LA TABLA INVENTARIO_LOCACION
	--==================================================================================
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO, QUE ES EL ORIGEN PARA TODOS LOS REGISTROS QUE SE ESTÁN INSPECCIONANDO.
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	SUM(CANTIDAD_RECIBIDA)
									FROM	INVENTARIO		(NOLOCK) 
									WHERE	K_ITEM					= @PP_K_ITEM 
									AND		LOTE_PEARL				= @PP_LOTE_PEARL
									AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
									AND		K_ENTREGA				= @PP_K_ENTREGA
									AND		K_STATUS_INVENTARIO		= 10	
									AND		INVENTARIO.L_BORRADO<>1		)

									
			IF (@VP_QTY_MOVIMIENTO IS NULL) OR (@VP_QTY_MOVIMIENTO=0)
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,4								,@VP_K_FOLIO_ORIGEN
												,@VP_K_ORDEN_TRABAJO_ORIGEN
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												,@VP_QTY_MOVIMIENTO	
												,10

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
															,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ITEM						
															,@PP_LOTE_PEARL					,@PP_K_ENTREGA				
															,4								,@VP_K_FOLIO_ORIGEN		-- LOCACIÓN ORIGEN SIEMPRE ES MHI
															,@VP_K_ORDEN_TRABAJO_ORIGEN
															,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
															,@VP_K_ORDEN_TRABAJO_DESTINO
															,10	--@PP_K_INVENTARIO_MOVIMIENTO_TIPO
--=====================================================================================================================================
--=====================================================================================================================================
		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION		(NOLOCK) 
									WHERE	K_ITEM				= @PP_K_ITEM	
									AND		K_LOCACION			= @PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL			= @PP_LOTE_PEARL			)
		
		--==============================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL 
		--	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==============================================				
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
--=====================================================================================================================================
	UPDATE	INVENTARIO
	SET		
			K_FOLIO=@VP_K_FOLIO
	WHERE	K_ITEM					=@PP_K_ITEM
	AND		LOTE_PEARL				=@PP_LOTE_PEARL
	AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
	AND		K_ENTREGA				=@PP_K_ENTREGA
	AND		K_STATUS_INVENTARIO =	10	
	AND		INVENTARIO.L_BORRADO<>1

	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='El Folio no puede ser actualizado...Verificar'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
--=====================================================================================================================================	
	-- SE ACTUALIZA EL ESTATUS DE LA TABLA INVENTARIO DEL MATERIAL QUE HA SIDO INSPECCIONADO.
	EXECUTE [dbo].[PG_UP_STATUS_INVENTARIO_INSPECCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														-- ===========================
														,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA			
														,@PP_K_ITEM						,@PP_LOTE_PEARL

	-- VERIFICA QUE NO VENGAN DOS FOLIOS POR LOTE
	EXECUTE [dbo].[PG_SK_FOLIO_NO_DOBLE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
											-- ===========================
											,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA			
											,@PP_K_ITEM						,@PP_LOTE_PEARL
-- //////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MOVIMIENTO_MQU_A_MHI]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MOVIMIENTO_MQU_A_MHI]
GO

CREATE PROCEDURE [dbo].[PG_IN_MOVIMIENTO_MQU_A_MHI]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],
	@PP_K_LOCACION_DESTINO			[INT]
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
	FROM	INVENTARIO		(NOLOCK) 
	INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					= @PP_K_ITEM 
	AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				= @PP_LOTE_PEARL
	AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
	AND		K_ENTREGA				= @PP_K_ENTREGA
	AND		K_STATUS_INVENTARIO		= 20
	AND		INVENTARIO.L_BORRADO<>1
--=====================================================================================================================================
	--====		SE VERIFICA QUE EXISTA UN FOLIO BASE PARA EL MATERIAL
	--			PRIMERO BUSCAR EN INVENTARIO SI HAY UN K_LOCACION=4 Y TIPO 'B' ASIGNADO AL ITEM
	SET @VP_K_FOLIO= ISNULL(	(SELECT TOP(1)	--*,
										INVENTARIO.K_FOLIO
								FROM	INVENTARIO		(NOLOCK) 
								INNER JOIN FOLIO		(NOLOCK) ON	INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
								WHERE	K_ITEM		= @PP_K_ITEM
								AND		K_LOCACION	= 4		--	4=MHI	/		107= RW0
								AND		TIPO		= 'B'
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
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO	= K_ORDEN_TRABAJO
		FROM	FOLIO		(NOLOCK) 
		WHERE	K_FOLIO		= @VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	SUM(CANTIDAD_RECIBIDA)
									FROM	INVENTARIO		(NOLOCK)  
									WHERE	K_ITEM					= @PP_K_ITEM 
									AND		LOTE_PEARL				= @PP_LOTE_PEARL
									AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
									AND		K_ENTREGA				= @PP_K_ENTREGA
									AND		K_STATUS_INVENTARIO		= 20
									AND		INVENTARIO.L_BORRADO<>1						
									AND		K_INVENTARIO IN (
																SELECT	K_INVENTARIO
																FROM	INVENTARIO		(NOLOCK) 
																INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
																WHERE	K_ITEM					= @PP_K_ITEM
																AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
																AND		LOTE_PEARL				= @PP_LOTE_PEARL
																AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
																AND		K_ENTREGA				= @PP_K_ENTREGA
																AND		K_STATUS_INVENTARIO		= 20
																AND		INVENTARIO.L_BORRADO<>1				)									
									)

			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
--=====================================================================================================================================
		--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
		EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
												,@PP_K_ITEM						,@PP_LOTE_PEARL
												,@PP_K_LOCACION_ORIGEN								,@VP_K_FOLIO_ORIGEN
												,@VP_K_ORDEN_TRABAJO_ORIGEN
												,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
												,@VP_K_ORDEN_TRABAJO_DESTINO
												,@VP_QTY_MOVIMIENTO	
												,20


		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
															,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ITEM						
															,@PP_LOTE_PEARL					,@PP_K_ENTREGA				
															,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
															,@VP_K_ORDEN_TRABAJO_ORIGEN
															,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
															,@VP_K_ORDEN_TRABAJO_DESTINO
															,20	--@PP_K_INVENTARIO_MOVIMIENTO_TIPO

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
		AND		K_INVENTARIO IN	(
									SELECT	K_INVENTARIO
									FROM	INVENTARIO		(NOLOCK) 
									INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
									WHERE	K_ITEM					= @PP_K_ITEM
									AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
									AND		LOTE_PEARL				= @PP_LOTE_PEARL
									AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
									AND		K_ENTREGA				= @PP_K_ENTREGA
									AND		K_STATUS_INVENTARIO		= 20
									AND		INVENTARIO.L_BORRADO<>1						)

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
									FROM	INVENTARIO_LOCACION		(NOLOCK) 
									WHERE	K_ITEM			= @PP_K_ITEM	
									AND		K_LOCACION		= @PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL		= @PP_LOTE_PEARL			)
		
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
---- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
---- //	DEL MATERIAL QUE SE MUEVE DE MHI A MQU
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_MOVIMIENTO_MHI_A_MQU]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_MOVIMIENTO_MHI_A_MQU]
GO

CREATE PROCEDURE [dbo].[PG_IN_MOVIMIENTO_MHI_A_MQU]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],
	@PP_K_LOCACION_DESTINO			[INT]
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
	FROM	INVENTARIO		(NOLOCK) 
	INNER JOIN FOLIO		(NOLOCK)  ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
	WHERE	K_ITEM					= @PP_K_ITEM 
	AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
	AND		LOTE_PEARL				= @PP_LOTE_PEARL
	AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
	AND		K_ENTREGA				= @PP_K_ENTREGA
	AND		K_STATUS_INVENTARIO		= 20
	AND		INVENTARIO.L_BORRADO<>1
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
		SELECT	@VP_K_ORDEN_TRABAJO_DESTINO	= K_ORDEN_TRABAJO
		FROM	FOLIO		(NOLOCK) 
		WHERE	K_FOLIO		= @VP_K_FOLIO
--=====================================================================================================================================
--=====================================================================================================================================
	---=== OBTENER LAS CANTIDADES PARA LOS MOVIMIENTOS
		--==============================================
		--	SE OBTIENEN LAS CANTIDADES DE LA TABLA DE INVENTARIO
		--==============================================
		SET @VP_QTY_MOVIMIENTO=	(	SELECT	SUM(CANTIDAD_RECIBIDA)
									FROM	INVENTARIO		(NOLOCK)  
									WHERE	K_ITEM					= @PP_K_ITEM
									AND		LOTE_PEARL				= @PP_LOTE_PEARL
									AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
									AND		K_ENTREGA				= @PP_K_ENTREGA
									AND		K_STATUS_INVENTARIO		= 20
									AND		INVENTARIO.L_BORRADO<>1
									AND		K_INVENTARIO IN (
																SELECT	K_INVENTARIO
																FROM	INVENTARIO		(NOLOCK) 
																INNER JOIN FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
																WHERE	K_ITEM					= @PP_K_ITEM
																AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
																AND		LOTE_PEARL				= @PP_LOTE_PEARL
																AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
																AND		K_ENTREGA				= @PP_K_ENTREGA
																AND		K_STATUS_INVENTARIO		= 20
																AND		INVENTARIO.L_BORRADO<>1				)									
									)

			IF @VP_QTY_MOVIMIENTO IS NULL OR @VP_QTY_MOVIMIENTO=0
			BEGIN
				SET @VP_MENSAJE='La cantidad movimiento no pude ser nula o menor a 0.'
				RAISERROR (@VP_MENSAJE, 16, 1 )
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
												,20

		--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
		EXECUTE [dbo].[PG_IN_CURSOR_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
															,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ITEM						
															,@PP_LOTE_PEARL					,@PP_K_ENTREGA				
															,@PP_K_LOCACION_ORIGEN			,@VP_K_FOLIO_ORIGEN
															,@VP_K_ORDEN_TRABAJO_ORIGEN
															,@PP_K_LOCACION_DESTINO			,@VP_K_FOLIO
															,@VP_K_ORDEN_TRABAJO_DESTINO
															,20	--@PP_K_INVENTARIO_MOVIMIENTO_TIPO
--=====================================================================================================================================
		UPDATE	INVENTARIO
		SET		
				K_FOLIO=@VP_K_FOLIO
		WHERE	K_ITEM					=@PP_K_ITEM
		AND		LOTE_PEARL				=@PP_LOTE_PEARL
		AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
		AND		K_ENTREGA				=@PP_K_ENTREGA
		AND		K_STATUS_INVENTARIO		=20
		AND		INVENTARIO.L_BORRADO<>1
		AND		K_INVENTARIO IN (
									SELECT	K_INVENTARIO
									FROM	INVENTARIO		(NOLOCK)  
									INNER JOIN FOLIO		(NOLOCK)  ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
									WHERE	K_ITEM					= @PP_K_ITEM
									AND		K_LOCACION				= @PP_K_LOCACION_ORIGEN
									AND		LOTE_PEARL				= @PP_LOTE_PEARL
									AND		K_ORDEN_COMPRA_PEDIDO	= @PP_K_ORDEN_COMPRA_PEDIDO
									AND		K_ENTREGA				= @PP_K_ENTREGA
									AND		K_STATUS_INVENTARIO		= 20
									AND		INVENTARIO.L_BORRADO<>1				)
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
									FROM	INVENTARIO_LOCACION		(NOLOCK) 
									WHERE	K_ITEM			= @PP_K_ITEM	
									AND		K_LOCACION		= @PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL		= @PP_LOTE_PEARL			)
		
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


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT EN LA TABLA DE MOVIMIENTO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]
GO
--	PRUEBAS1	PARA LA ENTREGA DE HILO.
----	EXECUTE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]	0,139, 4,1,70,40004,0,4			-- DE RECIBO A MHI
----	EXECUTE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]	0,139, 4,2,70,40005,0,4			-- DE RECIBO A MHI

----	EXECUTE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]	0,139, 5,1,70,40006,0,4			-- DE RECIBO A MHI
----	EXECUTE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]	0,139, 5,2,70,40006,0,4			-- DE RECIBO A MHI
----	EXECUTE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]	0,139, 5,3,70,40007,0,4			-- DE RECIBO A MHI
----	EXECUTE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]	0,139, 5,3,70,40006,0,4			-- DE RECIBO A MHI


CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_X_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50),
	@PP_K_ENTREGA					[INT],
	@PP_K_ITEM						[INT],
	@PP_LOTE_PEARL					[INT],
	@PP_K_LOCACION_ORIGEN			[INT],			---===	0-4	/	0-6	/	4-6 OR 6-4
	@PP_K_LOCACION_DESTINO			[INT]			---===
AS			
	DECLARE @VP_MENSAJE					VARCHAR(500) = ''
BEGIN TRANSACTION 
BEGIN TRY
--=====================================================================================================================================
	--==================================================================================
	--		VERIFICAMOS QUE EXISTA LA CANTIDAD MINIMA/MAXIMA ASIGNADA AL K_ITEM
	--==================================================================================
	EXECUTE [PG_SK_MIN_MAX_X_ITEM]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
									,@PP_K_ITEM
	
	--	LOCACIÓN ORIGEN [0], SE RECIBE DESDE LA VENTANA DE INSPECCIÓN.
	IF @PP_K_LOCACION_ORIGEN=0
		BEGIN
			IF @PP_K_LOCACION_DESTINO=4
				BEGIN
					EXECUTE [dbo].[PG_IN_MOVIMIENTO_A_MHI]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
															,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
															,@PP_K_ITEM						,@PP_LOTE_PEARL
															,@PP_K_LOCACION_ORIGEN			,@PP_K_LOCACION_DESTINO
				END
			ELSE IF @PP_K_LOCACION_DESTINO=6
				BEGIN
					EXECUTE [dbo].[PG_IN_MOVIMIENTO_A_MQU]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
															,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
															,@PP_K_ITEM						,@PP_LOTE_PEARL
															,@PP_K_LOCACION_ORIGEN			,@PP_K_LOCACION_DESTINO
				END
			ELSE
				BEGIN
					SET @VP_MENSAJE='Movimiento no permitido desde la locación seleccionada...Verifique'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
		END
	ELSE IF @PP_K_LOCACION_ORIGEN=4
		BEGIN			
				EXECUTE [dbo].[PG_IN_MOVIMIENTO_MHI_A_MQU]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
														,@PP_K_ITEM						,@PP_LOTE_PEARL
														,@PP_K_LOCACION_ORIGEN			,@PP_K_LOCACION_DESTINO
		END
	ELSE IF @PP_K_LOCACION_ORIGEN=6
		BEGIN			
				EXECUTE [dbo].[PG_IN_MOVIMIENTO_MQU_A_MHI]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
														,@PP_K_ORDEN_COMPRA_PEDIDO		,@PP_K_ENTREGA
														,@PP_K_ITEM						,@PP_LOTE_PEARL
														,@PP_K_LOCACION_ORIGEN			,@PP_K_LOCACION_DESTINO
		END
	ELSE
		BEGIN
			SET @VP_MENSAJE='Movimiento no permitido desde la locación seleccionada...Verifique'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

--=====================================================================================================================================
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
		SET		@VP_MENSAJE = 'No es posible [Insertar] el [INVENTARIO_LOCACIÓN]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ITEM AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////


--IF @PP_K_SISTEMA_EXE = 0 
--BEGIN
--	-- //////////////////////////////////////////////////////////////////////////////////////
--	IF	(	SELECT	LTRIM(RTRIM(TRADEMARK_ITEM))
--			FROM	COMPRAS_Pruebas.DBO.ITEM	(NOLOCK)
--			WHERE	K_ITEM	= @PP_K_ITEM		
--		)	<> 'HILO'
--	BEGIN
--			SELECT		DISTINCT
--						-- =============================	
--						INVENTARIO.K_FOLIO
--						,FOLIO.TIPO
--						,( CASE WHEN LOC = 'MHI' THEN	'ALMACEN'
--							ELSE	LOC	END
--						 ) AS	LOC
--						,K_LOCACION
--						,K_ORDEN_TRABAJO AS ORDEN_TRABAJO
--						-- =============================	
--			FROM		INVENTARIO						(NOLOCK) 
--			INNER JOIN	FOLIO							(NOLOCK) ON FOLIO.K_FOLIO=INVENTARIO.K_FOLIO
--			INNER JOIN	COMPRAS_Pruebas.dbo.ITEM		(NOLOCK) ON INVENTARIO.K_ITEM=ITEM.K_ITEM	
--			INNER JOIN	IMLOCFIL_SQL					(NOLOCK) ON FOLIO.K_LOCACION	= IMLOCFIL_SQL.A4GLIdentity
--						-- =============================
--						-- =============================
--			WHERE		INVENTARIO.K_ITEM				= @PP_K_ITEM
--			AND			INVENTARIO.K_STATUS_INVENTARIO	= 20	-- [20]	= INSPECCIONADO
--			AND			INVENTARIO.L_BORRADO			<> 1
--			ORDER BY	K_FOLIO DESC
--	END
--	ELSE
--	BEGIN
--			SELECT		DISTINCT
--						-- =============================	
--						INVENTARIO.K_FOLIO
--						,FOLIO.TIPO
--						,( CASE WHEN LOC = 'MHI' THEN	'ALMACEN'
--							ELSE	LOC	END
--						 ) AS	LOC
--						,K_LOCACION
--						,K_ORDEN_TRABAJO AS ORDEN_TRABAJO
--						-- =============================	
--			FROM		INVENTARIO						(NOLOCK) 
--			INNER JOIN	FOLIO							(NOLOCK) ON FOLIO.K_FOLIO=INVENTARIO.K_FOLIO
--			INNER JOIN	COMPRAS_Pruebas.dbo.ITEM		(NOLOCK) ON INVENTARIO.K_ITEM=ITEM.K_ITEM	
--			INNER JOIN	IMLOCFIL_SQL					(NOLOCK) ON FOLIO.K_LOCACION=IMLOCFIL_SQL.A4GLIdentity
--						-- =============================
--						-- =============================
--			WHERE		INVENTARIO.K_ITEM				= @PP_K_ITEM
--			AND			INVENTARIO.K_STATUS_INVENTARIO	= 20	-- [20]	= INSPECCIONADO
--			AND			FOLIO.K_LOCACION				= 4
--			AND			INVENTARIO.L_BORRADO <> 1
--			ORDER BY	K_FOLIO DESC
--	END
--	-- //////////////////////////////////////////////////////////////////////////////////////
--END