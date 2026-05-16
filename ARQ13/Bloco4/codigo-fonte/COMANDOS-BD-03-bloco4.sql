-- =========================================================================
-- BLOCO 4 — Stored Procedure de Transferência Bancária (v1)
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco4.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-3 executados (Conta com 4 registros).
-- =========================================================================

USE `Financeiro`;

-- -------------------------------------------------------------------------
-- Criando a Stored Procedure sp_transf_bancaria (versão 1)
-- ATENÇÃO: esta versão tem falhas conhecidas que serão analisadas no Bloco 5
-- e corrigidas no Bloco 6. Use-a aqui APENAS para dominar a estrutura.
-- -------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_transf_bancaria (
    IN v_origem  INT,
    IN v_destino INT,
    IN v_valor   FLOAT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    -- Captura saldo da origem ANTES de qualquer decisão.
    -- Se a conta não existir, @saldo_origem fica NULL (bug latente!).
    SET @saldo_origem  = (SELECT saldo FROM Conta WHERE NroConta = v_origem);
    SET @saldo_destino = 0;

    -- IF nível 1 — validação de parâmetros (NULL?)
    IF v_origem IS NOT NULL AND v_destino IS NOT NULL THEN

        -- IF nível 2 — validação de saldo
        IF @saldo_origem >= v_valor THEN

            -- IF nível 3 — transação
            START TRANSACTION;
                UPDATE Conta SET Saldo = (saldo - v_valor) WHERE NroConta = v_origem;
                UPDATE Conta SET Saldo = (saldo + v_valor) WHERE NroConta = v_destino;

                IF erro_sql = FALSE THEN
                    COMMIT;
                    -- Reler saldos atualizados para a mensagem de sucesso
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
-- Bateria de testes obrigatória (4 chamadas, 4 caminhos)
-- -------------------------------------------------------------------------
CALL sp_transf_bancaria(1111, 2222, 5000);  -- caminho #1: sucesso
CALL sp_transf_bancaria(5555, 6666, 1600);  -- caminho #1: sucesso
CALL sp_transf_bancaria(1111, 2222, 7000);  -- caminho #3: saldo insuficiente
CALL sp_transf_bancaria(1111, NULL, 2000);  -- caminho #4: parâmetro inválido

-- -------------------------------------------------------------------------
-- Verificação final do estado de Conta
-- -------------------------------------------------------------------------
SELECT * FROM Conta;
-- Esperado:
--   1111 → 5000   (debitada na #1)
--   2222 → 5000   (creditada na #1)
--   5555 → 8400   (debitada na #2)
--   6666 → 2600   (creditada na #2)

-- =========================================================================
-- FIM DO BLOCO 4
-- =========================================================================
