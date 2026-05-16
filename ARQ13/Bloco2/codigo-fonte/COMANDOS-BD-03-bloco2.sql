-- =========================================================================
-- BLOCO 2 — Schema Financeiro e Tabelas Cliente / TipoConta
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco2.sql (gabarito de referência)
-- Pré-requisito: Bloco 1 executado (3 SETs aplicados na sessão)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Passo 1 — Criando o schema Financeiro
-- -------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Financeiro` DEFAULT CHARACTER SET utf8;

USE `Financeiro`;

-- -------------------------------------------------------------------------
-- Passo 2 — Criando a tabela Cliente
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Financeiro`.`Cliente` (
    `idCliente` INT NOT NULL AUTO_INCREMENT,
    `NomeCli`   VARCHAR(60) NOT NULL,
    PRIMARY KEY (`idCliente`)
)
ENGINE = InnoDB;

-- -------------------------------------------------------------------------
-- Passo 3 — Criando a tabela TipoConta
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Financeiro`.`TipoConta` (
    `idTipoConta`    INT NOT NULL AUTO_INCREMENT,
    `DescricaoConta` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`idTipoConta`)
)
ENGINE = InnoDB;

-- -------------------------------------------------------------------------
-- Passo 4 — Populando as tabelas
-- (idCliente e idTipoConta são omitidos no INSERT — AUTO_INCREMENT preenche)
-- -------------------------------------------------------------------------
INSERT INTO Cliente (NomeCli)
VALUES ('RUBENS ZAMPAR JUNIOR'), ('OSWALDO MARTINS DE SOUZA');

INSERT INTO TipoConta (DescricaoConta)
VALUES ('Conta Corrente'), ('Conta Poupança');

-- -------------------------------------------------------------------------
-- Passo 5 — Confirmando e verificando
-- -------------------------------------------------------------------------
COMMIT;

SELECT * FROM Cliente;
SELECT * FROM TipoConta;

-- -------------------------------------------------------------------------
-- Verificações complementares (referência para a Atividade)
-- -------------------------------------------------------------------------
SHOW CREATE TABLE Cliente;

SELECT TABLE_NAME, ENGINE, AUTO_INCREMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'Financeiro';

-- =========================================================================
-- FIM DO BLOCO 2
-- =========================================================================
