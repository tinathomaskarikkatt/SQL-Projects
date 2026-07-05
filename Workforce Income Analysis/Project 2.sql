use Project_2;

select top 10 *
from Workforce;

--No.of employees working in different comapny size in the year 2021
SELECT company_size, COUNT(*) AS employee_count
FROM Workforce
WHERE work_year = 2021
GROUP BY company_size;
-- L=124
-- M=52
-- S=42

--Top 3 job titles with the highest average salary for part-time positions in 2023: 
WITH EligibleCountries AS (
    SELECT employee_residence
    FROM Workforce
    WHERE work_year = 2023
    GROUP BY employee_residence
    HAVING COUNT(*) > 50
)
SELECT TOP 3 job_title, AVG(salary_in_usd) AS avg_salary
FROM Workforce
WHERE employment_type = 'PT'
  AND work_year = 2023
  AND employee_residence IN (SELECT employee_residence FROM EligibleCountries)
GROUP BY job_title
ORDER BY avg_salary DESC;
--Data scientist with average salary 95650


SELECT job_title, COUNT(*) AS employee_count, AVG(salary_in_usd) AS avg_salary
FROM Workforce
WHERE employment_type = 'PT' AND work_year = 2023
GROUP BY job_title
ORDER BY employee_count DESC;

--Countries where mid-level salary is higher than the overall mid-level salary in 2023:
WITH Overall AS (
    SELECT AVG(salary_in_usd) AS global_avg
    FROM Workforce
    WHERE experience_level = 'MI' AND work_year = 2023
)
SELECT employee_residence, AVG(salary_in_usd) AS avg_mid_salary
FROM Workforce, Overall
WHERE experience_level = 'MI' AND work_year = 2023
GROUP BY employee_residence, global_avg
HAVING AVG(salary_in_usd) > global_avg;

-- SA,AU,CA,QA,US,TN

--Highest and lowest average salary locations for senior-level employees in 2023:
SELECT TOP 1 company_location, AVG(salary_in_usd) AS avg_salary
FROM Workforce
WHERE experience_level = 'SE' AND work_year = 2023
GROUP BY company_location
ORDER BY avg_salary DESC;  -- Highest
--IL-266468.5
SELECT TOP 1 company_location, AVG(salary_in_usd) AS avg_salary
FROM Workforce
WHERE experience_level = 'SE' AND work_year = 2023
GROUP BY company_location
ORDER BY avg_salary ASC;   -- Lowest
--TR-18381

--Salary growth percentage for each job title from 2023-->2024
SELECT j.job_title,
       ((s2024.avg_salary - s2023.avg_salary) * 100.0 / s2023.avg_salary) AS growth_rate_percent
FROM (
    SELECT job_title, AVG(salary_in_usd) AS avg_salary
    FROM Workforce
    WHERE work_year = 2023
    GROUP BY job_title
) s2023
JOIN (
    SELECT job_title, AVG(salary_in_usd) AS avg_salary
    FROM Workforce
    WHERE work_year = 2024
    GROUP BY job_title
) s2024
ON s2023.job_title = s2024.job_title
JOIN (SELECT DISTINCT job_title FROM Workforce) j
ON j.job_title = s2023.job_title;

--Top 3 countries with highest salary growth (Entry-level, 2020 → 2023)
WITH SalaryGrowth AS (
    SELECT employee_residence,
           ( (MAX(CASE WHEN work_year = 2023 THEN salary_in_usd END) -
              MAX(CASE WHEN work_year = 2020 THEN salary_in_usd END))
             * 100.0 / MAX(CASE WHEN work_year = 2020 THEN salary_in_usd END)) AS growth_rate
    FROM Workforce
    WHERE experience_level = 'EN'
    GROUP BY employee_residence
    HAVING COUNT(*) > 50
)
SELECT TOP 3 employee_residence, growth_rate
FROM SalaryGrowth
ORDER BY growth_rate DESC;
--US-40
--GB-NULL

--Remote work ratio update for employees earning more than $90,000 in the US and AU: 
UPDATE Workforce
SET remote_ratio = 100
WHERE salary_in_usd > 90000
AND employee_residence IN ('US', 'AU');
--10644 rows were updated

--Salary updates based on percentage increases by level in 2024
UPDATE Workforce
SET salary_in_usd = 
    CASE experience_level
        WHEN 'SE' THEN salary_in_usd * 1.22
        WHEN 'MI' THEN salary_in_usd * 1.30
        WHEN 'EN' THEN salary_in_usd * 1.35
        WHEN 'EX' THEN salary_in_usd * 1.15
        ELSE salary_in_usd
    END
WHERE work_year = 2024;
--3509 rows were updated

--Year with the highest average salary for each job title: 
SELECT job_title, work_year, avg_salary
FROM (
    SELECT job_title, work_year, AVG(salary_in_usd) AS avg_salary,
           ROW_NUMBER() OVER (PARTITION BY job_title ORDER BY AVG(salary_in_usd) DESC) AS rn
    FROM Workforce
    GROUP BY job_title, work_year
) t
WHERE rn = 1;

--Percentage of employment types for different job titles: 
SELECT 
    job_title,
    SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_fulltime,
    SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_parttime
FROM Workforce
GROUP BY job_title;


--Countries offering full remote work for managers with salaries > $90K
SELECT employee_residence, AVG(salary_in_usd) AS avg_salary
FROM Workforce
WHERE job_title LIKE '%Manager%'
  AND salary_in_usd > 90000
  AND remote_ratio = 100
GROUP BY employee_residence;


--Top 5 countires with the most larg comapanies
SELECT company_location, COUNT(*) AS large_company_count
FROM Workforce
WHERE company_size = 'L'
GROUP BY company_location
ORDER BY large_company_count DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--Percentage of employees with fully remote roles earning more than $100K: 
SELECT 
    (COUNT(CASE WHEN remote_ratio = 100 AND salary_in_usd > 100000 THEN 1 END) * 100.0) / COUNT(*) AS pct_remote_over_100k
FROM Workforce;
--74.99%

--Locations where entry-level average salaries exceed market average for entry level:
WITH OverallAvg AS (
    SELECT AVG(salary_in_usd) AS market_avg
    FROM Workforce
    WHERE experience_level = 'EN'
)
SELECT company_location, AVG(salary_in_usd) AS avg_entry_salary
FROM Workforce, OverallAvg
WHERE experience_level = 'EN'
GROUP BY company_location, market_avg
HAVING AVG(salary_in_usd) > market_avg;
--

--Countries paying the maximum average salary for each job title
SELECT job_title, employee_residence, avg_salary
FROM (
    SELECT job_title, employee_residence, AVG(salary_in_usd) AS avg_salary,
           ROW_NUMBER() OVER (PARTITION BY job_title ORDER BY AVG(salary_in_usd) DESC) AS rn
    FROM Workforce
    GROUP BY job_title, employee_residence
) t
WHERE rn = 1;

--Countries with sustained salary growth over 3 years
WITH YearlyAvg AS (
    SELECT employee_residence, work_year, AVG(salary_in_usd) AS avg_salary
    FROM Workforce
    GROUP BY employee_residence, work_year
),
GrowthCheck AS (
    SELECT employee_residence,
           MIN(work_year) AS start_year,
           MAX(work_year) AS end_year,
           COUNT(DISTINCT work_year) AS year_count
    FROM YearlyAvg
    GROUP BY employee_residence
)
SELECT y.employee_residence
FROM YearlyAvg y
JOIN GrowthCheck g ON y.employee_residence = g.employee_residence
WHERE g.year_count >= 3
GROUP BY y.employee_residence
HAVING MIN(avg_salary) < MAX(avg_salary);

--Percentage of fully remote work by experience level (2021 vs 2024)
SELECT work_year, experience_level,
       SUM(CASE WHEN remote_ratio = 100 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_remote
FROM Workforce
WHERE work_year IN (2021, 2024)
GROUP BY work_year, experience_level
ORDER BY experience_level, work_year;

--Average salary increase percentage by experience level and job title (2023 → 2024)
WITH avg2023 AS (
    SELECT job_title, experience_level, AVG(salary_in_usd) AS avg_salary_2023
    FROM Workforce
    WHERE work_year = 2023
    GROUP BY job_title, experience_level
),
avg2024 AS (
    SELECT job_title, experience_level, AVG(salary_in_usd) AS avg_salary_2024
    FROM Workforce
    WHERE work_year = 2024
    GROUP BY job_title, experience_level
)
SELECT a23.job_title, a23.experience_level,
       ((a24.avg_salary_2024 - a23.avg_salary_2023) * 100.0 / a23.avg_salary_2023) AS salary_growth_pct
FROM avg2023 a23
JOIN avg2024 a24
  ON a23.job_title = a24.job_title
 AND a23.experience_level = a24.experience_level
ORDER BY salary_growth_pct DESC;


--Role-based access control for employees based on experience level
-- Vieew for Mid-level employees (MI)
CREATE VIEW MI_Employee_View AS
SELECT *
FROM Workforce
WHERE experience_level = 'MI';

-- View for Entry-level employees
CREATE VIEW EN_Employee_View AS
SELECT *
FROM Workforce
WHERE experience_level = 'EN';

-- View for Senior employees
CREATE VIEW SE_Employee_View AS
SELECT *
FROM Workforce
WHERE experience_level = 'SE';

--Guiding clients in switching domains based on salary insights

WITH avg_salaries AS (
    SELECT experience_level, job_title, AVG(CAST(salary_in_usd AS FLOAT)) AS avg_salary
    FROM Workforce
    GROUP BY experience_level, job_title
),
ranked AS (
    SELECT
        a1.experience_level,
        a1.job_title  AS current_role,
        a1.avg_salary AS current_avg_salary,
        a2.job_title  AS suggested_role,
        a2.avg_salary AS suggested_avg_salary,
        (a2.avg_salary - a1.avg_salary) AS delta_usd,
        ROW_NUMBER() OVER (
            PARTITION BY a1.experience_level, a1.job_title
            ORDER BY (a2.avg_salary - a1.avg_salary) DESC
        ) AS rn
    FROM avg_salaries a1
    JOIN avg_salaries a2
      ON a1.experience_level = a2.experience_level
     AND a1.job_title <> a2.job_title
     AND a2.avg_salary > a1.avg_salary
)
SELECT experience_level, current_role, current_avg_salary,
       suggested_role, suggested_avg_salary, delta_usd
FROM ranked
WHERE rn <= 3
ORDER BY delta_usd DESC;



















