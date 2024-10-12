-- Create the database and the initial table for layoffs data
CREATE DATABASE layoffs;

USE layoffs;

-- Create the main table for layoffs data
CREATE TABLE layoffs (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT
);

-- Create a staging table to work on and clean the data while preserving the raw data
CREATE TABLE layoffs_stage LIKE layoffs;

-- Insert data from the main table into the staging table
INSERT INTO layoffs_stage SELECT * FROM layoffs;

-- Step 1: Remove Duplicates

-- Check for duplicates
SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, `date`) AS row_num
FROM layoffs_stage;

-- Find the rows that are duplicates
SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_stage
) duplicates
WHERE row_num > 1;

-- Add a row number column to the staging table
ALTER TABLE layoffs_stage ADD row_num INT;

-- Create a new staging table with row numbers assigned to each row
CREATE TABLE layoffs_stage2 AS
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
       ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_stage;

-- Delete duplicate rows from the new staging table
DELETE FROM layoffs_stage2 WHERE row_num >= 2;

-- Step 2: Standardize Data

-- Identify distinct values in the 'industry' column to check for nulls or blanks
SELECT DISTINCT industry FROM layoffs_stage2 ORDER BY industry;

-- Check for rows with null or empty 'industry' values
SELECT * FROM layoffs_stage2 WHERE industry IS NULL OR industry = '' ORDER BY industry;

-- Set blank 'industry' values to null for easier handling
UPDATE layoffs_stage2 SET industry = NULL WHERE industry = '';

-- Populate null 'industry' values based on other rows with the same company name
UPDATE layoffs_stage2 t1
JOIN layoffs_stage2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Standardize variations in the 'industry' column (e.g., 'Crypto' variations)
UPDATE layoffs_stage2 SET industry = 'Crypto' WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Check distinct 'country' values to find and fix inconsistencies
SELECT DISTINCT country FROM layoffs_stage2 ORDER BY country;

-- Standardize 'country' values by removing trailing periods
UPDATE layoffs_stage2 SET country = TRIM(TRAILING '.' FROM country);

-- Convert 'date' column to proper DATE data type
UPDATE layoffs_stage2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_stage2 MODIFY COLUMN `date` DATE;

-- Step 3: Handle Null Values

-- Check for rows with null values in 'total_laid_off' and 'percentage_laid_off'
SELECT * FROM layoffs_stage2 WHERE total_laid_off IS NULL;
SELECT * FROM layoffs_stage2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Delete rows with both 'total_laid_off' and 'percentage_laid_off' null
DELETE FROM layoffs_stage2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove the 'row_num' column as it is no longer needed
ALTER TABLE layoffs_stage2 DROP COLUMN row_num;

-- ===================== Exploratory Data Analysis ==============================

-- Find the maximum number of total layoffs
SELECT MAX(total_laid_off) FROM layoffs_stage2;

-- Find the range of 'percentage_laid_off'
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off) FROM layoffs_stage2 WHERE percentage_laid_off IS NOT NULL;

-- Identify companies with 100% layoffs
SELECT * FROM layoffs_stage2 WHERE percentage_laid_off = 1;

-- Order companies with 100% layoffs by 'funds_raised_millions'
SELECT * FROM layoffs_stage2 WHERE percentage_laid_off = 1 ORDER BY funds_raised_millions DESC;

-- Companies with the biggest single layoff
SELECT company, total_laid_off FROM layoffs_stage2 ORDER BY total_laid_off DESC LIMIT 5;

-- Companies with the most total layoffs
SELECT company, SUM(total_laid_off) FROM layoffs_stage2 GROUP BY company ORDER BY SUM(total_laid_off) DESC LIMIT 10;

-- Locations with the most total layoffs
SELECT location, SUM(total_laid_off) FROM layoffs_stage2 GROUP BY location ORDER BY SUM(total_laid_off) DESC LIMIT 10;

-- Total layoffs by country
SELECT country, SUM(total_laid_off) FROM layoffs_stage2 GROUP BY country ORDER BY SUM(total_laid_off) DESC;

-- Total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off) FROM layoffs_stage2 GROUP BY YEAR(`date`) ORDER BY YEAR(`date`) ASC;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) FROM layoffs_stage2 GROUP BY industry ORDER BY SUM(total_laid_off) DESC;

-- Total layoffs by stage
SELECT stage, SUM(total_laid_off) FROM layoffs_stage2 GROUP BY stage ORDER BY SUM(total_laid_off) DESC;

-- Companies with the most layoffs per year
WITH Company_Year AS (
    SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_stage2
    GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS (
    SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3 AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Rolling total of layoffs per month
WITH DATE_CTE AS (
    SELECT SUBSTRING(`date`, 1, 7) AS dates, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_stage2
    GROUP BY dates
    ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
