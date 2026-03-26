# Aula de Banco de Dados - Comandos DDL e DML

## Problematização Inicial

Imagine que você é o administrador do banco de dados de uma grande empresa. Em um dia comum de trabalho, você recebe duas situações urgentes:

**Situação 1:** O departamento de RH solicitou a remoção de todos os funcionários de um setor específico para uma reestruturação. Porém, após executar o comando de exclusão, o diretor liga desesperado informando que a solicitação foi cancelada e os dados precisam ser recuperados imediatamente. Como você faria para restaurar as informações?

**Situação 2:** Em outro momento, você precisa limpar completamente uma tabela de logs antigos que ocupam muito espaço no banco de dados. Desta vez, não há chance de arrependimento — os dados realmente não serão mais necessários. Qual seria a melhor abordagem para garantir uma exclusão rápida e definitiva?

Estas situações do dia a dia mostram como é essencial entender o comportamento dos comandos de exclusão e o controle de transações. Nesta aula, você aprenderá a diferença entre `DELETE` e `TRUNCATE`, além de dominar o uso de `COMMIT` e `ROLLBACK` para gerenciar transações com segurança.

---

## Objetivo
Aprender a criar um banco de dados, tabelas, e entender a diferença entre os comandos `DELETE`, `TRUNCATE`, `COMMIT` e `ROLLBACK` com o autocommit desativado.

---

## 1. Criando o Banco de Dados e a Tabela

### Criar o schema (banco de dados)
```sql
CREATE DATABASE empresa;
```

### Selecionar o banco de dados para uso
```sql
USE empresa;
```

### Criar a tabela `funcionarios`
```sql
CREATE TABLE funcionarios (
    id_funcionario INT PRIMARY KEY,
    nome VARCHAR(50),
    sobrenome VARCHAR(50),
    salario_hora DECIMAL(5,2),
    data_contratacao DATE
);
```

---

## 2. Inserindo Dados na Tabela

```sql
INSERT INTO funcionarios (id_funcionario, nome, sobrenome, salario_hora, data_contratacao) VALUES
(1, 'Eugene', 'Siriguejo', 0.0, '1978-11-30'),
(2, 'Lula', 'Molusco', 15.00, '1996-03-15'),
(3, 'Bob', 'Esponja', 12.50, '1999-05-01'),
(4, 'Patrick', 'Estrela', 12.50, '2000-02-03'),
(5, 'Sandy', 'Bochechas', 17.25, '2006-05-05');
```

---

## 3. Trabalhando com Transações

### Desabilitar o autocommit
```sql
SET autocommit = OFF;
```

### Verificando os dados inseridos
```sql
SELECT * FROM funcionarios;
```

### Confirmar a transação atual
```sql
COMMIT;
```

### Remover todos os registros com `DELETE`
```sql
DELETE FROM funcionarios;
```

> **Observação:** Se o `DELETE` não funcionar por restrições de chave estrangeira, utilize `TRUNCATE`:
> ```sql
> TRUNCATE TABLE funcionarios;
> ```

### Verificar que a tabela está vazia
```sql
SELECT * FROM funcionarios;
```

### Desfazer a exclusão com `ROLLBACK` — **Resolvendo a Situação 1**
```sql
ROLLBACK;
```

> 💡 **Reflexão:** Foi exatamente isso que salvou a situação do RH! Como as alterações ainda não tinham sido confirmadas com `COMMIT`, o `ROLLBACK` desfez a exclusão e restaurou todos os dados dos funcionários.

### Confirmar que os dados foram restaurados
```sql
SELECT * FROM funcionarios;
```

---

## 4. Diferença entre DELETE e TRUNCATE

### Usando `DELETE` novamente
```sql
DELETE FROM funcionarios;
```

### Usando `TRUNCATE` como alternativa — **Resolvendo a Situação 2**
```sql
TRUNCATE TABLE funcionarios;
```

> 💡 **Reflexão:** Para a limpeza dos logs antigos, o `TRUNCATE` foi a melhor escolha. Ele remove todos os registros de forma mais rápida e libera espaço em disco imediatamente, ideal para situações onde não há necessidade de recuperação dos dados.

### Confirmar a exclusão permanente com `COMMIT`
```sql
COMMIT;
```

### Verificar que a tabela permanece vazia
```sql
SELECT * FROM funcionarios;
```

---

## Resumo dos Comandos

| Comando | Descrição |
|---------|-----------|
| `CREATE DATABASE` | Cria um novo banco de dados |
| `USE` | Seleciona o banco de dados ativo |
| `CREATE TABLE` | Cria uma nova tabela |
| `INSERT INTO` | Insere registros na tabela |
| `SELECT` | Consulta os registros |
| `SET autocommit = OFF` | Desativa o autocommit automático |
| `COMMIT` | Confirma as alterações permanentemente |
| `ROLLBACK` | Desfaz as alterações não confirmadas |
| `DELETE` | Remove registros (pode ser desfeito com ROLLBACK) |
| `TRUNCATE` | Remove todos os registros rapidamente (não pode ser desfeito facilmente) |

---

## Comparativo: DELETE vs TRUNCATE

| Característica | DELETE | TRUNCATE |
|----------------|--------|----------|
| Remove registros | Um a um | Todos de uma vez |
| Velocidade | Mais lento em grandes volumes | Muito rápido |
| Pode usar WHERE | Sim | Não |
| Pode ser desfeito com ROLLBACK | Sim (dentro de uma transação) | Não (em alguns bancos) |
| Reseta contadores de auto-incremento | Não | Sim |
| Registra cada exclusão no log | Sim | Não |

---

## Exercícios Práticos

1. **Exercício 1:** Crie um novo banco de dados chamado `teste_transacoes`. Crie uma tabela `clientes` com os campos: `id`, `nome`, `email`. Insira 3 clientes.

2. **Exercício 2:** Desabilite o autocommit e faça uma exclusão de todos os registros. Utilize `ROLLBACK` e verifique se os dados voltaram.

3. **Exercício 3:** Repita o processo de exclusão, mas agora utilize `COMMIT` antes de verificar os dados. O que aconteceu de diferente?

4. **Exercício 4 (Desafio):** Simule a situação do RH: insira 5 novos funcionários, inicie uma transação, exclua-os e, antes do commit, receba um "cancelamento" da solicitação. Como você recuperaria os dados?

5. **Exercício 5 (Desafio):** Simule a situação dos logs: crie uma tabela de logs, insira 100 registros (use um loop ou insira manualmente), e utilize `TRUNCATE` para limpá-la. Compare o tempo de execução com um `DELETE` em uma tabela similar.

---

## Conclusão

Nesta aula, aprendemos que:

- O comando `DELETE` é versátil e permite exclusões seletivas, mas seu efeito pode ser revertido com `ROLLBACK` quando usado dentro de uma transação.
- O comando `TRUNCATE` é ideal para limpezas rápidas e definitivas, especialmente em tabelas grandes ou temporárias.
- O controle de transações com `COMMIT` e `ROLLBACK` é essencial para garantir a segurança e a integridade dos dados em cenários críticos.

Com esses conhecimentos, você está preparado para lidar com situações de exclusão de dados no dia a dia de um administrador de banco de dados, sabendo quando agir com cautela e quando optar por uma abordagem mais agressiva.
