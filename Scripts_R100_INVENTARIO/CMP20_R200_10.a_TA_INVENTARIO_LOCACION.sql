-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO_LOCACION
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20201003
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_MOVIMIENTO_X_REGISTRO]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_MOVIMIENTO_X_REGISTRO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_MOVIMIENTO]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_MOVIMIENTO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_LOCACION]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_LOCACION]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_MOVIMIENTO_TIPO]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_MOVIMIENTO_TIPO]
GO

-- ////////////////////////////////////////////////////////////////
-- //					INVENTARIO_MOVIMIENTO_TIPO
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_MOVIMIENTO_TIPO] (
	[K_INVENTARIO_MOVIMIENTO_TIPO]		[INT] NOT NULL,
	-- ============================
	[D_INVENTARIO_MOVIMIENTO_TIPO]		[VARCHAR] (100)	NOT NULL,
	[S_INVENTARIO_MOVIMIENTO_TIPO]		[VARCHAR] (10)	NOT NULL,
	[C_INVENTARIO_MOVIMIENTO_TIPO]		[VARCHAR] (500)	NOT NULL DEFAULT '',
	[O_INVENTARIO_MOVIMIENTO_TIPO]		[INT] NOT NULL DEFAULT 10,
	[L_INVENTARIO_MOVIMIENTO_TIPO]		[INT] NOT NULL DEFAULT 1
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_MOVIMIENTO_TIPO]
	ADD CONSTRAINT [PK_INVENTARIO_MOVIMIENTO_TIPO]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_MOVIMIENTO_TIPO])	
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO]
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - INVENTARIO_MOVIMIENTO_TIPO
-- //////////////////////////////////////////////////////////////

CREATE PROCEDURE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_INVENTARIO_MOVIMIENTO_TIPO				INT,
	@PP_D_INVENTARIO_MOVIMIENTO_TIPO				VARCHAR(100),
	@PP_S_INVENTARIO_MOVIMIENTO_TIPO				VARCHAR(10),
	@PP_C_INVENTARIO_MOVIMIENTO_TIPO				VARCHAR(500),
	@PP_O_INVENTARIO_MOVIMIENTO_TIPO				INT,
	@PP_L_INVENTARIO_MOVIMIENTO_TIPO				INT
AS				
	-- ===========================
	INSERT INTO INVENTARIO_MOVIMIENTO_TIPO
			(	[K_INVENTARIO_MOVIMIENTO_TIPO], [D_INVENTARIO_MOVIMIENTO_TIPO], 
				[C_INVENTARIO_MOVIMIENTO_TIPO], [S_INVENTARIO_MOVIMIENTO_TIPO], 
				[O_INVENTARIO_MOVIMIENTO_TIPO], [L_INVENTARIO_MOVIMIENTO_TIPO]		)
	VALUES	
			(	@PP_K_INVENTARIO_MOVIMIENTO_TIPO, @PP_D_INVENTARIO_MOVIMIENTO_TIPO, 
				@PP_C_INVENTARIO_MOVIMIENTO_TIPO, @PP_S_INVENTARIO_MOVIMIENTO_TIPO,
				@PP_O_INVENTARIO_MOVIMIENTO_TIPO, @PP_L_INVENTARIO_MOVIMIENTO_TIPO	 )
GO

EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,05, 'REGISTRO EN SISTEMA',			'REGSIS', '',	05,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,10, 'ENTRADA X LIBERACIÓN',		'ENXLIB', '',	10,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,20, 'TRANSFERENCIA A LOCACIÓN',	'TRXLOC', '',	20,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,30, 'FOLIO NUEVO',					'FOLNEW', '',	30,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,40, 'TRANSFERENCIA A ORDEN',		'TRXORD', '',	40,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,50, 'TRANSFERENCIA A FOLIO',		'TRXFOL', '',	50,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,60, 'DEVOLUCIÓN',					'DVOLUC', '',	60,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,70, 'ISSUE OUT',					'ISSOUT', '',	70,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,80, 'REIMPRESIÓN',					'REIMPR', '',	80,1
EXECUTE [dbo].[PG_CI_INVENTARIO_MOVIMIENTO_TIPO] 0,0,90, 'FOLIO SCRAP',					'FOLSCR', '',	90,1
-- =================================================================================
GO

-- ////////////////////////////////////////////////////////////////
-- //					INVENTARIO_LOCACION		 
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_LOCACION] (
	[K_INVENTARIO_LOCACION]				[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_LOCACION]						[INT] NOT NULL,
	[K_ITEM]							[INT] NOT NULL,
	-- ============================
	[LOTE_PEARL]						[INT] NOT NULL DEFAULT 0,
	[CANTIDAD_DISPONIBLE]				[DECIMAL] (19,4) NOT NULL,
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_LOCACION]
	ADD CONSTRAINT [PK_INVENTARIO_LOCACION]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_LOCACION])	
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_LOCACION]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					INVENTARIO_MOVIMIENTO
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_MOVIMIENTO] (
	[K_INVENTARIO_MOVIMIENTO]			[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_ITEM]							[INT] NOT NULL,
	[K_INVENTARIO_MOVIMIENTO_TIPO]		[INT] NOT NULL,
	[LOTE_PEARL]						[INT] NOT NULL DEFAULT 0,
	-- ============================	
	[K_LOCACION_ORIGEN]					[INT] NOT NULL DEFAULT 0,
	[K_FOLIO_ORIGEN]					[INT] NOT NULL DEFAULT 0,
	[K_ORDEN_TRABAJO_ORIGEN]			[INT] NOT NULL DEFAULT 0,
	-- ============================	
	[K_LOCACION_DESTINO]				[INT] NOT NULL,
	[K_FOLIO_DESTINO]					[INT] NOT NULL DEFAULT 0,
	[K_ORDEN_TRABAJO_DESTINO]			[INT] NOT NULL DEFAULT 0,
	-- ============================	
	[CANTIDAD_MOVIMIENTO]				[DECIMAL] (19,4) NOT NULL,
	[CANTIDAD_ORIGEN]					[DECIMAL] (19,4) NOT NULL DEFAULT 0,
	[CANTIDAD_DESTINO]					[DECIMAL] (19,4) NOT NULL DEFAULT 0
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_MOVIMIENTO]
	ADD CONSTRAINT [PK_INVENTARIO_MOVIMIENTO]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_MOVIMIENTO])	
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_MOVIMIENTO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //				INVENTARIO_MOVIMIENTO_X_REGISTRO
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_MOVIMIENTO_X_REGISTRO] (
	[K_INVENTARIO_MOVIMIENTO_X_REGISTRO]			[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_INVENTARIO]									[INT] NOT NULL,
	[K_ITEM]										[INT] NOT NULL,
	[K_INVENTARIO_MOVIMIENTO_TIPO]					[INT] NOT NULL,
	[LOTE_PEARL]									[INT] NOT NULL DEFAULT 0,
	[SERIE_NO]										[VARCHAR](50) NOT NULL DEFAULT 'NOSERIE',
	-- ============================	
	[K_LOCACION_ORIGEN]								[INT] NOT NULL,
	[K_FOLIO_ORIGEN]								[INT] NOT NULL DEFAULT 0,
	[K_ORDEN_TRABAJO_ORIGEN]						[INT] NOT NULL DEFAULT 0,
	-- ============================	
	[K_LOCACION_DESTINO]							[INT] NOT NULL,
	[K_FOLIO_DESTINO]								[INT] NOT NULL DEFAULT 0,
	[K_ORDEN_TRABAJO_DESTINO]						[INT] NOT NULL DEFAULT 0,
	-- ============================	
	[CANTIDAD_MOVIMIENTO]							[DECIMAL] (19,4) NOT NULL
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_MOVIMIENTO_X_REGISTRO]
	ADD CONSTRAINT [PK_INVENTARIO_MOVIMIENTO_X_REGISTRO]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_MOVIMIENTO_X_REGISTRO])	
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_MOVIMIENTO_X_REGISTRO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

