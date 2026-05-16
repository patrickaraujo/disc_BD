-- =========================================================================
-- BLOCO 8 — Exercício Integrador: sp_saque e sp_deposito
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco8.sql (gabarito do exercício)
-- Pré-requisito: Blocos 1-7 executados (Conta, AuditFin, Trigger ativos).
--
-- ATENÇÃO: este arquivo é o GABARITO. Resolva o exercício antes de consultá-lo.
-- =========================================================================

USE `Financeiro`;

-- -------------------------------------------------------------------------
-- Restaurando estado conhecido antes dos testes
-- -------------------------------------------------------------------------
TRUNCATE Conta;
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0,    1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
COMMIT;
TRUNCATE AUDITFIN;

-- -------------------------------------------------------------------------
-- Requisito 1 — sp_saque
-- (caso já exista, substitua com DROP)
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_saque;

DELIMITER //

CREATE PROCEDURE sp_saque (
    IN v_conta INT,
    IN v_valor FLOAT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    -- Captura existência da conta + saldo
    SET @conta = (SELECT NroConta FROM Conta WHERE NroConta = v_conta);
    SET @saldo = (SELECT saldo    FROM Conta WHERE NroConta = v_conta);

    -- IF nível 1 — validação combinada (existência + valor positivo)
    IF @conta IS NOT NULL AND v_valor > 0 THEN

        -- IF nível 2 — validação de saldo
        IF @saldo >= v_valor THEN

            START TRANSACTION;
                UPDATE Conta SET saldo = saldo - v_valor WHERE NroConta = v_conta;

                IF erro_sql = FALSE THEN
                    COMMIT;
                    SET @saldo = (SELECT saldo FROM Conta WHERE NroConta = v_conta);
                    SELECT 'Saque efetuado com sucesso:' AS RESULTADO,
                           @saldo AS "NOVO SALDO";
                ELSE
                    ROLLBACK;
                    SELECT 'ATENÇÃO: Erro na transação, saque não efetuado!!!' AS RESULTADO;
                END IF;
        ELSE
            SELECT 'ATENÇÃO: Saldo Insuficiente, saque cancelado!!!' AS RESULTADO;
        END IF;

    ELSE
        SELECT 'ATENÇÃO: Parâmetros inadequados, saque cancelado!!!' AS RESULTADO;
    END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Requisito 2 — sp_deposito
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_deposito;

DELIMITER //

CREATE PROCEDURE sp_deposito (
    IN v_conta INT,
    IN v_valor FLOAT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    -- Captura existência da conta (não precisamos de saldo aqui)
    SET @conta = (SELECT NroConta FROM Conta WHERE NroConta = v_conta);

    -- IF único — validação combinada
    IF @conta IS NOT NULL AND v_valor > 0 THEN

        START TRANSACTION;
            UPDATE Conta SET saldo = saldo + v_valor WHERE NroConta = v_conta;

            IF erro_sql = FALSE THEN
                COMMIT;
                SET @saldo = (SELECT saldo FROM Conta WHERE NroConta = v_conta);
                SELECT 'Depósito efetuado com sucesso:' AS RESULTADO,
                       @saldo AS "NOVO SALDO";
            ELSE
                ROLLBACK;
                SELECT 'ATENÇÃO: Erro na transação, depósito não efetuado!!!' AS RESULTADO;
            END IF;

    ELSE
        SELECT 'ATENÇÃO: Parâmetros inadequados, depósito cancelado!!!' AS RESULTADO;
    END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Bateria de testes — sp_saque
-- -------------------------------------------------------------------------
CALL sp_saque(1111, 3000);    -- ✅ sucesso → 1 linha em AuditFin (-3000)
CALL sp_saque(1111, 100000);  -- ❌ saldo insuficiente
CALL sp_saque(9999, 100);     -- ❌ conta inexistente
CALL sp_saque(1111, -500);    -- ❌ valor negativo
CALL sp_saque(1111, 0);       -- ❌ valor zero

-- -------------------------------------------------------------------------
-- Bateria de testes — sp_deposito
-- -------------------------------------------------------------------------
CALL sp_deposito(2222, 5000); -- ✅ sucesso → 1 linha em AuditFin (+5000)
CALL sp_deposito(9999, 100);  -- ❌ conta inexistente
CALL sp_deposito(2222, -200); -- ❌ valor negativo
CALL sp_deposito(2222, 0);    -- ❌ valor zero

-- -------------------------------------------------------------------------
-- Verificações finais
-- -------------------------------------------------------------------------
SELECT * FROM Conta;
-- Esperado:
--   1111 → 7000  (10000 - 3000)
--   2222 → 5000  (0 + 5000)
--   5555 → 10000 (inalterado)
--   6666 → 1000  (inalterado)

SELECT * FROM AuditFin ORDER BY idAuditoria;
-- Esperado: 2 linhas
--   1: conta 1111, valor_transacao -3000.00 (saque)
--   2: conta 2222, valor_transacao  5000.00 (depósito)

-- A soma NÃO é zero (diferente do Bloco 7 — operações assimétricas)
SELECT SUM(valor_transacao) AS resultado_liquido FROM AuditFin;
-- Esperado: +2000.00 (depositou mais do que sacou)

-- =========================================================================
-- FIM DO BLOCO 8 — FIM DA AULA ARQ13
-- =========================================================================
