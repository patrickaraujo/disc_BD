-- =========================================================================
-- BLOCO 2 — Setup de Duas Sessões + LOCK TABLE READ
-- Disciplina: Banco de Dados | Aula ARQ14
-- Arquivo: COMANDOS-BD-04-bloco2.sql (gabarito de referência)
-- Pré-requisito: Bloco 1 executado (autocommit = 0)
--
-- ATENÇÃO: este arquivo contém comandos para DUAS sessões distintas.
-- As seções estão marcadas com [S1] (Sessão 1) e [S2] (Sessão 2).
-- NÃO execute tudo na mesma aba do Workbench — abra Ctrl+T para nova aba.
-- =========================================================================

-- =========================================================================
-- [S1] — SESSÃO 1
-- =========================================================================

-- -------------------------------------------------------------------------
-- Passo 1 — Criação do database e da tabela messages
-- -------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS BLOQUEIOS;
USE BLOQUEIOS;

CREATE TABLE IF NOT EXISTS messages (
    id      INT NOT NULL AUTO_INCREMENT,
    message VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
)
ENGINE = InnoDB;

TRUNCATE TABLE messages;

-- -------------------------------------------------------------------------
-- Passo 2 — Identificar a Sessão 1
-- -------------------------------------------------------------------------
SELECT CONNECTION_ID();
-- Anote o valor retornado. Ex: 42

-- =========================================================================
-- [S2] — SESSÃO 2 (abra nova aba com Ctrl+T)
-- =========================================================================

USE BLOQUEIOS;
SELECT CONNECTION_ID();
-- Anote o valor retornado. Ex: 43
-- Deve ser DIFERENTE do retornado em [S1].

-- =========================================================================
-- [S1] — VOLTE PARA A SESSÃO 1
-- =========================================================================

-- -------------------------------------------------------------------------
-- Passo 3 — Inserção inicial (sem lock)
-- -------------------------------------------------------------------------
INSERT INTO messages(message) VALUES('Hello');
SELECT * FROM messages;
-- Esperado: 1 linha em S1.

-- =========================================================================
-- [S2] — VERIFIQUE NA SESSÃO 2 (antes do COMMIT da S1)
-- =========================================================================

SELECT * FROM messages;
-- Esperado: 0 linhas (S2 não vê a inserção não commitada da S1).

-- =========================================================================
-- [S1] — DE VOLTA À SESSÃO 1
-- =========================================================================

COMMIT;
-- Agora S2 pode ver, na próxima leitura.

-- =========================================================================
-- [S2] — CONFIRME EM S2
-- =========================================================================

SELECT * FROM messages;
-- Esperado: 1 linha ('Hello').

-- =========================================================================
-- [S1] — APLICAR O READ LOCK
-- =========================================================================

LOCK TABLE messages READ;

-- Tentar escrever a partir do detentor do READ lock
INSERT INTO messages(message) VALUES('Hi');
-- Esperado: ERROR 1099 (HY000):
--   Table 'messages' was locked with a READ lock and can't be updated

-- Leitura ainda funciona
SELECT * FROM messages;

-- =========================================================================
-- [S2] — TESTE EM S2 (sob o READ lock da S1)
-- =========================================================================

-- Leitura: deve funcionar (READ é compartilhado entre leitores)
SELECT * FROM messages;

-- Escrita: deve TRAVAR (cursor girando — não retorna)
INSERT INTO messages(message) VALUES('Bye');
-- DEIXE TRAVADA. Volte para S1 para o próximo passo.

-- =========================================================================
-- [S1] — DIAGNÓSTICO COM SHOW PROCESSLIST
-- =========================================================================

SHOW PROCESSLIST;
-- Observe a linha cujo Id corresponde à S2:
--   State: "Waiting for table lock" (ou "Waiting for table metadata lock")
--   Time:  segundos em espera
--   Info:  INSERT INTO messages(message) VALUES('Bye')

-- =========================================================================
-- [S1] — LIBERAR O LOCK
-- =========================================================================

UNLOCK TABLES;
-- IMEDIATAMENTE a S2 destrava e processa o INSERT preso.

-- =========================================================================
-- [S2] — VERIFICAÇÃO FINAL
-- =========================================================================

COMMIT;  -- commita o INSERT que destravou
SELECT * FROM messages;
-- Esperado: 2 linhas ('Hello', 'Bye').

-- =========================================================================
-- FIM DO BLOCO 2
-- =========================================================================
