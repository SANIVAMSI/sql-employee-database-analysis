--Employee and department details using FULL JOIN.
 SELECT
    e.emp_id,
    e.emp_name,
    e.manager_id,
    d.dept_id,
    d.dept_name
FROM dept_info d
FULL JOIN emp_info e
    ON d.dept_id = e.dept_id
ORDER BY e.emp_id;

--Find departments without employees

SELECT
    d.dept_id,
    d.dept_name,
    d.location
FROM dept_info d
LEFT JOIN emp_info e
    ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL
ORDER BY d.dept_id;


--Department-wise employee count
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM dept_info d
LEFT JOIN emp_info e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_id; 

--Find the highest salary in each department
SELECT
    d.dept_id,
    d.dept_name,
    MAX(e.salary) AS highest_salary
FROM dept_info d
LEFT JOIN emp_info e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_id; 

--Identify employees earning above their department's average salary

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.salary,
    round(a.avg_salary,2)
FROM emp_info e
JOIN dept_info d
    ON e.dept_id = d.dept_id
JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM emp_info
    GROUP BY dept_id
) a
    ON e.dept_id = a.dept_id
WHERE e.salary > a.avg_salary
ORDER BY e.dept_id, e.emp_id;

--Find the second-highest salary in each department


SELECT
    d.dept_id,
    d.dept_name,
    MAX(
        CASE WHEN x.rn = 2 THEN x.salary END
    ) AS second_highest_salary
FROM dept_info d
LEFT JOIN (
    SELECT
        dept_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC
        ) AS rn
    FROM emp_info
) x
    ON d.dept_id = x.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_id;
