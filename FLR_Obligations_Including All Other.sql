WITH MaxYearCTE AS (
    SELECT MAX(YEAR(
        DATEFROMPARTS(
            CASE
                WHEN [FMO] >= 10 THEN CAST(SUBSTRING([FY], 3, 2) AS INT) + 2000
                ELSE CAST(SUBSTRING([FY], 3, 2) AS INT) + 2000
            END,
            [FMO],
            1
        )
    )) AS MaxYear
    FROM [VHA104_Finance].[CDR].[FMS830887]
),
CleanedDistinctOffices AS (
    SELECT DISTINCT 
        [887 Stn], 
        [Standard Data Rollup Group]
    FROM CDR.[Stn Xwalk]
    WHERE [887 Stn] IS NOT NULL AND [887 Stn] <> ''
),
FMSData AS (
    SELECT
        [Parent Facility District],
        [VISN District],
        [Sta6a ID],
        [FY],
        [FMO],
		[Budget Fiscal Year],
        [VACCID 6],
        [VACC Lvl1],
        [VA Cost Ctr_2],
        [FUNDID],
        [BOC Lvl1],
        [BOC Lvl2],
        [BOC Lvl3],
        [BOCID],
        [Progcode],
        [Sub Prog],
        [Org Code],
        [Act Code],
        [Transaction Code],
        [FYTD Obligations],
        [LFYTD Obligations],
        [FYTD Expenditures],
        [LFYTD Expenditures],
        [Monthly Obligations],
        [Monthly Expenditures],
        CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) AS [Account Classification Code],
        CASE 
    WHEN (
        -- Fund conditions
        (
            [FUNDID] LIKE '0152%' AND [FUNDID] NOT LIKE '0152RH%'
        )
        OR (
            [FUNDID] LIKE '0160%' AND [FUNDID] NOT LIKE '0160RH%'
        )
        OR (
            [FUNDID] LIKE '0162%' AND [FUNDID] NOT LIKE '0162RH%'
        )
        OR (
            [FUNDID] LIKE '1126%' AND [FUNDID] NOT LIKE '1126C5%'
        )
    )
    AND [Progcode] IN ('01', '02', '03', '04', '99', 'CS', 'ES', 'IP', 'LG') 
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4331S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4461S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4553S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4759S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4764S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4765S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG4766S__'
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'LG5082S__'
    
    OR (
        [FUNDID] LIKE '0140%'
        OR [FUNDID] LIKE '1126C5%'
    )
    AND CONCAT([Progcode], [Sub Prog], [Org Code], [Act Code]) NOT LIKE 'SPW0FP7%'
    THEN 'GP'
    
    ELSE 'SP'
END AS GP_SP,
        CASE
            WHEN [FUNDID] LIKE '0140%' OR [FUNDID] LIKE '1126C5%' THEN 'Community Care'
            WHEN [FUNDID] LIKE '0152%' OR
                 [FUNDID] LIKE '0160%' OR
                 [FUNDID] LIKE '0162%' OR
                 [FUNDID] LIKE '1126M5%' OR
				 [FUNDID] LIKE '1126MS%' OR
				 [FUNDID] LIKE '1126S5%' OR
				 [FUNDID] LIKE '1126SC%'
				 THEN 'Direct Care'
            ELSE NULL
        END AS Direct_Community,
        DATEFROMPARTS(
            CASE
                WHEN [FMO] >= 10 THEN CAST(SUBSTRING([FY], 3, 2) AS INT) + 2000
                ELSE CAST(SUBSTRING([FY], 3, 2) AS INT) + 2000
            END,
            [FMO],
            1
        ) AS [Fiscal Date]
    FROM [VHA104_Finance].[CDR].[FMS830887]
    WHERE
        [VA Cost Ctr_2] IN ('80', '82', '83', '84', '85', '86')
        AND ([FUNDID] LIKE '0140__' OR [FUNDID] LIKE '0152__' OR [FUNDID] LIKE '0160__' OR [FUNDID] LIKE '0162__' OR [FUNDID] LIKE '1126__')
        AND [FUNDID] NOT LIKE '1126R5%'
        AND [FUNDID] NOT LIKE '1126RD%'
        AND [Sta6a ID] NOT IN ('742', '777', '962')
        AND [BOC Lvl1] LIKE 'Personal Services & All Other'
),
CategorizedData AS (
    SELECT 
    fms.*,
	ST.[Standard Data Rollup Group],
    CASE
        WHEN [BOC Lvl2] LIKE '(1000-1099) Personnel Services'
             AND GP_SP = 'GP'
             AND Direct_Community = 'Direct Care' THEN 1
        ELSE 0
    END AS Is_Personal_Services,
	CASE
        WHEN GP_SP = 'GP'
             AND Direct_Community = 'Direct Care'
             AND TRY_CAST(BOCID AS INT) IN (2631, 2636) THEN 1
        ELSE 0
    END AS Is_Pharmacy,
    CASE
        WHEN GP_SP = 'GP'
             AND Direct_Community = 'Direct Care'
             AND [VACCID 6] LIKE '8224__%'
             AND [Transaction Code] = 'SE'
             AND TRY_CAST(BOCID AS INT) = 2572 THEN 1
        ELSE 0
    END AS Is_CMOP,
    CASE
        WHEN GP_SP = 'GP'
             AND Direct_Community = 'Direct Care'
             AND [BOC Lvl3] LIKE '(2500-2599) Other Contractual Services' THEN 1
        ELSE 0
    END AS Is_Contracts,
    CASE
        WHEN GP_SP = 'GP'
             AND Direct_Community = 'Community Care'
             AND [Account Classification Code] LIKE 'SPW0APG__%' THEN 1
        ELSE 0
    END AS Is_Outpatient,
    CASE
        WHEN GP_SP = 'GP'
             AND Direct_Community = 'Community Care'
             AND [Account Classification Code] LIKE 'SPW0APF__%' THEN 1
        ELSE 0
    END AS Is_Inpatient,
    CASE
        WHEN GP_SP = 'GP'
             AND Direct_Community = 'Community Care'
             AND [Account Classification Code] LIKE 'SPW0APR__%' THEN 1
        ELSE 0
    END AS Is_Dental,
    CASE
        WHEN (FUNDID LIKE '0152__%' OR FUNDID LIKE '0160__%' OR FUNDID LIKE '0162__%' OR FUNDID LIKE '1126__%')
             AND NOT (FUNDID LIKE '0162RH%' OR FUNDID LIKE '1126C5%')
             AND [Account Classification Code] LIKE 'SPR0Q__%' THEN 1
        ELSE 0
    END AS Is_Prosthetics,
    CASE
        WHEN
            (
                (FUNDID LIKE '0152__%' AND NOT (FUNDID LIKE '0152RH%' OR FUNDID LIKE '0152XA%'))
                OR (FUNDID LIKE '0160__%' AND NOT (FUNDID LIKE '0160RH%' OR FUNDID LIKE '0160XA%'))
                OR (FUNDID LIKE '0162__%' AND NOT (FUNDID LIKE '0162RH%' OR FUNDID LIKE '0162XA%'))
                OR (FUNDID LIKE '1126__%' AND NOT FUNDID LIKE '1126C5%')
            )
            AND
            (
                [Account Classification Code] LIKE 'SPD0V__%'
                OR [Account Classification Code] LIKE 'SPS0M__%'
            )
        THEN 1
        ELSE 0
    END AS Is_Trainees,
    CASE
        WHEN ([Account Classification Code] LIKE 'SP80BP__%'
             OR [Account Classification Code] LIKE 'SP8FB00__%'
             OR [Account Classification Code] LIKE 'SP8FBPA__%')
			 AND [VA Cost Ctr_2] <> '83' THEN 1
        ELSE 0
    END AS Is_Homeless_Veterans,
    CASE
        WHEN [Account Classification Code] LIKE 'SP80CP1__%' THEN 1
        ELSE 0
    END AS Is_Transplants,
    CASE
        WHEN [Account Classification Code] LIKE 'SP80KPB__%'
             OR [Account Classification Code] LIKE 'SP80KPG__%'
             OR [Account Classification Code] LIKE 'SP80KPH__%'
             OR [Account Classification Code] LIKE 'SP80KPM__%'
             OR [Account Classification Code] LIKE 'SP80KPN__%'
             OR [Account Classification Code] LIKE 'SP80KPP__%' THEN 1
        ELSE 0
    END AS Is_Suicide_Prevention,
    CASE
        WHEN [Account Classification Code] LIKE 'SPR0LP3__%'
             OR [Account Classification Code] LIKE 'SPR0LP4__%'
             OR [Account Classification Code] LIKE 'SPR0LP5__%'
             OR [Account Classification Code] LIKE 'SPR0LP6__%'
             OR [Account Classification Code] LIKE 'SPR0LP8__%'
             OR [Account Classification Code] LIKE 'SPR0LPV__%' THEN 1
        ELSE 0
    END AS Is_Caregiver,
    CASE
        WHEN [Account Classification Code] LIKE 'LG4331S2M%'
             OR [Account Classification Code] LIKE 'LG4759S4M%'
             OR [Account Classification Code] LIKE 'LG4553S3M%'
             OR [Account Classification Code] LIKE 'LG4461S3M%'
             OR [Account Classification Code] LIKE 'LG4764S4M%'
             OR [Account Classification Code] LIKE 'LG4765S4M%'
             OR [Account Classification Code] LIKE 'LG4766S4M%'
             OR [Account Classification Code] LIKE 'LG5082S5M%' THEN 1
        ELSE 0
    END AS Is_Station_Level,
    CASE
        WHEN FUNDID LIKE '0160RH'
             OR FUNDID LIKE '0152RH'
             OR FUNDID LIKE '0162RH' THEN 1
        ELSE 0
    END AS Is_Rural_Health,
    CASE
        WHEN [Account Classification Code] LIKE 'SPY0__%'
             OR [Account Classification Code] LIKE 'SPYC__%' THEN 1
        ELSE 0
    END AS Is_Activations,
    CASE
        WHEN [Account Classification Code] LIKE '23__%'
             OR [Account Classification Code] LIKE 'EH__%' THEN 1
        ELSE 0
    END AS Is_NRM,
    CASE
        WHEN FUNDID LIKE '0140__'
             AND [Account Classification Code] LIKE 'SPW0FP7__%' THEN 1
        ELSE 0
    END AS Is_State_Home,
    CASE
        WHEN [FUNDID] LIKE '0140__' OR [FUNDID] LIKE '1126C5%' THEN 'Medical Community Care'
        WHEN [FUNDID] LIKE '0162__' THEN 'Facilities'
        WHEN [FUNDID] LIKE '0160__' OR [FUNDID] LIKE '1126M5%' OR [FUNDID] LIKE '1126MS%' THEN 'Medical Services'
        WHEN [FUNDID] LIKE '0152__' OR [FUNDID] LIKE '1126S5%' OR [FUNDID] LIKE '1126SC%' THEN 'Support and Compliance'
        ELSE NULL
    END AS Appropriation,
    acc.[core noncore]
FROM FMSData AS fms
CROSS JOIN MaxYearCTE
LEFT JOIN [VHA104_Finance].[CDR].[ACC_Crosswalk] acc 
    ON fms.[Account Classification Code] = acc.[ACC]
LEFT OUTER JOIN CleanedDistinctOffices AS ST 
    ON fms.[Parent Facility District] = ST.[887 Stn]
WHERE YEAR(fms.[Fiscal Date]) >= (MaxYear - 3)
)
SELECT *,
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
			AND Is_Personal_Services = 0
			AND Is_Pharmacy = 0
			AND Is_CMOP = 0
			AND Is_Contracts = 0
			AND Is_Outpatient = 0
			AND Is_Inpatient = 0
			AND Is_Dental = 0
        THEN 1 
        ELSE 0 
    END AS Is_Other_SP
FROM CategorizedData;
