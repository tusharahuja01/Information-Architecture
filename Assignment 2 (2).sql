--------------------------- Assignment 1 -------------------------------

SELECT * FROM ADVISOR LIMIT 5;

SELECT * FROM CLASSROOM LIMIT 5;

SELECT * FROM COURSE LIMIT 5;

SELECT * FROM DEPARTMENT LIMIT 5;

SELECT * FROM INSTRUCTOR LIMIT 5;

SELECT * FROM PREREQ LIMIT 5;

SELECT * FROM STUDENT LIMIT 5;

---------------------------- Assignment 2 --------------------------------

---- Part 1: Create tables and Insert values in it (We used Table Data Import Wizard to load the data here)

-- time slot table --
CREATE TABLE IF NOT EXISTS time_slot (
    time_slot_id INT AUTO_INCREMENT PRIMARY KEY,
    day_of_week VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    UNIQUE (day_of_week, start_time, end_time)  -- Ensuring that each time slot is unique
);

Select * from time_slot order by time_slot_id asc;




-- section table --
CREATE TABLE IF NOT EXISTS section (
    course_id VARCHAR(10),  -- Ensure the type matches with the course_id in course table
    sec_id INT,
    semester VARCHAR(20),
    year INT NOT NULL,
    building VARCHAR(50) NULL,
    room_no VARCHAR(10) NULL,
    time_slot_id INT DEFAULT NULL,
    PRIMARY KEY (course_id, sec_id, semester, year),
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,  -- Foreign Key references course_id
    FOREIGN KEY (time_slot_id) REFERENCES time_slot(time_slot_id) ON DELETE CASCADE
);

Select * from section;




-- teaches table --
CREATE TABLE IF NOT EXISTS teaches (
    instructor_id VARCHAR(128) NOT NULL,  -- Foreign Key referencing the instructor's ID (matching VARCHAR(128))
    course_id VARCHAR(10),  -- Foreign Key referencing course_id in section table
    sec_id INT NOT NULL,  -- Foreign Key referencing sec_id in section table
    semester VARCHAR(20) NOT NULL,  -- Foreign Key referencing semester in section table
    year INT NOT NULL,  -- Foreign Key referencing year in section table
    PRIMARY KEY (instructor_id, course_id, sec_id, semester, year),
    FOREIGN KEY (instructor_id) REFERENCES instructor(ID) ON DELETE CASCADE,  -- Ensure matching data type VARCHAR(128)
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section(course_id, sec_id, semester, year) ON DELETE CASCADE  -- Section references course_id and other details in section table
);

Select * from teaches;





-- takes table --
CREATE TABLE IF NOT EXISTS takes (
    student_id VARCHAR(128) NOT NULL,  -- Foreign Key referencing the student's ID (matching VARCHAR(128))
    course_id VARCHAR(10) NOT NULL,    -- Foreign Key referencing course_id in section table
    sec_id INT NOT NULL,               -- Foreign Key referencing sec_id in section table
    semester VARCHAR(20) NOT NULL,     -- Foreign Key referencing semester in section table
    year INT NOT NULL,                 -- Foreign Key referencing year in section table
    grade VARCHAR(5),                  -- Optional grade column (can be NULL)
    PRIMARY KEY (student_id, course_id, sec_id, semester, year),
    FOREIGN KEY (student_id) REFERENCES student(ID) ON DELETE CASCADE,  -- Ensure matching data type VARCHAR(128)
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section(course_id, sec_id, semester, year) ON DELETE CASCADE  -- Section references course_id and other details in section table
);

Select * from takes;





---- Part 2: Answer the questions 

--- Question: 1
SELECT c.course_id AS id, 
       c.title, 
       s.sec_id AS section_id
FROM course c
JOIN section s ON c.course_id = s.course_id
JOIN teaches t ON s.course_id = t.course_id 
               AND s.sec_id = t.sec_id
               AND s.semester = 'Fall' 
               AND s.year = 2023;
               
               


--- Question: 2
SELECT c.course_id AS id, 
       c.title, 
       s.sec_id AS section_id, 
       i.name AS instructor_name
FROM course c
JOIN section s ON c.course_id = s.course_id
JOIN teaches t ON s.course_id = t.course_id 
               AND s.sec_id = t.sec_id
               AND s.semester = 'Fall' 
               AND s.year = 2023
JOIN instructor i ON t.instructor_id = i.ID;


--- Question: 3
UPDATE section
SET time_slot_id = 2
WHERE time_slot_id = 6;

SELECT course_id, sec_id, semester, year, time_slot_id
FROM section
WHERE time_slot_id = 2;

Select * from section;




--- Question: 4
SELECT c.course_id, 
       c.title, 
       s.sec_id AS section, 
       ts.start_time
FROM course c
JOIN section s ON c.course_id = s.course_id
JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id
WHERE s.semester = 'Fall' 
  AND s.year = 2022;
  
  
  
  

--- Question: 5  
UPDATE takes
SET grade = 'A'
WHERE student_id IN ('1238', '1333')
  AND (grade IS NULL OR grade = '');

-- Check If NULL Values Exist
SELECT * FROM takes
WHERE student_id IN ('1238', '1333')
  AND (grade IS NULL OR grade = '');
  
-- Handle Empty Strings ('')
  UPDATE takes
SET grade = 'A'
WHERE student_id IN ('1238', '1333') 
  AND (grade IS NULL OR grade = '');

-- Check Transaction Commit
  COMMIT;

-- Verify Table Constraints
  SHOW CREATE TABLE takes;
  ALTER TABLE takes MODIFY grade VARCHAR(2) NULL;

-- Verify
SELECT student_id, course_id, grade
FROM takes
WHERE student_id IN ('1238', '1333');




--- Question: 6
UPDATE student s
JOIN takes t ON s.ID = t.student_id
JOIN course c ON t.course_id = c.course_id
SET s.tot_cred = s.tot_cred + c.credits
WHERE t.student_id IN ('1238', '1333')
  AND t.grade = 'A'
  AND t.course_id IN (
      SELECT course_id 
      FROM takes 
      WHERE (grade IS NULL OR grade = '' OR grade = 'B') 
        AND student_id = t.student_id
  );



SELECT ID, name, tot_cred FROM student WHERE ID IN ('1238', '1333');



  
  
--- Question: 7
SELECT ID, name
FROM student
WHERE tot_cred = (SELECT MAX(tot_cred) FROM student);

SELECT ID, name, tot_cred
FROM student
WHERE tot_cred = (SELECT MAX(tot_cred) FROM student);





------------------------------ Extra Practice For Assignment  2 ---------------------------------



DROP TABLE IF EXISTS time_slot;

DROP TABLE IF EXISTS section;

DROP TABLE IF EXISTS teaches;

DROP TABLE IF EXISTS takes;


CREATE TABLE IF NOT EXISTS time_slot (
    time_slot_id INT DEFAULT NULL,         -- Allow NULL for time_slot_id
    day_of_week VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    PRIMARY KEY (day_of_week, start_time, end_time),   -- Composite Primary Key
    );


CREATE TABLE IF NOT EXISTS time_slot (
    time_slot_id INT DEFAULT NULL AUTO_INCREMENT PRIMARY KEY,
    day_of_week VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    UNIQUE (day_of_week, start_time, end_time)  -- Ensuring that each time slot is unique
);

CREATE TABLE IF NOT EXISTS section (
    course_id VARCHAR(10),  -- Ensure the type matches with the course_id in course table
    sec_id INT,
    semester VARCHAR(20),
    year INT NOT NULL,
    building VARCHAR(50) NULL,
    room_no VARCHAR(10) NULL,
    time_slot_id INT DEFAULT NULL,
    PRIMARY KEY (course_id, sec_id, semester, year),
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,  -- Foreign Key references course_id
    FOREIGN KEY (time_slot_id) REFERENCES time_slot(time_slot_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS teaches (
    instructor_id VARCHAR(128) NOT NULL,  -- Foreign Key referencing the instructor's ID (matching VARCHAR(128))
    course_id VARCHAR(10),  -- Foreign Key referencing course_id in section table
    sec_id INT NOT NULL,  -- Foreign Key referencing sec_id in section table
    semester VARCHAR(20) NOT NULL,  -- Foreign Key referencing semester in section table
    year INT NOT NULL,  -- Foreign Key referencing year in section table
    PRIMARY KEY (instructor_id, course_id, sec_id, semester, year),
    FOREIGN KEY (instructor_id) REFERENCES instructor(ID) ON DELETE CASCADE,  -- Ensure matching data type VARCHAR(128)
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section(course_id, sec_id, semester, year) ON DELETE CASCADE  -- Section references course_id and other details in section table
);

CREATE TABLE IF NOT EXISTS takes (
    student_id VARCHAR(128) NOT NULL,  -- Foreign Key referencing the student's ID (matching VARCHAR(128))
    course_id VARCHAR(10) NOT NULL,    -- Foreign Key referencing course_id in section table
    sec_id INT NOT NULL,               -- Foreign Key referencing sec_id in section table
    semester VARCHAR(20) NOT NULL,     -- Foreign Key referencing semester in section table
    year INT NOT NULL,                 -- Foreign Key referencing year in section table
    grade VARCHAR(5),                  -- Optional grade column (can be NULL)
    PRIMARY KEY (student_id, course_id, sec_id, semester, year),
    FOREIGN KEY (student_id) REFERENCES student(ID) ON DELETE CASCADE,  -- Ensure matching data type VARCHAR(128)
    FOREIGN KEY (course_id, sec_id, semester, year) REFERENCES section(course_id, sec_id, semester, year) ON DELETE CASCADE  -- Section references course_id and other details in section table
);

ALTER TABLE section 
MODIFY building VARCHAR(50) NULL,
MODIFY room_no VARCHAR(10) NULL,
MODIFY time_slot_id INT NULL;

ALTER TABLE time_slot
MODIFY COLUMN time_slot_id INT NULL;

ALTER TABLE time_slot
DROP PRIMARY KEY,
ADD UNIQUE (time_slot_id);

Select * from time_slot 

Select * from time_slot order by time_slot_id asc;
Select * from section;
Select * from teaches;
Select * from takes;

SELECT * FROM student;


DESCRIBE section;

DESCRIBE time_slot;

DESCRIBE takes;

DESCRIBE teaches;



SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/tusharahuja/Documents/Information Architecture Homework 1/time_slot.csv' 
INTO TABLE time_slot
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';





SELECT c.course_id AS id, 
       c.title, 
       s.sec_id AS section_id
FROM course c
JOIN section s ON c.course_id = s.course_id
JOIN teaches t ON s.course_id = t.course_id 
               AND s.sec_id = t.sec_id
               AND s.semester = 'Fall' 
               AND s.year = 2023;


SELECT c.course_id AS id, 
       c.title, 
       s.sec_id AS section_id, 
       i.name AS instructor_name
FROM course c
JOIN section s ON c.course_id = s.course_id
JOIN teaches t ON s.course_id = t.course_id 
               AND s.sec_id = t.sec_id
               AND s.semester = 'Fall' 
               AND s.year = 2023
JOIN instructor i ON t.instructor_id = i.ID;

UPDATE section
SET time_slot_id = 2
WHERE time_slot_id = 6;


SELECT c.course_id, 
       c.title, 
       s.sec_id AS section, 
       ts.start_time
FROM course c
JOIN section s ON c.course_id = s.course_id
JOIN time_slot ts ON s.time_slot_id = ts.time_slot_id
WHERE s.semester = 'Fall' 
  AND s.year = 2022;


UPDATE takes
SET grade = 'A'
WHERE (student_id = '1238' OR student_id = '1333')
  AND grade IS NULL;

UPDATE student s
JOIN takes t ON s.ID = t.student_id
JOIN course c ON t.course_id = c.course_id
SET s.tot_cred = s.tot_cred + c.credits
WHERE t.student_id IN ('1238', '1333')
  AND t.grade = 'A';

SELECT ID, name
FROM student
WHERE tot_cred = (SELECT MAX(tot_cred) FROM student);

