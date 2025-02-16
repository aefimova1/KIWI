SELECT 
    AUSH, 
    CAST(FORMAT(Month, 'yyyy-MM-dd')AS DATE) AS Month, 
    CoreType, 
	'SP' AS GP_SP,               -- Adding the GP_SP column with "SP" values
    'AUSH' AS [VISN/AUSH],       -- Adding the VISN/AUSH column with "AUSH" values
    Attribute, 
    Value,
	CASE 
        WHEN Attribute = 'SurplusNeedMedicalServices' THEN 'Medical Services'
        WHEN Attribute = 'SurplusNeedSupportAndCompliance' THEN 'Support and Compliance'
        WHEN Attribute = 'SurplusNeedFacilities' THEN 'Facilities'
        WHEN Attribute = 'SurplusNeedMedicalCommunityCare' THEN 'Medical Community Care'
        ELSE NULL 
    END AS Appropriation,        -- Adding the Appropriation column
    CASE 
        WHEN Attribute = 'SurplusNeedTotal'THEN 1 ELSE 0 
    END AS [Surplus/Need_Total],  -- Adding the Surplus/Need_Total column
	CASE 
        WHEN Attribute IN ('SurplusNeedMedicalServices', 
                           'SurplusNeedSupportAndCompliance', 
                           'SurplusNeedFacilitiesa') 
        THEN 1 
        ELSE 0 
    END AS [Surplus/Need_Direct],  -- Adding the Surplus/Need_Direct column
	CASE 
        WHEN Attribute LIKE 'SurplusNeedMedicalCommunityCare'
        THEN 1 
        ELSE 0 
    END AS [Surplus/Need_Community],  -- Adding the Surplus/Need_Community column
	-- Medical Survices Surplus/Need
	  CASE 
        WHEN Attribute LIKE 'SurplusNeedMedicalServices' THEN Value
        ELSE NULL
    END AS [Medical Services],

		-- Support and Compliance Surplus/Need
	  CASE 
         WHEN Attribute LIKE 'SurplusNeedSupportAndCompliance' THEN Value
        ELSE NULL
    END AS [Support & Compliance],

	-- Facilities Surplus/Need
	  CASE 
        WHEN Attribute LIKE 'SurplusNeedFacilities' THEN Value
        ELSE NULL
    END AS [Facilities],

	-- Medical Community Care Surplus/Need
	  CASE 
        WHEN Attribute LIKE 'SurplusNeedMedicalCommunityCare' THEN Value
        ELSE NULL
    END AS [Medical Community Care]
FROM 
    (  
        SELECT  
            AUSH,  
            Month,  
            CoreType,  
            SurplusNeedTotal,  
            SurplusNeedMedicalServices,  
            SurplusNeedSupportAndCompliance,  
            SurplusNeedFacilities,  
            SurplusNeedMedicalCommunityCare  
        FROM [VHA104_Finance].[App].[AUSH_Inpits_Surplus/Need_by_Appropriation]  
    ) AS SourceTable
UNPIVOT  
    (  
        Value FOR Attribute IN  
        (SurplusNeedTotal,  
         SurplusNeedMedicalServices,  
         SurplusNeedSupportAndCompliance,  
         SurplusNeedFacilities,  
         SurplusNeedMedicalCommunityCare)  
    ) AS UnpivotedData;
