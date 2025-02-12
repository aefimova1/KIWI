CREATE TABLE [VHA104_Finance].[App].[AUSH_Inputs-Core_Hybrid_Obligation_Growth_By_Cost_Driver] (
    AUSH VARCHAR(255),
    Month DATE,
    TypeOfCare VARCHAR(50),
    PlannedObligations DECIMAL(18, 2),
    PYEoyObligations DECIMAL(18, 2),
    Growth DECIMAL(18, 2),
    YTDObligations DECIMAL(18, 2),
    YTDExecutionRate DECIMAL(5, 2)
);
