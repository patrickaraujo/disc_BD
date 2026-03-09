-- -----------------------------------------------------
-- Script de Criação — Imobiliária (Exercício 06 / ARQ08)
-- Gabarito: estrutura completa do banco
-- -----------------------------------------------------

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema imobiliaria
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `imobiliaria` DEFAULT CHARACTER SET utf8;
USE `imobiliaria`;

-- -----------------------------------------------------
-- Table: TipoImovel
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TipoImovel` (
  `idTipoImovel` SMALLINT NOT NULL,
  `TipoImovel` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idTipoImovel`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: Cidade
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Cidade` (
  `CodCidade` SMALLINT NOT NULL,
  `Cidade` VARCHAR(100) NOT NULL,
  `UF` ENUM('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO') NULL,
  PRIMARY KEY (`CodCidade`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: Praia
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Praia` (
  `idPraia` SMALLINT NOT NULL,
  `NomePraia` VARCHAR(45) NULL,
  PRIMARY KEY (`idPraia`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: Proprietario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Proprietario` (
  `idProprietario` INT NOT NULL,
  `Nome` VARCHAR(100) NULL,
  `RG` VARCHAR(15) NULL,
  PRIMARY KEY (`idProprietario`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: Imovel
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Imovel` (
  `idImovel` INT NOT NULL,
  `QtdeQuartos` SMALLINT NULL,
  `QtdeBanheiros` SMALLINT NULL,
  `VistaMar` ENUM('N', 'S') NULL,
  `Logradouro` VARCHAR(50) NULL,
  `Numero` SMALLINT NULL,
  `Complemento` VARCHAR(25) NULL,
  `Bairro` VARCHAR(35) NULL,
  `CEP` INT NULL,
  `idTipoImovel` SMALLINT NULL,
  `CodCidade` SMALLINT NULL,
  `idPraia` SMALLINT NULL,
  `idProprietario` INT NULL,
  PRIMARY KEY (`idImovel`),
  INDEX `fk_Imovel_TipoImovel_idx` (`idTipoImovel` ASC) VISIBLE,
  INDEX `fk_Imovel_Cidade_idx` (`CodCidade` ASC) VISIBLE,
  INDEX `fk_Imovel_Praia_idx` (`idPraia` ASC) VISIBLE,
  INDEX `fk_Imovel_Proprietario_idx` (`idProprietario` ASC) VISIBLE,
  CONSTRAINT `fk_Imovel_TipoImovel`
    FOREIGN KEY (`idTipoImovel`)
    REFERENCES `TipoImovel` (`idTipoImovel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Imovel_Cidade`
    FOREIGN KEY (`CodCidade`)
    REFERENCES `Cidade` (`CodCidade`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Imovel_Praia`
    FOREIGN KEY (`idPraia`)
    REFERENCES `Praia` (`idPraia`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Imovel_Proprietario`
    FOREIGN KEY (`idProprietario`)
    REFERENCES `Proprietario` (`idProprietario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: Inquilino
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Inquilino` (
  `CodInquilino` INT NOT NULL,
  `Nome` VARCHAR(100) NULL,
  `CPF` INT NULL,
  PRIMARY KEY (`CodInquilino`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: ContratoAluguel
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ContratoAluguel` (
  `NroContrato` INT NOT NULL,
  `Inquilino_CodInquilino` INT NULL,
  `Imovel_idImovel` INT NULL,
  `DtContrato` DATE NULL,
  `DtInicio` DATE NULL,
  `DtFim` DATE NULL,
  `ValorAluguel` DECIMAL(5,2) NULL,
  PRIMARY KEY (`NroContrato`),
  INDEX `fk_ContratoAluguel_Inquilino_idx` (`Inquilino_CodInquilino` ASC) VISIBLE,
  INDEX `fk_ContratoAluguel_Imovel_idx` (`Imovel_idImovel` ASC) VISIBLE,
  CONSTRAINT `fk_ContratoAluguel_Inquilino`
    FOREIGN KEY (`Inquilino_CodInquilino`)
    REFERENCES `Inquilino` (`CodInquilino`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ContratoAluguel_Imovel`
    FOREIGN KEY (`Imovel_idImovel`)
    REFERENCES `Imovel` (`idImovel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: Mobilia
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Mobilia` (
  `idMobilia` INT NOT NULL,
  `Descricao` VARCHAR(45) NULL,
  PRIMARY KEY (`idMobilia`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table: ItensMobilia
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ItensMobilia` (
  `CodItemMobilia` INT NOT NULL,
  `Mobilia_idMobilia` INT NOT NULL,
  `Imovel_idImovel` INT NOT NULL,
  `Qtde` SMALLINT(2) NULL,
  PRIMARY KEY (`CodItemMobilia`),
  INDEX `fk_ItensMobilia_Mobilia_idx` (`Mobilia_idMobilia` ASC) VISIBLE,
  INDEX `fk_ItensMobilia_Imovel_idx` (`Imovel_idImovel` ASC) VISIBLE,
  CONSTRAINT `fk_ItensMobilia_Mobilia`
    FOREIGN KEY (`Mobilia_idMobilia`)
    REFERENCES `Mobilia` (`idMobilia`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ItensMobilia_Imovel`
    FOREIGN KEY (`Imovel_idImovel`)
    REFERENCES `Imovel` (`idImovel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
