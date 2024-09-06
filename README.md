# Library Management Project-SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/dsmohiit/Library_Management_Project_SQL/blob/main/download%20(1).png)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Entity Relation Diagram(ERD)
![ERD](https://github.com/dsmohiit/Library_Management_Project_SQL/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_management_system`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_management_system;

-- Creating Branch Table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(25),
	contact_no VARCHAR(15)
);


-- Creating Employee Table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(25),
	position VARCHAR(15),	
	salary INT, 
	branch_id VARCHAR(15) --FK
);


-- Creating  Books Table
DROP TABLE IF EXISTS books;
CREATE TABLE books(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(75),
	category VARCHAR(25),
	rental_price FLOAT,
	status VARCHAR(15),
	author VARCHAR(35),
	publisher VARCHAR(75)

);



-- Creating Members' Table
DROP TABLE IF EXISTS members;
CREATE TABLE members(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name VARCHAR(25),
	member_address VARCHAR(75),
	reg_date DATE

);



-- Creating Issue Status Table
DROP TABLE IF EXISTS issue_status;
CREATE TABLE issue_status(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10), --FK
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(25), --FK
	issued_emp_id VARCHAR(10) -- FK

);



-- Creating a Return Status Table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10), --FK
	return_book_name VARCHAR(75),
	return_date DATE,
	return_book_isbn VARCHAR(25)

);

-- ADDING FOREIGN KEY
ALTER TABLE issue_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id); 

ALTER TABLE issue_status
ADD CONSTRAINT fk_BOOKS
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn); 

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id); 

ALTER TABLE return_status
ADD CONSTRAINT fk_issue_status
FOREIGN KEY (issued_id)
REFERENCES issue_status(issued_id);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')".**

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```
**Task 2: Update the Address of Member with member_id= 'C103' to '125 Oak St'.**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete the record with issued_id = 'IS121' from the issue_status table.**

```sql
DELETE FROM issue_status
WHERE issued_id = 'IS121';
```

**Task 4: Select all books issued by the employee with emp_id = 'E101'.**
```sql
SELECT issued_book_name
FROM issue_status
WHERE issued_emp_id= 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book.**

```sql
SELECT me.member_id, me.member_name
FROM members me
JOIN issue_status iss
ON me.member_id = iss.issued_member_id
GROUP BY me.member_id
HAVING COUNT(*) > 1;
```

### 3. CTAS (Create Table As Select)

**Task 6: Use CTAS to generate new tables based on query results - each book and total book_issued_count.**

```sql
CREATE TABLE book_issed_count AS  
	SELECT b.isbn, b.book_title, COUNT(iss.issued_book_isbn) AS issue_count
	FROM books b
	JOIN issue_status iss
	ON b.isbn = iss.issued_book_isbn
	GROUP BY b.isbn;
```


### 4. Data Analysis & Findings

**Task 7. Retrieve All Books 'Classic' Specific Category.**:

```sql
SELECT *
FROM books
WHERE Category = 'Classic';
```

**Task 8: Find Total Rental Income by Category.**

```sql
SELECT b.Category, SUM(rental_price) AS rental_income, COUNT(*) AS total_books_rented
FROM books b
JOIN issue_status iss
ON b.isbn = iss.issued_book_isbn
GROUP BY Category
ORDER BY rental_income DESC;
```

**Task 9: List Members Who Registered in the Last 180 Days**
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Task 10: List employees with their branch manager's name and branch details.**

```sql
SELECT e1.emp_id, e1.emp_name, e2.emp_name AS manager_name, b.*
FROM employees e1
JOIN branch b
ON e1.branch_id = b.branch_id
JOIN employees e2
ON e2.emp_id = b.manager_id; 
```

**Task 11: Create a Table of Books with a Rental Price Above 7.00.**
```sql
CREATE TABLE expensive_book AS 
	SELECT *
	FROM books
	WHERE rental_price > 7.00;
```

**Task 12: Retrieve the List of Books Not Yet Returned.**
```sql
SELECT *
FROM issue_status iss
JOIN return_status rs
ON iss.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's id, member's name, book title, issue date, and days overdue.**  

```sql
SELECT m.member_id, m.member_name, iss.issued_book_name, iss.issued_date, rs.return_date - iss.issued_date AS "days_overdues"
FROM issue_status iss
JOIN return_status rs
ON iss.issued_id = rs.issued_id
JOIN members m
ON m.member_id = iss.issued_member_id
WHERE rs.return_date - iss.issued_date  > 30
ORDER BY days_overdues DESC;
```


**Task 14: Write a query to update the status of books in the books table to "Yes" when they are returned(based on entries in the return_status table). A book called "Moby Dick" with issued_id= "IS130" has been issued but it has not been returned yet. The status for this is "no" on the books table and there is no entry of this book in return_statustable because it has not been yet returned.**  


```sql

CREATE OR REPLACE PROCEDURE add_return_record(p_retrun_id VARCHAR(10), p_issued_id VARCHAR(30))
LANGUAGE plpgsql
AS $$

DECLARE	
	v_isbn VARCHAR(50);

BEGIN

	-- Inserting return record in return_status table
	INSERT INTO return_status(return_id, issued_id, return_date)
	VALUES(p_retrun_id, p_issued_id, CURRENT_DATE);

	-- Extracting isbn
	SELECT issued_book_isbn
	INTO 
	v_isbn
	FROM issue_status
	WHERE issued_id = p_issued_id;

	-- Updating status on the books table
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	
END;
$$

-- Calling the function
CALL add_return_record('RS119', 'IS130');

-- Record has been added
SELECT * FROM return_status;

-- Status was updated
SELECT * FROM books;
```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
```

**-- Task 16: Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.**  

```sql

CREATE TABLE branch_report
AS
	SELECT b.branch_id, b.manager_id, SUM(rental_price) AS "revenue", COUNT(iss.issued_id) AS num_of_books_issued, COUNT(rs.return_id) AS num_of_returned_books
	FROM issue_status iss
	JOIN employees e
	ON iss.issued_emp_id = e.emp_id
	JOIN branch b
	ON b.branch_id = e.branch_id
	LEFT JOIN return_status rs
	ON rs.issued_id = iss.issued_id
	JOIN books bk 
	ON bk.isbn = iss.issued_book_isbn
	GROUP BY b.branch_id
	ORDER BY SUM(rental_price) DESC;

SELECT *
FROM branch_report;

```


**-- Task 16: Create a new table active_members containing members who have issued at least one book in the last 2 months.** 

```sql
CREATE TABLE active_members
AS	
	SELECT m.member_id, m.member_name
	FROM members m
	JOIN issue_status iss
	ON m.member_id = iss.issued_member_id
	JOIN return_status rs
	ON rs.issued_id = iss.issued_id
	WHERE rs.return_date - iss.issued_date <= 60
	GROUP BY m.member_id;
```


**Task 17: Write a 'stored procedure' that updates the status of a book in the library based on its issuance. The procedure should function as follows: 
-- The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.**

```sql

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE

	v_status VARCHAR(10);

BEGIN 

	-- Check if the book the customer wants is available or not (status= 'yes').
	SELECT status
	INTO v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;

	-- If the book is available (status= 'yes'), then execute the 'IF' block.
	-- 'IF' logic is adding a record into the 'issue_status' table and updating the status to 'no' in books table.
	IF v_status = 'yes'
		THEN
			INSERT INTO issue_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
			VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

			UPDATE books	
			SET status = 'no'
			WHERE isbn = p_issued_book_isbn;

			RAISE NOTICE 'Book record added successfully for book isbn: %', p_issued_book_isbn;

	ELSE
		RAISE NOTICE 'Book you requested is not available book_isbn: %', p_issued_book_isbn;

	END IF;
	
END;

$$

CALL issue_book('IS141', 'C106', '978-0-553-29698-2', 'E104');

SELECT * FROM issue_status;
SELECT * FROM books;
```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.


## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Mohit Soni

This project showcases SQL skills essential for database management and analysis. 
