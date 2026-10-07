# Validation and Testing

The completed manufacturing data warehouse was validated using SQL queries in Azure Synapse Analytics.

## 1. Data Processing Validation

The raw manufacturing dataset contained 5,003 records.

After staging, cleaning, duplicate removal, and standardization, 5,000 records were loaded into the warehouse.

| Data Object | Verified Count |
|---|---:|
| Raw records | 5,003 |
| Clean records | 5,000 |
| FactProduction | 5,000 |
| DimMachine | 5 |
| DimProduct | 3 |
| DimPlant | 3 |
| DimDate | 181 |

The difference between the raw and cleaned record counts confirms that duplicate records were removed during the transformation process.

## 2. Warehouse Validation

The dimensional warehouse was verified by checking the populated fact and dimension tables.

The resulting star schema contained:

- `FactProduction`
- `DimMachine`
- `DimProduct`
- `DimPlant`
- `DimDate`

All 5,000 cleaned production records were loaded into `FactProduction`.

## 3. Analytical Validation

SQL aggregation queries were executed against `FactProduction` to verify the analytical results.

| Metric | Result |
|---|---:|
| Total Production | 4,990,312 |
| Total Defects | 74,832 |
| Average Defect Rate | ~1.499% |
| Total Downtime | 12,637.10 hours |
| Total Energy Consumption | 2,589,945.20 kWh |

## 4. ETL Validation

The ETL workflow was verified through the following stages:

1. Raw manufacturing CSV stored in Azure Data Lake Storage Gen2.
2. Raw data copied into the Synapse staging table.
3. Data cleaned and standardized using SQL transformation logic.
4. Dimension tables rebuilt from the cleaned staging data.
5. Fact records loaded into `FactProduction`.
6. Analytical SQL queries executed against the completed warehouse.

## 5. Final Verification

The dedicated SQL pool was successfully used to verify the final warehouse contents.

The completed ETL process produced a consistent dimensional model and successfully supported analytical queries for production, defects, downtime, and energy consumption.
