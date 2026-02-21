# 📝 Exercício 03 — Praticando SQL Manualmente (DDL)

> **Duração:** ~15 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Exercício 02 concluído — schema `mydb` recriado via script

---

## 🎯 Objetivo

Executar os comandos DDL mais importantes manualmente, compreendendo a sintaxe e o efeito de cada instrução. O Workbench gera SQL automaticamente — mas o profissional precisa entender o que está sendo gerado.

---

## 💡 O que é DDL?

**DDL — Data Definition Language** é o subconjunto do SQL responsável por **criar, alterar e remover a estrutura** do banco (schemas, tabelas, colunas, índices, constraints).

| Comando    | O que faz                                      |
|------------|------------------------------------------------|
| `SHOW`     | Lista objetos existentes                       |
| `CREATE`   | Cria schemas, tabelas e outros objetos         |
| `DROP`     | Remove schemas, tabelas e outros objetos       |
| `USE`      | Seleciona o schema ativo                       |
| `ALTER`    | Modifica a estrutura de uma tabela existente   |
| `DESCRIBE` | Exibe a estrutura de uma tabela                |

---

## 🖥️ Comandos — Execute um por vez

Abra uma nova aba no Query Editor (`Ctrl+T`) e execute cada bloco separadamente. Observe o resultado no painel **Output** e na **Result Grid** antes de seguir para o próximo.

---

### 1. Listar os schemas e tabelas existentes

```sql
-- Ver todos os schemas (bancos) do servidor
SHOW DATABASES;
```

```sql
-- Ver as tabelas do schema ativo
USE mydb;
SHOW TABLES;
```

> 💡 `SHOW DATABASES` é o equivalente a abrir o painel Schemas no Workbench — mas via linha de comando.

---

### 2. Remover e recriar um schema do zero

```sql
-- Apaga o schema inteiro (cuidado — sem confirmação!)
DROP DATABASE novoesquema;
```

```sql
-- Recria o schema vazio
CREATE DATABASE novoesquema;
```

```sql
-- Seleciona o schema para uso
USE novoesquema;
```

> ⚠️ `DROP DATABASE` não pede confirmação — ele executa imediatamente. Em produção, sempre faça backup antes.

---

### 3. Criar a tabela pai manualmente

```sql
CREATE TABLE `TabMae` (
  `CodTabMae` INT NOT NULL AUTO_INCREMENT,
  `DescMae`   VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CodTabMae`)
) ENGINE = InnoDB;
```

> 💡 Compare este comando com o que o Workbench gerou automaticamente no Exercício 01. São idênticos — o Workbench apenas poupou o trabalho de digitação.

---

### 4. Inspecionar a estrutura da tabela

```sql
DESCRIBE tabmae;
```

Resultado esperado:

| Field     | Type        | Null | Key | Default | Extra          |
|-----------|-------------|------|-----|---------|----------------|
| CodTabMae | int         | NO   | PRI | NULL    | auto_increment |
| DescMae   | varchar(45) | NO   |     | NULL    |                |

---

### 5. Criar a tabela filha com PK composta e FK

```sql
CREATE TABLE `TabFilha` (
  `CodTabFilha`      INT         NOT NULL,
  `DescFilha`        VARCHAR(45) NOT NULL,
  `TabMae_CodTabMae` INT         NOT NULL,
  PRIMARY KEY (`CodTabFilha`, `TabMae_CodTabMae`),
  INDEX `fk_TabFilha_TabMae_idx` (`TabMae_CodTabMae` ASC) VISIBLE,
  CONSTRAINT `fk_TabFilha_TabMae`
    FOREIGN KEY (`TabMae_CodTabMae`)
    REFERENCES `TabMae` (`CodTabMae`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;
```

---

### 6. Inspecionar a estrutura da tabela filha

```sql
DESCRIBE tabfilha;
```

Resultado esperado:

| Field            | Type        | Null | Key | Default | Extra |
|------------------|-------------|------|-----|---------|-------|
| CodTabFilha      | int         | NO   | PRI | NULL    |       |
| DescFilha        | varchar(45) | NO   |     | NULL    |       |
| TabMae_CodTabMae | int         | NO   | PRI | NULL    |       |

> 💡 Observe que `CodTabFilha` e `TabMae_CodTabMae` aparecem ambos como `PRI` — confirmando a **chave primária composta**.

---

### 7. Adicionar uma nova coluna (ALTER TABLE — ADD)

```sql
ALTER TABLE tabmae
ADD ValorMae DECIMAL(5,2);
```

Execute `DESCRIBE tabmae;` novamente — `ValorMae` deve aparecer como coluna nova, com `Null: YES` (nullable por padrão).

---

### 8. Modificar a coluna para NOT NULL (ALTER TABLE — MODIFY)

```sql
ALTER TABLE tabmae
MODIFY COLUMN ValorMae DECIMAL(5,2) NOT NULL;
```

Execute `DESCRIBE tabmae;` — `ValorMae` agora deve aparecer com `Null: NO`.

---

### 9. Remover a coluna (ALTER TABLE — DROP COLUMN)

```sql
ALTER TABLE tabmae
DROP COLUMN ValorMae;
```

Execute `DESCRIBE tabmae;` — `ValorMae` não deve mais aparecer.

---

### 10. Remover e recriar a FK manualmente

```sql
-- Remove a constraint de FK
ALTER TABLE tabfilha
DROP CONSTRAINT fk_TabFilha_TabMae;
```

```sql
-- Recria a mesma FK
ALTER TABLE tabfilha
ADD CONSTRAINT `fk_TabFilha_TabMae`
  FOREIGN KEY (`TabMae_CodTabMae`)
  REFERENCES `TabMae` (`CodTabMae`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
```

> 💡 Remover e recriar uma FK é necessário quando precisamos alterar as ações `ON DELETE` ou `ON UPDATE` — não é possível modificar uma constraint existente diretamente.

---

### 11. Remover uma tabela

```sql
DROP TABLE tabfilha;
```

> ⚠️ Só é possível remover `TabFilha` antes de `TabMae` por causa da FK. Tentar o inverso resulta em erro de integridade referencial.

---

## 🔄 Limpeza Final — Obrigatória

Antes de encerrar, execute os passos abaixo para garantir que as próximas aulas continuem a partir do estado correto:

```sql
-- 1. Apagar o schema de exercício
DROP DATABASE novoesquema;
```

Em seguida:
1. Abra o script `NovoEsquema.sql` (`File → Open SQL Script...`)
2. Selecione todo o conteúdo (`Ctrl+A`)
3. Execute (`Ctrl+Shift+Enter`)
4. Confirme que `mydb` está de volta com `tabmae` e `tabfilha`

---

## ✅ Critérios de conclusão

- [ ] Todos os 11 comandos executados com sucesso (✅ no Output)
- [ ] `DESCRIBE` usado após cada `ALTER TABLE` para confirmar as mudanças
- [ ] FK removida e recriada manualmente com sucesso
- [ ] Schema `novoesquema` apagado ao final
- [ ] Schema `mydb` recriado a partir do script `.sql`

---

## 🎯 O que você aprendeu neste exercício

| Ação | Comando DDL |
|------|------------|
| Ver schemas | `SHOW DATABASES` |
| Ver tabelas | `SHOW TABLES` |
| Selecionar schema | `USE nome` |
| Criar schema | `CREATE DATABASE nome` |
| Apagar schema | `DROP DATABASE nome` |
| Criar tabela | `CREATE TABLE nome (...)` |
| Ver estrutura | `DESCRIBE nome` |
| Adicionar coluna | `ALTER TABLE ... ADD coluna tipo` |
| Modificar coluna | `ALTER TABLE ... MODIFY COLUMN coluna tipo` |
| Remover coluna | `ALTER TABLE ... DROP COLUMN coluna` |
| Remover FK | `ALTER TABLE ... DROP CONSTRAINT nome_fk` |
| Adicionar FK | `ALTER TABLE ... ADD CONSTRAINT ... FOREIGN KEY` |
| Remover tabela | `DROP TABLE nome` |

---

> 💭 *"O Workbench gera o SQL por você — mas entender o SQL garante que você não depende do Workbench."*
