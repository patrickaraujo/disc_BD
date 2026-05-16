-- =========================================================================
-- BLOCO 6 — Stored Procedure de Transferência (v2 — validação robusta)
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco6.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-5 executados (v1 e cenários de falha conhecidos)
-- =========================================================================

USE `Financeiro`;

-- -------------------------------------------------------------------------
-- Restaurando saldos para um estado conhecido antes dos testes
-- -------------------------------------------------------------------------
TRUNCATE Conta;
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0,    1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
COMMIT;

-- -------------------------------------------------------------------------
-- Criando a SP versão 2 — sp_transf_bancaria02
-- (a v1 do Bloco 4 PERMANECE existindo, lado a lado com a v2)
-- -------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_transf_bancaria02 (
    IN v_origem  INT,
    IN v_destino INT,
    IN v_valor   FLOAT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    -- NOVAS variáveis: validam EXISTÊNCIA das contas (origem e destino).
    -- Se a conta não existir, a variável recebe NULL — exatamente o que
    -- queremos para detectar tanto "conta inexistente" quanto "param NULL".
    SET @conta_origem  = (SELECT NroConta FROM Conta WHERE NroConta = v_origem);
    SET @conta_destino = (SELECT NroConta FROM Conta WHERE NroConta = v_destino);

    -- Captura saldo da origem (igual à v1)
    SET @saldo_origem = (SELECT saldo FROM Conta WHERE NroConta = v_origem);

    -- IF nível 1 — VALIDAÇÃO COMBINADA (existência + valor positivo)
    IF @conta_origem  IS NOT NULL
       AND @conta_destino IS NOT NULL
       AND v_valor > 0
    THEN
        -- IF nível 2 — validação de saldo (igual à v1)
        IF @saldo_origem >= v_valor THEN

            START TRANSACTION;
                UPDATE Conta SET Saldo = (saldo - v_valor) WHERE NroConta = v_origem;
                UPDATE Conta SET Saldo = (saldo + v_valor) WHERE NroConta = v_destino;

                IF erro_sql = FALSE THEN
                    COMMIT;
                    SET @saldo_origem  = (SELECT saldo FROM Conta WHERE NroConta = v_origem);
                    SET @saldo_destino = (SELECT saldo FROM Conta WHERE NroConta = v_destino);
                    SELECT 'Contas alteradas com sucesso:' AS RESULTADO,
                           @saldo_origem  AS "NOVO SALDO ORIGEM",
                           @saldo_destino AS "NOVO SALDO DESTINO";
                ELSE
                    ROLLBACK;
                    SELECT 'ATENÇÃO: Erro na transação, Contas não alteradas!!!' AS RESULTADO;
                END IF;

        ELSE
            SELECT 'ATENÇÃO: Saldo Insuficiente, transação cancelada!!!' AS RESULTADO;
        END IF;

    ELSE
        SELECT 'ATENÇÃO: Parâmetros inadequados, transação cancelada!!!' AS RESULTADO;
    END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Bateria de testes — v2 corrige cada falha do Bloco 5
-- -------------------------------------------------------------------------

-- Teste 1: caso de sucesso clássico
CALL sp_transf_bancaria02(1111, 2222, 7000);
-- Esperado: SUCESSO. 1111 → 3000, 2222 → 7000.

-- Teste 2: origem inexistente (era "diagnóstico errado" na v1)
CALL sp_transf_bancaria02(9999, 2222, 100);
-- Esperado: 'Parâmetros inadequados…' (HONESTO desta vez)

-- Teste 3: destino inexistente (era CATASTRÓFICO na v1 — dinheiro sumia)
CALL sp_transf_bancaria02(1111, 9999, 100);
-- Esperado: 'Parâmetros inadequados…'. Saldo de 1111 INALTERADO.

-- Teste 4: valor negativo (invertia a transferência na v1!)
CALL sp_transf_bancaria02(1111, 2222, -500);
-- Esperado: 'Parâmetros inadequados…'

-- Teste 5: valor zero
CALL sp_transf_bancaria02(1111, 2222, 0);
-- Esperado: 'Parâmetros inadequados…'

-- Teste 6: parâmetro NULL
CALL sp_transf_bancaria02(1111, NULL, 2000);
-- Esperado: 'Parâmetros inadequados…'

-- -------------------------------------------------------------------------
-- Verificação de conservação do dinheiro
-- -------------------------------------------------------------------------
SELECT * FROM Conta;
SELECT SUM(saldo) AS soma_total_apos_v2 FROM Conta;
-- A soma deve ser igual à inicial (21000), confirmando integridade.

-- =========================================================================
-- FIM DO BLOCO 6
-- =========================================================================
