CREATE TABLE [VHA104_Finance].[App].[AUSH_Inpits-Surplus/Need_by_Appropriation] (
    AUSH VARCHAR(255),
    Month DATE,
    CoreType VARCHAR(50),
    SurplusNeedTotal DECIMAL(18, 2),
    SurplusNeedMedicalServices DECIMAL(18, 2),
    SurplusNeedSupportAndCompliance DECIMAL(18, 2),
    SurplusNeedFacilities DECIMAL(18, 2),
    SurplusNeedMedicalCommunityCare DECIMAL(18, 2)
);
