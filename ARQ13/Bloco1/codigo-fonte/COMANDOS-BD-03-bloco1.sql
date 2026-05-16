-- =========================================================================
-- BLOCO 1 — Modelagem do Schema Financeiro: Diagrama ER e Forward Engineering
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco1.sql (gabarito de referência)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Os 3 SETs gerados pelo MySQL Workbench Forward Engineering
-- -------------------------------------------------------------------------

-- SET 1 — Salva o valor atual de UNIQUE_CHECKS e o desliga
SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS,
    UNIQUE_CHECKS = 0;

-- SET 2 — Salva o valor atual de FOREIGN_KEY_CHECKS e o desliga
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS,
    FOREIGN_KEY_CHECKS = 0;

-- SET 3 — Salva o SQL_MODE atual e ativa o modo "estrito" do MySQL
SET @OLD_SQL_MODE = @@SQL_MODE,
    SQL_MODE = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -------------------------------------------------------------------------
-- Verificação dos valores ajustados
-- -------------------------------------------------------------------------
SELECT @@UNIQUE_CHECKS, @@FOREIGN_KEY_CHECKS, @@SQL_MODE;
SELECT @OLD_UNIQUE_CHECKS, @OLD_FOREIGN_KEY_CHECKS, @OLD_SQL_MODE;

-- -------------------------------------------------------------------------
-- (Opcional) Restauração ao final do script — NÃO executar agora.
-- Mantemos os flags relaxados para os próximos blocos.
-- -------------------------------------------------------------------------
-- SET SQL_MODE          = @OLD_SQL_MODE;
-- SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
-- SET UNIQUE_CHECKS      = @OLD_UNIQUE_CHECKS;

-- =========================================================================
-- FIM DO BLOCO 1
-- =========================================================================
