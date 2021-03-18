-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		COMPRAS
-- // MODULE:			HEADER_PURCHASE_ORDER
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20200914
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
--USE [DATA_02]
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> LISTADO DE INVENTARIO ACTUAL EN ALMACEN DE PRODUCCIÓN
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVENTARIO_HILO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVENTARIO_HILO]
GO
--		 EXECUTE [dbo].[PG_LI_INVENTARIO_HILO] 1,139
CREATE PROCEDURE [dbo].[PG_LI_INVENTARIO_HILO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT
	-- ===========================
	--,@PP_K_LOTE						VARCHAR(50)
AS
	-- ///////////////////////////////////////////	
	IF	@PP_K_SISTEMA_EXE	= 0
	BEGIN
		SELECT	DATENAME(DW,GETDATE()) + ', ' + CONVERT(varchar,GETDATE(),107)	AS F_DATE,
				D_ITEM,
				PART_NUMBER_ITEM_PEARL,
				(CASE
					WHEN	INVENTARIO.K_ITEM	= 70	THEN	'COGNAC'
					WHEN	INVENTARIO.K_ITEM	= 1507	THEN	'CARAMEL'
					WHEN	INVENTARIO.K_ITEM	= 1508	THEN	'TUPELO'
					WHEN	INVENTARIO.K_ITEM	= 1867	THEN	'BLACK'
					WHEN	INVENTARIO.K_ITEM	= 1868	THEN	'BLUE AGAVE'
					WHEN	INVENTARIO.K_ITEM	= 2212	THEN	'GREY SEAL'
					WHEN	INVENTARIO.K_ITEM	= 2213	THEN	'LK5'					
				END )		AS COLOR_PRODUCCION,
				CONVERT(INT,(	SUM(CANTIDAD_RECIBIDA)	/ 2 )) AS QUANTITY
		FROM	INVENTARIO	
		INNER JOIN	COMPRAS_PRUEBAS.DBO.ITEM	ON	ITEM.K_ITEM		= INVENTARIO.K_ITEM
		INNER JOIN	FOLIO						ON	FOLIO.K_FOLIO	= INVENTARIO.K_FOLIO
		WHERE	K_CLASS_ITEM	= 2
		AND		TRADEMARK_ITEM	= 'HILO'
		AND		K_LOCACION		= 4
		AND		TIPO			= 'B'
		AND		K_STATUS_INVENTARIO	= 20
		GROUP BY INVENTARIO.K_ITEM, D_ITEM, PART_NUMBER_ITEM_PEARL
	END
	ELSE
	BEGIN
		SELECT	DATENAME(DW,GETDATE()) + ', ' + CONVERT(varchar,GETDATE(),107)	AS F_DATE,
				D_ITEM,
				PART_NUMBER_ITEM_PEARL,
				(CASE
					WHEN	INVENTARIO.K_ITEM	= 70	THEN	'COGNAC'
					WHEN	INVENTARIO.K_ITEM	= 1507	THEN	'CARAMEL'
					WHEN	INVENTARIO.K_ITEM	= 1508	THEN	'TUPELO'
					WHEN	INVENTARIO.K_ITEM	= 1867	THEN	'BLACK'
					WHEN	INVENTARIO.K_ITEM	= 1868	THEN	'BLUE AGAVE'
					WHEN	INVENTARIO.K_ITEM	= 2212	THEN	'GREY SEAL'
					WHEN	INVENTARIO.K_ITEM	= 2213	THEN	'LK5'					
				END )		AS COLOR_PRODUCCION,
				CONVERT(INT,(	SUM(CANTIDAD_RECIBIDA)	/ 2 )) AS QUANTITY
		FROM	INVENTARIO	
		INNER JOIN	COMPRAS.DBO.ITEM			ON	ITEM.K_ITEM		= INVENTARIO.K_ITEM
		INNER JOIN	FOLIO						ON	FOLIO.K_FOLIO	= INVENTARIO.K_FOLIO
		WHERE	K_CLASS_ITEM	= 2
		AND		TRADEMARK_ITEM	= 'HILO'
		AND		K_LOCACION		= 4
		AND		TIPO			= 'B'
		AND		K_STATUS_INVENTARIO	= 20
		GROUP BY INVENTARIO.K_ITEM, D_ITEM, PART_NUMBER_ITEM_PEARL
	END
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> LISTADO DE REGISTROS DE ENTREGA DE MATERIAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ENTREGAR_CONTROLADO_EMPLEADOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ENTREGAR_CONTROLADO_EMPLEADOS]
GO
--		 EXECUTE [dbo].[PG_LI_ENTREGAR_CONTROLADO_EMPLEADOS] 1,139, '2021-03-10','2021-03-16'
CREATE PROCEDURE [dbo].[PG_LI_ENTREGAR_CONTROLADO_EMPLEADOS]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_F_INICIAL					[DATE],
	@PP_F_FINAL						[DATE]
AS

SELECT --	* ,
		K_MATERIAL_CONTROLADO,
		D_ITEM,
		(CASE
					WHEN	ITEM.K_ITEM	= 70	THEN	'COGNAC'
					WHEN	ITEM.K_ITEM	= 1507	THEN	'CARAMEL'
					WHEN	ITEM.K_ITEM	= 1508	THEN	'TUPELO'
					WHEN	ITEM.K_ITEM	= 1867	THEN	'BLACK'
					WHEN	ITEM.K_ITEM	= 1868	THEN	'BLUE AGAVE'
					WHEN	ITEM.K_ITEM	= 2212	THEN	'GREY SEAL'
					WHEN	ITEM.K_ITEM	= 2213	THEN	'LK5'					
				END )		AS COLOR_PRODUCCION,
		LOC_DESC,
		D_MODELO,
		LOC_DESC,
		F_ENTREGA,
		K_EMPLEADO_PEARL,
		D_EMPLEADO,
		CONVERT(INT, CANTIDAD_ENTREGADA/2) AS QUANTITY
		--	SE DEBERÁ GUARDAR EL NOMBRE DE EMPLEADO PARA EVITAR BUSCAR EN HOWE Y NO ENCONTRAR LOS QUE FUERON DADOS DE BAJA.
FROM MATERIAL_CONTROLADO
INNER JOIN COMPRAS.DBO.ITEM		ON	ITEM.K_ITEM	= MATERIAL_CONTROLADO.K_ITEM
INNER JOIN IMLOCFIL_SQL			ON	IMLOCFIL_SQL.A4GLIdentity	= MATERIAL_CONTROLADO.K_LOCACION_ENTREGA
WHERE		( @PP_F_INICIAL IS NULL		OR	@PP_F_INICIAL<=F_ENTREGA)
AND			( @PP_F_FINAL IS NULL		OR	@PP_F_FINAL>=F_ENTREGA)
ORDER BY	F_ENTREGA DESC, K_MATERIAL_CONTROLADO DESC

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE]
GO
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE] 0,139,230001
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE] 0,139,140001
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE] 0,139,'Q20077'
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE] 0,139,'165432'
CREATE PROCEDURE [dbo].[PG_SK_ENTREGAR_CONTROLADO_LOTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_LOTE						VARCHAR(50)
AS
--	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////	
	SELECT	TOP(1)
			INVENTARIO_LOCACION.K_ITEM,	
			CONVERT(DECIMAL(16,2),CANTIDAD_DISPONIBLE	/	2	)	AS CANTIDAD_DISPONIBLE
			--CONVERT(DECIMAL(16,2),CANTIDAD_DISPONIBLE)	AS CANTIDAD_DISPONIBLE
	FROM	INVENTARIO_LOCACION
	INNER JOIN	INVENTARIO	ON		INVENTARIO.LOTE_PEARL	= INVENTARIO_LOCACION.LOTE_PEARL
	--WHERE	INVENTARIO_LOCACION.LOTE_PEARL	= @PP_K_LOTE
	WHERE	LOTE_VENDOR	= @PP_K_LOTE
	AND		K_LOCACION	= 4
	AND		INVENTARIO_LOCACION.L_BORRADO	= 0
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ENTREGAR_CONTROLADO_EMPLEADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ENTREGAR_CONTROLADO_EMPLEADO]
GO
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_EMPLEADO] 0,139,13164
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_EMPLEADO] 0,139,13367
--		 EXECUTE [dbo].[PG_SK_ENTREGAR_CONTROLADO_EMPLEADO] 0,139,99999
CREATE PROCEDURE [dbo].[PG_SK_ENTREGAR_CONTROLADO_EMPLEADO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_EMPLEADO_PEARL			INT
AS
--	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
			SELECT	TOP  (1)
				EN_NUM_EMP	AS EMPLEADO,
				EP_NOMBRE	AS D_EMPLEADO
			FROM HOWE.DBO.VISTA_GAFETES
			WHERE	EN_NUM_EMP=@PP_K_EMPLEADO_PEARL
GO

-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DATOS EN EL INVENTARIO DE PRODUCCIÓN
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_ENTREGAR_CONTROLADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_ENTREGAR_CONTROLADO]
GO
--		 EXECUTE [dbo].[PG_IN_ENTREGAR_CONTROLADO] 0,139,  '165432' , 70 , '1' , 'WL -75' , 108 , '13164' , 'TEST PARA ENTREGA DE HILO. POR SISTEMAS'
CREATE PROCEDURE [dbo].[PG_IN_ENTREGAR_CONTROLADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_LOTE_VENDOR				VARCHAR(10),
	@PP_K_ITEM					INT,
	@PP_CANTIDAD_ENTREGAR		DECIMAL(16,4),
	@PP_MODELO					VARCHAR(50),
	@PP_K_LOCACION_DESTINO		INT,
	@PP_K_EMPLEADO_PEARL		INT,
	@PP_COMENTARIO				VARCHAR(250)
	-----=====================================================
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE		 @VP_MENSAJE					VARCHAR(300) = ''
				,@VP_K_MATERIAL_CONTROLADO		INT
	-----=====================================================				
				,@VP_K_FOLIO_DESTINO			INT
	-----=====================================================
				,@VP_ES_HILO					VARCHAR(50)
	-- /////////////////////////////////////////////////////////////////////
	--	SE VERIFICA QUE EL MATERIAL ENTREGADO SEA HILO. 
	IF @PP_K_SISTEMA_EXE	= 0
	BEGIN
		SELECT	@VP_ES_HILO		= LTRIM(RTRIM(TRADEMARK_ITEM))
		FROM	COMPRAS_Pruebas.DBO.ITEM
		WHERE	K_ITEM			= @PP_K_ITEM
	END
	ELSE
	BEGIN
		SELECT	@VP_ES_HILO		= LTRIM(RTRIM(TRADEMARK_ITEM))
		FROM	COMPRAS.DBO.ITEM
		WHERE	K_ITEM	= @PP_K_ITEM
	END

	--============================================================================
	--	SE VALIDA NUEVAMENTE EL EMPLEADO.
	--	DECLARE	@VP_EXISTE_EMPLEADO	AS INT
	IF (	SELECT	COUNT(EN_NUM_EMP)
			FROM	HOWE.DBO.VISTA_GAFETES
			WHERE	EN_NUM_EMP=@PP_K_EMPLEADO_PEARL	)	<= 0
	BEGIN
		RAISERROR ('El empleado no existe. Verifique y vuelva a intentar...', 16, 1 )
	END

	DECLARE	@VP_D_EMPLEADO		VARCHAR(250)
	SELECT	@VP_D_EMPLEADO		=	EP_NOMBRE
	FROM	HOWE.DBO.VISTA_GAFETES
	WHERE	EN_NUM_EMP	=	@PP_K_EMPLEADO_PEARL

	--============================================================================
IF @VP_ES_HILO	= 'HILO'
BEGIN
	-- /////////////////////////////////////////////////////////////////////
	--====================================== ANTES DE REALIZAR EL INSERT, SE REALIZA LA CONVERSIÓN
	--	CADA PIEZA DE HILO CONTIENE 32 oz EQUIVALENTE A 2 lb, QUE ES LA UNIDAD DE MEDIDA CON LA QUE SE SOLICITA EL HILO
	--	Y ESTE A SU VEZ SE ENTREGA POR PIEZA.
	SET	@PP_CANTIDAD_ENTREGAR	= @PP_CANTIDAD_ENTREGAR * 2			
	
	--============================================================================
	--	SE GENERA UN NUEVO FOLIO PARA EL MATERIAL. COMO SERÁ DE TIPO MHI-B SE ASIGNA DE TIPO MHI-A
	DECLARE @VP_F_DATE_FOLIO			DATE = GETDATE()

	EXECUTE [dbo].[PG_IN_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
									-- ===========================	
									@PP_K_LOCACION_DESTINO,
									0,	
									'A',--@PP_TIPO, 
									-- =========================
									@VP_F_DATE_FOLIO,
									-- ==========================
									@PP_K_FOLIO_INSERTADO	= @VP_K_FOLIO_DESTINO	OUTPUT
	-- /////////////////////////////////////////////////////////////////////
	--============================================================================
	--======================================INSERTAR REGISTRO EN TABLA CONTROLADO
	--============================================================================
		INSERT INTO [MATERIAL_CONTROLADO]
			(	 [K_ITEM]							
				,[K_LOCACION_ENTREGA]				
				,[K_EMPLEADO_PEARL]					
				-- ============================	
				,[LOTE_VENDOR]						
				-- ============================
				,[D_MODELO]							
				,[C_INVENTARIO]						
				-- ============================
				,[F_ENTREGA]							
				-- ============================
				,[CANTIDAD_ENTREGADA]
				,[K_FOLIO_DESTINO]		
				,[D_EMPLEADO]		
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	 @PP_K_ITEM					
				,@PP_K_LOCACION_DESTINO
				,@PP_K_EMPLEADO_PEARL		
				-- ============================				
				,@PP_LOTE_VENDOR					
				-- ============================				
				,@PP_MODELO					
				,@PP_COMENTARIO				
				-- ============================				
				,GETDATE()
				-- ============================				
				,@PP_CANTIDAD_ENTREGAR
				,@VP_K_FOLIO_DESTINO		
				,@VP_D_EMPLEADO
				-- ============================				
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El registro no fue ingresado.'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
		ELSE
		BEGIN
			SELECT @VP_K_MATERIAL_CONTROLADO= SCOPE_IDENTITY()
		END

		--	SE ACTUALIZA LA TABLA DE INVENTARIO DE MATERIAL Y SE REALIZA EL INSERT EN LOS LOGS DE MOVIMIENTOS.
		EXECUTE	[dbo].[PG_PR_ENTREGAR_CONTROLADO_UP_INVENTARIO]		 @PP_K_SISTEMA_EXE		,@PP_K_USUARIO_ACCION,
																--=====================================================
																	@PP_LOTE_VENDOR,		@PP_K_ITEM,
																	@PP_CANTIDAD_ENTREGAR,	@PP_K_LOCACION_DESTINO,
																	@VP_K_FOLIO_DESTINO

-- /////////////////////////////////////////////////////////////////////
END
ELSE
BEGIN
	RAISERROR ('El lote indicado, no pertenece al componente [HILO], verifique y vuelva a intentar...', 16, 1 )
END
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(MAX);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = '!!! ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE	,@VP_K_MATERIAL_CONTROLADO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // PARA ACTUALIZAR LOS DATOS EN LA TABLA DE INVENTARIO
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ENTREGAR_CONTROLADO_UP_INVENTARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ENTREGAR_CONTROLADO_UP_INVENTARIO]
GO
CREATE PROCEDURE [dbo].[PG_PR_ENTREGAR_CONTROLADO_UP_INVENTARIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_LOTE_VENDOR				VARCHAR(10),
	@PP_K_ITEM					INT,
	@PP_CANTIDAD_ENTREGAR		DECIMAL(16,4),
	@PP_K_LOCACION_DESTINO		INT,
	@PP_K_FOLIO_DESTINO			INT
-----=====================================================
AS
	DECLARE		 @VP_MENSAJE					NVARCHAR(MAX) = ''
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
DECLARE		 @VP_CU_K_ORDEN_COMPRA_PEDIDO	VARCHAR(50)			,@VP_CU_K_ENTREGA			INT					,@VP_CU_LOTE_PEARL				INT
			,@VP_CU_K_INVENTARIO			INT					,@VP_CU_SERIE_NO			VARCHAR(50)			,@VP_CU_CANTIDAD_RECIBIDA		DECIMAL(16,4)
			,@VP_CU_K_FOLIO_ORIGEN			INT					,@VP_CU_K_ORDEN_TRABAJO		INT					,@VP_CU_K_DETAILS_BPO_RECIBO	INT	
			,@VP_CU_LOTE_NUMERO_CONSECUTIVO	INT					,@VP_CU_F_DATE_INVENTARIO	DATE
			
		DECLARE CU_CANTIDAD_ENTREGAR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			--	OBTENER DATOS PARA INGRESAR A INVENTARIO
			SELECT
					-- LOTE_VENDOR
					--,K_ITEM
					--,K_LOCACION
					 K_ORDEN_COMPRA_PEDIDO
					,K_ENTREGA
					,LOTE_PEARL
					,K_INVENTARIO
					,SERIE_NO
					,CANTIDAD_RECIBIDA
					,INVENTARIO.K_FOLIO					--	FOLIO ORIGEN
					,K_ORDEN_TRABAJO
--					,K_DETAILS_BPO_RECIBO
--					,LOTE_NUMERO_CONSECUTIVO
--					,F_DATE_INVENTARIO
			FROM	INVENTARIO
			INNER JOIN FOLIO				ON INVENTARIO.K_FOLIO=FOLIO.K_FOLIO
			WHERE	K_STATUS_INVENTARIO	= 20
			AND		K_LOCACION			= 4					-- LOCACIÓN ORIGEN
			AND		K_ITEM				= @PP_K_ITEM		-- 70		--- 334		--	@PP_K_ITEM
			AND		LOTE_VENDOR			= @PP_LOTE_VENDOR	-- '165432'	---'Q20077'	--	@PP_LOTE_VENDOR
			AND		TIPO				= 'B'
			ORDER	BY	K_INVENTARIO ASC,	CANTIDAD_RECIBIDA ASC
		OPEN			CU_CANTIDAD_ENTREGAR
		FETCH NEXT FROM CU_CANTIDAD_ENTREGAR INTO	 @VP_CU_K_ORDEN_COMPRA_PEDIDO	,@VP_CU_K_ENTREGA			,@VP_CU_LOTE_PEARL
													,@VP_CU_K_INVENTARIO			,@VP_CU_SERIE_NO			,@VP_CU_CANTIDAD_RECIBIDA
													,@VP_CU_K_FOLIO_ORIGEN			,@VP_CU_K_ORDEN_TRABAJO		--,@VP_CU_K_DETAILS_BPO_RECIBO
													--,@VP_CU_LOTE_NUMERO_CONSECUTIVO	,@VP_CU_F_DATE_INVENTARIO
		WHILE @@FETCH_STATUS = 0	--	OR	@PP_CANTIDAD_ENTREGAR	> 0
		BEGIN
			IF	@PP_CANTIDAD_ENTREGAR	= 0
				BREAK;
--=====================================================================================================================================		
--=====================================================================================================================================		
--=====================================================================================================================================	
		DECLARE		@VP_QTY_MOVIMIENTO		DECIMAL(16,4)

		-- SE VERIFICA QUE EL FOLIO ORIGEN CUENTE CON UN FOLIO ASIGNADO, EN ESTE CASO DEBE SER EL BASE.
		IF @VP_CU_K_FOLIO_ORIGEN IS NULL OR @VP_CU_K_FOLIO_ORIGEN=0
		BEGIN
			SET @VP_MENSAJE='Folio Origen [0] no encontrado...Verifique'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END		
		
		-- AQUÍ REALIZARÁ LA ACTUALIZACIÓN 
		--=====================================================================================================================================
		--=====================================================================================================================================
		IF @PP_CANTIDAD_ENTREGAR = @VP_CU_CANTIDAD_RECIBIDA
		BEGIN
			UPDATE	INVENTARIO
			SET		
					K_FOLIO					= @PP_K_FOLIO_DESTINO
			WHERE	K_INVENTARIO			= @VP_CU_K_INVENTARIO
			AND		INVENTARIO.L_BORRADO<>1

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='El Folio [INV] no puede ser actualizado...Verificar'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END		

			--====================================== SE ACTUALIZA EL REGISTRO PARA SALIR DEL CURSOR Y PARA EL LOG DE MOVIMIENTOS.
			SET	@VP_QTY_MOVIMIENTO		= @PP_CANTIDAD_ENTREGAR
			SET	@PP_CANTIDAD_ENTREGAR	= 0
		END
		--=====================================================================================================================================
		--=====================================================================================================================================
		ELSE IF @PP_CANTIDAD_ENTREGAR < @VP_CU_CANTIDAD_RECIBIDA
		BEGIN
				--======================================INSERTAR EL REGISTRO DE INVENTARIO, PARA DIVIDIR LAS CANTIDADES
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
					SELECT
						@PP_K_ITEM						,@PP_K_FOLIO_DESTINO					
						-- =========================
						,0								,20
						-- =========================
						,@VP_CU_K_ORDEN_COMPRA_PEDIDO	,K_DETAILS_BPO_RECIBO
						,@VP_CU_K_ENTREGA
						-- =========================
						,@VP_CU_SERIE_NO				,@PP_LOTE_VENDOR				
						,@VP_CU_LOTE_PEARL				,LOTE_NUMERO_CONSECUTIVO
						-- =========================
						,F_DATE_INVENTARIO				,C_INVENTARIO
						-- =========================
						,@PP_CANTIDAD_ENTREGAR
						-- =========================
						,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL
					FROM	INVENTARIO	
					WHERE	K_INVENTARIO	= @VP_CU_K_INVENTARIO

					IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro [INV] no fue Insertado.'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END				
					--ELSE
					--	BEGIN
					--		SELECT @VP_K_INVENTARIO=SCOPE_IDENTITY()
					--
					--		IF @VP_K_INVENTARIO=NULL
					--		BEGIN
					--			--SET @VP_MENSAJE='The IDENTITY assign value was failed.'
					--			SET @VP_MENSAJE='Error en la asignación de IDENTIDAD [INV].'
					--			RAISERROR (@VP_MENSAJE, 16, 1 )
					--		END
					--	END

				--======================================SE ACTUALIZA LA CANTIDAD ORIGINAL RESTANDOLE EL TOTAL ENTREGADO.
				UPDATE	INVENTARIO
				SET		
						CANTIDAD_RECIBIDA		= (	CANTIDAD_RECIBIDA	- @PP_CANTIDAD_ENTREGAR )
				WHERE	K_INVENTARIO			= @VP_CU_K_INVENTARIO
				AND		INVENTARIO.L_BORRADO<>1

				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El Folio [INV] no puede ser actualizado...Verificar'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END		
				
				--====================================== SE ACTUALIZA EL REGISTRO PARA SALIR DEL CURSOR Y PARA EL LOG DE MOVIMIENTOS.
				SET	@VP_QTY_MOVIMIENTO		= @PP_CANTIDAD_ENTREGAR
				SET	@PP_CANTIDAD_ENTREGAR	= 0
		END
		--=====================================================================================================================================
		--=====================================================================================================================================
		ELSE IF @PP_CANTIDAD_ENTREGAR > @VP_CU_CANTIDAD_RECIBIDA
		BEGIN				
				--======================================SE ACTUALIZA LA CANTIDAD ORIGINAL RESTANDOLE EL TOTAL ENTREGADO.
				UPDATE	INVENTARIO
				SET		
						K_FOLIO					= @PP_K_FOLIO_DESTINO
				WHERE	K_INVENTARIO			= @VP_CU_K_INVENTARIO
				AND		INVENTARIO.L_BORRADO<>1
				
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El Folio [INV] no puede ser actualizado...Verificar'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END		
				--====================================== SE ACTUALIZA EL REGISTRO PARA SALIR DEL CURSOR Y PARA EL LOG DE MOVIMIENTOS.
				SET	@VP_QTY_MOVIMIENTO		= @VP_CU_CANTIDAD_RECIBIDA
				SET	@PP_CANTIDAD_ENTREGAR	= @PP_CANTIDAD_ENTREGAR - @VP_CU_CANTIDAD_RECIBIDA
		END

	--=====================================================================================================================================
	--- SE HACE EL INSERT EN LA TABLA INVENTARIO_MOVIMIENTO
	EXECUTE [dbo].[PG_IN_MOVIMIENTO_INVENTARIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
											,@VP_CU_K_ORDEN_COMPRA_PEDIDO	,@VP_CU_K_ENTREGA
											,@PP_K_ITEM						,@VP_CU_LOTE_PEARL
											,4			-- @PP_K_LOCACION_ORIGEN			
											,@VP_CU_K_FOLIO_ORIGEN
											,@VP_CU_K_ORDEN_TRABAJO
											,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
											,0
											,@VP_QTY_MOVIMIENTO	
											,20			-- @PP_K_TIPO_MOVIMIENTO


	--	PARA OBTENER LOS DATOS DEL DESTINO PARA EL LOG DE MOVIMIENTO X REGISTRO	
	EXECUTE [dbo].[PG_IN_MOVIMIENTO_X_REGISTRO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
												-- ===========================
												,@VP_CU_K_INVENTARIO			,@PP_K_ITEM						
												,20		-- @PP_K_TIPO_MOVIMIENTO			
												,@VP_CU_LOTE_PEARL
												,@VP_CU_SERIE_NO
												-- ============================	
												,4		-- @PP_K_LOCACION_ORIGEN			
												,@VP_CU_K_FOLIO_ORIGEN
												,@VP_CU_K_ORDEN_TRABAJO
												-- ============================	
												,@PP_K_LOCACION_DESTINO			,@PP_K_FOLIO_DESTINO
												,0
												-- ============================	
												,@VP_QTY_MOVIMIENTO

	--=====================================================================================================================================

		--==============================================
		-- VERIFICAMOS SI EXISTE UN REGISTRO DEL K_ITEM
		--==============================================
		DECLARE @VP_EXISTE_LOCACION		INT
		SET @VP_EXISTE_LOCACION= (	SELECT	COUNT(K_ITEM)
									FROM	INVENTARIO_LOCACION
									WHERE	K_ITEM		=@PP_K_ITEM	
									AND		K_LOCACION	=@PP_K_LOCACION_DESTINO
									AND		LOTE_PEARL	=@VP_CU_LOTE_PEARL			)
		
		--==========================================================================================
		--	SI NO EXISTE REGISTRO ALGUNO SE REALIZA EL	INSERT EN LA TABLA DE INVENTARIO_LOCACION
		--==========================================================================================				
		IF @VP_EXISTE_LOCACION=0
		BEGIN
			--============================================================================
			--======================================INSERTAR EL INVENTARIO_LOCACION
			--============================================================================
			EXECUTE	[dbo].[PG_IN_INVENTARIO_LOCACION]	 @PP_K_SISTEMA_EXE			,@PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@VP_CU_LOTE_PEARL			,@VP_QTY_MOVIMIENTO
		END
		ELSE
		BEGIN
			EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	 @PP_K_SISTEMA_EXE			,@PP_K_USUARIO_ACCION
														,@PP_K_LOCACION_DESTINO		,@PP_K_ITEM
														,@VP_CU_LOTE_PEARL			,@VP_QTY_MOVIMIENTO
														,'SUMAR'
		END

		--== SE ACTUALIZA LA LOCACIÓN ORIGEN
		EXECUTE	[dbo].[PG_UP_INVENTARIO_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION
													,4				-- ,@PP_K_LOCACION_ORIGEN		
													,@PP_K_ITEM
													,@VP_CU_LOTE_PEARL			,@VP_QTY_MOVIMIENTO
													,'RESTAR'
--=====================================================================================================================================
--=====================================================================================================================================	
--=====================================================================================================================================	
		FETCH NEXT FROM CU_CANTIDAD_ENTREGAR INTO	 @VP_CU_K_ORDEN_COMPRA_PEDIDO	,@VP_CU_K_ENTREGA			,@VP_CU_LOTE_PEARL
													,@VP_CU_K_INVENTARIO			,@VP_CU_SERIE_NO			,@VP_CU_CANTIDAD_RECIBIDA
													,@VP_CU_K_FOLIO_ORIGEN			,@VP_CU_K_ORDEN_TRABAJO		--,@VP_CU_K_DETAILS_BPO_RECIBO
													--,@VP_CU_LOTE_NUMERO_CONSECUTIVO	,@VP_CU_F_DATE_INVENTARIO
		END
		CLOSE			CU_CANTIDAD_ENTREGAR
		DEALLOCATE		CU_CANTIDAD_ENTREGAR
-----===========================================================================================================
-----===========================================================================================================
	IF @PP_CANTIDAD_ENTREGAR	> 0
	BEGIN
		RAISERROR ('No fue posible establecer la cantidad a mover en [0]. Informe a Sistemas...', 16, 1 )
	END
	ELSE IF @PP_CANTIDAD_ENTREGAR	< 0
	BEGIN
		RAISERROR ('Hubo un problema al actualizar la tabla [INVENTARIO]. Informe a Sistemas...', 16, 1 )
	END

-----===========================================================================================================
GO
-- /////////////////////////////////////////////////////////////////////	
-- /////////////////////////////////////////////////////////////////////	
-- /////////////////////////////////////////////////////////////////////	
-- /////////////////////////////////////////////////////////////////////	
