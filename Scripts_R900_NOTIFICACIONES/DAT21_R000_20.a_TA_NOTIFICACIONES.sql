-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		COMPRAS
-- // MODULE:			ITEM
-- // OPERATION:		TABLA
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20200206
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_INACTIVO]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_INACTIVO]
GO

-- ////////////////////////////////////////////////////////////////
-- //					ITEM_INACTIVO				AX: 20210519
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ITEM_INACTIVO] (
	[K_ITEM_INACTIVO]				[INT] IDENTITY (1,1),
	 -- ============================
	[K_ITEM]						[INT] NOT NULL	
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ITEM_INACTIVO]
	ADD CONSTRAINT [PK_ITEM_INACTIVO]
		PRIMARY KEY CLUSTERED ([K_ITEM_INACTIVO])
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[ITEM_INACTIVO] 
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL
			--[L_BORRADO]					[INT] NOT NULL,
			--[K_USUARIO_BAJA]			[INT] NULL,
			--[F_BAJA]					[DATETIME] NULL;
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_NOTIFICACION]') AND type in (N'U'))
	DROP TABLE [dbo].[ITEM_NOTIFICACION]
GO
-- ////////////////////////////////////////////////////////////////
-- //					ITEM_NOTIFICACION				AX: 20210519
-- ////////////////////////////////////////////////////////////////
--			SELECT * FROM [ITEM_NOTIFICACION]
CREATE TABLE [dbo].[ITEM_NOTIFICACION] (
	[K_ITEM_NOTIFICACION]			[INT] IDENTITY (1,1),
	 -- ============================
	[K_ITEM]						[INT]	NOT NULL,
	[TIPO_NOTIFICACION]				[INT]	NOT NULL,	--	#10 MINIMO, #20 MAXIMO
	[F_NOTIFICACION]				[DATE]	NOT NULL DEFAULT GETDATE()

) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ITEM_NOTIFICACION]
	ADD CONSTRAINT [PK_ITEM_NOTIFICACION]
		PRIMARY KEY CLUSTERED ([K_ITEM_NOTIFICACION])
GO
-- //////////////////////////////////////////////////////
--ALTER TABLE [dbo].[ITEM_NOTIFICACION] 
--	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
--			[F_ALTA]					[DATETIME] NOT NULL
--			--[K_USUARIO_CAMBIO]			[INT] NOT NULL,
--			--[F_CAMBIO]					[DATETIME] NOT NULL
--			--[L_BORRADO]					[INT] NOT NULL,
--			--[K_USUARIO_BAJA]			[INT] NULL,
--			--[F_BAJA]					[DATETIME] NULL;
--GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////