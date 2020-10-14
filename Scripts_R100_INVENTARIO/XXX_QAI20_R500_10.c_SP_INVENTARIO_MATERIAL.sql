-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	09/SEP/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_MATERIAL]
GO
/*
 EXECUTE [PG_IN_UP_INSPECCION_MATERIAL_ORDEN] 0,0,    78 , '200435AWT3' , 1 , 2 , '1.1' , '' 
*/
CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_ORDEN_COMPRA_PEDIDO			INT,
	@PP_K_ITEM							INT,
	@PP_K_FOLIO							INT,
	@PP_K_CLASIFICACION					INT,
	-- ======================
	@PP_LOTE_EXTERNO					VARCHAR(50),
	@PP_CONSECUTIVO_EXTERNO				VARCHAR(50),
	@PP_LOTE_INTERNO					VARCHAR(50),
	@PP_CONSECUTIVO_INTERNO				INT,
	@PP_CANTIDAD						DECIMAL(13,2)	
	-- ============================
	
				
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_INVENTARIO_MATERIAL	INT = 0
	
	--IF @VP_MENSAJE=''	
		--EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_ORDEN_INSERT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--													@PP_INSPECCION_PORCENTAJE, @PP_OPCION_1_PORCENTAJE,
		--													@PP_OPCION_2_PORCENTAJE, @PP_OPCION_3_PORCENTAJE,
		--													@PP_OPCION_4_PORCENTAJE, @PP_OPCION_5_PORCENTAJE,
		--													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			-- ///////SE OBTIENE EL ID A INGRESAR///////////////////////////////////////////////////////
			EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																	'DATA_02Pruebas', 'INVENTARIO_MATERIAL', 'K_INVENTARIO_MATERIAL',
																	@OU_K_TABLA_DISPONIBLE = @VP_K_INVENTARIO_MATERIAL	OUTPUT
			-- SELECT * FROM [INVENTARIO_MATERIAL]
			-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
			INSERT INTO [INVENTARIO_MATERIAL]
				(	[K_INVENTARIO_MATERIAL],
					-- ===========================
					[K_ORDEN_COMPRA_PEDIDO],
					[K_ITEM],
					[K_FOLIO],
					[K_CLASIFICACION],
					-- ===========================
					[LOTE_EXTERNO],
					[CONSECUTIVO_EXTERNO],
					[LOTE_INTERNO],
					[CONSECUTIVO_INTERNO],
					[CANTIDAD],
					-- ===========================
					[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
					[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
			VALUES	
				(	@VP_K_INVENTARIO_MATERIAL,
					-- ===========================	
					@PP_K_ORDEN_COMPRA_PEDIDO,			
					@PP_K_ITEM,							
					@PP_K_FOLIO,							
					@PP_K_CLASIFICACION,					
					-- ======================
					@PP_LOTE_EXTERNO,					
					@PP_CONSECUTIVO_EXTERNO,				
					@PP_LOTE_INTERNO,					
					@PP_CONSECUTIVO_INTERNO,				
					@PP_CANTIDAD,						
					-- ===========================
					@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
					0, NULL, NULL )
	END
				
	-- //////////////////////////////////////////////////////////////

GO

