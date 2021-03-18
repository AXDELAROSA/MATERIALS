-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			MATERIAL_CONTROLADO
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA
-- // CREATION DATE:	20210312
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02]
USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MATERIAL_CONTROLADO]') AND type in (N'U'))
	DROP TABLE [dbo].[MATERIAL_CONTROLADO]
GO

-- ////////////////////////////////////////////////////////////////
-- //					MATERIAL_CONTROLADO				 
-- ////////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[MATERIAL_CONTROLADO] (
	[K_MATERIAL_CONTROLADO]				[INT] IDENTITY (1,1)	NOT NULL,
	-- ============================
	[K_ITEM]							[INT] NOT NULL,
	[K_LOCACION_ENTREGA]				[INT] NOT NULL,
	[K_EMPLEADO_PEARL]					[INT] NOT NULL,
	-- ============================	
	[LOTE_VENDOR]						[VARCHAR](50) NOT NULL,
	-- ============================
	[D_MODELO]							NVARCHAR(MAX),
	[C_INVENTARIO]						NVARCHAR(MAX),
	-- ============================
	[F_ENTREGA]							[DATE] NOT NULL,
	-- ============================
	[CANTIDAD_ENTREGADA]				[DECIMAL] (19,4) NOT NULL,
	--[CANTIDAD_DISPONIBLE_INVENTARIO]	[DECIMAL] (19,4) NOT NULL,
	---- ============================
	--[LOTE_PEARL]						[INT] NOT NULL DEFAULT 0,
	[K_FOLIO_DESTINO]					[INT] NOT NULL DEFAULT 0,

) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[MATERIAL_CONTROLADO]
	ADD CONSTRAINT [PK_MATERIAL_CONTROLADO]
		PRIMARY KEY CLUSTERED ([K_MATERIAL_CONTROLADO])	
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[MATERIAL_CONTROLADO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO

ALTER TABLE [dbo].[MATERIAL_CONTROLADO]
	ADD		[D_EMPLEADO]				[VARCHAR](250) NOT NULL DEFAULT ''
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

