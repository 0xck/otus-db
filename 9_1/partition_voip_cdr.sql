-- Script performed per month partitioning on DB voip.CDR by BILL_DATE from 2018-01-01 up to previous month of current date.

USE voip;


-- Loading procedures for partitioning
DELIMITER $$

CREATE PROCEDURE `generate_per_month_partitions` (
    IN init_date DATE,
    IN table_name_ TEXT,
    IN db_engine TEXT,
    IN sql_code TEXT,
    OUT res TEXT)
    DETERMINISTIC
    COMMENT 'Generate SQL code for partitioning data per month. Each entry contains settings for defining per month value. 1st entry contains values before init date. Last entry contains values newer previous month of current date. Other entry contains values for one month.'
BEGIN
    DECLARE current_year, year_, month_ INT DEFAULT 0;

    SET current_year = YEAR(CURRENT_DATE());

    -- Init partition for all old values
    -- All data that is less than init date will be here
    -- Literally: PARTITION $table_name__TOO_OLD VALUES LESS THAN ('init_date') ENGINE = $db_engine,
    SET sql_code = CONCAT(
        sql_code,
        'PARTITION ',
        CONCAT(table_name_, '_TOO_OLD'),
        ' VALUES LESS THAN (\'',
        init_date,
        '\') ENGINE = ',
        db_engine,
        ',');

    -- Generating partition entry based on year and month. E.g.
    -- PARTITION t1_less_2018_2 VALUES LESS THAN ('2018-2-1') ENGINE = InnoDB,
    -- PARTITION t1_less_2018_3 VALUES LESS THAN ('2018-3-1') ENGINE = InnoDB,
    -- ...
    -- PARTITION t1_less_YYYY_MM VALUES LESS THAN ('YYYY-MM-1') ENGINE = InnoDB,
    SET year_ = YEAR(init_date);
    SET month_ = MONTH(init_date) + 1;

    WHILE year_ <= (current_year) DO

        -- Generate for every month for all previous yers, but only up to previos month of current date
        WHILE ((year_ != current_year AND month_ <= 12) OR (year_ = current_year AND month_ < MONTH(CURRENT_DATE())))  DO

            -- Literally: PARTITION table_name__less_year__month_ VALUES LESS THAN ('year_-month_-1') ENGINE = $db_engine,
            SET sql_code = CONCAT(
                sql_code,
                'PARTITION ',
                CONCAT_WS('_', table_name_, 'less', year_, month_),
                ' VALUES LESS THAN (\'',
                CONCAT_WS('-', year_, month_, '1'),
                '\') ENGINE = ',
                db_engine,
                ',');

            SET month_ = month_ + 1;

        END WHILE;

        SET month_ = 1;

        SET year_ = year_ + 1;
    END WHILE;

    -- Final partition for all newest values
    -- All data that is newer than current month will be here
    -- Literally: PARTITION $table_name__NEWEST VALUES LESS THAN (MAXVALUE) ENGINE = $db_engine
    SET sql_code = CONCAT(
        sql_code,
        'PARTITION ',
        CONCAT(table_name_, '_NEWEST'),
        ' VALUES LESS THAN (MAXVALUE) ENGINE = ',
        db_engine);

    SELECT sql_code INTO res;

END $$


DELIMITER $$

CREATE PROCEDURE `partition_exist_per_month` (
    IN init_date DATE,
    IN schema_ TEXT,
    IN table_name_ TEXT,
    IN column_name TEXT)
    MODIFIES SQL DATA
    COMMENT 'Partition existing table per month, from given date up to previous month of current date.'

BEGIN
    DECLARE current_month, current_year,  init_month, init_year INT DEFAULT 0;
    DECLARE db_engine, sql_code, res TEXT DEFAULT '';
    DECLARE current_date_ DATE DEFAULT CURRENT_DATE();

    SET current_month = MONTH(current_date_);
    SET current_year = YEAR(current_date_);
    SET init_month = MONTH(init_date);
    SET init_year = YEAR(init_date);

    -- It is unclear what to do if init date is more than current
    IF init_date > current_date_ THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Init date is more than current.';
    END IF;

    -- Without this checking it can make only 2 partitions for old and new data,
    -- which is not per month partitioning
    IF (current_year = init_year) AND (current_month = init_month) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'For init and current dates of the same year init date month has to be less than current.';
    END IF;

    -- Need to set proper engine for partitions and one has to be get from origin table
    SET db_engine = (SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_NAME = table_name_ AND TABLE_SCHEMA = schema_ LIMIT 1);

    IF db_engine IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unknown given table engine or table does not exist in `information_schema`.';
    END IF;

    -- Initial code, due generator provides only partition related enries
    SET sql_code = CONCAT('ALTER TABLE ', CONCAT(schema_, '.', table_name_), ' PARTITION BY RANGE COLUMNS(', column_name, ' ) (');

    CALL generate_per_month_partitions(CONCAT_WS('-', init_year, init_month, '1'),
                                       table_name_, db_engine, sql_code, res);

    SET @ress = CONCAT(res, ')');

    PREPARE cmd FROM @ress;
    EXECUTE cmd;
    DEALLOCATE PREPARE cmd;

END $$


CALL partition_exist_per_month('2018-01-01', 'voip', 'CDR', 'BILL_DATE');


-- Deleting procedures for partitioning
DROP PROCEDURE IF EXISTS `generate_per_month_partitions`;
DROP PROCEDURE IF EXISTS `partition_exist_per_month`;
