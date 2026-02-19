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
-- Table `mydb`.`Estado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Estado` (
  `UF` VARCHAR(2) NOT NULL,
  `Estado` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`UF`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Cidade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Cidade` (
  `codCidade` INT NOT NULL AUTO_INCREMENT,
  `Cidade` VARCHAR(45) NOT NULL,
  `Estado_UF` VARCHAR(2) NOT NULL,
  PRIMARY KEY (`codCidade`, `Estado_UF`),
  INDEX `fk_Cidade_Estado_idx` (`Estado_UF` ASC) VISIBLE,
  CONSTRAINT `fk_Cidade_Estado`
    FOREIGN KEY (`Estado_UF`)
    REFERENCES `mydb`.`Estado` (`UF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
