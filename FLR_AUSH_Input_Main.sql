SELECT 
    AUSH,
    CAST(FORMAT(Month, 'yyyy-MM-dd')AS DATE) AS Month,
    [Executive Commentary],
    [Initiatives],
    'SP' AS GP_SP,               -- Adding the GP_SP column with "SP" values
    'AUSH' AS [VISN/AUSH],       -- Adding the VISN/AUSH column with "AUSH" values
    Attribute,                   
    Value,                       
    CASE 
        WHEN Attribute = 'Medical Services' THEN 'Medical Services'
        WHEN Attribute = 'Support and Compliance' THEN 'Support and Compliance'
        WHEN Attribute = 'Facilities' THEN 'Facilities'
        WHEN Attribute = 'Medical Community Care' THEN 'Medical Community Care'
        ELSE NULL 
    END AS Appropriation,        -- Adding the Appropriation column
    CASE 
        WHEN Attribute IN ('Medical Services', 
                           'Support and Compliance', 
                           'Facilities', 
                           'Medical Community Care') 
        THEN 1 
        ELSE 0 
    END AS [Surplus/Need_Total],  -- Adding the Surplus/Need_Total column
	CASE 
        WHEN Attribute IN ('Medical Services', 
                           'Support and Compliance', 
                           'Facilities') 
        THEN 1 
        ELSE 0 
    END AS [Surplus/Need_Direct],  -- Adding the Surplus/Need_Direct column
	CASE 
        WHEN Attribute LIKE 'Medical Community Care'
        THEN 1 
        ELSE 0 
    END AS [Surplus/Need_Community]  -- Adding the Surplus/Need_Community column
FROM 
    (SELECT 
        AUSH,
        [Month],
        [Executive Commentary],
        [Initiatives],
        [Surplus/Need - Total],
        [Surplus/Need - Medical Services],
        [Surplus/Need - Support and Compliance],
        [Surplus/Need - Facilities],
        [Surplus/Need - Medical Community Care]
    FROM [VHA104_Finance].[App].[AUSH_Input_Main]
    ) AS SourceTable
UNPIVOT (
    Value FOR Attribute IN ( 
        [Surplus/Need - Total], 
        [Surplus/Need - Medical Services], 
        [Surplus/Need - Support and Compliance], 
        [Surplus/Need - Facilities], 
        [Surplus/Need - Medical Community Care]
    )
) AS UnpivotedData;
