-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')".
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update the Address of Member with member_id= 'C103' to '125 Oak St'.
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Task 3: Delete the record with issued_id = 'IS121' from the issue_status table.
DELETE FROM issue_status
WHERE issued_id = 'IS121';

-- Task 4: Select all books issued by the employee with emp_id = 'E101'.
SELECT issued_book_name
FROM issue_status
WHERE issued_emp_id= 'E101';

-- Task 5: List Members Who Have Issued More Than One Book.
SELECT me.member_id, me.member_name
FROM members me
JOIN issue_status iss
ON me.member_id = iss.issued_member_id
GROUP BY me.member_id
HAVING COUNT(*) > 1;

-- Task 6: Use CTAS to generate new tables based on query results - each book and total book_issued_cnt**.
CREATE TABLE book_issed_count AS  
	SELECT b.isbn, b.book_title, COUNT(iss.issued_book_isbn) AS issue_count
	FROM books b
	JOIN issue_status iss
	ON b.isbn = iss.issued_book_isbn
	GROUP BY b.isbn;

-- Task 7. Retrieve All Books 'Classic' Specific Category.
SELECT *
FROM books
WHERE Category = 'Classic';

-- Task 8: Find Total Rental Income by Category.
SELECT b.Category, SUM(rental_price) AS rental_income, COUNT(*) AS total_books_rented
FROM books b
JOIN issue_status iss
ON b.isbn = iss.issued_book_isbn
GROUP BY Category
ORDER BY rental_income DESC;

-- Task 9: List Members Who Registered in the Last 180 Days.
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List employees with their branch manager's name and branch details.
SELECT e1.emp_id, e1.emp_name, e2.emp_name AS manager_name, b.*
FROM employees e1
JOIN branch b
ON e1.branch_id = b.branch_id
JOIN employees e2
ON e2.emp_id = b.manager_id; 

-- Task 11: Create a Table of Books with a Rental Price Above 7.00.
CREATE TABLE expensive_book AS 
	SELECT *
	FROM books
	WHERE rental_price > 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT *
FROM issue_status iss
JOIN return_status rs
ON iss.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;


-- ADVANCE SQL QUERIES
-- Task 13: Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's id, member's name, book title, issue date, and days overdue.
SELECT m.member_id, m.member_name, iss.issued_book_name, iss.issued_date, rs.return_date - iss.issued_date AS "days_overdues"
FROM issue_status iss
JOIN return_status rs
ON iss.issued_id = rs.issued_id
JOIN members m
ON m.member_id = iss.issued_member_id
WHERE rs.return_date - iss.issued_date  > 30
ORDER BY days_overdues DESC;

-- Task 14: Write a query to update the status of books in the books table to "Yes" when they are returned 
-- (based on entries in the return_status table). 
-- A book called "Moby Dick" with issued_id= "IS130" has been issued but it has not 
-- been returned yet. The status for this is "no" on the books table and there is no entry of this book in return_status
-- table because it has not been yet returned.
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

-- Task 15: Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.
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

-- Task 16: Create a new table active_members containing members who have 
-- issued at least one book in the last 2 months.
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

-- Task 17: Write a 'stored procedure' that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: 
-- The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). 
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
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