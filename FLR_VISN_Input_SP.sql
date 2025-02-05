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
        WHEN [Appropriation] LIKE '%Medical Services%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        WHEN [Appropriation] LIKE '%Support and Compliance%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        WHEN [Appropriation] LIKE '%Facilities%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        ELSE NULL
    END AS [Surplus/Need],

	-- Medical Survices Surplus/Need
	  CASE 
        WHEN [Appropriation] LIKE '%Medical Services%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        ELSE NULL
    END AS [Medical Services],

		-- Support and Compliance Surplus/Need
	  CASE 
         WHEN [Appropriation] LIKE '%Support and Compliance%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        ELSE NULL
    END AS [Support & Compliance],

	-- Facilities Surplus/Need
	  CASE 
        WHEN [Appropriation] LIKE '%Facilities%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        ELSE NULL
    END AS [Facilities],

	-- Medical Community Care Surplus/Need
	  CASE 
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN ISNULL([YTD Allocated]/1000, 0) - ISNULL([Plan]/1000, 0)
        ELSE NULL
    END AS [Medical Community Care]

FROM 
    [VHA104_Finance].[App].[VISN_Input_SP]
	WHERE [Appropriation] NOT LIKE 'Parent';
