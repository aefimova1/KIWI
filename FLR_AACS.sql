WITH CleanedMnemonicXwalk AS (SELECT DISTINCT Mnemonic, Designation
                                                       FROM    CDR.MnemonicXwalk), CleanedDistinctStations AS
    (SELECT DISTINCT [AACS Stn], Stn3, [Standard Data Rollup Group], [VISN/VHA]
    FROM    CDR.[Stn Xwalk]
    WHERE ([AACS Stn] IS NOT NULL) AND ([AACS Stn] <> ''))
    SELECT A.Facility, A.TDA#, A.Fund, A.[Prog Office], A.[Prog Code], A.Mnemonic, A.Date, A.Ledger, A.Total, DT.FiscalMonth, DT.FiscalYear, DATEFROMPARTS(DT.FiscalYear, DT.FiscalMonth, 1) AS [Fiscal Date], ST.Stn3 AS Stn, ST.[Standard Data Rollup Group], ST.[VISN/VHA], MC.Designation,
                    (SELECT CASE WHEN A.[Fund] LIKE '0140__' OR
                                 A.[Fund] LIKE '1126C5%' THEN 'Medical Community Care' WHEN A.[Fund] LIKE '0162__' THEN 'Facilities' WHEN A.[Fund] LIKE '0160__' OR
                                 A.[Fund] LIKE '1126M5%' OR
                                 A.[Fund] LIKE '1126MS%' THEN 'Medical Services' WHEN A.[Fund] LIKE '0152__' OR
                                 A.[Fund] LIKE '1126S5%' OR
                                 A.[Fund] LIKE '1126SC%' THEN 'Support and Compliance' ELSE NULL END AS Expr1) AS Appropriation, 
								 CASE WHEN RIGHT(A.[Fund], 2) = 'RH' OR
                LEFT(A.[Mnemonic], 2) = '23' OR
                A.[Mnemonic] = '07SP' OR
                LEFT(A.[Prog Code], 2) = '23' OR
                (LEFT(A.[Mnemonic], 2) = 'SP' AND
                    (SELECT CASE WHEN A.[Fund] LIKE '0140__' OR
                                 A.[Fund] LIKE '1126C5%' THEN 'Medical Community Care' WHEN A.[Fund] LIKE '0162__' THEN 'Facilities' WHEN A.[Fund] LIKE '0160__' OR
                                 A.[Fund] LIKE '1126M5%' OR
                                 A.[Fund] LIKE '1126MS%' THEN 'Medical Services' WHEN A.[Fund] LIKE '0152__' OR
                                 A.[Fund] LIKE '1126S5%' OR
                                 A.[Fund] LIKE '1126SC%' THEN 'Support and Compliance' ELSE NULL END) <> 'Medical Community Care') OR
                A.[Mnemonic] = 'SPWF-STHA140' THEN 'SP' ELSE 'GP' END AS GP_SP, CASE WHEN ST.[VISN/VHA] LIKE 'V00%' THEN 'AUSH' ELSE 'VISN' END AS [VISN/AUSH], CASE WHEN A.[Fund] LIKE '0140__' OR
                A.[Fund] LIKE '1126C5%' THEN 'Community Care' WHEN 
				A.[Fund] LIKE '0152__' OR
                A.[Fund] LIKE '0160__' OR
                A.[Fund] LIKE '0162__' OR
                A.[Fund] LIKE '1126M5%' OR
                A.[Fund] LIKE '1126MS%' OR
                A.[Fund] LIKE '1126S5%' OR
                A.[Fund] LIKE '1126SC%' THEN 'Direct Care' ELSE NULL END AS Direct_Community,
				CASE WHEN A.[Fund] LIKE '%X4' 
				AND [Ledger] NOT LIKE '%INITIAL ALLOCATION%'
				AND ST.[VISN/VHA] NOT LIKE 'V00%' THEN 1 ELSE 0 END AS Is_Collections, 
				CASE WHEN A.[Fund] LIKE '%R1'
				AND ST.[VISN/VHA] NOT LIKE 'V00%' THEN 1 ELSE 0 END AS Is_Reimbursables, 
                CASE WHEN A.[Mnemonic] LIKE 'SPRQ-PRTA160' THEN 1 ELSE 0 END AS Is_Prosthetics, 
				CASE WHEN A.[Mnemonic] IN ('SPDV-EXDA152', 'SPDV-EXDA160', 'SPDV-EXDA162', 'SPDV-GHAA152','SPDV-TECFA152', 'SPDV-TECFA160', 'SPDV-TECFA162', 'SPSM-TNGA160','SPSM-GMEA160') 
                THEN 1 ELSE 0 END AS Is_Trainees, 
				CASE WHEN A.[Prog Office] LIKE '11HPO%' THEN 1 ELSE 0 END AS Is_Homeless_Veterans, 
				CASE WHEN A.[Mnemonic] LIKE 'SP8C-INDA160' THEN 1 ELSE 0 END AS Is_Transplants, 
				CASE WHEN A.[Mnemonic] LIKE 'SP8K-SPPIA%' OR
				A.[Mnemonic] LIKE 'SP8K-COORA_%' OR
				A.[Mnemonic] LIKE 'P8K-DEMA_%' OR
				A.[Mnemonic] LIKE 'SP8K-PREVA_%' OR
				A.[Mnemonic] LIKE 'SP8K-SPICLA_%' OR
				A.[Mnemonic] LIKE 'SP8K-SPGPA_%'
				THEN 1 ELSE 0 END AS Is_Suicide_Prevention, 
				CASE WHEN A.[Mnemonic] LIKE 'SPRL-LLSA__%' OR
                A.[Mnemonic] LIKE 'SPRL-LOAA__%' OR
                A.[Mnemonic] LIKE 'SPRL-LRCRA__%' OR
                A.[Mnemonic] LIKE 'SPRL-LPTA__%' OR
                A.[Mnemonic] LIKE 'SPRL-CGRSA__%' OR
                A.[Mnemonic] LIKE 'SPRL-LMHA__%' OR
                A.[Mnemonic] LIKE 'SPRL-LEGA__%' THEN 1 ELSE 0 END AS Is_Caregiver, 
				CASE WHEN A.[Prog Code] = 'SP0Y' AND A.[Mnemonic] LIKE 'SPYD-LSE__%' THEN 1 ELSE 0 END AS Is_Station_Level, 
				CASE WHEN A.[Fund] IN ('0152RH', '0160RH', '0162RH') 
                THEN 1 ELSE 0 END AS Is_Rural_Health, 
				CASE WHEN A.[Prog Code] LIKE 'SP0Y' AND A.[Mnemonic] NOT LIKE 'SPYD-LSE__%' THEN 1 ELSE 0 END AS Is_Activations, 
				CASE WHEN A.[Prog Code] LIKE '23__' THEN 1 ELSE 0 END AS Is_NRM, 
                CASE WHEN A.[Mnemonic] = 'SPWF-STHA140' THEN 1 ELSE 0 END AS Is_State_Home
   FROM    CDR.AACS AS A LEFT OUTER JOIN
                CDR.DateTable AS DT ON CAST(A.Date AS DATE) = CAST(DT.Date AS DATE) LEFT OUTER JOIN
                CleanedDistinctStations AS ST ON A.Facility = ST.[AACS Stn] LEFT OUTER JOIN
                CleanedMnemonicXwalk AS MC ON A.Mnemonic = MC.Mnemonic
   WHERE (A.Fund LIKE '0140A1%' OR
                A.Fund LIKE '0140B2%' OR
                A.Fund LIKE '0140EO%' OR
                A.Fund LIKE '0140X4%' OR
                A.Fund LIKE '0152A1%' OR
                A.Fund LIKE '0152B2%' OR
                A.Fund LIKE '0152R1%' OR
                A.Fund LIKE '0152RH%' OR
                A.Fund LIKE '0152XA%' OR
                A.Fund LIKE '0160A1%' OR
                A.Fund LIKE '0160B2%' OR
                A.Fund LIKE '0160EO%' OR
                A.Fund LIKE '0160R1%' OR
                A.Fund LIKE '0160RH%' OR
                A.Fund LIKE '0160X4%' OR
                A.Fund LIKE '0160XA%' OR
                A.Fund LIKE '0162A1%' OR
                A.Fund LIKE '0162B2%' OR
                A.Fund LIKE '0162R1%' OR
                A.Fund LIKE '0162RH%' OR
                A.Fund LIKE '0162X3%' OR
                A.Fund LIKE '0162X6%' OR
                A.Fund LIKE '0162XA%' OR
                A.Fund LIKE '0162XL%' OR
                A.Fund LIKE '0162XT%' OR
                A.Fund LIKE '0162XU%' OR
                A.Fund LIKE '1126C5%' OR
                A.Fund LIKE '1126M5%' OR
                A.Fund LIKE '1126MS%' OR
                A.Fund LIKE '1126S5%' OR
                A.Fund LIKE '1126SC%') 
				AND (A.Facility <> '1 VHA CENTRAL OFFICE');