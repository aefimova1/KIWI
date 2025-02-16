CREATE TABLE [VHA104_Finance].[App].[AUSH_Inputs_Total_Projected_SurplusNeed_CoreHybrid] (
    AUSH VARCHAR(250), 
    Month DATE, 
    TestRecord VARCHAR(50), 
    Category VARCHAR(50), 
    Care VARCHAR(50), 
    YTD_Allocation DECIMAL(18,2), 
    YTD_Obligations DECIMAL(18,2), 
    Planned_Obligations DECIMAL(18,2), 
    Projected_Surplus_Need DECIMAL(18,2), 
    POC_Comments TEXT, 
    Review VARCHAR(50), 
    Reviewer_Comments TEXT
);
