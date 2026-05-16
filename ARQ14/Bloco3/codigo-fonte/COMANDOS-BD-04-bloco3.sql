-- =========================================================================
-- BLOCO 3 — LOCK TABLE WRITE e Bloqueio Entre Sessões
-- Disciplina: Banco de Dados | Aula ARQ14
-- Arquivo: COMANDOS-BD-04-bloco3.sql (gabarito de referência)
-- Pré-requisito: Bloco 2 executado (database BLOQUEIOS, tabela messages)
--
-- ATENÇÃO: novamente, duas sessões. Os blocos [S1] e [S2] devem ser
-- executados em ABAS SEPARADAS do Workbench.
-- =========================================================================

-- =========================================================================
-- [S1] — SESSÃO 1: preparar estado conhecido
-- =========================================================================

USE BLOQUEIOS;
SELECT CONNECTION_ID();

-- Reset da tabela para estado conhecido
TRUNCATE TABLE messages;
INSERT INTO messages(message) VALUES('Hello');
COMMIT;
SELECT * FROM messages;
-- Esperado: 1 linha ('Hello')

-- =========================================================================
-- [S2] — SESSÃO 2: confirmar acesso
-- =========================================================================

USE BLOQUEIOS;
SELECT CONNECTION_ID();
SELECT * FROM messages;
-- Esperado: 1 linha ('Hello')

-- =========================================================================
-- [S1] — APLICAR WRITE LOCK
-- =========================================================================

LOCK TABLE messages WRITE;

-- Detentor pode tudo:
SELECT * FROM messages;                                       -- ✅
INSERT INTO messages(message) VALUES('Good Morning');         -- ✅
SELECT * FROM messages;                                       -- ✅ vê 2 linhas
COMMIT;                                                       -- ✅

-- =========================================================================
-- [S2] — TESTAR LEITURA (sob WRITE lock da S1)
-- =========================================================================

SELECT * FROM messages;
-- ⏳ TRAVA. Cursor fica girando.
-- DEIXE TRAVADO e volte para S1.

-- =========================================================================
-- [S1] — DIAGNÓSTICO
-- =========================================================================

SHOW PROCESSLIST;
-- Observe a linha da S2:
--   State: "Waiting for table lock"
--   Time: segundos em espera
--   Info: SELECT * FROM messages
--
-- Compare com o Bloco 2: lá, sob READ lock, SELECTs JAMAIS travavam.
-- Aqui, sob WRITE lock, até SELECT trava.

-- =========================================================================
-- [S1] — LIBERAR
-- =========================================================================

UNLOCK TABLES;
-- IMEDIATAMENTE a S2 destrava e retorna 2 linhas.

-- =========================================================================
-- [S2] — CONFIRMAR APÓS DESTRAVAMENTO
-- =========================================================================

-- (O SELECT pendente já retornou automaticamente.)
-- Faça uma nova consulta para confirmar:
SELECT * FROM messages;
-- Esperado: 2 linhas (Hello, Good Morning)

-- =========================================================================
-- EXTRA — CENÁRIO COM 3 SESSÕES
-- (Opcional — abra uma terceira aba [S3] para reproduzir)
-- =========================================================================
--
-- [S1] LOCK TABLE messages WRITE;
-- [S2] SELECT * FROM messages;             -- trava
-- [S3] INSERT INTO messages(message) VALUES('Da S3');  -- também trava
--
-- [S1] SHOW PROCESSLIST;
--     ↓ Agora apareceriam DUAS linhas em espera:
--       - S2 com SELECT travado
--       - S3 com INSERT travado
--
-- [S1] UNLOCK TABLES;
--     ↓ Ambas destravam (S2 retorna leitura; S3 processa insert).

-- =========================================================================
-- VERIFICAÇÃO FINAL DE CONCEITOS
-- =========================================================================

-- Tabela comparativa empírica:
--
-- ┌───────────────────────────────┬───────────────┬────────────────┐
-- │ Cenário                       │ LOCK READ     │ LOCK WRITE     │
-- ├───────────────────────────────┼───────────────┼────────────────┤
-- │ S1 (detentora) SELECT         │ ✅            │ ✅             │
-- │ S1 (detentora) INSERT         │ ⛔ erro 1099  │ ✅             │
-- │ S2 (outra) SELECT             │ ✅            │ ⏳ trava        │
-- │ S2 (outra) INSERT             │ ⏳ trava       │ ⏳ trava        │
-- └───────────────────────────────┴───────────────┴────────────────┘

-- =========================================================================
-- FIM DO BLOCO 3
-- =========================================================================
