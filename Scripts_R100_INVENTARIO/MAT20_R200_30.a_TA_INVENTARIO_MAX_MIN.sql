-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			INVENTARIO_MAXIMOS/MINIMOS
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20201022
-- ////////////////////////////////////////////////////////////// 

USE [COMPRAS]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_MIN_MAX]') AND type in (N'U'))
--	DROP TABLE [dbo].[INVENTARIO_MIN_MAX]
--GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOG_INVENTARIO_MIN_MAX]') AND type in (N'U'))
	DROP TABLE [dbo].[LOG_INVENTARIO_MIN_MAX]
GO

-- ////////////////////////////////////////////////////////////////
-- //					LOG_INVENTARIO_MIN_MAX
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[LOG_INVENTARIO_MIN_MAX] (
	[K_LOG_INVENTARIO_MIN_MAX]			[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_ITEM]							[INT] NOT NULL,
	[CANTIDAD_MINIMA_NUEVA]				[DECIMAL] (19,4) NOT NULL,
	[CANTIDAD_MAXIMA_NUEVA]				[DECIMAL] (19,4) NOT NULL,
	[CANTIDAD_MINIMA]					[DECIMAL] (19,4) NOT NULL,
	[CANTIDAD_MAXIMA]					[DECIMAL] (19,4) NOT NULL
--	[K_INVENTARIO_MIN_MAX]				[INT] NOT NULL,			--- ESTE CAMPO ES PENSANDO QUE SE HAGA POR LOCACIÓN
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[LOG_INVENTARIO_MIN_MAX]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL;
GO

-- ////////////////////////////////////////////////////////////////
-- //					INVENTARIO_MIN_MAX
-- ////////////////////////////////////////////////////////////////

--CREATE TABLE [dbo].[INVENTARIO_MIN_MAX] (
--	[K_INVENTARIO_MIN_MAX]				[INT] IDENTITY (1,1)	NOT NULL,
--	-- ============================
--	[K_ITEM]							[INT] NOT NULL,
--	[CANTIDAD_MINIMA]					[DECIMAL] (19,4) NOT NULL,
--	[CANTIDAD_MAXIMA]					[DECIMAL] (19,4) NOT NULL
--	-- ============================
--) ON [PRIMARY]
--GO
---- //////////////////////////////////////////////////////
--ALTER TABLE [dbo].[INVENTARIO_MIN_MAX]
--	ADD CONSTRAINT [PK_INVENTARIO_MIN_MAX]
--		PRIMARY KEY CLUSTERED ([K_INVENTARIO_MIN_MAX])	
--GO
---- //////////////////////////////////////////////////////
--ALTER TABLE [dbo].[INVENTARIO_MIN_MAX]
--	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
--			[F_ALTA]					[DATETIME] NOT NULL,
--			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
--			[F_CAMBIO]					[DATETIME] NOT NULL,
--			[L_BORRADO]					[INT] NOT NULL,
--			[K_USUARIO_BAJA]			[INT] NULL,
--			[F_BAJA]					[DATETIME] NULL;
--GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

