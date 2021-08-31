/* CREATE A NEW ROLE */
CREATE ROLE db_executor

/* GRANT EXECUTE TO THE ROLE */
GRANT EXECUTE TO db_executor
--creates Database Role with execute permissions to all current and future stored procedures and functions
--appears blank when you view this in Database Roles (look at the Permissions at the database level to see it) 
--http://www.sqldbatips.com/showarticle.asp?ID=8