-- =========================================================================
-- BLOCO 5 — Análise crítica das falhas da v1 (roteiro de testes diagnósticos)
-- Disciplina: Banco de Dados | Aula ARQ13
-- Arquivo: COMANDOS-BD-03-bloco5.sql (roteiro analítico)
-- Pré-requisito: Blocos 1-4 executados (sp_transf_bancaria v1 criada).
--
-- ATENÇÃO: este bloco NÃO cria SP nem Trigger. É uma sequência de testes
-- diagnósticos para evidenciar as falhas da v1, que serão corrigidas na v2.
-- =========================================================================

USE `Financeiro`;

-- =========================================================================
-- CENÁRIO 1 — Conta de origem inexistente
-- =========================================================================

-- Soma total ANTES dos testes (conservação do dinheiro)
SELECT SUM(saldo) AS soma_total_antes FROM Conta;

-- Tentativa: origem 9999 (que não existe) → destino 2222
CALL sp_transf_bancaria(9999, 2222, 100);
-- Mensagem retornada: 'Saldo Insuficiente, transação cancelada!!!'
-- Diagnóstico: ENGANOSO — o problema real é "conta inexistente".

-- Soma total DEPOIS — não mudou (nada foi transferido)
SELECT SUM(saldo) AS soma_total_depois_cenario1 FROM Conta;


-- =========================================================================
-- CENÁRIO 2 — Conta de destino inexistente — DINHEIRO SOME
-- =========================================================================

-- Saldo de 1111 ANTES
SELECT saldo AS saldo_1111_antes FROM Conta WHERE NroConta = 1111;

-- A "transferência" para o nada
CALL sp_transf_bancaria(1111, 9999, 100);
-- Mensagem retornada: 'Contas alteradas com sucesso:' + NOVO SALDO DESTINO: NULL
-- Diagnóstico: A SP AFIRMA SUCESSO, MAS R$100 DESAPARECERAM!

-- Saldo de 1111 DEPOIS
SELECT saldo AS saldo_1111_depois FROM Conta WHERE NroConta = 1111;

-- Soma total — DIMINUIU R$100
SELECT SUM(saldo) AS soma_total_depois_cenario2 FROM Conta;


-- =========================================================================
-- CENÁRIO 3 — Valor zero, negativo e origem == destino
-- =========================================================================

-- 3a. Valor zero
CALL sp_transf_bancaria(1111, 2222, 0);
-- Mensagem: 'sucesso' (mas saldos não mudam — operação inútil)

-- 3b. Valor negativo — INVERTE A TRANSFERÊNCIA
SELECT saldo FROM Conta WHERE NroConta IN (1111, 2222);
CALL sp_transf_bancaria(1111, 2222, -500);
SELECT saldo FROM Conta WHERE NroConta IN (1111, 2222);
-- Diagnóstico: 1111 GANHOU R$500, 2222 PERDEU R$500.
-- A "transferência" inverteu o fluxo!

-- 3c. Origem == destino
CALL sp_transf_bancaria(1111, 1111, 100);
-- Saldo final inalterado, mas a operação executou — pollui auditoria sem motivo.


-- =========================================================================
-- TESTES DA LÓGICA DE 3 VALORES (referência da Atividade)
-- =========================================================================
SELECT 5 >= 100               AS expr1;  -- 0 (FALSE)
SELECT NULL >= 100            AS expr2;  -- NULL (UNKNOWN)
SELECT NULL = NULL            AS expr3;  -- NULL
SELECT NULL IS NULL           AS expr4;  -- 1 (TRUE)
SELECT (NULL >= 100) IS NULL  AS expr5;  -- 1 (TRUE)


-- =========================================================================
-- LIMPEZA opcional — restaurar saldos originais antes do Bloco 6
-- =========================================================================
-- TRUNCATE Conta;
-- INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0, 1, 2);
-- INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
-- COMMIT;

-- =========================================================================
-- FIM DO BLOCO 5
-- =========================================================================
