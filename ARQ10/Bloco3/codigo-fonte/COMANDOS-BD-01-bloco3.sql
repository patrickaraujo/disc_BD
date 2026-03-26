-- =========================================================================
-- BLOCO 3 — Funções de Agregação e Ordenação
-- Disciplina: Banco de Dados | Aula ARQ10
-- Pré-requisito: ter executado os Blocos 1 e 2 por completo
-- =========================================================================

-- ***** FUNÇÕES DE AGREGAÇÃO ***** --

-- Contagem total de registros nas tabelas PAI e FILHA
SELECT COUNT(*) AS 'Total de Pais' FROM pai;
SELECT COUNT(*) AS 'Total de Filhas' FROM filha;

-- Contando apenas os pais com 30 anos
SELECT COUNT(*) FROM pai WHERE idade = 30;

-- -------------------------------------------------------------------------
-- ORDER BY — Ordenação
-- -------------------------------------------------------------------------

-- Todos os pais por ordem de idade (ascendente)
SELECT * FROM pai ORDER BY idade ASC;

-- Todos os pais por ordem de idade (descendente)
SELECT * FROM pai ORDER BY idade DESC;

-- Contando pais menores de 45 anos / com 45 ou menos
SELECT COUNT(*) FROM pai WHERE idade < 45;
SELECT COUNT(*) FROM pai WHERE idade <= 45;

-- -------------------------------------------------------------------------
-- GROUP BY — Agrupamento
-- -------------------------------------------------------------------------

-- Contando os pais POR IDADE
SELECT idade, COUNT(*) AS quantidade FROM pai GROUP BY idade;

-- Contando os pais POR IDADE, ordenado por quantidade (ascendente)
SELECT idade, COUNT(*) AS quantidade FROM pai
GROUP BY idade ORDER BY (2) ASC;

-- -------------------------------------------------------------------------
-- DISTINCT — Valores únicos
-- -------------------------------------------------------------------------

-- Contando as idades distintas
SELECT COUNT(DISTINCT idade) FROM pai;

-- Listando as idades distintas
SELECT DISTINCT idade FROM pai;

-- -------------------------------------------------------------------------
-- JOIN + GROUP BY — Contando filhos por pai
-- -------------------------------------------------------------------------

-- Verificando o estado atual
SELECT * FROM filha, pai WHERE filha.parente_id = pai.id;

-- Quantidade de filhos por pai
SELECT pai.nome, COUNT(*) AS Quantidade_Filhos
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY filha.parente_id;

-- Verificando a tabela filha
SELECT * FROM filha;

-- Vinculando Nando ao pai João
UPDATE filha SET parente_id = 1 WHERE id = 4;
SELECT * FROM filha;

-- Nova contagem (João agora tem 2 filhos)
SELECT pai.nome, COUNT(*) AS Quantidade_Filhos
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY filha.parente_id;

COMMIT;

-- -------------------------------------------------------------------------
-- HAVING — Filtrando grupos
-- -------------------------------------------------------------------------

-- Somente pais com mais de 1 filho
SELECT pai.nome, COUNT(*) AS Quantidade_Filhos
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY filha.parente_id
HAVING COUNT(*) > 1;

-- -------------------------------------------------------------------------
-- Expressões aritméticas
-- -------------------------------------------------------------------------

-- Pais com 45 anos: idade atual e projeção
SELECT nome, idade AS 'Idade atual', (idade + 1) AS 'Idade no próximo ano'
FROM pai
WHERE idade = 45;

-- Todos os pais com projeção, ordenados do mais novo ao mais velho
SELECT nome, idade AS 'Idade atual', (idade + 1) AS 'Idade no próximo ano'
FROM pai
ORDER BY idade ASC;

-- -------------------------------------------------------------------------
-- IS NULL e IS NOT NULL
-- -------------------------------------------------------------------------

-- Filhas SEM pai vinculado
SELECT id, nome, parente_id FROM filha WHERE parente_id IS NULL;

-- Filhas COM pai vinculado
SELECT id, nome, parente_id FROM filha WHERE parente_id IS NOT NULL;

-- -------------------------------------------------------------------------
-- MIN, MAX, AVG, SUM, ROUND
-- -------------------------------------------------------------------------

SELECT * FROM pai;
SELECT MIN(idade) AS 'Menor Idade' FROM pai;
SELECT MAX(idade) AS 'Maior Idade' FROM pai;
SELECT MIN(idade) AS 'Menor', MAX(idade) AS 'Maior', AVG(idade) AS 'Média' FROM pai;

-- Média de idade
SELECT AVG(idade) AS Média_Idade FROM pai;

-- Média arredondada
SELECT ROUND(AVG(idade)) AS 'Média Arredondada' FROM pai;

-- Soma de todas as idades
SELECT SUM(idade) AS 'Total das Idades' FROM pai;

-- =========================================================================
-- FIM DO BLOCO 3
-- =========================================================================
