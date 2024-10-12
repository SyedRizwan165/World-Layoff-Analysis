# Layoffs Database Project

This project involves the design, setup, and analysis of a database to track layoff events across companies, industries, and locations. The database, `layoffs`, stores structured information on layoffs to support data-driven analysis. The project includes an initial raw data table (`layoffs`), a staging table for data cleaning (`layoffs_stage`), and a refined table for analysis (`layoffs_stage2`). The main focus is on deduplication, data standardization, handling null values, and performing exploratory data analysis (EDA) for insights into trends in layoffs.

## Project Structure

### Database Setup
1. **Database Creation**: Initializes the `layoffs` database.
2. **Table Creation**:
   - **`layoffs`**: Stores the main data on layoffs, including columns for company, location, industry, layoffs count, percentage laid off, date, stage, country, and funds raised.
   - **`layoffs_stage`**: Staging table created to facilitate data cleaning without altering raw data.
3. **Data Transfer**: Copies data from `layoffs` to `layoffs_stage` for cleaning and processing.

### Data Cleaning
1. **Duplicate Removal**: Identifies and removes duplicate records to ensure data integrity.
   - Utilizes `ROW_NUMBER()` with `PARTITION BY` on key attributes to find duplicates.
   - Deletes duplicate rows in the staging table to retain only unique records.
2. **Standardization**:
   - Cleans and standardizes values in the `industry` and `country` columns, including handling nulls and harmonizing variations.
   - Converts date strings to proper DATE format (`YYYY-MM-DD`).
3. **Null Handling**:
   - Fills missing `industry` values based on matching company names.
   - Removes records where both `total_laid_off` and `percentage_laid_off` are null.

### Exploratory Data Analysis (EDA)
The database structure allows for flexible queries, enabling insights into layoff trends across various dimensions:

1. **Key Metrics**:
   - **Maximum Layoffs**: Finds the highest single layoff count.
   - **Percentage Range**: Computes the range of layoff percentages.
   - **100% Layoffs**: Identifies companies with a complete workforce reduction.
2. **Layoffs by Category**:
   - **Top Companies**: Lists companies with the highest total layoffs.
   - **Top Locations and Countries**: Aggregates layoffs by location and country.
   - **Annual Totals**: Summarizes layoffs per year, by industry and company stage.
3. **Trends and Rankings**:
   - **Companies with Most Layoffs per Year**: Ranks companies by layoffs annually.
   - **Rolling Monthly Totals**: Shows cumulative layoffs over time, aggregated monthly.

## Usage
These queries provide structured data analysis on layoffs, allowing users to explore:
- Companies and locations with the most layoffs.
- Trends in layoffs by industry, date, and funding stage.
- Aggregated totals by location, industry, and over time.

## Future Improvements
1. **Data Enrichment**: Integrate external data such as economic indicators or sector-specific factors.
2. **Visualization Tools**: Use Power BI or Tableau to create visual dashboards for an intuitive overview of layoff trends.
3. **Automation**: Schedule regular data imports to keep the database up to date with recent layoff events. 

This project provides a comprehensive framework for analyzing layoffs across multiple dimensions, supporting HR professionals, economic analysts, and business leaders with actionable insights into workforce trends.







