-- ============================================================
--        💻 Laptop Inventory Data Cleaning Project
-- ============================================================
-- Database  : Laptop_Inventory
-- Table     : laptop_data
-- Tool      : MySQL Workbench 8.0
-- ============================================================


-- ============================================================
-- STEP 0: Create & Select The Database
-- ============================================================

CREATE DATABASE IF NOT EXISTS `Laptop_Inventory`;
USE `Laptop_Inventory`;


-- ============================================================
-- STEP 1: Check The Table Column Types
-- ============================================================

DESCRIBE laptop_data;


-- ============================================================
-- STEP 2: Drop Unnecessary Columns
-- ============================================================
-- Remove Auto-generated Index Columns That We Don't Need

ALTER TABLE laptop_data
DROP COLUMN `Unnamed: 0`;

ALTER TABLE laptop_data
DROP COLUMN MyUnknownColumn;

-- Verify Columns After Drop
SELECT * FROM laptop_data;


-- ============================================================
-- STEP 3: Standardize All Columns
-- ============================================================


-- ------------------------------------------------------------
-- A. Brand Column
-- ------------------------------------------------------------

SELECT brand, COUNT(*) AS Count
FROM laptop_data
GROUP BY brand
ORDER BY Count DESC;


-- ------------------------------------------------------------
-- B. Name Column
-- ------------------------------------------------------------

-- Check Duplicate Names
SELECT name, COUNT(*) AS Count
FROM laptop_data
GROUP BY name
HAVING Count > 1
ORDER BY Count DESC;

-- Remove Corrupted Character (â€Ž) From Name
UPDATE laptop_data
SET name = TRIM(REGEXP_REPLACE(name, 'â€Ž', ''))
WHERE name LIKE '%â€Ž%';

-- Trim Extra Spaces Inside Name
UPDATE laptop_data
SET name = TRIM(REGEXP_REPLACE(name, ' +', ' '))
WHERE name LIKE '%  %';

-- Confirm Both Fixes Are Applied (Should Return 0 Rows)
SELECT name FROM laptop_data
WHERE name LIKE '%â€Ž%'
   OR name LIKE '%  %';


-- ------------------------------------------------------------
-- C. Price Column
-- ------------------------------------------------------------

-- Check MAX, MIN, AVG Price
SELECT
    MAX(price) AS Max_Price,
    MIN(price) AS Min_Price,
    AVG(price) AS Average_Price
FROM laptop_data;

-- Check For Suspicious Outliers (Too Cheap Or Too Expensive)
SELECT name, brand, price
FROM laptop_data
WHERE price < 10000 OR price > 500000
ORDER BY price;


-- ------------------------------------------------------------
-- D. Spec Rating Column
-- ------------------------------------------------------------

-- Check Current spec_rating Range
SELECT
    MIN(spec_rating) AS Min_Rating,
    MAX(spec_rating) AS Max_Rating,
    AVG(spec_rating) AS Average_Rating
FROM laptop_data;

-- Round All spec_rating Values To 2 Decimal Places
UPDATE laptop_data
SET spec_rating = ROUND(spec_rating, 2);

-- Change Column Type To DECIMAL To Enforce 2 Decimal Places
ALTER TABLE laptop_data
MODIFY COLUMN spec_rating DECIMAL(5, 2);

-- Verify Rounding Worked
SELECT spec_rating, COUNT(*) AS Count
FROM laptop_data
GROUP BY spec_rating
ORDER BY Count DESC
LIMIT 10;


-- ------------------------------------------------------------
-- E. Processor Column
-- ------------------------------------------------------------

-- Check Distinct Processor Values
SELECT processor, COUNT(*) AS Count
FROM laptop_data
GROUP BY processor
ORDER BY Count DESC
LIMIT 10;

-- Check All Inconsistent AMD Casing
SELECT processor, COUNT(*) AS Count
FROM laptop_data
WHERE processor LIKE '%Amd%'
GROUP BY processor
ORDER BY Count DESC;

-- Fix: Replace 'Amd' With 'AMD' Everywhere
UPDATE laptop_data
SET processor = REPLACE(processor, 'Amd', 'AMD')
WHERE processor LIKE '%Amd%';

-- Confirm Fix (Should Return 0 Rows)
SELECT processor FROM laptop_data
WHERE processor LIKE '%Amd%';


-- ------------------------------------------------------------
-- F. Ram Column
-- ------------------------------------------------------------

-- Check Distinct RAM Values
SELECT Ram, COUNT(*) AS Count
FROM laptop_data
GROUP BY Ram
ORDER BY Count DESC;

-- Preview Numeric Extraction From RAM String
SELECT Ram, CAST(REPLACE(Ram, 'GB', '') AS UNSIGNED) AS Ram_Numeric
FROM laptop_data
GROUP BY Ram;

-- Add New Numeric Column For RAM
ALTER TABLE laptop_data
ADD COLUMN Ram_GB INT AFTER Ram;

-- Fill New Column With Numeric Values
UPDATE laptop_data
SET Ram_GB = CAST(REPLACE(Ram, 'GB', '') AS UNSIGNED);

-- Drop Old String Column
ALTER TABLE laptop_data
DROP COLUMN Ram;

-- Rename New Column Back To Ram
ALTER TABLE laptop_data
RENAME COLUMN Ram_GB TO Ram;

-- Verify Final RAM Column
SELECT * FROM laptop_data;


-- ------------------------------------------------------------
-- G. Ram Type Column
-- ------------------------------------------------------------

-- Check Distinct Ram_type Values
SELECT Ram_type, COUNT(*) AS Count
FROM laptop_data
GROUP BY Ram_type
ORDER BY Count DESC;

-- Fix DDR4 Trailing Dash (DDR4- → DDR4)
UPDATE laptop_data
SET Ram_type = 'DDR4'
WHERE Ram_type = 'DDR4-';

-- Inspect The DDR1 Row To Decide What To Do
SELECT name, brand, Ram, Ram_type, price
FROM laptop_data
WHERE Ram_type = 'DDR1';


-- ------------------------------------------------------------
-- H. ROM Column
-- ------------------------------------------------------------

-- Check Distinct ROM Values
SELECT ROM, COUNT(*) AS Count
FROM laptop_data
GROUP BY ROM
ORDER BY Count DESC;


-- ------------------------------------------------------------
-- I. GPU Column
-- ------------------------------------------------------------

-- Trim Extra Spaces In GPU
UPDATE laptop_data
SET GPU = TRIM(REGEXP_REPLACE(GPU, ' +', ' '));

-- Check Distinct GPU Values
SELECT GPU, COUNT(*) AS Count
FROM laptop_data
GROUP BY GPU
ORDER BY Count DESC;

-- Fix Corrupted Character (Â®)
UPDATE laptop_data
SET GPU = REPLACE(GPU, 'Â®', '')
WHERE GPU LIKE '%Â®%';

-- Fix Duplicated 'AMD Radeon AMD' → 'AMD Radeon'
UPDATE laptop_data
SET GPU = REPLACE(GPU, 'AMD Radeon AMD', 'AMD Radeon')
WHERE GPU LIKE '%AMD Radeon AMD%';

-- Fix Duplicated 'AMD Radeon Radeon' → 'AMD Radeon'
UPDATE laptop_data
SET GPU = REPLACE(GPU, 'AMD Radeon Radeon', 'AMD Radeon')
WHERE GPU LIKE '%AMD Radeon Radeon%';

-- Fix Duplicated 'Intel Integrated Integrated' → 'Intel Integrated'
UPDATE laptop_data
SET GPU = REPLACE(GPU, 'Intel Integrated Integrated', 'Intel Integrated')
WHERE GPU LIKE '%Intel Integrated Integrated%';

-- Fix Typo 'Graphiics' → 'Graphics'
UPDATE laptop_data
SET GPU = REPLACE(GPU, 'Graphiics', 'Graphics')
WHERE GPU LIKE '%Graphiics%';

-- Standardize 'Integrated Intel UHD' → 'Intel Integrated UHD'
UPDATE laptop_data
SET GPU = REPLACE(GPU, 'Integrated Intel UHD', 'Intel Integrated UHD')
WHERE GPU LIKE '%Integrated Intel UHD%';

-- Verify All GPU Fixes
SELECT GPU, COUNT(*) AS Count
FROM laptop_data
GROUP BY GPU
ORDER BY Count DESC
LIMIT 20;


-- ------------------------------------------------------------
-- J. OS Column
-- ------------------------------------------------------------

-- Check Distinct OS Values
SELECT OS, COUNT(*) AS Count
FROM laptop_data
GROUP BY OS
ORDER BY Count DESC;

-- Fix Double Spaces In Windows 11 OS
UPDATE laptop_data
SET OS = 'Windows 11 OS'
WHERE OS = 'Windows 11  OS';

-- Fix Double Spaces In Windows 10 OS
UPDATE laptop_data
SET OS = 'Windows 10 OS'
WHERE OS = 'Windows 10  OS';

-- Standardize 'Windows OS' → 'Windows 11 OS'
UPDATE laptop_data
SET OS = 'Windows 11 OS'
WHERE OS = 'Windows OS';

-- Standardize 'DOS 3.0 OS' → 'DOS OS'
UPDATE laptop_data
SET OS = 'DOS OS'
WHERE OS = 'DOS 3.0 OS';

-- Standardize All Mac Versions → 'Mac OS'
UPDATE laptop_data
SET OS = 'Mac OS'
WHERE OS IN ('Mac 10.15.3 OS', 'Mac Catalina OS', 'Mac High Sierra OS');

-- Force Fix Using LENGTH To Target Exact 15 Character Mac Values
UPDATE laptop_data
SET OS = 'Mac OS'
WHERE LENGTH(OS) = 15 AND OS LIKE '%Mac%';

-- Verify Final OS Values
SELECT OS, COUNT(*) AS Count
FROM laptop_data
GROUP BY OS
ORDER BY Count DESC;


-- ------------------------------------------------------------
-- K. Warranty Column
-- ------------------------------------------------------------

-- Check Distinct Warranty Values
SELECT warranty, COUNT(*) AS Count
FROM laptop_data
GROUP BY warranty
ORDER BY Count DESC;

-- Check Rows With 0 Warranty
SELECT name, brand, price, warranty
FROM laptop_data
WHERE warranty = 0;

-- Set Warranty To 1 For Rows With 0 Warranty
UPDATE laptop_data
SET warranty = 1
WHERE warranty = 0;

-- Verify Final Warranty Values
SELECT warranty, COUNT(*) AS Count
FROM laptop_data
GROUP BY warranty
ORDER BY Count DESC;


-- ============================================================
-- STEP 4: Export Cleaned Data To CSV
-- ============================================================

-- Check MySQL Secure Upload Folder Path First
SHOW VARIABLES LIKE 'secure_file_priv';

-- Export Cleaned Table To CSV File
SELECT * FROM laptop_data
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Laptop_data_cleaned.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- ============================================================
-- ✅ Laptop Data Is 100% Clean — Ready For Analysis!
-- ============================================================
