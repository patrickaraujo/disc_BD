-- =========================================================================
-- BLOCO 3 — Encapsulando Transações em Stored Procedures
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco3.sql (gabarito de referência)
-- Pré-requisito: Bloco 2 executado (LIVROS truncada e vazia)
-- =========================================================================

USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Criando a Stored Procedure transacional sp_insere_livros
-- -------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_insere_livros (
    v_ISBN       BIGINT,
    v_AUTOR      VARCHAR(50),
    v_NOMELIVRO  VARCHAR(100),
    v_PRECOLIVRO FLOAT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    START TRANSACTION;

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
-- Inspeção da SP recém-criada
-- -------------------------------------------------------------------------
SHOW PROCEDURE STATUS WHERE Db = 'procs_armazenados' AND Name = 'sp_insere_livros';

-- -------------------------------------------------------------------------
-- Testes — 4 chamadas válidas + 1 inválida
-- -------------------------------------------------------------------------
CALL sp_insere_livros(9786525223742, 'Rubens Zampar Jr',
    'As Expectativas e Dilemas dos Alunos do Ensino Médio acerca do Papel da Universidade',
    74.90);

CALL sp_insere_livros(9999999999999, 'Maria José Almeida',
    'Livro Exemplo 02', 34.50);

CALL sp_insere_livros(8888888888888, 'Américo da Silva',
    'Livro Exemplo 03', 55.90);

CALL sp_insere_livros(7777777777777, 'Adalberto Felisbino Cruz',
    'Livro Exemplo 02', 29.90);

-- Chamada inválida — Precolivro NULL viola a constraint NOT NULL
CALL sp_insere_livros(6666666666666, 'XXXXXXXXXXXX', 'YYYYYYYYYYYYY', NULL);

-- -------------------------------------------------------------------------
-- Verificação do estado final da tabela
-- -------------------------------------------------------------------------
SELECT * FROM LIVROS; -- 4 linhas (a chamada inválida foi descartada)

-- =========================================================================
-- FIM DO BLOCO 3
-- =========================================================================
