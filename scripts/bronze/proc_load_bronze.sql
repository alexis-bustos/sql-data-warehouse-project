/*
=================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=================================================================================
Script Purpose: 
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
    - Truncates the bonze tables before loading data.
    - Uses the `BULK INSERT` command to load data from CSV files to bronze tables.

Parameters:
  - None
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
=================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
  DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
  BEGIN TRY
    SET @batch_start_time = GETDATE();
    PRINT '================================';
    PRINT 'Loading Bronze layer...';
    PRINT '================================';

    PRINT '--------------------------------';
    PRINT 'Loading CRM Tables...';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncatating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    PRINT '>> Inserting data into Table: bronze.crm_cust_info';
    BULK INSERT bronze.crm_cust_info
    FROM '/var/opt/mssql/cust_info.csv'
    WITH (
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load duration bronze.crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncatating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    PRINT '>> Inserting data into Table: bronze.crm_prd_info';
    BULK INSERT bronze.crm_prd_info
    FROM '/var/opt/mssql/prd_info.csv'
    WITH (
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load duration bronze.crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncatating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    PRINT '>> Inserting data into Table: bronze.crm_sales_details';
    BULK INSERT bronze.crm_sales_details
    FROM '/var/opt/mssql/sales_details.csv'
    WITH (
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load duration bronze.crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '--------------------------------';

    PRINT '--------------------------------';
    PRINT 'Loading ERP Tables...';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncatating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    PRINT '>> Inserting data into Table: bronze.erp_cust_az12';
    BULK INSERT bronze.erp_cust_az12
    FROM '/var/opt/mssql/cust_az12.csv'
    WITH (
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load duration bronze.erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncatating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    PRINT '>> Inserting data into Table: bronze.erp_loc_a101';
    BULK INSERT bronze.erp_loc_a101
    FROM '/var/opt/mssql/loc_a101.csv'
    WITH (
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load duration bronze.erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncatating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    PRINT '>> Inserting data into Table: bronze.erp_px_cat_g1v2';
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM '/var/opt/mssql/px_cat_g1v2.csv'
    WITH (
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load duration bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '--------------------------------';

    SET @batch_end_time = GETDATE();
    PRINT '================================';
    PRINT 'Bronze layer load completed successfully.';
    PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '================================';
  END TRY
  BEGIN CATCH
    PRINT '================================';
    PRINT 'Error occurred while loading Bronze layer: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT '================================';
    THROW;
  END CATCH
END
GO

EXEC bronze.load_bronze;
GO

