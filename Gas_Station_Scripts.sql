--DDL SCRIPT - creation of DB, schema and tables with constraints for gas station network.


-----SCHEMA CREATION ----------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS gaspoint_transaction;

-- FUNCTION last_update CREATION------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION gaspoint_transaction.last_update()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.last_update = CURRENT_TIMESTAMP;
    RETURN NEW;
END $$
;
-- TABLE CREATION   -----------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Name: Category; Type: TABLE; Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.category
    (
    category_id SERIAL4 PRIMARY KEY ,
    category_name VARCHAR(30) UNIQUE NOT null ,
    category_description TEXT,
    category_parent_category_id INTEGER DEFAULT NULL REFERENCES gaspoint_transaction.Category(category_id),
    last_update timestamptz NOT NULL DEFAULT now()
    );
 
-- Trigger creation - updating the value of last_update column to current date when any modification (UPDATE, INSERT) is made
DO
$$
BEGIN
    IF EXISTS 
    ( 
    SELECT  event_object_table AS table_name  ,
            trigger_name         
    FROM information_schema.triggers 
    WHERE event_object_table = 'category' AND 
          trigger_name::TEXT = 'last_update'  
    )
    THEN RAISE NOTICE 'The trigger  already exists';
    ELSE 
        CREATE TRIGGER  last_update 
        BEFORE UPDATE
            ON  gaspoint_transaction.category 
            FOR EACH ROW 
            EXECUTE FUNCTION gaspoint_transaction.last_update();
     END IF;    
END $$;




-- Name: Product; Type: TABLE; Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.product
    (
    product_id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(20) NOT NULL UNIQUE,
    product_category_id INTEGER NOT NULL REFERENCES gaspoint_transaction.category(category_id),
    product_unit_price_pln DECIMAL NOT NULL ,
    last_update timestamptz NOT NULL DEFAULT now()
    );

-- Trigger creation - updating the value of last_update column to current date when any modification (UPDATE, INSERT) is made
DO
$$
BEGIN
    IF EXISTS 
    ( 
    SELECT  event_object_table AS table_name  ,
            trigger_name         
    FROM information_schema.triggers 
    WHERE event_object_table = 'product' AND 
          trigger_name::TEXT = 'last_update'  
    )
    THEN RAISE NOTICE 'The trigger already exists';
    ELSE 
        CREATE TRIGGER  last_update 
        BEFORE UPDATE
            ON  gaspoint_transaction.product
            FOR EACH ROW 
            EXECUTE FUNCTION last_update();
     END IF;    
END $$;





-- Name: Position;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction."position"
    (
    position_id BIGSERIAL PRIMARY KEY,
    position_name VARCHAR(20) NOT NULL DEFAULT 'Junior Cashier',
    position_band CHAR(1) NOT NULL DEFAULT 'A',
    position_wage_monthly_gross DECIMAL NOT NULL,
    last_update timestamptz NOT NULL DEFAULT now()   
    );

-- Trigger creation - updating the value of last_update column to current date when any modification (UPDATE, INSERT) is made
DO
$$
BEGIN
    IF EXISTS 
    ( 
    SELECT  event_object_table AS table_name  ,
            trigger_name         
    FROM information_schema.triggers 
    WHERE event_object_table = 'position' AND 
          trigger_name::TEXT = 'last_update'  
    )
    THEN RAISE NOTICE 'The trigger already exists';
    ELSE 
        CREATE TRIGGER  last_update 
        BEFORE UPDATE
            ON  gaspoint_transaction."position"
            FOR EACH ROW 
            EXECUTE FUNCTION last_update();
     END IF;    
END $$;




-- Name: Staff;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.Staff
    (
    staff_id SERIAL4 PRIMARY KEY,
    staff_name VARCHAR(40) NOT NULL,
    staff_gender CHAR(1) NOT NULL,
    staff_date_of_birth DATE NOT NULL,  
    staff_date_of_hiring DATE NOT NULL DEFAULT current_date,
    staff_position_id INTEGER REFERENCES gaspoint_transaction."position"(position_id),
    last_update timestamptz NOT NULL DEFAULT now()   
    );
    
-- Trigger creation - updating the value of last_update column to current date when any modification (UPDATE, INSERT) is made
DO
$$
BEGIN
    IF EXISTS 
    ( 
    SELECT  event_object_table AS table_name  ,
            trigger_name         
    FROM information_schema.triggers 
    WHERE event_object_table = 'staff' AND 
          trigger_name::TEXT = 'last_update'  
    )
    THEN RAISE NOTICE 'The trigger already exists';
    ELSE 
        CREATE TRIGGER  last_update 
        BEFORE UPDATE
            ON  gaspoint_transaction.staff
            FOR EACH ROW 
            EXECUTE FUNCTION last_update();
     END IF;    
END $$;




-- Name: Station;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.Station
    (
    station_id SERIAL4 PRIMARY KEY,
    station_name VARCHAR(30) NOT NULL UNIQUE,
    station_capacity  SMALLINT NOT NULL,
    station_address VARCHAR(30) NOT NULL UNIQUE,
    last_update timestamptz NOT NULL DEFAULT now()   
    );
  
-- Trigger creation - updating the value of last_update column to current date when any modification (UPDATE, INSERT) is made
DO
$$
BEGIN
    IF EXISTS 
    ( 
    SELECT  event_object_table AS table_name  ,
            trigger_name         
    FROM information_schema.triggers 
    WHERE event_object_table = 'station' AND 
          trigger_name::TEXT = 'last_update'  
    )
    THEN RAISE NOTICE 'The trigger already exists';
    ELSE 
        CREATE TRIGGER  last_update 
        BEFORE UPDATE
            ON  gaspoint_transaction.station
            FOR EACH ROW 
            EXECUTE FUNCTION last_update();
     END IF;    
END $$;



-- Name: Client;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.Client
    (
    client_id BIGSERIAL PRIMARY KEY,
    client_company_name VARCHAR(50) NOT NULL UNIQUE,
    client_nip BIGINT NOT NULL,
    client_company_address VARCHAR(30) NOT NULL,
    client_company_phone VARCHAR(15) NOT NULL ,
    client_company_email VARCHAR(30) NOT NULL,
    last_update timestamptz NOT NULL DEFAULT now()  
    );

-- Trigger creation - updating the value of last_update column to current date when any modification (UPDATE, INSERT) is made
DO
$$
BEGIN
    IF EXISTS 
    ( 
    SELECT  event_object_table AS table_name,
            trigger_name         
    FROM information_schema.triggers 
    WHERE event_object_table = 'client' AND 
          trigger_name::TEXT = 'last_update'  
    )
    THEN RAISE NOTICE 'The trigger already exists';
    ELSE 
        CREATE TRIGGER  last_update 
        BEFORE UPDATE
            ON  gaspoint_transaction.client
            FOR EACH ROW 
            EXECUTE FUNCTION last_update();
     END IF;    
END $$;


-- Name: Invoice;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.Invoice
    (
    invoice_id BIGSERIAL PRIMARY KEY,
    invoice_number VARCHAR(10) NOT NULL UNIQUE,
    invoice_client_id INTEGER NOT NULL REFERENCES gaspoint_transaction.Client(client_id),
    invoice_date_of_issue DATE NOT NULL DEFAULT current_date,
    invoice_payment_terms_days INTEGER NOT NULL DEFAULT 30,
    invoice_tax_rate_percentage INTEGER NOT NULL DEFAULT 23 
    );
    

-- Name: Payment;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.Payment
    (
    payment_id BIGSERIAL PRIMARY KEY,
    payment_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    payment_staff_id INTEGER NOT NULL REFERENCES  gaspoint_transaction.Staff(staff_id),
    payment_method VARCHAR(13) NOT NULL,
    payment_amount_PLN DECIMAL NOT NULL,
    payment_invoice_id INTEGER DEFAULT NULL REFERENCES gaspoint_transaction.Invoice(invoice_id)
    );
    
-- Name: Transaction;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction."Transaction"
    (
    transaction_id BIGSERIAL PRIMARY KEY,
    transaction_date_time TIMESTAMP  NOT NULL DEFAULT now(),
    transaction_station_id INTEGER NOT NULL REFERENCES gaspoint_transaction.Station(station_id),
    transaction_staff_id INTEGER NOT NULL REFERENCES  gaspoint_transaction.Staff(staff_id),
    transaction_payment_id INTEGER NOT NULL REFERENCES gaspoint_transaction.Payment(payment_id)
    );
    

-- Name: Product_List;  Type: TABLE;    Schema: gaspoint_transaction

CREATE TABLE IF NOT EXISTS gaspoint_transaction.Product_List
    (
    product_list_id BIGSERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES gaspoint_transaction."Transaction"(transaction_id),
    product_id INTEGER NOT NULL REFERENCES gaspoint_transaction.Product(product_id),
    product_amount DECIMAL NOT NULL,
    product_total_cost DECIMAL  NOT NULL 
    );



-- ADDING CONSTRAINTS -----------------------------------------------------------------------------------------------------------------------------

-- Table:  position (checking the wage is bigger than zero)
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'position'     AND 
                    constraint_name = 'wage_not_null')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction."position"
    ADD CONSTRAINT wage_not_null CHECK (position_wage_monthly_gross > 0) ;
END IF;
END $$;

-- Table:  staff (checkinkg the gender)
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'staff'     AND 
                    constraint_name = 'staff_gender_check')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Staff
    ADD CONSTRAINT staff_gender_check CHECK (staff_gender IN ('F', 'M', 'D')) ;
END IF;
END $$;

-- Table:  staff (checkinkg the age - only adult employees)
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'staff'     AND 
                    constraint_name = 'adult_employee_check')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Staff
    ADD CONSTRAINT adult_employee_check CHECK ((staff_date_of_birth + INTERVAL '18 years') < current_date) ;
END IF;
END $$;


-- Table:  station (checkinkg the minimum number of car-filling spots on each petrol station)
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'station'     AND 
                    constraint_name = 'station_capacity_check')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Station
    ADD CONSTRAINT station_capacity_check CHECK (station_capacity >=3) ;
END IF;
END $$;


-- Table:  client (checkinkg the NIP number /taxpayer identification number/ - cannot be zero )
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'client'     AND 
                    constraint_name = 'client_nip_not_zero')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Client
    ADD CONSTRAINT client_nip_not_zero CHECK (client_nip  > 0) ;
END IF;
END $$;


-- Table:  Invoice (checkinkg the payment terms which has to be 7, 21 ,30 or  90 days )
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'invoice'     AND 
                    constraint_name = 'payment_term_days')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Invoice
    ADD CONSTRAINT payment_term_days CHECK (invoice_payment_terms_days IN(7, 21 ,30 , 90)) ;
END IF;
END $$;

-- Table:  Invoice (checkinkg tax rate has to be bigger than zero )
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'invoice'     AND 
                    constraint_name = 'tax_rate_percentage')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Invoice
    ADD CONSTRAINT tax_rate_percentage CHECK (invoice_tax_rate_percentage > 0) ;
END IF;
END $$;

-- Table:  Payment (checkinkg tax rate has to be bigger than zero )
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'payment'     AND 
                    constraint_name = 'payment_method_list')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Payment
    ADD CONSTRAINT payment_method_list CHECK (payment_method IN ('cash', 'bank transfer', 'card', 'coupon')) ;
END IF;
END $$;


-- Table:  Payment (checkinkg payment amount which has to be bigger than zero )
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'payment'     AND 
                    constraint_name = 'payment_amount_not_zero')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.Payment
    ADD CONSTRAINT payment_amount_not_zero CHECK (payment_amount_PLN > 0) ;
END IF;
END $$;


-- Table:  Product_List (checkinkg total cost which has to be bigger than zero )
DO $$
BEGIN
IF EXISTS ( SELECT table_name, constraint_name 
            FROM information_schema.table_constraints 
            WHERE   table_name = 'product_list'     AND 
                    constraint_name = 'total_cost_not_zero')
THEN RAISE NOTICE 'The constraint already exists';
ELSE
    ALTER TABLE gaspoint_transaction.product_list
    ADD CONSTRAINT total_cost_not_zero CHECK (product_total_cost > 0) ;
END IF;
END $$;




--DML SCRIPT : INSERTING DATA - Adding fictional data to my database (5+ rows per table, 50+ rows total across all tables)------------------------------------------------------------

-- Table : Category -- needed to split the insert statemnet into two steps - first for main categories (parent categories) and second for the rest
WITH new_category AS(
    SELECT  'petrol' AS category_name, 
            'Includes all liquid fuel' AS category_description
    UNION ALL
    SELECT  'beverages',
            'Includes water, juices, alcohol and coctails. Also, coffee and tea prepared on the spot, execpt dry tea and coffee to sefl-preparation'
    UNION ALL
    SELECT  'ice_cream',
            'Includes all type of ice_cream available')
     
INSERT INTO gaspoint_transaction.category (category_name, category_description)
SELECT * 
FROM new_category
WHERE NOT EXISTS (SELECT  category_name  
                  FROM gaspoint_transaction.category 
                  WHERE category_name IN ('petrol', 'beverages','ice_cream'));

WITH new_category AS(
    SELECT  'lead_free',
            'liquid petrol lead free E5 or E10 type',
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'petrol')
    UNION ALL
    SELECT  'diesel',
            'Used only in diesel engines',
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'petrol'))
     
INSERT INTO gaspoint_transaction.category (category_name, category_description, category_parent_category_id)
SELECT * 
FROM new_category
WHERE NOT EXISTS (SELECT  category_name  
                  FROM gaspoint_transaction.category 
                  WHERE category_name IN ('lead_free','diesel'));
                       
--SELECT * FROM gaspoint_transaction.category c2 


              
-- Table : Product             

WITH new_product AS (
    SELECT  'BigMilk_100g' AS product_name,
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'ice_cream') AS product_category_id,
            3.99 AS product_unit_price_pln
    UNION ALL
    SELECT  'BigMilk_200g',
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'ice_cream'), 
            5.99
    UNION ALL
    SELECT  'Bonaqua_2l',
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'beverages'),
            5.50     
    UNION ALL
    SELECT  'B7',
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'diesel'),
            8.50      
    UNION ALL
    SELECT  'B10',
            (SELECT category_id  FROM gaspoint_transaction.category c WHERE c.category_name = 'diesel'),
            10.50 )
INSERT INTO gaspoint_transaction.product (product_name, product_category_id, product_unit_price_pln)
SELECT * 
FROM new_product 
WHERE NOT EXISTS (SELECT product_name 
                  FROM gaspoint_transaction.product 
                  WHERE product_name  IN ('BigMilk_100g', 'BigMilk_200g', 'Bonaqua_2l','B7','B10'));
              
-- SELECT  * FROM  gaspoint_transaction.product

              
-- Table : Position
              
WITH new_position AS (
    SELECT  'facility manager' AS position_name,
            'C'     AS position_band,
            6000    AS position_wage_monthly_gross
    UNION ALL
    SELECT  'reginal leader',
            'D',
            7500
    UNION ALL
    SELECT  'senior cashier',
            'B',
            4000
    UNION ALL
    SELECT  'cashier',
            'B',
            3000
    UNION ALL
        SELECT  'assistant',
            'A',
            2000)
INSERT INTO gaspoint_transaction."position" (position_name, position_band, position_wage_monthly_gross)
SELECT *
FROM new_position 
WHERE NOT EXISTS (SELECT position_name 
                  FROM gaspoint_transaction."position"
                  WHERE position_name  IN ('facility manager', 'reginal leader', 'senior cashier','cashier','assistant'));
 -- SELECT * FROM gaspoint_transaction."position" p 
                  
              
-- Table : Staff
              
WITH new_staff AS (
    SELECT  'Anna Nowak'    AS staff_name,
            'F'             AS staff_gender,
            '2000-12-12'::DATE    AS staff_date_of_birth,
            '2018-10-13'::DATE    AS staff_date_of_hiring,
            (SELECT position_id FROM gaspoint_transaction."position" p WHERE position_name = 'facility manager') AS staff_position_id
    UNION ALL
    SELECT  'Monika Buczek',
            'F',
            '1989-12-17'::DATE,
            '2022-03-13'::DATE,
            (SELECT position_id FROM gaspoint_transaction."position" p WHERE position_name = 'reginal leader')
    UNION ALL              
    SELECT  'Ludmila Bobek',
            'F' ,
            '1966-03-12'::DATE,
            '2021-05-13'::DATE,
            (SELECT position_id FROM gaspoint_transaction."position" p WHERE position_name = 'senior cashier')
    UNION ALL
    SELECT  'Jan Kowalczyk',
            'M',
            '2001-12-11'::DATE,
            '2019-08-13'::DATE,
            (SELECT position_id FROM gaspoint_transaction."position" p WHERE position_name = 'cashier')
    UNION ALL
    SELECT  'Jakub Zajac' ,
            'M' ,
            '2003-12-12'::DATE,
            '2023-12-15'::DATE,
            (SELECT position_id FROM gaspoint_transaction."position" p WHERE position_name = 'cashier'))
INSERT INTO gaspoint_transaction.staff ( staff_name,staff_gender,staff_date_of_birth,staff_date_of_hiring,staff_position_id)
SELECT *
FROM new_staff 
WHERE NOT EXISTS (SELECT staff_name, staff_date_of_birth
                  FROM gaspoint_transaction.staff
                  WHERE (staff_name = 'Anna Nowak'      AND staff_date_of_birth = '2000-12-12')  OR
                        (staff_name = 'Monika Buczek'   AND staff_date_of_birth = '1989-12-17')  OR
                        (staff_name = 'Ludmila Bobek'   AND staff_date_of_birth = '1966-03-12')  OR
                        (staff_name = 'Jan Kowalczyk'   AND staff_date_of_birth = '2001-12-11')  OR
                        (staff_name = 'Jakub Zajac'     AND staff_date_of_birth = '2003-12-12'));
--SELECT * FROM gaspoint_transaction.staff s2 
                    
                    
 -- Table : Station
              
WITH new_station AS (  
    SELECT  'Bytom Centrum'  AS station_name,
            3                AS station_capacity,
            'Zamek 7 44-200 Bytom'   AS station_address
    UNION ALL 
    SELECT  'Zabrze Centrum',
            3,
            'Wolna 10 44-200 Zabrze'
    UNION ALL 
    SELECT  'Zabrze Zajezdnia',
            10,
            'Mila 15 44-300 Zabrze'
    UNION ALL 
    SELECT  'Supersam Katowice',
            6,
            'Dluga 111 41-100 Katowice'
    UNION ALL 
    SELECT  'Straz Katowice',
            5,
            'Waska 21 41-120 Katowice')
INSERT INTO gaspoint_transaction.station (station_name,station_capacity,station_address)
SELECT *
FROM new_station 
WHERE NOT EXISTS (SELECT station_name
                  FROM gaspoint_transaction.station s 
                  WHERE station_name IN ('Bytom Centrum','Zabrze Centrum','Zabrze Zajezdnia','Supersam Katowice','Straz Katowice'));
-- SELECT * FROM gaspoint_transaction.station s 
              

-- Table : Client
              
WITH new_client AS (
    SELECT  'Pirotox Sp. z o.o.'      AS client_company_name,
            789000456               AS client_nip,
            'Dluga 1/2 43-200 Rybnik' AS client_company_address,
            '+48507508966'            AS client_company_phone,
            'office@pirotox.com.pl'   AS client_company_email
    UNION ALL
    SELECT  'Pyrex   Sp. z o.o.',
            7893454221,
            'Szara   43-203 Rybnik',
            '+4850456768',
            'office@pyrex.com.pl'
    UNION ALL
    SELECT  'Ameba Group Sp. z o.o.',
            7892226665,
            'Zielona 8 43-212 Katowice',
            '+48609789321',
            'office@ameba.com.pl'
    UNION ALL
    SELECT  'Health&Beauty Sp. z o.o.',
            7896321474,
            'Biala 13 42-122 Glody',
            '+4860564231',
            'office@handb.com.pl'
    UNION ALL
    SELECT  'Totek Lotek Sp. z o.o.',
            797856321 ,
            'Zolta 22 21-765 Mirki',
            '+4860564231',
            'office@totek.com.pl')
INSERT INTO gaspoint_transaction.client (client_company_name, client_nip, client_company_address, client_company_phone, client_company_email)
SELECT *
FROM new_client
WHERE NOT EXISTS ( SELECT client_company_name
                   FROM gaspoint_transaction.client c
                   WHERE client_company_name IN ('Pirotox Sp. z o.o.','Pyrex   Sp. z o.o.','Ameba Group Sp. z o.o.','Health&Beauty Sp. z o.o.','Totek Lotek Sp. z o.o.'));
    
-- SELECT * FROM gaspoint_transaction.client c 
               

-- Table : Invoice
              
WITH new_invoice AS (      
    SELECT  '202304/001' AS invoice_number,
            (SELECT client_id FROM gaspoint_transaction.client c WHERE client_nip = 789000456 ) AS invoice_client_id,
            '2023-04-12'::DATE    AS invoice_date_of_issue,
            7   AS invoice_payment_terms_days,
            23  AS invoice_tax_rate_percentage
    UNION ALL 
    SELECT  '202304/002',
            (SELECT client_id FROM gaspoint_transaction.client c WHERE client_nip = 7893454221 ),
            '2023-04-14'::DATE,
            7 ,
            8   
    UNION ALL 
    SELECT  '202304/003',
            (SELECT client_id FROM gaspoint_transaction.client c WHERE client_nip = 7892226665 ),
            '2023-04-16'::DATE,
            21 ,
            8   
    UNION ALL 
    SELECT  '202304/004',
            (SELECT client_id FROM gaspoint_transaction.client c WHERE client_nip = 7896321474 ),
            '2023-04-18'::DATE,
            30 ,
            23 
    UNION ALL 
    SELECT  '202304/005',
            (SELECT client_id FROM gaspoint_transaction.client c WHERE client_nip = 797856321 ),
            '2023-04-19'::DATE,
            90 ,
            23 )
            
INSERT INTO gaspoint_transaction.invoice (invoice_number,invoice_client_id, invoice_date_of_issue, invoice_payment_terms_days,invoice_tax_rate_percentage)
SELECT *
FROM new_invoice
WHERE NOT EXISTS ( SELECT invoice_number
                   FROM gaspoint_transaction.invoice
                   WHERE invoice_number IN ('202304/001', '202304/002', '202304/003','202304/004', '202304/005'));
-- SELECT * FROM gaspoint_transaction.invoice i 
   

                
               

 -- Table : Payment
              
WITH new_payment AS ( 
    SELECT 'cash'   AS payment_method,
            (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Anna Nowak'      AND staff_date_of_birth = '2000-12-12'),
            125.50  AS payment_amount_pln,
            (SELECT invoice_id FROM gaspoint_transaction.invoice i WHERE invoice_number = '202304/001') AS payment_invoice_id
    UNION ALL       
    SELECT 'bank transfer',
            (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Monika Buczek'   AND staff_date_of_birth = '1989-12-17'),
            1360.56,
            (SELECT invoice_id FROM gaspoint_transaction.invoice i WHERE invoice_number = '202304/002')          
    UNION ALL       
    SELECT 'card',
            (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Ludmila Bobek'   AND staff_date_of_birth = '1966-03-12'),
            456.78,
            (SELECT invoice_id FROM gaspoint_transaction.invoice i WHERE invoice_number = '202304/003')             
    UNION ALL       
    SELECT 'card',
            (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Jan Kowalczyk'   AND staff_date_of_birth = '2001-12-11'),
            456.98,
            (SELECT invoice_id FROM gaspoint_transaction.invoice i WHERE invoice_number = '202304/004')   
    UNION ALL       
    SELECT 'card',
            (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Jakub Zajac'     AND staff_date_of_birth = '2003-12-12'),
            894.45,
            (SELECT invoice_id FROM gaspoint_transaction.invoice i WHERE invoice_number = '202304/005'))
INSERT INTO gaspoint_transaction.payment (payment_method, payment_staff_id, payment_amount_pln, payment_invoice_id)
SELECT *
FROM new_payment
WHERE NOT EXISTS (SELECT payment_invoice_id 
                  FROM gaspoint_transaction.payment p 
                  WHERE payment_invoice_id IN (SELECT invoice_id 
                                                FROM gaspoint_transaction.invoice i 
                                                WHERE invoice_number IN ('202304/001','202304/002','202304/003','202304/004','202304/005')));
                                            
-- I also added some payments which are not attached to an invoice - these payment are done in a facility by a random customer
INSERT INTO gaspoint_transaction.payment (payment_method, payment_amount_pln, payment_staff_id)
VALUES ('cash', 123.80, (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Anna Nowak'      AND staff_date_of_birth = '2000-12-12')),
       ('cash', 226.50, (SELECT staff_id FROM gaspoint_transaction.staff s  WHERE staff_name = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17')),
       ('cash', 13.20 , (SELECT staff_id FROM gaspoint_transaction.staff s  WHERE staff_name = 'Ludmila Bobek'  AND staff_date_of_birth = '1966-03-12')),
       ('card', 557.00, (SELECT staff_id FROM gaspoint_transaction.staff s WHERE staff_name = 'Jan Kowalczyk'   AND staff_date_of_birth = '2001-12-11')),
       ('card', 457.00, (SELECT staff_id FROM gaspoint_transaction.staff s  WHERE staff_name = 'Jakub Zajac'    AND staff_date_of_birth = '2003-12-12'));
-- SELECT * FROM gaspoint_transaction.payment p 
    


 -- Table : "Transaction"  - each transaction is conected with a payment. Payment is identified not by its ID (it would be hardcoding), but by the combination of time and staff member
                             --( one person cannot carry out more that one payment/transaction at one time) 

             
WITH new_transaction AS ( 
    SELECT (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Bytom Centrum')    AS transaction_station_id,
           (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AS transaction_staff_id,
           (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_invoice_id IS NULL AND 
                                                                         payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                   staff_date_of_birth = '2000-12-12')) AS transaction_payment_id
    UNION ALL 
    SELECT (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Zabrze Centrum'),
           (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Monika Buczek' AND staff_date_of_birth = '1989-12-17'),
           (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_invoice_id IS NULL AND 
                                                                         payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                   staff_date_of_birth = '1989-12-17')) 
    UNION ALL 
    SELECT (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Zabrze Zajezdnia') ,
           (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Jan Kowalczyk'   AND staff_date_of_birth = '2001-12-11'),       
           (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_invoice_id IS NULL AND 
                                                                         payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Jan Kowalczyk'  AND 
                                                                                                   staff_date_of_birth = '2001-12-11'))       
    UNION ALL 
    SELECT (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Supersam Katowice'),
           (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name = 'Ludmila Bobek'   AND staff_date_of_birth = '1966-03-12'),
           (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_invoice_id IS NULL AND 
                                                                         payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Ludmila Bobek'  AND 
                                                                                                   staff_date_of_birth = '1966-03-12'))                                            
    UNION ALL 
    SELECT (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Straz Katowice'),
           (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Jakub Zajac'     AND staff_date_of_birth = '2003-12-12'),
           (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_invoice_id IS NULL AND 
                                                                         payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Jakub Zajac'  AND 
                                                                                                   staff_date_of_birth = '2003-12-12')))  
INSERT INTO gaspoint_transaction."Transaction" (transaction_station_id, transaction_staff_id,transaction_payment_id)
SELECT *
FROM new_transaction
WHERE NOT EXISTS (SELECT transaction_station_id, transaction_staff_id,transaction_payment_id
                  FROM gaspoint_transaction."Transaction" t 
                  WHERE ( transaction_station_id = (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Bytom Centrum') AND
                          transaction_staff_id   = (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND 
                          transaction_payment_id = (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                   staff_date_of_birth = '2000-12-12')))
                          OR
                          (transaction_station_id = (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Zabrze Centrum') AND
                           transaction_staff_id   = (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Monika Buczek' AND staff_date_of_birth = '1989-12-17') AND 
                           transaction_payment_id = (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                   staff_date_of_birth = '1989-12-17'))) 
                          OR 
                          (transaction_station_id = (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Zabrze Zajezdnia') AND
                           transaction_staff_id   = (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Jan Kowalczyk'   AND staff_date_of_birth = '2001-12-11') AND 
                           transaction_payment_id = (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Jan Kowalczyk'  AND 
                                                                                                   staff_date_of_birth = '2001-12-11')))
                          OR 
                          (transaction_station_id = (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Supersam Katowice') AND
                           transaction_staff_id   = (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name = 'Ludmila Bobek'   AND staff_date_of_birth = '1966-03-12') AND 
                           transaction_payment_id =  (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Ludmila Bobek'  AND 
                                                                                                   staff_date_of_birth = '1966-03-12')))    
                          OR
                          (transaction_station_id = (SELECT station_id FROM gaspoint_transaction.station s WHERE station_name = 'Straz Katowice') AND
                           transaction_staff_id   = (SELECT staff_id   FROM gaspoint_transaction.staff s2  WHERE staff_name   = 'Jakub Zajac'     AND staff_date_of_birth = '2003-12-12') AND 
                           transaction_payment_id =  (SELECT payment_id FROM gaspoint_transaction.payment p WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND
                                                                         payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                         payment_staff_id = (SELECT staff_id   
                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                             WHERE staff_name   = 'Jakub Zajac'  AND 
                                                                                                   staff_date_of_birth = '2003-12-12'))));
--SELECT * FROM gaspoint_transaction."Transaction" t 
                      



-- Table : product_list -- link table - contains the list of products bought in each transaction
WITH new_product_list AS (
    SELECT (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND
                                                                                   transaction_payment_id = ( SELECT payment_id 
                                                                                                              FROM gaspoint_transaction.payment p 
                                                                                                              WHERE payment_invoice_id IS NULL AND payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                    payment_staff_id = ( SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                                                               staff_date_of_birth = '2000-12-12')))) AS transaction_id,                                                                     
           (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'BigMilk_100g') AS product_id,
           3 AS product_amount,
           (SELECT 3 * product_unit_price_pln FROM gaspoint_transaction.product p2 WHERE product_name = 'BigMilk_100g') AS product_total_cost

    UNION ALL 
    SELECT (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND
                                                                                   transaction_payment_id = ( SELECT payment_id 
                                                                                                              FROM gaspoint_transaction.payment p 
                                                                                                              WHERE payment_invoice_id IS NULL AND payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                    payment_staff_id = ( SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                                                               staff_date_of_birth = '2000-12-12')))), 
           (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'BigMilk_200g'),
           2 AS product_amount,
           (SELECT 2 * product_unit_price_pln FROM gaspoint_transaction.product p2 WHERE product_name = 'BigMilk_200g')
    UNION ALL 
    SELECT (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND
                                                                                   transaction_payment_id = ( SELECT payment_id 
                                                                                                              FROM gaspoint_transaction.payment p 
                                                                                                              WHERE payment_invoice_id IS NULL AND payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                    payment_staff_id = ( SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                                                               staff_date_of_birth = '2000-12-12')))),
           (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'B7'),
           20,
           (SELECT 20 * product_unit_price_pln FROM gaspoint_transaction.product p2 WHERE product_name = 'B7')  
           
           
           
    UNION ALL 
    SELECT (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17') AND
                                                                                   transaction_payment_id = (SELECT payment_id 
                                                                                                             FROM gaspoint_transaction.payment p 
                                                                                                             WHERE payment_invoice_id IS NULL AND payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                   payment_staff_id = (  SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                                                               staff_date_of_birth = '1989-12-17')))),                                                                                                                                  
           (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'Bonaqua_2l') AS product_id,
           6 AS product_amount,
           (SELECT 6 * product_unit_price_pln FROM gaspoint_transaction.product p2 WHERE product_name = 'Bonaqua_2l') AS product_total_cost
    UNION ALL 
    SELECT (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17') AND
                                                                                   transaction_payment_id = (SELECT payment_id 
                                                                                                             FROM gaspoint_transaction.payment p 
                                                                                                             WHERE payment_invoice_id IS NULL AND payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                   payment_staff_id = (  SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                                                               staff_date_of_birth = '1989-12-17')))),
           (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'BigMilk_200g') AS product_id,
           1 AS product_amount,
           (SELECT 1 * product_unit_price_pln FROM gaspoint_transaction.product p2 WHERE product_name = 'BigMilk_200g') AS product_total_cost
    UNION ALL 
    SELECT (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17') AND
                                                                                   transaction_payment_id = (SELECT payment_id 
                                                                                                             FROM gaspoint_transaction.payment p 
                                                                                                             WHERE payment_invoice_id IS NULL AND payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                   payment_staff_id = (  SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                                                               staff_date_of_birth = '1989-12-17')))),
           (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'B7') AS product_id,
           25 AS product_amount,
           (SELECT 25 * product_unit_price_pln FROM gaspoint_transaction.product p2 WHERE product_name = 'B7'))
INSERT INTO gaspoint_transaction.product_list  (transaction_id, product_id, product_amount, product_total_cost)
SELECT * 
FROM new_product_list
WHERE NOT EXISTS ( SELECT transaction_id, product_id
                   FROM gaspoint_transaction.product_list pl 
                   WHERE  (transaction_id = (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND
                                                                                   transaction_payment_id = ( SELECT payment_id 
                                                                                                              FROM gaspoint_transaction.payment p 
                                                                                                              WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                    payment_staff_id = ( SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                                                               staff_date_of_birth = '2000-12-12'))))
                         AND product_id =  (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'BigMilk_100g'))
                        OR 
                         (transaction_id = (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND
                                                                                   transaction_payment_id = ( SELECT payment_id 
                                                                                                              FROM gaspoint_transaction.payment p 
                                                                                                              WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                    payment_staff_id = ( SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                                                               staff_date_of_birth = '2000-12-12'))))
                         AND product_id =  (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'BigMilk_200g'))
                        OR 
                         (transaction_id = (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Anna Nowak'  AND staff_date_of_birth = '2000-12-12') AND
                                                                                   transaction_payment_id = ( SELECT payment_id 
                                                                                                              FROM gaspoint_transaction.payment p 
                                                                                                              WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                    payment_staff_id = ( SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Anna Nowak'  AND 
                                                                                                                                               staff_date_of_birth = '2000-12-12'))))
                         AND product_id =  (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'B7'))
                        OR 
                         (transaction_id = (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17') AND
                                                                                   transaction_payment_id = (SELECT payment_id 
                                                                                                             FROM gaspoint_transaction.payment p 
                                                                                                             WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                   payment_staff_id = (  SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                                                               staff_date_of_birth = '1989-12-17'))))
                         AND product_id = (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'Bonaqua_2l'))
                        OR
                         (transaction_id = (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17') AND
                                                                                   transaction_payment_id = (SELECT payment_id 
                                                                                                             FROM gaspoint_transaction.payment p 
                                                                                                             WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                   payment_staff_id = (  SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                                                               staff_date_of_birth = '1989-12-17'))))
                         AND product_id = (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'BigMilk_200g'))
                        OR
                         (transaction_id = (SELECT transaction_id FROM gaspoint_transaction."Transaction"  WHERE (transaction_staff_id   = ( SELECT staff_id   
                                                                                                             FROM gaspoint_transaction.staff s2  
                                                                                                             WHERE staff_name   = 'Monika Buczek'  AND staff_date_of_birth = '1989-12-17') AND
                                                                                   transaction_payment_id = (SELECT payment_id 
                                                                                                             FROM gaspoint_transaction.payment p 
                                                                                                             WHERE payment_date >= (current_timestamp - INTERVAL '1 second')  AND payment_date < (current_timestamp  + INTERVAL '1 second') AND
                                                                                                                   payment_staff_id = (  SELECT staff_id   
                                                                                                                                         FROM gaspoint_transaction.staff s2  
                                                                                                                                         WHERE staff_name   = 'Monika Buczek'  AND 
                                                                                                                                               staff_date_of_birth = '1989-12-17'))))
                         AND product_id = (SELECT product_id FROM gaspoint_transaction.product p WHERE product_name = 'B7'))); 
                                                                                   
 -- select * from gaspoint_transaction.product_list pl 
           
 
                     
 -- FUNCTIONS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                    
/*
Create the following functions:
• Function that UPDATEs data in one of your tables (input arguments: table's primary key value, column name and column value to UPDATE to).
• Function that adds new transaction to your transaction table. Come up with input arguments and output format yourself. Make sure all transaction
attributes can be set with the function (via their natural keys). 
*/

                     
-- • Function which updates table: gaspoint_transaction.station 
                     
CREATE OR REPLACE FUNCTION gaspoint_transaction.update_station
    (
    IN update_station_name VARCHAR(30),
    IN update_column_name VARCHAR,
    IN update_value VARCHAR
    ) 
RETURNS VOID
LANGUAGE plpgsql

AS 
$f$
DECLARE
    v_station_id INTEGER;

BEGIN
    SELECT station_id 
    FROM gaspoint_transaction.station s 
    WHERE trim(lower(station_name)) = trim(lower(update_station_name))
    INTO V_station_id;

    EXECUTE 'UPDATE gaspoint_transaction.station s
             SET ' || update_column_name || ' = ' || update_value || ' WHERE s.station_id = ' || v_station_id ;
    
    RAISE NOTICE 'You have just updated data for % . The new % is %' ,
                  update_station_name,update_column_name,update_value;
END;
$f$ ;

--   Calling a function:  SELECT * FROM update_station('Bytom Centrum', 'station_capacity', '6');
--   Check:    SELECT * FROM gaspoint_transaction.station s 
                                                                  

-- • Function that adds new transaction to your transaction table.
    
-- I decided to create a function for payment table. 

CREATE OR REPLACE FUNCTION new_transaction 
    (
    IN p_staff_name VARCHAR(40),
    IN p_method VARCHAR(13),
    IN product_ids INTEGER[],           --this variable IS an ARRAY WITH CONTAINS  ids OF products being bought BY a customer
    IN quantity INTEGER[]               -- the number OF products 
    )
RETURNS VOID
LANGUAGE plpgsql
AS 
$$
DECLARE
    unit_cost DECIMAL := 0;
    total_cost DECIMAL := 0;
    new_payment_id INTEGER :=0;
BEGIN
    FOR i IN 1..array_length(product_ids, 1)                                        -- one OF the POSITION IN payment TABLE IS amount, which IS calulated AS a SUM OF 'basket' , 
    LOOP                                                                            -- so my first step as to calculate the total sum of products bought by the custmer        
        SELECT product_unit_price_pln * quantity[i] INTO unit_cost
        FROM gaspoint_transaction.product
        WHERE product_id  = product_ids[i];
    
        total_cost := total_cost + unit_cost;
    END LOOP;

    INSERT INTO gaspoint_transaction.payment (payment_staff_id, payment_method, payment_amount_pln)
    VALUES  ((SELECT staff_id FROM gaspoint_transaction.staff WHERE trim(lower(staff_name)) = trim(lower(p_staff_name))),
        p_method,
        total_cost)
    RETURNING payment_id INTO new_payment_id;

    RAISE NOTICE 'You have just added new payment with id %' ,
                  new_payment_id;
END;
$$ ;


-- SELECT new_transaction ('Anna Nowak','card', ARRAY[1, 2, 3], ARRAY[2, 3, 1]);
 -- SELECT * FROM gaspoint_transaction.payment p 




/*
 
Create view that joins all tables in your database and represents data in denormalized form for the past month. Make sure to omit meaningless fields in the
result (e.g. surrogate keys, duplicate fields, etc.).

*/

CREATE OR REPLACE VIEW gaspoint_transaction.all_data AS 
SELECT  t.transaction_id,
        t.transaction_date_time,
        s.station_name,
        s.station_capacity,
        s.station_address,
        s2.staff_name,
        s2.staff_gender,
        s2.staff_date_of_birth,
        s2.staff_date_of_hiring,
        p2.payment_id,
        p2.payment_date,
        p2.payment_method,
        p2.payment_amount_pln,
        i.invoice_number,
        i.invoice_date_of_issue,
        i.invoice_payment_terms_days,
        i.invoice_tax_rate_percentage,
        c.client_id,
        c.client_company_name,
        c.client_nip,
        pl.product_id,
        p3.product_name,
        c2.category_name,
        c2.category_parent_category_id,
        p3.product_unit_price_pln

FROM gaspoint_transaction."Transaction" t 
LEFT JOIN gaspoint_transaction.station s       ON  t.transaction_station_id = s.station_id 
LEFT JOIN gaspoint_transaction.staff s2        ON  t.transaction_staff_id   = s2.staff_id 
LEFT JOIN gaspoint_transaction."position" p    ON  s2.staff_position_id     = p.position_id
LEFT JOIN gaspoint_transaction.payment p2      ON  t.transaction_payment_id = p2.payment_id 
LEFT JOIN gaspoint_transaction.invoice i       ON  p2.payment_invoice_id    = i.invoice_id 
LEFT JOIN gaspoint_transaction.client c        ON  i.invoice_client_id      = c.client_id  
LEFT JOIN gaspoint_transaction.product_list pl ON  t.transaction_id         = pl.transaction_id 
LEFT JOIN gaspoint_transaction.product p3      ON  pl.product_id            = p3.product_id 
LEFT JOIN gaspoint_transaction.category c2     ON  p3.product_category_id   = c2.category_id  

WHERE t.transaction_date_time::date >= (current_date - INTERVAL '1 month')  ;


--  SELECT * FROM gaspoint_transaction.all_data




/*
Create manager's read-only role. Make sure he can only SELECT from tables in your database. Make sure he can LOGIN as well. Make sure you follow
database security best practices when creating role(s).


--Creation of role for managers. Granting only SELECT from all tables privelage, which allows to retrieve the data, but not change it.
*/

DO
$$
BEGIN
   IF EXISTS (
      SELECT * FROM pg_catalog.pg_roles
      WHERE  rolname = 'manager') 
   THEN RAISE NOTICE 'Role "manager" already exists.';
   ELSE
      CREATE ROLE manager WITH 
        NOSUPERUSER
        NOCREATEDB
        NOCREATEROLE
        INHERIT
        NOLOGIN
        NOREPLICATION
        NOBYPASSRLS;
    
    GRANT USAGE ON SCHEMA gaspoint_transaction TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.category        TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction."Transaction"   TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.client          TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.invoice         TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.payment         TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction."position"      TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.product         TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.product_list    TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.staff           TO manager;
    GRANT SELECT ON TABLE gaspoint_transaction.station         TO manager;
      
   END IF;
END;
$$;

-- checking the privelage granted
SELECT  grantee,
        table_catalog ,
        table_schema ,
        table_name,
        privilege_type
 FROM   information_schema.role_table_grants
WHERE   grantee = 'manager';



-- adding a manager role to a staff member


DO
$block$
DECLARE 

new_role_name TEXT;

BEGIN
    WITH  hired_managers AS (                                                     -- the CTEs purpose is  to  disply only the staff members who ARE managers
            SELECT staff_name 
            FROM gaspoint_transaction.staff s 
            WHERE staff_position_id = (SELECT position_id
                                       FROM gaspoint_transaction."position" p 
                                       WHERE lower(position_name)= 'facility manager'))
            
    SELECT lower(trim(REPLACE(staff_name, ' ', '_')))||'_manager' INTO new_role_name          -- assigning the name of  a new role /user to  a variable   
    FROM hired_managers;
    
        

    IF EXISTS (                                                                          -- checking whether the ROLE with given name exists  
      SELECT * FROM pg_catalog.pg_roles
      WHERE  rolname::TEXT = new_role_name) 
   THEN RAISE NOTICE 'This role  for  already exists.';
   ELSE                                                                          
                                                                                      
       EXECUTE 'CREATE ROLE ' || new_role_name || ' WITH                               
        PASSWORD $pw$ default_password_to_be_changed $pw$
        NOSUPERUSER
        NOCREATEDB
        NOCREATEROLE
        INHERIT
        LOGIN
        NOREPLICATION
        NOBYPASSRLS';
      
      EXECUTE 'GRANT CONNECT ON DATABASE gas_point TO ' || new_role_name;
      EXECUTE 'GRANT manager1 TO ' || new_role_name;
      
   END IF;
END;
$block$;


