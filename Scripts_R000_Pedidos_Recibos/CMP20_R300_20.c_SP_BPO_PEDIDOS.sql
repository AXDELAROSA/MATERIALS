-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		COMPRAS
-- // MODULE:			HEADER_PURCHASE_ORDER
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20200914
-- ////////////////////////////////////////////////////////////// 

 USE [COMPRAS]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO DE LOS PEDIDOS 
-- // REALIZADOS DE UNA BLANKET
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HEADER_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HEADER_BPO_PEDIDO]
GO
--		 EXECUTE [dbo].[PG_LI_HEADER_BPO_PEDIDO] 0,139,'',-1,null,null
CREATE PROCEDURE [dbo].[PG_LI_HEADER_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25),
	@PP_K_VENDOR					INT,
	@PP_F_INIT						DATE,
	@PP_F_FINISH					DATE
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_L_APLICAR_MAX_ROWS	INT=1		
	DECLARE @VP_LI_N_REGISTROS		INT =5000
	-- ///////////////////////////////////////////
	-- =========================================		
	DECLARE @VP_K_FOLIO				INT
	EXECUTE [BD_GENERAL].DBO.[PG_RN_OBTENER_ID_X_REFERENCIA]			
								@PP_BUSCAR,	@OU_K_ELEMENTO = @VP_K_FOLIO	OUTPUT
	-- =========================================		
	IF @VP_MENSAJE=''
	BEGIN
		--SET @VP_LI_N_REGISTROS = 0		
	SELECT		TOP (@VP_LI_N_REGISTROS)
				HEADER_BPO_PEDIDO.[K_HEADER_PURCHASE_ORDER]				
				,[K_ORDEN_COMPRA_PEDIDO]
				,HEADER_BPO_PEDIDO.[K_STATUS_BPO_PEDIDO]
				,D_STATUS_BPO_PEDIDO
				,HEADER_BPO_PEDIDO.[F_DATE_BPO_PEDIDO]
				,[C_BPO_PEDIDO]
				,HEADER_BPO_PEDIDO.K_VENDOR
				,HEADER_BPO_PEDIDO.K_CUSTOMER
				-- ============================
				,D_VENDOR
				,LTRIM(RTRIM(CUS_NO))	AS	D_CUSTOMER
				-- =============================	
				,D_PROGRAM
				,(CASE
					WHEN L_URGENTE=1 THEN  'SI'
					ELSE	'NO'
				 END)	AS L_URGENTE
				-- =============================	
	FROM		HEADER_PURCHASE_ORDER
	INNER JOIN 	VENDOR					ON VENDOR.K_VENDOR=HEADER_PURCHASE_ORDER.K_VENDOR
	INNER JOIN	DETAILS_BLANKET_PURCHASE_ORDER	ON HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER=DETAILS_BLANKET_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER
	INNER JOIN	HEADER_BPO_PEDIDO				ON	HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER=HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
	INNER JOIN	[DATA_02].[dbo].ARCUSFIL_SQL	ON	HEADER_BPO_PEDIDO.K_CUSTOMER=[DATA_02].[dbo].ARCUSFIL_SQL.A4GLIdentity	--CUSTOMER,
	INNER JOIN	STATUS_BPO_PEDIDO ON HEADER_BPO_PEDIDO.K_STATUS_BPO_PEDIDO=STATUS_BPO_PEDIDO.K_STATUS_BPO_PEDIDO
				-- =============================
	WHERE		(	HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER=@VP_K_FOLIO
				OR	HEADER_PURCHASE_ORDER.CONFIRMING_ORDER_WITH				LIKE '%'+@PP_BUSCAR+'%' 
				OR	HEADER_PURCHASE_ORDER.C_PURCHASE_ORDER					LIKE '%'+@PP_BUSCAR+'%' )
				-- =============================
	AND			( @PP_F_INIT IS NULL		OR	@PP_F_INIT<=HEADER_BPO_PEDIDO.F_DATE_BPO_PEDIDO)
	AND			( @PP_F_FINISH IS NULL		OR	@PP_F_FINISH>=HEADER_BPO_PEDIDO.F_DATE_BPO_PEDIDO)
				-- =============================
	AND			( @PP_K_VENDOR =-1			OR	HEADER_PURCHASE_ORDER.K_VENDOR=@PP_K_VENDOR )
				-- =============================
	AND			HEADER_PURCHASE_ORDER.L_BORRADO<>1 
	AND			HEADER_BPO_PEDIDO.L_BORRADO<>1
	ORDER BY	K_ORDEN_COMPRA_PEDIDO ,K_STATUS_BPO_PEDIDO, F_DATE_BPO_PEDIDO	DESC
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO DE LAS BLANKET PO
-- // QUE ESTAN ASIGNADAS A LOS PROVEEDORES
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_BPO_VENDOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_BPO_VENDOR]
GO
--		 EXECUTE [dbo].[PG_LI_BPO_VENDOR] 0,139,128
--		 EXECUTE [dbo].[PG_LI_BPO_VENDOR] 0,139,190
--		 EXECUTE [dbo].[PG_LI_BPO_VENDOR] 0,139,226
CREATE PROCEDURE [dbo].[PG_LI_BPO_VENDOR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_VENDOR					INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_L_APLICAR_MAX_ROWS	INT=1		
	DECLARE @VP_LI_N_REGISTROS		INT =5000
	-- ///////////////////////////////////////////
	-- =========================================		
	IF @VP_MENSAJE=''
	BEGIN
		--SET @VP_LI_N_REGISTROS = 0		
	SELECT		TOP (@VP_LI_N_REGISTROS)
				-- =============================	
				K_CUSTOMER
				,LTRIM(RTRIM(CUS_NO))	AS	D_CUSTOMER
				,D_VENDOR
				,D_PROGRAM
				-- =============================	
				,HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER
				-- =============================	
	FROM		HEADER_PURCHASE_ORDER
	INNER JOIN 	VENDOR					ON VENDOR.K_VENDOR=HEADER_PURCHASE_ORDER.K_VENDOR
	INNER JOIN	DETAILS_BLANKET_PURCHASE_ORDER	ON HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER=DETAILS_BLANKET_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER
	INNER JOIN	[DATA_02].[dbo].ARCUSFIL_SQL	ON	DETAILS_BLANKET_PURCHASE_ORDER.K_CUSTOMER=[DATA_02].[dbo].ARCUSFIL_SQL.A4GLIdentity	--CUSTOMER,
				-- =============================
	WHERE		HEADER_PURCHASE_ORDER.K_VENDOR=@PP_K_VENDOR
				-- =============================
	AND			HEADER_PURCHASE_ORDER.L_IS_BLANKET=1
	AND			HEADER_PURCHASE_ORDER.K_STATUS_PURCHASE_ORDER>=9
	AND			HEADER_PURCHASE_ORDER.L_BORRADO<>1
	ORDER BY	K_STATUS_PURCHASE_ORDER, F_DATE_PURCHASE_ORDER	DESC
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HEADER_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HEADER_BPO_PEDIDO]
GO
--		 EXECUTE [dbo].[PG_SK_HEADER_BPO_PEDIDO] 0,139,19,'00019-00001'
--		 EXECUTE [dbo].[PG_SK_HEADER_BPO_PEDIDO] 0,139,16,'00016-00001'
CREATE PROCEDURE [dbo].[PG_SK_HEADER_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER		INT,
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(50)
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		TOP (1)
				HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER,	HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO,
				-- ===========================	-- ===========================
				HEADER_PURCHASE_ORDER.K_VENDOR
				,HEADER_BPO_PEDIDO.K_VENDOR
				,D_VENDOR
				,K_CUSTOMER
				,LTRIM(RTRIM(CUS_NO))	AS	D_CUSTOMER
				-- ===========================	-- ===========================
				,F_DATE_BPO_PEDIDO
				,C_BPO_PEDIDO
				,L_URGENTE
				-- =============================	
	FROM		HEADER_BPO_PEDIDO
	INNER JOIN HEADER_PURCHASE_ORDER	ON HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER=HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
--				HEADER_PURCHASE_ORDER,
	INNER JOIN 	VENDOR					ON VENDOR.K_VENDOR=HEADER_PURCHASE_ORDER.K_VENDOR
--				VENDOR
	INNER JOIN	[DATA_02].[dbo].ARCUSFIL_SQL	ON	HEADER_BPO_PEDIDO.K_CUSTOMER=[DATA_02].[dbo].ARCUSFIL_SQL.A4GLIdentity	--CUSTOMER,
				-- =============================
	WHERE		HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=HEADER_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER
	AND			HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
	AND			HEADER_BPO_PEDIDO.L_BORRADO<>1		
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DETAILS_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_DETAILS_BPO_PEDIDO]
GO
--		 EXECUTE [dbo].[PG_SK_DETAILS_BPO_PEDIDO] 0,139,19,'00019-00001'
--		 EXECUTE [dbo].[PG_SK_DETAILS_BPO_PEDIDO] 0,139,16,'00016-00001'
CREATE PROCEDURE [dbo].[PG_SK_DETAILS_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER		INT,
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(50)
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		
				DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
				,DETAILS_BPO_PEDIDO.K_DETAILS_BPO_PEDIDO	--HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO
				,DETAILS_BPO_PEDIDO.K_ITEM
				-- ===========================	-- ===========================
				,S_UNIT_OF_MEASURE
				,PART_NUMBER_ITEM_VENDOR
				,PART_NUMBER_ITEM_PEARL
				,D_ITEM
				-- ===========================	-- ===========================
				,QUANTITY_ORDER
				-- =============================	
	FROM		DETAILS_BPO_PEDIDO
	INNER JOIN	ITEM		ON	DETAILS_BPO_PEDIDO.K_ITEM=ITEM.K_ITEM
	INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM=UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
	--,HEADER_BPO_PEDIDO
				-- =============================
	--WHERE		HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
	--AND			HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO
	WHERE		DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
	AND			DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
	--AND			HEADER_BPO_PEDIDO.L_BORRADO<>1		
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / CARGA LOS ARTÍCULOS DE 
-- // LA ORDEN DE COMPRA SELECCIONADA AL LISTADO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DETAILS_BPO_ITEMS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_DETAILS_BPO_ITEMS]
GO
--			   EXECUTE [PG_SK_DETAILS_BPO_ITEMS] 0,139,  19
--			   EXECUTE [PG_SK_DETAILS_BPO_ITEMS] 0,139,  16
CREATE PROCEDURE [dbo].[PG_SK_DETAILS_BPO_ITEMS]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER		INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_K_STATUS			INT
	-- ///////////////////////////////////////////
	SELECT		@VP_K_STATUS = K_STATUS_PURCHASE_ORDER
	FROM		HEADER_PURCHASE_ORDER
	WHERE		K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
	
	IF	@VP_K_STATUS >= 9
	BEGIN
		SELECT		TOP (5000)
					S_UNIT_OF_MEASURE
					,PART_NUMBER_ITEM_VENDOR
					,PART_NUMBER_ITEM_PEARL
					,D_ITEM
					-- ======================================================
					,0			AS QUANTITY_ORDER
					,K_DETAILS_PURCHASE_ORDER AS K_DETAILS_BPO_PEDIDO
					,K_HEADER_PURCHASE_ORDER
					,DETAILS_PURCHASE_ORDER.K_ITEM
					-- ======================================================
					--,DETAILS_PURCHASE_ORDER.*
		FROM		DETAILS_PURCHASE_ORDER
		INNER JOIN	ITEM		ON	DETAILS_PURCHASE_ORDER.K_ITEM=ITEM.K_ITEM
		INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM=UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
		INNER JOIN	BD_GENERAL.DBO.CURRENCY	ON	ITEM.K_CURRENCY=CURRENCY.K_CURRENCY
		WHERE		DETAILS_PURCHASE_ORDER.K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
		ORDER BY	K_DETAILS_PURCHASE_ORDER
	END
	
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DETALLES DEL PEDIDO
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_INUP_DETAILS_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_INUP_DETAILS_BPO_PEDIDO]
GO
CREATE PROCEDURE [dbo].[PG_INUP_DETAILS_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_K_HEADER_PURCHASE_ORDER				INT,
	@PP_K_ORDEN_COMPRA_PEDIDO				VARCHAR(50),
	@PP_K_DETAIL_ARRAY						NVARCHAR(MAX),
	@PP_ITEM_ARRAY							NVARCHAR(MAX),
	@PP_QUANTITY_ARRAY						NVARCHAR(MAX)
	-----=====================================================
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	-----=====================================================				
	DECLARE @VP_K_DETAIL_PO	INT = 1
	
	DECLARE @VP_POSICION_DETA	INT
	DECLARE @VP_POSICION_ITEM	INT
	DECLARE @VP_POSICION_QTY	INT
	DECLARE @VP_VALOR_DETA		VARCHAR(500)
	DECLARE @VP_VALOR_ITEM		VARCHAR(500)
	DECLARE @VP_VALOR_QTY		VARCHAR(500)
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_K_DETAIL_ARRAY	= @PP_K_DETAIL_ARRAY	+ '/'
	SET	@PP_ITEM_ARRAY		= @PP_ITEM_ARRAY		+ '/'
	SET	@PP_QUANTITY_ARRAY	= @PP_QUANTITY_ARRAY	+ '/'
		
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ITEM_ARRAY) <> 0
		BEGIN
			SELECT @VP_POSICION_DETA	=	patindex('%/%' , @PP_K_DETAIL_ARRAY	)
			SELECT @VP_POSICION_ITEM	=	patindex('%/%' , @PP_ITEM_ARRAY		)
			SELECT @VP_POSICION_QTY		=	patindex('%/%' , @PP_QUANTITY_ARRAY	)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_DETA		= LEFT(@PP_K_DETAIL_ARRAY	, @VP_POSICION_DETA	- 1)
			SELECT @VP_VALOR_ITEM		= LEFT(@PP_ITEM_ARRAY		, @VP_POSICION_ITEM		- 1)
			SELECT @VP_VALOR_QTY		= LEFT(@PP_QUANTITY_ARRAY	, @VP_POSICION_QTY		- 1)

			IF CAST(@VP_VALOR_QTY AS DECIMAL(19,4))<=0
			BEGIN
				--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
				SET @VP_MENSAJE='QUANTITY PER ITEM MUST BE MORE THAN 0 [ITEM#'+CONVERT(VARCHAR(10),@VP_VALOR_ITEM)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
			END

					INSERT INTO DETAILS_BPO_PEDIDO
						(
						[K_HEADER_PURCHASE_ORDER]		
						,[K_ORDEN_COMPRA_PEDIDO]			
						,[K_DETAILS_BPO_PEDIDO]			
						-- ============================	
						,[K_ITEM]												
						-- ============================
						,[QUANTITY_ORDER]
						,[QUANTITY_PENDING]
						-- ===========================
						,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
					VALUES
						(
						@PP_K_HEADER_PURCHASE_ORDER
						,@PP_K_ORDEN_COMPRA_PEDIDO
						,@VP_VALOR_DETA	
						-- ============================
						,@VP_VALOR_ITEM
						-- ============================
						,@VP_VALOR_QTY		--	CANTIDAD ORDENADA
						,@VP_VALOR_QTY		--	CANTIDAD PENDIENTE
						-- ============================
						,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL  )							
													
			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='The DETAIL_PURCHASE_ORDER was not inserted. [DETAIL#'+CONVERT(VARCHAR(10),@VP_VALOR_ITEM)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END
				
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_K_DETAIL_ARRAY	= STUFF(@PP_K_DETAIL_ARRAY	, 1, @VP_POSICION_DETA, '')
			SELECT @PP_ITEM_ARRAY		= STUFF(@PP_ITEM_ARRAY		, 1, @VP_POSICION_ITEM , '')
			SELECT @PP_QUANTITY_ARRAY	= STUFF(@PP_QUANTITY_ARRAY	, 1, @VP_POSICION_QTY  , '')
		END
	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////
-- //	CUERPO DEL MENSAJA A ENVIAR CUANDO UN MATERIAL
-- //	NO TIENE PARAMETROS PARA INSPECCIÓN.
-- ///////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CONFIGURAR_CORREO_MATERIAL_A_PEDIDO_NUEVO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_MATERIAL_A_PEDIDO_NUEVO]
GO
CREATE PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_MATERIAL_A_PEDIDO_NUEVO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_ITEM							INT
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_SUBJECT					VARCHAR(255)	= ''
	DECLARE @VP_RECIPIENTS				NVARCHAR(MAX)	= ''
	DECLARE @VP_BODY_HTML				NVARCHAR(MAX)	= ''
--	DECLARE @PP_K_ITEM							INT=35
	DECLARE @VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)		= 7899	--7800			CORREO PARA FRNAK EN PRUEBAS, AQUI VAN USARIOS DE CALIDAD.

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM		BD_GENERAL.dbo.USUARIO_PEARL AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
								--WHERE   GP_APROB.S_GRUPO_APROBADOR = 'MHI_MQU_LR'
								WHERE		GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @VP_K_TIPO_GRUPO_APROBADOR
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	DECLARE @VP_PART_NUMBER_ITEM_VENDOR		VARCHAR(500)
	DECLARE @VP_PART_NUMBER_ITEM_PEARL		VARCHAR(500)
	DECLARE @VP_D_ITEM						VARCHAR(500)
	
			SELECT	@VP_PART_NUMBER_ITEM_VENDOR=PART_NUMBER_ITEM_VENDOR,
					@VP_PART_NUMBER_ITEM_PEARL=PART_NUMBER_ITEM_PEARL,
					@VP_D_ITEM=D_ITEM
			FROM	ITEM
			WHERE	K_ITEM=@PP_K_ITEM

	SET @VP_SUBJECT	=	'['	+	@VP_PART_NUMBER_ITEM_VENDOR		+'] Material sin parametros para inspección de recibo.'
			
	SET @VP_BODY_HTML =  
		N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+
		N'Buen día, <br><br>'+
		N'Se ha creado un pedido del [ITEM]:<br>'+		
			N'<table  border="1" align="center" cellspacing="3" cellpadding="3" border="3">' + 
				N'<thead>' + 
				  N'<tr BGCOLOR="#ADD8E6">' + 
				    N'<th colspan="3">Material Solicitado</th>' + 
				  N'</tr>' + 
				  N'<tr BGCOLOR="#48D1CC">' + 
				    N'<th> ITEM_NUMBER_VENDOR </th><th> ITEM_NUMBER_PEARL </th><th> DESCRIPCIÓN </th>' + 
				  N'</tr>' + 
				N'</thead>' + 
				N'<tbody>' + 
				  N'<tr>' + 
					N'<td align="center">'	+ @VP_PART_NUMBER_ITEM_VENDOR +
					N'</td>' + 
					N'<td align="center">'	+ @VP_PART_NUMBER_ITEM_PEARL +
					N'</td>' + 
					N'<td align="left">'	+ @VP_D_ITEM +
					N'</td>' + 
				 N'</tr>' + 
				N'</tbody>' + 
			N'</table> <br>'+
		N'Y no tiene parametros para inspección de recibo.<br>'+
		N'Tomar las medidas pertinentes, para agregar los atributos necesarios para su revisión.<br><br>'
		
		EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
		@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
		@subject = @VP_SUBJECT,
		@body = @VP_BODY_HTML,  
		@body_format = 'HTML'

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // PARA ENVIAR NOTIFICACIÓN DE NUEVOS PRODUCTOS SOLICITADOS
-- //	Y QUE NO TIENEN CONFIGURACION GRABADA
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_PEDIDO]
GO
--		 EXECUTE [dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_PEDIDO]	1,139,  '39'
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_PEDIDO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_ITEM_ARRAY							NVARCHAR(MAX)
	-----=====================================================
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	-----=====================================================				
	DECLARE @VP_POSICION_ITEM	INT
	DECLARE @VP_VALOR_ITEM		VARCHAR(500)
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ITEM_ARRAY		= @PP_ITEM_ARRAY		+ '/'
		
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ITEM_ARRAY) <> 0
		BEGIN
			SELECT @VP_POSICION_ITEM	=	patindex('%/%' , @PP_ITEM_ARRAY		)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_ITEM		= LEFT(@PP_ITEM_ARRAY		, @VP_POSICION_ITEM		- 1)
			
			-- ====================================================================================
			--	VERIFICA SI EL MATERIAL TIENE PARAMETROS DEFINIDOS PARA LA INSPECCIÓN, EN CASO CONTRARIO
			--	NOTIFICA A CALIDAD PARA QUE INGRESE LOS ATRIBUTOS DE REVISIÓN NECESARIOS.
			DECLARE	@VP_EXISTE_EN_INSPECCION	INT

				SELECT	@VP_EXISTE_EN_INSPECCION=COUNT(K_ITEM)
				FROM	DATA_02.dbo.INSPECCION_MATERIAL
				WHERE	K_ITEM=@VP_VALOR_ITEM
				AND		K_ESTATUS_INSPECCION_MATERIAL=1


				IF @VP_EXISTE_EN_INSPECCION=0
				BEGIN
					EXECUTE [PG_CONFIGURAR_CORREO_MATERIAL_A_PEDIDO_NUEVO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @VP_VALOR_ITEM
				END
				
			-- ====================================================================================

			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ITEM_ARRAY		= STUFF(@PP_ITEM_ARRAY		, 1, @VP_POSICION_ITEM , '')
		END
	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_ITEM_PEDIDOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_ITEM_PEDIDOS]
GO

--		EXECUTE  [dbo].[PG_NOTIFICAR_ITEM_PEDIDOS]	0,139,'00023-00001',0, '[New]'
--		EXECUTE  [dbo].[PG_NOTIFICAR_ITEM_PEDIDOS]	0,139,'00023-00001',1,'[Update]'
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_ITEM_PEDIDOS]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN_COMPRA_PEDIDO				VARCHAR(50),
	@PP_L_URGENTE						INT,
	@PP_IS_UPDATE						VARCHAR(50) = ''
AS
	-- ///////////////////////////////////////////
	
	DECLARE @VP_SUBJECT		VARCHAR(255) = '['+@PP_ORDEN_COMPRA_PEDIDO+'] Material Request.' + @PP_IS_UPDATE
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = ''
	DECLARE @VP_BODY_HTML		NVARCHAR(MAX) 
	DECLARE @VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)		= 7801	--7899 --7801		MANUELG
	
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM		BD_GENERAL.dbo.USUARIO_PEARL AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
								WHERE		GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @VP_K_TIPO_GRUPO_APROBADOR
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
		
	SET @VP_BODY_HTML = N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="4">Items:</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>Part No.</th><th>Part No. PEARL</th><th>Quantity Order</th><th>Unit of measure</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
										CAST ( ( SELECT
													 td = RTRIM(LTRIM(PART_NUMBER_ITEM_VENDOR)), '',  
													 td = RTRIM(LTRIM(PART_NUMBER_ITEM_PEARL)), '',  
													 td = RTRIM(LTRIM(FORMAT(QUANTITY_ORDER,'0.00'))), '',  
													 td = RTRIM(LTRIM(S_UNIT_OF_MEASURE)), ''
												FROM		COMPRAS.dbo.DETAILS_BPO_PEDIDO
												INNER JOIN	COMPRAS.dbo.HEADER_BPO_PEDIDO  ON	DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
												INNER JOIN	COMPRAS.dbo.ITEM		ON	DETAILS_BPO_PEDIDO.K_ITEM=ITEM.K_ITEM
												INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM = UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
															-- =============================
												WHERE		DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=@PP_ORDEN_COMPRA_PEDIDO

								          FOR XML PATH('tr'), TYPE   
										) AS NVARCHAR(MAX) ) +  
								  N'</tr>' + 
									N'</tbody>' + 
								N'</table>' ; 
					SET ROWCOUNT 0
		 				
		DECLARE @VP_IMPORTANCE	VARCHAR(50)
		IF @PP_L_URGENTE =1 
		BEGIN
			SET @VP_IMPORTANCE='HIGH'
		END
		ELSE
		BEGIN
			SET @VP_IMPORTANCE= 'NORMAL'
		END

		EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
		@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
		@subject = @VP_SUBJECT,
		@body = @VP_BODY_HTML,  
		@body_format = 'HTML',
		@importance= @VP_IMPORTANCE
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERTA EL ENCABEZADO DEL PEDIDO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HEADER_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_HEADER_BPO_PEDIDO]
GO
--		EXECUTE [dbo].[PG_IN_HEADER_BPO]	1,139,  
--		16 , 226,18, '2020/09/26' , '1','39','1800'		
CREATE PROCEDURE [dbo].[PG_IN_HEADER_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER				[INT],
	@PP_C_PURCHASE_ORDER					[VARCHAR](255),
	-- ============================
	@PP_K_VENDOR							[INT],
	@PP_K_CUSTOMER							[INT],
	-- ============================
	@PP_F_DATE_BPO_PEDIDO					[DATE],
	-----=====================================================
	--	PARA DETAILS_PURCHASE_ORDER
	@PP_K_DETAIL_ARRAY						NVARCHAR(MAX),
	@PP_ITEM_ARRAY							NVARCHAR(MAX),
	@PP_QUANTITY_ARRAY						NVARCHAR(MAX),
	@PP_L_URGENTE							[INT]
	-----=====================================================
AS			
DECLARE @VP_MENSAJE						VARCHAR(500) = ''
DECLARE @VP_K_SIGUIENTE					INT
DECLARE @VP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(50) =  '' ;
BEGIN TRANSACTION 
BEGIN TRY
		-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
	BEGIN
		SELECT	@VP_K_SIGUIENTE=COUNT(K_ORDEN_COMPRA_PEDIDO)	
		FROM	HEADER_BPO_PEDIDO
		WHERE	K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER

	END

	IF @VP_MENSAJE=''
	BEGIN
		SELECT @VP_K_ORDEN_COMPRA_PEDIDO= FORMAT(@PP_K_HEADER_PURCHASE_ORDER,'00000') + '-' + FORMAT(@VP_K_SIGUIENTE+1,'00000')
				
	--============================================================================
	--======================================INSERTAR EL HEADER_BPO_PEDIDO
	--============================================================================
		INSERT INTO HEADER_BPO_PEDIDO
			(	[K_HEADER_PURCHASE_ORDER]
				,[K_ORDEN_COMPRA_PEDIDO]
				,[C_BPO_PEDIDO]
				-- ============================
				,[K_VENDOR]
				,[K_CUSTOMER]
				-- ============================
				,[K_STATUS_BPO_PEDIDO]
				-- ============================
				,[F_DATE_BPO_PEDIDO]
				,[L_URGENTE]
				-- ===========================
				,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	@PP_K_HEADER_PURCHASE_ORDER
				,@VP_K_ORDEN_COMPRA_PEDIDO
				,@PP_C_PURCHASE_ORDER
				-- ============================				
				,@PP_K_VENDOR	
				,@PP_K_CUSTOMER
				-- ============================
				,1
				-- ============================
				,@PP_F_DATE_BPO_PEDIDO
				,@PP_L_URGENTE
				-- ============================
				,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='The BPO_PEDIDO was not inserted. [ORDEN_COMPRA_PEDIDO#'+CONVERT(VARCHAR(10),@VP_K_ORDEN_COMPRA_PEDIDO)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END				
	END


	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE		[dbo].[PG_INUP_DETAILS_BPO_PEDIDO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															-----=====================================================
															@PP_K_HEADER_PURCHASE_ORDER,	@VP_K_ORDEN_COMPRA_PEDIDO,
															@PP_K_DETAIL_ARRAY, @PP_ITEM_ARRAY,		@PP_QUANTITY_ARRAY
	END

	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE	[PG_NOTIFICAR_PRODUCTO_NUEVO_PEDIDO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @PP_ITEM_ARRAY
	END

	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE	[PG_NOTIFICAR_ITEM_PEDIDOS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @VP_K_ORDEN_COMPRA_PEDIDO, @PP_L_URGENTE, '[New]'
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
		SET		@VP_MENSAJE = 'Not is possible [Insert] at [BPO]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_ORDEN_COMPRA_PEDIDO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZA EL ENCABEZADO DEL PEDIDO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HEADER_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_HEADER_BPO_PEDIDO]
GO
--		 EXECUTE [dbo].[PG_UP_HEADER_BPO]	1,139,  
--		'78' , '' , '2020/09/15' , 
CREATE PROCEDURE [dbo].[PG_UP_HEADER_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER				[INT],
	@PP_K_ORDEN_COMPRA_PEDIDO				[VARCHAR](50),
	@PP_C_PURCHASE_ORDER					[VARCHAR](255),
	-- ============================
	@PP_K_VENDOR							[INT],
	@PP_K_CUSTOMER							[INT],
	-- ============================
	@PP_F_DATE_BPO_PEDIDO					[DATE],
	-----=====================================================
	--	PARA DETAILS_PURCHASE_ORDER
	@PP_K_DETAIL_ARRAY						NVARCHAR(MAX),
	@PP_ITEM_ARRAY							NVARCHAR(MAX),
	@PP_QUANTITY_ARRAY						NVARCHAR(MAX),
	@PP_L_URGENTE							[INT]
	-----=====================================================
AS			
DECLARE @VP_MENSAJE						VARCHAR(500) = ''
BEGIN TRANSACTION 
BEGIN TRY
		-- /////////////////////////////////////////////////////////////////////
	DECLARE @VP_NO_EDITABLE					INT
	SET @VP_NO_EDITABLE= ISNULL((		SELECT	COUNT(K_DETAILS_BPO_RECIBO)
										FROM	DETAILS_BPO_RECIBO
										WHERE	K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO ),0)

	IF @VP_NO_EDITABLE >0
	BEGIN
		--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
		SET @VP_MENSAJE='The BPO_PEDIDO was not updated. Material has already been received. [ORDEN_COMPRA_PEDIDO#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_COMPRA_PEDIDO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
	END

	IF @VP_MENSAJE=''
	BEGIN		
	--============================================================================
	--======================================INSERTAR EL HEADER_BPO_PEDIDO
	--============================================================================
		UPDATE	HEADER_BPO_PEDIDO
		SET					
				[C_BPO_PEDIDO]						= @PP_C_PURCHASE_ORDER
				-- ============================		= -- ============================
				,[K_VENDOR]							= @PP_K_VENDOR
				,[K_CUSTOMER]						= @PP_K_CUSTOMER
				-- ============================		= -- ============================
				,[K_STATUS_BPO_PEDIDO]				= 1
				-- ============================		= -- ============================
				,[F_DATE_BPO_PEDIDO]				= @PP_F_DATE_BPO_PEDIDO
				,[L_URGENTE]						= @PP_L_URGENTE
				-- ============================		= -- ============================
				,[F_CAMBIO]							= GETDATE()
				,[K_USUARIO_CAMBIO]					= @PP_K_USUARIO_ACCION
		WHERE	[K_HEADER_PURCHASE_ORDER]= @PP_K_HEADER_PURCHASE_ORDER
		AND		[K_ORDEN_COMPRA_PEDIDO]= @PP_K_ORDEN_COMPRA_PEDIDO	

			IF @@ROWCOUNT = 0
				BEGIN
					--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
					SET @VP_MENSAJE='The BPO_PEDIDO was not updated. [ORDEN_COMPRA_PEDIDO#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_COMPRA_PEDIDO)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
				END				
	END

		DELETE 
		FROM	DETAILS_BPO_PEDIDO
		WHERE	[K_HEADER_PURCHASE_ORDER]= @PP_K_HEADER_PURCHASE_ORDER
		AND		[K_ORDEN_COMPRA_PEDIDO]= @PP_K_ORDEN_COMPRA_PEDIDO

	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE		[dbo].[PG_INUP_DETAILS_BPO_PEDIDO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															-----=====================================================
															@PP_K_HEADER_PURCHASE_ORDER,	@PP_K_ORDEN_COMPRA_PEDIDO,
															@PP_K_DETAIL_ARRAY, @PP_ITEM_ARRAY,		@PP_QUANTITY_ARRAY
	END

	IF @VP_MENSAJE=''
	BEGIN
		EXECUTE	[PG_NOTIFICAR_ITEM_PEDIDOS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @PP_K_ORDEN_COMPRA_PEDIDO, @PP_L_URGENTE, '[Update]'
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
		SET		@VP_MENSAJE = 'Not is possible [Update] at [BPO]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ORDEN_COMPRA_PEDIDO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
--	EXECUTE [dbo].[PG_DL_HEADER_PURCHASE_ORDER] 0,139,380,2,2
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_HEADER_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_HEADER_BPO_PEDIDO]
GO
CREATE PROCEDURE [dbo].[PG_DL_HEADER_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER		[INT],
	@PP_K_ORDEN_COMPRA_PEDIDO		[VARCHAR](50)
AS
DECLARE @VP_MENSAJE				VARCHAR(300) = ''
BEGIN TRANSACTION 
BEGIN TRY
	--////////////////////////////////////////////////////////////
	DECLARE @VP_NO_EDITABLE				INT
	SET @VP_NO_EDITABLE= ISNULL((		SELECT	COUNT(K_DETAILS_BPO_RECIBO)
										FROM	DETAILS_BPO_RECIBO
										WHERE	K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO ),0)

	IF @VP_NO_EDITABLE >0
	BEGIN
		--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
		SET @VP_MENSAJE='The BPO_PEDIDO was not updated. Material has already been received. [ORDEN_COMPRA_PEDIDO#'+CONVERT(VARCHAR(10),@PP_K_ORDEN_COMPRA_PEDIDO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
	END

	IF @VP_MENSAJE=''
	BEGIN		
		UPDATE	HEADER_BPO_PEDIDO
		SET		
				[L_BORRADO]				= 1,
				-- ====================
				[F_BAJA]				= GETDATE(), 
				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
		WHERE	[K_HEADER_PURCHASE_ORDER]= @PP_K_HEADER_PURCHASE_ORDER
		AND		[K_ORDEN_COMPRA_PEDIDO]= @PP_K_ORDEN_COMPRA_PEDIDO	
		IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='The BPO_PEDIDO was not updated. [ORDEN_COMPRA_PEDIDO#'+CONVERT(VARCHAR(10),@PP_K_HEADER_PURCHASE_ORDER)+']'
			END
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
		SET		@VP_MENSAJE = 'Not is possible [Update] at [ORDEN_COMPRA_PEDIDO]: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HEADER_PURCHASE_ORDER AS CLAVE
	-- //////////////////////////////////////////////////////////////
	
	-- //////////////////////////////////////////////////////////////	
GO


-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////


-- //												COMIENZA SECCIÓN DE RECIBOSS


-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / PARA MOSTRAR EL DETALLE 
-- // DE LA ORDEN PEDIDO CON LAS CANTIDADES RECIBIDAS Y PEDIDAS.
-- // ES EL SEGUNDO LISTADO DE LA PANTALLA DE RECIBOS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD]
GO
--		 EXECUTE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD] 0,139,19,'00019-00001'
--		 EXECUTE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD] 0,139,16,'00016-00001'
--		 EXECUTE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD] 0,139,18,'00018-00001'
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER		INT,
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(50)
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		
				 K_ORDEN_COMPRA_PEDIDO
				,DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
				,DETAILS_BPO_PEDIDO.K_DETAILS_BPO_PEDIDO	--HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO
				,DETAILS_BPO_PEDIDO.K_ITEM
				-- ===========================	-- ===========================
				,S_UNIT_OF_MEASURE
				,PART_NUMBER_ITEM_VENDOR
				,PART_NUMBER_ITEM_PEARL
				,D_ITEM
				-- ===========================	-- ===========================
				,QUANTITY_ORDER
				,(	
					SELECT	ISNULL(SUM(QUANTITY_RECEIVED),0)
					FROM	DETAILS_BPO_RECIBO
					INNER JOIN ITEM AS I ON	DETAILS_BPO_PEDIDO.K_ITEM=I.K_ITEM
					WHERE	K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER 
					AND		K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
					AND		DETAILS_BPO_RECIBO.K_ITEM=I.K_ITEM
					) AS QUANTITY_RECEIVED
				-- =============================	
	FROM		DETAILS_BPO_PEDIDO
	INNER JOIN	ITEM 		ON	DETAILS_BPO_PEDIDO.K_ITEM=ITEM.K_ITEM
	INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM=UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
	--,HEADER_BPO_PEDIDO
				-- =============================
	--WHERE		HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
	--AND			HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO
	WHERE		DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
	AND			DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
	--AND			HEADER_BPO_PEDIDO.L_BORRADO<>1		
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA PARA MOSTRAR EL DETALLADO
-- // DE ARTICULOS RECIBIDOS CON EL NÚMERO DE SERIE ESCANEADO Y 
-- // LA CANTIDAD RECIBIDA, ES LA FICHA DE LA PANTALLA DE RECIBOS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD_SERIES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD_SERIES]
GO
--		 EXECUTE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD_SERIES] 0,139,19,'00019-00001',36
--		 EXECUTE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD_SERIES] 0,139,16,'00016-00001',35	
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_PEDIDO_CANTIDAD_SERIES]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_PURCHASE_ORDER		INT,
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(50),
	@PP_K_ITEM						INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''	
	-- ///////////////////////////////////////////			
	SELECT		
				 DETAILS_BPO_RECIBO.K_HEADER_PURCHASE_ORDER
				,DETAILS_BPO_RECIBO.K_ITEM
				-- ===========================	-- ===========================
				,S_UNIT_OF_MEASURE
				,PART_NUMBER_ITEM_VENDOR
				,PART_NUMBER_ITEM_PEARL
				,D_ITEM
				-- ===========================	-- ===========================
				,SERIE_NO
				,LOTE_VENDOR
				,LOTE_PEARL
				,DETAILS_BPO_RECIBO.F_ALTA
				,QUANTITY_RECEIVED
				,L_ES_BORRABLE
				-- =============================	
	FROM		DETAILS_BPO_RECIBO --DETAILS_BPO_PEDIDO
	INNER JOIN	ITEM		ON	DETAILS_BPO_RECIBO.K_ITEM=ITEM.K_ITEM
	INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM=UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
				-- =============================
	--WHERE		HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER=DETAILS_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
	--AND			HEADER_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO
	WHERE		DETAILS_BPO_RECIBO.K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
	AND			DETAILS_BPO_RECIBO.K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
	AND			DETAILS_BPO_RECIBO.K_ITEM=@PP_K_ITEM
	--AND			HEADER_BPO_PEDIDO.L_BORRADO<>1		
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / CARGA LOS ARTÍCULOS DE 
-- // LA ORDEN DE COMPRA SELECCIONADA AL LISTADO.
-- // SE UTILIZA CUANDO SE DA ENTER EN EL TB DE CODE2D
-- // Y EL ENCABEZADO 
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ITEM_PARA_RECIBOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ITEM_PARA_RECIBOS]
GO
--			   EXECUTE [PG_SK_ITEM_PARA_RECIBOS] 0,139,  '00016-00001',35
--			   EXECUTE [PG_SK_ITEM_PARA_RECIBOS] 0,139,  '00019-00001',36
--			   EXECUTE [PG_SK_ITEM_PARA_RECIBOS] 0,139,  '00019-00001',35
CREATE PROCEDURE [dbo].[PG_SK_ITEM_PARA_RECIBOS]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(50),
	@PP_K_ITEM						INT
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_K_STATUS			INT
	-- ///////////////////////////////////////////
	--SELECT		@VP_K_STATUS = K_STATUS_PURCHASE_ORDER
	--FROM		HEADER_PURCHASE_ORDER
	--WHERE		K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
	
	--IF	@VP_K_STATUS >= 9
	--BEGIN
		SELECT		TOP (1)
					S_UNIT_OF_MEASURE
					,PART_NUMBER_ITEM_VENDOR
					,PART_NUMBER_ITEM_PEARL
					,D_ITEM
					-- ======================================================
					,-1			AS QUANTITY_RECEIVED
					,K_DETAILS_BPO_PEDIDO
					,K_HEADER_PURCHASE_ORDER
					,K_ORDEN_COMPRA_PEDIDO
					,DETAILS_BPO_PEDIDO.K_ITEM
					-- ======================================================
					--,DETAILS_PURCHASE_ORDER.*
		FROM		DETAILS_BPO_PEDIDO
		INNER JOIN	ITEM		ON	DETAILS_BPO_PEDIDO.K_ITEM=ITEM.K_ITEM
		INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM=UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
		INNER JOIN	BD_GENERAL.DBO.CURRENCY	ON	ITEM.K_CURRENCY=CURRENCY.K_CURRENCY
		WHERE		DETAILS_BPO_PEDIDO.K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
		AND			DETAILS_BPO_PEDIDO.K_ITEM=@PP_K_ITEM
	--END	
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // 
-- // PARA ENVIAR NOTIFICACIÓN DE PRODUCTOS RECIBIDOS
-- // 
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_RECIBO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_RECIBO]
GO
--		 EXECUTE [dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_RECIBO]	1,139, '00023-00001',3
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_PRODUCTO_NUEVO_RECIBO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(250),
	@PP_NO_ENTREGA					VARCHAR(50)
	-----=====================================================
AS	
	-- ////////////////////////////////////////////////////////////////
	DECLARE @VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)		= 7899	--7900
	DECLARE @VP_SUBJECT					VARCHAR(255)	= ''
	DECLARE @VP_RECIPIENTS				NVARCHAR(MAX)	= ''
	DECLARE @VP_BODY_HTML				NVARCHAR(MAX)	= ''

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM		BD_GENERAL.dbo.USUARIO_PEARL AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
								WHERE		GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @VP_K_TIPO_GRUPO_APROBADOR
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	--DECLARE @VP_PART_NUMBER_ITEM_VENDOR		VARCHAR(500)
	--DECLARE @VP_PART_NUMBER_ITEM_PEARL		VARCHAR(500)
	--DECLARE @VP_D_ITEM						VARCHAR(500)
	
	--		SELECT	@VP_PART_NUMBER_ITEM_VENDOR=PART_NUMBER_ITEM_VENDOR,
	--				@VP_PART_NUMBER_ITEM_PEARL=PART_NUMBER_ITEM_PEARL,
	--				@VP_D_ITEM=D_ITEM
	--		FROM	ITEM
	--		WHERE	K_ITEM=35--@PP_K_ITEM

	SET @VP_SUBJECT	=	'['	+	@PP_K_ORDEN_COMPRA_PEDIDO +']  ['	+	@PP_NO_ENTREGA + '] Material recibido para inspeccionar.'
			
	SET @VP_BODY_HTML =  
		N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+
		N'Buen día, <br><br>'+
		N'Se ha realizado la recepción de:<br>'+		
		N'<table  border="1" align="center" cellspacing="3" cellpadding="3" border="3">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="2">Material Recibido</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>#No. ENTREGA</th><th>#No. ORDEN PEDIDO</th>' + 
									  N'</tr>' +  
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
										N'<td align="center">'+ @PP_NO_ENTREGA +
										N'</td>' + 
										N'<td align="center">' + @PP_K_ORDEN_COMPRA_PEDIDO +
										N'</td>' + 
								  N'</tr>' + 
									N'</tbody>' + 
								N'</table> <br>'+		
		N'Tomar las medidas necesarias para su revisión.<br><br>'
		
		EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
		@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
		@subject = @VP_SUBJECT,
		@body = @VP_BODY_HTML,  
		@body_format = 'HTML'		
	-- ///////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DETALLES DEL MATERIAL RECIBIDO
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_ASIGNAR_LOTE_PEARL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_ASIGNAR_LOTE_PEARL]
GO
--	     EXECUTE [dbo].[PG_ASIGNAR_LOTE_PEARL]	0,139,  16 , 35 , 23414404
CREATE PROCEDURE [dbo].[PG_ASIGNAR_LOTE_PEARL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_K_HEADER_PURCHASE_ORDER				INT,
	@PP_K_ITEM								INT,
	@PP_LOTE_VENDOR							VARCHAR(50),
	@PP_LOTE_PEARL							INT			OUTPUT,
	@PP_LOTE_NUMERO_CONSECUTIVO				INT			OUTPUT
	-----=====================================================
AS
DECLARE @VP_LOTE_PEARL					INT=0		-- PARA ASIGNAR EL LOTE PEARL
DECLARE @VP_LOTE_NUMERO_CONSECUTIVO		INT		-- PARA ASIGNAR EL CONSECUTIVO DEL LOTE PEARL
--============================================================================
--	SE REALIZA LA ASIGNACIÓN DEL LOTE_PEARL:
--	SE VERIFICA SI EXISTEN REGISTROS DEL MISMO ITEM, CON EL MISMO LOTE_VENDOR
--	EN CASO DE SER ASÍ SE LE ASIGNA UN NUEVO CONSECUTIVO, 
--	EN CASO CONTRARIO EL CONSECUTIVO INICIA EN 1

DECLARE	@VP_EXISTE_LOTE_VENDOR			INT
DECLARE	@VP_EXISTE_LOTE_PEARL			INT

	SET @VP_EXISTE_LOTE_VENDOR=	ISNULL((SELECT	COUNT(LOTE_VENDOR)
										FROM	DATA_02.DBO.INVENTARIO
										WHERE	K_ITEM=@PP_K_ITEM
										AND		LTRIM(RTRIM(LOTE_VENDOR))=@PP_LOTE_VENDOR
										),0)

	IF @VP_EXISTE_LOTE_VENDOR<=0
	BEGIN						
			DECLARE	@VP_CONSECUTIVO_NUEVO_LOTE	INT=1
			
			WHILE @VP_LOTE_PEARL <> -1
			BEGIN					
				--SET @VP_LOTE_PEARL= CONCAT ( '20', '09')
				SET @VP_LOTE_PEARL= CONCAT ( RIGHT((YEAR(GETDATE())),2), FORMAT(MONTH(GETDATE()),'00'))
				SET @VP_LOTE_PEARL= CONCAT(@VP_LOTE_PEARL,FORMAT(@VP_CONSECUTIVO_NUEVO_LOTE,'00000'))
							
					SET @VP_EXISTE_LOTE_PEARL=ISNULL( (	SELECT	COUNT(LOTE_PEARL)													
														--SELECT	COUNT(distinct(LOTE_PEARL))
														FROM	DATA_02.DBO.INVENTARIO
														WHERE	LOTE_PEARL=@VP_LOTE_PEARL		--WHERE	LOTE_PEARL=@VP_LOTE_PEARL										
														),0)
					
					IF @VP_EXISTE_LOTE_PEARL>0
					BEGIN
						SET @VP_CONSECUTIVO_NUEVO_LOTE += 1
						SET @VP_LOTE_PEARL=0
					END
					ELSE
					BEGIN
						BREAK
					END
			END
			
			SET @VP_LOTE_NUMERO_CONSECUTIVO=1
	END
	ELSE
	BEGIN			
			SELECT TOP(1)	@VP_LOTE_PEARL=(LOTE_PEARL),
							@VP_LOTE_NUMERO_CONSECUTIVO=(LOTE_NUMERO_CONSECUTIVO)+1
			FROM	DATA_02.DBO.INVENTARIO
			WHERE	K_ITEM=@PP_K_ITEM
			AND		LOTE_VENDOR=@PP_LOTE_VENDOR
			ORDER BY LOTE_NUMERO_CONSECUTIVO DESC							
	END
	
	SET @PP_LOTE_PEARL=@VP_LOTE_PEARL
	SET @PP_LOTE_NUMERO_CONSECUTIVO=@VP_LOTE_NUMERO_CONSECUTIVO
GO




-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DETALLES DEL MATERIAL RECIBIDO
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_INUP_DETAILS_BPO_RECIBO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_INUP_DETAILS_BPO_RECIBO]
GO
-- EXECUTE	[dbo].[PG_INUP_DETAILS_BPO_RECIBO]	0,139,  '16' , '00016-00001' , '35' , '100.00/50.00' , '0/0' , '23414400/23414400' 
CREATE PROCEDURE [dbo].[PG_INUP_DETAILS_BPO_RECIBO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-----=====================================================
	@PP_K_HEADER_PURCHASE_ORDER				INT,
	@PP_K_ORDEN_COMPRA_PEDIDO				VARCHAR(50),
	@PP_K_ITEM								INT,
	@PP_QTTY_ARRAY							NVARCHAR(MAX),
	@PP_INUP_ARRAY							NVARCHAR(MAX),
	@PP_LOTE_ARRAY							NVARCHAR(MAX),
	@PP_SERI_ARRAY							NVARCHAR(MAX)
	-----=====================================================
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	-----=====================================================				
BEGIN TRANSACTION 
BEGIN TRY	
	DECLARE @VP_ENTREGA_NO				INT,		--PARA LA ASIGNACIÓN DEL NÚMERO DE ENTREGA
			@VP_TOTAL_PENDIENTE			DECIMAL(19,4),
			@VP_K_DETAILS_BPO_RECIBO	INT,
	
			@VP_POSICION_QTTY			INT,
			@VP_POSICION_INUP			INT,
			@VP_POSICION_LOTE			INT,
			@VP_POSICION_SERI			INT,
			@VP_VALOR_QTTY				VARCHAR(500),
			@VP_VALOR_INUP				VARCHAR(500),
			@VP_VALOR_LOTE				VARCHAR(500),
			@VP_VALOR_SERI				VARCHAR(500)
	-----==========================================================================================================
	--	SE REALIZA UN SELECT PARA OBTENER LOS TOTALES PENDIENTES DE LOS ITEM A RECIBIR: 
	--	EN CASO DE NO EXISTIR UN VALOR PARA EL SELECT SE ENVIARÁ UNA 'X' QUE MANDARA EL ERROR AL FRONT.
	--	EN CASO DE OBTENER UN VALOR DE '00' SE ENVIARÁ MENSAJE DE MATERIAL COMPLETO.
	--	EN CASO CONTRARIO REALIZARÁ LA ACCIÓN.
	IF @VP_MENSAJE=''
	BEGIN
		SET @VP_TOTAL_PENDIENTE=	(
												(	SELECT	QUANTITY_ORDER
													FROM	DETAILS_BPO_PEDIDO
													WHERE	K_HEADER_PURCHASE_ORDER	=@PP_K_HEADER_PURCHASE_ORDER
													AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
													AND		K_ITEM					=@PP_K_ITEM		)
											-
												ISNULL(
												(	SELECT	SUM(QUANTITY_RECEIVED)
												FROM	DETAILS_BPO_RECIBO
												WHERE	K_HEADER_PURCHASE_ORDER	=@PP_K_HEADER_PURCHASE_ORDER
												AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
												AND		K_ITEM					=@PP_K_ITEM		)
												,0)
									)
		IF @VP_TOTAL_PENDIENTE=NULL
		BEGIN
			--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
			SET @VP_MENSAJE='Record not found. [PO#'+CONVERT(VARCHAR(15),@PP_K_ORDEN_COMPRA_PEDIDO)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		END
	END

	IF @VP_TOTAL_PENDIENTE<0
	BEGIN
		--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
		SET @VP_MENSAJE='Total cannot be negative. [PO#'+CONVERT(VARCHAR(15),@PP_K_ORDEN_COMPRA_PEDIDO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
	END
	ELSE IF @VP_TOTAL_PENDIENTE=0
	BEGIN
		--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
		SET @VP_MENSAJE='The order not required more ITEMS. [PO#'+CONVERT(VARCHAR(15),@PP_K_ORDEN_COMPRA_PEDIDO)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
	END
	ELSE IF @VP_TOTAL_PENDIENTE>0
	BEGIN
			-----==========================================================================================================
			--	SE REALIZA UN SELECT PARA IDENTIFICAR EL NÚMERO DE ENTREGA A LA QUE PERTENECE EL RECIBO DEL MATERIAL EN CURSO.
			--	SE VA SUMANDO UNA UNIDAD A CADA CONJUNTO DE ENTREGAS RECIBIDAS. ESTO ES POR ARTÍCULO.
			SET @VP_ENTREGA_NO=		(ISNULL((
											SELECT	COUNT(DISTINCT(K_ENTREGA))
											FROM	DETAILS_BPO_RECIBO
											WHERE	K_HEADER_PURCHASE_ORDER=@PP_K_HEADER_PURCHASE_ORDER
											AND		K_ORDEN_COMPRA_PEDIDO=@PP_K_ORDEN_COMPRA_PEDIDO
									),0)	) + 1
			-----==========================================================================================================
		-- INICIO DEL INSERT CON ARREGLO
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_QTTY_ARRAY	= @PP_QTTY_ARRAY	+ '/'
		SET	@PP_INUP_ARRAY	= @PP_INUP_ARRAY	+ '/'
		SET	@PP_LOTE_ARRAY	= @PP_LOTE_ARRAY	+ '/'
		SET	@PP_SERI_ARRAY	= @PP_SERI_ARRAY	+ '/'
			
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_QTTY_ARRAY) <> 0
			BEGIN
				SELECT @VP_POSICION_QTTY	=	patindex('%/%' , @PP_QTTY_ARRAY )
				SELECT @VP_POSICION_INUP	=	patindex('%/%' , @PP_INUP_ARRAY	)
				SELECT @VP_POSICION_LOTE	=	patindex('%/%' , @PP_LOTE_ARRAY	)
				SELECT @VP_POSICION_SERI	=	patindex('%/%' , @PP_SERI_ARRAY	)

				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_QTTY		= LEFT(@PP_QTTY_ARRAY	, @VP_POSICION_QTTY	- 1)
				SELECT @VP_VALOR_INUP		= LEFT(@PP_INUP_ARRAY	, @VP_POSICION_INUP	- 1)
				SELECT @VP_VALOR_LOTE		= LEFT(@PP_LOTE_ARRAY	, @VP_POSICION_LOTE	- 1)
				SELECT @VP_VALOR_SERI		= LEFT(@PP_SERI_ARRAY	, @VP_POSICION_SERI	- 1)

				-----====================================================
				--	EL VALOR_INUP, ES UN IDENTIFICADOR QUE SE ENVÍA DEL FRONT PARA CONOCER CUALES ITEM NO DEBEN SER INSERTADOS
				--	YA QUE SE MOSTRARÓN EN EL LISTADO POR SER PARTE DEL HISTORIAL DE RECIBOS DEL ARTÍCULO EN RECEPCIÓN.
				IF @VP_VALOR_INUP=0
				BEGIN
				
				DECLARE @VP_LOTE_PEARL INT =-1
				DECLARE @VP_LOTE_NUMERO_CONSECUTIVO INT =-1

				EXECUTE [dbo].[PG_ASIGNAR_LOTE_PEARL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
														-- =====================================
														@PP_K_HEADER_PURCHASE_ORDER				
														,@PP_K_ITEM								
														,@VP_VALOR_LOTE							
														,@PP_LOTE_PEARL					=	@VP_LOTE_PEARL					OUTPUT		
														,@PP_LOTE_NUMERO_CONSECUTIVO	=	@VP_LOTE_NUMERO_CONSECUTIVO		OUTPUT				

						
					IF @VP_LOTE_PEARL<>-1	AND		@VP_LOTE_NUMERO_CONSECUTIVO<>-1
					BEGIN
						INSERT INTO DETAILS_BPO_RECIBO
							(
							[K_HEADER_PURCHASE_ORDER]		
							,[K_ORDEN_COMPRA_PEDIDO]			
							,[K_ENTREGA]			
							-- ============================	
							,[K_ITEM]												
							-- ============================
							,[QUANTITY_RECEIVED]
							-- ============================
							,[SERIE_NO]
							,[LOTE_VENDOR]
							,[LOTE_PEARL]
							-- ============================
							,[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
							[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
						VALUES
							(
							@PP_K_HEADER_PURCHASE_ORDER
							,@PP_K_ORDEN_COMPRA_PEDIDO
							,@VP_ENTREGA_NO
							-- ============================
							,@PP_K_ITEM
							-- ============================
							,@VP_VALOR_QTTY
							-- ============================
							,@VP_VALOR_SERI
							,@VP_VALOR_LOTE
							,@VP_LOTE_PEARL
							-- ============================
							,@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
							0, NULL, NULL  )							
														
							IF @@ROWCOUNT = 0
							BEGIN
								--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
								SET @VP_MENSAJE='The DETAIL RECEIVED was not inserted. [QTTY#'+CONVERT(VARCHAR(10),@VP_VALOR_QTTY)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
							END
							ELSE
							BEGIN
								SELECT @VP_K_DETAILS_BPO_RECIBO= SCOPE_IDENTITY()
							END
							

						IF @VP_MENSAJE=''
						BEGIN
							DECLARE @PP_F_DATE_INVENTARIO DATE
							SET @PP_F_DATE_INVENTARIO=GETDATE()

							EXECUTE [DATA_02].[dbo].[PG_IN_INVENTARIO_RECIBO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
														-- =====================================
														@PP_K_ITEM,						
														-- ===========================
														0,--,@PP_K_CLASIFICACION, DEFAULT '0'
														10,--@PP_K_STATUS_INVENTARIO,		10= PREREGISTRADO
														-- ===========================
														@PP_K_ORDEN_COMPRA_PEDIDO,	@VP_K_DETAILS_BPO_RECIBO,
														-- ===========================
														@VP_VALOR_SERI,					--@PP_SERIE_NO,
														@VP_VALOR_LOTE,					--@PP_LOTE_VENDOR,
														@VP_LOTE_PEARL,				
														@VP_LOTE_NUMERO_CONSECUTIVO,
														@VP_ENTREGA_NO,
														-- ===========================
														@PP_F_DATE_INVENTARIO,
														'',--@PP_C_INVENTARIO,
														-- ============================
														@VP_VALOR_QTTY							
						END
					END		
					ELSE
					BEGIN
						--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
						SET @VP_MENSAJE='LOTE was not assign. [VENDOR_LOTE#'+CONVERT(VARCHAR(10),@VP_VALOR_LOTE)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
					END
				
				END
				
				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_QTTY_ARRAY	= STUFF(@PP_QTTY_ARRAY  , 1, @VP_POSICION_QTTY , '')
				SELECT @PP_INUP_ARRAY	= STUFF(@PP_INUP_ARRAY	, 1, @VP_POSICION_INUP , '')
				SELECT @PP_LOTE_ARRAY	= STUFF(@PP_LOTE_ARRAY	, 1, @VP_POSICION_LOTE , '')
				SELECT @PP_SERI_ARRAY	= STUFF(@PP_SERI_ARRAY	, 1, @VP_POSICION_SERI , '')
			END

			IF @VP_MENSAJE=''
			BEGIN
			-----========================================================================================================
			--	UNA VEZ INGRESADOS TODOS LOS REGISTROS DEL ARRAY SE REALIZA EL UPDATE DEL TOTAL DE LOS DETALLES DEL PEDIDO.
			--	INCLUYENDO LA FECHA DE MODIFICACIÓN
				DECLARE	@VP_TOTAL_RECIBIDO	AS DECIMAL (19,4)
				SET @VP_TOTAL_RECIBIDO=	ISNULL	(	
										(SELECT	SUM(QUANTITY_RECEIVED) 
										FROM	DETAILS_BPO_RECIBO
										WHERE	K_HEADER_PURCHASE_ORDER	=@PP_K_HEADER_PURCHASE_ORDER
										AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
										AND		K_ITEM					=@PP_K_ITEM
										)	,0)
														
				UPDATE	DETAILS_BPO_PEDIDO
				SET
						QUANTITY_RECEIVED	=	@VP_TOTAL_RECIBIDO,
						QUANTITY_PENDING	=	(QUANTITY_ORDER-@VP_TOTAL_RECIBIDO),
						F_CAMBIO=GETDATE(),								
						K_USUARIO_CAMBIO=@PP_K_USUARIO_ACCION
				WHERE	K_HEADER_PURCHASE_ORDER	=@PP_K_HEADER_PURCHASE_ORDER
				AND		K_ORDEN_COMPRA_PEDIDO	=@PP_K_ORDEN_COMPRA_PEDIDO
				AND		K_ITEM					=@PP_K_ITEM

				IF @@ROWCOUNT = 0
					BEGIN
						--RAISERROR (@VP_ERROR_1, 16, 1 ) --MENSAJE - Severity -State.
						SET @VP_MENSAJE='The DETAIL RECEIVED was not updated. [QTTY#'+CONVERT(VARCHAR(10),@PP_K_ITEM)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
					END
			END
	END	

	IF @VP_MENSAJE=''
	BEGIN
		-----========================================================================================================
		--	SE REALIZA LA NOTIFICACIÓN DE LOS ARTÍCULOS RECIBIDOS AL GRUPO CORRESPONDIENTE.
		EXECUTE	[PG_NOTIFICAR_PRODUCTO_NUEVO_RECIBO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
														@PP_K_ORDEN_COMPRA_PEDIDO,	@VP_ENTREGA_NO
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
		SET		@VP_MENSAJE = 'Not is possible [Insert] at [Item_Received]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_ORDEN_COMPRA_PEDIDO AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO