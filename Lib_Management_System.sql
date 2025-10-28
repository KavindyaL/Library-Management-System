--Library Management System Project 2

CREATE DATABASE sql_project_p1;

--Creating branch table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch 
	(
		branch_id VARCHAR(10) PRIMARY KEY,	
		manager_id VARCHAR(10), --FK
		branch_address VARCHAR(60),
		contact_no VARCHAR(10)
	);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(30); 

--Creating employees table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(
		emp_id VARCHAR(10) PRIMARY KEY,
		emp_name VARCHAR(16),
		position VARCHAR(10),
		salary INT,
		branch_id VARCHAR(10) --FK
	);

--Creating books table
DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
	 	isbn VARCHAR(40) PRIMARY KEY,
	 	book_title VARCHAR(80),	
	 	category VARCHAR(10),	
	 	rental_price FLOAT,
	 	status VARCHAR(20),
		author VARCHAR(40),
	 	publisher VARCHAR(80)
	);

ALTER TABLE books
ALTER COLUMN category TYPE VARCHAR(30); 

--Creating members table
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
		member_id VARCHAR(10) PRIMARY KEY,
		member_name	VARCHAR(40),
		member_address VARCHAR(60),
		reg_date DATE
	);

--Creating issued_status table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
		issued_id VARCHAR(10) PRIMARY KEY,
		issued_member_id VARCHAR(10), --FK
		issued_book_name VARCHAR(100),
		issued_date	DATE,
		issued_book_isbn VARCHAR(40),--FK
		issued_emp_id VARCHAR(10) --FK
	);

--Creating return_status table
DROP TABLE IF EXISTS return_status ;
CREATE TABLE return_status
	(
		return_id VARCHAR(10) PRIMARY KEY,
		issued_id VARCHAR(10), --FK
		return_book_name VARCHAR(100),
		return_date DATE,
		return_book_isbn VARCHAR(40)
	);

ALTER TABLE return_status
ALTER COLUMN return_book_isbn TYPE VARCHAR(90); 

--Foreign key
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

SELECT * FROM books
SELECT * FROM branch 
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM return_status

--Project Task
--1.Create a new book record --"'978-1-60129-456-2','To kill a Mockingbird','Classic','6.00','yes','Harper Lee','J.B.Lippincott & Co.'"
INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2','To kill a Mockingbird','Classic','6.00','yes','Harper Lee','J.B.Lippincott & Co.');
SELECT * FROM books;

--2.Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

--3.Delete a record from the Tssued Status Table --objective:Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';
SELECT * FROM issued_status;

--4.Retrieve all Books Issued by a Specipic Employee --Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

--5.List members who have Issued more than one book --Objective: Use GROUP By to find members who have issued more than one book.
SELECT 	issued_member_id --COUNT(issued_member_id) as member_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id)>1;

--CTAS
--6.Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt.
CREATE TABLE book_cnts
as
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN 
	issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_cnts;

--7.Retrieve all Books in Specific category 
SELECT * FROM books 
WHERE category = 'Classic';

--8.Find total rental Income by category 
SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*) 
FROM books as b
JOIN 
	issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

--9.List members who registered in the last 2 years
SELECT *
FROM members
WHERE 
	reg_date >= CURRENT_DATE - INTERVAL '2 years';

--10.List Employees with their branch manager's name and their branch details 
SELECT 
	e1.*,
	h.branch_address ,
	h.manager_id,
	e2.emp_name as manager_name
FROM employees as e1	
JOIN branch as h
ON h.branch_id = e1.branch_id
JOIN 
	employees as e2
ON e2.emp_id = h.manager_id;

--11.Create a table of books with rental price above a certain threshold 7USD
CREATE TABLE books_price_greater_than_7
AS
SELECT *
FROM books
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_7;

--12.Retrieve the list of books not yet returned
SELECT 
	DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as r
ON r.issued_id = ist.issued_id
WHERE return_id IS ;

--13.Identify members with overdue books..
	/*Write a query to identify members who have overdue books (assume a 30day return periad).
	  Display the member's id, member's name, book title, issue date and days overdue.*/

--issued_status == members == books == return_status
--filter books which is return
--overdue > 30

SELECT 
	ist.issued_member_id,
	m.member_name,
	ist.issued_book_name,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN members as m
ON ist.issued_member_id = m.member_id
LEFT JOIN return_status as r
ON r.issued_id = ist.issued_id
WHERE 
	r.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1

--14.Update book status on return
	/*Write a query to update the status of books in the books table to "yes" when they are returned (based on entries in the return_status table).*/
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

INSERT INTO return_status(return_id,issued_id,return_book_name,return_date,return_book_isbn)
VALUES 
	('RS125','IS130','Moby Dick',CURRENT_DATE,'978-0-451-52994-2');
SELECT * FROM return_status
WHERE issued_id = 'IS130';	

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';

--Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10) ,p_issued_id VARCHAR(10) ,p_return_book_name VARCHAR(100) ,p_return_date DATE ,p_return_book_isbn VARCHAR(90))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(40);
	v_book_name VARCHAR(80);

BEGIN 
	--all your logic and code
	--inserting into returns based on users input
	INSERT INTO return_status(return_id,issued_id,return_book_name,return_date,return_book_isbn)
	VALUES 
	(p_return_id,p_issued_id,p_return_book_name,CURRENT_DATE,p_return_book_isbn);

	SELECT 
		issued_book_isbn,
		issued_book_name
		INTO 
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %' , v_book_name ;

END;
$$

CALL add_return_records();

--Testing Function add_return_records

SELECT * FROM issued_status
WHERE issued_id = 'IS135';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

--Colling Function
CALL add_return_records('RS138','IS135','Sapiens: A Brief History of Humankind', CURRENT_DATE ,'978-0-307-58837-1');

SELECT * FROM books
WHERE isbn = '978-0-330-25864-8';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-330-25864-8';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';

--Colling Function
CALL add_return_records('RS139','IS140','Animal Farm', CURRENT_DATE ,'978-0-330-25864-8');

--15.Branch performance report
	/*Create a query that genarates a performance report for each branch, showing the number of books issued, the number of books returned and the total revenue from book rentals.*/
CREATE TABLE branch_report
AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) as number_of_books_issued ,
	COUNT(r.return_id) as number_of_books_returned,
	SUM(bk.rental_price) as total_revenue	
FROM branch as b
JOIN employees as e
ON e.branch_id = b.branch_id
JOIN issued_status as ist
ON ist.issued_emp_id = e.emp_id
LEFT JOIN return_status as r
ON r.issued_id = ist.issued_id
JOIN members as m
ON m.member_id = ist.issued_member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
GROUP BY 1
ORDER BY 1;

SELECT * FROM branch_report;

--16.CTAS: Create a table of active members
	/*Use the create table as (CTAS) statement to create a new table active_members who have issued at least one book in the last 2 years.*/
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN 
	(
		SELECT 
			DISTINCT issued_member_id
		FROM issued_status 
		WHERE 	
			issued_date >= CURRENT_DATE - INTERVAL '2 years'	
	)
ORDER BY 1;

SELECT * FROM active_members;

--17.Find employees with the most book issues processed
	/*Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.*/
SELECT 
	e.*	,
	COUNT(ist.issued_id) AS no_book_issued
FROM employees as e
JOIN issued_status as ist
ON e.emp_id = ist.issued_emp_id
GROUP BY 1
ORDER BY COUNT(ist.issued_id) DESC
LIMIT 3;

--18.Stored procedure objective: Create a stored procedure to manage the status of books in a library system.
	 /*Description: Write a stored procedure that updates the status of a book in the library
	   based on it issuance.
	   The procedure should function as follows: The stored procedure should take the book_id 
	   as an input parameter. The procedure should first check if the book is available 
	   (status = 'yes'). If the book is available, it should be issued and the status in the 
	   books table should be updated to 'no'. If the book is not available (status = 'no'),
	   the procedure should return an error message indicating that the book is currently not available. */
CREATE OR REPLACE PROCEDURE issued_book(p_issued_id VARCHAR(10) ,p_issued_member_id VARCHAR(10) ,p_issued_book_isbn VARCHAR(40),p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	--all the variable
	v_status VARCHAR(10);
BEGIN
	--all your logic and code
	SELECT
		status
		INTO
		v_status
	FROM books 
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN 
		INSERT INTO issued_status (issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		VALUES 
			(p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;
		
		RAISE NOTICE 'Book records added successfully for book isbn : %',p_issued_book_isbn ;
		
	ELSE
		RAISE NOTICE 'Sorry to inform you the book you the book you have requested is unavailable book_isbn : %',p_issued_book_isbn ;

	END IF;
END;
$$

--Colling Function
CALL issued_book('IS155','C108',  '978-0-553-29698-2', 'E103');

CALL issued_book('IS156','C108',  '978-0-7432-7357-1', 'E104');

CALL issued_book('IS156','C108',  '978-0-14-118776-1', 'E104');

--19. Create Table As Select (CTAS)
	/*Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
	Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines*/
CREATE TABLE over_books_and_fines
AS
SELECT 
	ist.issued_member_id,
	m.member_name,
	(CURRENT_DATE - ist.issued_date) as over_dues_days,
	(CURRENT_DATE - ist.issued_date)*0.50 as total_fines	
FROM issued_status as ist
JOIN members as m
ON ist.issued_member_id = m.member_id
LEFT JOIN return_status as r
ON r.issued_id = ist.issued_id
WHERE 
	r.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

SELECT 
	issued_member_id,
	SUM(total_fines)
FROM
	over_books_and_fines
GROUP BY 1
ORDER BY 1;

--20.Identify Members Issuing High-Risk Books  
	/*Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.*/
SELECT 
	m.member_id,
	m.member_name,
	b.book_title,
	COUNT(ist.issued_id) as damaged_issue_count
FROM members as m
JOIN issued_status as ist
ON m.member_id = ist.issued_member_id
JOIN books as b
ON b.isbn = ist.issued_book_isbn
WHERE b.status = 'yes,damaged' OR b.status = 'no,damaged'
GROUP BY m.member_id,m.member_name,b.book_title
HAVING COUNT(ist.issued_id) >= 2
ORDER BY damaged_issue_count DESC;

--We can prepare a update to see above task 
UPDATE books
SET status = 'no,damaged'
WHERE isbn = '978-0-14-118776-1';

SELECT * FROM issued_status;
SELECT * FROM books;