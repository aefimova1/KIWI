SELECT
    CAST(FORMAT(Month, 'yyyy-MM-dd')AS DATE) AS Month,
    [VISN],
    [Category] AS CostDriver,
    [Appropriation],
    [YTD Allocated],
    [Obligation YTD],
    [Plan],
    
    -- GP_SP column with only value 'SP'
    'SP' AS GP_SP,

	-- Core/Non-Core column with only value 'NON CORE'
    'NON CORE' AS [Core/Non-Core],

	-- VISN/AUSH column with only value 'VISN'
    'VISN' AS [VISN/AUSH],
    
    -- Direct/Community column based on Appropriation
    CASE 
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN 'Community Care'
        ELSE 'Direct Care'
    END AS [Direct/Community], 
	
	    -- Surplus/Need_Total column using the new Value column
    CASE 
        WHEN [Appropriation] LIKE '%Medical Services%' THEN 1
        WHEN [Appropriation] LIKE '%Support and Compliance%' THEN 1
        WHEN [Appropriation] LIKE '%Facilities%' THEN 1
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN 1
        ELSE 0
    END AS [Surplus/Need_Total],

	    -- Surplus/Need_Direct column using the new Value column
    CASE 
        WHEN [Appropriation] LIKE '%Medical Services%' THEN 1
        WHEN [Appropriation] LIKE '%Support and Compliance%' THEN 1
        WHEN [Appropriation] LIKE '%Facilities%' THEN 1
        ELSE 0
    END AS [Surplus/Need_Direct],

		-- Surplus/Need_Community column using the new Value column
    CASE 
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN 1
        ELSE 0
    END AS [Surplus/Need_Community],
 
    -- Surplus/Need column using the new Value column
    CASE 
        WHEN [Appropriation] LIKE '%Medical Services%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        WHEN [Appropriation] LIKE '%Support and Compliance%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        WHEN [Appropriation] LIKE '%Facilities%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        ELSE NULL
    END AS [Surplus/Need],

	-- Medical Survices Surplus/Need
	  CASE 
        WHEN [Appropriation] LIKE '%Medical Services%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        ELSE NULL
    END AS [Medical Services],

		-- Support and Compliance Surplus/Need
	  CASE 
         WHEN [Appropriation] LIKE '%Support and Compliance%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        ELSE NULL
    END AS [Support & Compliance],

	-- Facilities Surplus/Need
	  CASE 
        WHEN [Appropriation] LIKE '%Facilities%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        ELSE NULL
    END AS [Facilities],

	-- Medical Community Care Surplus/Need
	  CASE 
        WHEN [Appropriation] LIKE '%Medical Community Care%' THEN ISNULL([YTD Allocated], 0) - ISNULL([Plan], 0)
        ELSE NULL
    END AS [Medical Community Care]

FROM 
    [VHA104_Finance].[App].[VISN_Input_SP]
	WHERE [Appropriation] NOT LIKE 'Parent';
