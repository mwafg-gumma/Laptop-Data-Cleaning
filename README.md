
# 🖥️ Laptop Data Cleaning Project

## 📋 Project Overview
This project involves cleaning a raw laptop dataset using **MySQL only**.
The dataset contains 893 rows and 16 columns after cleaning.

## 🗃️ Dataset
- **Raw data:** 893 rows, 18 columns
- **Cleaned data:** 893 rows, 16 columns

## 🧹 Cleaning Steps

### 1. Dropped Junk Columns
- Removed `Unnamed: 0`, `Unnamed: 0.1` and `MyUnknownColumn` (duplicate index columns)

### 2. Fixed `name` Column
- Removed corrupted characters `â€Ž`
- Removed double spaces

### 3. Fixed `spec_rating` Column
- Changed data type from `DOUBLE` to `DECIMAL(5,2)`
- Rounded all values to 2 decimal places

### 4. Fixed `processor` Column
- Standardized `Amd` → `AMD`

### 5. Fixed `Ram` Column
- Extracted numeric values from strings (e.g. `8GB` → `8`)
- Changed data type to `INT`

### 6. Fixed `Ram_type` Column
- Uppercased all values for consistency
- Fixed `DDR4-` → `DDR4`

### 7. Fixed `ROM` Column
- Converted all values to GB as integers
- `1TB` → `1024`, `512GB` → `512`

### 8. Fixed `GPU` Column
- Removed duplicated words (`AMD Radeon AMD` → `AMD Radeon`)
- Fixed typos (`Graphiics` → `Graphics`)
- Standardized casing (`Iris XE` → `Iris Xe`)
- Removed corrupted characters (`Â®`)

### 9. Fixed `OS` Column
- Removed double spaces
- Standardized all Mac versions to `Mac OS`
- Standardized `Windows OS` → `Windows 11 OS`
- Standardized `DOS 3.0 OS` → `DOS OS`

### 10. Fixed `warranty` Column
- Replaced `0` values with `1` (minimum warranty)

## 🛠️ Tools Used
- **MySQL** — All cleaning done using SQL queries only

## 📁 Files
- `Laptop_data_cleaned.csv` — Final cleaned dataset
