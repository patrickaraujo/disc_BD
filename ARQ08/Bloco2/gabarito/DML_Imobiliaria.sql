-- =============================================================
-- Gabarito DML — Exercício 07 / ARQ08
-- Todos os comandos praticados na aula
-- =============================================================

USE imobiliaria;

-- =============================================================
-- PARTE A — DDL de consulta à estrutura
-- =============================================================

-- 1. Listar bancos de dados
SHOW DATABASES;
-- alternativa:
SHOW SCHEMAS;

-- 1.1 Listar tabelas do banco em uso
SHOW TABLES;

-- 2. Verificar permissões do usuário
SHOW GRANTS;

-- 3. Ver estrutura da tabela Cidade
DESCRIBE Cidade;

-- 4. Filtrar coluna específica
SHOW COLUMNS FROM Cidade LIKE 'UF';

-- =============================================================
-- PARTE B — INSERT e SELECT com ENUM
-- =============================================================

-- 5. Inserir cidades com UFs válidas
INSERT INTO Cidade (CodCidade, Cidade, UF) VALUES
(1, 'Belo Horizonte', 'MG'),
(2, 'Manaus', 'AM'),
(3, 'São Paulo', 'SP'),
(4, 'Ouro Preto', 'MG'),
(5, 'Porto Alegre', 'RS'),
(6, 'Belo Horizonte', 'MG');

-- 6. Consultar todos os registros
SELECT * FROM Cidade;

-- 7. Consultar ordenando por UF
SELECT * FROM Cidade ORDER BY UF;

-- 8. Consultar ordenando pela PK
SELECT * FROM Cidade ORDER BY CodCidade;

-- 9. Tentar inserir UF inválida (deve gerar ERRO)
--    Descomente para testar:
-- INSERT INTO Cidade (CodCidade, Cidade, UF) VALUES (7, 'Campinas', 'XX');

-- =============================================================
-- PARTE C — DELETE, UPDATE, ROLLBACK, COMMIT e TRUNCATE
-- =============================================================

-- 10. Excluir um registro
DELETE FROM Cidade WHERE CodCidade = 6;

-- 11. Atualizar o nome de uma cidade
UPDATE Cidade SET Cidade = 'Mariana' WHERE CodCidade = 4;

-- 12. Verificar alterações
SELECT * FROM Cidade;

-- 13. Tentar desfazer (depende do autocommit)
ROLLBACK;

-- 14. Confirmar alterações
COMMIT;

-- 15. Apagar todos os registros (sem apagar a tabela)
TRUNCATE TABLE Cidade;

-- 16. Confirmar que a tabela está vazia mas existe
SELECT * FROM Cidade;
DESCRIBE Cidade;
