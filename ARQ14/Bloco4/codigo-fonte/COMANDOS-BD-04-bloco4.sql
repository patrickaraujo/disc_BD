-- =========================================================================
-- BLOCO 4 — Integrador: SP Transacional + LOCK Explícito
-- Disciplina: Banco de Dados | Aula ARQ14
-- Arquivo: COMANDOS-BD-04-bloco4.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-3 executados (BLOQUEIOS, autocommit = 0)
-- =========================================================================

USE BLOQUEIOS;

-- -------------------------------------------------------------------------
-- Passo 1 — Criar a tabela LIVROS
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LIVROS (
    ISBN        BIGINT UNSIGNED NOT NULL,
    Autor       VARCHAR(50)  NOT NULL,
    Nomelivro   VARCHAR(100) NOT NULL,
    Precolivro  FLOAT        NOT NULL,
    PRIMARY KEY (ISBN)
)
ENGINE = InnoDB;

SELECT * FROM LIVROS;
-- Esperado: vazio

-- -------------------------------------------------------------------------
-- Passo 2 — Criar a SP sp_insere_livros_02
-- (padrão HANDLER + COMMIT/ROLLBACK — recap de ARQ12/ARQ13)
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_insere_livros_02;

DELIMITER //

CREATE PROCEDURE sp_insere_livros_02 (
    v_ISBN       BIGINT,
    v_AUTOR      VARCHAR(50),
    v_NOMELIVRO  VARCHAR(100),
    v_PRECOLIVRO FLOAT
)
BEGIN
    DECLARE erro_sql BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    INSERT INTO LIVROS (ISBN, Autor, Nomelivro, Precolivro)
    VALUES (v_ISBN, v_AUTOR, v_NOMELIVRO, v_PRECOLIVRO);

    IF erro_sql = FALSE THEN
        COMMIT;
        SELECT 'Transação efetivada com sucesso!!!' AS RESULTADO;
    ELSE
        ROLLBACK;
        SELECT 'ATENÇÃO: Erro na transação!!!' AS RESULTADO;
    END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Passo 3 — Bateria de testes: LOCK + CALL + UNLOCK
-- -------------------------------------------------------------------------

-- Teste 1 — caminho de sucesso clássico
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(22222222222222, 'Golias Alencar', 'Pet - O livro', 29.99);
UNLOCK TABLES;
-- Esperado: 'Transação efetivada com sucesso!!!'

-- Teste 2 — sucesso, mantendo o LOCK aberto entre CALL e UNLOCK
LOCK TABLE LIVROS WRITE;
CALL sp_insere_livros_02(3333333333333, 'Rosimeire Alencar', 'Receitas da Rosi', 19.90);
SELECT * FROM LIVROS;
-- (S2 estaria travada aqui se tentasse SELECT — veja o Bloco 3)
UNLOCK TABLES;

-- Teste 3 — sucesso, SEM lock explícito (só a SP)
CALL sp_insere_livros_02(44444, 'QUATRO', 'QUATRO', 4.44);
-- Esperado: 'Transação efetivada com sucesso!!!'
-- Funciona porque o INSERT, dentro de transação InnoDB, tem proteção
-- automática de row-lock. O LOCK TABLE não é necessário aqui.

-- Teste 4 — tentativa de duplicata (mesma PK = 44444)
CALL sp_insere_livros_02(44444, 'DUPLICADO', 'DUPLICADO', 9.99);
-- Esperado: 'ATENÇÃO: Erro na transação!!!'
-- O handler captura SQLEXCEPTION 1062 (duplicate entry for PRIMARY)
-- e executa ROLLBACK. Tabela permanece com 3 linhas (não 4).

-- Teste 5 — outro sucesso sem lock
CALL sp_insere_livros_02(6666666, 'SEIS', 'SEIS', 6.66);

-- -------------------------------------------------------------------------
-- Passo 4 — Verificação do estado final
-- -------------------------------------------------------------------------
SELECT * FROM LIVROS ORDER BY ISBN;
-- Esperado: 4 linhas
--   44444           QUATRO              QUATRO             4.44
--   6666666         SEIS                SEIS               6.66
--   3333333333333   Rosimeire Alencar   Receitas da Rosi   19.90
--   22222222222222  Golias Alencar      Pet - O livro      29.99

-- -------------------------------------------------------------------------
-- Passo 5 — Demonstração: COMMIT/ROLLBACK ≠ LOCK/UNLOCK
-- -------------------------------------------------------------------------

-- Cenário: LOCK + INSERT + ROLLBACK + (LOCK AINDA ATIVO)
TRUNCATE LIVROS;
COMMIT;

LOCK TABLE LIVROS WRITE;
INSERT INTO LIVROS VALUES (88888888888888, 'Manual', 'Manual de Testes', 5.00);
ROLLBACK;                    -- desfaz o INSERT
SELECT * FROM LIVROS;        -- vazio (ROLLBACK funcionou)
-- MAS: a tabela continua travada para outras sessões!
-- Em S2 (se aberta): SELECT * FROM LIVROS → TRAVA.

UNLOCK TABLES;               -- agora sim libera

-- Lição: COMMIT e ROLLBACK atuam sobre TRANSAÇÃO.
--        LOCK e UNLOCK atuam sobre LOCK DE TABELA.
--        São mecanismos INDEPENDENTES.

-- -------------------------------------------------------------------------
-- Limpeza final (opcional)
-- -------------------------------------------------------------------------
-- DROP PROCEDURE IF EXISTS sp_insere_livros_02;
-- DROP TABLE IF EXISTS LIVROS;
-- DROP TABLE IF EXISTS messages;
-- DROP DATABASE IF EXISTS BLOQUEIOS;

-- =========================================================================
-- FIM DO BLOCO 4 — FIM DA AULA ARQ14
-- =========================================================================
