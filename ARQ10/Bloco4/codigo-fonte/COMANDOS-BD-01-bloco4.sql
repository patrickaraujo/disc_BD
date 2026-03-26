-- =========================================================================
-- BLOCO 4 — Filtros Avançados, Subqueries e Variáveis SQL
-- Disciplina: Banco de Dados | Aula ARQ10
-- Pré-requisito: ter executado os Blocos 1, 2 e 3 por completo
-- =========================================================================

-- -------------------------------------------------------------------------
-- LIKE — Filtro por padrão de texto
-- -------------------------------------------------------------------------

SELECT * FROM pai;

-- Nomes que começam com "J"
SELECT * FROM pai WHERE nome LIKE 'J%';

-- Nomes que NÃO começam com "J"
SELECT * FROM pai WHERE nome NOT LIKE 'J%';

-- Nomes que terminam com "l"
SELECT * FROM pai WHERE nome LIKE '%l';

-- Nomes que contêm "an"
SELECT * FROM pai WHERE nome LIKE '%an%';

-- -------------------------------------------------------------------------
-- BETWEEN — Filtro por intervalo
-- -------------------------------------------------------------------------

-- Idade entre 45 e 50 (inclusive)
SELECT * FROM pai
WHERE idade BETWEEN 45 AND 50
ORDER BY idade;

-- Equivalente ao BETWEEN (com >= e <=)
SELECT * FROM pai
WHERE idade >= 45 AND idade <= 50
ORDER BY idade;

-- Idade entre 46 e 49 (exclusive nos limites)
SELECT * FROM pai
WHERE idade > 45 AND idade < 50
ORDER BY idade;

-- Outro exemplo: entre 29 (exclusive) e 45 (exclusive)
SELECT * FROM pai
WHERE idade > 29 AND idade < 45
ORDER BY idade;

-- -------------------------------------------------------------------------
-- IN e NOT IN — Filtro por lista
-- -------------------------------------------------------------------------

-- Pais que CONSTAM na lista
SELECT * FROM pai
WHERE nome IN ('rubens', 'joao', 'pedro', 'sebastião', 'jorge', 'Humberto');

-- Pais que NÃO CONSTAM na lista
SELECT * FROM pai
WHERE nome NOT IN ('rubens', 'joao', 'pedro', 'sebastião', 'jorge', 'Humberto');

-- -------------------------------------------------------------------------
-- EXISTS e NOT EXISTS — Subqueries
-- -------------------------------------------------------------------------

-- Pais que POSSUEM filhos vinculados
SELECT pai.id, pai.nome FROM pai
WHERE EXISTS (
  SELECT filha.parente_id FROM filha
  WHERE filha.parente_id = pai.id
);

-- Filhas que POSSUEM pais vinculados
SELECT filha.id, filha.nome FROM filha
WHERE EXISTS (
  SELECT pai.id FROM pai
  WHERE pai.id = filha.parente_id
);

-- Mesma consulta usando INNER JOIN + EXISTS
SELECT DISTINCT pai.id, pai.nome FROM pai INNER JOIN filha
ON filha.parente_id = pai.id
WHERE EXISTS (SELECT filha.parente_id FROM filha);

-- Pais que NÃO POSSUEM filhos vinculados
SELECT pai.id, pai.nome FROM pai
WHERE NOT EXISTS (
  SELECT filha.parente_id FROM filha
  WHERE filha.parente_id = pai.id
);

-- ATENÇÃO: esta query NÃO traz resultado (INNER JOIN + NOT EXISTS não funciona)
SELECT pai.id, pai.nome FROM pai INNER JOIN filha
ON filha.parente_id = pai.id
WHERE NOT EXISTS (SELECT filha.parente_id FROM filha);

-- -------------------------------------------------------------------------
-- TRUNCATE — Exclusão física sem volta
-- -------------------------------------------------------------------------

SELECT * FROM pai;
SELECT * FROM filha;

-- FALHA: erro 1701 (FK aponta para pai)
TRUNCATE TABLE pai;

-- FUNCIONA: nenhuma tabela depende de filha
TRUNCATE TABLE filha;

-- Reinserindo os registros da filha
INSERT INTO filha (id, nome, parente_id)
VALUES (1, 'Ana', 1),
       (2, 'Fabia', 2),
       (3, 'José', 3),
       (4, 'Nando', 1),
       (5, 'Fernanda', NULL),
       (6, 'Igor', NULL);

SELECT * FROM pai;
SELECT * FROM filha;

-- -------------------------------------------------------------------------
-- Variáveis SQL — Parametrizando queries
-- -------------------------------------------------------------------------

SELECT * FROM pai;
SELECT * FROM filha;

SET @chave_filha = 5;  -- Fernanda
SET @chave_pai = 7;    -- Evandro

UPDATE filha
SET parente_id = @chave_pai
WHERE id = @chave_filha;

SELECT * FROM filha;

-- -------------------------------------------------------------------------
-- GROUP_CONCAT — Concatenando valores agrupados
-- -------------------------------------------------------------------------

SELECT pai.nome, GROUP_CONCAT(filha.nome SEPARATOR ' | ') AS 'Nome dos Filhos'
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY pai.nome;

-- =========================================================================
-- FIM DO BLOCO 4 — FIM DA AULA ARQ10
-- =========================================================================
