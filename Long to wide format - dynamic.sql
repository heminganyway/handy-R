
SELECT TOP 100 * FROM _dizhang.mkt.allReasons


SELECT *
      ,'CASE WHEN CampaignReasonID = ' + CAST(CampaignReasonID AS VARCHAR) + ' THEN 1 ELSE 0 END AS R' + CAST(CampaignReasonID AS VARCHAR) field
INTO #wide_reason_fields
FROM
(
SELECT DISTINCT CampaignReasonID 
FROM _dizhang.mkt.allReasons
) TEMP



SELECT * FROM #wide_reason_fields


declare @cols varchar(MAX)
declare @query varchar(MAX)
select @cols = STUFF((SELECT ',' + FIELD  --variable from row to column
                    from #wide_reason_fields

            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
select @cols


SET @query = 'SELECT CustomerID, Category, ' + @cols + '
              INTO ##wide_reason
			  FROM _dizhang.mkt.allReasons
		      GROUP BY CustomerID, Category, CampaignReasonID
			  ORDER BY CustomerID
'

EXECUTE(@query)


SELECT TOP 100 * FROM ##wide_reason


-----------------------------------------------

DROP TABLE #wide_reason_condensed_fields
SELECT COLUMN_NAME
      ,'MAX(' + COLUMN_NAME + ') AS ' + COLUMN_NAME FIELD
INTO #wide_reason_condensed_fields
FROM tempdb.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '##wide_reason'
AND COLUMN_NAME LIKE 'R[0-9]%'


select top 100 * from #wide_reason_condensed_fields


declare @cols2 varchar(MAX)
declare @query2 varchar(MAX)
select @cols2 = STUFF((SELECT ',' + FIELD  --variable from row to column
                    from #wide_reason_condensed_fields

            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')
select @cols2



SET @query2 = 'SELECT CustomerID, Category, ' + @cols2 + '
              INTO ##wide_reason_condensed
              FROM _HChen..MR_cust_reason_profile
              GROUP BY CustomerID, Category
'

EXECUTE(@query2)



SELECT TOP 100 * FROM ##wide_reason_condensed
