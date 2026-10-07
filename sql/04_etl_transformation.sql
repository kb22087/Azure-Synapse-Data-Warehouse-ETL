CREATE PROCEDURE dbo.usp_Transform_Manufacturing
AS
BEGIN

    /* =========================================
       1. CLEAN STAGING DATA
       ========================================= */

    TRUNCATE TABLE dbo.stg_Production_Clean;

    INSERT INTO dbo.stg_Production_Clean
    (
        ProductionID,
        [Date],
        MachineID,
        ProductID,
        PlantID,
        ProductionQty,
        DefectQty,
        OperatingHours,
        DowntimeHours,
        EnergyKWh,
        TemperatureC,
        VibrationMMs
    )
    SELECT
        ProductionID,
        [Date],
        UPPER(LTRIM(RTRIM(MachineID))),
        UPPER(LTRIM(RTRIM(ProductID))),
        UPPER(LTRIM(RTRIM(PlantID))),
        ProductionQty,
        DefectQty,
        OperatingHours,
        DowntimeHours,
        EnergyKWh,
        TemperatureC,
        VibrationMMs
    FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER
            (
                PARTITION BY ProductionID
                ORDER BY [Date] DESC
            ) AS rn
        FROM dbo.stg_Production
    ) AS C
    WHERE rn = 1;


    /* =========================================
       2. REBUILD MACHINE DIMENSION
       ========================================= */

    TRUNCATE TABLE dbo.DimMachine;

    INSERT INTO dbo.DimMachine
    (
        MachineKey,
        MachineID
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY MachineID),
        MachineID
    FROM
    (
        SELECT DISTINCT MachineID
        FROM dbo.stg_Production_Clean
        WHERE MachineID IS NOT NULL
    ) AS M;


    /* =========================================
       3. REBUILD PRODUCT DIMENSION
       ========================================= */

    TRUNCATE TABLE dbo.DimProduct;

    INSERT INTO dbo.DimProduct
    (
        ProductKey,
        ProductID
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY ProductID),
        ProductID
    FROM
    (
        SELECT DISTINCT ProductID
        FROM dbo.stg_Production_Clean
        WHERE ProductID IS NOT NULL
    ) AS P;


    /* =========================================
       4. REBUILD PLANT DIMENSION
       ========================================= */

    TRUNCATE TABLE dbo.DimPlant;

    INSERT INTO dbo.DimPlant
    (
        PlantKey,
        PlantID
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY PlantID),
        PlantID
    FROM
    (
        SELECT DISTINCT PlantID
        FROM dbo.stg_Production_Clean
        WHERE PlantID IS NOT NULL
    ) AS PL;


    /* =========================================
       5. REBUILD DATE DIMENSION
       ========================================= */

    TRUNCATE TABLE dbo.DimDate;

    INSERT INTO dbo.DimDate
    (
        DateKey,
        [Date],
        Year,
        Month,
        Day,
        MonthName
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY [Date]),
        [Date],
        YEAR([Date]),
        MONTH([Date]),
        DAY([Date]),
        DATENAME(month, [Date])
    FROM
    (
        SELECT DISTINCT [Date]
        FROM dbo.stg_Production_Clean
        WHERE [Date] IS NOT NULL
    ) AS D;


    /* =========================================
       6. REBUILD FACT TABLE
       ========================================= */

    TRUNCATE TABLE dbo.FactProduction;

    INSERT INTO dbo.FactProduction
    (
        ProductionID,
        DateKey,
        MachineKey,
        ProductKey,
        PlantKey,
        ProductionQty,
        DefectQty,
        OperatingHours,
        DowntimeHours,
        EnergyKWh,
        TemperatureC,
        VibrationMMs,
        DefectRate,
        EnergyPerUnit
    )
    SELECT
        C.ProductionID,
        DD.DateKey,
        DM.MachineKey,
        DP.ProductKey,
        DPL.PlantKey,
        C.ProductionQty,
        C.DefectQty,
        C.OperatingHours,
        C.DowntimeHours,
        C.EnergyKWh,
        C.TemperatureC,
        C.VibrationMMs,

        CAST(
            CASE
                WHEN C.ProductionQty > 0
                THEN (C.DefectQty * 100.0) / C.ProductionQty
                ELSE 0
            END
            AS DECIMAL(10,2)
        ),

        CAST(
            CASE
                WHEN C.ProductionQty > 0
                THEN C.EnergyKWh / C.ProductionQty
                ELSE 0
            END
            AS DECIMAL(12,4)
        )

    FROM dbo.stg_Production_Clean C

    LEFT JOIN dbo.DimDate DD
        ON C.[Date] = DD.[Date]

    LEFT JOIN dbo.DimMachine DM
        ON C.MachineID = DM.MachineID

    LEFT JOIN dbo.DimProduct DP
        ON C.ProductID = DP.ProductID

    LEFT JOIN dbo.DimPlant DPL
        ON C.PlantID = DPL.PlantID;

END;
