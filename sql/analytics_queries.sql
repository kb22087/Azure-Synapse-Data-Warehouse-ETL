-- =========================================
-- MANUFACTURING DATA WAREHOUSE ANALYTICS
-- =========================================

-- 1. Total Production
SELECT
    SUM(ProductionQty) AS TotalProduction
FROM dbo.FactProduction;


-- 2. Total Defects
SELECT
    SUM(DefectQty) AS TotalDefects
FROM dbo.FactProduction;


-- 3. Average Defect Rate
SELECT
    AVG(DefectRate) AS AverageDefectRate
FROM dbo.FactProduction;


-- 4. Total Downtime
SELECT
    SUM(DowntimeHours) AS TotalDowntimeHours
FROM dbo.FactProduction;


-- 5. Total Energy Consumption
SELECT
    SUM(EnergyKWh) AS TotalEnergyKWh
FROM dbo.FactProduction;
