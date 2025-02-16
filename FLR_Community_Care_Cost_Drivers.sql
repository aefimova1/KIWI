USE [VHA104_Finance]
GO
/****** Object:  StoredProcedure [App].[FLR_Community_Care_Cost_Drivers]    Script Date: 2/11/2025 8:32:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <01/18/2025>
-- Updated date: <01/25/2025>
-- Description:	<Community care cost drivers>
-- =============================================
ALTER PROCEDURE [App].[FLR_Community_Care_Cost_Drivers]


AS
BEGIN
WITH FinalData AS (
    SELECT
        [Parent Facility District],
        Direct_Community,
              GP_SP,
        [Fiscal Date],
        CASE
            WHEN Is_Outpatient = 0
                 AND Is_Inpatient = 0
                 AND Is_Dental = 0 THEN [FYTD Obligations]
            ELSE NULL
        END AS [All Other],
        CASE
            WHEN Direct_Community = 'Community Care' THEN [FYTD Obligations]
            ELSE NULL
        END AS [Community Care],
        CASE
            WHEN Is_Outpatient = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Outpatient,
        CASE
            WHEN Is_Inpatient = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Inpatient,
        CASE
            WHEN Is_Dental = 1 THEN [FYTD Expenditures]
            ELSE NULL
        END AS Dental
    FROM [VHA104_Finance].[CDR].[FLR_Obligations]
    WHERE GP_SP = 'GP'
         AND Direct_Community = 'Community Care')
SELECT 
    [Parent Facility District],
    Direct_Community,
       GP_SP,
    [Fiscal Date],
    [Cost Driver],
    SUM([FYTD Obligations]) AS [FYTD Obligations]
FROM (
    SELECT 
        [Parent Facility District],
        Direct_Community,
              GP_SP,
        [Fiscal Date],
        Category AS [Cost Driver],
        Value AS [FYTD Obligations],
        Value
    FROM FinalData
    UNPIVOT (
        Value FOR Category IN ([All Other], [Community Care], [Outpatient], [Inpatient], [Dental])
    ) AS UnpivotedData
) AS GroupedData
GROUP BY
    [Parent Facility District],
    Direct_Community,
       GP_SP,
    [Fiscal Date],
    [Cost Driver];

END
