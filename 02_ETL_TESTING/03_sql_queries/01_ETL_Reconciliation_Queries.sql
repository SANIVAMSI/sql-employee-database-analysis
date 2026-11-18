-- finding duplicate records in target
SELECT EMP_ID,
       COUNT(*) AS DUPLICATE_RECORDS
FROM TARGET_EMP
GROUP BY EMP_ID
HAVING COUNT(*) > 1;


--Find missing records in target

SELECT s.emp_id, s.emp_name
FROM source_emp s
WHERE NOT EXISTS (
    SELECT 1
    FROM target_emp t
    WHERE s.emp_id = t.emp_id
);


--Find extra records in target
SELECT t.emp_id, t.emp_name
FROM target_emp t
WHERE NOT EXISTS (
    SELECT 1
    FROM source_emp s
    WHERE s.emp_id = t.emp_id
);



--Validate salary mismatches b/w matching records
SELECT s.emp_id,
       s.emp_name,
       s.salary AS source_salary,
       t.salary AS target_salary
FROM source_emp s
INNER JOIN target_emp t
    ON s.emp_id = t.emp_id
WHERE s.salary <> t.salary
   OR (s.salary IS NULL AND t.salary IS NOT NULL)
   OR (s.salary IS NOT NULL AND t.salary IS NULL);
   
   
--Validate employee name mismatches

SELECT t.emp_id,
       s.emp_name AS source_name,
       t.emp_name AS target_name
FROM source_emp s
JOIN target_emp t
    ON s.emp_id = t.emp_id
WHERE s.emp_name <> t.emp_name
   OR (s.emp_name IS NULL AND t.emp_name IS NOT NULL)
   OR (t.emp_name IS NULL AND s.emp_name IS NOT NULL);
   
--Department mismatch validation

SELECT t.emp_id,
       s.dept_id AS source_dept,
       t.dept_id AS target_dept
FROM source_emp s
JOIN target_emp t
    ON s.emp_id = t.emp_id
WHERE s.dept_id <> t.dept_id
   OR (s.dept_id IS NULL AND t.dept_id IS NOT NULL)
   OR (t.dept_id IS NULL AND s.dept_id IS NOT NULL);
   
--Validate hire dates
SELECT t.emp_id,
       s.hire_date AS source_hire_date,
       t.hire_date AS target_hire_date
FROM source_emp s
JOIN target_emp t
    ON s.emp_id = t.emp_id
WHERE s.hire_date <> t.hire_date
   OR (s.hire_date IS NULL AND t.hire_date IS NOT NULL)
   OR (t.hire_date IS NULL AND s.hire_date IS NOT NULL);


--Validate complete employee records
SELECT t.emp_id,
       s.emp_name AS source_emp_name,
       s.dept_id AS source_dept_id,
       s.salary AS source_salary,
       s.hire_date AS source_hire_date,
       t.emp_name AS target_emp_name,
       t.dept_id AS target_dept_id,
       t.salary AS target_salary,
       t.hire_date AS target_hire_date
FROM source_emp s
JOIN target_emp t
    ON s.emp_id = t.emp_id
WHERE DECODE(s.emp_name, t.emp_name, 0, 1) = 1
   OR DECODE(s.dept_id, t.dept_id, 0, 1) = 1
   OR DECODE(s.salary, t.salary, 0, 1) = 1
   OR DECODE(s.hire_date, t.hire_date, 0, 1) = 1;
 
--Validate total record counts
SELECT
    (SELECT COUNT(*) FROM source_emp) AS source_count,
    (SELECT COUNT(*) FROM target_emp) AS target_count,
    (SELECT COUNT(*) FROM source_emp) -
    (SELECT COUNT(*) FROM target_emp) AS count_diff
FROM dual;


--Validate duplicate employee records

SELECT COUNT(*),
       EMP_ID,
       EMP_NAME,
       SALARY,
       DEPT_ID,
       HIRE_DATE
FROM TARGET_EMP
GROUP BY EMP_ID, EMP_NAME, SALARY, DEPT_ID, HIRE_DATE
HAVING COUNT(*) > 1;


--Calculate salary totals and compare

select 
  (select sum(salary) from source_emp) as source_total,
  (select sum(salary) from target_emp) as target_total,
 (select sum(salary) from source_emp)- (select sum(salary) from target_emp) as sal_diff from dual;
 
 --Identify significant salary mismatches
 
 SELECT t.emp_id,
       t.emp_name,
       s.salary AS source_salary,
       t.salary AS target_salary,
       s.salary - t.salary AS sal_diff
FROM source_emp s
JOIN target_emp t
    ON s.emp_id = t.emp_id
WHERE (s.salary - t.salary) > 1000
   OR (t.salary - s.salary) > 1000;
   
   
   
--Identify duplicate employee IDs with different records

SELECT E1.EMP_ID,
       E1.EMP_NAME,
       (SELECT COUNT(*)
        FROM TARGET_EMP E3
        WHERE E3.EMP_ID = E1.EMP_ID) AS RECORD_COUNT,
       E1.SALARY AS SALARY_1,
       E2.SALARY AS SALARY_2,
       E1.DEPT_ID AS DEPT_1,
       E2.DEPT_ID AS DEPT_2
FROM TARGET_EMP E1
JOIN TARGET_EMP E2
  ON E1.EMP_ID = E2.EMP_ID
WHERE (
        E1.SALARY <> E2.SALARY
        OR E1.DEPT_ID <> E2.DEPT_ID
      )
  AND E1.ROWID < E2.ROWID;
  
  
--Identify inconsistent employee names

      SELECT E1.EMP_ID,
       E1.EMP_NAME AS EMPNAME1,
       E2.EMP_NAME AS EMPNAME2,
       (SELECT COUNT(*)
        FROM TARGET_EMP E3
        WHERE E3.EMP_ID = E1.EMP_ID) AS RECORD_COUNT
FROM TARGET_EMP E1
JOIN TARGET_EMP E2
  ON E1.EMP_ID = E2.EMP_ID
WHERE (
        E1.EMP_NAME <> E2.EMP_NAME
        OR (E1.EMP_NAME IS NULL AND E2.EMP_NAME IS NOT NULL)
        OR (E1.EMP_NAME IS NOT NULL AND E2.EMP_NAME IS NULL)
      )
  AND E1.ROWID < E2.ROWID;
  
--Identify duplicate employee IDs with different hire dates

select e1.emp_id ,
e1.hire_date as hiredate1,
e2.hire_date as hiredate2,
(select count(*) from target_emp e3 where e3.emp_id = e1.emp_id) as record_count
from target_emp e1 join target_emp e2 on e1.emp_id = e2.emp_id   
where (
  e1.hire_date <> e2.hire_date or 
  (e1.hire_date is null and e2.hire_date is not null) or
  (e2.hire_date is null and e1.hire_date is not null)) and e1.rowid < e2.rowid;
  
  
--Identify duplicate IDs with different employee names, salaries, departments, or hire dates

SELECT E1.EMP_ID,
       E1.EMP_NAME AS EMP_NAME1,
       E2.EMP_NAME AS EMP_NAME2,
       E1.SALARY AS SALARY1,
       E2.SALARY AS SALARY2,
       E1.DEPT_ID AS DEPT1,
       E2.DEPT_ID AS DEPT2,
       E1.HIRE_DATE AS HIREDATE1,
       E2.HIRE_DATE AS HIREDATE2,
       (SELECT COUNT(*)
        FROM TARGET_EMP E3
        WHERE E3.EMP_ID = E1.EMP_ID) AS RECORD_COUNT
FROM TARGET_EMP E1
JOIN TARGET_EMP E2
  ON E1.EMP_ID = E2.EMP_ID
WHERE (
       DECODE(E1.EMP_NAME, E2.EMP_NAME, 0, 1) = 1
       OR DECODE(E1.SALARY, E2.SALARY, 0, 1) = 1
       OR DECODE(E1.DEPT_ID, E2.DEPT_ID, 0, 1) = 1
       OR DECODE(E1.HIRE_DATE, E2.HIRE_DATE, 0, 1) = 1
      )
  AND E1.ROWID < E2.ROWID;