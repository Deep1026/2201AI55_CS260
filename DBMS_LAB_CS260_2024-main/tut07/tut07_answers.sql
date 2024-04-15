-- General Instructions
-- 1.	The .sql files are run automatically, so please ensure that there are no syntax errors in the file. If we are unable to run your file, you get an automatic reduction to 0 marks.
-- Comment in MYSQL 

-- 1. Create a procedure to calculate the average salary of employees in a given department.
DELIMITER $$
CREATE PROCEDURE get_avg_salary_by_department(IN dept_id INT)
BEGIN
    SELECT AVG(salary) AS avg_salary
    FROM employees
    WHERE department_id = dept_id;
END$$
DELIMITER ;

-- 2. Write a procedure to update the salary of an employee by a specified percentage.
DELIMITER $$
CREATE PROCEDURE update_employee_salary(IN emp_id INT, IN percentage DECIMAL(5,2))
BEGIN
    UPDATE employees
    SET salary = salary + (salary * percentage / 100)
    WHERE emp_id = emp_id;
END$$
DELIMITER ;

-- 3. Create a procedure to list all employees in a given department.
DELIMITER $$
CREATE PROCEDURE get_employees_by_department(IN dept_id INT)
BEGIN
    SELECT e.emp_id, e.first_name, e.last_name, e.salary
    FROM employees e
    WHERE e.department_id = dept_id;
END$$
DELIMITER ;

-- 4. Write a procedure to calculate the total budget allocated to a specific project.
DELIMITER $$
CREATE PROCEDURE get_project_budget(IN proj_id INT)
BEGIN
    SELECT budget
    FROM projects
    WHERE project_id = proj_id;
END$$
DELIMITER ;

-- 5. Create a procedure to find the employee with the highest salary in a given department.
DELIMITER $$
CREATE PROCEDURE get_highest_paid_employee_by_department(IN dept_id INT)
BEGIN
    SELECT e.emp_id, e.first_name, e.last_name, e.salary
    FROM employees e
    WHERE e.department_id = dept_id
    ORDER BY e.salary DESC
    LIMIT 1;
END$$
DELIMITER ;

-- 6. Write a procedure to list all projects that are due to end within a specified number of days.
DELIMITER $$
CREATE PROCEDURE get_projects_ending_soon(IN days INT)
BEGIN
    SELECT project_id, project_name, end_date
    FROM projects
    WHERE DATEDIFF(end_date, CURDATE()) <= days;
END$$
DELIMITER ;

-- 7. Create a procedure to calculate the total salary expenditure for a given department.
DELIMITER $$
CREATE PROCEDURE get_total_salary_by_department(IN dept_id INT)
BEGIN
    SELECT SUM(salary) AS total_salary
    FROM employees
    WHERE department_id = dept_id;
END$$
DELIMITER ;

-- 8. Write a procedure to generate a report listing all employees along with their department and salary details.
DELIMITER $$
CREATE PROCEDURE get_employee_report()
BEGIN
    SELECT e.emp_id, e.first_name, e.last_name, e.salary, d.department_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id;
END$$
DELIMITER ;

-- 9. Create a procedure to find the project with the highest budget.
DELIMITER $$
CREATE PROCEDURE get_highest_budget_project()
BEGIN
    SELECT project_id, project_name, budget
    FROM projects
    ORDER BY budget DESC
    LIMIT 1;
END$$
DELIMITER ;

-- 10. Write a procedure to calculate the average salary of employees across all departments.
DELIMITER $$
CREATE PROCEDURE get_avg_salary_all_departments()
BEGIN
    SELECT AVG(salary) AS avg_salary
    FROM employees;
END$$
DELIMITER ;

-- 11. Create a procedure to assign a new manager to a department and update the manager_id in the departments table.
DELIMITER $$
CREATE PROCEDURE assign_department_manager(IN dept_id INT, IN manager_id INT)
BEGIN
    UPDATE departments
    SET manager_id = manager_id
    WHERE department_id = dept_id;
END$$
DELIMITER ;

-- 12. Write a procedure to calculate the remaining budget for a specific project.
DELIMITER $$
CREATE PROCEDURE get_remaining_project_budget(IN proj_id INT)
BEGIN
    DECLARE project_budget DECIMAL;
    DECLARE total_employee_salary DECIMAL;
    
    SELECT budget INTO project_budget
    FROM projects
    WHERE project_id = proj_id;
    
    SELECT SUM(salary) INTO total_employee_salary
    FROM employees
    WHERE department_id = (
        SELECT department_id
        FROM departments
        WHERE manager_id IN (
            SELECT emp_id
            FROM employees
            WHERE department_id = (
                SELECT department_id
                FROM departments
                WHERE department_id = (
                    SELECT department_id
                    FROM projects
                    WHERE project_id = proj_id
                )
            )
        )
    );
    
    SELECT project_budget - total_employee_salary AS remaining_budget;
END$$
DELIMITER ;

-- 13. Create a procedure to generate a report of employees who joined the company in a specific year.
DELIMITER $$
CREATE PROCEDURE get_employees_by_join_year(IN join_year YEAR)
BEGIN
    SELECT emp_id, first_name, last_name, YEAR(hire_date) AS join_year
    FROM employees
    WHERE YEAR(hire_date) = join_year;
END$$
DELIMITER ;

-- 14. Write a procedure to update the end date of a project based on its start date and duration.
DELIMITER $$
CREATE PROCEDURE update_project_end_date(IN proj_id INT, IN duration INT)
BEGIN
    DECLARE start_date DATE;
    
    SELECT start_date INTO start_date
    FROM projects
    WHERE project_id = proj_id;
    
    UPDATE projects
    SET end_date = DATE_ADD(start_date, INTERVAL duration DAY)
    WHERE project_id = proj_id;
END$$
DELIMITER ;

-- 15. Create a procedure to calculate the total number of employees in each department.
DELIMITER $$
CREATE PROCEDURE get_employee_count_by_department()
BEGIN
    SELECT d.department_name, COUNT(e.emp_id) AS employee_count
    FROM departments d
    LEFT JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_id;
END$$
DELIMITER ;