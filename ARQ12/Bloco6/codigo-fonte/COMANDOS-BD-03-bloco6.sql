-- =========================================================================
-- BLOCO 6 — Integrando Trigger + Transação em SP
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco6.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-5 executados
--   (LIVROS com 4 registros, tab_audit vazia, Trigger Audita_Livros ativa)
-- =========================================================================

USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Criando a Stored Procedure transacional sp_altera_livros
-- (mesmo padrão das SPs anteriores, agora com UPDATE)
-- -------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_altera_livros (
    v_ISBN       BIGINT,
    v_PRECOLIVRO FLOAT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    START TRANSACTION;

        UPDATE livros
        SET Precolivro = v_PRECOLIVRO
        WHERE ISBN = v_ISBN;

        IF erro_sql = FALSE THEN
            COMMIT;
            SELECT 'Preço do Livro alterado com sucesso:' AS RESULTADO,
                   ISBN,
                   PRECOLIVRO AS 'PREÇO NOVO'
            FROM LIVROS
            WHERE ISBN = v_ISBN;
        ELSE
            ROLLBACK;
            SELECT 'ATENÇÃO: Erro na transação, preço do livro não alterado!!!' AS RESULTADO;
        END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Testes — duas chamadas válidas e uma inválida
-- -------------------------------------------------------------------------
CALL sp_altera_livros(9786525223742, 44.44); -- sucesso → Trigger dispara
CALL sp_altera_livros(8888888888888, 10.99); -- sucesso → Trigger dispara
CALL sp_altera_livros(7777777777777, NULL);  -- falha → ROLLBACK → Trigger não dispara

-- -------------------------------------------------------------------------
-- Verificação do estado de LIVROS
-- -------------------------------------------------------------------------
SELECT * FROM LIVROS;
-- Esperado:
--   9786525223742 → Precolivro 44.44   (alterado pela #1)
--   9999999999999 → Precolivro 34.50   (inalterado)
--   8888888888888 → Precolivro 10.99   (alterado pela #2)
--   7777777777777 → Precolivro 29.90   (inalterado — #3 falhou)

-- -------------------------------------------------------------------------
-- Verificação do estado de tab_audit
-- -------------------------------------------------------------------------
SELECT * FROM tab_audit;
-- Esperado: 2 linhas
--   #1: codigo_Produto=9786525223742, antigo=74.9000, novo=44.4400
--   #2: codigo_Produto=8888888888888, antigo=55.9000, novo=10.9900

-- =========================================================================
-- FIM DO BLOCO 6
-- =========================================================================
