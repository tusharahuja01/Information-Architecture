-- Trigger Alert -------------------------------------------

DELIMITER $$
CREATE TRIGGER trg_check_adverse_interaction
AFTER INSERT ON prescriptions
FOR EACH ROW
BEGIN
    DECLARE prev_drug VARCHAR(100);
    DECLARE done INT DEFAULT 0;

    -- Cursor to find all previously prescribed drugs for the same patient
    DECLARE cur CURSOR FOR
        SELECT drug_name
        FROM prescriptions
        WHERE patient_id = NEW.patient_id
          AND date < NEW.date;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO prev_drug;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if there is an adverse interaction between NEW drug and previous one
        IF EXISTS (
            SELECT 1
            FROM adverse_interactions
            WHERE (drug_name_1 = NEW.drug_name AND drug_name_2 = prev_drug)
               OR (drug_name_2 = NEW.drug_name AND drug_name_1 = prev_drug)
        ) THEN
            -- Insert into alerts table
            INSERT INTO alerts (patient_id, physician_id, alert_date, drug1, drug2)
            VALUES (NEW.patient_id, NEW.physician_id, NEW.date, prev_drug, NEW.drug_name);
        END IF;

    END LOOP;

    CLOSE cur;
END$$
DELIMITER ;

-- To test if it works:--------------------------------------


-- Test: 1
INSERT INTO prescriptions (id, patient_id, physician_id, drug_name, date, quantity)
VALUES (17, '501-47-2038', '156-28-1945', 'Kanulin', '2023-10-01', 10);

SELECT * FROM alerts WHERE patient_id = '501-47-2038' ORDER BY alert_date DESC;


 -- Test 2: Insert with Interaction

-- Patient has already been prescribed Avafoxin (check this exists in prescriptions)
INSERT INTO prescriptions (id, patient_id, physician_id, drug_name, date, quantity)
VALUES (18, '501-47-2038', '156-28-1945', 'Kanulin', '2023-10-03', 20);

SELECT * FROM alerts WHERE patient_id = '501-47-2038' AND drug2 = 'Kanulin';


-- Test 3: Insert without Interaction

INSERT INTO prescriptions (id, patient_id, physician_id, drug_name, date, quantity)
VALUES (19, '478-34-0781', '614-57-6885', 'Olanzanafine', '2023-10-04', 25);

SELECT * FROM alerts WHERE patient_id = '478-34-0781' AND drug2 = 'Olanzanafine';


-- Test 4: Reverse Drug Order
INSERT INTO prescriptions (id, patient_id, physician_id, drug_name, date, quantity)
VALUES (20, '501-47-2038', '156-28-1945', 'Avafoxin', '2023-10-05', 10);

SELECT *
FROM alerts
WHERE patient_id = '501-47-2038'
  AND (drug1 = 'Kanulin' AND drug2 = 'Avafoxin')
   OR (drug1 = 'Avafoxin' AND drug2 = 'Kanulin');



-- Test 5: Multiple Prior Interactions
INSERT INTO prescriptions (id, patient_id, physician_id, drug_name, date, quantity)
VALUES (21, '501-47-2038', '156-28-1945', 'Cleotrana', '2023-10-06', 15);

SELECT *
FROM alerts
WHERE patient_id = '501-47-2038'
  AND drug2 = 'Cleotrana'
  AND drug1 IN ('Avafoxin', 'Quixiposide');
