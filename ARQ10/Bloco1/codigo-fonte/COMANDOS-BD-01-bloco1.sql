-- =========================================================================
-- BLOCO 1 — Preparação do Ambiente e Introdução ao SELECT
-- Disciplina: Banco de Dados | Aula ARQ10
-- =========================================================================

-- Criando o Banco de Dados/Schema e configurando charset
CREATE DATABASE familia02
DEFAULT CHARSET = utf8
DEFAULT COLLATE = utf8_general_ci;

-- Setando o banco de dados para ser utilizado
USE familia02;

-- -------------------------------------------------------------------------
-- Criando a tabela PAI, inserindo dados e verificando
-- -------------------------------------------------------------------------
CREATE TABLE pai (
  id    INT NOT NULL,
  nome  VARCHAR(50),
  idade SMALLINT,
  PRIMARY KEY (id)
);

INSERT INTO pai (id, nome, idade)
VALUES (1, 'João', 30), (2, 'Maria', 45), (3, 'Pedro', 30),
       (4, 'Manoel', 50), (5, 'Antônio', 30), (6, 'Sebastião', 45),
       (7, 'Evandro', 29);

SELECT * FROM pai;

-- -------------------------------------------------------------------------
-- Criando a tabela FILHA, inserindo dados e verificando
-- -------------------------------------------------------------------------
CREATE TABLE filha (
  id   INT PRIMARY KEY,
  nome VARCHAR(50)
);

INSERT INTO filha (id, nome)
VALUES (1, 'Ana'), (2, 'Fabia'), (3, 'José'),
       (4, 'Nando'), (5, 'Fernanda'), (6, 'Igor');

SELECT * FROM filha;

-- Validando fisicamente as transações
COMMIT;

-- -------------------------------------------------------------------------
-- IMPORTANTE: até este momento, criamos o BD e 2 tabelas (pai e filha)
-- As 2 tabelas são independentes, pois não possuem relacionamento entre si
-- -------------------------------------------------------------------------

-- Demonstração: excluir um pai NÃO afeta a filha (sem FK)
DELETE FROM pai WHERE id = 4;
SELECT * FROM pai;
SELECT * FROM filha;

-- Desfazendo a exclusão com ROLLBACK
ROLLBACK;

-- Verificando que Manoel voltou
SELECT * FROM pai;
SELECT * FROM filha;

-- -------------------------------------------------------------------------
-- Criando o relacionamento entre PAI e FILHA (FK com CASCADE)
-- -------------------------------------------------------------------------

-- Adicionando a coluna parente_id na tabela filha
ALTER TABLE filha ADD parente_id INT;

-- Criando a constraint de FK com ON DELETE CASCADE
ALTER TABLE filha
ADD CONSTRAINT FK_parente
FOREIGN KEY (parente_id) REFERENCES pai(id)
ON DELETE CASCADE;

-- Verificando que parente_id foi criada com NULL
SELECT * FROM filha;

-- Vinculando os 3 primeiros registros
UPDATE filha SET parente_id = 1 WHERE id = 1;
UPDATE filha SET parente_id = 2 WHERE id = 2;
UPDATE filha SET parente_id = 3 WHERE id = 3;

-- Gravando as alterações
COMMIT;

-- Verificando o resultado
SELECT * FROM filha;

-- =========================================================================
-- FIM DO BLOCO 1
-- =========================================================================
