-- =========================================================================
-- BLOCO 2 — Junções (JOINs) entre Tabelas
-- Disciplina: Banco de Dados | Aula ARQ10
-- Pré-requisito: ter executado o Bloco 1 por completo
-- =========================================================================

-- -------------------------------------------------------------------------
-- PRODUTO CARTESIANO ERRADO: junta tudo com tudo
-- 6 filhos × 7 pais = 42 linhas sem sentido!
-- -------------------------------------------------------------------------
SELECT * FROM filha, pai;

-- -------------------------------------------------------------------------
-- 7 EXEMPLOS DE JUNÇÃO CORRETA
-- -------------------------------------------------------------------------

-- Exemplo 1: todas as colunas, junção via WHERE
SELECT * FROM filha, pai
WHERE filha.parente_id = pai.id;

-- Exemplo 2: colunas específicas com alias
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha, pai
WHERE filha.parente_id = pai.id;

-- Exemplo 3: INNER JOIN com cláusula ON
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha INNER JOIN pai
ON filha.parente_id = pai.id;

-- Exemplo 4: INNER JOIN + filtro WHERE por idade
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai', pai.idade AS 'Idade do Pai'
FROM filha INNER JOIN pai
ON filha.parente_id = pai.id
WHERE pai.idade = 30;

-- Exemplo 5: LEFT JOIN — todos da esquerda (filha)
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha LEFT JOIN pai
ON filha.parente_id = pai.id;

-- Exemplo 6: RIGHT JOIN — todos da direita (pai)
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha RIGHT JOIN pai
ON filha.parente_id = pai.id;

-- Exemplo 7: FULL JOIN simulado com UNION ALL
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha LEFT JOIN pai ON filha.parente_id = pai.id
UNION ALL
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha RIGHT JOIN pai ON filha.parente_id = pai.id;

-- -------------------------------------------------------------------------
-- EXCLUSÃO EM CASCATA (ON DELETE CASCADE)
-- -------------------------------------------------------------------------

-- Consultando antes da exclusão
SELECT * FROM pai;
SELECT * FROM filha;
SELECT * FROM filha, pai WHERE filha.parente_id = pai.id;

-- Excluindo Maria (id = 2) — Fabia será excluída automaticamente
DELETE FROM pai WHERE id = 2;
SELECT * FROM filha, pai WHERE filha.parente_id = pai.id;

-- Desfazendo a exclusão
ROLLBACK;

-- -------------------------------------------------------------------------
-- INTEGRIDADE REFERENCIAL — tentativa de INSERT inválido
-- -------------------------------------------------------------------------
SELECT * FROM pai;
SELECT * FROM filha;

-- Este funciona (NULL é permitido na FK)
INSERT INTO filha (id, nome, parente_id) VALUES (7, 'Margareth', NULL);

-- Este FALHA com erro 1452 (pai id=10 não existe)
INSERT INTO filha (id, nome, parente_id) VALUES (8, 'Humberto', 10);

-- =========================================================================
-- FIM DO BLOCO 2
-- =========================================================================
