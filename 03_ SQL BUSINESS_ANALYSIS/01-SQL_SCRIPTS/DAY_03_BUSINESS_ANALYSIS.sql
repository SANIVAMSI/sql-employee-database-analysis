  --TASK-001-Department Salary SummarY
    
SELECT D.DEPT_ID,
       D.DEPT_NAME,
       COUNT(E.EMP_ID) AS EMP_COUNT,
       NVL(SUM(E.SALARY), 0) AS TOTAL_SAL,
       NVL(AVG(E.SALARY), 0) AS AVG_SAL
FROM DEPT_INFO D
LEFT JOIN EMP_INFO E
    ON D.DEPT_ID = E.DEPT_ID
GROUP BY D.DEPT_ID, D.DEPT_NAME
ORDER BY D.DEPT_ID;


--TASK-002-Highest Salary by Department

SELECT D.DEPT_ID,
       D.DEPT_NAME,
       NVL(MAX(E.SALARY), 0) AS HIGHEST_SALARY
FROM DEPT_INFO D
LEFT JOIN EMP_INFO E
    ON D.DEPT_ID = E.DEPT_ID
GROUP BY D.DEPT_ID, D.DEPT_NAME
ORDER BY D.DEPT_ID;


--TASK-003 Top 3 Highest-Paid Employees in Each Department

SELECT EMP_ID,
       EMP_NAME,
       SALARY,
       DEPT_ID,
       RN
FROM (
    SELECT EMP_ID,
           EMP_NAME,
           SALARY,
           DEPT_ID,
           DENSE_RANK() OVER (
               PARTITION BY DEPT_ID
               ORDER BY SALARY DESC
           ) AS RN
    FROM EMP_INFO
)
WHERE RN < 4
ORDER BY EMP_ID;

--TASK-004 Department-wise Average Salary Comparison

SELECT EMP_ID,
       EMP_NAME,
       SALARY,
       DEPT_ID,
       DEPT_AVG
FROM (
    SELECT EMP_ID,
           EMP_NAME,
           SALARY,
           DEPT_ID,
           AVG(SALARY) OVER (
               PARTITION BY DEPT_ID
           ) AS DEPT_AVG
    FROM EMP_INFO
)
WHERE SALARY > DEPT_AVG
ORDER BY DEPT_ID;

--TASK-005 Department Salary Contribution

SELECT D.DEPT_ID,
       D.DEPT_NAME,
       NVL(SUM(E.SALARY), 0) AS DEPT_TOTAL_SAL,
       (SELECT SUM(SALARY)
        FROM EMP_INFO) AS TOTAL_SAL_EXPENDITURE,
       ROUND(
           NVL(SUM(E.SALARY), 0) /
           NULLIF((SELECT SUM(SALARY)
                   FROM EMP_INFO), 0) * 100,
           2
       ) AS DEPT_PERCENTAGE
FROM DEPT_INFO D
LEFT JOIN EMP_INFO E
    ON D.DEPT_ID = E.DEPT_ID
GROUP BY D.DEPT_ID, D.DEPT_NAME
ORDER BY D.DEPT_ID;


--TASK-006 Employees Earning More Than the Highest-Paid Employee in Department 20

SELECT EMP_ID,
       EMP_NAME,
       DEPT_ID,
       SALARY
FROM EMP_INFO
WHERE DEPT_ID <> 20
  AND SALARY > (
      SELECT MAX(SALARY)
      FROM EMP_INFO
      WHERE DEPT_ID = 20
  )
ORDER BY SALARY DESC;


--TASK-007 Employees Earning More Than Their Department's Second-Highest Salary

WITH EMP_RANK AS (
    SELECT EMP_ID,
           EMP_NAME,
           SALARY,
           DEPT_ID,
           DENSE_RANK() OVER (
               PARTITION BY DEPT_ID
               ORDER BY SALARY DESC
           ) AS RN
    FROM EMP_INFO
),
DEPT_SECOND AS (
    SELECT DEPT_ID,
           SALARY AS SECOND_HIGHEST
    FROM EMP_RANK
    WHERE RN = 2
)
SELECT E.EMP_ID,
       E.EMP_NAME,
       E.DEPT_ID,
       E.SALARY,
       D.SECOND_HIGHEST
FROM EMP_INFO E
JOIN DEPT_SECOND D
    ON E.DEPT_ID = D.DEPT_ID
WHERE E.SALARY > D.SECOND_HIGHEST
ORDER BY E.DEPT_ID, E.SALARY DESC;


--TASK-008 Employees Receiving the Same Salary Within a Department

SELECT E1.EMP_ID,
       E1.EMP_NAME,
       E1.SALARY,
       E1.DEPT_ID,
       E2.EMP_ID,
       E2.EMP_NAME,
       E2.SALARY,
       E2.DEPT_ID
FROM EMP_INFO E1
JOIN EMP_INFO E2
    ON E1.DEPT_ID = E2.DEPT_ID
WHERE E1.SALARY = E2.SALARY
  AND E1.EMP_ID <> E2.EMP_ID;
  
  
--TASK-009 Department Salary Ranking

SELECT EMP_ID,
       EMP_NAME,
       SALARY,
       DEPT_ID,
       RANK
FROM (
    SELECT EMP_ID,
           EMP_NAME,
           SALARY,
           DEPT_ID,
           DENSE_RANK() OVER (
               PARTITION BY DEPT_ID
               ORDER BY SALARY DESC
           ) AS RANK
    FROM EMP_INFO
);

--TASK-010 Department-wise Salary Range

SELECT D.DEPT_ID,
       D.DEPT_NAME,
       MIN(E.SALARY) AS MIN_SAL,
       MAX(E.SALARY) AS MAX_SAL,
       NVL(MAX(E.SALARY), 0) - NVL(MIN(E.SALARY), 0) AS SAL_RANGE
FROM DEPT_INFO D
LEFT JOIN EMP_INFO E
    ON D.DEPT_ID = E.DEPT_ID
GROUP BY D.DEPT_ID, D.DEPT_NAME
ORDER BY D.DEPT_ID;

--TASK-011 Employees Above Company Average Salary

SELECT EMP_ID,
       EMP_NAME,
       DEPT_ID,
       SALARY,
       COMPANY_AVG
FROM (
    SELECT EMP_ID,
           EMP_NAME,
           DEPT_ID,
           SALARY,
           AVG(SALARY) OVER () AS COMPANY_AVG
    FROM EMP_INFO
)
WHERE SALARY > COMPANY_AVG;

--TASK-012 Department-wise Employee Salary Classification

WITH DEPT_AVG AS (
    SELECT DEPT_ID,
           AVG(SALARY) AS DEPT_AVG
    FROM EMP_INFO
    GROUP BY DEPT_ID
)
SELECT E.EMP_ID,
       E.EMP_NAME,
       E.DEPT_ID,
       E.SALARY,
       ROUND(D.DEPT_AVG, 2) AS DEPT_AVG,
       CASE
           WHEN E.SALARY > D.DEPT_AVG THEN 'ABOVE AVERAGE'
           WHEN E.SALARY < D.DEPT_AVG THEN 'BELOW AVERAGE'
           WHEN E.SALARY = D.DEPT_AVG THEN 'EQUAL TO AVERAGE'
       END AS CLASSIFICATION
FROM EMP_INFO E
LEFT JOIN DEPT_AVG D
    ON E.DEPT_ID = D.DEPT_ID
ORDER BY E.DEPT_ID, E.EMP_ID;

--TASK-013 Employees Without a Department Match

SELECT E.EMP_ID,
       E.EMP_NAME,
       E.DEPT_ID
FROM EMP_INFO E
LEFT JOIN DEPT_INFO D
    ON E.DEPT_ID = D.DEPT_ID
WHERE D.DEPT_ID IS NULL;

--TASK-014 Employees Whose Salary Is Above Their Department's Average but Below the Company Average

SELECT EMP_ID,
       EMP_NAME,
       DEPT_ID,
       SALARY,
       DEPT_AVG,
       COMPANY_AVG
FROM (
    SELECT EMP_ID,
           EMP_NAME,
           DEPT_ID,
           SALARY,
           AVG(SALARY) OVER (PARTITION BY DEPT_ID) AS DEPT_AVG,
           AVG(SALARY) OVER () AS COMPANY_AVG
    FROM EMP_INFO
)
WHERE SALARY > DEPT_AVG
  AND SALARY < COMPANY_AVG;
  
  
--TASK-015 Department-wise Salary Statistics

SELECT D.DEPT_ID,
       D.DEPT_NAME,
       COUNT(E.EMP_ID) AS EMP_COUNT,
       NVL(SUM(E.SALARY), 0) AS TOTAL_EXP,
       AVG(E.SALARY) AS AVG_SAL,
       MAX(E.SALARY) AS HIGH_SAL,
       MIN(E.SALARY) AS LOW_SAL
FROM DEPT_INFO D
LEFT JOIN EMP_INFO E
    ON D.DEPT_ID = E.DEPT_ID
GROUP BY D.DEPT_ID, D.DEPT_NAME
ORDER BY D.DEPT_ID;


--TASK-016 Employees with Consecutive Salary Rankings

SELECT EMP_ID,
       EMP_NAME,
       DEPT_ID,
       SALARY,
       RANK
FROM (
    SELECT EMP_ID,
           EMP_NAME,
           DEPT_ID,
           SALARY,
           DENSE_RANK() OVER (
               PARTITION BY DEPT_ID
               ORDER BY SALARY DESC
           ) AS RANK
    FROM EMP_INFO
)
WHERE RANK IN (1, 2);

--TASK-017 Departments Spending Above Average

WITH DEPT_TOTAL AS
(
    SELECT D.DEPT_ID,
           D.DEPT_NAME,
           NVL(SUM(E.SALARY), 0) AS TOTAL_SAL
    FROM DEPT_INFO D
    LEFT JOIN EMP_INFO E
        ON D.DEPT_ID = E.DEPT_ID
    GROUP BY D.DEPT_ID, D.DEPT_NAME
)
SELECT DEPT_ID,
       DEPT_NAME,
       TOTAL_SAL,
       (SELECT AVG(TOTAL_SAL) FROM DEPT_TOTAL) AS AVG_DEPT_SAL
FROM DEPT_TOTAL
WHERE TOTAL_SAL > (SELECT AVG(TOTAL_SAL) FROM DEPT_TOTAL)
ORDER BY TOTAL_SAL DESC;



