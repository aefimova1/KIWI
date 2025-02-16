USE [VHA104_Finance]
GO
/****** Object:  StoredProcedure [App].[FLR_SP_Fund_Cost_Drivers]    Script Date: 1/25/2025 3:28:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Efimova,Anna>
-- Create date: <01/18/2025>
-- Updated date: <01/25/2025>
-- Description:	<SP Fund Cost Drivers>
-- =============================================
ALTER PROCEDURE [App].[FLR_SP_Fund_Cost_Drivers]


AS
BEGIN
WITH FinalData AS (
    SELECT
        [Parent Facility District],
        Direct_Community,
              GP_SP,
        [Fiscal Date],
        CASE
            WHEN Is_Prosthetics = 0
                 AND Is_Trainees = 0
                 AND Is_Homeless_Veterans = 0 
                              AND Is_Transplants = 0 
                              AND Is_Suicide_Prevention = 0 
                              AND Is_Caregiver = 0 
                              AND Is_Station_Level = 0 
                              AND Is_Rural_Health = 0 
                              AND Is_Activations = 0 
                              AND Is_NRM = 0 
                              AND Is_State_Home = 0 
                              THEN [FYTD Obligations]
            ELSE NULL
        END AS [Other SP],
        CASE
            WHEN Is_Prosthetics = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Prosthetics,
        CASE
            WHEN Is_Trainees = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Trainees,
        CASE
            WHEN Is_Homeless_Veterans = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [Homeless Veterans Prog.],
              CASE
            WHEN Is_Transplants = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Transplants,
              CASE
            WHEN Is_Suicide_Prevention = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [Suicide Prevention],
              CASE
            WHEN Is_Caregiver = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Caregiver,
              CASE
            WHEN Is_Station_Level = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [Station Level SP],
              CASE
            WHEN Is_Rural_Health = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [Rural Health Initiatives],
              CASE
            WHEN Is_Activations = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS Activations,
              CASE
            WHEN Is_NRM = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS NRM,
              CASE
            WHEN Is_State_Home = 1 THEN [FYTD Obligations]
            ELSE NULL
        END AS [State Home]
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
        Value AS [FYTD Obligations],
        Value
    FROM FinalData
    UNPIVOT (
        Value FOR Category IN ([Other SP], [Activations], [Caregiver], [Homeless Veterans Prog.], [NRM],[Prosthetics], [Rural Health Initiatives], [State Home],[Station Level SP], [Suicide Prevention], [Trainees], [Transplants])
    ) AS UnpivotedData
) AS GroupedData
GROUP BY
    [Parent Facility District],
    Direct_Community,
       GP_SP,
    [Fiscal Date],
    [Cost Driver];

END
