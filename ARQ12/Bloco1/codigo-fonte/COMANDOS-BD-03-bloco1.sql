-- =========================================================================
-- BLOCO 1 — Preparação do Ambiente: Autocommit e Banco de Trabalho
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco1.sql (gabarito de referência)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Passo 1 — Verificando o estado atual do autocommit
-- "ZERO" = desativado | "UM" = ativado
-- -------------------------------------------------------------------------
SELECT @@autocommit;

-- -------------------------------------------------------------------------
-- Passo 2 — Desativando o autocommit (válido apenas para a sessão atual)
-- -------------------------------------------------------------------------
SET autocommit = 0; -- ou 1 para reativar

-- Forma equivalente:
-- SET autocommit = OFF; -- ou ON

-- Conferindo o ajuste
SELECT @@autocommit;

-- -------------------------------------------------------------------------
-- Passo 3 — (Re)criando o banco de dados procs_armazenados
-- -------------------------------------------------------------------------
DROP DATABASE IF EXISTS procs_armazenados;
CREATE DATABASE procs_armazenados;
USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Passo 4 — Criando a tabela LIVROS
-- ENGINE = InnoDB é obrigatória para que COMMIT/ROLLBACK funcionem
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LIVROS (
    ISBN       BIGINT UNSIGNED NOT NULL,
    Autor      VARCHAR(50)     NOT NULL,
    Nomelivro  VARCHAR(100)    NOT NULL,
    Precolivro FLOAT           NOT NULL,
    PRIMARY KEY (ISBN)
)
ENGINE = InnoDB;

-- -------------------------------------------------------------------------
-- Passo 5 — Verificando a tabela vazia
-- -------------------------------------------------------------------------
SELECT * FROM LIVROS; -- 0 row(s) returned (esperado)

-- -------------------------------------------------------------------------
-- Verificações complementares (referência para a Atividade)
-- -------------------------------------------------------------------------
SHOW CREATE TABLE LIVROS;

SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'procs_armazenados';

-- =========================================================================
-- FIM DO BLOCO 1
-- =========================================================================
