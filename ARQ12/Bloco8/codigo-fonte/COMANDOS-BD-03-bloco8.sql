-- =========================================================================
-- BLOCO 8 — Exercício Integrador: Auditoria de Alteração de Preço
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco8.sql (gabarito do exercício)
-- Pré-requisito: Blocos 1-7 executados (em particular, BD procs_armazenados,
--                tabela LIVROS populada, e sp_altera_livros do Bloco 6 já
--                criada).
--
-- ATENÇÃO: este arquivo é o GABARITO. Resolva o exercício antes de consultá-lo.
-- =========================================================================

USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Requisito 1 — Recriar a tabela tab_audit
-- -------------------------------------------------------------------------
DROP TABLE IF EXISTS tab_audit;

CREATE TABLE tab_audit (
    codigo                INT AUTO_INCREMENT,
    usuario               CHAR(30) NOT NULL,
    estacao               CHAR(30) NOT NULL,
    dataautitoria         DATETIME NOT NULL,
    codigo_Produto        BIGINT   NOT NULL,
    preco_unitario_novo   DECIMAL(10,4) NOT NULL,
    preco_unitario_antigo DECIMAL(10,4) NOT NULL,
    PRIMARY KEY (codigo)
);

-- -------------------------------------------------------------------------
-- Requisito 2 — (Re)criar a Trigger AFTER UPDATE
-- (necessário recriar porque tab_audit foi recriada — referência por nome,
--  mas vale repetir para garantir o vínculo lógico)
-- -------------------------------------------------------------------------
DROP TRIGGER IF EXISTS Audita_Livros;

DELIMITER //

CREATE TRIGGER Audita_Livros AFTER UPDATE ON LIVROS
FOR EACH ROW BEGIN
    SET @ISBN        = OLD.ISBN;
    SET @PRECONOVO   = NEW.PRECOLIVRO;
    SET @PRECOANTIGO = OLD.PRECOLIVRO;

    INSERT INTO TAB_AUDIT
        (usuario, estacao, dataautitoria, codigo_Produto,
         preco_unitario_novo, preco_unitario_antigo)
    VALUES
        (CURRENT_USER, USER(), CURRENT_DATE, @ISBN, @PRECONOVO, @PRECOANTIGO);
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Requisito 3 — Criar a Stored Procedure transacional sp_altera_livros
-- (caso a SP já tenha sido criada no Bloco 6, faça DROP antes)
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_altera_livros;

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
-- Requisito 4 — Bateria de Testes
-- -------------------------------------------------------------------------

-- 4.1 — Chamadas que devem ser bem-sucedidas (mínimo de 2)
CALL sp_altera_livros(9786525223742, 49.90);
CALL sp_altera_livros(8888888888888, 65.00);

-- 4.2 — Chamada que deve falhar
CALL sp_altera_livros(9999999999999, NULL);

-- (Opcional) Mais um teste de falha — ISBN inexistente faz UPDATE que afeta
-- 0 linhas. NÃO dispara SQLEXCEPTION, ou seja, a SP retorna "sucesso" mas
-- nenhuma linha é alterada e a Trigger não dispara. Cuidado conceitual:
-- "0 rows affected" não é erro!
-- CALL sp_altera_livros(1234567890123, 19.99);

-- 4.3 — Verificações
SELECT * FROM LIVROS;     -- 4 linhas, com preços de 9786525223742 e 8888888888888 alterados
SELECT * FROM tab_audit;  -- 2 linhas, exatamente uma para cada chamada bem-sucedida

-- =========================================================================
-- FIM DO BLOCO 8 — FIM DA AULA ARQ12
-- =========================================================================
