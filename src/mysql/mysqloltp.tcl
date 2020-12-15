proc build_mysqltpcc {} {
global maxvuser suppo ntimes threadscreated _ED
upvar #0 dbdict dbdict
if {[dict exists $dbdict mysql library ]} {
        set library [ dict get $dbdict mysql library ]
} else { set library "mysqltcl" }
upvar #0 configmysql configmysql
#set variables to values in dict
setlocaltpccvars $configmysql
if {[ tk_messageBox -title "Create Schema" -icon question -message "Ready to create a $mysql_count_ware Warehouse MySQL TPC-C schema\nin host [string toupper $mysql_host:$mysql_port] under user [ string toupper $mysql_user ] in database [ string toupper $mysql_dbase ] with storage engine [ string toupper $mysql_storage_engine ]?" -type yesno ] == yes} { 
if { $mysql_num_vu eq 1 || $mysql_count_ware eq 1 } {
set maxvuser 1
} else {
set maxvuser [ expr $mysql_num_vu + 1 ]
}
set suppo 1
set ntimes 1
ed_edit_clear
set _ED(packagekeyname) "TPC-C creation"
if { [catch {load_virtual} message]} {
puts "Failed to created thread for schema creation: $message"
	return
	}
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh8.6
#LOAD LIBRARIES AND MODULES
set library $library
"
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end {if [catch {package require $library} message] { error "Failed to load $library - $message" }
if [catch {::tcl::tm::path add modules} ] { error "Failed to find modules directory" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }
proc CreateStoredProcs { mysql_handler } {
puts "CREATING TPCC STORED PROCEDURES"
set sql(1) { CREATE PROCEDURE `NEWORD` (
no_w_id		INTEGER,
no_max_w_id		INTEGER,
no_d_id		INTEGER,
no_c_id		INTEGER,
no_o_ol_cnt		INTEGER,
OUT no_c_discount 	DECIMAL(4,4),
OUT no_c_last 		VARCHAR(16),
OUT no_c_credit 		VARCHAR(2),
OUT no_d_tax 		DECIMAL(4,4),
OUT no_w_tax 		DECIMAL(4,4),
INOUT no_d_next_o_id 	INTEGER,
IN timestamp 		DATE
)
BEGIN
DECLARE no_ol_supply_w_id	INTEGER;
DECLARE no_ol_i_id		INTEGER;
DECLARE no_ol_quantity 		INTEGER;
DECLARE no_o_all_local 		INTEGER;
DECLARE o_id 			INTEGER;
DECLARE no_i_name		VARCHAR(24);
DECLARE no_i_price		DECIMAL(5,2);
DECLARE no_i_data		VARCHAR(50);
DECLARE no_s_quantity		DECIMAL(6);
DECLARE no_ol_amount		DECIMAL(6,2);
DECLARE no_s_dist_01		CHAR(24);
DECLARE no_s_dist_02		CHAR(24);
DECLARE no_s_dist_03		CHAR(24);
DECLARE no_s_dist_04		CHAR(24);
DECLARE no_s_dist_05		CHAR(24);
DECLARE no_s_dist_06		CHAR(24);
DECLARE no_s_dist_07		CHAR(24);
DECLARE no_s_dist_08		CHAR(24);
DECLARE no_s_dist_09		CHAR(24);
DECLARE no_s_dist_10		CHAR(24);
DECLARE no_ol_dist_info 	CHAR(24);
DECLARE no_s_data	   	VARCHAR(50);
DECLARE x		        INTEGER;
DECLARE rbk		       	INTEGER;
DECLARE loop_counter    	INT;
DECLARE `Constraint Violation` CONDITION FOR SQLSTATE '23000';
DECLARE EXIT HANDLER FOR `Constraint Violation` ROLLBACK;
DECLARE EXIT HANDLER FOR NOT FOUND ROLLBACK;
SET no_o_all_local = 0;
SELECT c_discount, c_last, c_credit, w_tax
INTO no_c_discount, no_c_last, no_c_credit, no_w_tax
FROM customer, warehouse
WHERE warehouse.w_id = no_w_id AND customer.c_w_id = no_w_id AND
customer.c_d_id = no_d_id AND customer.c_id = no_c_id;
START TRANSACTION;
SELECT d_next_o_id, d_tax INTO no_d_next_o_id, no_d_tax
FROM district
WHERE d_id = no_d_id AND d_w_id = no_w_id FOR UPDATE;
UPDATE district SET d_next_o_id = d_next_o_id + 1 WHERE d_id = no_d_id AND d_w_id = no_w_id;
SET o_id = no_d_next_o_id;
INSERT INTO orders (o_id, o_d_id, o_w_id, o_c_id, o_entry_d, o_ol_cnt, o_all_local) VALUES (o_id, no_d_id, no_w_id, no_c_id, timestamp, no_o_ol_cnt, no_o_all_local);
INSERT INTO new_order (no_o_id, no_d_id, no_w_id) VALUES (o_id, no_d_id, no_w_id);
SET rbk = FLOOR(1 + (RAND() * 99));
SET loop_counter = 1;
WHILE loop_counter <= no_o_ol_cnt DO
IF ((loop_counter = no_o_ol_cnt) AND (rbk = 1))
THEN
SET no_ol_i_id = 100001;
ELSE
SET no_ol_i_id = FLOOR(1 + (RAND() * 100000));
END IF;
SET x = FLOOR(1 + (RAND() * 100));
IF ( x > 1 )
THEN
SET no_ol_supply_w_id = no_w_id;
ELSE
SET no_ol_supply_w_id = no_w_id;
SET no_o_all_local = 0;
WHILE ((no_ol_supply_w_id = no_w_id) AND (no_max_w_id != 1)) DO
SET no_ol_supply_w_id = FLOOR(1 + (RAND() * no_max_w_id));
END WHILE;
END IF;
SET no_ol_quantity = FLOOR(1 + (RAND() * 10));
SELECT i_price, i_name, i_data INTO no_i_price, no_i_name, no_i_data
FROM item WHERE i_id = no_ol_i_id;
SELECT s_quantity, s_data, s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05, s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
INTO no_s_quantity, no_s_data, no_s_dist_01, no_s_dist_02, no_s_dist_03, no_s_dist_04, no_s_dist_05, no_s_dist_06, no_s_dist_07, no_s_dist_08, no_s_dist_09, no_s_dist_10
FROM stock WHERE s_i_id = no_ol_i_id AND s_w_id = no_ol_supply_w_id;
IF ( no_s_quantity > no_ol_quantity )
THEN
SET no_s_quantity = ( no_s_quantity - no_ol_quantity );
ELSE
SET no_s_quantity = ( no_s_quantity - no_ol_quantity + 91 );
END IF;
UPDATE stock SET s_quantity = no_s_quantity
WHERE s_i_id = no_ol_i_id
AND s_w_id = no_ol_supply_w_id;
SET no_ol_amount = (  no_ol_quantity * no_i_price * ( 1 + no_w_tax + no_d_tax ) * ( 1 - no_c_discount ) );
CASE no_d_id
WHEN 1 THEN
SET no_ol_dist_info = no_s_dist_01;
WHEN 2 THEN
SET no_ol_dist_info = no_s_dist_02;
WHEN 3 THEN
SET no_ol_dist_info = no_s_dist_03;
WHEN 4 THEN
SET no_ol_dist_info = no_s_dist_04;
WHEN 5 THEN
SET no_ol_dist_info = no_s_dist_05;
WHEN 6 THEN
SET no_ol_dist_info = no_s_dist_06;
WHEN 7 THEN
SET no_ol_dist_info = no_s_dist_07;
WHEN 8 THEN
SET no_ol_dist_info = no_s_dist_08;
WHEN 9 THEN
SET no_ol_dist_info = no_s_dist_09;
WHEN 10 THEN
SET no_ol_dist_info = no_s_dist_10;
END CASE;
INSERT INTO order_line (ol_o_id, ol_d_id, ol_w_id, ol_number, ol_i_id, ol_supply_w_id, ol_quantity, ol_amount, ol_dist_info)
VALUES (o_id, no_d_id, no_w_id, loop_counter, no_ol_i_id, no_ol_supply_w_id, no_ol_quantity, no_ol_amount, no_ol_dist_info);
set loop_counter = loop_counter + 1;
END WHILE;
COMMIT;
END }
set sql(2) { CREATE PROCEDURE `DELIVERY`(
d_w_id			INTEGER,
d_o_carrier_id  	INTEGER,
IN timestamp 		DATE
)
BEGIN
DECLARE d_no_o_id	INTEGER;
DECLARE current_rowid 	INTEGER;
DECLARE d_d_id	    	INTEGER;
DECLARE d_c_id        	INTEGER;
DECLARE d_ol_total	INTEGER;
DECLARE deliv_data	VARCHAR(100);
DECLARE loop_counter  	INT;
DECLARE `Constraint Violation` CONDITION FOR SQLSTATE '23000';
DECLARE EXIT HANDLER FOR `Constraint Violation` ROLLBACK;
SET loop_counter = 1;
WHILE loop_counter <= 10 DO
SET d_d_id = loop_counter;
SELECT no_o_id INTO d_no_o_id FROM new_order WHERE no_w_id = d_w_id AND no_d_id = d_d_id LIMIT 1;
DELETE FROM new_order WHERE no_w_id = d_w_id AND no_d_id = d_d_id AND no_o_id = d_no_o_id;
SELECT o_c_id INTO d_c_id FROM orders
WHERE o_id = d_no_o_id AND o_d_id = d_d_id AND
o_w_id = d_w_id;
 UPDATE orders SET o_carrier_id = d_o_carrier_id
WHERE o_id = d_no_o_id AND o_d_id = d_d_id AND
o_w_id = d_w_id;
UPDATE order_line SET ol_delivery_d = timestamp
WHERE ol_o_id = d_no_o_id AND ol_d_id = d_d_id AND
ol_w_id = d_w_id;
SELECT SUM(ol_amount) INTO d_ol_total
FROM order_line
WHERE ol_o_id = d_no_o_id AND ol_d_id = d_d_id
AND ol_w_id = d_w_id;
UPDATE customer SET c_balance = c_balance + d_ol_total
WHERE c_id = d_c_id AND c_d_id = d_d_id AND
c_w_id = d_w_id;
SET deliv_data = CONCAT(d_d_id,' ',d_no_o_id,' ',timestamp);
COMMIT;
set loop_counter = loop_counter + 1;
END WHILE;
END }
set sql(3) { CREATE PROCEDURE `PAYMENT` (
p_w_id			INTEGER,
p_d_id			INTEGER,
p_c_w_id		INTEGER,
p_c_d_id		INTEGER,
INOUT p_c_id		INTEGER,
byname			INTEGER,
p_h_amount		DECIMAL(6,2),
INOUT p_c_last	  	VARCHAR(16),
OUT p_w_street_1  	VARCHAR(20),
OUT p_w_street_2  	VARCHAR(20),
OUT p_w_city		VARCHAR(20),
OUT p_w_state		CHAR(2),
OUT p_w_zip		CHAR(9),
OUT p_d_street_1	VARCHAR(20),
OUT p_d_street_2	VARCHAR(20),
OUT p_d_city		VARCHAR(20),
OUT p_d_state		CHAR(2),
OUT p_d_zip		CHAR(9),
OUT p_c_first		VARCHAR(16),
OUT p_c_middle		CHAR(2),
OUT p_c_street_1	VARCHAR(20),
OUT p_c_street_2	VARCHAR(20),
OUT p_c_city		VARCHAR(20),
OUT p_c_state		CHAR(2),
OUT p_c_zip		CHAR(9),
OUT p_c_phone		CHAR(16),
OUT p_c_since		DATE,
INOUT p_c_credit	CHAR(2),
OUT p_c_credit_lim 	DECIMAL(12,2),
OUT p_c_discount	DECIMAL(4,4),
INOUT p_c_balance 	DECIMAL(12,2),
OUT p_c_data		VARCHAR(500),
IN timestamp		DATE
)
BEGIN
DECLARE done      	INT DEFAULT 0;
DECLARE	namecnt		INTEGER;
DECLARE p_d_name	VARCHAR(11);
DECLARE p_w_name	VARCHAR(11);
DECLARE p_c_new_data	VARCHAR(500);
DECLARE h_data		VARCHAR(30);
DECLARE loop_counter  	INT;
DECLARE `Constraint Violation` CONDITION FOR SQLSTATE '23000';
DECLARE c_byname CURSOR FOR
SELECT c_first, c_middle, c_id, c_street_1, c_street_2, c_city, c_state, c_zip, c_phone, c_credit, c_credit_lim, c_discount, c_balance, c_since
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_last = p_c_last
ORDER BY c_first;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
DECLARE EXIT HANDLER FOR `Constraint Violation` ROLLBACK;
START TRANSACTION;
UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
WHERE w_id = p_w_id;
SELECT w_street_1, w_street_2, w_city, w_state, w_zip, w_name
INTO p_w_street_1, p_w_street_2, p_w_city, p_w_state, p_w_zip, p_w_name
FROM warehouse
WHERE w_id = p_w_id;
UPDATE district SET d_ytd = d_ytd + p_h_amount
WHERE d_w_id = p_w_id AND d_id = p_d_id;
SELECT d_street_1, d_street_2, d_city, d_state, d_zip, d_name
INTO p_d_street_1, p_d_street_2, p_d_city, p_d_state, p_d_zip, p_d_name
FROM district
WHERE d_w_id = p_w_id AND d_id = p_d_id;
IF (byname = 1)
THEN
SELECT count(c_id) INTO namecnt
FROM customer
WHERE c_last = p_c_last AND c_d_id = p_c_d_id AND c_w_id = p_c_w_id;
OPEN c_byname;
IF ( MOD (namecnt, 2) = 1 )
THEN
SET namecnt = (namecnt + 1);
END IF;
SET loop_counter = 0;
WHILE loop_counter <= (namecnt/2) DO
FETCH c_byname
INTO p_c_first, p_c_middle, p_c_id, p_c_street_1, p_c_street_2, p_c_city,
p_c_state, p_c_zip, p_c_phone, p_c_credit, p_c_credit_lim, p_c_discount, p_c_balance, p_c_since;
set loop_counter = loop_counter + 1;
END WHILE;
CLOSE c_byname;
ELSE
SELECT c_first, c_middle, c_last,
c_street_1, c_street_2, c_city, c_state, c_zip,
c_phone, c_credit, c_credit_lim,
c_discount, c_balance, c_since
INTO p_c_first, p_c_middle, p_c_last,
p_c_street_1, p_c_street_2, p_c_city, p_c_state, p_c_zip,
p_c_phone, p_c_credit, p_c_credit_lim,
p_c_discount, p_c_balance, p_c_since
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_id = p_c_id;
END IF;
SET p_c_balance = ( p_c_balance + p_h_amount );
IF p_c_credit = 'BC'
THEN
 SELECT c_data INTO p_c_data
FROM customer
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND c_id = p_c_id;
SET h_data = CONCAT(p_w_name,' ',p_d_name);
SET p_c_new_data = CONCAT(CAST(p_c_id AS CHAR),' ',CAST(p_c_d_id AS CHAR),' ',CAST(p_c_w_id AS CHAR),' ',CAST(p_d_id AS CHAR),' ',CAST(p_w_id AS CHAR),' ',CAST(FORMAT(p_h_amount,2) AS CHAR),CAST(timestamp AS CHAR),h_data);
SET p_c_new_data = SUBSTR(CONCAT(p_c_new_data,p_c_data),1,500-(LENGTH(p_c_new_data)));
UPDATE customer
SET c_balance = p_c_balance, c_data = p_c_new_data
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND
c_id = p_c_id;
ELSE
UPDATE customer SET c_balance = p_c_balance
WHERE c_w_id = p_c_w_id AND c_d_id = p_c_d_id AND
c_id = p_c_id;
END IF;
SET h_data = CONCAT(p_w_name,' ',p_d_name);
INSERT INTO history (h_c_d_id, h_c_w_id, h_c_id, h_d_id, h_w_id, h_date, h_amount, h_data)
VALUES (p_c_d_id, p_c_w_id, p_c_id, p_d_id, p_w_id, timestamp, p_h_amount, h_data);
COMMIT;
END }
set sql(4) { CREATE PROCEDURE `OSTAT` (
os_w_id                 INTEGER,
os_d_id                 INTEGER,
INOUT os_c_id           INTEGER,
byname                  INTEGER,
INOUT os_c_last         VARCHAR(16),
OUT os_c_first          VARCHAR(16),
OUT os_c_middle         CHAR(2),
OUT os_c_balance        DECIMAL(12,2),
OUT os_o_id             INTEGER,
OUT os_entdate          DATE,
OUT os_o_carrier_id     INTEGER
)
BEGIN 
DECLARE  os_ol_i_id 	INTEGER;
DECLARE  os_ol_supply_w_id INTEGER;
DECLARE  os_ol_quantity INTEGER;
DECLARE  os_ol_amount 	INTEGER;
DECLARE  os_ol_delivery_d 	DATE;
DECLARE done            INT DEFAULT 0;
DECLARE namecnt         INTEGER;
DECLARE i               INTEGER;
DECLARE loop_counter    INT;
DECLARE no_order_status VARCHAR(100);
DECLARE os_ol_i_id_array VARCHAR(200);
DECLARE os_ol_supply_w_id_array VARCHAR(200);
DECLARE os_ol_quantity_array VARCHAR(200);
DECLARE os_ol_amount_array VARCHAR(200);
DECLARE os_ol_delivery_d_array VARCHAR(210);
DECLARE `Constraint Violation` CONDITION FOR SQLSTATE '23000';
DECLARE c_name CURSOR FOR
SELECT c_balance, c_first, c_middle, c_id
FROM customer
WHERE c_last = os_c_last AND c_d_id = os_d_id AND c_w_id = os_w_id
ORDER BY c_first;
DECLARE c_line CURSOR FOR
SELECT ol_i_id, ol_supply_w_id, ol_quantity,
ol_amount, ol_delivery_d
FROM order_line
WHERE ol_o_id = os_o_id AND ol_d_id = os_d_id AND ol_w_id = os_w_id;
DECLARE EXIT HANDLER FOR `Constraint Violation` ROLLBACK;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
set no_order_status = '';
set os_ol_i_id_array = 'CSV,';
set os_ol_supply_w_id_array = 'CSV,';
set os_ol_quantity_array = 'CSV,';
set os_ol_amount_array = 'CSV,';
set os_ol_delivery_d_array = 'CSV,';
IF ( byname = 1 )
THEN
SELECT count(c_id) INTO namecnt
FROM customer
WHERE c_last = os_c_last AND c_d_id = os_d_id AND c_w_id = os_w_id;
IF ( MOD (namecnt, 2) = 1 )
THEN
SET namecnt = (namecnt + 1);
END IF;
OPEN c_name;
SET loop_counter = 0;
WHILE loop_counter <= (namecnt/2) DO
FETCH c_name
INTO os_c_balance, os_c_first, os_c_middle, os_c_id;
set loop_counter = loop_counter + 1;
END WHILE;
close c_name;
ELSE
SELECT c_balance, c_first, c_middle, c_last
INTO os_c_balance, os_c_first, os_c_middle, os_c_last
FROM customer
WHERE c_id = os_c_id AND c_d_id = os_d_id AND c_w_id = os_w_id;
END IF;
set done = 0;
SELECT o_id, o_carrier_id, o_entry_d
INTO os_o_id, os_o_carrier_id, os_entdate
FROM
(SELECT o_id, o_carrier_id, o_entry_d
FROM orders where o_d_id = os_d_id AND o_w_id = os_w_id and o_c_id = os_c_id
ORDER BY o_id DESC) AS sb LIMIT 1;
IF done THEN
set no_order_status = 'No orders for customer';
END IF;
set done = 0;
set i = 0;
OPEN c_line;
REPEAT
FETCH c_line INTO os_ol_i_id, os_ol_supply_w_id, os_ol_quantity, os_ol_amount, os_ol_delivery_d;
IF NOT done THEN
set os_ol_i_id_array = CONCAT(os_ol_i_id_array,',',CAST(i AS CHAR),',',CAST(os_ol_i_id AS CHAR));
set os_ol_supply_w_id_array = CONCAT(os_ol_supply_w_id_array,',',CAST(i AS CHAR),',',CAST(os_ol_supply_w_id AS CHAR));
set os_ol_quantity_array = CONCAT(os_ol_quantity_array,',',CAST(i AS CHAR),',',CAST(os_ol_quantity AS CHAR));
set os_ol_amount_array = CONCAT(os_ol_amount_array,',',CAST(i AS CHAR),',',CAST(os_ol_amount AS CHAR));
set os_ol_delivery_d_array = CONCAT(os_ol_delivery_d_array,',',CAST(i AS CHAR),',',CAST(os_ol_delivery_d AS CHAR));
set i = i+1;
END IF;
UNTIL done END REPEAT;
CLOSE c_line;
END }
set sql(5) { CREATE PROCEDURE `SLEV` (
st_w_id                 INTEGER,
st_d_id                 INTEGER,
threshold               INTEGER
)
BEGIN 
DECLARE st_o_id         INTEGER;
DECLARE stock_count     INTEGER;
DECLARE `Constraint Violation` CONDITION FOR SQLSTATE '23000';
DECLARE EXIT HANDLER FOR `Constraint Violation` ROLLBACK;
DECLARE EXIT HANDLER FOR NOT FOUND ROLLBACK;
SELECT d_next_o_id INTO st_o_id
FROM district
WHERE d_w_id=st_w_id AND d_id=st_d_id;
SELECT COUNT(DISTINCT (s_i_id)) INTO stock_count
FROM order_line, stock
WHERE ol_w_id = st_w_id AND
ol_d_id = st_d_id AND (ol_o_id < st_o_id) AND
ol_o_id >= (st_o_id - 20) AND s_w_id = st_w_id AND
s_i_id = ol_i_id AND s_quantity < threshold;
END }
for { set i 1 } { $i <= 5 } { incr i } {
mysqlexec $mysql_handler $sql($i)
		}
return
}

proc GatherStatistics { mysql_handler } {
puts "GATHERING SCHEMA STATISTICS"
set sql(1) "analyze table customer, district, history, item, new_order, orders, order_line, stock, warehouse"
mysqlexec $mysql_handler $sql(1)
return
}

proc CreateDatabase { mysql_handler db } {
puts "CREATING DATABASE $db"
set sql(1) "SET FOREIGN_KEY_CHECKS = 0"
set sql(2) "CREATE DATABASE IF NOT EXISTS `$db` CHARACTER SET latin1 COLLATE latin1_swedish_ci"
for { set i 1 } { $i <= 2 } { incr i } {
mysqlexec $mysql_handler $sql($i)
		}
return
}

proc CreateTables { mysql_handler mysql_storage_engine num_part } {
puts "CREATING TPCC TABLES"
set sql(1) "CREATE TABLE `customer` (
  `c_id` INT(5) NOT NULL,
  `c_d_id` INT(2) NOT NULL,
  `c_w_id` INT(4) NOT NULL,
  `c_first` VARCHAR(16) BINARY NULL,
  `c_middle` CHAR(2) BINARY NULL,
  `c_last` VARCHAR(16) BINARY NULL,
  `c_street_1` VARCHAR(20) BINARY NULL,
  `c_street_2` VARCHAR(20) BINARY NULL,
  `c_city` VARCHAR(20) BINARY NULL,
  `c_state` CHAR(2) BINARY NULL,
  `c_zip` CHAR(9) BINARY NULL,
  `c_phone` CHAR(16) BINARY NULL,
  `c_since` DATETIME NULL,
  `c_credit` CHAR(2) BINARY NULL,
  `c_credit_lim` DECIMAL(12, 2) NULL,
  `c_discount` DECIMAL(4, 4) NULL,
  `c_balance` DECIMAL(12, 2) NULL,
  `c_ytd_payment` DECIMAL(12, 2) NULL,
  `c_payment_cnt` INT(8) NULL,
  `c_delivery_cnt` INT(8) NULL,
  `c_data` VARCHAR(500) BINARY NULL,
PRIMARY KEY (`c_w_id`,`c_d_id`,`c_id`),
KEY c_w_id (`c_w_id`,`c_d_id`,`c_last`(16),`c_first`(16))
)
ENGINE = $mysql_storage_engine"
set sql(2) "CREATE TABLE `district` (
  `d_id` INT(2) NOT NULL,
  `d_w_id` INT(4) NOT NULL,
  `d_ytd` DECIMAL(12, 2) NULL,
  `d_tax` DECIMAL(4, 4) NULL,
  `d_next_o_id` INT NULL,
  `d_name` VARCHAR(10) BINARY NULL,
  `d_street_1` VARCHAR(20) BINARY NULL,
  `d_street_2` VARCHAR(20) BINARY NULL,
  `d_city` VARCHAR(20) BINARY NULL,
  `d_state` CHAR(2) BINARY NULL,
  `d_zip` CHAR(9) BINARY NULL,
PRIMARY KEY (`d_w_id`,`d_id`)
)
ENGINE = $mysql_storage_engine"
set sql(3) "CREATE TABLE `history` (
  `h_c_id` INT NULL,
  `h_c_d_id` INT NULL,
  `h_c_w_id` INT NULL,
  `h_d_id` INT NULL,
  `h_w_id` INT NULL,
  `h_date` DATETIME NULL,
  `h_amount` DECIMAL(6, 2) NULL,
  `h_data` VARCHAR(24) BINARY NULL
)
ENGINE = $mysql_storage_engine"
set sql(4) "CREATE TABLE `item` (
  `i_id` INT(6) NOT NULL,
  `i_im_id` INT NULL,
  `i_name` VARCHAR(24) BINARY NULL,
  `i_price` DECIMAL(5, 2) NULL,
  `i_data` VARCHAR(50) BINARY NULL,
PRIMARY KEY (`i_id`)
)
ENGINE = $mysql_storage_engine"
set sql(5) "CREATE TABLE `new_order` (
  `no_w_id` INT NOT NULL,
  `no_d_id` INT NOT NULL,
  `no_o_id` INT NOT NULL,
PRIMARY KEY (`no_w_id`, `no_d_id`, `no_o_id`)
)
ENGINE = $mysql_storage_engine"
set sql(6) "CREATE TABLE `orders` (
  `o_id` INT NOT NULL,
  `o_w_id` INT NOT NULL,
  `o_d_id` INT NOT NULL,
  `o_c_id` INT NULL,
  `o_carrier_id` INT NULL,
  `o_ol_cnt` INT NULL,
  `o_all_local` INT NULL,
  `o_entry_d` DATETIME NULL,
PRIMARY KEY (`o_w_id`,`o_d_id`,`o_id`),
KEY o_w_id (`o_w_id`,`o_d_id`,`o_c_id`,`o_id`)
)
ENGINE = $mysql_storage_engine"
if {$num_part eq 0} {
set sql(7) "CREATE TABLE `order_line` (
  `ol_w_id` INT NOT NULL,
  `ol_d_id` INT NOT NULL,
  `ol_o_id` iNT NOT NULL,
  `ol_number` INT NOT NULL,
  `ol_i_id` INT NULL,
  `ol_delivery_d` DATETIME NULL,
  `ol_amount` INT NULL,
  `ol_supply_w_id` INT NULL,
  `ol_quantity` INT NULL,
  `ol_dist_info` CHAR(24) BINARY NULL,
PRIMARY KEY (`ol_w_id`,`ol_d_id`,`ol_o_id`,`ol_number`)
)
ENGINE = $mysql_storage_engine"
	} else {
set sql(7) "CREATE TABLE `order_line` (
  `ol_w_id` INT NOT NULL,
  `ol_d_id` INT NOT NULL,
  `ol_o_id` iNT NOT NULL,
  `ol_number` INT NOT NULL,
  `ol_i_id` INT NULL,
  `ol_delivery_d` DATETIME NULL,
  `ol_amount` INT NULL,
  `ol_supply_w_id` INT NULL,
  `ol_quantity` INT NULL,
  `ol_dist_info` CHAR(24) BINARY NULL,
PRIMARY KEY (`ol_w_id`,`ol_d_id`,`ol_o_id`,`ol_number`)
)
ENGINE = $mysql_storage_engine
PARTITION BY HASH (`ol_w_id`)
PARTITIONS $num_part"
	}
set sql(8) "CREATE TABLE `stock` (
  `s_i_id` INT(6) NOT NULL,
  `s_w_id` INT(4) NOT NULL,
  `s_quantity` INT(6) NULL,
  `s_dist_01` CHAR(24) BINARY NULL,
  `s_dist_02` CHAR(24) BINARY NULL,
  `s_dist_03` CHAR(24) BINARY NULL,
  `s_dist_04` CHAR(24) BINARY NULL,
  `s_dist_05` CHAR(24) BINARY NULL,
  `s_dist_06` CHAR(24) BINARY NULL,
  `s_dist_07` CHAR(24) BINARY NULL,
  `s_dist_08` CHAR(24) BINARY NULL,
  `s_dist_09` CHAR(24) BINARY NULL,
  `s_dist_10` CHAR(24) BINARY NULL,
  `s_ytd` BIGINT(10) NULL,
  `s_order_cnt` INT(6) NULL,
  `s_remote_cnt` INT(6) NULL,
  `s_data` VARCHAR(50) BINARY NULL,
PRIMARY KEY (`s_w_id`,`s_i_id`)
)
ENGINE = $mysql_storage_engine"
set sql(9) "CREATE TABLE `warehouse` (
  `w_id` INT(4) NOT NULL,
  `w_ytd` DECIMAL(12, 2) NULL,
  `w_tax` DECIMAL(4, 4) NULL,
  `w_name` VARCHAR(10) BINARY NULL,
  `w_street_1` VARCHAR(20) BINARY NULL,
  `w_street_2` VARCHAR(20) BINARY NULL,
  `w_city` VARCHAR(20) BINARY NULL,
  `w_state` CHAR(2) BINARY NULL,
  `w_zip` CHAR(9) BINARY NULL,
PRIMARY KEY (`w_id`)
)
ENGINE = $mysql_storage_engine"
for { set i 1 } { $i <= 9 } { incr i } {
mysqlexec $mysql_handler $sql($i)
		}
return
}

proc gettimestamp { } {
set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
return $tstamp
}

proc Customer { mysql_handler d_id w_id CUST_PER_DIST } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set namearr [list BAR OUGHT ABLE PRI PRES ESE ANTI CALLY ATION EING]
set chalen [ llength $globArray ]
set bld_cnt 1
set c_d_id $d_id
set c_w_id $w_id
set c_middle "OE"
set c_balance -10.0
set c_credit_lim 50000
set h_amount 10.0
puts "Loading Customer for DID=$d_id WID=$w_id"
for {set c_id 1} {$c_id <= $CUST_PER_DIST } {incr c_id } {
set c_first [ MakeAlphaString 8 16 $globArray $chalen ]
if { $c_id <= 1000 } {
set c_last [ Lastname [ expr {$c_id - 1} ] $namearr ]
	} else {
set nrnd [ NURand 255 0 999 123 ]
set c_last [ Lastname $nrnd $namearr ]
	}
set c_add [ MakeAddress $globArray $chalen ]
set c_phone [ MakeNumberString ]
if { [RandomNumber 0 1] eq 1 } {
set c_credit "GC"
	} else {
set c_credit "BC"
	}
set disc_ran [ RandomNumber 0 50 ]
set c_discount [ expr {$disc_ran / 100.0} ]
set c_data [ MakeAlphaString 300 500 $globArray $chalen ]
append c_val_list ('$c_id', '$c_d_id', '$c_w_id', '$c_first', '$c_middle', '$c_last', '[ lindex $c_add 0 ]', '[ lindex $c_add 1 ]', '[ lindex $c_add 2 ]', '[ lindex $c_add 3 ]', '[ lindex $c_add 4 ]', '$c_phone', str_to_date('[ gettimestamp ]','%Y%m%d%H%i%s'), '$c_credit', '$c_credit_lim', '$c_discount', '$c_balance', '$c_data', '10.0', '1', '0')
set h_data [ MakeAlphaString 12 24 $globArray $chalen ]
append h_val_list ('$c_id', '$c_d_id', '$c_w_id', '$c_w_id', '$c_d_id', str_to_date([ gettimestamp ],'%Y%m%d%H%i%s'), '$h_amount', '$h_data')
if { $bld_cnt<= 999 } { 
append c_val_list ,
append h_val_list ,
	}
incr bld_cnt
if { ![ expr {$c_id % 1000} ] } {
mysql::exec $mysql_handler "insert into customer (`c_id`, `c_d_id`, `c_w_id`, `c_first`, `c_middle`, `c_last`, `c_street_1`, `c_street_2`, `c_city`, `c_state`, `c_zip`, `c_phone`, `c_since`, `c_credit`, `c_credit_lim`, `c_discount`, `c_balance`, `c_data`, `c_ytd_payment`, `c_payment_cnt`, `c_delivery_cnt`) values $c_val_list"
mysql::exec $mysql_handler "insert into history (`h_c_id`, `h_c_d_id`, `h_c_w_id`, `h_w_id`, `h_d_id`, `h_date`, `h_amount`, `h_data`) values $h_val_list"
	mysql::commit $mysql_handler
	set bld_cnt 1
	unset c_val_list
	unset h_val_list
		}
	}
puts "Customer Done"
return
}

proc Orders { mysql_handler d_id w_id MAXITEMS ORD_PER_DIST } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
set bld_cnt 1
puts "Loading Orders for D=$d_id W=$w_id"
set o_d_id $d_id
set o_w_id $w_id
for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
set cust($i) $i
}
for {set i 1} {$i <= $ORD_PER_DIST } {incr i } {
set r [ RandomNumber $i $ORD_PER_DIST ]
set t $cust($i)
set cust($i) $cust($r)
set $cust($r) $t
}
set e ""
for {set o_id 1} {$o_id <= $ORD_PER_DIST } {incr o_id } {
set o_c_id $cust($o_id)
set o_carrier_id [ RandomNumber 1 10 ]
set o_ol_cnt [ RandomNumber 5 15 ]
if { $o_id > 2100 } {
set e "o1"
append o_val_list ('$o_id', '$o_c_id', '$o_d_id', '$o_w_id', str_to_date([ gettimestamp ],'%Y%m%d%H%i%s'), null, '$o_ol_cnt', '1')
set e "no1"
append no_val_list ('$o_id', '$o_d_id', '$o_w_id')
  } else {
  set e "o3"
append o_val_list ('$o_id', '$o_c_id', '$o_d_id', '$o_w_id', str_to_date([ gettimestamp ],'%Y%m%d%H%i%s'), '$o_carrier_id', '$o_ol_cnt', '1')
	}
for {set ol 1} {$ol <= $o_ol_cnt } {incr ol } {
set ol_i_id [ RandomNumber 1 $MAXITEMS ]
set ol_supply_w_id $o_w_id
set ol_quantity 5
set ol_amount 0.0
set ol_dist_info [ MakeAlphaString 24 24 $globArray $chalen ]
if { $o_id > 2100 } {
set e "ol1"
append ol_val_list ('$o_id', '$o_d_id', '$o_w_id', '$ol', '$ol_i_id', '$ol_supply_w_id', '$ol_quantity', '$ol_amount', '$ol_dist_info', null)
if { $bld_cnt<= 99 } { append ol_val_list , } else {
if { $ol != $o_ol_cnt } { append ol_val_list , }
		}
	} else {
set amt_ran [ RandomNumber 10 10000 ]
set ol_amount [ expr {$amt_ran / 100.0} ]
set e "ol2"
append ol_val_list ('$o_id', '$o_d_id', '$o_w_id', '$ol', '$ol_i_id', '$ol_supply_w_id', '$ol_quantity', '$ol_amount', '$ol_dist_info', str_to_date([ gettimestamp ],'%Y%m%d%H%i%s'))
if { $bld_cnt<= 99 } { append ol_val_list , } else {
if { $ol != $o_ol_cnt } { append ol_val_list , }
		}
	}
}
if { $bld_cnt<= 99 } {
append o_val_list ,
if { $o_id > 2100 } {
append no_val_list ,
		}
        }
incr bld_cnt
 if { ![ expr {$o_id % 100} ] } {
 if { ![ expr {$o_id % 1000} ] } {
	puts "...$o_id"
	}
mysql::exec $mysql_handler "insert into orders (`o_id`, `o_c_id`, `o_d_id`, `o_w_id`, `o_entry_d`, `o_carrier_id`, `o_ol_cnt`, `o_all_local`) values $o_val_list"
if { $o_id > 2100 } {
mysql::exec $mysql_handler "insert into new_order (`no_o_id`, `no_d_id`, `no_w_id`) values $no_val_list"
	}
mysql::exec $mysql_handler "insert into order_line (`ol_o_id`, `ol_d_id`, `ol_w_id`, `ol_number`, `ol_i_id`, `ol_supply_w_id`, `ol_quantity`, `ol_amount`, `ol_dist_info`, `ol_delivery_d`) values $ol_val_list"
	mysql::commit $mysql_handler 
	set bld_cnt 1
	unset o_val_list
	unset -nocomplain no_val_list
	unset ol_val_list
			}
		}
	mysql::commit $mysql_handler 
	puts "Orders Done"
	return
}

proc LoadItems { mysql_handler MAXITEMS } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
puts "Loading Item"
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set orig($i) 0
}
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set pos [ RandomNumber 0 $MAXITEMS ] 
set orig($pos) 1
	}
for {set i_id 1} {$i_id <= $MAXITEMS } {incr i_id } {
set i_im_id [ RandomNumber 1 10000 ] 
set i_name [ MakeAlphaString 14 24 $globArray $chalen ]
set i_price_ran [ RandomNumber 100 10000 ]
set i_price [ format "%4.2f" [ expr {$i_price_ran / 100.0} ] ]
set i_data [ MakeAlphaString 26 50 $globArray $chalen ]
if { [ info exists orig($i_id) ] } {
if { $orig($i_id) eq 1 } {
set first [ RandomNumber 0 [ expr {[ string length $i_data] - 8}] ]
set last [ expr {$first + 8} ]
set i_data [ string replace $i_data $first $last "original" ]
	}
}
	mysql::exec $mysql_handler "insert into item (`i_id`, `i_im_id`, `i_name`, `i_price`, `i_data`) VALUES ('$i_id', '$i_im_id', '$i_name', '$i_price', '$i_data')"
      if { ![ expr {$i_id % 50000} ] } {
	puts "Loading Items - $i_id"
			}
		}
	mysql::commit $mysql_handler 
	puts "Item done"
	return
	}

proc Stock { mysql_handler w_id MAXITEMS } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
set bld_cnt 1
puts "Loading Stock Wid=$w_id"
set s_w_id $w_id
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set orig($i) 0
}
for {set i 0} {$i < [ expr {$MAXITEMS/10} ] } {incr i } {
set pos [ RandomNumber 0 $MAXITEMS ] 
set orig($pos) 1
	}
for {set s_i_id 1} {$s_i_id <= $MAXITEMS } {incr s_i_id } {
set s_quantity [ RandomNumber 10 100 ]
set s_dist_01 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_02 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_03 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_04 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_05 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_06 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_07 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_08 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_09 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_dist_10 [ MakeAlphaString 24 24 $globArray $chalen ]
set s_data [ MakeAlphaString 26 50 $globArray $chalen ]
if { [ info exists orig($s_i_id) ] } {
if { $orig($s_i_id) eq 1 } {
set first [ RandomNumber 0 [ expr {[ string length $s_data]} - 8 ] ]
set last [ expr {$first + 8} ]
set s_data [ string replace $s_data $first $last "original" ]
		}
	}
append val_list ('$s_i_id', '$s_w_id', '$s_quantity', '$s_dist_01', '$s_dist_02', '$s_dist_03', '$s_dist_04', '$s_dist_05', '$s_dist_06', '$s_dist_07', '$s_dist_08', '$s_dist_09', '$s_dist_10', '$s_data', '0', '0', '0')
if { $bld_cnt<= 999 } { 
append val_list ,
}
incr bld_cnt
      if { ![ expr {$s_i_id % 1000} ] } {
mysql::exec $mysql_handler "insert into stock (`s_i_id`, `s_w_id`, `s_quantity`, `s_dist_01`, `s_dist_02`, `s_dist_03`, `s_dist_04`, `s_dist_05`, `s_dist_06`, `s_dist_07`, `s_dist_08`, `s_dist_09`, `s_dist_10`, `s_data`, `s_ytd`, `s_order_cnt`, `s_remote_cnt`) values $val_list"
	mysql::commit $mysql_handler
	set bld_cnt 1
	unset val_list
	}
      if { ![ expr {$s_i_id % 20000} ] } {
	puts "Loading Stock - $s_i_id"
			}
	}
	mysql::commit $mysql_handler
	puts "Stock done"
	return
}

proc District { mysql_handler w_id DIST_PER_WARE } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
puts "Loading District"
set d_w_id $w_id
set d_ytd 30000.0
set d_next_o_id 3001
for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
set d_name [ MakeAlphaString 6 10 $globArray $chalen ]
set d_add [ MakeAddress $globArray $chalen ]
set d_tax_ran [ RandomNumber 10 20 ]
set d_tax [ string replace [ format "%.2f" [ expr {$d_tax_ran / 100.0} ] ] 0 0 "" ]
mysql::exec $mysql_handler "insert into district (`d_id`, `d_w_id`, `d_name`, `d_street_1`, `d_street_2`, `d_city`, `d_state`, `d_zip`, `d_tax`, `d_ytd`, `d_next_o_id`) values ('$d_id', '$d_w_id', '$d_name', '[ lindex $d_add 0 ]', '[ lindex $d_add 1 ]', '[ lindex $d_add 2 ]', '[ lindex $d_add 3 ]', '[ lindex $d_add 4 ]', '$d_tax', '$d_ytd', '$d_next_o_id')"
	}
	mysql::commit $mysql_handler 
	puts "District done"
	return
}

proc LoadWare { mysql_handler ware_start count_ware MAXITEMS DIST_PER_WARE } {
set globArray [ list 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z ]
set chalen [ llength $globArray ]
puts "Loading Warehouse"
set w_ytd 3000000.00
for {set w_id $ware_start } {$w_id <= $count_ware } {incr w_id } {
set w_name [ MakeAlphaString 6 10 $globArray $chalen ]
set add [ MakeAddress $globArray $chalen ]
set w_tax_ran [ RandomNumber 10 20 ]
set w_tax [ string replace [ format "%.2f" [ expr {$w_tax_ran / 100.0} ] ] 0 0 "" ]
mysql::exec $mysql_handler "insert into warehouse (`w_id`, `w_name`, `w_street_1`, `w_street_2`, `w_city`, `w_state`, `w_zip`, `w_tax`, `w_ytd`) values ('$w_id', '$w_name', '[ lindex $add 0 ]', '[ lindex $add 1 ]', '[ lindex $add 2 ]' , '[ lindex $add 3 ]', '[ lindex $add 4 ]', '$w_tax', '$w_ytd')"
	Stock $mysql_handler $w_id $MAXITEMS
	District $mysql_handler $w_id $DIST_PER_WARE
	mysql::commit $mysql_handler 
	}
}

proc LoadCust { mysql_handler ware_start count_ware CUST_PER_DIST DIST_PER_WARE } {
for {set w_id $ware_start} {$w_id <= $count_ware } {incr w_id } {
for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
	Customer $mysql_handler $d_id $w_id $CUST_PER_DIST
		}
	}
	mysql::commit $mysql_handler 
	return
}

proc LoadOrd { mysql_handler ware_start count_ware MAXITEMS ORD_PER_DIST DIST_PER_WARE } {
for {set w_id $ware_start} {$w_id <= $count_ware } {incr w_id } {
for {set d_id 1} {$d_id <= $DIST_PER_WARE } {incr d_id } {
	Orders $mysql_handler $d_id $w_id $MAXITEMS $ORD_PER_DIST
		}
	}
	mysql::commit $mysql_handler 
	return
}

proc do_tpcc { host port count_ware user password db mysql_storage_engine partition num_vu } {
global mysqlstatus
set MAXITEMS 100000
set CUST_PER_DIST 3000
set DIST_PER_WARE 10
set ORD_PER_DIST 3000
if { $num_vu > $count_ware } { set num_vu $count_ware }
if { $num_vu > 1 && [ chk_thread ] eq "TRUE" } {
set threaded "MULTI-THREADED"
set rema [ lassign [ findvuposition ] myposition totalvirtualusers ]
switch $myposition {
        1 {
puts "Monitor Thread"
if { $threaded eq "MULTI-THREADED" } {
tsv::lappend common thrdlst monitor
for { set th 1 } { $th <= $totalvirtualusers } { incr th } {
tsv::lappend common thrdlst idle
                        }
tsv::set application load "WAIT"
                }
        }
        default {
puts "Worker Thread"
if { [ expr $myposition - 1 ] > $count_ware } { puts "No Warehouses to Create"; return }
     }
   }
} else {
set threaded "SINGLE-THREADED"
set num_vu 1
  }
if { $threaded eq "SINGLE-THREADED" ||  $threaded eq "MULTI-THREADED" && $myposition eq 1 } {
puts "CREATING [ string toupper $db ] SCHEMA"
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
puts "the database connection to $host could not be established"
error $mysqlstatus(message)
 } else {
CreateDatabase $mysql_handler $db
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 0
if { $partition eq "true" } {
if {$count_ware < 200} {
set num_part 0
        } else {
set num_part [ expr round($count_ware/100) ]
        }
        } else {
set num_part 0
}
CreateTables $mysql_handler $mysql_storage_engine $num_part
}
if { $threaded eq "MULTI-THREADED" } {
tsv::set application load "READY"
LoadItems $mysql_handler $MAXITEMS
puts "Monitoring Workers..."
set prevactive 0
while 1 {
set idlcnt 0; set lvcnt 0; set dncnt 0;
for {set th 2} {$th <= $totalvirtualusers } {incr th} {
switch [tsv::lindex common thrdlst $th] {
idle { incr idlcnt }
active { incr lvcnt }
done { incr dncnt }
        }
}
if { $lvcnt != $prevactive } {
puts "Workers: $lvcnt Active $dncnt Done"
        }
set prevactive $lvcnt
if { $dncnt eq [expr  $totalvirtualusers - 1] } { break }
after 10000
}} else {
LoadItems $mysql_handler $MAXITEMS
}}
if { $threaded eq "SINGLE-THREADED" ||  $threaded eq "MULTI-THREADED" && $myposition != 1 } {
if { $threaded eq "MULTI-THREADED" } {
puts "Waiting for Monitor Thread..."
set mtcnt 0
while 1 {
incr mtcnt
if {  [ tsv::get application load ] eq "READY" } { break }
if { $mtcnt eq 48 } {
puts "Monitor failed to notify ready state"
return
        }
after 5000
}
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
puts "the database connection to $host could not be established"
error $mysqlstatus(message)
 } else {
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 0
} 
set remb [ lassign [ findchunk $num_vu $count_ware $myposition ] chunk mystart myend ]
puts "Loading $chunk Warehouses start:$mystart end:$myend"
tsv::lreplace common thrdlst $myposition $myposition active
} else {
set mystart 1
set myend $count_ware
}
puts "Start:[ clock format [ clock seconds ] ]"
LoadWare $mysql_handler $mystart $myend $MAXITEMS $DIST_PER_WARE
LoadCust $mysql_handler $mystart $myend $CUST_PER_DIST $DIST_PER_WARE
LoadOrd $mysql_handler $mystart $myend $MAXITEMS $ORD_PER_DIST $DIST_PER_WARE
puts "End:[ clock format [ clock seconds ] ]"
mysql::commit $mysql_handler 
if { $threaded eq "MULTI-THREADED" } {
tsv::lreplace common thrdlst $myposition $myposition done
        }
}
if { $threaded eq "SINGLE-THREADED" || $threaded eq "MULTI-THREADED" && $myposition eq 1 } {
CreateStoredProcs $mysql_handler
GatherStatistics $mysql_handler
puts "[ string toupper $db ] SCHEMA COMPLETE"
mysqlclose $mysql_handler
return
		}
	}
}

.ed_mainFrame.mainwin.textFrame.left.text fastinsert end "do_tpcc $mysql_host $mysql_port $mysql_count_ware $mysql_user $mysql_pass $mysql_dbase $mysql_storage_engine $mysql_partition $mysql_num_vu"
	} else { return }
}

proc loadmysqltpcc { } {
global _ED
upvar #0 dbdict dbdict
if {[dict exists $dbdict mysql library ]} {
set library [ dict get $dbdict mysql library ]
} else { set library "mysqltcl" }
upvar #0 configmysql configmysql
#set variables to values in dict
setlocaltpccvars $configmysql
ed_edit_clear
.ed_mainFrame.notebook select .ed_mainFrame.mainwin
set _ED(packagekeyname) "MySQL TPC-C"
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh8.6
#EDITABLE OPTIONS##################################################
set library $library ;# MySQL Library
set total_iterations $mysql_total_iterations ;# Number of transactions before logging off
set RAISEERROR \"$mysql_raiseerror\" ;# Exit script on MySQL error (true or false)
set KEYANDTHINK \"$mysql_keyandthink\" ;# Time for user thinking and keying (true or false)
set host \"$mysql_host\" ;# Address of the server hosting MySQL 
set port \"$mysql_port\" ;# Port of the MySQL Server, defaults to 3306
set user \"$mysql_user\" ;# MySQL user
set password \"$mysql_pass\" ;# Password for the MySQL user
set db \"$mysql_dbase\" ;# Database containing the TPC Schema
#EDITABLE OPTIONS##################################################
"
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end {#LOAD LIBRARIES AND MODULES
if [catch {package require $library} message] { error "Failed to load $library - $message" }
if [catch {::tcl::tm::path add modules} ] { error "Failed to find modules directory" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }
#TIMESTAMP
proc gettimestamp { } {
set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
return $tstamp
}
#NEW ORDER
proc neword { mysql_handler no_w_id w_id_input RAISEERROR } {
global mysqlstatus
#open new order cursor
#2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
set no_d_id [ RandomNumber 1 10 ]
#2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
set no_c_id [ RandomNumber 1 3000 ]
#2.4.1.3 Items in the order randomly selected from 5 to 15
set ol_cnt [ RandomNumber 5 15 ]
#2.4.1.6 order entry date O_ENTRY_D generated by SUT
set date [ gettimestamp ]
mysqlexec $mysql_handler "set @next_o_id = 0"
catch { mysqlexec $mysql_handler "CALL NEWORD($no_w_id,$w_id_input,$no_d_id,$no_c_id,$ol_cnt,@disc,@last,@credit,@dtax,@wtax,@next_o_id,$date)" }
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "New Order : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
      } 
  } else {
puts [ join [ mysql::sel $mysql_handler "select @disc,@last,@credit,@dtax,@wtax,@next_o_id" -list ] ]
   }
}
#PAYMENT
proc payment { mysql_handler p_w_id w_id_input RAISEERROR } {
global mysqlstatus
#2.5.1.1 The home warehouse id remains the same for each terminal
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set p_d_id [ RandomNumber 1 10 ]
#2.5.1.2 customer selected 60% of time by name and 40% of time by number
set x [ RandomNumber 1 100 ]
set y [ RandomNumber 1 100 ]
if { $x <= 85 } {
set p_c_d_id $p_d_id
set p_c_w_id $p_w_id
} else {
#use a remote warehouse
set p_c_d_id [ RandomNumber 1 10 ]
set p_c_w_id [ RandomNumber 1 $w_id_input ]
while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
set p_c_w_id [ RandomNumber 1  $w_id_input ]
	}
}
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set p_c_id [ RandomNumber 1 3000 ]
if { $y <= 60 } {
#use customer name
#C_LAST is generated
set byname 1
 } else {
#use customer number
set byname 0
set name {}
 }
#2.5.1.3 random amount from 1 to 5000
set p_h_amount [ RandomNumber 1 5000 ]
#2.5.1.4 date selected from SUT
set h_date [ gettimestamp ]
#2.5.2.1 Payment Transaction
mysqlexec $mysql_handler "set @p_c_id = $p_c_id, @p_c_last = '$name', @p_c_credit = 0, @p_c_balance = 0"
catch { mysqlexec $mysql_handler "CALL PAYMENT($p_w_id,$p_d_id,$p_c_w_id,$p_c_d_id,@p_c_id,$byname,$p_h_amount,@p_c_last,@p_w_street_1,@p_w_street_2,@p_w_city,@p_w_state,@p_w_zip,@p_d_street_1,@p_d_street_2,@p_d_city,@p_d_state,@p_d_zip,@p_c_first,@p_c_middle,@p_c_street_1,@p_c_street_2,@p_c_city,@p_c_state,@p_c_zip,@p_c_phone,@p_c_since,@p_c_credit,@p_c_credit_lim,@p_c_discount,@p_c_balance,@p_c_data,$h_date)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Payment : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
puts [ join [ mysql::sel $mysql_handler "select @p_c_id,@p_c_last,@p_w_street_1,@p_w_street_2,@p_w_city,@p_w_state,@p_w_zip,@p_d_street_1,@p_d_street_2,@p_d_city,@p_d_state,@p_d_zip,@p_c_first,@p_c_middle,@p_c_street_1,@p_c_street_2,@p_c_city,@p_c_state,@p_c_zip,@p_c_phone,@p_c_since,@p_c_credit,@p_c_credit_lim,@p_c_discount,@p_c_balance,@p_c_data" -list ] ]
    }
}
#ORDER_STATUS
proc ostat { mysql_handler w_id RAISEERROR } {
global mysqlstatus
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set d_id [ RandomNumber 1 10 ]
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set c_id [ RandomNumber 1 3000 ]
set y [ RandomNumber 1 100 ]
if { $y <= 60 } {
set byname 1
 } else {
set byname 0
set name {}
}
mysqlexec $mysql_handler "set @os_c_id = $c_id, @os_c_last = '$name'"
catch { mysqlexec $mysql_handler "CALL OSTAT($w_id,$d_id,@os_c_id,$byname,@os_c_last,@os_c_first,@os_c_middle,@os_c_balance,@os_o_id,@os_entdate,@os_o_carrier_id)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Order Status : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
puts [ join [ mysql::sel $mysql_handler "select @os_c_id,@os_c_last,@os_c_first,@os_c_middle,@os_c_balance,@os_o_id,@os_entdate,@os_o_carrier_id" -list ] ]
    }
}
#DELIVERY
proc delivery { mysql_handler w_id RAISEERROR } {
global mysqlstatus
set carrier_id [ RandomNumber 1 10 ]
set date [ gettimestamp ]
catch { mysqlexec $mysql_handler "CALL DELIVERY($w_id,$carrier_id,$date)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Delivery : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
puts "$w_id $carrier_id $date"
    }
}
#STOCK LEVEL
proc slev { mysql_handler w_id stock_level_d_id RAISEERROR } {
global mysqlstatus
set threshold [ RandomNumber 10 20 ]
mysqlexec $mysql_handler "CALL SLEV($w_id,$stock_level_d_id,$threshold)"
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Stock Level : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
puts "$w_id $stock_level_d_id $threshold"
    }
}
#RUN TPC-C
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
puts "the database connection to $host could not be established"
error $mysqlstatus(message)
 } else {
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 0
}
set w_id_input [ list [ mysql::sel $mysql_handler "select max(w_id) from warehouse" -list ] ]
#2.4.1.1 set warehouse_id stays constant for a given terminal
set w_id  [ RandomNumber 1 $w_id_input ]  
set d_id_input [ list [ mysql::sel $mysql_handler "select max(d_id) from district" -list ] ]
set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
puts "Processing $total_iterations transactions without output suppressed..."
set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
for {set it 0} {$it < $total_iterations} {incr it} {
if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
set choice [ RandomNumber 1 23 ]
if {$choice <= 10} {
puts "new order"
if { $KEYANDTHINK } { keytime 18 }
neword $mysql_handler $w_id $w_id_input $RAISEERROR
if { $KEYANDTHINK } { thinktime 12 }
} elseif {$choice <= 20} {
puts "payment"
if { $KEYANDTHINK } { keytime 3 }
payment $mysql_handler $w_id $w_id_input $RAISEERROR
if { $KEYANDTHINK } { thinktime 12 }
} elseif {$choice <= 21} {
puts "delivery"
if { $KEYANDTHINK } { keytime 2 }
delivery $mysql_handler $w_id $RAISEERROR
if { $KEYANDTHINK } { thinktime 10 }
} elseif {$choice <= 22} {
puts "stock level"
if { $KEYANDTHINK } { keytime 2 }
slev $mysql_handler $w_id $stock_level_d_id $RAISEERROR
if { $KEYANDTHINK } { thinktime 5 }
} elseif {$choice <= 23} {
puts "order status"
if { $KEYANDTHINK } { keytime 2 }
ostat $mysql_handler $w_id $RAISEERROR
if { $KEYANDTHINK } { thinktime 5 }
	}
}
mysqlclose $mysql_handler}
}

proc loadtimedmysqltpcc { } {
global opmode _ED
upvar #0 dbdict dbdict
if {[dict exists $dbdict mysql library ]} {
set library [ dict get $dbdict mysql library ]
} else { set library "mysqltcl" }
upvar #0 configmysql configmysql
#set variables to values in dict
setlocaltpccvars $configmysql
ed_edit_clear
.ed_mainFrame.notebook select .ed_mainFrame.mainwin
set _ED(packagekeyname) "MySQL TPC-C Timed"
if { !$mysql_async_scale } {
#REGULAR TIMED SCRIPT
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh8.6
#EDITABLE OPTIONS##################################################
set library $library ;# MySQL Library
global mysqlstatus
set total_iterations $mysql_total_iterations ;# Number of transactions before logging off
set RAISEERROR \"$mysql_raiseerror\" ;# Exit script on MySQL error (true or false)
set KEYANDTHINK \"$mysql_keyandthink\" ;# Time for user thinking and keying (true or false)
set rampup $mysql_rampup;  # Rampup time in minutes before first Transaction Count is taken
set duration $mysql_duration;  # Duration in minutes before second Transaction Count is taken
set mode \"$opmode\" ;# HammerDB operational mode
set host \"$mysql_host\" ;# Address of the server hosting MySQL 
set port \"$mysql_port\" ;# Port of the MySQL Server, defaults to 3306
set user \"$mysql_user\" ;# MySQL user
set password \"$mysql_pass\" ;# Password for the MySQL user
set db \"$mysql_dbase\" ;# Database containing the TPC Schema
#EDITABLE OPTIONS##################################################
"
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end {#LOAD LIBRARIES AND MODULES
if [catch {package require $library} message] { error "Failed to load $library - $message" }
if [catch {::tcl::tm::path add modules} ] { error "Failed to find modules directory" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }

if { [ chk_thread ] eq "FALSE" } {
error "MYSQL Timed Script must be run in Thread Enabled Interpreter"
}
set rema [ lassign [ findvuposition ] myposition totalvirtualusers ]
switch $myposition {
1 { 
if { $mode eq "Local" || $mode eq "Master" } {
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
puts "the database connection to $host could not be established"
error $mysqlstatus(message)
 } else {
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 1
}
set ramptime 0
puts "Beginning rampup time of $rampup minutes"
set rampup [ expr $rampup*60000 ]
while {$ramptime != $rampup} {
if { [ tsv::get application abort ] } { break } else { after 6000 }
set ramptime [ expr $ramptime+6000 ]
if { ![ expr {$ramptime % 60000} ] } {
puts "Rampup [ expr $ramptime / 60000 ] minutes complete ..."
	}
}
if { [ tsv::get application abort ] } { break }
puts "Rampup complete, Taking start Transaction Count."
if {[catch {set handler_stat [ list [ mysql::sel $mysql_handler "show global status where Variable_name = 'Com_commit' or Variable_name =  'Com_rollback'" -list ] ]}]} {
puts stderr {error, failed to query transaction statistics}
return
} else {
regexp {\{\{Com_commit\ ([0-9]+)\}\ \{Com_rollback\ ([0-9]+)\}\}} $handler_stat all com_comm com_roll
set start_trans [ expr $com_comm + $com_roll ]
	}
if {[catch {set start_nopm [ list [ mysql::sel $mysql_handler "select sum(d_next_o_id) from district" -list ] ]}]} {
puts stderr {error, failed to query district table}
return
}
puts "Timing test period of $duration in minutes"
set testtime 0
set durmin $duration
set duration [ expr $duration*60000 ]
while {$testtime != $duration} {
if { [ tsv::get application abort ] } { break } else { after 6000 }
set testtime [ expr $testtime+6000 ]
if { ![ expr {$testtime % 60000} ] } {
puts -nonewline  "[ expr $testtime / 60000 ]  ...,"
	}
}
if { [ tsv::get application abort ] } { break }
puts "Test complete, Taking end Transaction Count."
if {[catch {set handler_stat [ list [ mysql::sel $mysql_handler "show global status where Variable_name = 'Com_commit' or Variable_name =  'Com_rollback'" -list ] ]}]} {
puts stderr {error, failed to query transaction statistics}
return
} else {
regexp {\{\{Com_commit\ ([0-9]+)\}\ \{Com_rollback\ ([0-9]+)\}\}} $handler_stat all com_comm com_roll
set end_trans [ expr $com_comm + $com_roll ]
	}
if {[catch {set end_nopm [ list [ mysql::sel $mysql_handler "select sum(d_next_o_id) from district" -list ] ]}]} {
puts stderr {error, failed to query district table}
return
}
set tpm [ expr {($end_trans - $start_trans)/$durmin} ]
set nopm [ expr {($end_nopm - $start_nopm)/$durmin} ]
puts "[ expr $totalvirtualusers - 1 ] Active Virtual Users configured"
puts "TEST RESULT : System achieved $tpm MySQL TPM at $nopm NOPM"
tsv::set application abort 1
if { $mode eq "Master" } { eval [subst {thread::send -async $MASTER { remote_command ed_kill_vusers }}] }
catch { mysqlclose $mysql_handler }
		} else {
puts "Operating in Slave Mode, No Snapshots taken..."
		}
	}
default {
#TIMESTAMP
proc gettimestamp { } {
set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
return $tstamp
}
#NEW ORDER
proc neword { mysql_handler no_w_id w_id_input RAISEERROR } {
global mysqlstatus
#open new order cursor
#2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
set no_d_id [ RandomNumber 1 10 ]
#2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
set no_c_id [ RandomNumber 1 3000 ]
#2.4.1.3 Items in the order randomly selected from 5 to 15
set ol_cnt [ RandomNumber 5 15 ]
#2.4.1.6 order entry date O_ENTRY_D generated by SUT
set date [ gettimestamp ]
mysqlexec $mysql_handler "set @next_o_id = 0"
catch { mysqlexec $mysql_handler "CALL NEWORD($no_w_id,$w_id_input,$no_d_id,$no_c_id,$ol_cnt,@disc,@last,@credit,@dtax,@wtax,@next_o_id,$date)" }
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "New Order : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
      } 
  } else {
;
   }
}
#PAYMENT
proc payment { mysql_handler p_w_id w_id_input RAISEERROR } {
global mysqlstatus
#2.5.1.1 The home warehouse id remains the same for each terminal
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set p_d_id [ RandomNumber 1 10 ]
#2.5.1.2 customer selected 60% of time by name and 40% of time by number
set x [ RandomNumber 1 100 ]
set y [ RandomNumber 1 100 ]
if { $x <= 85 } {
set p_c_d_id $p_d_id
set p_c_w_id $p_w_id
} else {
#use a remote warehouse
set p_c_d_id [ RandomNumber 1 10 ]
set p_c_w_id [ RandomNumber 1 $w_id_input ]
while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
set p_c_w_id [ RandomNumber 1  $w_id_input ]
	}
}
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set p_c_id [ RandomNumber 1 3000 ]
if { $y <= 60 } {
#use customer name
#C_LAST is generated
set byname 1
 } else {
#use customer number
set byname 0
set name {}
 }
#2.5.1.3 random amount from 1 to 5000
set p_h_amount [ RandomNumber 1 5000 ]
#2.5.1.4 date selected from SUT
set h_date [ gettimestamp ]
#2.5.2.1 Payment Transaction
mysqlexec $mysql_handler "set @p_c_id = $p_c_id, @p_c_last = '$name', @p_c_credit = 0, @p_c_balance = 0"
catch { mysqlexec $mysql_handler "CALL PAYMENT($p_w_id,$p_d_id,$p_c_w_id,$p_c_d_id,@p_c_id,$byname,$p_h_amount,@p_c_last,@p_w_street_1,@p_w_street_2,@p_w_city,@p_w_state,@p_w_zip,@p_d_street_1,@p_d_street_2,@p_d_city,@p_d_state,@p_d_zip,@p_c_first,@p_c_middle,@p_c_street_1,@p_c_street_2,@p_c_city,@p_c_state,@p_c_zip,@p_c_phone,@p_c_since,@p_c_credit,@p_c_credit_lim,@p_c_discount,@p_c_balance,@p_c_data,$h_date)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Payment : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
;
    }
}
#ORDER_STATUS
proc ostat { mysql_handler w_id RAISEERROR } {
global mysqlstatus
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set d_id [ RandomNumber 1 10 ]
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set c_id [ RandomNumber 1 3000 ]
set y [ RandomNumber 1 100 ]
if { $y <= 60 } {
set byname 1
 } else {
set byname 0
set name {}
}
mysqlexec $mysql_handler "set @os_c_id = $c_id, @os_c_last = '$name'"
catch { mysqlexec $mysql_handler "CALL OSTAT($w_id,$d_id,@os_c_id,$byname,@os_c_last,@os_c_first,@os_c_middle,@os_c_balance,@os_o_id,@os_entdate,@os_o_carrier_id)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Order Status : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
;
    }
}
#DELIVERY
proc delivery { mysql_handler w_id RAISEERROR } {
global mysqlstatus
set carrier_id [ RandomNumber 1 10 ]
set date [ gettimestamp ]
catch { mysqlexec $mysql_handler "CALL DELIVERY($w_id,$carrier_id,$date)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Delivery : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
;
    }
}
#STOCK LEVEL
proc slev { mysql_handler w_id stock_level_d_id RAISEERROR } {
global mysqlstatus
set threshold [ RandomNumber 10 20 ]
mysqlexec $mysql_handler "CALL SLEV($w_id,$stock_level_d_id,$threshold)"
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Stock Level : $mysqlstatus(message)"
	} else { puts $mysqlstatus(message) 
       } 
  } else {
;
    }
}
#RUN TPC-C
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
puts "the database connection to $host could not be established"
error $mysqlstatus(message)
 } else {
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 0
}
set w_id_input [ list [ mysql::sel $mysql_handler "select max(w_id) from warehouse" -list ] ]
#2.4.1.1 set warehouse_id stays constant for a given terminal
set w_id  [ RandomNumber 1 $w_id_input ]  
set d_id_input [ list [ mysql::sel $mysql_handler "select max(d_id) from district" -list ] ]
set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
puts "Processing $total_iterations transactions with output suppressed..."
set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
for {set it 0} {$it < $total_iterations} {incr it} {
if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
set choice [ RandomNumber 1 23 ]
if {$choice <= 10} {
if { $KEYANDTHINK } { keytime 18 }
neword $mysql_handler $w_id $w_id_input $RAISEERROR
if { $KEYANDTHINK } { thinktime 12 }
} elseif {$choice <= 20} {
if { $KEYANDTHINK } { keytime 3 }
payment $mysql_handler $w_id $w_id_input $RAISEERROR
if { $KEYANDTHINK } { thinktime 12 }
} elseif {$choice <= 21} {
if { $KEYANDTHINK } { keytime 2 }
delivery $mysql_handler $w_id $RAISEERROR
if { $KEYANDTHINK } { thinktime 10 }
} elseif {$choice <= 22} {
if { $KEYANDTHINK } { keytime 2 }
slev $mysql_handler $w_id $stock_level_d_id $RAISEERROR
if { $KEYANDTHINK } { thinktime 5 }
} elseif {$choice <= 23} {
if { $KEYANDTHINK } { keytime 2 }
ostat $mysql_handler $w_id $RAISEERROR
if { $KEYANDTHINK } { thinktime 5 }
	}
}
mysqlclose $mysql_handler
	}
   }}
} else {
#ASYNCHRONOUS TIMED SCRIPT
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end "#!/usr/local/bin/tclsh8.6
#EDITABLE OPTIONS##################################################
set library $library ;# MySQL Library
global mysqlstatus
set total_iterations $mysql_total_iterations ;# Number of transactions before logging off
set RAISEERROR \"$mysql_raiseerror\" ;# Exit script on MySQL error (true or false)
set KEYANDTHINK \"$mysql_keyandthink\" ;# Time for user thinking and keying (true or false)
set rampup $mysql_rampup;  # Rampup time in minutes before first Transaction Count is taken
set duration $mysql_duration;  # Duration in minutes before second Transaction Count is taken
set mode \"$opmode\" ;# HammerDB operational mode
set host \"$mysql_host\" ;# Address of the server hosting MySQL 
set port \"$mysql_port\" ;# Port of the MySQL Server, defaults to 3306
set user \"$mysql_user\" ;# MySQL user
set password \"$mysql_pass\" ;# Password for the MySQL user
set db \"$mysql_dbase\" ;# Database containing the TPC Schema
set async_client $mysql_async_client;# Number of asynchronous clients per Vuser
set async_verbose $mysql_async_verbose;# Report activity of asynchronous clients
set async_delay $mysql_async_delay;# Delay in ms between logins of asynchronous clients
#EDITABLE OPTIONS##################################################
"
.ed_mainFrame.mainwin.textFrame.left.text fastinsert end {#LOAD LIBRARIES AND MODULES
if [catch {package require $library} message] { error "Failed to load $library - $message" }
if [catch {::tcl::tm::path add modules} ] { error "Failed to find modules directory" }
if [catch {package require tpcccommon} ] { error "Failed to load tpcc common functions" } else { namespace import tpcccommon::* }
if [catch {package require promise } message] { error "Failed to load promise package for asynchronous clients" }

if { [ chk_thread ] eq "FALSE" } {
error "MYSQL Timed Script must be run in Thread Enabled Interpreter"
}
set rema [ lassign [ findvuposition ] myposition totalvirtualusers ]
switch $myposition {
1 { 
if { $mode eq "Local" || $mode eq "Master" } {
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
puts "the database connection to $host could not be established"
error $mysqlstatus(message)
 } else {
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 1
}
set ramptime 0
puts "Beginning rampup time of $rampup minutes"
set rampup [ expr $rampup*60000 ]
while {$ramptime != $rampup} {
if { [ tsv::get application abort ] } { break } else { after 6000 }
set ramptime [ expr $ramptime+6000 ]
if { ![ expr {$ramptime % 60000} ] } {
puts "Rampup [ expr $ramptime / 60000 ] minutes complete ..."
	}
}
if { [ tsv::get application abort ] } { break }
puts "Rampup complete, Taking start Transaction Count."
if {[catch {set handler_stat [ list [ mysql::sel $mysql_handler "show global status where Variable_name = 'Com_commit' or Variable_name =  'Com_rollback'" -list ] ]}]} {
puts stderr {error, failed to query transaction statistics}
return
} else {
regexp {\{\{Com_commit\ ([0-9]+)\}\ \{Com_rollback\ ([0-9]+)\}\}} $handler_stat all com_comm com_roll
set start_trans [ expr $com_comm + $com_roll ]
	}
if {[catch {set start_nopm [ list [ mysql::sel $mysql_handler "select sum(d_next_o_id) from district" -list ] ]}]} {
puts stderr {error, failed to query district table}
return
}
puts "Timing test period of $duration in minutes"
set testtime 0
set durmin $duration
set duration [ expr $duration*60000 ]
while {$testtime != $duration} {
if { [ tsv::get application abort ] } { break } else { after 6000 }
set testtime [ expr $testtime+6000 ]
if { ![ expr {$testtime % 60000} ] } {
puts -nonewline  "[ expr $testtime / 60000 ]  ...,"
	}
}
if { [ tsv::get application abort ] } { break }
puts "Test complete, Taking end Transaction Count."
if {[catch {set handler_stat [ list [ mysql::sel $mysql_handler "show global status where Variable_name = 'Com_commit' or Variable_name =  'Com_rollback'" -list ] ]}]} {
puts stderr {error, failed to query transaction statistics}
return
} else {
regexp {\{\{Com_commit\ ([0-9]+)\}\ \{Com_rollback\ ([0-9]+)\}\}} $handler_stat all com_comm com_roll
set end_trans [ expr $com_comm + $com_roll ]
	}
if {[catch {set end_nopm [ list [ mysql::sel $mysql_handler "select sum(d_next_o_id) from district" -list ] ]}]} {
puts stderr {error, failed to query district table}
return
}
set tpm [ expr {($end_trans - $start_trans)/$durmin} ]
set nopm [ expr {($end_nopm - $start_nopm)/$durmin} ]
puts "[ expr $totalvirtualusers - 1 ] VU \* $async_client AC \= [ expr ($totalvirtualusers - 1) * $async_client ] Active Sessions configured"
puts "TEST RESULT : System achieved $tpm MySQL TPM at $nopm NOPM"
tsv::set application abort 1
if { $mode eq "Master" } { eval [subst {thread::send -async $MASTER { remote_command ed_kill_vusers }}] }
catch { mysqlclose $mysql_handler }
		} else {
puts "Operating in Slave Mode, No Snapshots taken..."
		}
	}
default {
#TIMESTAMP
proc gettimestamp { } {
set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
return $tstamp
}
#NEW ORDER
proc neword { mysql_handler no_w_id w_id_input RAISEERROR clientname } {
global mysqlstatus
#open new order cursor
#2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
set no_d_id [ RandomNumber 1 10 ]
#2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
set no_c_id [ RandomNumber 1 3000 ]
#2.4.1.3 Items in the order randomly selected from 5 to 15
set ol_cnt [ RandomNumber 5 15 ]
#2.4.1.6 order entry date O_ENTRY_D generated by SUT
set date [ gettimestamp ]
mysqlexec $mysql_handler "set @next_o_id = 0"
catch { mysqlexec $mysql_handler "CALL NEWORD($no_w_id,$w_id_input,$no_d_id,$no_c_id,$ol_cnt,@disc,@last,@credit,@dtax,@wtax,@next_o_id,$date)" }
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "New Order in $clientname : $mysqlstatus(message)"
	} else { 
puts "New Order in $clientname : $mysqlstatus(message)" 
      } 
  } else {
;
   }
}
#PAYMENT
proc payment { mysql_handler p_w_id w_id_input RAISEERROR clientname } {
global mysqlstatus
#2.5.1.1 The home warehouse id remains the same for each terminal
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set p_d_id [ RandomNumber 1 10 ]
#2.5.1.2 customer selected 60% of time by name and 40% of time by number
set x [ RandomNumber 1 100 ]
set y [ RandomNumber 1 100 ]
if { $x <= 85 } {
set p_c_d_id $p_d_id
set p_c_w_id $p_w_id
} else {
#use a remote warehouse
set p_c_d_id [ RandomNumber 1 10 ]
set p_c_w_id [ RandomNumber 1 $w_id_input ]
while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
set p_c_w_id [ RandomNumber 1  $w_id_input ]
	}
}
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set p_c_id [ RandomNumber 1 3000 ]
if { $y <= 60 } {
#use customer name
#C_LAST is generated
set byname 1
 } else {
#use customer number
set byname 0
set name {}
 }
#2.5.1.3 random amount from 1 to 5000
set p_h_amount [ RandomNumber 1 5000 ]
#2.5.1.4 date selected from SUT
set h_date [ gettimestamp ]
#2.5.2.1 Payment Transaction
mysqlexec $mysql_handler "set @p_c_id = $p_c_id, @p_c_last = '$name', @p_c_credit = 0, @p_c_balance = 0"
catch { mysqlexec $mysql_handler "CALL PAYMENT($p_w_id,$p_d_id,$p_c_w_id,$p_c_d_id,@p_c_id,$byname,$p_h_amount,@p_c_last,@p_w_street_1,@p_w_street_2,@p_w_city,@p_w_state,@p_w_zip,@p_d_street_1,@p_d_street_2,@p_d_city,@p_d_state,@p_d_zip,@p_c_first,@p_c_middle,@p_c_street_1,@p_c_street_2,@p_c_city,@p_c_state,@p_c_zip,@p_c_phone,@p_c_since,@p_c_credit,@p_c_credit_lim,@p_c_discount,@p_c_balance,@p_c_data,$h_date)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Payment in $clientname : $mysqlstatus(message)"
	} else { 
puts "Payment in $clientname : $mysqlstatus(message)"
       } 
  } else {
;
    }
}
#ORDER_STATUS
proc ostat { mysql_handler w_id RAISEERROR clientname } {
global mysqlstatus
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set d_id [ RandomNumber 1 10 ]
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set c_id [ RandomNumber 1 3000 ]
set y [ RandomNumber 1 100 ]
if { $y <= 60 } {
set byname 1
 } else {
set byname 0
set name {}
}
mysqlexec $mysql_handler "set @os_c_id = $c_id, @os_c_last = '$name'"
catch { mysqlexec $mysql_handler "CALL OSTAT($w_id,$d_id,@os_c_id,$byname,@os_c_last,@os_c_first,@os_c_middle,@os_c_balance,@os_o_id,@os_entdate,@os_o_carrier_id)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Order Status in $clientname : $mysqlstatus(message)"
	} else { 
puts "Order Status in $clientname : $mysqlstatus(message)"
       } 
  } else {
;
    }
}
#DELIVERY
proc delivery { mysql_handler w_id RAISEERROR clientname } {
global mysqlstatus
set carrier_id [ RandomNumber 1 10 ]
set date [ gettimestamp ]
catch { mysqlexec $mysql_handler "CALL DELIVERY($w_id,$carrier_id,$date)"}
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Delivery in $clientname : $mysqlstatus(message)"
	} else { 
puts "Delivery in $clientname : $mysqlstatus(message)"
       } 
  } else {
;
    }
}
#STOCK LEVEL
proc slev { mysql_handler w_id stock_level_d_id RAISEERROR clientname } {
global mysqlstatus
set threshold [ RandomNumber 10 20 ]
mysqlexec $mysql_handler "CALL SLEV($w_id,$stock_level_d_id,$threshold)"
if { $mysqlstatus(code)  } {
if { $RAISEERROR } {
error "Stock Level in $clientname : $mysqlstatus(message)"
	} else { 
puts "Stock Level in $clientname : $mysqlstatus(message)"
       } 
  } else {
;
    }
}

#RUN TPC-C
promise::async simulate_client { clientname total_iterations host port user password RAISEERROR KEYANDTHINK db async_verbose async_delay } {
global mysqlstatus
set acno [ expr [ string trimleft [ lindex [ split $clientname ":" ] 1 ] ac ] * $async_delay ]
if { $async_verbose } { puts "Delaying login of $clientname for $acno ms" }
async_time $acno
if {  [ tsv::get application abort ]  } { return "$clientname:abort before login" }
if { $async_verbose } { puts "Logging in $clientname" }
if [catch {mysqlconnect -host $host -port $port -user $user -password $password} mysql_handler] {
if { $RAISEERROR } {
puts "$clientname:login failed:$mysqlstatus(message)"
return "$clientname:login failed:$mysqlstatus(message)"
        }
   } else {
if { $async_verbose } { puts "Connected $clientname:$mysql_handler" }
mysqluse $mysql_handler $db
mysql::autocommit $mysql_handler 0
   }
set w_id_input [ list [ mysql::sel $mysql_handler "select max(w_id) from warehouse" -list ] ]
#2.4.1.1 set warehouse_id stays constant for a given terminal
set w_id  [ RandomNumber 1 $w_id_input ]  
set d_id_input [ list [ mysql::sel $mysql_handler "select max(d_id) from district" -list ] ]
set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
puts "Processing $total_iterations transactions with output suppressed..."
set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
for {set it 0} {$it < $total_iterations} {incr it} {
if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
set choice [ RandomNumber 1 23 ]
if {$choice <= 10} {
if { $async_verbose } { puts "$clientname:w_id:$w_id:neword" }
if { $KEYANDTHINK } { async_keytime 18  $clientname neword $async_verbose }
neword $mysql_handler $w_id $w_id_input $RAISEERROR $clientname
if { $KEYANDTHINK } { async_thinktime 12 $clientname neword $async_verbose }
} elseif {$choice <= 20} {
if { $async_verbose } { puts "$clientname:w_id:$w_id:payment" }
if { $KEYANDTHINK } { async_keytime 3 $clientname payment $async_verbose }
payment $mysql_handler $w_id $w_id_input $RAISEERROR $clientname
if { $KEYANDTHINK } { async_thinktime 12 $clientname payment $async_verbose }
} elseif {$choice <= 21} {
if { $async_verbose } { puts "$clientname:w_id:$w_id:delivery" }
if { $KEYANDTHINK } { async_keytime 2 $clientname delivery $async_verbose }
delivery $mysql_handler $w_id $RAISEERROR $clientname
if { $KEYANDTHINK } { async_thinktime 10 $clientname delivery $async_verbose }
} elseif {$choice <= 22} {
if { $async_verbose } { puts "$clientname:w_id:$w_id:slev" }
if { $KEYANDTHINK } { async_keytime 2 $clientname slev $async_verbose }
slev $mysql_handler $w_id $stock_level_d_id $RAISEERROR $clientname
if { $KEYANDTHINK } { async_thinktime 5 $clientname slev $async_verbose }
} elseif {$choice <= 23} {
if { $async_verbose } { puts "$clientname:w_id:$w_id:ostat" }
if { $KEYANDTHINK } { async_keytime 2 $clientname ostat $async_verbose }
ostat $mysql_handler $w_id $RAISEERROR $clientname
if { $KEYANDTHINK } { async_thinktime 5 $clientname ostat $async_verbose }
        }
  }
mysqlclose $mysql_handler
if { $async_verbose } { puts "$clientname:complete" }
return $clientname:complete
          }
for {set ac 1} {$ac <= $async_client} {incr ac} {
set clientdesc "vuser$myposition:ac$ac"
lappend clientlist $clientdesc
lappend clients [simulate_client $clientdesc $total_iterations $host $port $user $password $RAISEERROR $KEYANDTHINK $db $async_verbose $async_delay]
                }
puts "Started asynchronous clients:$clientlist"
set acprom [ promise::eventloop [ promise::all $clients ] ]
puts "All asynchronous clients complete"
if { $async_verbose } {
foreach client $acprom { puts $client }
      }
   }
}}
}
}
