-- =========================================================================
-- BLOCO 7 — Gestão de Usuários e Privilégios (DCL)
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco7.sql (gabarito de referência)
-- Pré-requisito: conexão como usuário com privilégios de superusuário (root).
-- =========================================================================

-- -------------------------------------------------------------------------
-- Passo 1 — Listar os usuários atualmente cadastrados
-- -------------------------------------------------------------------------
SELECT * FROM mysql.user;

-- Versão simplificada (apenas usuário e host)
SELECT User, Host FROM mysql.user;

-- -------------------------------------------------------------------------
-- Passo 2 — Criar um novo usuário
-- -------------------------------------------------------------------------
CREATE USER 'rzampar'@'localhost' IDENTIFIED BY '12345@';

-- -------------------------------------------------------------------------
-- Passo 3 — Conceder direito de acesso (TODOS os privilégios)
-- -------------------------------------------------------------------------
GRANT ALL PRIVILEGES ON *.* TO 'rzampar'@'localhost';

-- -------------------------------------------------------------------------
-- Passo 4 — Conferir os privilégios concedidos
-- -------------------------------------------------------------------------
SHOW GRANTS FOR 'rzampar'@'localhost';

-- -------------------------------------------------------------------------
-- Passo 5 — Efetivar mudanças (após manipulação direta de mysql.user;
-- redundante após CREATE USER/GRANT, mas inofensivo)
-- -------------------------------------------------------------------------
FLUSH PRIVILEGES;

-- -------------------------------------------------------------------------
-- Passo 6 — Remover o usuário
-- -------------------------------------------------------------------------
DROP USER 'rzampar'@'localhost';

-- -------------------------------------------------------------------------
-- Passo 7 — Verificações finais
-- -------------------------------------------------------------------------
SELECT User, Host FROM mysql.user WHERE User = 'rzampar'; -- 0 linhas
USE procs_armazenados;
SELECT * FROM LIVROS; -- 4 linhas (intactas; alterações de Bloco 6 preservadas)

-- =========================================================================
-- FIM DO BLOCO 7
-- =========================================================================
