-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			CONTROL INVENTARIO
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210518
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02pruebas]
USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- 							CONTENIDO SP
--	[PG_SK_NOTIFICACION_MIN]
--	[PG_NOTIFICAR_HILO]
--	[PG_NOTIFICAR_CANTIDAD_MIN]

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_NOTIFICACION_MIN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_NOTIFICACION_MIN]
GO
--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_MIN] 0,	'HILO'
--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_MIN] 0,	'MULLER'

--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_MIN] 1,	'HILO'
--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_MIN] 1,	'MULLER'
CREATE PROCEDURE [dbo].[PG_SK_NOTIFICACION_MIN]
	@PP_K_SISTEMA_EXE				INT,
	-- ===========================
	@PP_TIPO_ITEM					VARCHAR(250)
AS
	DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
BEGIN TRANSACTION 
BEGIN TRY		
	-- ///////////////////////////////////////////	
-- ========================================================================================================================================================================================================================
-- ========================================================================================================================================================================================================================
	---		DECLARACIÓN DE LAS TABLAS TEMPORALES A UTILIZAR.	
	DECLARE	@VP_TABLA	AS TABLE
	(	K_ITEM						INT,
		--CANTIDAD_STOCK				DECIMAL(19,4),
		PART_NUMBER_ITEM_PEARL		VARCHAR(50),
		TRADEMARK_ITEM				VARCHAR(250),
		D_ITEM						VARCHAR(250)		)

	---	DECLARACIÓN DE LAS VARIABLES A UTLIZAR EN EL CURSOR.
	DECLARE	 @VP_CU_K_ITEM						INT
			--,@VP_CU_QTY_STOCK_PRODUCCION		DECIMAL(19,4)
			,@VP_CU_PART_NUMBER_ITEM_PEARL		VARCHAR(50)
			,@VP_CU_TRADEMARK_ITEM				VARCHAR(250)
			,@VP_CU_D_ITEM						VARCHAR(250)
			
	--=================================================================================================================================================================================
	---	INSERCIÓN DE VALORES A LA TABLA TEMPORAL, SE OBTIENE POR TIPO DE ITEM LOS REGISTROS QUE NO HAYAN SIDO DESACTIVADOS.
			INSERT INTO @VP_TABLA
			SELECT	ITEM.K_ITEM,
					PART_NUMBER_ITEM_PEARL,
					TRADEMARK_ITEM,
					D_ITEM
			FROM	COMPRAS.DBO.ITEM	(NOLOCK)
			WHERE	TRADEMARK_ITEM	= @PP_TIPO_ITEM
			AND		ITEM.L_BORRADO		= 0		
			AND		ITEM.K_ITEM	NOT IN (SELECT K_ITEM FROM COMPRAS.DBO.ITEM_INACTIVO	(NOLOCK))
	--=================================================================================================================================================================================
	--	INICIO DEL CURSOR
	DECLARE CU_CURSOR_NOTIF_MIN	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR		
		SELECT * FROM @VP_TABLA
	OPEN CU_CURSOR_NOTIF_MIN
		FETCH NEXT FROM  CU_CURSOR_NOTIF_MIN INTO	@VP_CU_K_ITEM			,	@VP_CU_PART_NUMBER_ITEM_PEARL	,
													@VP_CU_TRADEMARK_ITEM	,	@VP_CU_D_ITEM
		WHILE @@FETCH_STATUS=0
		BEGIN
			--	SE AGREGA IF PARA REALIZAR LA VERIFICACIÓN POR TIPO DE ITEM.
			IF	@VP_CU_TRADEMARK_ITEM = 'HILO'
			BEGIN
				EXECUTE	[PG_NOTIFICAR_HILO]		@PP_K_SISTEMA_EXE,	--@PP_K_USUARIO_ACCION		,
												-- =====================================
												@VP_CU_K_ITEM		,	@VP_CU_PART_NUMBER_ITEM_PEARL	,			
												@VP_CU_D_ITEM		,	@VP_CU_TRADEMARK_ITEM	
			END
			ELSE IF @VP_CU_TRADEMARK_ITEM = 'MULLER'
			BEGIN
				EXECUTE	[PG_NOTIFICAR_MULLER]	@PP_K_SISTEMA_EXE,	--@PP_K_USUARIO_ACCION		,
												-- =====================================
												@VP_CU_K_ITEM		,	@VP_CU_PART_NUMBER_ITEM_PEARL	,			
												@VP_CU_D_ITEM		,	@VP_CU_TRADEMARK_ITEM
			END
		
		FETCH NEXT FROM  CU_CURSOR_NOTIF_MIN INTO	@VP_CU_K_ITEM			,	@VP_CU_PART_NUMBER_ITEM_PEARL	,
													@VP_CU_TRADEMARK_ITEM	,	@VP_CU_D_ITEM
	END
	CLOSE		CU_CURSOR_NOTIF_MIN
	DEALLOCATE	CU_CURSOR_NOTIF_MIN
	-- ////////////////////////////////////////////////////////////////////
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
	SELECT	@VP_MENSAJE AS MENSAJE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // PARA ENVIAR NOTIFICACIÓN DE STOCK MINIMO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_HILO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_HILO]
GO
--		 EXECUTE [dbo].[PG_NOTIFICAR_HILO]	1,139, 1,1,3500,70
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_HILO]
	@PP_K_SISTEMA_EXE			INT,
	-----=====================================================
	@PP_K_ITEM								INT,
	@PP_PART_NUMBER_ITEM_PEARL				VARCHAR(250),
	@PP_D_ITEM								VARCHAR(250),
	@PP_TIPO_ITEM							VARCHAR(50)
	-----=====================================================
AS	
DECLARE	 @VP_MENSAJE					NVARCHAR(MAX) = ''
		,@VP_QTY_STOCK_PRODUCCION		DECIMAL(19,4)
		,@VP_QTY_CONSUMIDA_MES			DECIMAL(19,4)
		--=================================================
		,@VP_MM_1		VARCHAR(15)	= FORMAT(DATEADD (DAY , -35 , GETDATE() ),'yyyy-MM-dd')		--	FECHA ACTUAL MENOS 35 DÍAS, QUE ES EL TIEMPO APRÓXIMADO DE ENTREGA DE MATERIAL.
		--,@VP_MM_1		VARCHAR(15)	= FORMAT(DATEADD (MONTH , -1 , GETDATE() ),'yyyy-MM-dd')	--	FECHA ACTUAL MENOS 1 MES

	--================================================================
	--	SE OBTIENE LA CANTIDAD ACTUALMENTE DISPONIBLE EN LA LOCACIÓN DE PRODUCCIÓN.
		SELECT	@VP_QTY_STOCK_PRODUCCION	=	ISNULL(	SUM(CANTIDAD_RECIBIDA) / 2	, 0	)				
		FROM	INVENTARIO	(NOLOCK)										
		INNER JOIN FOLIO	(NOLOCK)	ON FOLIO.K_FOLIO	= INVENTARIO.K_FOLIO
		WHERE	K_LOCACION	= 125	-- LOCACIÓN DE PRODUCCIÓN
		AND		INVENTARIO.L_BORRADO	= 0
		AND		K_ITEM =	@PP_K_ITEM
	
	--================================================================
	--	PRIMERO SE VERIFICA LA TENDENCIA DE UTILIZACIÓN DE MATERIAL UTILIZADO, DEL DÍA ACTUAL A UN 35 ANTES, QUE ES EL TIEMPO APRÓXIMADO DE ENTREGA DE MATERIAL.
		SELECT	@VP_QTY_CONSUMIDA_MES	= ( SUM(CANTIDAD_ENTREGADA) / 2)
		FROM	MATERIAL_CONTROLADO		(NOLOCK)
		WHERE	(	F_ENTREGA	>=	@VP_MM_1	)	
		AND		(	F_ENTREGA	<=	GETDATE()	)
		AND		K_ITEM			=	@PP_K_ITEM
		
			--================================================================
			--	SE REALIZA UNA COMPARACIÓN DE LA TENDENCIA DE USO CONTRA LA CANTIDAD EN STOCK EN PRODUCCIÓN.
				IF	@VP_QTY_CONSUMIDA_MES	>	@VP_QTY_STOCK_PRODUCCION
				BEGIN
					
					DECLARE	 @VP_QTY_USO_DIARIA				DECIMAL(19,4)	= (	@VP_QTY_CONSUMIDA_MES	/ 30	)
							,@VP_K_TIPO_GRUPO_APROBADOR		VARCHAR(15)		= 9600		--	 GRUPO DE NOTIFICACION.					
						
						--================================================================
						--================================================================
						--	SE VERIFICA SI SE HA ENVIADO LA NOTIFICACIÓN DIARIA. EN CASO QUE SE HAYA REALIZADO OMITIRA EL ENVÍO DEL CORREO.
						IF	(	SELECT	COUNT(K_ITEM_NOTIFICACION)
								FROM	ITEM_NOTIFICACION (NOLOCK)
								WHERE	K_ITEM			= @PP_K_ITEM
								AND		F_NOTIFICACION	= FORMAT(GETDATE(),'yyyy-MM-dd')	)	<=	0
						BEGIN

							EXECUTE	[PG_NOTIFICAR_CANTIDAD_MIN]		@PP_K_SISTEMA_EXE, --@PP_K_USUARIO_ACCION,
																	-- =====================================
																	@PP_PART_NUMBER_ITEM_PEARL		,	@PP_D_ITEM			,
																	@VP_QTY_STOCK_PRODUCCION		,
																	@VP_QTY_CONSUMIDA_MES			,	@VP_QTY_USO_DIARIA	,
																	@VP_K_TIPO_GRUPO_APROBADOR		,	@PP_TIPO_ITEM
								INSERT INTO	ITEM_NOTIFICACION
								(	[K_ITEM]			,			
									[TIPO_NOTIFICACION]	,			
									[F_NOTIFICACION]	)
								VALUES	
								(	@PP_K_ITEM			,
									10					,
									GETDATE()			)
						END
				END
GO


-- //////////////////////////////////////////////////////////////
-- // PARA ENVIAR NOTIFICACIÓN DE STOCK MINIMO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_MULLER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_MULLER]
GO
--		 EXECUTE [dbo].[PG_NOTIFICAR_MULLER]	1,139, 1,1,3500,70
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_MULLER]
	@PP_K_SISTEMA_EXE			INT,
	-----=====================================================
	@PP_K_ITEM								INT,
	@PP_PART_NUMBER_ITEM_PEARL				VARCHAR(250),
	@PP_D_ITEM								VARCHAR(250),
	-----=====================================================
	@PP_TIPO_ITEM							VARCHAR(50)
AS	
DECLARE	 @VP_MENSAJE					NVARCHAR(MAX) = ''
		,@VP_QTY_STOCK_ALMACEN			DECIMAL(19,4)
		,@VP_QTY_MINIMA_ITEM			DECIMAL(19,4)
		--=================================================

	--================================================================
	--	SE OBTIENE LA CANTIDAD ACTUALMENTE DISPONIBLE EN LA LOCACIÓN DE PRODUCCIÓN.
		SELECT	@VP_QTY_STOCK_ALMACEN	=	ISNULL(	SUM(CANTIDAD_RECIBIDA)	, 0	)				
		FROM	INVENTARIO	(NOLOCK)										
		INNER JOIN FOLIO	(NOLOCK)	ON FOLIO.K_FOLIO	= INVENTARIO.K_FOLIO
		WHERE	K_LOCACION	= 4	-- LOCACIÓN DE PRODUCCIÓN
		AND		INVENTARIO.L_BORRADO	= 0
		AND		K_ITEM =	@PP_K_ITEM

	--================================================================
	--	PRIMERO SE VERIFICA LA TENDENCIA DE UTILIZACIÓN DE MATERIAL UTILIZADO, DEL DÍA ACTUAL A UN 35 ANTES, QUE ES EL TIEMPO APRÓXIMADO DE ENTREGA DE MATERIAL.
		SELECT	@VP_QTY_MINIMA_ITEM	= CANTIDAD_MINIMA
		FROM	COMPRAS.DBO.ITEM	(NOLOCK)
		WHERE	K_ITEM	= @PP_K_ITEM

			--================================================================
			--	SE REALIZA UNA COMPARACIÓN DE LA TENDENCIA DE USO CONTRA LA CANTIDAD EN STOCK EN PRODUCCIÓN.
				IF	@VP_QTY_MINIMA_ITEM > @VP_QTY_STOCK_ALMACEN
				BEGIN

					--================================================================
					--================================================================
					--	SE VERIFICA SI SE HA ENVIADO LA NOTIFICACIÓN DIARIA. EN CASO QUE SE HAYA REALIZADO OMITIRA EL ENVÍO DEL CORREO.
					IF	(	SELECT	COUNT(K_ITEM_NOTIFICACION)
							FROM	ITEM_NOTIFICACION (NOLOCK)
							WHERE	K_ITEM			= @PP_K_ITEM
							AND		F_NOTIFICACION	= FORMAT(GETDATE(),'yyyy-MM-dd')	)	<=	0
					BEGIN

						DECLARE	 @VP_K_TIPO_GRUPO_APROBADOR		VARCHAR(15)		= 8300		--	 GRUPO DE NOTIFICACION.
								
						EXECUTE	[PG_NOTIFICAR_CANTIDAD_MIN]		@PP_K_SISTEMA_EXE, --@PP_K_USUARIO_ACCION,
																-- =====================================
																@PP_PART_NUMBER_ITEM_PEARL		,	@PP_D_ITEM		,
																@VP_QTY_STOCK_ALMACEN		,
																@VP_QTY_MINIMA_ITEM			,	0					,
																@VP_K_TIPO_GRUPO_APROBADOR	,	@PP_TIPO_ITEM
					
								INSERT INTO	ITEM_NOTIFICACION
								(	[K_ITEM]			,			
									[TIPO_NOTIFICACION]	,			
									[F_NOTIFICACION]	)
								VALUES	
								(	@PP_K_ITEM			,
									10					,
									GETDATE()			)
					END
				END
GO


-- //////////////////////////////////////////////////////////////
-- // PARA ENVIAR NOTIFICACIÓN DE STOCK MINIMO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_CANTIDAD_MIN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_CANTIDAD_MIN]
GO
--		 EXECUTE [dbo].[PG_NOTIFICAR_CANTIDAD_MIN]	1,139, 1,1,3500,70
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_CANTIDAD_MIN]
	@PP_K_SISTEMA_EXE			INT,
	-----=====================================================
	@PP_PART_NUMBER_ITEM_PEARL				VARCHAR(250),
	@PP_D_ITEM								VARCHAR(250),
	@PP_QTY_STOCK_PRODUCCION				DECIMAL(19,2),
	@PP_QTY_CONSUMIDA_MES					DECIMAL(19,2),
	@PP_QTY_USO_DIARIA						DECIMAL(19,2),
	-----=====================================================
	@PP_K_TIPO_GRUPO_APROBADOR				VARCHAR(15),
	@PP_TIPO_ITEM							VARCHAR(50)
AS	
	-- ////////////////////////////////////////////////////////////////
	DECLARE	 @VP_SUBJECT				VARCHAR(255)	= ''
			,@VP_RECIPIENTS				NVARCHAR(MAX)	= ''
			,@VP_BODY_HTML				NVARCHAR(MAX)	= ''

	IF @PP_K_SISTEMA_EXE=0
	BEGIN
		SET @PP_K_TIPO_GRUPO_APROBADOR	= 0000
	END	

		SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
		FROM	BD_GENERAL.dbo.USUARIO_PEARL			(NOLOCK)	AS USERS
		INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR	(NOLOCK)	ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
		WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @PP_K_TIPO_GRUPO_APROBADOR
		AND		K_ESTATUS_GRUPO_APROBADOR = 1

		SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

		--SET @VP_SUBJECT	=	'['	+	CONVERT(VARCHAR(50),FORMAT(@PP_K_ORDEN_COMPRA_PEDIDO,'00000')) +']  ['	+	CONVERT(VARCHAR(50),@PP_NO_ENTREGA) + '] Material recibido con excedente.'
		SET @VP_SUBJECT	=	'['	+ @PP_PART_NUMBER_ITEM_PEARL + ']' + ' Cantidad mínima alcanzada.'
		
		IF	@PP_TIPO_ITEM	= 'HILO'
		BEGIN
			SET @VP_BODY_HTML = 
				N'<html>'+
				N'<head>'+		
				N'<style>'+
				N'table	{border: solid 1px;border-collapse:collapse; width: 50%; cellspacing="1"}'+
				N'th	{border: solid 1px;padding: 3px;text-align: "center";background:"#ADD8E6"; color:"#000000"}'+
				N'td	{border: solid 1px;padding: 3px;text-align: "center";background:"#48D1CC"; color:"#000000"}'+
				N'</style>'+
						
				N'</head>'+
				N'<body>'+

				N'<p style="color:black; font-size:14.0pt;font-family:"Calisto MT",serif">'+
				
				N'Se informa que: <br><br>'+
				N'En base al consumo realizado durante los últimos 30 días, se ha detectado que el stock del material <b>[ '+ @PP_D_ITEM +' ]</b> es menor a lo utilizado durante dicho período.<br>' +
				N'Se recomiendan tomar las medidas necesarias y considerar los tiempos de entrega para evitar faltante de materia prima.<br><br><br>'+
				--N'Se ha realizado una adición/modificación de compatibilidad de Lotes, del [ITEM] indicado en el asunto del correo.<br>'+		
				--N'La autorización la han realizado los usuarios: <br>'+
					N'<table>' +
						N'<thead>' + 
						  N'<tr>' + 
						    N'<th colspan="4">Tendencia de uso de material:</th>' + 
						  N'</tr>' + 
						  N'<tr>' +
							N'	<th width: 25%>   Cantidad Stock.									</th>	
								<th width: 25%>   Cantidad utilizada<br> los últimos 30 días.		</th>
								<th width: 25%>   Cantidad aproximada <br>de uso diario.			</th>
								<th width: 25%>   Unidad <br> de Medida.							</th>' + 
						  N'</tr>' + 
						N'</thead>' + 
						N'<tbody>' + 
							N'<tr>'+
							N'	<td>'+ CONVERT(VARCHAR(50),@PP_QTY_STOCK_PRODUCCION)		+ '</td>	
								<td>'+ CONVERT(VARCHAR(50),@PP_QTY_CONSUMIDA_MES)			+ '</td>
								<td>'+ CONVERT(VARCHAR(50),@PP_QTY_USO_DIARIA)				+ '</td>
								<td>'+ 'Rollos'												+ '</td>' +
						N'</tbody>' + 
					N'</table>'+
					N'<br>'+
					N'<b>NOTA:</b>A falta de una cantidad mínima base establecida, se considera la tendencia de uso de los ultimos 30 dias. <br><br>'+
				N'</body>'+
				N'</html>';
		END
		ELSE IF @PP_TIPO_ITEM	IN ('MULLER')
		BEGIN
			SET @VP_BODY_HTML = 
				N'<html>'+
				N'<head>'+		
				N'<style>'+
				N'table	{border: solid 1px;border-collapse:collapse; width: 45%; cellspacing="1"}'+
				N'th	{border: solid 1px;padding: 3px;text-align: "center";background:"#ADD8E6"; color:"#000000"}'+
				N'td	{border: solid 1px;padding: 3px;text-align: "center";background:"#48D1CC"; color:"#000000"}'+
				N'</style>'+
						
				N'</head>'+
				N'<body>'+

				N'<p style="color:black; font-size:14.0pt;font-family:"Calisto MT",serif">'+

				N'Se informa que: <br><br>'+
				N'Se ha detectado que el stock del ITEM: <br>' +
				N'<b>[ '+ @PP_D_ITEM +' ]</b> ha llegado a su cantidad mínima.<br>' +
				N'Se recomiendan tomar las medidas necesarias y considerar los tiempos de entrega para evitar faltante de materia prima.<br>'+
				N'<table>' +
					N'<thead>' + 
					  N'<tr>' + 
					    N'<th colspan="3">MULLER:</th>' + 
					  N'</tr>' + 
					  N'<tr>' +
						N'	<th width: 33%>   Cantidad Stock.								</th>	
							<th width: 33%>   Cantidad mínima <br>establecida en sistema.	</th>
							<th width: 33%>   Unidad <br>de Medida.							</th>' + 
					  N'</tr>' + 
					N'</thead>' + 
					N'<tbody>' + 
						N'<tr>'+
						N'	<td>'+ CONVERT(VARCHAR(50),@PP_QTY_STOCK_PRODUCCION)			+'</td>	
							<td>'+ CONVERT(VARCHAR(50),@PP_QTY_CONSUMIDA_MES)				+'</td>
							<td>'+ 'Yardas Líneales <br>(LY)'									+'</td>' +
					N'</tbody>' + 
				N'</table>'+
				N'</body>'+
				N'</html>';
		END
				
	EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
	@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
	@subject = @VP_SUBJECT,
	@body = @VP_BODY_HTML,  
	@body_format = 'HTML'		
	-- ///////////////////////////////////////////////////////////////
GO