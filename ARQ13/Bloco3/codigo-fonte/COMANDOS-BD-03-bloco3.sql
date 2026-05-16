-- =========================================================================
-- BLOCO 3 — Tabela Conta: PK Composta e Chaves Estrangeiras
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco3.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-2 executados (schema Financeiro, Cliente, TipoConta)
-- =========================================================================

USE `Financeiro`;

-- -------------------------------------------------------------------------
-- Passo 1 — Criando a tabela Conta com PK composta, índices e FKs
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Financeiro`.`Conta` (
    `NroConta`              INT   NOT NULL,
    `saldo`                 FLOAT NOT NULL,
    `Cliente_idCliente`     INT   NOT NULL,
    `TipoConta_idTipoConta` INT   NOT NULL,
    PRIMARY KEY (`NroConta`, `Cliente_idCliente`, `TipoConta_idTipoConta`),
    INDEX `fk_Conta_Cliente_idx`     (`Cliente_idCliente`     ASC) VISIBLE,
    INDEX `fk_Conta_TipoConta1_idx`  (`TipoConta_idTipoConta` ASC) VISIBLE,
    CONSTRAINT `fk_Conta_Cliente`
        FOREIGN KEY (`Cliente_idCliente`)
        REFERENCES `Financeiro`.`Cliente` (`idCliente`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT `fk_Conta_TipoConta1`
        FOREIGN KEY (`TipoConta_idTipoConta`)
        REFERENCES `Financeiro`.`TipoConta` (`idTipoConta`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
ENGINE = InnoDB;

-- -------------------------------------------------------------------------
-- Passo 2 — Limpando as 3 tabelas em ordem reversa de FK
-- (com FOREIGN_KEY_CHECKS=0, vindo do Bloco 1, a ordem ainda é boa prática)
-- -------------------------------------------------------------------------
TRUNCATE Conta;
TRUNCATE TipoConta;
TRUNCATE Cliente;

-- -------------------------------------------------------------------------
-- Passo 3 — Repopulando Cliente e TipoConta
-- (necessário porque TRUNCATE resetou os AUTO_INCREMENT)
-- -------------------------------------------------------------------------
INSERT INTO Cliente (NomeCli)
VALUES ('RUBENS ZAMPAR JUNIOR'), ('OSWALDO MARTINS DE SOUZA');

INSERT INTO TipoConta (DescricaoConta)
VALUES ('Conta Corrente'), ('Conta Poupança');

-- -------------------------------------------------------------------------
-- Passo 4 — Inserindo as 4 contas
-- (NroConta, saldo, Cliente_idCliente, TipoConta_idTipoConta)
-- -------------------------------------------------------------------------
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0,    1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);

-- -------------------------------------------------------------------------
-- Passo 5 — Confirmando e verificando
-- -------------------------------------------------------------------------
COMMIT;

SELECT * FROM Cliente;
SELECT * FROM TipoConta;
SELECT * FROM Conta;

-- -------------------------------------------------------------------------
-- Verificações complementares (referência para a Atividade)
-- -------------------------------------------------------------------------
SHOW CREATE TABLE Conta;

SELECT
    CONSTRAINT_NAME, COLUMN_NAME,
    REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Financeiro' AND TABLE_NAME = 'Conta'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

SELECT INDEX_NAME, COLUMN_NAME, IS_VISIBLE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'Financeiro' AND TABLE_NAME = 'Conta';

-- =========================================================================
-- FIM DO BLOCO 3
-- =========================================================================
