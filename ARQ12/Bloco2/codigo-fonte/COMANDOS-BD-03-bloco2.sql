-- =========================================================================
-- BLOCO 2 — Transações Manuais: ROLLBACK e COMMIT
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco2.sql (gabarito de referência)
-- Pré-requisito: Bloco 1 executado (BD procs_armazenados + tabela LIVROS)
-- =========================================================================

USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Experimento 1 — Transação com ROLLBACK
-- -------------------------------------------------------------------------
START TRANSACTION;

    INSERT INTO LIVROS (ISBN, Autor, Nomelivro, Precolivro)
    VALUES
        (9786525223742, 'Rubens Zampar Jr',
         'As Expectativas e Dilemas dos Alunos do Ensino Médio acerca do Papel da Universidade', 74.90),
        (9999999999999, 'Maria José Almeida',         'Livro Exemplo 02', 34.50),
        (8888888888888, 'Américo da Silva',           'Livro Exemplo 03', 55.90),
        (7777777777777, 'Adalberto Felisbino Cruz',   'Livro Exemplo 02', 29.90);

    SELECT * FROM LIVROS; -- 4 linhas (visíveis para a sessão atual)

ROLLBACK; -- desfaz a transação

SELECT * FROM LIVROS; -- 0 linhas (a tabela voltou ao estado anterior)

-- -------------------------------------------------------------------------
-- Experimento 2 — Transação com COMMIT
-- -------------------------------------------------------------------------
START TRANSACTION;

    INSERT INTO LIVROS (ISBN, Autor, Nomelivro, Precolivro)
    VALUES
        (9786525223742, 'Rubens Zampar Jr',
         'As Expectativas e Dilemas dos Alunos do Ensino Médio acerca do Papel da Universidade', 74.90),
        (9999999999999, 'Maria José Almeida',         'Livro Exemplo 02', 34.50),
        (8888888888888, 'Américo da Silva',           'Livro Exemplo 03', 55.90),
        (7777777777777, 'Adalberto Felisbino Cruz',   'Livro Exemplo 02', 29.90);

    SELECT * FROM LIVROS; -- 4 linhas

COMMIT; -- confirma a transação

SELECT * FROM LIVROS; -- 4 linhas (definitivamente persistidas)

-- -------------------------------------------------------------------------
-- Experimento 3 — Limpando a tabela com TRUNCATE
-- -------------------------------------------------------------------------
TRUNCATE TABLE LIVROS;

SELECT * FROM LIVROS; -- 0 linhas (tabela limpa para o Bloco 3)

-- =========================================================================
-- FIM DO BLOCO 2
-- =========================================================================
