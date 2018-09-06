-- MySQL Script generated by MySQL Workbench
-- Wed Sep  5 14:34:35 2018
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema contact_book
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema contact_book
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `contact_book` DEFAULT CHARACTER SET latin1 ;
USE `contact_book` ;

-- -----------------------------------------------------
-- Table `contact_book`.`contact`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `contact_book`.`contact` (
  `contactid` INT(11) NOT NULL AUTO_INCREMENT,
  `contact_firstname` VARCHAR(45) NOT NULL DEFAULT 'john',
  `contact_lastname` VARCHAR(45) NOT NULL DEFAULT 'doe',
  `contact_email` VARCHAR(45) NOT NULL DEFAULT 'john.doe@somewhere.com',
  `contact_phone` VARCHAR(45) NOT NULL DEFAULT '111-111-1111',
  `contact_address` VARCHAR(45) NOT NULL DEFAULT '123 main street',
  `contact_state` VARCHAR(45) NOT NULL DEFAULT 'state',
  `contact_zipcode` VARCHAR(45) NOT NULL DEFAULT 'zipcode',
  `userid` INT(11) NULL DEFAULT NULL,
  `date_added` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `contact_city` VARCHAR(45) NOT NULL DEFAULT 'city',
  PRIMARY KEY (`contactid`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `contact_book`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `contact_book`.`user` (
  `userid` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NULL DEFAULT NULL,
  `user_firstname` VARCHAR(45) NULL DEFAULT NULL,
  `user_lastname` VARCHAR(45) NULL DEFAULT NULL,
  `user_password` VARCHAR(45) NULL DEFAULT NULL,
  `date_added` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `date_last_login` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `session_id` VARCHAR(32) NULL DEFAULT NULL,
  PRIMARY KEY (`userid`))
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = latin1;

USE `contact_book` ;

-- -----------------------------------------------------
-- procedure createContact
-- -----------------------------------------------------

DELIMITER $$
USE `contact_book`$$
CREATE PROCEDURE `createContact`(IN user_id INT, contactFirstName VARCHAR(32), contactLastName VARCHAR(32), contactPhone VARCHAR(32), contactEmail VARCHAR(32), contactAddress VARCHAR(32),
					contactCity VARCHAR(32), contactState VARCHAR(32), contactZipCode VARCHAR(32), sessionID VARCHAR(32))
BEGIN
DECLARE last_login DATETIME;
SET last_login = (SELECT date_last_login FROM user WHERE userid= user_id AND session_id= sessionID LIMIT 1);
IF  last_login IS NOT NULL THEN
	IF (timestampdiff(MINUTE, last_login, now()) < 30) THEN
		INSERT INTO contact (contact_firstname, contact_lastname, contact_email, contact_phone, contact_address, contact_city, contact_state, contact_zipcode, userid)
        VALUES(contactFirstName, contactLastName, contactEmail, contactPhone, contactAddress, contactCity, contactState, contactZipCode, user_id);
        SELECT * FROM contact WHERE contactid= LAST_INSERT_ID();
	END IF;
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure createUser
-- -----------------------------------------------------

DELIMITER $$
USE `contact_book`$$
CREATE PROCEDURE `createUser`(IN u_fname VARCHAR(45), u_lname VARCHAR(45), uname VARCHAR(45), u_pass VARCHAR(45), sessionID VARCHAR(32))
BEGIN

INSERT INTO USER (username, user_firstname, user_lastname, user_password, session_id)
VALUES (uname, u_fname, u_lname, u_pass, sessionID);

SELECT userid, username, user_firstname, user_lastname, date_added, date_last_login, sessionID
FROM user
WHERE userid = LAST_INSERT_ID();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure deleteContact
-- -----------------------------------------------------

DELIMITER $$
USE `contact_book`$$
CREATE PROCEDURE `deleteContact`(IN user_id INT, contact_id INT, sessionID VARCHAR(32))
BEGIN
DECLARE last_login DATETIME;
SET last_login = (SELECT date_last_login FROM user WHERE userid= user_id AND session_id= sessionID LIMIT 1);
IF  last_login IS NOT NULL THEN
	IF (timestampdiff(MINUTE, last_login, now()) < 30) THEN
		DELETE FROM contact WHERE contactid = contact_id;

	UPDATE user
	SET date_last_login = CURRENT_TIMESTAMP()
    WHERE userid= user_id
    LIMIT 1;

    SELECT   userid, username, user_firstname, user_lastname, date_added, date_last_login, session_id
    FROM user
    WHERE userid= user_id;
	END IF;
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure findContact
-- -----------------------------------------------------

DELIMITER $$
USE `contact_book`$$
CREATE PROCEDURE `findContact`(IN user_id INT, matchString VARCHAR(32), sessionID VARCHAR(32))
BEGIN

DECLARE last_login DATETIME;
SET last_login = (SELECT date_last_login FROM user WHERE userid= user_id AND session_id= sessionID LIMIT 1);
IF  last_login IS NOT NULL THEN
	IF (timestampdiff(MINUTE, last_login, now()) < 30) THEN
		IF matchString IS  NULL OR matchString = '' THEN
			SELECT * FROM contact
			WHERE  userid = user_id;
		ELSE
			SELECT * FROM contact
			WHERE  userid = user_id
			LIKE matchString;
		END IF;
	END IF;
END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure findContacts_json
-- -----------------------------------------------------

DELIMITER $$
USE `contact_book`$$
CREATE PROCEDURE `findContacts_json`(IN user_id INT, OUT results VARCHAR(5000))
BEGIN
SELECT group_concat(concat('[ ', json_object('firstName', contact_firstname, 'lastName', contact_lastname, 'email', contact_email,
										'phone', contact_phone, 'address', contact_address, 'state', contact_state, 'zipcode', contact_zipcode), ']'))
INTO results
FROM contact
WHERE userid = user_id;

SET results = concat('{ results : ', results, '}');
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userLogin
-- -----------------------------------------------------

DELIMITER $$
USE `contact_book`$$
CREATE PROCEDURE `userLogin`(IN uname VARCHAR(45),  pword VARCHAR(32), sessionID VARCHAR(32))
BEGIN
IF EXISTS (SELECT userid FROM user WHERE username= uname AND user_password = pword) THEN
	UPDATE user
	SET session_id= sessionID, date_last_login = CURRENT_TIMESTAMP()
    WHERE username= uname AND user_password = pword
    LIMIT 1;

    SELECT   userid, username, user_firstname, user_lastname, date_added, date_last_login, session_id
    FROM user
    WHERE username= uname AND user_password = pword;
END IF;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
