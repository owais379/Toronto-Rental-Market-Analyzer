#==========================================
#    Toronto Rental Market Analysis
#==========================================

# 1. DATA VALIDATION
use toronto_rental;

SELECT COUNT(*) AS total_rows
FROM clean_rent_data;
# Check shows CSV rows matches how many are loaded into SQL

# identify missing rent values
SELECT
    SUM(rent_2024 IS NULL) AS missing_rent_2024,
    SUM(rent_2025 IS NULL) AS missing_rent_2025
FROM clean_rent_data;

#==========================================

# 2. RENTAL MARKET ANALYSIS

# Market overview
SELECT
    ROUND(AVG(rent_2025), 2) AS average_rent,
    MIN(rent_2025) AS lowest_rent,
    MAX(rent_2025) AS highest_rent,
    COUNT(rent_2025) AS observations
FROM clean_rent_data;

# Average rent by bedroom type
SELECT
    bedroom_type,
    ROUND(AVG(rent_2025), 2) AS average_rent
FROM clean_rent_data
WHERE rent_2025 IS NOT NULL
GROUP BY bedroom_type
ORDER BY average_rent;


# Top 5 most expensive areas for 1-bedroom units
SELECT
    area,
    rent_2025
FROM clean_rent_data
WHERE bedroom_type = '1 Bedroom'
ORDER BY rent_2025 DESC
LIMIT 5;

# Ranking zones with each bedroom type based on price
SELECT
    area,
    bedroom_type,
    rent_2025,
    RANK() OVER (
        PARTITION BY bedroom_type
        ORDER BY rent_2025 DESC
    ) AS rent_rank
FROM clean_rent_data
WHERE rent_2025 IS NOT NULL;



# Compare each zone's 1-bedroom rent to the average 1-bedroom rent
SELECT
    area,
    rent_2025,
    ROUND(AVG(rent_2025) OVER (), 2) AS average_rent,
    ROUND(
        rent_2025 - AVG(rent_2025) OVER (),
        2
    ) AS difference_from_average
FROM clean_rent_data
WHERE bedroom_type = '1 Bedroom'
  AND rent_2025 IS NOT NULL
ORDER BY difference_from_average DESC;

# Compare 1 bedroom cost vs 2 bedroom cost and upgrade premium as a percent
SELECT
    a.area,
    a.rent_2025 AS one_bedroom_rent,
    b.rent_2025 AS two_bedroom_rent,
    b.rent_2025 - a.rent_2025 AS additional_monthly_cost,
    ROUND(
        ((b.rent_2025 - a.rent_2025) / a.rent_2025) * 100,
        2
    ) AS upgrade_premium_pct
FROM clean_rent_data a
JOIN clean_rent_data b
    ON a.zone = b.zone
WHERE a.bedroom_type = '1 Bedroom'
  AND b.bedroom_type = '2 Bedroom'
ORDER BY upgrade_premium_pct DESC;

# Largest year-over-year rent changes from 2024 to 2025
SELECT
    area,
    bedroom_type,
    rent_2024,
    rent_2025,
    rent_2025 - rent_2024 AS dollar_change,
    ROUND(
        ((rent_2025 - rent_2024) / rent_2024) * 100,
        2
    ) AS percent_change
FROM clean_rent_data
WHERE rent_2024 IS NOT NULL
  AND rent_2025 IS NOT NULL
ORDER BY percent_change DESC;

#==========================================

# 3. VACANCY MARKET ANALYSIS

# Market overview
SELECT
    ROUND(AVG(vacancy_2025), 2) AS average_vacancy_rate,
    MIN(vacancy_2025) AS lowest_vacancy_rate,
    MAX(vacancy_2025) AS highest_vacancy_rate,
    COUNT(vacancy_2025) AS observations
FROM clean_vacancy;


# Average vacancy rate by bedroom type
SELECT
    bedroom_type,
    ROUND(AVG(vacancy_2025), 2) AS average_vacancy_rate
FROM clean_vacancy
WHERE vacancy_2025 IS NOT NULL
GROUP BY bedroom_type
ORDER BY average_vacancy_rate DESC;


# Rank zones by 2025 1-bedroom vacancy rate
SELECT
    area,
    vacancy_2025,
    RANK() OVER (
        ORDER BY vacancy_2025 DESC
    ) AS vacancy_rank
FROM clean_vacancy
WHERE bedroom_type = '1 Bedroom'
  AND vacancy_2025 IS NOT NULL
ORDER BY vacancy_rank;


# Largest changes in vacancy rate from 2024 to 2025 (percentage points)
SELECT
    area,
    bedroom_type,
    vacancy_2024,
    vacancy_2025,
    ROUND(vacancy_2025 - vacancy_2024, 2) AS vacancy_change
FROM clean_vacancy
WHERE vacancy_2024 IS NOT NULL
  AND vacancy_2025 IS NOT NULL
ORDER BY vacancy_change DESC;

#==========================================

# 4. RENT AND VACANCY ANALYSIS

# Combine 2025 rent and vacancy data
SELECT
    r.zone,
    r.area,
    r.bedroom_type,
    r.rent_2025,
    v.vacancy_2025
FROM clean_rent_data r
JOIN clean_vacancy v
    ON r.zone = v.zone
    AND r.bedroom_type = v.bedroom_type
WHERE r.rent_2025 IS NOT NULL
  AND v.vacancy_2025 IS NOT NULL
ORDER BY r.zone, r.bedroom_type;

# Compare 1-bedroom rent and vacancy rates by zone
SELECT
    r.area,
    r.rent_2025,
    v.vacancy_2025
FROM clean_rent_data r
JOIN clean_vacancy v
    ON r.zone = v.zone
    AND r.bedroom_type = v.bedroom_type
WHERE r.bedroom_type = '1 Bedroom'
  AND r.rent_2025 IS NOT NULL
  AND v.vacancy_2025 IS NOT NULL
ORDER BY r.rent_2025 DESC;

# Classify 1-bedroom rental market conditions
# Analytical categories created for this project;
# these are not official CMHC vacancy classifications.
SELECT
    r.area,
    r.rent_2025,
    v.vacancy_2025,
    CASE
        WHEN v.vacancy_2025 < 2 THEN 'Low Vacancy'
        WHEN v.vacancy_2025 < 4 THEN 'Moderate Vacancy'
        ELSE 'Higher Vacancy'
    END AS vacancy_category
FROM clean_rent_data r
JOIN clean_vacancy v
    ON r.zone = v.zone
    AND r.bedroom_type = v.bedroom_type
WHERE r.bedroom_type = '1 Bedroom'
  AND r.rent_2025 IS NOT NULL
  AND v.vacancy_2025 IS NOT NULL
ORDER BY v.vacancy_2025;














