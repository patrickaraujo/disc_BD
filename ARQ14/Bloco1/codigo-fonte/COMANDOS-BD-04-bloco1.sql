-- =========================================================================
-- BLOCO 1 — Administração: Usuários e Privilégios
-- Disciplina: Banco de Dados | Aula ARQ14
-- Arquivo: COMANDOS-BD-04-bloco1.sql (gabarito de referência)
-- Pré-requisito: nenhum (este é o primeiro bloco da aula)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Passo 1 — Verificar e ajustar autocommit
-- -------------------------------------------------------------------------
SELECT @@autocommit;
-- Se retornar 1, desligue:
SET autocommit = 0;

-- -------------------------------------------------------------------------
-- Passo 2 — Inspecionar usuários existentes
-- (requer privilégio administrativo — execute como root)
-- -------------------------------------------------------------------------
SELECT * FROM mysql.user;

-- Versão mais focada (apenas as colunas relevantes):
SELECT User, Host, account_locked
FROM mysql.user
ORDER BY User;

-- -------------------------------------------------------------------------
-- Passo 3 — Criar o novo usuário
-- -------------------------------------------------------------------------
CREATE USER 'rzampar'@'localhost' IDENTIFIED BY '1234';

-- -------------------------------------------------------------------------
-- Passo 4 — Conceder TODOS os privilégios (forma "preguiçosa")
-- -------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON *.* TO 'rzampar'@'localhost';

-- -------------------------------------------------------------------------
-- Passo 5 — Inspecionar privilégios concedidos
-- -------------------------------------------------------------------------
SHOW GRANTS FOR 'rzampar'@'localhost';
-- Saída esperada (1 linha relevante):
--   GRANT ALL PRIVILEGES ON *.* TO `rzampar`@`localhost`

-- -------------------------------------------------------------------------
-- Passo 6 — Revogar tudo (incluindo GRANT OPTION)
-- -------------------------------------------------------------------------
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'rzampar'@'localhost';

-- Confirmar — agora só sobra USAGE (login sem privilégios)
SHOW GRANTS FOR 'rzampar'@'localhost';
-- Saída esperada:
--   GRANT USAGE ON *.* TO `rzampar`@`localhost`

-- -------------------------------------------------------------------------
-- Passo 7 — Conceder apenas o necessário (princípio do menor privilégio)
-- -------------------------------------------------------------------------
GRANT CREATE, SELECT ON *.* TO 'rzampar'@'localhost';

-- Confirmar
SHOW GRANTS FOR 'rzampar'@'localhost';
-- Saída esperada:
--   GRANT SELECT, CREATE ON *.* TO `rzampar`@`localhost`

-- -------------------------------------------------------------------------
-- Passo 8 — Efetivar mudanças
-- -------------------------------------------------------------------------
FLUSH PRIVILEGES;

-- -------------------------------------------------------------------------
-- Passo 9 — Apagar o usuário
-- -------------------------------------------------------------------------
DROP USER 'rzampar'@'localhost';

-- Confirmar a remoção
SELECT User, Host FROM mysql.user WHERE User = 'rzampar';
-- Retorno esperado: vazio

-- =========================================================================
-- FIM DO BLOCO 1
-- =========================================================================
