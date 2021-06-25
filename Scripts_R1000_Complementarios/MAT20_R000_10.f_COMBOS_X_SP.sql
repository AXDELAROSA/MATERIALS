-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			DATA_02
-- // OPERATION:		CARGA COMBO
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20201009
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////

--SELECT upc_cd, item_no  FROM IMITMIDX_SQL WHERE PUR_OR_MFG='R'
-- //////////////////////////////////////////////////////////////
--	SE UTILIZAN EN LA FO BACKING_YARDAGE
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA CARGAR COMBO DE VENDORS EN BASE A LOS QUE TIENEN
-- // ITEM CATALOGADOS CON LA CLASS_ITEM [ROW_MATERIAL]
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ROW_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ROW_MATERIAL]
GO
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL] 0,139,0
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL] 0,139,1
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL] 0,139,2
CREATE PROCEDURE [dbo].[PG_CB_ROW_MATERIAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50)	)	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT		upc_cd					AS K_COMBOBOX,
				item_no					AS D_COMBOBOX
	FROM		IMITMIDX_SQL		(NOLOCK)
	INNER JOIN	COMPRAS.DBO.ITEM ON	IMITMIDX_SQL.upc_cd=item.K_ITEM
	WHERE		PUR_OR_MFG='R'
	AND			ITEM.L_BORRADO=0
	ORDER BY item_no


	IF @PP_L_CON_TODOS=1
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO	)
		VALUES
			( -1,				'( SELECCIONA UNA OPCIÓN )'	)
	END
	ELSE IF @PP_L_CON_TODOS=2
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO	)
		VALUES
			( -1,				'( TODOS )'	)
	END

		SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
					TA_D_CATALOGO	AS D_COMBOBOX 
		FROM		@VP_TA_CATALOGO
		ORDER BY	TA_D_CATALOGO 
	-- ==========================================

	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
--	SE UTILIZAN EN LA FO PEDIDOS_BPO
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA SELECCIONAR LOS PROVEEDORES QUE TIENEN ALTA DE BLANKETS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_VENDOR_ROW_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_VENDOR_ROW_MATERIAL]
GO
--		 EXECUTE [dbo].[PG_CB_VENDOR_ROW_MATERIAL] 0,139,0
--		 EXECUTE [dbo].[PG_CB_VENDOR_ROW_MATERIAL] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_VENDOR_ROW_MATERIAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT	DISTINCT
				-- =============================
				VENDOR.K_VENDOR			AS K_COMBOBOX
				,D_VENDOR				AS D_COMBOBOX
				,0						AS TA_O_CATALOGO
				,0						AS L_DELETED
				,1						AS L_ACTIVO
				-- =============================	
	FROM		[COMPRAS].[dbo].ITEM	(NOLOCK) 
	INNER JOIN  [COMPRAS].[dbo].VENDOR	(NOLOCK) ON VENDOR.K_VENDOR=ITEM.K_VENDOR
				-- =============================
	WHERE		K_CLASS_ITEM=2
	AND			ITEM.L_BORRADO<>1
	
			
	IF @PP_L_CON_TODOS=1
	INSERT INTO @VP_TA_CATALOGO
		( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	VALUES
		( -1,				'( TODOS )',	-999,		   0,			 1				)
	SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
	FROM		@VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO, TA_D_CATALOGO 
	-- ==========================================
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //		SE UTILIZA EN LA PANTALLA PARA ENTREGA DE MATERIAL CONTROLADO
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA CARGAR COMBO CON ITEMS CONTROLADOS.
-- // ITEM CATALOGADOS CON LA CLASS_ITEM [ROW_MATERIAL]
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ITEM_ENTREGAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ITEM_ENTREGAR]
GO
--		 EXECUTE [dbo].[PG_CB_ITEM_ENTREGAR] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_ITEM_ENTREGAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(250)	)	
	
	INSERT INTO @VP_TA_CATALOGO	
	SELECT		upc_cd					AS K_COMBOBOX,
				--item_no					AS D_COMBOBOX
				D_ITEM					AS D_COMBOBOX
	FROM		IMITMIDX_SQL		(NOLOCK) 
	INNER JOIN	COMPRAS.DBO.ITEM	(NOLOCK) ON	IMITMIDX_SQL.upc_cd=item.K_ITEM
	WHERE		PUR_OR_MFG		= 'R'
	AND			ITEM.L_BORRADO	= 0
	--AND			TRADEMARK_ITEM	= 'HILO'
	ORDER BY	D_ITEM


	IF @PP_L_CON_TODOS=1
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO	)
		VALUES
			( -1,				'( SIN DESCRIPCIÓN )'	)
	END

		SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
					TA_D_CATALOGO	AS D_COMBOBOX 
		FROM		@VP_TA_CATALOGO
		ORDER BY	TA_D_CATALOGO 
	-- ==========================================

	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA CARGAR COMBO CON ITEMS CONTROLADOS.
-- // ITEM CATALOGADOS CON LA CLASS_ITEM [ROW_MATERIAL]
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_LOCACION_ENTREGAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_LOCACION_ENTREGAR]
GO
--		 EXECUTE [dbo].[PG_CB_LOCACION_ENTREGAR] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_LOCACION_ENTREGAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(250)	)	
	
	INSERT INTO @VP_TA_CATALOGO	
	SELECT		A4GLIdentity			AS K_COMBOBOX,
				loc_desc				AS D_COMBOBOX
	FROM		[IMLOCFIL_SQL]		(NOLOCK)
	WHERE		[user_def_fld_1]	= 'RW0'
	ORDER BY	loc_desc


	IF @PP_L_CON_TODOS=1
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO	)
		VALUES
			( -1,				'( SELECCIONAR )'	)
	END

		SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
					TA_D_CATALOGO	AS D_COMBOBOX 
		FROM		@VP_TA_CATALOGO
		ORDER BY	TA_D_CATALOGO 
	-- ==========================================

	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
--	SE UTILIZAN EN LA FO INVENTARIO
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA CARGAR COMBO DE ITEM ROW MATERIAL
-- // CON AQUELLOS QUE TIENEN MATERIAL EN EL FOLIO BASE.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ROW_MATERIAL_INVENTARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ROW_MATERIAL_INVENTARIO]
GO
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL_INVENTARIO] 0,139,0
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL_INVENTARIO] 0,87,0
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL_INVENTARIO] 0,139,1
--		 EXECUTE [dbo].[PG_CB_ROW_MATERIAL_INVENTARIO] 0,139,2
CREATE PROCEDURE [dbo].[PG_CB_ROW_MATERIAL_INVENTARIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50)	)	

	IF @PP_K_USUARIO	IN (139)
	BEGIN
		INSERT INTO @VP_TA_CATALOGO 
		SELECT		upc_cd					AS K_COMBOBOX,
					item_no					AS D_COMBOBOX
		FROM		IMITMIDX_SQL		(NOLOCK)
		INNER JOIN	COMPRAS.DBO.ITEM	(NOLOCK) ON	IMITMIDX_SQL.upc_cd=item.K_ITEM
		WHERE		PUR_OR_MFG='R'
		AND			ITEM.L_BORRADO=0
		ORDER BY item_no
	END
	ELSE
	BEGIN
		INSERT INTO @VP_TA_CATALOGO 
		SELECT		DISTINCT
					upc_cd					AS K_COMBOBOX,
					item_no					AS D_COMBOBOX
		FROM		IMITMIDX_SQL			(NOLOCK)
		INNER JOIN	COMPRAS.DBO.ITEM		(NOLOCK) ON	IMITMIDX_SQL.upc_cd	= item.K_ITEM
		INNER JOIN	DATA_02.dbo.INVENTARIO	(NOLOCK) ON INVENTARIO.K_ITEM	= ITEM.K_ITEM
		INNER JOIN	DATA_02.dbo.FOLIO		(NOLOCK) ON INVENTARIO.K_FOLIO	= FOLIO.K_FOLIO
		WHERE		PUR_OR_MFG='R'
		AND			ITEM.L_BORRADO=0
		AND			FOLIO.TIPO	= 'B'
		ORDER BY item_no
	END	

	IF @PP_L_CON_TODOS=1
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO	)
		VALUES
			( -1,				'( SELECCIONA UNA OPCIÓN )'	)
	END
	ELSE IF @PP_L_CON_TODOS=2
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO	)
		VALUES
			( -1,				'( TODOS )'	)
	END

		SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
					TA_D_CATALOGO	AS D_COMBOBOX 
		FROM		@VP_TA_CATALOGO
		ORDER BY	TA_D_CATALOGO 
	-- ==========================================

	-- ////////////////////////////////////////////////////
GO
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////