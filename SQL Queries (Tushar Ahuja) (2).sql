-- Task 2: SQL Queries for Healthcare Database

Show Databases;
SHOW TABLES;

-- ️1. Physicians (ssn) who have most prescribed drugs that caused alerts

SELECT pr.physician_id, COUNT(*) AS alert_count
FROM prescriptions pr
JOIN alerts a ON pr.patient_id = a.patient_id 
             AND pr.drug_name = a.drug2 
             AND pr.date = a.alert_date
GROUP BY pr.physician_id
ORDER BY alert_count DESC;


-- 2. Physicians (ssn) who prescribed two drugs to the same patient which have adverse interactions

SELECT DISTINCT p1.physician_id
FROM prescriptions p1
JOIN prescriptions p2 
  ON p1.patient_id = p2.patient_id
 AND p1.physician_id = p2.physician_id
 AND p1.drug_name < p2.drug_name
JOIN adverse_interactions ai 
  ON (p1.drug_name = ai.drug_name_1 AND p2.drug_name = ai.drug_name_2)
  OR (p1.drug_name = ai.drug_name_2 AND p2.drug_name = ai.drug_name_1);
  
  

-- 3. Physicians who have prescribed the most drugs supplied by company DRUGXO

SELECT pr.physician_id, COUNT(*) AS total_prescribed
FROM prescriptions pr
JOIN contracts c ON pr.drug_name = c.drug_name
JOIN companies co ON co.id = c.company_id
WHERE co.name = 'DRUGXO'
GROUP BY pr.physician_id
ORDER BY total_prescribed DESC;


-- 4. Price per unit from PHARMASEE and avg price per unit by any company

SELECT 
    c.drug_name,
    ROUND(c.price / c.quantity, 2) AS pharmasee_unit_price,
    ROUND((
        SELECT AVG(c2.price / c2.quantity)
        FROM contracts c2
        WHERE c2.drug_name = c.drug_name
    ), 2) AS avg_unit_price
FROM contracts c
JOIN companies co ON co.id = c.company_id
WHERE co.name = 'PHARMASEE';


-- 5. Drug markup percentage (per unit) at each pharmacy

SELECT 
    pf.pharmacy_id,
    pr.drug_name,
    ROUND(
        100 * ((pf.cost / pr.quantity) - (c.price / c.quantity)) / (c.price / c.quantity),
        2
    ) AS markup_percentage
FROM pharmacy_fills pf
JOIN prescriptions pr ON pf.prescription_id = pr.id
JOIN contracts c 
  ON c.drug_name = pr.drug_name AND c.pharmacy_id = pf.pharmacy_id;
  
SELECT 
    pr.drug_name, 
    pf.pharmacy_id, 
    c.pharmacy_id
FROM pharmacy_fills pf
JOIN prescriptions pr ON pf.prescription_id = pr.id
JOIN contracts c 
  ON pr.drug_name = c.drug_name 
 AND pf.pharmacy_id = c.pharmacy_id;






-- 6. Avg time between prescription date and pharmacy fill date (in days)


SELECT 
    p.drug_name,
    ROUND(AVG(DATEDIFF(f.date, p.date)), 2) AS avg_days_to_fill
FROM prescriptions p
JOIN pharmacy_fills f 
    ON p.id = f.prescription_id
WHERE f.date >= p.date  -- Optional: to exclude negative or invalid cases
GROUP BY p.drug_name
ORDER BY avg_days_to_fill DESC;



-- 7. Drugs prescribed to patients but never filled at a specific pharmacy

SELECT 
    pr.drug_name,
    COUNT(*) AS not_filled_count
FROM pharmacies ph
JOIN prescriptions pr
WHERE NOT EXISTS (
    SELECT 1
    FROM pharmacy_fills pf
    WHERE pf.prescription_id = pr.id AND pf.pharmacy_id = ph.id
)
GROUP BY pr.drug_name
ORDER BY not_filled_count DESC;






    -- Extra Queries Practice (For verifying Results)

SELECT 
    ph.id AS pharmacy_id,
    p.drug_name,
    COUNT(*) AS unfilled_prescriptions
FROM prescriptions p
JOIN pharmacies ph ON ph.id = 5
LEFT JOIN pharmacy_fills pf 
    ON pf.prescription_id = p.id AND pf.pharmacy_id = ph.id
WHERE pf.prescription_id IS NULL
GROUP BY ph.id, p.drug_name
ORDER BY unfilled_prescriptions DESC;



SELECT DISTINCT pr.drug_name, ph.id AS pharmacy_id
FROM pharmacies ph
JOIN prescriptions pr
WHERE NOT EXISTS (
    SELECT 1
    FROM pharmacy_fills pf
    WHERE pf.prescription_id = pr.id AND pf.pharmacy_id = ph.id
);

SELECT 
    pr.id AS prescription_id,
    pr.drug_name,
    pr.patient_id,
    pr.physician_id
FROM prescriptions pr
WHERE NOT EXISTS (
    SELECT 1
    FROM pharmacy_fills pf
    WHERE pf.prescription_id = pr.id
);

SELECT COUNT(*) FROM prescriptions;

SELECT COUNT(DISTINCT prescription_id) FROM pharmacy_fills;


SELECT 
    pr.drug_name,
    COUNT(*) AS not_filled_count
FROM pharmacies ph
JOIN prescriptions pr
WHERE NOT EXISTS (
    SELECT 1
    FROM pharmacy_fills pf
    WHERE pf.prescription_id = pr.id AND pf.pharmacy_id = ph.id
)
GROUP BY pr.drug_name
ORDER BY not_filled_count DESC;




SELECT p1.physician_id, p1.patient_id, p1.drug_name AS drug1, p2.drug_name AS drug2
FROM prescriptions p1
JOIN prescriptions p2 
  ON p1.patient_id = p2.patient_id
 AND p1.physician_id = p2.physician_id
 AND p1.drug_name < p2.drug_name
JOIN adverse_interactions ai 
  ON (p1.drug_name = ai.drug_name_1 AND p2.drug_name = ai.drug_name_2)
  OR (p1.drug_name = ai.drug_name_2 AND p2.drug_name = ai.drug_name_1)
ORDER BY p1.physician_id;

SELECT DISTINCT
    p1.physician_id,
    p1.patient_id,
    LEAST(p1.drug_name, p2.drug_name) AS drug1,
    GREATEST(p1.drug_name, p2.drug_name) AS drug2
FROM prescriptions p1
JOIN prescriptions p2 
  ON p1.patient_id = p2.patient_id
 AND p1.physician_id = p2.physician_id
 AND p1.drug_name <> p2.drug_name
JOIN adverse_interactions ai 
  ON (p1.drug_name = ai.drug_name_1 AND p2.drug_name = ai.drug_name_2)
  OR (p1.drug_name = ai.drug_name_2 AND p2.drug_name = ai.drug_name_1)
ORDER BY physician_id;



SELECT 
    pr.drug_name,
    pf.pharmacy_id,
    ROUND(AVG(pf.cost / pr.quantity), 6) AS price_per_unit_pharmacy,
    ROUND(AVG(c.price / c.quantity), 6) AS price_per_unit_company,
    ROUND(
        100 * (AVG(pf.cost / pr.quantity) - AVG(c.price / c.quantity)) / AVG(c.price / c.quantity),
        10
    ) AS markup_percentage
FROM pharmacy_fills pf
JOIN prescriptions pr ON pf.prescription_id = pr.id
JOIN contracts c 
  ON c.drug_name = pr.drug_name AND c.pharmacy_id = pf.pharmacy_id
GROUP BY pr.drug_name, pf.pharmacy_id
ORDER BY markup_percentage DESC;

SELECT pr.drug_name, pf.pharmacy_id, COUNT(*) AS num_fills
FROM prescriptions pr
JOIN pharmacy_fills pf ON pf.prescription_id = pr.id
GROUP BY pr.drug_name, pf.pharmacy_id;

SELECT DISTINCT drug_name, pharmacy_id FROM contracts;

SELECT DISTINCT pr.drug_name, pf.pharmacy_id
FROM prescriptions pr
JOIN pharmacy_fills pf ON pr.id = pf.prescription_id
WHERE NOT EXISTS (
    SELECT 1
    FROM contracts c
    WHERE c.drug_name = pr.drug_name
      AND c.pharmacy_id = pf.pharmacy_id
);

SELECT DISTINCT pr.drug_name, pf.pharmacy_id
FROM prescriptions pr
JOIN pharmacy_fills pf ON pr.id = pf.prescription_id
WHERE NOT EXISTS (
    SELECT 1
    FROM contracts c
    WHERE c.drug_name = pr.drug_name
      AND c.pharmacy_id = pf.pharmacy_id
);

SELECT 
    pr.drug_name,
    pf.pharmacy_id,
    ROUND(pf.cost / pr.quantity, 6) AS price_per_unit_pharmacy,
    ROUND(c.price / c.quantity, 6) AS price_per_unit_company,
    ROUND(
        100 * ((pf.cost / pr.quantity) - (c.price / c.quantity)) / (c.price / c.quantity),
        2
    ) AS markup_percentage
FROM pharmacy_fills pf
JOIN prescriptions pr ON pf.prescription_id = pr.id
LEFT JOIN contracts c 
  ON c.drug_name = pr.drug_name AND c.pharmacy_id = pf.pharmacy_id;
  
SELECT 
    c.drug_name,
    c.pharmacy_id,
    ROUND(SUM(pf.cost) / SUM(pr.quantity), 6) AS price_per_unit_pharmacy,
    ROUND(c.price / c.quantity, 6) AS price_per_unit_company,
    ROUND(
        100 * ((SUM(pf.cost) / SUM(pr.quantity)) - (c.price / c.quantity)) / (c.price / c.quantity),
        10
    ) AS markup_percentage
FROM contracts c
JOIN prescriptions pr ON c.drug_name = pr.drug_name
JOIN pharmacy_fills pf ON pr.id = pf.prescription_id AND pf.pharmacy_id = c.pharmacy_id
GROUP BY c.drug_name, c.pharmacy_id, c.price, c.quantity
ORDER BY c.drug_name, c.pharmacy_id;



SELECT 
    pr.drug_name,
    pf.pharmacy_id,
    ROUND(AVG(pf.cost / pr.quantity), 6) AS price_per_unit_pharmacy,
    ROUND(AVG(c.price / c.quantity), 6) AS price_per_unit_company,
    ROUND(
        100 * (AVG(pf.cost / pr.quantity) - AVG(c.price / c.quantity)) / AVG(c.price / c.quantity),
        10
    ) AS markup_percentage
FROM pharmacy_fills pf
JOIN prescriptions pr ON pf.prescription_id = pr.id
JOIN contracts c 
  ON pr.drug_name = c.drug_name AND pf.pharmacy_id = c.pharmacy_id
GROUP BY pr.drug_name, pf.pharmacy_id
ORDER BY markup_percentage DESC;

SELECT DISTINCT pr.drug_name, pf.pharmacy_id
FROM prescriptions pr
JOIN pharmacy_fills pf ON pf.prescription_id = pr.id
ORDER BY pr.drug_name, pf.pharmacy_id;

SELECT DISTINCT drug_name, pharmacy_id
FROM contracts
ORDER BY drug_name, pharmacy_id;

SELECT DISTINCT pr.drug_name, pf.pharmacy_id
FROM prescriptions pr
JOIN pharmacy_fills pf ON pf.prescription_id = pr.id
WHERE NOT EXISTS (
    SELECT 1 FROM contracts c 
    WHERE c.drug_name = pr.drug_name 
      AND c.pharmacy_id = pf.pharmacy_id
);



SELECT 
    pr.drug_name,
    ROUND(AVG(DATEDIFF(pf.date, pr.date)), 2) AS avg_days_to_fill
FROM prescriptions pr
JOIN pharmacy_fills pf ON pf.prescription_id = pr.id
GROUP BY pr.drug_name;

SELECT 
    pr.id AS prescription_id,
    pr.drug_name,
    pr.date AS prescribed_date,
    pf.date AS filled_date,
    DATEDIFF(pf.date, pr.date) AS days_between
FROM prescriptions pr
JOIN pharmacy_fills pf ON pf.prescription_id = pr.id
ORDER BY days_between DESC;

SELECT 
    pr.drug_name,
    ROUND(AVG(DATEDIFF(pf.date, pr.date)), 2) AS avg_days_to_fill
FROM prescriptions pr
JOIN pharmacy_fills pf ON pf.prescription_id = pr.id
WHERE pf.date >= pr.date
GROUP BY pr.drug_name;


