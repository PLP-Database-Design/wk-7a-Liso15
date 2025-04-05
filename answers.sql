-- Create the 1NF table
CREATE TABLE OrderProducts_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Populate the 1NF table using a stored procedure to handle the string splitting
DELIMITER //
CREATE PROCEDURE NormalizeTo1NF()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE o_id INT;
    DECLARE c_name VARCHAR(100);
    DECLARE p_list VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT OrderID, CustomerName, Products FROM ProductDetail;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO o_id, c_name, p_list;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Handle products splitting
        SET @products = p_list;
        SET @pos = 1;
        SET @delim = ',';
        
        WHILE LENGTH(@products) > 0 DO
            SET @product = TRIM(SUBSTRING_INDEX(@products, @delim, 1));
            SET @products = SUBSTRING(@products, LENGTH(@product) + 2);
            
            IF LENGTH(@products) = 0 THEN
                SET @products = '';
            END IF;
            
            INSERT INTO OrderProducts_1NF (OrderID, CustomerName, Product) 
            VALUES (o_id, c_name, @product);
        END WHILE;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;

-- Execute the procedure
CALL NormalizeTo1NF();

-- Verify the 1NF table
SELECT * FROM OrderProducts_1NF;
-- Question 2

-- Step 1: Create Orders table (removes CustomerName from OrderDetails)
CREATE TABLE Orders AS
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 2: Create OrderItems table (keeps only what depends on full PK)
CREATE TABLE OrderItems AS
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Step 3: (Optional) Drop the original table if needed
-- DROP TABLE OrderDetails;    