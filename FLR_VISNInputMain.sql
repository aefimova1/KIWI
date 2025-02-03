SELECT 
    [Month], 
    [VISN], 
    [Commentary - Initiatives],
    [Commentary - Executive Level Commentary],
    Category, 
    Value / 1000 AS Value,  -- Divide by 1000
    -- DirectCommunity
    CASE 
        WHEN Category LIKE '%Total Surplus/Need - CurrentGP - Community Care%' THEN 'Community'
        WHEN Category LIKE '%Community Care - TotalGP - Plan%' THEN ''
        ELSE 'Direct Care'
    END AS DirectCommunity,
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
        WHEN Category LIKE '%All Other%' THEN 'All Other'
        WHEN Category LIKE '%Community Care - TotalGP - Plan%' THEN 'Community Care'
        WHEN Category LIKE '%CMOP%' THEN 'CMOP'
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
        WHEN Category LIKE '%YTDAllocationsVERA%' THEN Value
        ELSE NULL
    END AS YTD_Allocated,
    -- Obligations_YTD
    CASE 
        WHEN Category LIKE '%ObligationsYTD%' THEN Value
        ELSE NULL
    END AS Obligations_YTD,
	-- Plan
    CASE 
        WHEN Category LIKE '%CMOP%' THEN NULL
        WHEN Category LIKE '%Plan%' THEN Value
        WHEN Category LIKE '%Community Care%' THEN Value
        ELSE NULL  -- Otherwise, return NULL
    END AS [Plan],
    -- Surplus/Need
    CASE 
        WHEN Category LIKE '%Medical Services%' 
          OR Category LIKE '%SupportCompliance%' 
          OR Category LIKE '%Facilities%' 
          OR Category LIKE '%Total Surplus/Need - CurrentGP - Community Care%' 
        THEN Value
        ELSE NULL
    END AS Surplus_Need,
	-- Medical Services
    CASE 
        WHEN Category LIKE '%Medical Services%' 
        THEN Value
        ELSE NULL
    END AS [Medical Services],
	-- Support & Compliance
	CASE 
        WHEN Category LIKE '%SupportCompliance%' 
        THEN Value
        ELSE NULL
    END AS [Support & Compliance],
	-- Facilities
	CASE 
        WHEN Category LIKE '%Facilities%' 
        THEN Value
        ELSE NULL
    END AS [Facilities],
	-- Community Care
		CASE 
        WHEN Category LIKE '%Community Care%' 
        THEN Value
        ELSE NULL
    END AS [Medical Community Care]
FROM 
    (SELECT 
        [Month], 
        [VISN], 
        [Commentary - Initiatives],
        [Commentary - Executive Level Commentary],
        -- All columns that need to be unpivoted
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
        [Community Care - All Other - ObligationsYTD]
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
        [Total Surplus/Need - CurrentSP - Facilities]
    )) AS UnpivotedTable;
