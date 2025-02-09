USE [VHA104_Finance]
GO
/****** Object:  StoredProcedure [App].[FLR_AUSH_FMS_Cost_Drivers]    Script Date: 1/25/2025 3:31:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Efimova,Anna>
-- Create date: <01/07/2025>
-- Description:	<Obligations AUSH Cost Drivers>
-- =============================================
ALTER PROCEDURE [App].[FLR_AUSH_FMS_Cost_Drivers]

AS
BEGIN

    WITH FinalData AS (
    SELECT
        [Parent Facility District],
        Direct_Community,
        [Fiscal Date],
        GP_SP,
        CASE
            WHEN Direct_Community = 'Direct'
                 AND Is_Personal_Services = 0
                 AND Is_Contracts = 0
            THEN [FYTD Obligations]
            ELSE NULL
        END AS [All Other],
        CASE
            WHEN Direct_Community = 'Community' THEN [FYTD Obligations]
            ELSE NULL
        END AS [Community Care],
        CASE
            WHEN Is_Personal_Services = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [Personal Services],
        CASE
            WHEN Is_Contracts = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Contracts
    FROM [VHA104_Finance].[CDR].[FLR_Obligations]
)
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
        Value AS [FYTD Obligations]
    FROM FinalData
    UNPIVOT (
        Value FOR Category IN ([All Other], [Community Care], [Personal Services], [Contracts])
    ) AS UnpivotedData
) AS GroupedData
GROUP BY
    [Parent Facility District],
    Direct_Community,
    GP_SP,
    [Fiscal Date],
    [Cost Driver];

END
