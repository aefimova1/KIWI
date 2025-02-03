SELECT
    [Month],
    [VISN],
    [Category] AS CostDriver,
    [Appropriation],
    [YTD Allocated]/1000 AS [YTD Allocated],
    [Obligation YTD]/1000 AS [Obligation YTD],
    [Plan]/1000 AS [Plan],
    
    -- GP_SP column with only value 'SP'
    'SP' AS GP_SP,
    
    -- Direct/Community column based on Appropriation
    CASE 
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN 'Community Care'
        ELSE 'Direct Care'
    END AS [Direct/Community],   
    
    -- Surplus/Need column using the new Value column
    CASE 
        WHEN [Appropriation] LIKE '%Medical Services%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        WHEN [Appropriation] LIKE '%Support and Compliance%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        WHEN [Appropriation] LIKE '%Facilities%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        ELSE NULL
    END AS [Surplus/Need]
FROM 
    [VHA104_Finance].[App].[VISN_Input_SP];
