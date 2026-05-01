-- =========================================================================
-- BLOCO 4 — Aplicando em Cenário Real: ItemPedido × Produtos
-- Disciplina: Banco de Dados | Aula ARQ12
-- Arquivo: COMANDOS-BD-03-bloco4.sql (gabarito de referência)
-- Pré-requisito: Bloco 3 executado (LIVROS com 4 registros)
-- =========================================================================

USE procs_armazenados;

-- -------------------------------------------------------------------------
-- Recriando as tabelas ItemPedido e Produtos
-- -------------------------------------------------------------------------
CREATE TABLE ItemPedido (
    CODIGOPRODUTO INT NOT NULL,
    CODIGOPEDIDO  INT NOT NULL,
    QTD           INT NOT NULL,
    PRIMARY KEY (CODIGOPRODUTO, CODIGOPEDIDO)
);

CREATE TABLE Produtos (
    CODIGOPRODUTO INT NOT NULL,
    NOME          VARCHAR(30) NOT NULL,
    QTDESTOQUE    INT NOT NULL,
    PRECO         DECIMAL(5,2),
    PRIMARY KEY (CODIGOPRODUTO)
);

-- -------------------------------------------------------------------------
-- Populando as tabelas e confirmando
-- -------------------------------------------------------------------------
INSERT INTO ItemPedido VALUES (1, 10, 1), (2, 10, 3);
INSERT INTO Produtos   VALUES (1, 'DVD', 100, 50.00),
                              (2, 'LIQUIDIFICADOR', 30, 180.00);
COMMIT;

SELECT * FROM ItemPedido;
SELECT * FROM Produtos;

-- -------------------------------------------------------------------------
-- Criando a Stored Procedure transacional sp_insere_itempedido
-- (mesmo padrão de sp_insere_livros, em outro contexto)
-- -------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE sp_insere_itempedido (
    v_CODIGOPRODUTO INT,
    v_CODIGOPEDIDO  INT,
    v_QTD           INT
)
BEGIN
    DECLARE erro_sql boolean DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;

    START TRANSACTION;

        INSERT INTO ITEMPEDIDO (CODIGOPRODUTO, CODIGOPEDIDO, QTD)
        VALUES (v_CODIGOPRODUTO, v_CODIGOPEDIDO, v_QTD);

        IF erro_sql = FALSE THEN
            COMMIT;
            SELECT 'Item do Pedido incluído com sucesso e Estoque atualizado!!!' AS RESULTADO;
        ELSE
            ROLLBACK;
            SELECT 'ATENÇÃO: Erro na transação, item do Pedido não incluído e Produto não atualizado!!!' AS RESULTADO;
        END IF;
END //

DELIMITER ;

-- -------------------------------------------------------------------------
-- Testes — chamadas válidas
-- -------------------------------------------------------------------------
CALL sp_insere_itempedido(1, 11, 5);
CALL sp_insere_itempedido(1, 12, 6);

-- -------------------------------------------------------------------------
-- Testes — chamadas inválidas
-- (a primeira viola NOT NULL em QTD; a segunda viola PK composta)
-- -------------------------------------------------------------------------
CALL sp_insere_itempedido(1, 11, NULL);
CALL sp_insere_itempedido(1, NULL, 5);

-- -------------------------------------------------------------------------
-- Verificando estado final
-- -------------------------------------------------------------------------
SELECT * FROM ItemPedido; -- 4 linhas (2 originais + 2 inseridas pelas chamadas válidas)
SELECT * FROM Produtos;   -- 2 linhas (estoque inalterado, sem Trigger ainda)

-- =========================================================================
-- FIM DO BLOCO 4
-- =========================================================================
