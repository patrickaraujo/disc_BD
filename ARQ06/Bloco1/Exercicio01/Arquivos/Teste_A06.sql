-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`TabMae`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`TabMae` (
  `CodTabMae` INT NOT NULL AUTO_INCREMENT,
  `DescMae` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CodTabMae`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`TabFilha`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`TabFilha` (
  `CodTabFilha` INT NOT NULL,
  `TabFilhacol` VARCHAR(45) NOT NULL,
  `TabMae_CodTabMae` INT NOT NULL,
  PRIMARY KEY (`CodTabFilha`),
  INDEX `fk_TabFilha_TabMae_idx` (`TabMae_CodTabMae` ASC) VISIBLE,
  CONSTRAINT `fk_TabFilha_TabMae`
    FOREIGN KEY (`TabMae_CodTabMae`)
    REFERENCES `mydb`.`TabMae` (`CodTabMae`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
