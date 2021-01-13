-- POR LOTE
--SELECT * FROM IMLSTRX_SQL
SELECT 
		 IMLSTRX_SQL.Trx_Dt										AS	[DATE]
		,DBO.CONVERT_INT_TO_TIME(IMLSTRX_SQL.Trx_Tm)			AS	[TIME]
		,IMINVTRX_SQL.Doc_Ord_No								AS	[DOC_NO]
		,IMLSTRX_SQL.Item_No									AS	[ITEM_NO]
		,(CASE
			WHEN IMLSTRX_SQL.Source = 'I'	THEN	'IM'
			WHEN IMLSTRX_SQL.Source = 'P'	THEN	'PO'
			WHEN IMLSTRX_SQL.Source = 'O'	THEN	'OE'
			WHEN IMLSTRX_SQL.Source = 'S'	THEN	'SF'
			WHEN IMLSTRX_SQL.Source = 'C'	THEN	'CC'
			ELSE RTRIM(LTRIM(IMLSTRX_SQL.Source)) + '-Unkwn'
		END)													AS [SOURCE]
		,(CASE
			WHEN IMINVTRX_SQL.Doc_Type = 'A' THEN	'ALLOCATION'
			WHEN IMINVTRX_SQL.Doc_Type = 'B' THEN	'BALANCE'
			WHEN IMINVTRX_SQL.Doc_Type = 'H' THEN	'START OF MONTH'
			WHEN IMINVTRX_SQL.Doc_Type = 'I' AND IMLSTRX_SQL.Source = 'I' THEN	'ISSUE OUT'
			WHEN IMINVTRX_SQL.Doc_Type = 'I' AND IMLSTRX_SQL.Source = 'O' THEN	'INVOICE'
			WHEN IMINVTRX_SQL.Doc_Type = 'I' AND IMLSTRX_SQL.Source = 'P' THEN	'ISSUE'
			WHEN IMINVTRX_SQL.Doc_Type = 'L' THEN	'LOT ADJUSTMENT'
			WHEN IMINVTRX_SQL.Doc_Type = 'P' THEN	'STOCK TAKE'
			WHEN IMINVTRX_SQL.Doc_Type = 'Q' THEN	'QUANTITY ADJUST'
			WHEN IMINVTRX_SQL.Doc_Type = 'R' AND IMINVTRX_SQL.Doc_Source = 'C' THEN	'RECEIVE'	---IMLSTRX_SQL.Source = 'C' THEN	'RECEIVE'
			WHEN IMINVTRX_SQL.Doc_Type = 'R' THEN	'RECEIVE'
			WHEN IMINVTRX_SQL.Doc_Type = 'T' AND IMLSTRX_SQL.Lev_No = 0	THEN	'TRANS - OUT'
			WHEN IMINVTRX_SQL.Doc_Type = 'T' AND IMLSTRX_SQL.Lev_No = 1	THEN	'TRANS - IN'
			WHEN IMINVTRX_SQL.Doc_Type = 'Z' THEN	'RECEIVED'
			ELSE 'UNKNOWN'
		END)													AS [TRANS]
		,IMLSTRX_SQL.Ser_Lot_No									AS [SER_LOT_NO]
		--=====================================================================================
		,(CASE
			WHEN IMLSTRX_SQL.Source = 'I'	THEN	'IM'
			WHEN IMLSTRX_SQL.Source = 'P'	THEN	'PO'
			WHEN IMLSTRX_SQL.Source = 'O'	THEN	'OE'
			WHEN IMLSTRX_SQL.Source = 'S'	THEN	'SF'
			WHEN IMLSTRX_SQL.Source = 'C'	THEN	'CC'
			ELSE '-Unkwn'
		END)													AS [SOURCE],
		IMLSTRX_SQL.Ord_No,
		IMLSTRX_SQL.Ctl_No,			IMINVTRX_SQL.Quantity,			IMLSTRX_SQL.Line_No,
		IMLSTRX_SQL.Lev_No,			IMLSTRX_SQL.Seq_No,				IMLSTRX_SQL.Ser_Lot_No,
		IMLSTRX_SQL.Trx_Dt,			IMLSTRX_SQL.Trx_Qty,			IMLSTRX_SQL.Item_No,
		IMINVTRX_SQL.Loc,			IMINVTRX_SQL.Doc_Dt,			
		(CASE
			WHEN IMINVTRX_SQL.Doc_Type = 'A' THEN	'ALLOCATION'
			WHEN IMINVTRX_SQL.Doc_Type = 'B' THEN	'BALANCE'
			WHEN IMINVTRX_SQL.Doc_Type = 'H' THEN	'START OF MONTH'
			WHEN IMINVTRX_SQL.Doc_Type = 'I' AND IMLSTRX_SQL.Source = 'I' THEN	'ISSUE OUT'
			WHEN IMINVTRX_SQL.Doc_Type = 'I' AND IMLSTRX_SQL.Source = 'O' THEN	'INVOICE'
			WHEN IMINVTRX_SQL.Doc_Type = 'I' AND IMLSTRX_SQL.Source = 'P' THEN	'ISSUE'
			WHEN IMINVTRX_SQL.Doc_Type = 'L' THEN	'LOT ADJUSTMENT'
			WHEN IMINVTRX_SQL.Doc_Type = 'P' THEN	'STOCK TAKE'
			WHEN IMINVTRX_SQL.Doc_Type = 'Q' THEN	'QUANTITY ADJUST'
			WHEN IMINVTRX_SQL.Doc_Type = 'R' AND IMLSTRX_SQL.Source = 'C' THEN	'RECEIVE'
			WHEN IMINVTRX_SQL.Doc_Type = 'R' THEN	'RECEIVE'
			WHEN IMINVTRX_SQL.Doc_Type = 'T' AND IMLSTRX_SQL.Lev_No = 0	THEN	'TRANS - OUT'
			WHEN IMINVTRX_SQL.Doc_Type = 'T' AND IMLSTRX_SQL.Lev_No = 0	THEN	'TRANS - IN'
			WHEN IMINVTRX_SQL.Doc_Type = 'Z' THEN	'Received'
			ELSE 'UNKNOWN'
		END) AS	Doc_Type,
		
		IMINVTRX_SQL.Doc_Ord_No,	IMINVTRX_SQL.Doc_Source,
		UPPER(IMINVTRX_SQL.User_Name),		IMLSTRX_SQL.Trx_Tm,				IMINVTRX_SQL.Comment
FROM IMLSTRX_SQL, IMINVTRX_SQL
WHERE IMLSTRX_SQL.Source = IMINVTRX_SQL.Source
AND IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No
AND IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No
AND IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No
AND IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No
AND IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No
AND (IMLSTRX_SQL.Ser_Lot_No LIKE Format(106501, '_________000000')	            --	strSPackNo = Format(intSpNo, "_________000000")
OR (
	IMLSTRX_SQL.Ser_Lot_No BETWEEN Format(106501, '000000') + '   000000'
    AND Format(106501, '000000') + '   999999' )
OR ( 
			IMLSTRX_SQL.Ser_Lot_No BETWEEN LTRIM(RTRIM(106501))+'000000'
            AND  LTRIM(RTRIM(106501))+'999999')) 
ORDER BY IMINVTRX_SQL.Loc,IMLSTRX_SQL.trx_dt,IMLSTRX_SQL.trx_tm

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
