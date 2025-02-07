SELECT 
    [Month], 
    [VISN], 
    [Commentary - Initiatives],
    [Commentary - Executive Level Commentary],
    Category, 
    Value / 1000 AS Value,  -- Divide by 1000
    -- DirectCommunity
    CASE 
        WHEN Category LIKE '%Community Care%' THEN 'Community Care'
        WHEN Category LIKE '%Community Care - TotalGP - Plan%' THEN ''
        ELSE 'Direct Care'
    END AS [Direct/Community],
    -- Appropriation
    CASE 
        WHEN Category LIKE '%Medical Services%' THEN 'Medical Services'
        WHEN Category LIKE '%SupportCompliance%' THEN 'Support and Compliance'
        WHEN Category LIKE '%Facilities%' THEN 'Facilities'
        WHEN Category LIKE '%Community Care%' THEN 'Medical Community Care'
        ELSE ''
    END AS Appropriation,
    -- GP_SP with a fixed value of 'GP'
    'GP' AS GP_SP,
    -- CostDriver
    CASE 
        WHEN Category LIKE '%Personal Services%' THEN 'Personal Services'
        WHEN Category LIKE '%Pharmacy (2631, 2636)%' THEN 'Pharmacy'
        WHEN Category LIKE '%Contracts%' THEN 'Contracts'
        WHEN Category LIKE '%Direct Care - All Other%' THEN 'Direct Care - All Other'
        WHEN Category LIKE '%Community Care - TotalGP - Plan%' THEN 'Community Care'
		WHEN Category LIKE '%Community Care - TotalGP - ObligationsYTD%' THEN 'Community Care'
		WHEN Category LIKE '%Community Care - TotalGP - ObligationsPYTD%' THEN 'Community Care' 
        WHEN Category LIKE '%CMOP%' THEN 'CMOP'
        WHEN Category LIKE '%Outpatient%' THEN 'Outpatient'
	    WHEN Category LIKE '%Inpatient%' THEN 'Inpatient'
	    WHEN Category LIKE '%Dental%' THEN 'Dental'
		WHEN Category LIKE '%Community Care - All Other%' THEN 'Community Care - All Other'

        ELSE ''
    END AS CostDriver,
    -- Collections/Reimbursables
    CASE 
        WHEN Category LIKE '%Collections%' THEN 'Collections'
        WHEN Category LIKE '%Reimbursables%' THEN 'Reimbursables'
        ELSE ''
    END AS CollectionsReimbursables,
    -- MCCF
    CASE 
        WHEN Category LIKE '%MCCF%' THEN 'MCCF'
        ELSE ''
    END AS MCCF,
    -- YTD_Allocated
    CASE 
        WHEN Category LIKE '%YTDAllocationsVERA%' THEN Value /1000
        ELSE NULL
    END AS [YTD Allocated],
    -- Obligations_YTD_Totals
    CASE 
        WHEN Category LIKE '%TotalGP - ObligationsYTD%' THEN Value /1000
        ELSE NULL
    END AS [Obligation YTD],
	-- Obligations_YTD_Cost_Drivers
    CASE 
        WHEN Category LIKE '%ObligationsYTD%' THEN Value /1000
		WHEN Category LIKE '%TotalGP - ObligationsYTD%' THEN Value /1000
        ELSE NULL
    END AS [Obligation YTD_Cost_Drivers],
	-- Obligations_PYTD
    CASE 
        WHEN Category LIKE '%ObligationsPYTD%' THEN Value /1000
        ELSE NULL
    END AS [Obligation PYTD],
	-- Plan
    CASE 
        WHEN Category LIKE '%(CMOP) - Plan%' THEN Value /1000
        WHEN Category LIKE '%Plan%' THEN Value /1000
        WHEN Category LIKE '%Community Care - TotalGP - Plan%' THEN Value /1000
        ELSE NULL  -- Otherwise, return NULL
    END AS [Plan],
    -- Surplus/Need
    CASE 
        WHEN Category LIKE '%CurrentGP - Medical Services%' 
          OR Category LIKE '%CurrentGP - SupportCompliance%' 
          OR Category LIKE '%CurrentGP - Facilities%' 
          OR Category LIKE '%Community Care - Surplus/Need%'
        THEN Value /1000
        ELSE NULL
    END AS [Surplus/Need],
	-- Projected
	CASE 
        WHEN Category LIKE '%Projection%' THEN Value / 1000
        ELSE NULL  -- Otherwise, return NULL
    END AS [Projection],
    -- Expected
	CASE 
        WHEN Category LIKE '%Expected%' THEN Value / 1000
        ELSE NULL  -- Otherwise, return NULL
    END AS [Expected],
	-- AmountYTD
	CASE 
        WHEN Category LIKE '%AmountYTD%' THEN Value / 1000
        ELSE NULL  -- Otherwise, return NULL
    END AS [Amount YTD],
	-- Medical Services
    CASE 
        WHEN Category LIKE '%Medical Services%' 
        THEN Value / 1000
        ELSE NULL
    END AS [Medical Services],
	-- Support & Compliance
	CASE 
        WHEN Category LIKE '%CurrentGP - SupportCompliance%' 
        THEN Value / 1000
        ELSE NULL
    END AS [Support & Compliance],
	-- Facilities
	CASE 
        WHEN Category LIKE '%Facilities%' 
        THEN Value / 1000
        ELSE NULL
    END AS [Facilities],
	-- Community Care
		CASE 
        WHEN Category LIKE '%Community Care - Surplus/Need%' 
        THEN Value / 1000
        ELSE NULL
    END AS [Medical Community Care]
FROM
    (SELECT
        [Month],
        [VISN],
        [Commentary - Initiatives],
        [Commentary - Executive Level Commentary],
        -- Original columns
        [Direct Care - YTDAllocationsVERA],
        [Direct Care - Collections - Projection],
        [Direct Care - Collections - Expected],
        [Direct Care - Collections - AmountYTD],
        [Direct Care - Reimbursables - Projection],
        [Direct Care - Reimbursables - Expected],
        [Direct Care - Reimbursables - AmountYTD],
        [Direct Care - Personal Services - Plan],
        [Direct Care - Personal Services - ObligationsYTD],
        [Direct Care - Personal Services - GrowthYTD],
        [Direct Care - Pharmacy (2631, 2636) - Plan],
        [Direct Care - Pharmacy (2631, 2636) - ObligationsYTD],
        [Direct Care - Pharmacy (2631, 2636) - GrowthYTD],
        [Direct Care - Pharmacy (CMOP) - Plan],
        [Direct Care - Pharmacy (CMOP) - ObligationsYTD],
        [Direct Care - Contracts - Plan],
        [Direct Care - Contracts - ObligationsYTD],
        [Direct Care - Contracts - GrowthYTD],
        [Direct Care - All Other - Plan],
        [Direct Care - TotalGP - ObligationsYTD],
        [Direct Care - TotalGP - GrowthYTD],
        [Community Care - YTDAllocationsVERA],
        [Community Care - MCCF - Projection],
        [Community Care - MCCF - Expected],
        [Community Care - MCCF - AmountYTD],
        [Community Care - TotalGP - Plan],
        [Community Care - TotalGP - ObligationsYTD],
        [Community Care - Outpatient - ObligationsYTD],
        [Community Care - Inpatient - ObligationsYTD],
        [Community Care - Dental - ObligationsYTD],
        [Total Surplus/Need - CurrentGP - SupportCompliance],
        [Total Surplus/Need - CurrentGP - Medical Services],
        [Total Surplus/Need - CurrentGP - Facilities],
        [Total Surplus/Need - CurrentSP - Medical Services],
        [Total Surplus/Need - CurrentSP - SupportCompliance],
        [Total Surplus/Need - CurrentSP - Facilities],
        [Direct Care - All Other - ObligationsYTD],
        [Community Care - TotalGP - GrowthYTD],
        [Direct Care - Pharmacy (CMOP) - GrowthYTD],
        [Direct Care - All Other - GrowthYTD],
        [Community Care - Outpatient - ObligationsPYTD],
        [Community Care - Inpatient - ObligationsPYTD],
        [Community Care - Dental - ObligationsPYTD],
        [Community Care - All Other - ObligationsPYTD],
        [Community Care - All Other - ObligationsYTD],
		--- Calculted columns
        CAST(ISNULL([Community Care - YTDAllocationsVERA], 0) +  
        ISNULL([Community Care - MCCF - Projection], 0) -  
        ISNULL([Community Care - TotalGP - Plan], 0) AS DECIMAL(18,6)) AS [Community Care - Surplus/Need],

		CAST(ISNULL([Direct Care - Personal Services - ObligationsYTD],0) / (ISNULL([Direct Care - Personal Services - GrowthYTD], 0)+ 1) AS DECIMAL(18,6))
        AS [Direct Care - Personal Services - ObligationsPYTD],

		CAST(ISNULL([Direct Care - Pharmacy (CMOP) - ObligationsYTD],0) / (ISNULL([Direct Care - Pharmacy (CMOP) - GrowthYTD], 0) + 1) AS DECIMAL(18,6))
        AS [Direct Care - CMOP - ObligationsPYTD],

		CAST(ISNULL([Direct Care - Contracts - ObligationsYTD],0) / (ISNULL([Direct Care - Contracts - GrowthYTD], 0) + 1) AS DECIMAL(18,6))
        AS [Direct Care - Contracts - ObligationsPYTD],

		CAST(ISNULL([Direct Care - All Other - ObligationsYTD],0) / (ISNULL([Direct Care - All Other - GrowthYTD], 0) + 1) AS DECIMAL(18,6))
        AS [Direct Care - All Other - ObligationsPYTD],

		CAST(ISNULL([Direct Care - Pharmacy (2631, 2636) - ObligationsYTD],0) / (ISNULL([Direct Care - Pharmacy (2631, 2636) - GrowthYTD], 0) + 1) AS DECIMAL(18,6))
        AS [Direct Care - Pharmacy (2631, 2636) - ObligationsPYTD],

		CAST(
        ISNULL([Community Care - Outpatient - ObligationsPYTD], 0) +
        ISNULL([Community Care - Inpatient - ObligationsPYTD], 0) +
        ISNULL([Community Care - Dental - ObligationsPYTD], 0) +
        ISNULL([Community Care - All Other - ObligationsPYTD], 0)
    AS DECIMAL(18,6)) AS [Community Care - TotalGP - ObligationsPYTD]

    FROM [VHA104_Finance].[App].[VISN_Input_Main]) AS SourceTable
UNPIVOT
    (Value FOR Category IN (
        [Direct Care - YTDAllocationsVERA],
        [Direct Care - Collections - Projection],
        [Direct Care - Collections - Expected],
        [Direct Care - Collections - AmountYTD],
        [Direct Care - Reimbursables - Projection],
        [Direct Care - Reimbursables - Expected],
        [Direct Care - Reimbursables - AmountYTD],
        [Direct Care - Personal Services - Plan],
        [Direct Care - Personal Services - ObligationsYTD],
        [Direct Care - Personal Services - GrowthYTD],
        [Direct Care - Pharmacy (2631, 2636) - Plan],
        [Direct Care - Pharmacy (2631, 2636) - ObligationsYTD],
        [Direct Care - Pharmacy (2631, 2636) - GrowthYTD],
        [Direct Care - Pharmacy (CMOP) - Plan],
        [Direct Care - Pharmacy (CMOP) - ObligationsYTD],
        [Direct Care - Contracts - Plan],
        [Direct Care - Contracts - ObligationsYTD],
        [Direct Care - Contracts - GrowthYTD],
        [Direct Care - All Other - Plan],
        [Direct Care - TotalGP - ObligationsYTD],
        [Direct Care - TotalGP - GrowthYTD],
        [Community Care - YTDAllocationsVERA],
        [Community Care - MCCF - Projection],
        [Community Care - MCCF - Expected],
        [Community Care - MCCF - AmountYTD],
        [Community Care - TotalGP - Plan],
        [Community Care - TotalGP - ObligationsYTD],
        [Community Care - Outpatient - ObligationsYTD],
        [Community Care - Inpatient - ObligationsYTD],
        [Community Care - Dental - ObligationsYTD],
        [Total Surplus/Need - CurrentGP - SupportCompliance],
        [Total Surplus/Need - CurrentGP - Medical Services],
        [Total Surplus/Need - CurrentGP - Facilities],
        [Total Surplus/Need - CurrentSP - Medical Services],
        [Total Surplus/Need - CurrentSP - SupportCompliance],
        [Total Surplus/Need - CurrentSP - Facilities],
        [Direct Care - All Other - ObligationsYTD],
        [Community Care - TotalGP - GrowthYTD],
        [Direct Care - Pharmacy (CMOP) - GrowthYTD],
        [Direct Care - All Other - GrowthYTD],
        [Community Care - Outpatient - ObligationsPYTD],
        [Community Care - Inpatient - ObligationsPYTD],
        [Community Care - Dental - ObligationsPYTD],
        [Community Care - All Other - ObligationsPYTD],
        [Community Care - All Other - ObligationsYTD],
		-- Include the new calculated columns
        [Community Care - Surplus/Need],
		[Direct Care - Personal Services - ObligationsPYTD],
		[Direct Care - CMOP - ObligationsPYTD],
		[Direct Care - Contracts - ObligationsPYTD],
		[Direct Care - All Other - ObligationsPYTD],
		[Direct Care - Pharmacy (2631, 2636) - ObligationsPYTD],
		[Community Care - TotalGP - ObligationsPYTD]
    )) AS UnpivotedTable;
