-- =========================================================================
-- BLOCO 5 — Auditoria Automática: tab_audit + Trigger Audita_Livros
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco5.sql (gabarito de referência)
-- Pré-requisito: Blocos 1-4 executados (LIVROS com 4 registros)
-- =========================================================================

USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Criando a tabela de auditoria
-- ATENÇÃO: codigo_Produto é BIGINT (porque audita ISBN, que é BIGINT UNSIGNED)
-- ATENÇÃO: nome "dataautitoria" preservado conforme o roteiro original
-- -------------------------------------------------------------------------
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
-- Criando a Trigger AFTER UPDATE em LIVROS
-- Para cada linha alterada, registra (preço novo, preço antigo, ISBN, etc.)
-- -------------------------------------------------------------------------
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
-- Inspeção da Trigger
-- -------------------------------------------------------------------------
SHOW TRIGGERS;
SHOW CREATE TRIGGER Audita_Livros;

-- -------------------------------------------------------------------------
-- Verificação inicial — tab_audit começa vazia
-- (a Trigger ainda não foi disparada porque não houve UPDATE em LIVROS)
-- -------------------------------------------------------------------------
SELECT * FROM tab_audit; -- 0 linhas

-- -------------------------------------------------------------------------
-- (Opcional) Para refazer a Trigger, primeiro apague:
-- DROP TRIGGER Audita_Livros;
-- -------------------------------------------------------------------------

-- =========================================================================
-- FIM DO BLOCO 5
-- =========================================================================
