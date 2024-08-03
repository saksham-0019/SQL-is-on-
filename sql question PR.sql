-- Create the table
CREATE TABLE employee_info (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    gender CHAR(1),
    salary DECIMAL(10, 2),
    city VARCHAR(50)
);

-- Insert sample data with salaries between 2 lakh and 5 lakh
INSERT INTO employee_info (emp_id, emp_name, gender, salary, city) VALUES
(1, 'Amit Kumar', 'M', 250000.00, 'Delhi'),
(2, 'Priya Sharma', 'F', 275000.00, 'Mumbai'),
(3, 'Rajesh Patel', 'M', 300000.00, 'Bangalore'),
(4, 'Anita Desai', 'F', 320000.00, 'Hyderabad'),
(5, 'Ravi Singh', 'M', 350000.00, 'Chennai'),
(6, 'Sneha Gupta', 'F', 270000.00, 'Kolkata'),
(7, 'Vikram Verma', 'M', 400000.00, 'Pune'),
(8, 'Neha Agarwal', 'F', 310000.00, 'Jaipur'),
(9, 'Suresh Rao', 'M', 330000.00, 'Delhi'),
(10, 'Kavita Mehta', 'F', 290000.00, 'Lucknow');



CREATE TABLE employee_projects (
    emp_id INT PRIMARY KEY,
    project VARCHAR(100),
    emp_position VARCHAR(50),
    date_of_join DATE
);
INSERT INTO employee_projects (emp_id, project, emp_position, date_of_join) VALUES
(1, 'Project A', 'Software Engineer', '2023-01-15'),
(2, 'Project B', 'Data Analyst', '2023-02-20'),
(3, 'Project C', 'Project Manager', '2023-03-05'),
(4, 'Project D', 'Software Engineer', '2023-04-10'),
(5, 'Project E', 'Quality Analyst', '2023-05-22'),
(6, 'Project F', 'Data Scientist', '2023-06-30'),
(7, 'Project G', 'Business Analyst', '2023-07-15'),
(8, 'Project H', 'Database Administrator', '2023-08-01'),
(9, 'Project I', 'System Architect', '2023-09-10'),
(10, 'Project J', 'Network Engineer', '2023-10-25');

-- find the list of employe whose salary ranges between 3lakh to 4 lakh 

SELECT emp_name, salary 
FROM public.employee_info
WHERE salary BETWEEN 300000.00 AND 400000.00;

--write a query to retrive the list of employes from the same city 

SELECT e1.emp_id, e1.emp_name, e1.city
FROM public.employee_info AS e1
JOIN public.employee_info AS e2
ON e1.city = e2.city
WHERE e1.emp_id != e2.emp_id;

-- Query to find null values 
SELECT * FROM public.employee_info 
WHERE emp_id IS NULL

--Query to find the cumulative sum of employes sallary 
	
SELECT 
    emp_id, 
    salary, 
    SUM(salary) OVER (ORDER BY emp_id) AS cumulative_sum
FROM public.employee_info;

-- what's the male and female employe ratio 

SELECT 
    COUNT(*) FILTER (WHERE gender = 'M') * 100.0 / COUNT(*) AS male_pct,
    COUNT(*) FILTER (WHERE gender = 'F') * 100.0 / COUNT(*) AS female_pct
FROM public.employee_info;

-- write a query to fetch 50% records of the employe table 

SELECT * 
FROM public.employee_info
WHERE emp_id <= (SELECT COUNT(emp_id) / 2 FROM public.employee_info);

--query to fetch the employe's salary but replace the last 2 digits 
--with (xx)i.e 12345 will be 123xxx

SELECT 
    salary,
    CONCAT(SUBSTRING(salary::text FROM 1 FOR LENGTH(salary::text) - 2), 'xx') AS masked_salary
FROM public.employee_info;

--write a query to fetch even and odd rows from employee table 

---fetch even rows 
select * from public.employee_info
where mod (emp_id,2)=0;

---fetch even rows 
select * from public.employee_info
where mod (emp_id,2)=1;

--nwrirte a query find all employe name starts with 
--.begint with A
--.contain A alphabet at second place 
--.contain Y alphabet at second last place 
--. ends with L and contain 4 alphabet 
--. begins with V and ends with A 


select * from public.employee_info where emp_name like 'A%';

select * from public.employee_info where emp_name like '_a%';

select * from public.employee_info where emp_name like '%y_';

select * from public.employee_info where emp_name like '____l';

select * from public.employee_info where emp_name like 'V%,';


--write a query to find the list of employe name which is :
--.start with vowels (a,e,i,o,u) without duplicate 
--.ending with vowels (a,e,i,o,u)without duplicates 
--.starting & ending with vowels (a,e,i,o,u)without duplicates 

SELECT DISTINCT emp_name
FROM public.employee_info
WHERE lower(emp_name) REGEXP '^[aeiou]';

SELECT DISTINCT emp_name
FROM public.employee_info
WHERE lower(emp_name) REGEXP '[aeiou]$';

SELECT DISTINCT emp_name
FROM public.employee_info
WHERE lower(emp_name) REGEXP '^[aeiou].*[aeiou]$';

--.find Nth term salary from employe taable with and without using the TOP/limit keyword 

SELECT COUNT(DISTINCT E2.salary) AS distinct_salaries_count
FROM public.employee_info E2
WHERE E2.salary > (
    SELECT E1.salary
    FROM public.employee_info E1
    WHERE N - 1 = C
);

--.show the employe with highest sallary for each project 


SELECT ed.project,
       MAX(e.salary) AS project_salary
FROM public.employee_info e
JOIN public.employee_projects ed ON e.emp_id = ed.emp_id
GROUP BY ed.project
ORDER BY project_salary DESC;

--query to find the total count of employe joind each year 

SELECT EXTRACT(YEAR FROM date_of_join) AS join_year,
       COUNT(*) AS emp_count
FROM public.employee_info
GROUP BY join_year
ORDER BY join_year ASC; --------------------------------------------------

--geat.3 group based on salary col,salary less then .2l is low , bettween 2'3l is medium and above 3l is high 

SELECT emp_name,
       salary,
       CASE
           WHEN salary > 300000 THEN 'high'
           WHEN salary >= 200000 AND salary <= 300000 THEN 'medium'
           ELSE 'low'
       END AS salary_status
FROM public.employee_info;


--- qery to piviot  the data in the employe table and retrive the total sallary for each city 
--- the result sould disply the empid , empname nad seprate column for each city (delhi,mumbai), contaning the corresponding total sallary.

SELECT emp_id,
       emp_name,
       SUM(CASE WHEN city = 'Delhi' THEN salary ELSE 0 END) AS Delhi,
       SUM(CASE WHEN city = 'Mumbai' THEN salary ELSE 0 END) AS Mumbai
FROM public.employee_info
GROUP BY emp_id, emp_name;
