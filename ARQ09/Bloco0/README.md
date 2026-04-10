# Aula de Banco de Dados - Comandos DDL, DML e Controle de Transações

## Problematização Inicial

Imagine que você é o administrador do banco de dados de uma grande empresa. Em um dia comum de trabalho, você recebe duas situações urgentes:

**Situação 1:** O departamento de RH solicitou a remoção de todos os funcionários de um setor específico para uma reestruturação. Porém, após executar o comando de exclusão, o diretor liga desesperado informando que a solicitação foi cancelada e os dados precisam ser recuperados imediatamente. Como você faria para restaurar as informações?

**Situação 2:** Em outro momento, você precisa limpar completamente uma tabela de logs antigos que ocupam muito espaço no banco de dados. Desta vez, não há chance de arrependimento — os dados realmente não serão mais necessários. Qual seria a melhor abordagem para garantir uma exclusão rápida e definitiva?

Estas situações do dia a dia mostram como é essencial entender o comportamento dos comandos de exclusão e o controle de transações. Nesta aula, você aprenderá a diferença entre `DELETE` e `TRUNCATE`, além de dominar o uso de `COMMIT` e `ROLLBACK` para gerenciar transações com segurança.

---

## Objetivo

Aprender a criar um banco de dados e tabelas, compreender a diferença entre os comandos `DELETE` e `TRUNCATE`, e dominar o controle transacional com `COMMIT` e `ROLLBACK`, entendendo o conceito de **commit implícito** em comandos DDL.

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
(1, 'Eugene',  'Siriguejo', 0.00,  '1978-11-30'),
(2, 'Lula',    'Molusco',   15.00, '1996-03-15'),
(3, 'Bob',     'Esponja',   12.50, '1999-05-01'),
(4, 'Patrick', 'Estrela',   12.50, '2000-02-03'),
(5, 'Sandy',   'Bochechas', 17.25, '2006-05-05');
```

---

## 3. Conceitos Fundamentais de Transação

Antes de executarmos os exemplos, vamos entender três conceitos-chave:

- **Transação:** um conjunto de operações tratadas como uma única unidade lógica. Ou tudo é confirmado, ou nada é.
- **`COMMIT`:** confirma definitivamente as alterações no banco, tornando-as visíveis para todos os usuários.
- **`ROLLBACK`:** desfaz todas as alterações feitas desde o início da transação (ou desde o último `COMMIT`).

No MySQL, por padrão, cada comando é automaticamente confirmado (modo *autocommit*). Para demonstrar o controle transacional, precisamos desabilitar esse comportamento ou iniciar uma transação explícita com `START TRANSACTION`.

> ⚠️ **Pré-requisito:** os exemplos a seguir funcionam apenas em tabelas com engine **InnoDB** (padrão do MySQL moderno), que suporta transações. Engines como MyISAM ignoram silenciosamente o `ROLLBACK`.

---

## 4. Bloco A — Demonstrando `DELETE` com `ROLLBACK` (Situação 1)

Neste bloco, vamos simular exatamente o cenário do RH: uma exclusão acidental que precisa ser revertida.

### Passo 1: Iniciar uma transação explícita
```sql
START TRANSACTION;
```

### Passo 2: Desabilitar o modo seguro do Workbench (se necessário)
```sql
SET SQL_SAFE_UPDATES = 0;
```

> 💡 O MySQL Workbench, por padrão, bloqueia comandos `DELETE` e `UPDATE` sem cláusula `WHERE` (erro 1175). Este comando desativa essa proteção **apenas para a sessão atual**.

### Passo 3: Excluir todos os registros
```sql
DELETE FROM funcionarios;
```

### Passo 4: Verificar que a tabela aparece vazia
```sql
SELECT * FROM funcionarios;
```
**Resultado esperado:** 0 linhas.

### Passo 5: Desfazer a exclusão com `ROLLBACK`
```sql
ROLLBACK;
```

### Passo 6: Confirmar que os dados foram restaurados
```sql
SELECT * FROM funcionarios;
```
**Resultado esperado:** os 5 funcionários originais.

> 💡 **Reflexão — Situação 1 resolvida:** Foi exatamente isso que salvou a situação do RH! Como as alterações ainda não tinham sido confirmadas com `COMMIT`, o `ROLLBACK` desfez a exclusão e restaurou todos os dados.

---

## 5. Bloco B — Demonstrando `TRUNCATE` (Situação 2)

Agora vamos simular a limpeza definitiva da tabela de logs. Aqui entra um conceito fundamental que diferencia radicalmente o `TRUNCATE` do `DELETE`.

### ⚠️ Conceito crítico: Commit Implícito em DDL

O comando `TRUNCATE` é classificado como **DDL (Data Definition Language)**, e não DML. Isso tem uma consequência importantíssima no MySQL:

> **Comandos DDL provocam um `COMMIT` automático (implícito), tanto antes quanto depois da sua execução.**

Isso significa que:

1. Qualquer transação aberta é **automaticamente confirmada** no momento em que o `TRUNCATE` é executado;
2. O `TRUNCATE` em si é executado **fora do controle transacional** — ele **não pode ser desfeito** por um `ROLLBACK` posterior;
3. Não adianta envolver o `TRUNCATE` em `START TRANSACTION ... ROLLBACK` — o rollback não terá efeito sobre ele.

Outros comandos que também provocam commit implícito: `CREATE`, `DROP`, `ALTER`, `RENAME`, `GRANT`, `REVOKE`.

### Passo 1: Executar o `TRUNCATE`
```sql
TRUNCATE TABLE funcionarios;
```

### Passo 2: Tentar reverter (apenas para fins didáticos)
```sql
ROLLBACK;
SELECT * FROM funcionarios;
```
**Resultado esperado:** 0 linhas. O `ROLLBACK` **não restaura** os dados, porque o `TRUNCATE` já foi commitado implicitamente.

> 💡 **Reflexão — Situação 2 resolvida:** Para a limpeza dos logs antigos, o `TRUNCATE` foi a escolha correta justamente por essa característica: ele é rápido, libera espaço imediatamente e dispensa controle transacional. Mas atenção — essa mesma característica o torna **perigoso** em cenários onde pode haver arrependimento.

---

## 6. Comparativo: DELETE vs TRUNCATE

| Característica                   | DELETE                              | TRUNCATE                          |
|----------------------------------|-------------------------------------|-----------------------------------|
| Categoria                        | DML                                 | DDL                               |
| Remove registros                 | Um a um (linha por linha)           | Desaloca a tabela inteira         |
| Velocidade em grandes volumes    | Mais lento                          | Muito rápido                      |
| Pode usar `WHERE`                | Sim                                 | Não                               |
| Pode ser desfeito com `ROLLBACK` | Sim (dentro de uma transação)       | **Não** (commit implícito)        |
| Reseta contadores AUTO_INCREMENT | Não                                 | Sim                               |
| Registra cada exclusão no log    | Sim                                 | Não (minimamente logado)          |
| Dispara *triggers* de `DELETE`   | Sim                                 | Não                               |

---

## 7. Resumo dos Comandos

| Comando                | Descrição                                                       |
|------------------------|-----------------------------------------------------------------|
| `CREATE DATABASE`      | Cria um novo banco de dados                                     |
| `USE`                  | Seleciona o banco de dados ativo                                |
| `CREATE TABLE`         | Cria uma nova tabela                                            |
| `INSERT INTO`          | Insere registros na tabela                                      |
| `SELECT`               | Consulta os registros                                           |
| `START TRANSACTION`    | Inicia uma transação explícita                                  |
| `COMMIT`               | Confirma as alterações permanentemente                          |
| `ROLLBACK`             | Desfaz as alterações não confirmadas                            |
| `DELETE`               | Remove registros (reversível com ROLLBACK dentro de transação)  |
| `TRUNCATE`             | Remove todos os registros (commit implícito, não reversível)    |
| `SET SQL_SAFE_UPDATES` | Liga/desliga o modo seguro do Workbench                         |

---

## 8. Exercícios Práticos

1. **Exercício 1:** Crie um novo banco de dados chamado `teste_transacoes`. Crie uma tabela `clientes` com os campos `id`, `nome` e `email`. Insira 3 clientes.

2. **Exercício 2:** Inicie uma transação explícita, faça uma exclusão de todos os registros com `DELETE`, utilize `ROLLBACK` e verifique se os dados voltaram.

3. **Exercício 3:** Repita o processo, mas agora execute `COMMIT` antes de tentar o `ROLLBACK`. Explique por que o `ROLLBACK` não tem efeito neste caso.

4. **Exercício 4 (Desafio):** Insira 5 novos clientes, inicie uma transação e execute `TRUNCATE TABLE clientes`. Em seguida, tente `ROLLBACK`. O que aconteceu? Relacione o resultado com o conceito de commit implícito em DDL.

5. **Exercício 5 (Desafio):** Crie duas tabelas idênticas `logs_delete` e `logs_truncate`, insira 10.000 registros em cada e compare o tempo de execução de `DELETE FROM` versus `TRUNCATE TABLE`. Documente os resultados.

---

## 9. Conclusão

Nesta aula, aprendemos que:

- O comando `DELETE` é versátil, permite exclusões seletivas com `WHERE` e seu efeito **pode ser revertido** com `ROLLBACK` quando usado dentro de uma transação explícita.
- O comando `TRUNCATE` é ideal para limpezas rápidas e definitivas, mas por ser DDL ele provoca um **commit implícito** — portanto, **não pode ser desfeito** por `ROLLBACK`.
- O controle de transações com `START TRANSACTION`, `COMMIT` e `ROLLBACK` é essencial para garantir a integridade dos dados em cenários críticos.
- Entender quais comandos disparam commit implícito (`CREATE`, `DROP`, `ALTER`, `TRUNCATE`, etc.) é fundamental para evitar surpresas em produção.

Com esses conhecimentos, você está preparado para lidar com situações de exclusão de dados no dia a dia de um administrador de banco de dados, sabendo quando agir com cautela (`DELETE` + transação) e quando optar por uma abordagem mais agressiva e definitiva (`TRUNCATE`).
