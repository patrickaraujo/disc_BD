-- =============================================================
-- Gabarito — Exercício 09 / ARQ09
-- Referência nos slides: Exercício 08
-- INSERT de 10 cidades + UPDATE do 5º registro
-- =============================================================

USE imobiliaria;

-- =============================================================
-- PARTE A — Inserir 10 cidades
-- =============================================================

-- 1. Inserir 10 registros na tabela Cidade
INSERT INTO Cidade (CodCidade, Cidade, UF) VALUES
(1, 'São Paulo', 'SP'),
(2, 'Belo Horizonte', 'MG'),
(3, 'Manaus', 'AM'),
(4, 'Ouro Preto', 'MG'),
(5, 'Porto Alegre', 'RS'),
(6, 'Curitiba', 'PR'),
(7, 'Salvador', 'BA'),
(8, 'Recife', 'PE'),
(9, 'Florianópolis', 'SC'),
(10, 'Goiânia', 'GO');

-- 2. Consultar todos os registros
SELECT * FROM Cidade;

-- =============================================================
-- PARTE B — Alterar o 5º registro
-- =============================================================

-- 3. Alterar cidade e UF do registro com CodCidade = 5
UPDATE Cidade SET Cidade = 'JALAPÃO', UF = 'TO' WHERE CodCidade = 5;

-- 4. Confirmar a alteração (registro específico)
SELECT * FROM Cidade WHERE CodCidade = 5;

-- 5. Consultar tabela completa
SELECT * FROM Cidade;
