-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		COMPRAS
-- // MODULE:			HEADER_PURCHASE_ORDER
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20200914
-- ////////////////////////////////////////////////////////////// 

USE [COMPRAS]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETAILS_BPO_RECIBO]') AND type in (N'U'))
	DROP TABLE [dbo].[DETAILS_BPO_RECIBO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETAILS_BPO_PEDIDO]') AND type in (N'U'))
	DROP TABLE [dbo].[DETAILS_BPO_PEDIDO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HEADER_BPO_PEDIDO]') AND type in (N'U'))
	DROP TABLE [dbo].[HEADER_BPO_PEDIDO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STATUS_BPO_PEDIDO]') AND type in (N'U'))
	DROP TABLE [dbo].[STATUS_BPO_PEDIDO]
GO


-- ////////////////////////////////////////////////////////////////
-- //					STATUS_BPO_PEDIDO				 
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[STATUS_BPO_PEDIDO] (
	[K_STATUS_BPO_PEDIDO]				[INT]			NOT NULL,
	[D_STATUS_BPO_PEDIDO]				[VARCHAR](100)	NOT NULL,
	[C_STATUS_BPO_PEDIDO]				[VARCHAR](255)	NOT NULL,
	[S_STATUS_BPO_PEDIDO]				[VARCHAR](10)	NOT NULL,
	[O_STATUS_BPO_PEDIDO]				[INT]			NOT NULL,
	[L_STATUS_BPO_PEDIDO]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[STATUS_BPO_PEDIDO]
	ADD CONSTRAINT [PK_STATUS_BPO_PEDIDO]
		PRIMARY KEY CLUSTERED ([K_STATUS_BPO_PEDIDO])
GO

CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_STATUS_BPO_PEDIDO_01_DESCRIPCION] 
	   ON [dbo].[STATUS_BPO_PEDIDO] ( [D_STATUS_BPO_PEDIDO] )
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_STATUS_BPO_PEDIDO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_STATUS_BPO_PEDIDO]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - STATUS_BPO_PEDIDO
-- //////////////////////////////////////////////////////////////
CREATE PROCEDURE [dbo].[PG_CI_STATUS_BPO_PEDIDO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_STATUS_BPO_PEDIDO				INT,
	@PP_D_STATUS_BPO_PEDIDO				VARCHAR(100),
	@PP_C_STATUS_BPO_PEDIDO				VARCHAR(255),
	@PP_S_STATUS_BPO_PEDIDO				VARCHAR(10),
	@PP_O_STATUS_BPO_PEDIDO				INT,
	@PP_L_STATUS_BPO_PEDIDO				INT
AS				
	-- ===========================
	INSERT INTO STATUS_BPO_PEDIDO
			(	[K_STATUS_BPO_PEDIDO], [D_STATUS_BPO_PEDIDO], 
				[C_STATUS_BPO_PEDIDO], [S_STATUS_BPO_PEDIDO], 
				[O_STATUS_BPO_PEDIDO], [L_STATUS_BPO_PEDIDO]		)
	VALUES	
			(	@PP_K_STATUS_BPO_PEDIDO, @PP_D_STATUS_BPO_PEDIDO, 
				@PP_C_STATUS_BPO_PEDIDO, @PP_S_STATUS_BPO_PEDIDO,
				@PP_O_STATUS_BPO_PEDIDO, @PP_L_STATUS_BPO_PEDIDO	 )
GO

EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,00, 'CANCEL',						'', 'CANCL', 130,1
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,01, 'REGISTERED',					'', 'REGIS', 10,1
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,11, 'PENDING TO RECEIVE',			'', 'PNRCV', 110,1
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,12, 'COMPLETE ORDER RECEIVED',		'', 'COMPL', 110,1
EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,13, 'PARTIAL ORDER RECEIVED',		'', 'PRRCV', 130,1
EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,14, 'PARTIAL ORDER CLOSED',			'', 'PRCOM', 140,1
EXECUTE [dbo].[PG_CI_STATUS_BPO_PEDIDO] 0,0,15, 'RETURNED ORDER',				'', 'RETUR', 150,1

GO

-- ////////////////////////////////////////////////////////////////
-- //					HEADER_BPO_PEDIDO				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HEADER_BPO_PEDIDO] (
	[K_ORDEN_COMPRA_PEDIDO]					[INT] IDENTITY (1,1)	NOT NULL,	-- [VARCHAR](50) NOT NULL,
--	[K_HEADER_PURCHASE_ORDER]				[INT] NOT NULL,
	-- ============================
	[K_VENDOR]								[INT] NOT NULL,
	[K_CURRENCY]							[INT] NOT NULL,
	[K_STATUS_BPO_PEDIDO]					[INT] NOT NULL DEFAULT 1,
	-- ============================
	[L_URGENTE]								[INT] NOT NULL DEFAULT 0,
	[F_DATE_BPO_PEDIDO]						[DATE] NOT NULL,
	[F_DATE_BPO_RECIBIDO]					[DATE] NULL,
	[C_BPO_PEDIDO]							[VARCHAR](500)
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[HEADER_BPO_PEDIDO] 
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO

-- ////////////////////////////////////////////////////////////////
-- //					DETAILS_BPO_PEDIDO				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[DETAILS_BPO_PEDIDO] (
	[K_DETAILS_BPO_PEDIDO]					[INT] NOT NULL,
	-- ============================
	[K_ORDEN_COMPRA_PEDIDO]					[INT] NOT NULL,						--[VARCHAR](50) NOT NULL,
	[K_HEADER_PURCHASE_ORDER]				[INT] NOT NULL,
	[K_ITEM]								[INT] NOT NULL,
--	[K_CUSTOMER]							[INT] NOT NULL,
	[K_PO_PRICE_LOG]						[INT] NOT NULL,
	-- ============================
	[QUANTITY_ORDER]						[DECIMAL] (10,4) NOT NULL DEFAULT 0,
	[QUANTITY_ORDER_ORIGINAL]				[DECIMAL] (10,4) NOT NULL DEFAULT 0,
	-- ============================
	[QUANTITY_RECEIVED]						[DECIMAL] (10,4) NOT NULL DEFAULT 0,
	[QUANTITY_PENDING]						[DECIMAL] (10,4) NOT NULL DEFAULT 0,
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[DETAILS_BPO_PEDIDO] 
	ADD		[K_USUARIO_ALTA]			[INT] NULL			,
			[F_ALTA]					[DATETIME] NULL		,
			[K_USUARIO_CAMBIO]			[INT] NULL			,
			[F_CAMBIO]					[DATETIME] NULL,
			[L_BORRADO]					[INT] NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					DETAILS_BPO_RECIBO
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[DETAILS_BPO_RECIBO] (
	[K_DETAILS_BPO_RECIBO]					[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_ORDEN_COMPRA_PEDIDO]					[INT] NOT NULL,					--[VARCHAR](50) NOT NULL,
	[K_HEADER_PURCHASE_ORDER]				[INT] NOT NULL,
	[K_ITEM]								[INT] NOT NULL,
--	[K_CUSTOMER]							[INT] NOT NULL,
	-- ============================
	[K_ENTREGA]								[INT] NOT NULL DEFAULT 1,
	-- ============================
	[QUANTITY_RECEIVED]						[DECIMAL] (10,4) NOT NULL DEFAULT 0,
	-- ============================
	[SERIE_NO]								[VARCHAR] (20) NOT NULL,
	[LOTE_VENDOR]							[VARCHAR] (20) NOT NULL,
	[LOTE_PEARL]							[INT] NOT NULL,
	-- ============================
	[L_ES_BORRABLE]							[INT] NOT NULL DEFAULT 1,
	[L_INSPECCIONADO]						[INT] NOT NULL DEFAULT 0
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DETAILS_BPO_RECIBO] 
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL			,
			[F_ALTA]					[DATETIME] NOT NULL		,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL			,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

