-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			TRANSACTION_REPORT
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210112
-- ////////////////////////////////////////////////////////////// 

 --USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / PARA TRANSACTION_REPORT POR PACK
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]
GO
--		 EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK] 0,139,105501,0
--		 EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK] 0,139,105501,1
CREATE PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_PACK_NO						INT,
	@PP_L_CONCILIACION				INT
AS
	--DECLARE @PP_PACK_NO						INT	= 106501
	DECLARE  @VP_PACK_NO_TRIM			VARCHAR(25)	--= LTRIM(RTRIM(@PP_PACK_NO))
			,@VP_INT_LEN				INT			--= 9 - Len(@PP_PACK_NO)
			,@VP_STR_PACK_NO			VARCHAR(25) --= @PP_PACK_NO + Space(@VP_INT_LEN)

	SET	@VP_PACK_NO_TRIM		= LTRIM(RTRIM(@PP_PACK_NO))
	--SELECT @VP_PACK_NO_TRIM
	SET	@VP_INT_LEN				= 9 - Len(@PP_PACK_NO)
	--SELECT @VP_INT_LEN
	SET	@VP_STR_PACK_NO			= @PP_PACK_NO + Space(@VP_INT_LEN)
	--SELECT @VP_STR_PACK_NO


	-- ////////////// PARA INGRESAR EL SELECT DEL FRONT
	DECLARE @TRANSACTION_REPORT_SQL_1		TABLE
	(	
		 [TA_LOC]			VARCHAR(150) DEFAULT ''
		,[TA_DATE]			VARCHAR(150) DEFAULT ''
		,[TA_TIME]			VARCHAR(150) DEFAULT ''
		,[TA_DOC_NO]		VARCHAR(150) DEFAULT ''
		,[TA_ITEM_NO]		VARCHAR(150) DEFAULT ''
		,[TA_SOURCE]		VARCHAR(150) DEFAULT ''
		,[TA_TRANS]			VARCHAR(150) DEFAULT ''
		,[TA_SER_LOT_NO]	VARCHAR(150) DEFAULT ''
		,[TA_QTY_SQFT]		VARCHAR(150) DEFAULT ''
		,[TA_USERNAME]		VARCHAR(150) DEFAULT ''
		,[TA_COMMENTS]		VARCHAR(500) DEFAULT ''
		,[TA_LEVEL_NO]		VARCHAR(150) DEFAULT ''
	)
	SET NOCOUNT ON
	-- ////////////// PARA DIVIDIR POR GRUPOS
	DECLARE @TRANSACTION_REPORT_SQL_2		TABLE
	(	
		 [TA_2_DATE]			VARCHAR(150) DEFAULT ''			
		,[TA_2_TIME]			VARCHAR(150) DEFAULT ''			
		,[TA_2_DOC_NO]			VARCHAR(150) DEFAULT ''
		,[TA_2_ITEM_NO]			VARCHAR(150) DEFAULT ''			
		,[TA_2_SOURCE]			VARCHAR(150) DEFAULT ''			
		,[TA_2_TRANS]			VARCHAR(150) DEFAULT ''
		,[TA_2_SER_LOT_NO]		VARCHAR(150) DEFAULT ''			
		,[TA_2_QTY_SQFT]		VARCHAR(150) DEFAULT ''			
		,[TA_2_USERNAME]		VARCHAR(150) DEFAULT ''
		,[TA_2_COMMENTS]		VARCHAR(500) DEFAULT ''			
		,[TA_2_L_FORMAT]		VARCHAR(150) DEFAULT ''
		,[TA_2_ORDEN]			INT
		,[TA_2_ORDEN_LETRA]		VARCHAR(150) DEFAULT 'B'
	)
	SET NOCOUNT ON				
-------===========================================================================================================
-------===========================================================================================================
--	-- ////////////// ENCABEZADO DEL REPORTE
-- ////////////// PARA DIVIDIR POR GRUPOS
	DECLARE @TRANSACTION_REPORT_SQL_3		TABLE
	(	
		 [TA_3_DATE]			VARCHAR(150) DEFAULT ''			
		,[TA_3_TIME]			VARCHAR(150) DEFAULT ''			
		,[TA_3_DOC_NO]			VARCHAR(150) DEFAULT ''
		,[TA_3_ITEM_NO]			VARCHAR(150) DEFAULT ''			
		,[TA_3_SOURCE]			VARCHAR(150) DEFAULT ''			
		,[TA_3_TRANS]			VARCHAR(150) DEFAULT ''
		,[TA_3_SER_LOT_NO]		VARCHAR(150) DEFAULT ''			
		,[TA_3_QTY_SQFT]		VARCHAR(150) DEFAULT ''			
		,[TA_3_USERNAME]		VARCHAR(150) DEFAULT ''
		,[TA_3_COMMENTS]		VARCHAR(500) DEFAULT ''			
		,[TA_3_L_FORMAT]		VARCHAR(150) DEFAULT '0'			
		,[TA_2_ORDEN]			INT			 
		,[TA_2_ORDEN_LETRA]		VARCHAR(150) DEFAULT 'Z'
	)
	SET NOCOUNT ON	
			
			DECLARE	@VP_DATE	DATE
			SET		@VP_DATE =	GETDATE()
			DECLARE @VP_FECHA	VARCHAR(10)
			
			SET	@VP_FECHA	=	CONVERT(varchar,@VP_DATE,103)
			

			INSERT INTO @TRANSACTION_REPORT_SQL_3
			(
				 TA_3_DATE		,TA_3_TIME				,TA_3_DOC_NO		,TA_3_ITEM_NO		,TA_3_SOURCE			
				,TA_3_TRANS		,TA_3_SER_LOT_NO		,TA_3_QTY_SQFT		,TA_3_USERNAME		,TA_3_COMMENTS
				,TA_3_L_FORMAT	
				--,TA_2_ORDEN
				--,TA_2_ORDEN_LETRA
			)
			VALUES	
			 (	 ''							,''	,''	,''	,''	,''	,''	,''	,''	,''																					,0)--,'A')--,0)
			,(	 ''							,''	,''	,''	,''	,''	,''	,''	,''	,''																					,0)--,'B')--,1)
			,(	 'History By Pack/Lot'		,''	,''	,''	,''	,''	,''	,''	,''	,''																					,0)--,'C')--,2)
			,(	 'Report Date:'				,@VP_FECHA,''	,''	,''	,''	,''	,''	,''	,''																			,0)--,'D')--,3)
			,(	 'Pack Number:'				,CONVERT(VARCHAR(25),@PP_PACK_NO),''	,''	,''	,''	,''	,''	,''	,''													,0)--,'E')--,4)
			,(	 ''							,''	,''	,''	,''	,''	,''	,''	,''	,''																					,0)--,'F')--,5)
			,(	 'DATE'		,'TIME'		,'DOC_NO'	,'ITEM_NO'		,'SOURCE'		,'TRANS'		,'PACK'		,'QTY_SQFT'		,'USERNAME'		,'COMMENTS'		,0)--,'G')--,6)
-----===========================================================================================================
-----===========================================================================================================

	-- ////////////// INSERT EN LA TABLA TEMPORAL #1
			INSERT INTO @TRANSACTION_REPORT_SQL_1
			(
				 TA_LOC
				,TA_DATE		
				,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			,TA_SOURCE			
				,TA_TRANS		,TA_SER_LOT_NO		,TA_QTY_SQFT		,TA_USERNAME		,TA_COMMENTS		
				,TA_LEVEL_NO
			)
			SELECT	--TOP	1
					 IMINVTRX_SQL.Loc
					,CONVERT(Varchar(25),DBO.CONVERT_INT_TO_DATE(IMLSTRX_SQL.Trx_Dt),103)
					,CONVERT(VARCHAR(8),DBO.CONVERT_INT_TO_TIME(IMLSTRX_SQL.Trx_Tm))
					,IMINVTRX_SQL.Doc_Ord_No								
					,IMLSTRX_SQL.Item_No									
					,RTRIM(LTRIM(IMLSTRX_SQL.Source))
					,LTRIM(RTRIM(IMINVTRX_SQL.Doc_Type))
					,IMLSTRX_SQL.Ser_Lot_No									
					,IMLSTRX_SQL.Trx_Qty
					,UPPER(IMINVTRX_SQL.User_Name)							
					,IMINVTRX_SQL.Comment									
					,IMLSTRX_SQL.Lev_No
					--=====================================================================================
			FROM IMLSTRX_SQL, IMINVTRX_SQL, IMLOCFIL_SQL
			WHERE IMLSTRX_SQL.Source = IMINVTRX_SQL.Source
			AND IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No
			AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No
			AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No
			AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No
			AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
			AND (		IMLSTRX_SQL.Ser_Lot_No LIKE Format(@PP_PACK_NO, '_________000000')
					OR	(		IMLSTRX_SQL.Ser_Lot_No BETWEEN Format(@PP_PACK_NO, '000000') + '   000000'		AND	Format(@PP_PACK_NO, '000000') + '   999999' )
					OR  (		IMLSTRX_SQL.Ser_Lot_No BETWEEN @VP_STR_PACK_NO	+	'000000'					AND		@VP_STR_PACK_NO	+	'999999'					)
				) 

			--AND		(		IMLSTRX_SQL.Ser_Lot_No LIKE '_________106501' 
			--	OR		(		IMLSTRX_SQL.Ser_Lot_No BETWEEN '106501   000000' AND '106501   999999') 
			--	OR		(		IMLSTRX_SQL.Ser_Lot_No BETWEEN '106501   000000' AND '106501   999999')
			--		) 
			AND IMLOCFIL_SQL.loc	= IMINVTRX_SQL.Loc
			ORDER BY IMINVTRX_SQL.Loc,	IMLSTRX_SQL.trx_dt,	IMLSTRX_SQL.trx_tm
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	DECLARE	 @VP_TOTAL_RECEIVED			DECIMAL(10,4)	= 0			,@VP_TOTAL_ISSUE_OUT		DECIMAL(10,4)	= 0			,@VP_TOTAL_CUTTING			DECIMAL(10,4)	= 0
			,@VP_TOTAL_STOCK_TAKE		DECIMAL(10,4)	= 0			,@VP_TOTAL_QUARENTINE		DECIMAL(10,4)	= 0

			,@VP_TOTAL_QTY_SQFT			DECIMAL(10,4)	= 0
			,@VP_CONTADOR				INT				= 0
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
		DECLARE		 @VP_CU_2_LOC				VARCHAR(150)					,@VP_CU_2_DATE				VARCHAR(150)					,@VP_CU_2_TIME				VARCHAR(150)
					,@VP_CU_2_DOC_NO			VARCHAR(150)					,@VP_CU_2_ITEM_NO			VARCHAR(150)					,@VP_CU_2_SOURCE			VARCHAR(150)
					,@VP_CU_2_TRANS				VARCHAR(150)					,@VP_CU_2_SER_LOT_NO		VARCHAR(150)					,@VP_CU_2_QTY_SQFT			VARCHAR(150)
					,@VP_CU_2_USERNAME			VARCHAR(150)					,@VP_CU_2_COMMENTS			VARCHAR(500)					,@VP_CU_2_SOURCE_O			VARCHAR(150)
					,@VP_CU_2_TRANS_O			VARCHAR(150)					,@VP_CU_2_LEVEL_NO			VARCHAR(150)					,@VP_CU_2_QTY_SQFT_O		VARCHAR(150)

					,@VP_CU_2_LOC_ANTERIOR		VARCHAR(150)	= ''

		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			SELECT
			 TA_LOC
			,TA_DATE
			,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			
			,(CASE
						WHEN TA_SOURCE = 'I'	THEN	'IM'
						WHEN TA_SOURCE = 'P'	THEN	'PO'
						WHEN TA_SOURCE = 'O'	THEN	'OE'
						WHEN TA_SOURCE = 'S'	THEN	'SF'
						WHEN TA_SOURCE = 'C'	THEN	'CC'
						ELSE TA_SOURCE + '-Unkwn'
			END)	
			,(CASE
						WHEN TA_TRANS = 'A' THEN	'Allocation'
						WHEN TA_TRANS = 'B' THEN	'Balance'
						WHEN TA_TRANS = 'H' THEN	'Start of Month'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'I' THEN	'Issue Out'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'O' THEN	'Invoice'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'P' THEN	'Issue'
						WHEN TA_TRANS = 'L' THEN	'Lot Adjustment'
						WHEN TA_TRANS = 'P' THEN	'Stock Take'
						WHEN TA_TRANS = 'Q' THEN	'Quantity Adjust'
						WHEN TA_TRANS = 'R' AND TA_SOURCE = 'C' THEN	'Received'
						WHEN TA_TRANS = 'R' THEN	'Received'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	'Trans - Out'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 1	THEN	'Trans - In'
						WHEN TA_TRANS = 'Z' THEN	'Received'
						ELSE 'Unknown'
					END)
			,TA_SER_LOT_NO		
			,(CASE
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'I' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'O' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'P' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				ELSE CONVERT(DECIMAL(10,4),TA_QTY_SQFT)
			END)
			,TA_USERNAME			,TA_COMMENTS			,TA_SOURCE
			,TA_TRANS				,TA_LEVEL_NO			,TA_QTY_SQFT
			FROM	@TRANSACTION_REPORT_SQL_1
			ORDER BY	TA_LOC		
						,TA_DATE	
						,TA_TIME
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			
												,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
												,@VP_CU_2_SOURCE_O		,@VP_CU_2_TRANS_O			,@VP_CU_2_LEVEL_NO		,@VP_CU_2_QTY_SQFT_O
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @VP_CONTADOR += 1
			-- INSERTAR LOS ENCABEZADOS DE LAS LOCACIONES CON SU DESCRIPCIÓN
			IF @VP_CU_2_LOC_ANTERIOR <>	@VP_CU_2_LOC
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	TA_2_DATE	, TA_2_L_FORMAT		,TA_2_ORDEN)
				SELECT	TOP (1) 
						LTRIM(RTRIM(LOC)) + '	' + LTRIM(RTRIM(loc_desc))
						,0
						,@VP_CONTADOR
				FROM	IMLOCFIL_SQL
				WHERE	LOC	= @VP_CU_2_LOC
				
				SET @VP_CONTADOR += 1
			END

			--	INSERTAR LOS REGISTROS DE CADA UNA DE LAS TRANSACCIONES.
			INSERT INTO @TRANSACTION_REPORT_SQL_2
			(
				 TA_2_DATE		,TA_2_TIME				,TA_2_DOC_NO		,TA_2_ITEM_NO		,TA_2_SOURCE			
				,TA_2_TRANS		,TA_2_SER_LOT_NO		,TA_2_QTY_SQFT		,TA_2_USERNAME		,TA_2_COMMENTS
				,TA_2_L_FORMAT	
				--,TA_2_ORDEN
			)
			VALUES	
			(
				 @VP_CU_2_DATE		,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
				,@VP_CU_2_TRANS		,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS		
				,1					
				--,@VP_CONTADOR
			)

			-- PARA LA SUMA POR LOCACIÓN						
			SET @VP_TOTAL_QTY_SQFT +=	@VP_CU_2_QTY_SQFT
			
			--	SI APLICA EL CHECK DE CONCILIACIÓN IRA HACIENDO LA SUMA DE LOS TOTALES.
			IF 	@PP_L_CONCILIACION	= 1
			BEGIN
				IF @VP_CU_2_TRANS_O = 'R'
					SET	@VP_TOTAL_RECEIVED		+= CONVERT(DECIMAL(10,4),@VP_CU_2_QTY_SQFT_O)
				IF @VP_CU_2_TRANS_O = 'I' AND @VP_CU_2_SOURCE_O = 'I' 
					SET	@VP_TOTAL_ISSUE_OUT		+= CONVERT(DECIMAL(10,4),@VP_CU_2_QTY_SQFT_O)
				IF @VP_CU_2_TRANS_O = 'T' AND (	@VP_CU_2_LEVEL_NO = '0'	OR @VP_CU_2_LEVEL_NO = '1' )	
					SET	@VP_TOTAL_CUTTING		+= CONVERT(DECIMAL(10,4),@VP_CU_2_QTY_SQFT_O)
				IF @VP_CU_2_TRANS_O = 'P'
					SET	@VP_TOTAL_STOCK_TAKE	+= CONVERT(DECIMAL(10,4),@VP_CU_2_QTY_SQFT_O)
				IF @VP_CU_2_TRANS_O = 'I' AND @VP_CU_2_SOURCE_O = 'I'	AND	@VP_CU_2_LOC = 'MQU'
					SET	@VP_TOTAL_QUARENTINE	+= CONVERT(DECIMAL(10,4),@VP_CU_2_QTY_SQFT_O)
				IF @VP_CU_2_TRANS_O = 'T' AND (	@VP_CU_2_LEVEL_NO = '0'	OR @VP_CU_2_LEVEL_NO = '1' )	AND	@VP_CU_2_LOC = 'MQU'
					SET	@VP_TOTAL_QUARENTINE	+= CONVERT(DECIMAL(10,4),@VP_CU_2_QTY_SQFT_O)
			END				

			SET	@VP_CU_2_LOC_ANTERIOR	=	@VP_CU_2_LOC
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			
												,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
												,@VP_CU_2_SOURCE_O		,@VP_CU_2_TRANS_O			,@VP_CU_2_LEVEL_NO		,@VP_CU_2_QTY_SQFT_O

		--	COMPARA LOS REGISTROS PARA DETECTAR EL CAMBIO DE LOCACIÓN Y MOSTRAR LOS TOTALES POR LOCACIÓN.
		IF @VP_CU_2_LOC_ANTERIOR <>	@VP_CU_2_LOC
		BEGIN
			SET @VP_CONTADOR += 1
			INSERT INTO @TRANSACTION_REPORT_SQL_2
					(	[TA_2_QTY_SQFT]		,[TA_2_L_FORMAT]	)--,[TA_2_ORDEN])
			VALUES	(	@VP_TOTAL_QTY_SQFT	,1					)--,@VP_CONTADOR)

			SET @VP_TOTAL_QTY_SQFT = 0
			SET @VP_CONTADOR += 1
		END
		
		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS

		-- SE INSERTA EL TOTAL DEL ÚLTIMO GRUPO DE REGISTROS.
		SET @VP_CONTADOR += 1
		INSERT INTO @TRANSACTION_REPORT_SQL_2
		(	[TA_2_QTY_SQFT]		,[TA_2_L_FORMAT]		)	--,[TA_2_ORDEN])
		SELECT	CONVERT(VARCHAR(25),SUM(CONVERT(DECIMAL(10,4),TA_QTY_SQFT)))
				,1
				--,@VP_CONTADOR
		FROM	@TRANSACTION_REPORT_SQL_1
		WHERE	TA_LOC	= @VP_CU_2_LOC_ANTERIOR
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	IF @PP_L_CONCILIACION = 1
	BEGIN	
		INSERT INTO @TRANSACTION_REPORT_SQL_2 (	[TA_2_DATE],	[TA_2_TIME]		,[TA_2_L_FORMAT]	)--,[TA_2_ORDEN]		,[TA_2_ORDEN_LETRA])	
		VALUES
				 ( '' ,'',''																			)--				,@VP_CONTADOR + 1	,'C')
				,( '' ,'',''																			)--				,@VP_CONTADOR + 1	,'C')
				,( '' ,'',''																			)--				,@VP_CONTADOR + 1	,'C')	
				,( 'Received'		,CONVERT(VARCHAR(25),FORMAT(@VP_TOTAL_RECEIVED		,'0.00'))	,3	)--				,@VP_CONTADOR + 1	,'C')
				,( 'Issue Out'		,CONVERT(VARCHAR(25),FORMAT(@VP_TOTAL_ISSUE_OUT		,'0.00'))	,3	)--				,@VP_CONTADOR + 1	,'C')
				,( 'Trans Balance'	,CONVERT(VARCHAR(25),FORMAT(@VP_TOTAL_CUTTING		,'0.00'))	,3	)--				,@VP_CONTADOR + 1	,'C')
				,( 'Stock Take'		,CONVERT(VARCHAR(25),FORMAT(@VP_TOTAL_STOCK_TAKE	,'0.00'))	,3	)--				,@VP_CONTADOR + 1	,'C')
				,( 'Quarentine'		,CONVERT(VARCHAR(25),FORMAT(@VP_TOTAL_QUARENTINE	,'0.00'))	,3	)--				,@VP_CONTADOR + 1	,'C')
	END

--	ORDER BY	TA_3_ORDEN
--	ORDER BY	TA_3_ORDEN
	SELECT	--*  
		 [TA_2_DATE]			AS [DATE]
--		,(
--			CASE
--			WHEN	[TA_2_L_FORMAT] = '1'	THEN	CONVERT(VARCHAR(50),FORMAT(CONVERT(DECIMAL(16,4),[TA_2_TIME]), '#,##0.00'))
--			ELSE	[TA_2_TIME]			
--		END)					AS [TIME]
		,[TA_2_TIME]
		,[TA_2_DOC_NO]			AS DOC_NO		
		,[TA_2_ITEM_NO]			AS ITEM_NO		
		,[TA_2_SOURCE]			AS [SOURCE]
		,[TA_2_TRANS]			AS TRANS			
		,[TA_2_SER_LOT_NO]		AS PACK
--		,(
--			CASE
--			WHEN	[TA_2_L_FORMAT] = ''	OR [TA_2_L_FORMAT] = '1'	THEN	TA_2_QTY_SQFT
--			ELSE	CONVERT(VARCHAR(50),FORMAT(CONVERT(DECIMAL(16,4),[TA_2_QTY_SQFT]), '#,##0.00'))
--		END)					AS QTY_SQFT
		,[TA_2_QTY_SQFT]
		,[TA_2_USERNAME]		AS USERNAME		
		,[TA_2_COMMENTS]		AS COMMENTS		
		,[TA_2_L_FORMAT]		AS L_FORMATO
--		,TA_2_ORDEN
--		,TA_2_ORDEN_LETRA
	FROM @TRANSACTION_REPORT_SQL_2
--	UNION
--	SELECT 
--		 [TA_3_DATE]			AS [DATE]
--		,[TA_3_TIME]			AS [TIME]
--		,[TA_3_DOC_NO]			AS DOC_NO		
--		,[TA_3_ITEM_NO]			AS ITEM_NO		
--		,[TA_3_SOURCE]			AS [SOURCE]
--		,[TA_3_TRANS]			AS TRANS			
--		,[TA_3_SER_LOT_NO]		AS PACK
--		,TA_3_QTY_SQFT			AS QTY_SQFT
--		,[TA_3_USERNAME]		AS USERNAME		
--		,[TA_3_COMMENTS]		AS COMMENTS
--		,TA_2_ORDEN
--		,TA_2_ORDEN_LETRA
--	FROM @TRANSACTION_REPORT_SQL_3
--	ORDER BY TA_2_ORDEN		, TA_2_ORDEN_LETRA
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / PARA TRANSACTION_REPORT POR ITEM
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TRANSACTION_REPORT_BY_ITEM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_ITEM]
GO
--		 EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_ITEM] 0,139,'FYPATX7','01-14-2021','01-14-2021'
--		 EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_ITEM] 0,139,'','01-14-2021','01-14-2021'
CREATE PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_ITEM]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_S_ITEM						VARCHAR(25),
	@PP_F_INIT						DATE,
	@PP_F_FINISH					DATE
AS
	-- ////////////// PARA INGRESAR EL SELECT DEL FRONT
	DECLARE @TRANSACTION_REPORT_SQL_1		TABLE
	(	
		 [TA_LOC]			VARCHAR(150) DEFAULT ''			,[TA_DATE]			VARCHAR(150) DEFAULT ''			,[TA_TIME]			VARCHAR(150) DEFAULT ''
		,[TA_DOC_NO]		VARCHAR(150) DEFAULT ''			,[TA_ITEM_NO]		VARCHAR(150) DEFAULT ''			,[TA_SOURCE]		VARCHAR(150) DEFAULT ''
		,[TA_TRANS]			VARCHAR(150) DEFAULT ''			,[TA_SER_LOT_NO]	VARCHAR(150) DEFAULT ''			,[TA_QTY_SQFT]		VARCHAR(150) DEFAULT ''
		,[TA_USERNAME]		VARCHAR(150) DEFAULT ''			,[TA_COMMENTS]		VARCHAR(500) DEFAULT ''			,[TA_LEVEL_NO]		VARCHAR(150) DEFAULT ''
	)
	SET NOCOUNT ON
	-- ////////////// PARA DIVIDIR POR GRUPOS
	DECLARE @TRANSACTION_REPORT_SQL_2		TABLE
	(	
		 [TA_2_DATE]			VARCHAR(150) DEFAULT ''			,[TA_2_TIME]			VARCHAR(150) DEFAULT ''			,[TA_2_DOC_NO]			VARCHAR(150) DEFAULT ''
		,[TA_2_ITEM_NO]			VARCHAR(150) DEFAULT ''			,[TA_2_SOURCE]			VARCHAR(150) DEFAULT ''			,[TA_2_TRANS]			VARCHAR(150) DEFAULT ''
		,[TA_2_SER_LOT_NO]		VARCHAR(150) DEFAULT ''			,[TA_2_QTY_SQFT]		VARCHAR(150) DEFAULT ''			,[TA_2_USERNAME]		VARCHAR(150) DEFAULT ''
		,[TA_2_COMMENTS]		VARCHAR(500) DEFAULT ''			,[TA_2_L_FORMAT]		VARCHAR(500) DEFAULT ''
	)
	SET NOCOUNT ON

	-- ////////////// SE HACE EL INSERT EN LA TABLA #1
			INSERT INTO @TRANSACTION_REPORT_SQL_1
			(
				 TA_LOC
				,TA_DATE		,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			,TA_SOURCE			
				,TA_TRANS		,TA_SER_LOT_NO		,TA_QTY_SQFT		,TA_USERNAME		,TA_COMMENTS		
				,TA_LEVEL_NO
			)
			SELECT 
					 IMINVTRX_SQL.Loc
					 ,CONVERT(varchar,DBO.CONVERT_INT_TO_DATE(IMLSTRX_SQL.Trx_Dt),103)
					,DBO.CONVERT_INT_TO_TIME(IMLSTRX_SQL.Trx_Tm)
					,IMINVTRX_SQL.Doc_Ord_No
					,IMLSTRX_SQL.Item_No
					,RTRIM(LTRIM(IMLSTRX_SQL.Source))
					,LTRIM(RTRIM(IMINVTRX_SQL.Doc_Type))
					,IMLSTRX_SQL.Ser_Lot_No
					,IMLSTRX_SQL.Trx_Qty
					,UPPER(IMINVTRX_SQL.User_Name)
					,IMINVTRX_SQL.Comment
					,IMLSTRX_SQL.Lev_No
			FROM IMLSTRX_SQL,IMINVTRX_SQL
			WHERE(IMLSTRX_SQL.Source = IMINVTRX_SQL.Source And IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No)
			AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No 
			AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
			-- =============================			
			AND		(		@PP_S_ITEM	=''			
						OR	IMLSTRX_SQL.item_no=@PP_S_ITEM 
					)
			-- =============================	
			AND		(			IMLSTRX_SQL.trx_dt>=DBO.CONVERT_DATE_TO_INT(@PP_F_INIT,'yyyyMMdd')
						AND		IMLSTRX_SQL.trx_dt<=DBO.CONVERT_DATE_TO_INT(@PP_F_FINISH,'yyyyMMdd')
					)
			-- =============================
			ORDER BY	IMINVTRX_SQL.loc,	IMLSTRX_SQL.trx_dt,		IMLSTRX_SQL.trx_tm

-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
		DECLARE		 @VP_CU_2_LOC				VARCHAR(150)					,@VP_CU_2_DATE				VARCHAR(150)					,@VP_CU_2_TIME				VARCHAR(150)
					,@VP_CU_2_DOC_NO			VARCHAR(150)					,@VP_CU_2_ITEM_NO			VARCHAR(150)					,@VP_CU_2_SOURCE			VARCHAR(150)
					,@VP_CU_2_TRANS				VARCHAR(150)					,@VP_CU_2_SER_LOT_NO		VARCHAR(150)					,@VP_CU_2_QTY_SQFT			VARCHAR(150)
					,@VP_CU_2_USERNAME			VARCHAR(150)					,@VP_CU_2_COMMENTS			VARCHAR(500)					,@VP_CU_2_SOURCE_O			VARCHAR(150)
					,@VP_CU_2_TRANS_O			VARCHAR(150)					,@VP_CU_2_LEVEL_NO			VARCHAR(150)					,@VP_CU_2_QTY_SQFT_O		VARCHAR(150)

					,@VP_TOTAL_QTY_SQFT			DECIMAL(10,4)	= 0
					,@VP_CU_2_LOC_ANTERIOR		VARCHAR(150)	= ''

		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			SELECT
			 TA_LOC
			,TA_DATE		,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			
			,(CASE
						WHEN TA_SOURCE = 'I'	THEN	'IM'
						WHEN TA_SOURCE = 'P'	THEN	'PO'
						WHEN TA_SOURCE = 'O'	THEN	'OE'
						WHEN TA_SOURCE = 'S'	THEN	'SF'
						WHEN TA_SOURCE = 'C'	THEN	'CC'
						ELSE TA_SOURCE + '-Unkwn'
			END)	
			,(CASE
						WHEN TA_TRANS = 'A' THEN	'Allocation'
						WHEN TA_TRANS = 'B' THEN	'Balance'
						WHEN TA_TRANS = 'H' THEN	'Start of Month'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'I' THEN	'Issue Out'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'O' THEN	'Invoice'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'P' THEN	'Issue'
						WHEN TA_TRANS = 'L' THEN	'Lot Adjustment'
						WHEN TA_TRANS = 'P' THEN	'Stock Take'
						WHEN TA_TRANS = 'Q' THEN	'Quantity Adjust'
						WHEN TA_TRANS = 'R' AND TA_SOURCE = 'C' THEN	'Received'	---IMLSTRX_SQL.Source = 'C' THEN	'RECEIVE'
						WHEN TA_TRANS = 'R' THEN	'Received'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	'Trans - Out'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 1	THEN	'Trans - In'
						WHEN TA_TRANS = 'Z' THEN	'Received'
						ELSE 'Unknown'
					END)													--AS [TRANS]
			,TA_SER_LOT_NO		
			,(CASE
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'I' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'O' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'P' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				ELSE CONVERT(DECIMAL(10,4),TA_QTY_SQFT)
			END)
			,TA_USERNAME		
			,TA_COMMENTS
			FROM	@TRANSACTION_REPORT_SQL_1
			ORDER BY	TA_LOC,	TA_DATE,	TA_TIME
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @VP_CU_2_LOC_ANTERIOR <>	@VP_CU_2_LOC
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	TA_2_DATE )
				SELECT	TOP (1) 
						LTRIM(RTRIM(LOC)) + '	' + LTRIM(RTRIM(loc_desc))
				FROM	IMLOCFIL_SQL
				WHERE	LTRIM(RTRIM(LOC))	= @VP_CU_2_LOC
			END

			INSERT INTO @TRANSACTION_REPORT_SQL_2
			(
				 TA_2_DATE		,TA_2_TIME				,TA_2_DOC_NO		,TA_2_ITEM_NO		,TA_2_SOURCE			
				,TA_2_TRANS		,TA_2_SER_LOT_NO		,TA_2_QTY_SQFT		,TA_2_USERNAME		,TA_2_COMMENTS
				,TA_2_L_FORMAT
			)
			VALUES	
			(
				 @VP_CU_2_DATE		,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
				,@VP_CU_2_TRANS		,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS		
				,0
			)
						
			SET @VP_TOTAL_QTY_SQFT +=	@VP_CU_2_QTY_SQFT
			
			SET	@VP_CU_2_LOC_ANTERIOR	=	@VP_CU_2_LOC
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS

			IF @VP_CU_2_LOC_ANTERIOR <>	@VP_CU_2_LOC
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	[TA_2_QTY_SQFT]		,[TA_2_L_FORMAT]	)
				VALUES	(	@VP_TOTAL_QTY_SQFT	,0					)

				SET @VP_TOTAL_QTY_SQFT = 0
			END

		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	SELECT 
		 [TA_2_DATE]			AS [DATE]
		,[TA_2_TIME]			AS [TIME]
		,[TA_2_DOC_NO]			AS DOC_NO		
		,[TA_2_ITEM_NO]			AS ITEM_NO		
		,[TA_2_SOURCE]			AS [SOURCE]
		,[TA_2_TRANS]			AS TRANS			
		,[TA_2_SER_LOT_NO]		AS PACK
		,(
		CASE
			WHEN	[TA_2_L_FORMAT] = ''	THEN	TA_2_QTY_SQFT
			ELSE	FORMAT(CONVERT(DECIMAL(16,4),[TA_2_QTY_SQFT]), '#,##0.00')		
		END)	AS QTY_SQFT
		,[TA_2_USERNAME]		AS USERNAME		
		,[TA_2_COMMENTS]		AS COMMENTS		
	FROM @TRANSACTION_REPORT_SQL_2
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / PARA TRANSACTION_REPORT POR JOBNO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TRANSACTION_REPORT_BY_JOBNO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_JOBNO]
GO
--		 EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_JOBNO] 0,139,'21977','01-14-2021','01-14-2021'
--		 EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_JOBNO] 0,139,'','01-14-2021','01-14-2021'
CREATE PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_JOBNO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_JOB_NO						VARCHAR(25),
	@PP_F_INIT						DATE,
	@PP_F_FINISH					DATE
AS
	-- ////////////// PARA INGRESAR EL SELECT DEL FRONT
	DECLARE @TRANSACTION_REPORT_SQL_1		TABLE
	(	
		 [TA_LOC]			VARCHAR(150) DEFAULT ''			,[TA_DATE]			VARCHAR(150) DEFAULT ''			,[TA_TIME]			VARCHAR(150) DEFAULT ''
		,[TA_DOC_NO]		VARCHAR(150) DEFAULT ''			,[TA_ITEM_NO]		VARCHAR(150) DEFAULT ''			,[TA_SOURCE]		VARCHAR(150) DEFAULT ''
		,[TA_TRANS]			VARCHAR(150) DEFAULT ''			,[TA_SER_LOT_NO]	VARCHAR(150) DEFAULT ''			,[TA_QTY_SQFT]		VARCHAR(150) DEFAULT ''
		,[TA_USERNAME]		VARCHAR(150) DEFAULT ''			,[TA_COMMENTS]		VARCHAR(500) DEFAULT ''			,[TA_LEVEL_NO]		VARCHAR(150) DEFAULT ''
	)
	SET NOCOUNT ON
	-- ////////////// PARA DIVIDIR POR GRUPOS
	DECLARE @TRANSACTION_REPORT_SQL_2		TABLE
	(	
		 [TA_2_DATE]			VARCHAR(150) DEFAULT ''			,[TA_2_TIME]			VARCHAR(150) DEFAULT ''			,[TA_2_DOC_NO]			VARCHAR(150) DEFAULT ''
		,[TA_2_ITEM_NO]			VARCHAR(150) DEFAULT ''			,[TA_2_SOURCE]			VARCHAR(150) DEFAULT ''			,[TA_2_TRANS]			VARCHAR(150) DEFAULT ''
		,[TA_2_SER_LOT_NO]		VARCHAR(150) DEFAULT ''			,[TA_2_QTY_SQFT]		VARCHAR(150) DEFAULT ''			,[TA_2_USERNAME]		VARCHAR(150) DEFAULT ''
		,[TA_2_COMMENTS]		VARCHAR(500) DEFAULT ''			,[TA_2_L_FORMAT]		VARCHAR(500) DEFAULT ''
	)
	SET NOCOUNT ON

	-- ////////////// SE HACE EL INSERT EN LA TABLA #1
			INSERT INTO @TRANSACTION_REPORT_SQL_1
			(
				 TA_LOC
				,TA_DATE		,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			,TA_SOURCE			
				,TA_TRANS		,TA_SER_LOT_NO		,TA_QTY_SQFT		,TA_USERNAME		,TA_COMMENTS		
				,TA_LEVEL_NO
			)
			SELECT 
					LTRIM(RTRIM(IMINVTRX_SQL.Loc))
					,CONVERT(varchar,DBO.CONVERT_INT_TO_DATE(IMLSTRX_SQL.Trx_Dt),103)
					,DBO.CONVERT_INT_TO_TIME(IMLSTRX_SQL.Trx_Tm)
					,IMINVTRX_SQL.Doc_Ord_No
					,IMLSTRX_SQL.Item_No
					,RTRIM(LTRIM(IMLSTRX_SQL.Source))
					,LTRIM(RTRIM(IMINVTRX_SQL.Doc_Type))
					,IMLSTRX_SQL.Ser_Lot_No
					,IMLSTRX_SQL.Trx_Qty
					,UPPER(IMINVTRX_SQL.User_Name)
					,IMINVTRX_SQL.Comment
					,IMLSTRX_SQL.Lev_No
			FROM IMLSTRX_SQL,IMINVTRX_SQL
			WHERE(IMLSTRX_SQL.Source = IMINVTRX_SQL.Source And IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No)
			AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No 
			AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
			-- =============================
			AND		(		IMINVTRX_SQL.doc_ord_no	= @PP_JOB_NO	
						OR	IMINVTRX_SQL.doc_ord_no	= 'J'+@PP_JOB_NO	
					)			
			-- =============================	
			AND		(			IMLSTRX_SQL.trx_dt>=DBO.CONVERT_DATE_TO_INT(@PP_F_INIT,'yyyyMMdd')
						AND		IMLSTRX_SQL.trx_dt<=DBO.CONVERT_DATE_TO_INT(@PP_F_FINISH,'yyyyMMdd')
					)
			-- =============================
			ORDER BY	IMINVTRX_SQL.loc,	IMLSTRX_SQL.trx_dt,		IMLSTRX_SQL.trx_tm
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
		DECLARE		 @VP_CU_2_LOC				VARCHAR(150)					,@VP_CU_2_DATE				VARCHAR(150)					,@VP_CU_2_TIME				VARCHAR(150)
					,@VP_CU_2_DOC_NO			VARCHAR(150)					,@VP_CU_2_ITEM_NO			VARCHAR(150)					,@VP_CU_2_SOURCE			VARCHAR(150)
					,@VP_CU_2_TRANS				VARCHAR(150)					,@VP_CU_2_SER_LOT_NO		VARCHAR(150)					,@VP_CU_2_QTY_SQFT			VARCHAR(150)
					,@VP_CU_2_USERNAME			VARCHAR(150)					,@VP_CU_2_COMMENTS			VARCHAR(500)					,@VP_CU_2_SOURCE_O			VARCHAR(150)
					,@VP_CU_2_TRANS_O			VARCHAR(150)					,@VP_CU_2_LEVEL_NO			VARCHAR(150)					,@VP_CU_2_QTY_SQFT_O		VARCHAR(150)

					,@VP_TOTAL_QTY_SQFT			DECIMAL(10,4)	= 0
					,@VP_CU_2_LOC_ANTERIOR		VARCHAR(150)	= ''

		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			SELECT
			 TA_LOC
			,TA_DATE		,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			
			,(CASE
						WHEN TA_SOURCE = 'I'	THEN	'IM'
						WHEN TA_SOURCE = 'P'	THEN	'PO'
						WHEN TA_SOURCE = 'O'	THEN	'OE'
						WHEN TA_SOURCE = 'S'	THEN	'SF'
						WHEN TA_SOURCE = 'C'	THEN	'CC'
						ELSE TA_SOURCE + '-Unkwn'
			END)	
			,(CASE
						WHEN TA_TRANS = 'A' THEN	'Allocation'
						WHEN TA_TRANS = 'B' THEN	'Balance'
						WHEN TA_TRANS = 'H' THEN	'Start of Month'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'I' THEN	'Issue Out'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'O' THEN	'Invoice'
						WHEN TA_TRANS = 'I' AND TA_SOURCE = 'P' THEN	'Issue'
						WHEN TA_TRANS = 'L' THEN	'Lot Adjustment'
						WHEN TA_TRANS = 'P' THEN	'Stock Take'
						WHEN TA_TRANS = 'Q' THEN	'Quantity Adjust'
						WHEN TA_TRANS = 'R' AND TA_SOURCE = 'C' THEN	'Received'	---IMLSTRX_SQL.Source = 'C' THEN	'RECEIVE'
						WHEN TA_TRANS = 'R' THEN	'Received'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	'Trans - Out'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 1	THEN	'Trans - In'
						WHEN TA_TRANS = 'Z' THEN	'Received'
						ELSE 'Unknown'
					END)													--AS [TRANS]
			,TA_SER_LOT_NO		
			,(CASE
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'I' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'O' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'I' AND TA_SOURCE = 'P' THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	(	CONVERT(DECIMAL(10,4),TA_QTY_SQFT)	* -1	)
				ELSE CONVERT(DECIMAL(10,4),TA_QTY_SQFT)
			END)
			,TA_USERNAME		
			,TA_COMMENTS
			FROM	@TRANSACTION_REPORT_SQL_1
			ORDER BY	TA_LOC,	TA_DATE,	TA_TIME
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @VP_CU_2_LOC_ANTERIOR <>	@VP_CU_2_LOC
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	TA_2_DATE )
				SELECT	TOP (1) 
						LTRIM(RTRIM(LOC)) + '	' + LTRIM(RTRIM(loc_desc))
				FROM	IMLOCFIL_SQL
				WHERE	LTRIM(RTRIM(LOC))	= @VP_CU_2_LOC
			END

			INSERT INTO @TRANSACTION_REPORT_SQL_2
			(
				 TA_2_DATE		,TA_2_TIME				,TA_2_DOC_NO		,TA_2_ITEM_NO		,TA_2_SOURCE			
				,TA_2_TRANS		,TA_2_SER_LOT_NO		,TA_2_QTY_SQFT		,TA_2_USERNAME		,TA_2_COMMENTS
				,TA_2_L_FORMAT
			)
			VALUES	
			(
				 @VP_CU_2_DATE		,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
				,@VP_CU_2_TRANS		,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS		
				,0
			)
						
			SET @VP_TOTAL_QTY_SQFT +=	@VP_CU_2_QTY_SQFT
			
			SET	@VP_CU_2_LOC_ANTERIOR	=	@VP_CU_2_LOC
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS

			IF @VP_CU_2_LOC_ANTERIOR <>	@VP_CU_2_LOC
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	[TA_2_QTY_SQFT]		,[TA_2_L_FORMAT]	)
				VALUES	(	@VP_TOTAL_QTY_SQFT	,0					)

				SET @VP_TOTAL_QTY_SQFT = 0
			END

		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================

	SELECT 
		 [TA_2_DATE]			AS [DATE]
		,[TA_2_TIME]			AS [TIME]
		,[TA_2_DOC_NO]			AS DOC_NO		
		,[TA_2_ITEM_NO]			AS ITEM_NO		
		,[TA_2_SOURCE]			AS [SOURCE]
		,[TA_2_TRANS]			AS TRANS			
		,[TA_2_SER_LOT_NO]		AS PACK
		,(
		CASE
			WHEN	[TA_2_L_FORMAT] = ''	THEN	TA_2_QTY_SQFT
			ELSE	FORMAT(CONVERT(DECIMAL(16,4),[TA_2_QTY_SQFT]), '#,##0.00')		
		END)	AS QTY_SQFT
		,[TA_2_USERNAME]		AS USERNAME		
		,[TA_2_COMMENTS]		AS COMMENTS		
	FROM @TRANSACTION_REPORT_SQL_2
GO

-- POR ITEM        

----	COMBO PARA SELECCIONAR ITEMS    
--SELECT DISTINCT(item_no)--* 
--FROM	IMLSTRX_SQL
--WHERE	LTRIM(RTRIM(item_no)) <> ''
--AND		LTRIM(RTRIM(item_no))	LIKE 'F%'
--ORDER	BY	item_no			
						
			
---		POR PACK			
			-- strSPackNo = Trim(Str(intSpNo))
            -- intLen = 9 - Len(strSPackNo)
            -- strSPackNo = strSPackNo & Space(intLen)

------SELECT IMLSTRX_SQL.Source, IMLSTRX_SQL.Ord_No, IMLSTRX_SQL.Ctl_No, IMINVTRX_SQL.Quantity,
------IMLSTRX_SQL.Line_No, IMLSTRX_SQL.Lev_No, IMLSTRX_SQL.Seq_No, IMLSTRX_SQL.Ser_Lot_No,
------IMLSTRX_SQL.Trx_Dt, IMLSTRX_SQL.Trx_Qty, IMLSTRX_SQL.Item_No, IMINVTRX_SQL.Loc, IMINVTRX_SQL.Doc_Dt,
------IMINVTRX_SQL.Doc_Type, IMINVTRX_SQL.Doc_Ord_No, IMINVTRX_SQL.Doc_Source, IMINVTRX_SQL.User_Name,
------IMLSTRX_SQL.Trx_Tm, IMINVTRX_SQL.Comment
------FROM IMLSTRX_SQL,IMINVTRX_SQL
------WHERE(IMLSTRX_SQL.Source = IMINVTRX_SQL.Source And IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No)
------AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No 
------AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
        
--------and IMLSTRX_SQL.trx_dt>='20210111'
--------and IMLSTRX_SQL.trx_dt<	='20210111'
--------ORDER BY IMINVTRX_SQL.loc,IMLSTRX_SQL.trx_dt
------AND IMLSTRX_SQL.item_no='" & Trim(TextBox1.Text) & "' and (IMLSTRX_SQL.trx_dt>='" & DateTimePicker1.Value.Year & DateTimePicker1.Value.Month.ToString.PadLeft(2, "0") & DateTimePicker1.Value.Day.ToString.PadLeft(2, "0") & "' and IMLSTRX_SQL.trx_dt<='" & DateTimePicker2.Value.Year & DateTimePicker2.Value.Month.ToString.PadLeft(2, "0") & DateTimePicker2.Value.Day.ToString.PadLeft(2, "0") & "')" & _
------                "ORDER BY IMINVTRX_SQL.loc,IMLSTRX_SQL.trx_dt,IMLSTRX_SQL.trx_tm"
------        End If