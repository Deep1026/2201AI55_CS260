-- General Instructions
-- 1.	The .sql files are run automatically, so please ensure that there are no syntax errors in the file. If we are unable to run your file, you get an automatic reduction to 0 marks.
-- Comment in MYSQL 

-- 1. Create a trigger that automatically increases the salary by 10% for employees whose salary is below €60000 when a new record is inserted into the employees table.

DELIMITER $$
CREATE TRIGGER increase_low_salary_on_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < 60000 THEN
        SET NEW.salary = NEW.salary * 1.1;
    END IF;
END$$
DELIMITER ;

-- 2. Create a trigger that prevents deleting records from the departments table if there are employees assigned to that department.
DELIMITER $$
CREATE TRIGGER prevent_department_delete
BEFORE DELETE ON departments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM employees WHERE department_id = OLD.department_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete department with employees assigned.';
    END IF;
END$$
DELIMITER ;

-- 3. Write a trigger that logs the details of any salary updates (old salary, new salary, employee name, and date) into a separate audit table.
CREATE TABLE salary_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    full_name VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER log_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salary_audit (emp_id, old_salary, new_salary, full_name)
    VALUES (OLD.emp_id, OLD.salary, NEW.salary, CONCAT(OLD.first_name, ' ', OLD.last_name));
END$$
DELIMITER ;

-- 4. Create a trigger that automatically assigns a department to an employee based on their salary range (e.g., salary <= €60000 -> department_id = 3).
DELIMITER $$
CREATE TRIGGER assign_department_on_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary <= 60000 THEN
        SET NEW.department_id = 3;
    ELSEIF NEW.salary <= 80000 THEN
        SET NEW.department_id = 2;
    ELSE
        SET NEW.department_id = 1;
    END IF;
END$$
DELIMITER ;

-- 5. Write a trigger that updates the salary of the manager (highest-paid employee) in each department whenever a new employee is hired in that department.
DELIMITER $$
CREATE TRIGGER update_manager_salary
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    UPDATE employees e
    SET e.salary = (
        SELECT MAX(salary)
        FROM employees
        WHERE department_id = NEW.department_id
    )
    WHERE e.emp_id = (
        SELECT manager_id
        FROM departments
        WHERE department_id = NEW.department_id
    );
END$$
DELIMITER ;

-- 6. Create a trigger that prevents updating the department_id of an employee if they have worked on projects.
DELIMITER $$
CREATE TRIGGER prevent_department_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM works_on WHERE emp_id = OLD.emp_id
    ) AND OLD.department_id != NEW.department_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update department for employee with project assignments.';
    END IF;
END$$
DELIMITER ;

-- 7. Write a trigger that calculates and updates the average salary for each department whenever a salary change occurs.
CREATE TABLE department_avg_salary (
    department_id INT PRIMARY KEY,
    avg_salary DECIMAL(10,2)
);

DELIMITER $$
CREATE TRIGGER update_department_avg_salary
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    UPDATE department_avg_salary
    SET avg_salary = (
        SELECT AVG(salary)
        FROM employees
        WHERE department_id = NEW.department_id
    )
    WHERE department_id = NEW.department_id;
END$$
DELIMITER ;

-- 8. Create a trigger that automatically deletes all records from the works_on table for an employee when that employee is deleted from the employees table.
DELIMITER $$
CREATE TRIGGER delete_works_on_records
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    DELETE FROM works_on WHERE emp_id = OLD.emp_id;
END$$
DELIMITER ;

-- 9. Write a trigger that prevents inserting a new employee if their salary is less than the minimum salary set for their department.
DELIMITER $$
CREATE TRIGGER prevent_low_salary_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    DECLARE min_salary DECIMAL(10,2);
    SELECT MIN(salary) INTO min_salary
    FROM employees
    WHERE department_id = NEW.department_id;

    IF NEW.salary < min_salary THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary cannot be lower than department minimum.';
    END IF;
END$$
DELIMITER ;

-- 10. Create a trigger that automatically updates the total salary budget for a department whenever an employee's salary is updated.
CREATE TABLE department_salary_budget (
    department_id INT PRIMARY KEY,
    total_salary DECIMAL(12,2)
);

DELIMITER $$
CREATE TRIGGER update_department_salary_budget
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    UPDATE department_salary_budget
    SET total_salary = (
        SELECT SUM(salary)
        FROM employees
        WHERE department_id = NEW.department_id
    )
    WHERE department_id = NEW.department_id;
END$$
DELIMITER ;

-- 11. Write a trigger that sends an email notification to HR whenever a new employee is hired.
-- Note: This trigger requires a custom function or stored procedure to send emails.

-- 12. Create a trigger that prevents inserting a new department if the location is not specified.
DELIMITER $$
CREATE TRIGGER prevent_null_location
BEFORE INSERT ON departments
FOR EACH ROW
BEGIN
    IF NEW.location IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Location cannot be NULL.';
    END IF;
END$$
DELIMITER ;

-- 13. Write a trigger that updates the department_name in the employees table when the corresponding department_name is updated in the departments table.
DELIMITER $$
CREATE TRIGGER update_employee_department_name
AFTER UPDATE ON departments
FOR EACH ROW
BEGIN
    UPDATE employees e
    JOIN departments d ON e.department_id = d.department_id
    SET e.department_name = d.department_name
    WHERE d.department_id = OLD.department_id;
END$$
DELIMITER ;

-- 14. Create a trigger that logs all insert, update, and delete operations on the employees table into a separate audit table.
-- Create a separate table for employee_audit if it doesn't exist
CREATE TABLE employee_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    operation VARCHAR(10),
    emp_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary DECIMAL(10,2),
    department_id INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for INSERT
DELIMITER $$
CREATE TRIGGER log_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (operation, emp_id, first_name, last_name, salary, department_id)
    VALUES ('INSERT', NEW.emp_id, NEW.first_name, NEW.last_name, NEW.salary, NEW.department_id);
END$$
DELIMITER ;

-- Trigger for UPDATE
DELIMITER $$
CREATE TRIGGER log_employee_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (operation, emp_id, first_name, last_name, salary, department_id)
    VALUES ('UPDATE', OLD.emp_id, OLD.first_name, OLD.last_name, OLD.salary, OLD.department_id);
END$$
DELIMITER ;

-- Trigger for DELETE
DELIMITER $$
CREATE TRIGGER log_employee_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit (operation, emp_id, first_name, last_name, salary, department_id)
    VALUES ('DELETE', OLD.emp_id, OLD.first_name, OLD.last_name, OLD.salary, OLD.department_id);
END$$
DELIMITER ;