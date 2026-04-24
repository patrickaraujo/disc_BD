-- -----------------------------------------------------
-- Script de Criação — Imobiliária (Exercício 06 / ARQ08)
-- Gabarito: estrutura completa do banco
-- -----------------------------------------------------

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
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb3 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`cidade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`cidade` (
  `CodCidade` INT NOT NULL AUTO_INCREMENT,
  `Cidade` VARCHAR(100) NOT NULL,
  `UF` ENUM('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO') NOT NULL,
  PRIMARY KEY (`CodCidade`))
ENGINE = InnoDB
AUTO_INCREMENT = 13
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`praia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`praia` (
  `IdPraia` INT NOT NULL AUTO_INCREMENT,
  `NmPraia` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`IdPraia`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`proprietario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`proprietario` (
  `IdProprietario` INT NOT NULL AUTO_INCREMENT,
  `Nome` VARCHAR(100) NOT NULL,
  `RG` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`IdProprietario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`tipo_de_imovel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`tipo_de_imovel` (
  `IdTpImovel` INT NOT NULL AUTO_INCREMENT,
  `TipoImovel` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`IdTpImovel`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`imovel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`imovel` (
  `NrImovel` INT NOT NULL,
  `QtdeQuartos` INT NOT NULL,
  `QtdeBanheiros` INT NOT NULL,
  `VistaMar` ENUM('N', 'S') NOT NULL,
  `Logradouro` VARCHAR(50) NOT NULL,
  `Numero` INT NOT NULL,
  `Complemento` VARCHAR(25) NULL DEFAULT NULL,
  `Bairro` VARCHAR(35) NOT NULL,
  `CEP` INT NOT NULL,
  `IdTpImovel` INT NOT NULL,
  `CodCidade` INT NOT NULL,
  `IdPraia` INT NOT NULL,
  `IdProprietario` INT NOT NULL,
  PRIMARY KEY (`NrImovel`, `IdTpImovel`, `CodCidade`, `IdPraia`, `IdProprietario`),
  INDEX `fk_Imovel_Tipo_de_Imovel_idx` (`IdTpImovel` ASC) VISIBLE,
  INDEX `fk_Imovel_Cidade1_idx` (`CodCidade` ASC) VISIBLE,
  INDEX `fk_Imovel_Praia1_idx` (`IdPraia` ASC) VISIBLE,
  INDEX `fk_Imovel_Proprietario1_idx` (`IdProprietario` ASC) VISIBLE,
  CONSTRAINT `fk_Imovel_Cidade1`
    FOREIGN KEY (`CodCidade`)
    REFERENCES `mydb`.`cidade` (`CodCidade`),
  CONSTRAINT `fk_Imovel_Praia1`
    FOREIGN KEY (`IdPraia`)
    REFERENCES `mydb`.`praia` (`IdPraia`),
  CONSTRAINT `fk_Imovel_Proprietario1`
    FOREIGN KEY (`IdProprietario`)
    REFERENCES `mydb`.`proprietario` (`IdProprietario`),
  CONSTRAINT `fk_Imovel_Tipo_de_Imovel`
    FOREIGN KEY (`IdTpImovel`)
    REFERENCES `mydb`.`tipo_de_imovel` (`IdTpImovel`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`inquilino`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`inquilino` (
  `CodInquilino` INT NOT NULL AUTO_INCREMENT,
  `Nome` VARCHAR(100) NOT NULL,
  `CPF` INT NOT NULL,
  PRIMARY KEY (`CodInquilino`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`contratoaluguel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`contratoaluguel` (
  `NroContrato` INT NOT NULL,
  `Inquilino_CodInquilino` INT NOT NULL,
  `Imovel_NrImovel` INT NOT NULL,
  `DtContrato` DATE NOT NULL,
  `DtInicio` DATE NOT NULL,
  `DtFim` DATE NOT NULL,
  `ValorAluguel` DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (`Inquilino_CodInquilino`, `Imovel_NrImovel`, `NroContrato`),
  INDEX `fk_Inquilino_has_Imovel_Imovel1_idx` (`Imovel_NrImovel` ASC) VISIBLE,
  INDEX `fk_Inquilino_has_Imovel_Inquilino1_idx` (`Inquilino_CodInquilino` ASC) VISIBLE,
  CONSTRAINT `fk_Inquilino_has_Imovel_Imovel1`
    FOREIGN KEY (`Imovel_NrImovel`)
    REFERENCES `mydb`.`imovel` (`NrImovel`),
  CONSTRAINT `fk_Inquilino_has_Imovel_Inquilino1`
    FOREIGN KEY (`Inquilino_CodInquilino`)
    REFERENCES `mydb`.`inquilino` (`CodInquilino`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`mobilia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`mobilia` (
  `IdMobilia` INT NOT NULL AUTO_INCREMENT,
  `Descricao` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`IdMobilia`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`itensmoblia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`itensmoblia` (
  `CodItemMobilia` INT NOT NULL,
  `Mobilia_IdMobilia` INT NOT NULL,
  `Imovel_NrImovel` INT NOT NULL,
  `Qtde` INT NOT NULL,
  PRIMARY KEY (`Mobilia_IdMobilia`, `Imovel_NrImovel`, `CodItemMobilia`),
  INDEX `fk_Mobilia_has_Imovel_Imovel1_idx` (`Imovel_NrImovel` ASC) VISIBLE,
  INDEX `fk_Mobilia_has_Imovel_Mobilia1_idx` (`Mobilia_IdMobilia` ASC) VISIBLE,
  CONSTRAINT `fk_Mobilia_has_Imovel_Imovel1`
    FOREIGN KEY (`Imovel_NrImovel`)
    REFERENCES `mydb`.`imovel` (`NrImovel`),
  CONSTRAINT `fk_Mobilia_has_Imovel_Mobilia1`
    FOREIGN KEY (`Mobilia_IdMobilia`)
    REFERENCES `mydb`.`mobilia` (`IdMobilia`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
