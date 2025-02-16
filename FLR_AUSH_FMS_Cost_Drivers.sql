WITH FinalData AS (
    SELECT
        [Parent Facility District],
        Direct_Community,
        [Fiscal Date],
        GP_SP,
        CASE
            WHEN Direct_Community = 'Community Care' THEN [FYTD Obligations]
            ELSE NULL
        END AS [Community Care],
        CASE
            WHEN [BOC Lvl2] LIKE '(1000-1099) Personnel Services'
                 AND Direct_Community = 'Direct Care' 
            THEN [FYTD Obligations]
            ELSE 0
        END AS [Personal Services],
        CASE
            WHEN Direct_Community = 'Direct Care'
                 AND [BOC Lvl3] LIKE '(2500-2599) Other Contractual Services' 
            THEN [FYTD Obligations]
            ELSE 0
        END AS [Contracts],
        -- New "All Other" column logic
        CASE
            WHEN Direct_Community = 'Direct Care'
                 AND ([BOC Lvl2] NOT LIKE '(1000-1099) Personnel Services' OR [BOC Lvl2] IS NULL)
                 AND ([BOC Lvl3] NOT LIKE '(2500-2599) Other Contractual Services' OR [BOC Lvl3] IS NULL)
            THEN [FYTD Obligations]
            ELSE NULL
        END AS [All Other]
    FROM [VHA104_Finance].[CDR].[FLR_Obligations]
    WHERE [Parent Facility District] LIKE '(V00)__%'
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
