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
-- EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK] 0,139,105501,1
-- EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK] 0,139,106501,1

CREATE PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_PACK_NO						INT,
	@PP_L_CONCILIACION				INT
AS

-- POR LOTE
--SELECT * FROM IMLSTRX_SQL
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
		)
		SET NOCOUNT ON

		DECLARE		 @VP_CU_LOC				VARCHAR(150)
					,@VP_CU_DATE			VARCHAR(150)
					,@VP_CU_TIME			VARCHAR(150)
					,@VP_CU_DOC_NO			VARCHAR(150)
					,@VP_CU_ITEM_NO			VARCHAR(150)
					,@VP_CU_SOURCE			VARCHAR(150)
					,@VP_CU_TRANS			VARCHAR(150)
					,@VP_CU_SER_LOT_NO		VARCHAR(150)
					,@VP_CU_QTY_SQFT		VARCHAR(150)
					,@VP_CU_USERNAME		VARCHAR(150)
					,@VP_CU_COMMENTS		VARCHAR(500)
					,@VP_CU_LEVEL_NO		VARCHAR(150)
					
		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC FOR
			SELECT
					 IMINVTRX_SQL.Loc										-- + '   ' + IMLOCFIL_SQL.loc_desc
					,IMLSTRX_SQL.Trx_Dt										--AS	[DATE]
					,DBO.CONVERT_INT_TO_TIME(IMLSTRX_SQL.Trx_Tm)			--AS	[TIME]
					,IMINVTRX_SQL.Doc_Ord_No								--AS	[DOC_NO]
					,IMLSTRX_SQL.Item_No									--AS	[ITEM_NO]
					,RTRIM(LTRIM(IMLSTRX_SQL.Source))
					,LTRIM(RTRIM(IMINVTRX_SQL.Doc_Type))
					,IMLSTRX_SQL.Ser_Lot_No									--AS [SER_LOT_NO]
					,IMLSTRX_SQL.Trx_Qty
					,UPPER(IMINVTRX_SQL.User_Name)							--AS [USERNAME]
					,IMINVTRX_SQL.Comment									--AS [COMMENT]
					,IMLSTRX_SQL.Lev_No
					--=====================================================================================
			FROM IMLSTRX_SQL, IMINVTRX_SQL, IMLOCFIL_SQL
			WHERE IMLSTRX_SQL.Source = IMINVTRX_SQL.Source
			AND IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No
			AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No
			AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No
			AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No
			AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
			AND (IMLSTRX_SQL.Ser_Lot_No LIKE Format(@PP_PACK_NO, '_________000000')	            --	strSPackNo = Format(intSpNo ó 106501, "_________000000")
			OR (
				IMLSTRX_SQL.Ser_Lot_No BETWEEN Format(@PP_PACK_NO, '000000') + '   000000'
			    AND Format(@PP_PACK_NO, '000000') + '   999999' )
			OR ( 
						IMLSTRX_SQL.Ser_Lot_No BETWEEN LTRIM(RTRIM(@PP_PACK_NO))+'000000'
			            AND  LTRIM(RTRIM(@PP_PACK_NO))+'999999')) 
			AND IMLOCFIL_SQL.loc	= IMINVTRX_SQL.Loc
			--AND	IMINVTRX_SQL.loc	= @VP_CU_S_LOCATION
			ORDER BY IMINVTRX_SQL.Loc,IMLSTRX_SQL.trx_dt,IMLSTRX_SQL.trx_tm
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_LOC
												,@VP_CU_DATE			,@VP_CU_TIME			,@VP_CU_DOC_NO			,@VP_CU_ITEM_NO			,@VP_CU_SOURCE			
												,@VP_CU_TRANS			,@VP_CU_SER_LOT_NO		,@VP_CU_QTY_SQFT		,@VP_CU_USERNAME		,@VP_CU_COMMENTS
												,@VP_CU_LEVEL_NO				
		WHILE @@FETCH_STATUS = 0
			BEGIN	

			INSERT INTO @TRANSACTION_REPORT_SQL_1
			(
				 TA_LOC
				,TA_DATE		,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			,TA_SOURCE			
				,TA_TRANS		,TA_SER_LOT_NO		,TA_QTY_SQFT		,TA_USERNAME		,TA_COMMENTS		
				,TA_LEVEL_NO
			)
			VALUES	
			(
				 @VP_CU_LOC
				,@VP_CU_DATE		,@VP_CU_TIME			,@VP_CU_DOC_NO			,@VP_CU_ITEM_NO			,@VP_CU_SOURCE			
				,@VP_CU_TRANS		,@VP_CU_SER_LOT_NO		,@VP_CU_QTY_SQFT		,@VP_CU_USERNAME		,@VP_CU_COMMENTS		
				,@VP_CU_LEVEL_NO		
			)


		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_LOC
												,@VP_CU_DATE			,@VP_CU_TIME			,@VP_CU_DOC_NO			,@VP_CU_ITEM_NO			,@VP_CU_SOURCE			
												,@VP_CU_TRANS			,@VP_CU_SER_LOT_NO		,@VP_CU_QTY_SQFT		,@VP_CU_USERNAME		,@VP_CU_COMMENTS
												,@VP_CU_LEVEL_NO		
		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS

-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	DECLARE	 @VP_TOTAL_RECEIVED			DECIMAL(10,4)	= 0
			,@VP_TOTAL_ISSUE_OUT		DECIMAL(10,4)	= 0
			,@VP_TOTAL_CUTTING			DECIMAL(10,4)	= 0
			,@VP_TOTAL_STOCK_TAKE		DECIMAL(10,4)	= 0
			,@VP_TOTAL_QUARENTINE		DECIMAL(10,4)	= 0

	DECLARE	 @VP_CU_S_LOCATION		VARCHAR(150)
			,@VP_CU_D_LOCATION		VARCHAR(150)


	DECLARE CU_LOCATIONS CURSOR FOR
		SELECT	 LTRIM(RTRIM(LOC))
				,LTRIM(RTRIM(loc_desc))
		FROM	IMLOCFIL_SQL
		--SET NOCOUNT ON	
	OPEN CU_LOCATIONS
	FETCH NEXT FROM CU_LOCATIONS INTO @VP_CU_S_LOCATION		,@VP_CU_D_LOCATION
	WHILE @@FETCH_STATUS = 0
		BEGIN

		DECLARE  @VP_CONTADOR			INT = 0
				,@VP_TOTAL_QTY_SQFT		DECIMAL(10,4)	= 0
		--SET @VP_CONTADOR = 0
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
		DECLARE		 @VP_CU_2_LOC				VARCHAR(150)
					,@VP_CU_2_DATE				VARCHAR(150)
					,@VP_CU_2_TIME				VARCHAR(150)
					,@VP_CU_2_DOC_NO			VARCHAR(150)
					,@VP_CU_2_ITEM_NO			VARCHAR(150)
					,@VP_CU_2_SOURCE			VARCHAR(150)
					,@VP_CU_2_TRANS				VARCHAR(150)
					,@VP_CU_2_SER_LOT_NO		VARCHAR(150)
					,@VP_CU_2_QTY_SQFT			VARCHAR(150)
					,@VP_CU_2_USERNAME			VARCHAR(150)
					,@VP_CU_2_COMMENTS			VARCHAR(500)
					,@VP_CU_2_SOURCE_O			VARCHAR(150)
					,@VP_CU_2_TRANS_O			VARCHAR(150)
					,@VP_CU_2_LEVEL_NO			VARCHAR(150)
					,@VP_CU_2_QTY_SQFT_O		VARCHAR(150)

		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC FOR
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
						WHEN TA_TRANS = 'R' AND TA_SOURCE = 'C' THEN	'Receive'	---IMLSTRX_SQL.Source = 'C' THEN	'RECEIVE'
						WHEN TA_TRANS = 'R' THEN	'Received'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	'Trans - Out'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 1	THEN	'Trans - In'
						WHEN TA_TRANS = 'Z' THEN	'Received'
						ELSE 'UNKNOWN'
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
			,TA_SOURCE
			,TA_TRANS
			,TA_LEVEL_NO
			,TA_QTY_SQFT
			FROM	@TRANSACTION_REPORT_SQL_1
			WHERE	TA_LOC	= @VP_CU_S_LOCATION
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
												,@VP_CU_2_SOURCE_O		,@VP_CU_2_TRANS_O			,@VP_CU_2_LEVEL_NO		,@VP_CU_2_QTY_SQFT_O
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @VP_CONTADOR = 0 
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	TA_2_DATE	)
				VALUES	(	@VP_CU_S_LOCATION + ' ' + @VP_CU_D_LOCATION	)
			END

			INSERT INTO @TRANSACTION_REPORT_SQL_2
			(
				 TA_2_DATE		,TA_2_TIME				,TA_2_DOC_NO		,TA_2_ITEM_NO		,TA_2_SOURCE			
				,TA_2_TRANS		,TA_2_SER_LOT_NO		,TA_2_QTY_SQFT		,TA_2_USERNAME		,TA_2_COMMENTS		
			)
			VALUES	
			(
				 @VP_CU_2_DATE		,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
				,@VP_CU_2_TRANS		,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS		
			)
						
			SET @VP_TOTAL_QTY_SQFT +=	@VP_CU_2_QTY_SQFT
			
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
			
			SET @VP_CONTADOR += 1
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
												,@VP_CU_2_SOURCE_O		,@VP_CU_2_TRANS_O			,@VP_CU_2_LEVEL_NO		,@VP_CU_2_QTY_SQFT_O
		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS
			IF @VP_CONTADOR <> 0 
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	[TA_2_QTY_SQFT]	)
				VALUES	(	@VP_TOTAL_QTY_SQFT	)
			END
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	FETCH NEXT FROM CU_LOCATIONS INTO @VP_CU_S_LOCATION		,@VP_CU_D_LOCATION
	END
	CLOSE			CU_LOCATIONS
	DEALLOCATE		CU_LOCATIONS

	IF @PP_L_CONCILIACION = 1
	BEGIN
		INSERT INTO @TRANSACTION_REPORT_SQL_2 (	[TA_2_DATE]	)	VALUES	( '' ),( '' ),( '' )
		
		INSERT INTO @TRANSACTION_REPORT_SQL_2 (	[TA_2_DATE],[TA_2_TIME]	)	
		VALUES	
				 ( 'Received'		,FORMAT(@VP_TOTAL_RECEIVED		,'0.00'))
				,( 'Issue Out'		,FORMAT(@VP_TOTAL_ISSUE_OUT		,'0.00'))
				,( 'Trans Balance'	,FORMAT(@VP_TOTAL_CUTTING		,'0.00'))
				,( 'Stock Take'		,FORMAT(@VP_TOTAL_STOCK_TAKE	,'0.00'))
				,( 'Quarentine'		,FORMAT(@VP_TOTAL_QUARENTINE	,'0.00'))
	END

	SELECT 
		 [TA_2_DATE]			AS [DATE]
		,[TA_2_TIME]			AS [TIME]
		,[TA_2_DOC_NO]			AS DOC_NO		
		,[TA_2_ITEM_NO]			AS ITEM_NO		
		,[TA_2_SOURCE]			AS [SOURCE]
		,[TA_2_TRANS]			AS TRANS			
		,[TA_2_SER_LOT_NO]		AS PACK
		,[TA_2_QTY_SQFT]		AS QTY_SQFT		
		,[TA_2_USERNAME]		AS USERNAME		
		,[TA_2_COMMENTS]		AS COMMENTS		
	FROM @TRANSACTION_REPORT_SQL_2
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / PARA TRANSACTION_REPORT POR ITEM
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]
GO
-- EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK] 0,139,105501,1
-- EXECUTE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK] 0,139,106501,1

CREATE PROCEDURE [dbo].[PG_LI_TRANSACTION_REPORT_BY_PACK]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_PACK_NO						INT,
	@PP_L_CONCILIACION				INT
AS

-- POR LOTE
--SELECT * FROM IMLSTRX_SQL
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
		)
		SET NOCOUNT ON

		DECLARE		 @VP_CU_LOC				VARCHAR(150)
					,@VP_CU_DATE			VARCHAR(150)
					,@VP_CU_TIME			VARCHAR(150)
					,@VP_CU_DOC_NO			VARCHAR(150)
					,@VP_CU_ITEM_NO			VARCHAR(150)
					,@VP_CU_SOURCE			VARCHAR(150)
					,@VP_CU_TRANS			VARCHAR(150)
					,@VP_CU_SER_LOT_NO		VARCHAR(150)
					,@VP_CU_QTY_SQFT		VARCHAR(150)
					,@VP_CU_USERNAME		VARCHAR(150)
					,@VP_CU_COMMENTS		VARCHAR(500)
					,@VP_CU_LEVEL_NO		VARCHAR(150)
					
		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC FOR
			SELECT
					 IMINVTRX_SQL.Loc										-- + '   ' + IMLOCFIL_SQL.loc_desc
					,IMLSTRX_SQL.Trx_Dt										--AS	[DATE]
					,DBO.CONVERT_INT_TO_TIME(IMLSTRX_SQL.Trx_Tm)			--AS	[TIME]
					,IMINVTRX_SQL.Doc_Ord_No								--AS	[DOC_NO]
					,IMLSTRX_SQL.Item_No									--AS	[ITEM_NO]
					,RTRIM(LTRIM(IMLSTRX_SQL.Source))
					,LTRIM(RTRIM(IMINVTRX_SQL.Doc_Type))
					,IMLSTRX_SQL.Ser_Lot_No									--AS [SER_LOT_NO]
					,IMLSTRX_SQL.Trx_Qty
					,UPPER(IMINVTRX_SQL.User_Name)							--AS [USERNAME]
					,IMINVTRX_SQL.Comment									--AS [COMMENT]
					,IMLSTRX_SQL.Lev_No
					--=====================================================================================
			FROM IMLSTRX_SQL, IMINVTRX_SQL, IMLOCFIL_SQL
			WHERE IMLSTRX_SQL.Source = IMINVTRX_SQL.Source
			AND IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No
			AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No
			AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No
			AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No
			AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
			AND (IMLSTRX_SQL.Ser_Lot_No LIKE Format(@PP_PACK_NO, '_________000000')	            --	strSPackNo = Format(intSpNo ó 106501, "_________000000")
			OR (
				IMLSTRX_SQL.Ser_Lot_No BETWEEN Format(@PP_PACK_NO, '000000') + '   000000'
			    AND Format(@PP_PACK_NO, '000000') + '   999999' )
			OR ( 
						IMLSTRX_SQL.Ser_Lot_No BETWEEN LTRIM(RTRIM(@PP_PACK_NO))+'000000'
			            AND  LTRIM(RTRIM(@PP_PACK_NO))+'999999')) 
			AND IMLOCFIL_SQL.loc	= IMINVTRX_SQL.Loc
			--AND	IMINVTRX_SQL.loc	= @VP_CU_S_LOCATION
			ORDER BY IMINVTRX_SQL.Loc,IMLSTRX_SQL.trx_dt,IMLSTRX_SQL.trx_tm
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_LOC
												,@VP_CU_DATE			,@VP_CU_TIME			,@VP_CU_DOC_NO			,@VP_CU_ITEM_NO			,@VP_CU_SOURCE			
												,@VP_CU_TRANS			,@VP_CU_SER_LOT_NO		,@VP_CU_QTY_SQFT		,@VP_CU_USERNAME		,@VP_CU_COMMENTS
												,@VP_CU_LEVEL_NO				
		WHILE @@FETCH_STATUS = 0
			BEGIN	

			INSERT INTO @TRANSACTION_REPORT_SQL_1
			(
				 TA_LOC
				,TA_DATE		,TA_TIME			,TA_DOC_NO			,TA_ITEM_NO			,TA_SOURCE			
				,TA_TRANS		,TA_SER_LOT_NO		,TA_QTY_SQFT		,TA_USERNAME		,TA_COMMENTS		
				,TA_LEVEL_NO
			)
			VALUES	
			(
				 @VP_CU_LOC
				,@VP_CU_DATE		,@VP_CU_TIME			,@VP_CU_DOC_NO			,@VP_CU_ITEM_NO			,@VP_CU_SOURCE			
				,@VP_CU_TRANS		,@VP_CU_SER_LOT_NO		,@VP_CU_QTY_SQFT		,@VP_CU_USERNAME		,@VP_CU_COMMENTS		
				,@VP_CU_LEVEL_NO		
			)


		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_LOC
												,@VP_CU_DATE			,@VP_CU_TIME			,@VP_CU_DOC_NO			,@VP_CU_ITEM_NO			,@VP_CU_SOURCE			
												,@VP_CU_TRANS			,@VP_CU_SER_LOT_NO		,@VP_CU_QTY_SQFT		,@VP_CU_USERNAME		,@VP_CU_COMMENTS
												,@VP_CU_LEVEL_NO		
		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS

-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	DECLARE	 @VP_TOTAL_RECEIVED			DECIMAL(10,4)	= 0
			,@VP_TOTAL_ISSUE_OUT		DECIMAL(10,4)	= 0
			,@VP_TOTAL_CUTTING			DECIMAL(10,4)	= 0
			,@VP_TOTAL_STOCK_TAKE		DECIMAL(10,4)	= 0
			,@VP_TOTAL_QUARENTINE		DECIMAL(10,4)	= 0

	DECLARE	 @VP_CU_S_LOCATION		VARCHAR(150)
			,@VP_CU_D_LOCATION		VARCHAR(150)


	DECLARE CU_LOCATIONS CURSOR FOR
		SELECT	 LTRIM(RTRIM(LOC))
				,LTRIM(RTRIM(loc_desc))
		FROM	IMLOCFIL_SQL
		--SET NOCOUNT ON	
	OPEN CU_LOCATIONS
	FETCH NEXT FROM CU_LOCATIONS INTO @VP_CU_S_LOCATION		,@VP_CU_D_LOCATION
	WHILE @@FETCH_STATUS = 0
		BEGIN

		DECLARE  @VP_CONTADOR			INT = 0
				,@VP_TOTAL_QTY_SQFT		DECIMAL(10,4)	= 0
		--SET @VP_CONTADOR = 0
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
		DECLARE		 @VP_CU_2_LOC				VARCHAR(150)
					,@VP_CU_2_DATE				VARCHAR(150)
					,@VP_CU_2_TIME				VARCHAR(150)
					,@VP_CU_2_DOC_NO			VARCHAR(150)
					,@VP_CU_2_ITEM_NO			VARCHAR(150)
					,@VP_CU_2_SOURCE			VARCHAR(150)
					,@VP_CU_2_TRANS				VARCHAR(150)
					,@VP_CU_2_SER_LOT_NO		VARCHAR(150)
					,@VP_CU_2_QTY_SQFT			VARCHAR(150)
					,@VP_CU_2_USERNAME			VARCHAR(150)
					,@VP_CU_2_COMMENTS			VARCHAR(500)
					,@VP_CU_2_SOURCE_O			VARCHAR(150)
					,@VP_CU_2_TRANS_O			VARCHAR(150)
					,@VP_CU_2_LEVEL_NO			VARCHAR(150)
					,@VP_CU_2_QTY_SQFT_O		VARCHAR(150)

		DECLARE CU_TRANSACTIONS CURSOR LOCAL STATIC FOR
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
						WHEN TA_TRANS = 'R' AND TA_SOURCE = 'C' THEN	'Receive'	---IMLSTRX_SQL.Source = 'C' THEN	'RECEIVE'
						WHEN TA_TRANS = 'R' THEN	'Received'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 0	THEN	'Trans - Out'
						WHEN TA_TRANS = 'T' AND TA_LEVEL_NO = 1	THEN	'Trans - In'
						WHEN TA_TRANS = 'Z' THEN	'Received'
						ELSE 'UNKNOWN'
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
			,TA_SOURCE
			,TA_TRANS
			,TA_LEVEL_NO
			,TA_QTY_SQFT
			FROM	@TRANSACTION_REPORT_SQL_1
			WHERE	TA_LOC	= @VP_CU_S_LOCATION
		OPEN			CU_TRANSACTIONS
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
												,@VP_CU_2_SOURCE_O		,@VP_CU_2_TRANS_O			,@VP_CU_2_LEVEL_NO		,@VP_CU_2_QTY_SQFT_O
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @VP_CONTADOR = 0 
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	TA_2_DATE	)
				VALUES	(	@VP_CU_S_LOCATION + ' ' + @VP_CU_D_LOCATION	)
			END

			INSERT INTO @TRANSACTION_REPORT_SQL_2
			(
				 TA_2_DATE		,TA_2_TIME				,TA_2_DOC_NO		,TA_2_ITEM_NO		,TA_2_SOURCE			
				,TA_2_TRANS		,TA_2_SER_LOT_NO		,TA_2_QTY_SQFT		,TA_2_USERNAME		,TA_2_COMMENTS		
			)
			VALUES	
			(
				 @VP_CU_2_DATE		,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
				,@VP_CU_2_TRANS		,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS		
			)
						
			SET @VP_TOTAL_QTY_SQFT +=	@VP_CU_2_QTY_SQFT
			
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
			
			SET @VP_CONTADOR += 1
		FETCH NEXT FROM CU_TRANSACTIONS INTO	 @VP_CU_2_LOC
												,@VP_CU_2_DATE			,@VP_CU_2_TIME				,@VP_CU_2_DOC_NO		,@VP_CU_2_ITEM_NO		,@VP_CU_2_SOURCE			
												,@VP_CU_2_TRANS			,@VP_CU_2_SER_LOT_NO		,@VP_CU_2_QTY_SQFT		,@VP_CU_2_USERNAME		,@VP_CU_2_COMMENTS
												,@VP_CU_2_SOURCE_O		,@VP_CU_2_TRANS_O			,@VP_CU_2_LEVEL_NO		,@VP_CU_2_QTY_SQFT_O
		END
		CLOSE			CU_TRANSACTIONS
		DEALLOCATE		CU_TRANSACTIONS
			IF @VP_CONTADOR <> 0 
			BEGIN
				INSERT INTO @TRANSACTION_REPORT_SQL_2
						(	[TA_2_QTY_SQFT]	)
				VALUES	(	@VP_TOTAL_QTY_SQFT	)
			END
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
-----===========================================================================================================
	FETCH NEXT FROM CU_LOCATIONS INTO @VP_CU_S_LOCATION		,@VP_CU_D_LOCATION
	END
	CLOSE			CU_LOCATIONS
	DEALLOCATE		CU_LOCATIONS

	IF @PP_L_CONCILIACION = 1
	BEGIN
		INSERT INTO @TRANSACTION_REPORT_SQL_2 (	[TA_2_DATE]	)	VALUES	( '' ),( '' ),( '' )
		
		INSERT INTO @TRANSACTION_REPORT_SQL_2 (	[TA_2_DATE],[TA_2_TIME]	)	
		VALUES	
				 ( 'Received'		,FORMAT(@VP_TOTAL_RECEIVED		,'0.00'))
				,( 'Issue Out'		,FORMAT(@VP_TOTAL_ISSUE_OUT		,'0.00'))
				,( 'Trans Balance'	,FORMAT(@VP_TOTAL_CUTTING		,'0.00'))
				,( 'Stock Take'		,FORMAT(@VP_TOTAL_STOCK_TAKE	,'0.00'))
				,( 'Quarentine'		,FORMAT(@VP_TOTAL_QUARENTINE	,'0.00'))
	END

	SELECT 
		 [TA_2_DATE]			AS [DATE]
		,[TA_2_TIME]			AS [TIME]
		,[TA_2_DOC_NO]			AS DOC_NO		
		,[TA_2_ITEM_NO]			AS ITEM_NO		
		,[TA_2_SOURCE]			AS [SOURCE]
		,[TA_2_TRANS]			AS TRANS			
		,[TA_2_SER_LOT_NO]		AS PACK
		,[TA_2_QTY_SQFT]		AS QTY_SQFT		
		,[TA_2_USERNAME]		AS USERNAME		
		,[TA_2_COMMENTS]		AS COMMENTS		
	FROM @TRANSACTION_REPORT_SQL_2
GO

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