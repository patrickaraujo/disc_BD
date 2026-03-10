# 📝 Exercício 07 — Praticando DML no Banco da Imobiliária

> **Duração:** ~30 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Exercício 06 concluído — banco da imobiliária criado

---

## 🎯 Objetivo

Executar comandos DDL de consulta e DML no banco da imobiliária para praticar inserção, consulta, atualização e exclusão de dados, além de compreender o comportamento de ENUM, ROLLBACK, COMMIT e TRUNCATE.

---

## 🖥️ Passo a Passo

### Parte A — Comandos DDL de consulta à estrutura

Abra o **Query Editor** (`Ctrl+T`) e execute os comandos abaixo, um por vez, observando o resultado de cada um:

**1.** Listar todos os bancos de dados disponíveis:
```sql
SHOW DATABASES;
-- ou
SHOW SCHEMAS;
```

**2.** Selecionar o banco da imobiliária e listar suas tabelas:
```sql
USE `imobiliaria`;
show tables;
```

**3.** Verificar os direitos de acesso do usuário conectado:
```sql
USE `imobiliaria`;
show grants;
```

**4.** Ver a estrutura detalhada da tabela `Cidade`:
```sql
USE `imobiliaria`;
describe Cidade;
```

**5.** Filtrar uma coluna específica:
```sql
USE `imobiliaria`;
show columns from Cidade like 'uf';
```

✅ **Checkpoint:** Você consegue ver a estrutura do banco e confirmar que o campo `UF` é do tipo ENUM.

---

### Parte B — INSERT e SELECT com ENUM

**6.** Inserir cidades com UFs válidas:
```sql
USE `imobiliaria`;

INSERT INTO Cidade (CodCidade, Cidade, UF) VALUES
(1, 'Belo Horizonte', 'MG'),
(2, 'Manaus', 'AM'),
(3, 'São Paulo', 'SP'),
(4, 'Ouro Preto', 'MG'),
(5, 'Porto Alegre', 'RS'),
(6, 'Belo Horizonte', 'MG');
```

> 💡 Note que "Belo Horizonte" aparece duas vezes com CodCidade diferente — o banco permite isso porque `Cidade` não tem restrição UNIQUE no nome.

**7.** Consultar todos os registros:
```sql
USE `imobiliaria`;

SELECT * FROM Cidade;
```

**8.** Consultar ordenando por UF:
```sql
SELECT * FROM Cidade ORDER BY UF;
```

**9.** Consultar ordenando pela PK:
```sql
USE `imobiliaria`;

SELECT * FROM Cidade ORDER BY UF;
```

**10.** Tentar inserir uma UF **inválida**:
```sql
USE `imobiliaria`;

SELECT * FROM Cidade;

#	DELETE FROM Cidade WHERE CodCidade = 7;

INSERT INTO Cidade (CodCidade, Cidade, UF) VALUES (7, 'Campinas', 'SP');
SELECT * FROM Cidade;
```

> ⚠️ **Resultado esperado:** O MySQL rejeita o INSERT porque `'XX'` não faz parte da lista ENUM. A mensagem de erro indica que o valor é inválido para a coluna `UF`. Esse é exatamente o propósito do ENUM — restringir os valores aceitos.

✅ **Checkpoint:** 6 registros inseridos com sucesso; tentativa com UF inválida rejeitada.

---

### Parte C — DELETE, UPDATE, ROLLBACK, COMMIT e TRUNCATE

**11.** Excluir um registro específico (substitua `xx` pelo CodCidade desejado):
```sql
DELETE FROM Cidade WHERE CodCidade = 6;
```

**12.** Atualizar o nome de uma cidade (substitua `xx` pelo CodCidade desejado):
```sql
UPDATE Cidade SET Cidade = 'Mariana' WHERE CodCidade = 4;
```

**13.** Verificar as alterações:
```sql
SELECT * FROM Cidade;
```

**14.** Tentar desfazer as alterações:
```sql
ROLLBACK;
```

> ⚠️ **Atenção:** O comportamento do `ROLLBACK` depende do modo **autocommit** do MySQL. Se o autocommit estiver ativado (padrão), cada comando é confirmado automaticamente e o ROLLBACK não terá efeito. Para testar o ROLLBACK, você precisaria desativar o autocommit com `SET autocommit = 0;` antes de executar os comandos.

**15.** Confirmar as alterações:
```sql
COMMIT;
```

**16.** Apagar **todos** os registros da tabela (sem apagar a tabela):
```sql
TRUNCATE TABLE Cidade;
```

> 💡 Diferença importante: `DELETE` remove registros um por um (pode ter WHERE, gera log, pode ser desfeito com ROLLBACK se autocommit estiver desligado). `TRUNCATE` remove todos os registros de uma vez (não pode ter WHERE, mais rápido, não pode ser desfeito).

**17.** Confirmar que a tabela está vazia mas ainda existe:
```sql
SELECT * FROM Cidade;
DESCRIBE Cidade;
```

✅ **Checkpoint:** A tabela `Cidade` está vazia mas sua estrutura permanece intacta.

---

## 🔍 Resumo dos comandos praticados

| Comando | Categoria | O que faz |
|---------|-----------|-----------|
| `SHOW DATABASES` | DDL consulta | Lista todos os schemas |
| `SHOW TABLES` | DDL consulta | Lista tabelas do schema em uso |
| `SHOW GRANTS` | DDL consulta | Mostra permissões do usuário |
| `DESCRIBE` | DDL consulta | Mostra estrutura de uma tabela |
| `SHOW COLUMNS` | DDL consulta | Filtra colunas de uma tabela |
| `INSERT INTO` | DML | Insere registros |
| `SELECT` | DML | Consulta registros |
| `UPDATE` | DML | Altera registros existentes |
| `DELETE` | DML | Remove registros específicos |
| `ROLLBACK` | TCL | Desfaz alterações não confirmadas |
| `COMMIT` | TCL | Confirma alterações |
| `TRUNCATE` | DDL | Remove todos os registros de uma tabela |

---

## ✅ Critérios de conclusão

- [ ] Comandos DDL de consulta executados (`SHOW`, `DESCRIBE`)
- [ ] Dados inseridos na tabela `Cidade` com `INSERT INTO`
- [ ] Consultas com `SELECT` e `ORDER BY` executadas
- [ ] Tentativa de INSERT com ENUM inválido observada (erro esperado)
- [ ] `DELETE` e `UPDATE` executados
- [ ] `ROLLBACK`, `COMMIT` e `TRUNCATE` testados e comportamento observado

---

> 💡 O gabarito completo com todos os comandos está em [`../gabarito/DML_Imobiliaria.sql`](../gabarito/DML_Imobiliaria.sql).
