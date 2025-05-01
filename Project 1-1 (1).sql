CREATE DATABASE MedicalPractice;
USE MedicalPractice;

-- 1. Patients Table

CREATE TABLE Patients (
    ssn VARCHAR(15) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    birth_date DATE NOT NULL,
    primary_physician_ssn VARCHAR(15),
    FOREIGN KEY (primary_physician_ssn) REFERENCES Physicians(ssn) ON DELETE SET NULL
);

-- 2. Physicians Table

CREATE TABLE Physicians (
    ssn VARCHAR(15) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    primary_specialty VARCHAR(100) NOT NULL,
    years_experience INT CHECK (years_experience >= 0)
);

-- 3. Pharmacies Table

CREATE TABLE Pharmacies (
    pharmacy_id INT AUTO_INCREMENT PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);


-- 4. Drugs Table

CREATE TABLE Drugs (
    generic_name VARCHAR(100) PRIMARY KEY
);

-- 5. Prescriptions Table

CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_ssn VARCHAR(15),
    physician_ssn VARCHAR(15),
    drug_name VARCHAR(100),
    prescription_date DATE NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (patient_ssn) REFERENCES Patients(ssn) ON DELETE CASCADE,
    FOREIGN KEY (physician_ssn) REFERENCES Physicians(ssn) ON DELETE CASCADE,
    FOREIGN KEY (drug_name) REFERENCES Drugs(generic_name) ON DELETE CASCADE
);

-- 6. Adverse Interactions Table

CREATE TABLE Adverse_Interactions (
    drug1 VARCHAR(100),
    drug2 VARCHAR(100),
    PRIMARY KEY (drug1, drug2),
    FOREIGN KEY (drug1) REFERENCES Drugs(generic_name) ON DELETE CASCADE,
    FOREIGN KEY (drug2) REFERENCES Drugs(generic_name) ON DELETE CASCADE
);

 -- 7. Alerts Table
 
 CREATE TABLE Alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_ssn VARCHAR(15),
    patient_name VARCHAR(100),
    primary_physician_ssn VARCHAR(15),
    alert_date DATE NOT NULL DEFAULT (CURDATE()),
    drug_name VARCHAR(100),
    FOREIGN KEY (patient_ssn) REFERENCES Patients(ssn) ON DELETE CASCADE,
    FOREIGN KEY (primary_physician_ssn) REFERENCES Physicians(ssn) ON DELETE CASCADE,
    FOREIGN KEY (drug_name) REFERENCES Drugs(generic_name) ON DELETE CASCADE
);

 -- 8. Fills Table (Records Prescription Filling)
 
 CREATE TABLE Fills (
    fill_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT,
    pharmacy_id INT,
    fill_date DATE NOT NULL,
    cost DECIMAL(10,2) CHECK (cost >= 0),
    FOREIGN KEY (prescription_id) REFERENCES Prescriptions(prescription_id) ON DELETE CASCADE,
    FOREIGN KEY (pharmacy_id) REFERENCES Pharmacies(pharmacy_id) ON DELETE CASCADE
);

 -- 9. Pharmaceutical Companies Table
 
 CREATE TABLE Pharmaceutical_Companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact_name VARCHAR(100),
    contact_phone VARCHAR(20)
);

 -- 10. Contracts Table
 
 CREATE TABLE Contracts (
    contract_number INT AUTO_INCREMENT PRIMARY KEY,
    drug_name VARCHAR(100),
    dosage_mg DECIMAL(10,2),
    pharmacy_id INT,
    company_id INT,
    quantity INT CHECK (quantity > 0),
    contract_date DATE NOT NULL,
    FOREIGN KEY (drug_name) REFERENCES Drugs(generic_name) ON DELETE CASCADE,
    FOREIGN KEY (pharmacy_id) REFERENCES Pharmacies(pharmacy_id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES Pharmaceutical_Companies(company_id) ON DELETE CASCADE
);

--  Verify the Schema

SHOW TABLES;
