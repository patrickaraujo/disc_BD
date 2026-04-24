-- -----------------------------------------------------------------------------
-- DATABASE
-- -----------------------------------------------------------------------------

create database Procs_Armazenados;
use Procs_Armazenados;

-- -----------------------------------------------------------------------------
-- TABELA USUARIO
-- -----------------------------------------------------------------------------

CREATE TABLE usuario (
    usuario_CPF char(11), 
    usuario_nome varchar(20), 
    usuario_email varchar(35), 
    dt_cadastro datetime, 
    PRIMARY KEY (usuario_CPF)
);

-- -----------------------------------------------------------------------------
-- STORED PROCEDURES
-- -----------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE sp_InsereUsuario(
    v_CPF char(11), 
    v_nome varchar(20),
    v_email varchar(35), 
    v_dt_cadastro datetime)
BEGIN
    IF (v_cpf IS NOT NULL AND v_nome IS NOT NULL AND 
        v_email IS NOT NULL AND v_dt_cadastro IS NOT NULL) THEN
        
        INSERT INTO usuario 
        VALUES (v_CPF, v_nome , v_email, v_dt_cadastro);
        
        SELECT 'Registro inserido com sucesso';
    ELSE
        SELECT 'Parametros inadequados';
    END IF;
END
//

CREATE PROCEDURE sp_consultaUsuario (v_CPF char(11))
BEGIN
    IF (v_cpf IS NOT NULL) THEN
        SELECT * FROM usuario WHERE usuario_cpf = v_cpf;
    ELSE
        SELECT * FROM usuario;
    END IF;
END
//

CREATE PROCEDURE sp_deleteUsuario(v_CPF char(11))
BEGIN
    IF (v_cpf IS NOT NULL) THEN
        DELETE FROM usuario WHERE usuario_cpf = v_cpf;
    ELSE
        DELETE FROM usuario;
    END IF;
END
//

DELIMITER ;

-- -----------------------------------------------------------------------------
-- TESTES PROCEDURES
-- -----------------------------------------------------------------------------

CALL sp_insereUsuario ('03478956212', 'Rubens Zampar', 'rzampar@prof.unisa.br', '2022-10-03');
CALL sp_insereUsuario ('03578956999', 'Pedro da Silva', 'pedro@prof.unisa.br', '2022-10-03');

SELECT * FROM usuario;

CALL sp_consultaUsuario ('03478956212');
CALL sp_deleteUsuario ('03478956212');

-- -----------------------------------------------------------------------------
-- TABELAS PARA TRIGGER
-- -----------------------------------------------------------------------------

CREATE TABLE ItemPedido (
    CODIGOPRODUTO INT NOT NULL, 
    CODIGOPEDIDO INT NOT NULL, 
    QTD INT NOT NULL, 
    PRIMARY KEY (CODIGOPRODUTO, CODIGOPEDIDO)
);

CREATE TABLE Produtos (
    CODIGOPRODUTO INT NOT NULL, 
    NOME VARCHAR(30) NOT NULL, 
    QTDESTOQUE INT NOT NULL, 
    PRECO DECIMAL(5,2), 
    PRIMARY KEY (CODIGOPRODUTO)
);

INSERT INTO ItemPedido VALUES (1, 10, 1), (2, 10, 3);
INSERT INTO Produtos VALUES (1, 'DVD', 100, 50.00), (2, 'LIQUIDIFICADOR', 30, 180.00);

-- -----------------------------------------------------------------------------
-- TRIGGER ESTOQUE
-- -----------------------------------------------------------------------------

DELIMITER //

CREATE TRIGGER tg_atualiza_estoque 
AFTER INSERT ON ItemPedido
FOR EACH ROW 
BEGIN
    IF (NEW.CODIGOPRODUTO IS NOT NULL AND NEW.QTD IS NOT NULL) THEN
        UPDATE Produtos
        SET QTDESTOQUE = QTDESTOQUE - NEW.QTD
        WHERE CODIGOPRODUTO = NEW.CODIGOPRODUTO;
    END IF;
END
//

DELIMITER ;

-- TESTE
INSERT INTO ItemPedido VALUES (1, 11, 5);

SELECT * FROM Produtos;

-- -----------------------------------------------------------------------------
-- TRIGGER AUDITORIA
-- -----------------------------------------------------------------------------

CREATE TABLE tab_audit (
    codigo int AUTO_INCREMENT, 
    usuario char(30) NOT NULL, 
    estacao char(30) NOT NULL, 
    dataautitoria datetime NOT NULL, 
    codigo_Produto int NOT NULL, 
    preco_unitario_novo DECIMAL(10,4) NOT NULL, 
    preco_unitario_antigo DECIMAL(10,4) NOT NULL, 
    PRIMARY KEY(codigo)
);

DELIMITER //

CREATE TRIGGER Audita 
AFTER UPDATE ON Produtos
FOR EACH ROW 
BEGIN
    INSERT INTO tab_audit 
    (usuario, estacao, dataautitoria, codigo_Produto, preco_unitario_novo, preco_unitario_antigo)
    VALUES 
    (CURRENT_USER(), USER(), NOW(), OLD.CODIGOPRODUTO, NEW.PRECO, OLD.PRECO);
END
//

DELIMITER ;

-- TESTE
UPDATE produtos SET preco = 202.50 WHERE codigoproduto = 2;

SELECT * FROM tab_audit;

-- -----------------------------------------------------------------------------
-- FUNCTION + PROCEDURE
-- -----------------------------------------------------------------------------

CREATE TABLE Vinho (
    codbar int, 
    nome varchar(20), 
    preco decimal (4,2), 
    PRIMARY KEY (codbar)
);

INSERT INTO Vinho VALUES 
(1, 'Vinho AAA', 21.90),
(2, 'Vinho BBB', 20.50),
(3, 'Vinho CCC', 35.10);

-- Permissão para função
SET GLOBAL log_bin_trust_function_creators = 1;

-- FUNÇÃO
CREATE FUNCTION fn_desconto (x DECIMAL(5,2), y FLOAT) 
RETURNS DECIMAL(5,2)
RETURN (x * y);

-- PROCEDURE
CREATE PROCEDURE proc_desconto (VAR_VinhoCodBar INT)
SELECT (fn_desconto(Preco, 0.90)) AS valor_com_desconto, Nome
FROM Vinho
WHERE CodBar = VAR_VinhoCodBar;

-- TESTES
CALL proc_desconto(1);

SELECT Preco, fn_desconto(Preco, 0.90) AS desconto
FROM Vinho;
