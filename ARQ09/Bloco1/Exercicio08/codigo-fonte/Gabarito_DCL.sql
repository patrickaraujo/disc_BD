-- =============================================================
-- Gabarito DCL — Exercício 08 / ARQ09
-- Referência nos slides: Exercício 07
-- Todos os comandos praticados na aula
-- =============================================================

-- =============================================================
-- PARTE A — Consultar usuários existentes
-- =============================================================

-- 1. Listar todos os usuários cadastrados no MySQL
SELECT * FROM mysql.user;

-- =============================================================
-- PARTE B — Criar um novo usuário
-- =============================================================

-- 2. Criar um novo usuário local com senha
CREATE USER 'rzampar'@'localhost' IDENTIFIED BY '12345@';

-- =============================================================
-- PARTE C — Conceder permissões
-- =============================================================

-- 3. Conceder todos os privilégios ao novo usuário
GRANT ALL PRIVILEGES ON *.* TO 'rzampar'@'localhost';

-- 4. Consultar os privilégios concedidos
SHOW GRANTS FOR 'rzampar'@'localhost';

-- =============================================================
-- PARTE D — Restringir permissões
-- =============================================================

-- 5. Revogar todos os privilégios
REVOKE ALL PRIVILEGES ON *.* FROM 'rzampar'@'localhost';

-- 6. Conceder apenas criação e leitura
GRANT CREATE, SELECT ON *.* TO 'rzampar'@'localhost';

-- 7. Consultar novamente para confirmar
SHOW GRANTS FOR 'rzampar'@'localhost';

-- 8. Efetivar as mudanças
FLUSH PRIVILEGES;

-- =============================================================
-- PARTE E — Remover o usuário
-- =============================================================

-- 9. Apagar o usuário criado
DROP USER 'rzampar'@'localhost';

-- 10. Confirmar que o usuário foi removido
SELECT User, Host FROM mysql.user;
