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
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FOLIO]') AND type in (N'U'))
	DROP TABLE [dbo].[FOLIO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STATUS_INVENTARIO]') AND type in (N'U'))
	DROP TABLE [dbo].[STATUS_INVENTARIO]
GO


-- ////////////////////////////////////////////////////////////////
-- //					STATUS_INVENTARIO				 
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[STATUS_INVENTARIO] (
	[K_STATUS_INVENTARIO]				[INT]			NOT NULL,
	[D_STATUS_INVENTARIO]				[VARCHAR](100)	NOT NULL,
	[C_STATUS_INVENTARIO]				[VARCHAR](255)	NOT NULL,
	[S_STATUS_INVENTARIO]				[VARCHAR](10)	NOT NULL,
	[O_STATUS_INVENTARIO]				[INT]			NOT NULL,
	[L_STATUS_INVENTARIO]				[INT]			NOT NULL
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[STATUS_INVENTARIO]
	ADD CONSTRAINT [PK_STATUS_INVENTARIO]
		PRIMARY KEY CLUSTERED ([K_STATUS_INVENTARIO])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_STATUS_INVENTARIO_01_DESCRIPCION] 
	   ON [dbo].[STATUS_INVENTARIO] ( [D_STATUS_INVENTARIO] )
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_STATUS_INVENTARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_STATUS_INVENTARIO]
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - STATUS_INVENTARIO
-- //////////////////////////////////////////////////////////////

CREATE PROCEDURE [dbo].[PG_CI_STATUS_INVENTARIO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_STATUS_INVENTARIO				INT,
	@PP_D_STATUS_INVENTARIO				VARCHAR(100),
	@PP_C_STATUS_INVENTARIO				VARCHAR(255),
	@PP_S_STATUS_INVENTARIO				VARCHAR(10),
	@PP_O_STATUS_INVENTARIO				INT,
	@PP_L_STATUS_INVENTARIO				INT
AS				
	-- ===========================
	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_STATUS_INVENTARIO
							FROM	STATUS_INVENTARIO
							WHERE	K_STATUS_INVENTARIO=@PP_K_STATUS_INVENTARIO

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO STATUS_INVENTARIO	
			(	K_STATUS_INVENTARIO,				D_STATUS_INVENTARIO, 
				S_STATUS_INVENTARIO,				O_STATUS_INVENTARIO,
				C_STATUS_INVENTARIO,
				L_STATUS_INVENTARIO				)		
		VALUES	
			(	@PP_K_STATUS_INVENTARIO,			@PP_D_STATUS_INVENTARIO,	
				@PP_S_STATUS_INVENTARIO,			@PP_O_STATUS_INVENTARIO,
				@PP_C_STATUS_INVENTARIO,
				@PP_L_STATUS_INVENTARIO			)
	ELSE
		UPDATE	STATUS_INVENTARIO
		SET		D_STATUS_INVENTARIO	= @PP_D_STATUS_INVENTARIO,	
				S_STATUS_INVENTARIO	= @PP_S_STATUS_INVENTARIO,			
				O_STATUS_INVENTARIO	= @PP_O_STATUS_INVENTARIO,
				C_STATUS_INVENTARIO	= @PP_C_STATUS_INVENTARIO,
				L_STATUS_INVENTARIO	= @PP_L_STATUS_INVENTARIO	
		WHERE	K_STATUS_INVENTARIO=@PP_K_STATUS_INVENTARIO


	--INSERT INTO STATUS_INVENTARIO
	--		(	[K_STATUS_INVENTARIO], [D_STATUS_INVENTARIO], 
	--			[C_STATUS_INVENTARIO], [S_STATUS_INVENTARIO], 
	--			[O_STATUS_INVENTARIO], [L_STATUS_INVENTARIO]		)
	--VALUES	
	--		(	@PP_K_STATUS_INVENTARIO, @PP_D_STATUS_INVENTARIO, 
	--			@PP_C_STATUS_INVENTARIO, @PP_S_STATUS_INVENTARIO,
	--			@PP_O_STATUS_INVENTARIO, @PP_L_STATUS_INVENTARIO	 )
GO

EXECUTE [dbo].[PG_CI_STATUS_INVENTARIO] 0,0,00, 'SIN DEFINIR',				'', 'SNDEF', 00,1
EXECUTE [dbo].[PG_CI_STATUS_INVENTARIO] 0,0,10, 'PREREGISTRADO',			'', 'PRERE', 10,1
EXECUTE [dbo].[PG_CI_STATUS_INVENTARIO] 0,0,20, 'INSPECCIONADO',			'', 'INSPE', 20,1

EXECUTE [dbo].[PG_CI_STATUS_INVENTARIO] 0,0,30, 'ENTREGADO-PISO',			'', 'PISO', 30,1			--AX: 20210517 AGREGADO PARA DEJAR DE MOSTRAR INFORMACIÓN EN PANTALLA DE INVENTARIO.
-- =================================================================================
GO

-- ////////////////////////////////////////////////////////////////
-- //					FOLIO
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[FOLIO] (
	[K_FOLIO]							[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_LOCACION]						[INT] NOT NULL DEFAULT 4,				--MHI
	[K_ORDEN_TRABAJO]					[INT] NOT NULL DEFAULT 0,
	[TIPO]								[VARCHAR](50) NOT NULL DEFAULT 'B',		-- PARA LA PIEL SE ASIGNA FOLIO BASE (B) - -  SÓLO DE PUEDE MOVER A MHI.
	-- ============================	
	[F_DATE_FOLIO]						[DATE] NOT NULL,
	-- ============================
	[K_ITEM_BASE]						[INT] NOT NULL DEFAULT 0
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[FOLIO]
	ADD CONSTRAINT [PK_FOLIO]
		PRIMARY KEY CLUSTERED ([K_FOLIO])	
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[FOLIO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					INVENTARIO				 
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO] (
	[K_INVENTARIO]						[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_ITEM]							[INT] NOT NULL,
	[K_FOLIO]							[INT] NOT NULL DEFAULT 0,
	-- ============================	
	[K_CLASIFICACION]					[INT] NOT NULL DEFAULT 0,
	[K_STATUS_INVENTARIO]				[INT] NOT NULL DEFAULT 10,
	-- ============================	
	[K_ORDEN_COMPRA_PEDIDO]				[VARCHAR](50) NOT NULL,
	[K_DETAILS_BPO_RECIBO]				[INT] NOT NULL,
	[K_ENTREGA]							[INT] NOT NULL DEFAULT 1,
	-- ============================
	[SERIE_NO]							[VARCHAR](50) NOT NULL DEFAULT 'NOSERIE',
	[LOTE_VENDOR]						[VARCHAR](50) NOT NULL DEFAULT 'NOLOTE',
	[LOTE_PEARL]						[INT] NOT NULL DEFAULT 0,
	[LOTE_NUMERO_CONSECUTIVO]			[INT] NOT NULL DEFAULT 1,
	-- ============================
	[F_DATE_INVENTARIO]					[DATE] NOT NULL,
	[C_INVENTARIO]						NVARCHAR(MAX),
	-- ============================
	[CANTIDAD_RECIBIDA]					[DECIMAL] (19,4) NOT NULL
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO]
	ADD CONSTRAINT [PK_INVENTARIO]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO])	
GO
ALTER TABLE [dbo].[INVENTARIO] ADD 
	CONSTRAINT [FK_STATUS_INVENTARIO_01] 
		FOREIGN KEY ( K_STATUS_INVENTARIO ) 
		REFERENCES [dbo].[STATUS_INVENTARIO] (K_STATUS_INVENTARIO )
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO]
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

