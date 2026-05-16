-- =========================================================================
-- BLOCO 7 — Auditoria de Transações com Trigger
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco7.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-6 executados (sp_transf_bancaria criada)
-- =========================================================================

USE `Financeiro`;

-- -------------------------------------------------------------------------
-- Restaurando o estado de Conta para um ponto conhecido
-- -------------------------------------------------------------------------
TRUNCATE Conta;
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0,    1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
COMMIT;

SELECT * FROM Cliente;
SELECT * FROM TipoConta;
SELECT * FROM Conta;

-- -------------------------------------------------------------------------
-- Criando a tabela de auditoria financeira
--   - dataautitoria = DATE  (não DATETIME — granularidade de dia)
--   - saldos e valor_transacao em DECIMAL(9,2) — exatidão financeira
-- -------------------------------------------------------------------------
CREATE TABLE AuditFin (
    idAuditoria      INT  AUTO_INCREMENT PRIMARY KEY,
    usuario          CHAR(30)       NOT NULL,
    estacao          CHAR(30)       NOT NULL,
    dataautitoria    DATE           NOT NULL,
    conta            INT            NOT NULL,
    saldo_antigo     DECIMAL(9,2)   NOT NULL,
    valor_transacao  DECIMAL(9,2)   NOT NULL,
    saldo_novo       DECIMAL(9,2)   NOT NULL
);

-- -------------------------------------------------------------------------
-- Criando a Trigger AFTER UPDATE em CONTA
--   - Para CADA linha alterada, calcula valor_transacao = NEW.SALDO - OLD.SALDO
--   - Resultado: cada CALL de SP de transferência gera 2 linhas (espelhadas)
-- -------------------------------------------------------------------------
DELIMITER //

CREATE TRIGGER tg_Audita_Fin AFTER UPDATE ON CONTA
FOR EACH ROW BEGIN
    SET @NROCONTA       = OLD.NROCONTA;
    SET @SALDOANTIGO    = OLD.SALDO;
    SET @VALORTRANSACAO = (NEW.SALDO - OLD.SALDO);
    SET @SALDONOVO      = NEW.SALDO;

    INSERT INTO AUDITFIN
        (usuario, estacao, dataautitoria, conta,
         saldo_antigo, valor_transacao, saldo_novo)
    VALUES
        (CURRENT_USER, USER(), CURRENT_DATE,
         @NROCONTA, @SALDOANTIGO, @VALORTRANSACAO, @SALDONOVO);
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- (Para apagar a Trigger no futuro, descomente:)
-- DROP TRIGGER tg_Audita_Fin;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Inspeção da estrutura criada
-- -------------------------------------------------------------------------
SHOW CREATE TABLE AuditFin;
SHOW TRIGGERS LIKE 'Conta';

-- -------------------------------------------------------------------------
-- Bateria de testes — 4 chamadas (uma delas inválida)
-- -------------------------------------------------------------------------
CALL sp_transf_bancaria(1111, 2222, 5000);    -- ✅ → 2 linhas em AuditFin
CALL sp_transf_bancaria(5555, 6666, 1600);    -- ✅ → mais 2 linhas
CALL sp_transf_bancaria(1111, NULL, 2000);    -- ❌ → 0 linhas (falha de param)
CALL sp_transf_bancaria(1111, 2222, 450.55);  -- ✅ → mais 2 linhas

-- -------------------------------------------------------------------------
-- Verificações finais
-- -------------------------------------------------------------------------
SELECT * FROM Conta;
-- Esperado:
--   1111 → 4549.45  (10000 - 5000 - 450.55)
--   2222 → 5450.55  (0 + 5000 + 450.55)
--   5555 → 8400.00
--   6666 → 2600.00

SELECT * FROM AuditFin ORDER BY idAuditoria;
-- Esperado: 6 linhas, com pares espelhados de valor_transacao

-- Soma global de valor_transacao deve ser ZERO (conservação do dinheiro)
SELECT SUM(valor_transacao) AS conservacao_dinheiro FROM AuditFin;

-- =========================================================================
-- FIM DO BLOCO 7
-- =========================================================================
