-- HEART ATTACK ANALYSIS – SQL PROJECT
-- ---------------------------------------------

-- Table Structure
CREATE TABLE heart_data (
    age INTEGER,
    gender INTEGER, 
    heart_rate INTEGER,
    systolic_bp INTEGER,
    diastolic_bp INTEGER,
    blood_sugar NUMERIC,
    ckmb NUMERIC(5,2),
    troponin NUMERIC(5,3),
    result VARCHAR(15)
);



--Step 1 - Let's calculate the number and % of patient who had heart attack
SELECT 
  Result,
  COUNT(*) AS Count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS Percent
FROM heart_data
GROUP BY Result;

--Step 2 - Let's find out average biometrics by test result
SELECT 
  Result,
  ROUND(AVG("heart_rate"), 1)       AS avg_heart_rate,
  ROUND(AVG("blood_sugar"), 2)      AS avg_blood_sugar,
  ROUND(AVG("ckmb"), 2)            AS avg_ck_mb,
  ROUND(AVG(Troponin), 3)           AS avg_troponin
FROM heart_data
GROUP BY Result
ORDER BY Result;

--INSIGHT: Patients with positive resule (who got heart attack) have higher CK-MB and Troponin


--Step 3 - Patient Risk Classification by Biomarkers

WITH RiskScoring AS (
  SELECT *,
         CASE
           WHEN Troponin > 1 AND "ckmb" > 5 THEN 'Very High Risk'
           WHEN Troponin > 0.5 OR "ckmb" > 3 THEN 'Moderate Risk'
           ELSE 'Low Risk'
         END AS risk_level
  FROM heart_data
)
SELECT risk_level, Result, COUNT(*) AS count
FROM RiskScoring
GROUP BY risk_level, Result
ORDER BY risk_level;



-- Step 4 - Age Group Analysis of Heart Attack Patients
SELECT 
  CASE 
    WHEN Age < 30 THEN '0-30'
    WHEN Age BETWEEN 30 AND 49 THEN '30–49'
    WHEN Age BETWEEN 50 AND 69 THEN '50–69'
    ELSE '70+'
  END AS age_group,
  Result,
  COUNT(*) AS count
FROM heart_data
GROUP BY age_group, Result
ORDER BY age_group, Result;
--INSIGHT: Most heart attack (positive) patients fall in the 50–69 age group, confirming age as a major risk factor.


-- Step 5 - Blood Pressure Category vs Result
SELECT 
  CASE
    WHEN systolic_bp < 120 AND diastolic_bp < 80 THEN 'Normal'
    WHEN systolic_bp BETWEEN 120 AND 139 OR diastolic_bp BETWEEN 80 AND 89 THEN 'Prehypertension'
    WHEN systolic_bp BETWEEN 140 AND 159 OR diastolic_bp BETWEEN 90 AND 99 THEN 'Stage 1 Hypertension'
    ELSE 'Stage 2 Hypertension'
  END AS bp_category,
  result,
  COUNT(*) AS count
FROM heart_data
GROUP BY bp_category, result
ORDER BY bp_category, result;
--INSIGHT: Heart attacks occur across all blood pressure categories — even in 'Normal' blood pressure category


-- Step 6 - Heart attacks distribution by gender
SELECT 
  gender,
  result,
  COUNT(*) AS count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY gender), 2) AS percent_within_gender
FROM heart_data
GROUP BY gender, result
ORDER BY gender, result;
--INSIGHT: Heart attacks were more common among gender group 1, indicating a higher risk in that group.


-- Step 7 - High Blood Sugar Risk Group vs Result
SELECT 
  CASE 
    WHEN blood_sugar >= 200 THEN 'High Blood Sugar (>=200)'
    ELSE 'Normal/Controlled (<200)'
  END AS blood_sugar_status,
  result,
  COUNT(*) AS count
FROM heart_data
GROUP BY blood_sugar_status, result
ORDER BY blood_sugar_status, result;
--INSIGHT: Insight: Patients with high blood sugar (≥200) showed a greater number of heart attacks.


--Step 8 - Top 5 most critical cases based on Troponin levels
SELECT age, gender, troponin, ckmb, result
FROM heart_data
WHERE result = 'positive'
ORDER BY troponin DESC
LIMIT 5;

