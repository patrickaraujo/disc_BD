CREATE DATABASE empresa;
 
USE empresa;
 
CREATE TABLE funcionarios (
    id_funcionario INT PRIMARY KEY,
    nome VARCHAR(50),
    sobrenome VARCHAR (50),
    salario_hora DECIMAL(5,2),
    data_contratacao DATE
);
 
INSERT INTO funcionarios (
    id_funcionario, nome, sobrenome, salario_hora, data_contratacao)
    VALUES
    (1, 'Eugene', 'Siriguejo', 0.0, '1978-11-30'),
    (2, 'Lula', 'Molusco', 15.0, '1996-03-01'),
    (3, 'Bob', 'Esponja', 12.5, '1999-05-01'),
    (4, 'Patrick', 'Estrela', 12.5, '2000-02-03'),
    (5, 'Sandy', 'Bochechas', 17.25, '2006-05-05');
 
USE empresa;
SELECT * FROM funcionarios;
 
START TRANSACTION;
SET sql_safe_updates = 0;
DELETE FROM funcionarios;
 
 
SELECT * FROM funcionarios;
 
rollback;
 
SELECT * FROM funcionarios;
