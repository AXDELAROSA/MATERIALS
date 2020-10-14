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
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_MATERIAL]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_MATERIAL]
GO


-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_MATERIAL] (
	[K_INVENTARIO_MATERIAL]				[INT]			NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA_PEDIDO]				[INT]			NOT NULL,
	[K_ITEM]							[INT]			NOT NULL,
	[K_FOLIO]							[INT]			NOT NULL,
	[K_CLASIFICACION]					[INT]			NOT NULL,
	-- =================================	
	[LOTE_EXTERNO]						VARCHAR(50)		NOT NULL,
	[CONSECUTIVO_EXTERNO]				VARCHAR(50)		NOT NULL,
	[LOTE_INTERNO]						VARCHAR(50)		NOT NULL,
	[CONSECUTIVO_INTERNO]				[INT]				NOT NULL,
	[CANTIDAD]							DECIMAL(13,2)	NOT NULL
	-- =================================	
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INVENTARIO_MATERIAL]
	ADD CONSTRAINT [PK_INVENTARIO_MATERIAL]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_MATERIAL])
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[INSPECCION_MATERIAL_RESULTADO] ADD 
	--CONSTRAINT [FK_INSPECCION_MATERIAL_RESULTADO_01]  
	--	FOREIGN KEY ([K_PUESTO_DESCRIPCION]) 
	--	REFERENCES [dbo].[PUESTO_DESCRIPCION] ([K_PUESTO_DESCRIPCION]),
	--CONSTRAINT [FK_INSPECCION_MATERIAL_RESULTADO_02]  
	--	FOREIGN KEY ([K_TIPO_INSPECCION_MATERIAL_RESULTADO]) 
	--	REFERENCES [dbo].[TIPO_INSPECCION_MATERIAL_RESULTADO] ([K_TIPO_INSPECCION_MATERIAL_RESULTADO]),
	--CONSTRAINT [FK_INSPECCION_MATERIAL_RESULTADO_03]  
	--	FOREIGN KEY ([K_ESTATUS_INSPECCION_MATERIAL_RESULTADO]) 
	--	REFERENCES [dbo].[ESTATUS_INSPECCION_MATERIAL_RESULTADO] ([K_ESTATUS_INSPECCION_MATERIAL_RESULTADO])
--GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[INVENTARIO_MATERIAL] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
