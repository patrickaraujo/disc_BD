-- =============================================================
-- Gabarito — Exercício 10 / ARQ09
-- Referência nos slides: Exercício 09
-- UPDATE em massa, DELETE, ROLLBACK e COMMIT
-- =============================================================

USE imobiliaria;

-- =============================================================
-- PREPARAÇÃO — Desativar autocommit para que ROLLBACK funcione
-- =============================================================

SET autocommit = 0;

-- =============================================================
-- PARTE A — UPDATE sem WHERE + ROLLBACK
-- =============================================================

-- 1. Alterar TODAS as cidades para o mesmo nome
UPDATE Cidade SET Cidade = 'Santa Cruz das Palmeiras';

-- 2. Consultar para confirmar a alteração em massa
SELECT * FROM Cidade;

-- 3. Reverter a operação
ROLLBACK;

-- 4. Consultar para confirmar que voltou ao estado anterior
SELECT * FROM Cidade;

-- =============================================================
-- PARTE B — DELETE sem WHERE + ROLLBACK
-- =============================================================

-- 5. Apagar TODOS os registros
DELETE FROM Cidade;

-- 6. Consultar para confirmar que a tabela está vazia
SELECT * FROM Cidade;

-- 7. Reverter a exclusão
ROLLBACK;

-- 8. Consultar para confirmar que os dados voltaram
SELECT * FROM Cidade;

-- =============================================================
-- PARTE C — DELETE com WHERE (registro específico)
-- =============================================================

-- 9. Apagar apenas 1 registro
DELETE FROM Cidade WHERE CodCidade = 3;

-- 10. Consultar para confirmar (9 registros restantes)
SELECT * FROM Cidade;

-- 11. Confirmar as alterações (torna permanente)
COMMIT;

-- =============================================================
-- RESTAURAÇÃO — Reativar autocommit
-- =============================================================

SET autocommit = 1;
