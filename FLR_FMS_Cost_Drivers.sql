USE [VHA104_Finance]
GO
/****** Object:  StoredProcedure [App].[FLR_FMS_Cost_Drivers]    Script Date: 2/11/2025 8:33:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Efimova,Anna>
-- Create date: <12/26/2024>
-- Updated date: <01/25/2025>
-- Description:	<Cost Driver data for FLR>
-- =============================================
ALTER PROCEDURE [App].[FLR_FMS_Cost_Drivers]

AS
BEGIN
WITH FinalData AS (
    SELECT
        [Parent Facility District],
        Direct_Community,
		GP_SP,
        [Fiscal Date],
        CASE
            WHEN Direct_Community = 'Direct Care'
                 AND Is_Personal_Services = 0
                 AND Is_Contracts = 0
                 AND Is_Pharmacy = 0 THEN [FYTD Obligations]
            ELSE NULL
        END AS [All Other],
        CASE
            WHEN Direct_Community = 'Community Care' THEN [FYTD Obligations]
            ELSE NULL
        END AS [Community Care],
        CASE
            WHEN Is_Personal_Services = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [Personal Services],
        CASE
            WHEN Is_Pharmacy = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Pharmacy,
        CASE
            WHEN Is_CMOP = 1 THEN [FYTD Expenditures]
            ELSE NULL
        END AS CMOP,
        CASE
            WHEN Is_Contracts = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Contracts
    FROM [VHA104_Finance].[CDR].[FLR_Obligations]
    WHERE GP_SP = 'GP'
)
SELECT 
    [Parent Facility District],
    Direct_Community,
	GP_SP,
    [Fiscal Date],
    [Cost Driver],
    SUM([FYTD Obligations]) AS [FYTD Obligations],
    SUM(CASE WHEN [Cost Driver] = 'CMOP' THEN [Value] ELSE 0 END) AS [FYTD Expenditures]
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
        Value FOR Category IN ([All Other], [Community Care], [Personal Services], [Pharmacy], [Contracts], [CMOP])
    ) AS UnpivotedData
) AS GroupedData
GROUP BY
    [Parent Facility District],
    Direct_Community,
	GP_SP,
    [Fiscal Date],
    [Cost Driver];

END
