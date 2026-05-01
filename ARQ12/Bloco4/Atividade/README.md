# 🧠 Atividade 4 — Consolidando o padrão de SP transacional

> **Duração:** 25 minutos  
> **Formato:** Individual  
> **Objetivo:** Comparar as duas SPs já implementadas (`sp_insere_livros` × `sp_insere_itempedido`) e generalizar o padrão para outros cenários.

---

## 📋 Parte 1 — Execução

31. Após executar o roteiro do Bloco 4, execute os comandos abaixo e relate o estado final:

```sql
SELECT * FROM ItemPedido;
SELECT * FROM Produtos;
```

Quantas linhas há em cada tabela? Quais `(CODIGOPRODUTO, CODIGOPEDIDO)` aparecem em `ItemPedido`?

32. Liste todas as Stored Procedures atualmente presentes no banco `procs_armazenados`. Quais SPs aparecem? Use:

```sql
SHOW PROCEDURE STATUS WHERE Db = 'procs_armazenados';
```

---

## 📋 Parte 2 — Comparação entre SPs

33. Construa uma tabela comparando `sp_insere_livros` (Bloco 3) e `sp_insere_itempedido` (Bloco 4):

| Aspecto | `sp_insere_livros` | `sp_insere_itempedido` |
|---------|-------------------|------------------------|
| Quantidade de parâmetros | _____ | _____ |
| Tabela alvo do `INSERT` | _____ | _____ |
| Comando de abertura da transação | _____ | _____ |
| Variável-flag de erro | _____ | _____ |
| Handler usado | _____ | _____ |
| Estrutura do `IF … END IF` | _____ | _____ |
| Mensagem de sucesso | _____ | _____ |

Quais linhas da tabela são **idênticas** entre as duas SPs?

34. Com base na comparação, descreva, em uma frase, **o esqueleto fixo** do padrão transacional. (Em seguida, ele poderia ser usado para inserir um cliente, um pedido, uma nota fiscal, qualquer coisa…)

---

## 📋 Parte 3 — Questões Conceituais

35. Por que o `INSERT` em `ItemPedido` **não atualiza** automaticamente o estoque em `Produtos`? Que objeto de banco de dados resolveria isso de forma automática? (Você verá ele no Bloco 5.)

36. Qual é a diferença entre **chave primária simples** e **chave primária composta**? Cite uma situação concreta em que a chave composta é mais natural do que a simples.

37. Imagine que você precisa criar uma terceira SP, `sp_insere_pedido`, que **insere um pedido** (em uma tabela `Pedido` hipotética). Sem escrever o código, descreva quais partes da `sp_insere_itempedido` você manteria iguais e quais você adaptaria.

---

## 📋 Parte 4 — Experimentação

38. Tente uma chamada com `CODIGOPRODUTO = 1` e `CODIGOPEDIDO = 11` (combinação que já existe após o teste de sucesso do roteiro):

```sql
CALL sp_insere_itempedido(1, 11, 99);
```

O que acontece? Que erro o MySQL retorna? Por que o handler captura?

39. Após o experimento da questão 38, execute:

```sql
SELECT * FROM ItemPedido WHERE CODIGOPRODUTO = 1 AND CODIGOPEDIDO = 11;
```

Quantas linhas? Qual é o `QTD`? Por quê?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

31. **`ItemPedido`** tem **4 linhas**: `(1,10,1)`, `(2,10,3)`, `(1,11,5)`, `(1,12,6)`. **`Produtos`** tem **2 linhas**: `(1, 'DVD', 100, 50.00)` e `(2, 'LIQUIDIFICADOR', 30, 180.00)` — sem alterações no estoque, conforme esperado.

32. Aparecem `sp_insere_livros` (do Bloco 3) e `sp_insere_itempedido` (do Bloco 4). Ambas com `Type = PROCEDURE`.

---

### Parte 2

33. Tabela comparativa:

| Aspecto | `sp_insere_livros` | `sp_insere_itempedido` |
|---------|-------------------|------------------------|
| Quantidade de parâmetros | 4 | 3 |
| Tabela alvo do `INSERT` | `LIVROS` | `ItemPedido` |
| Comando de abertura da transação | `START TRANSACTION;` | `START TRANSACTION;` ✅ idêntico |
| Variável-flag de erro | `erro_sql boolean DEFAULT FALSE` | `erro_sql boolean DEFAULT FALSE` ✅ idêntico |
| Handler usado | `CONTINUE HANDLER FOR SQLEXCEPTION` | `CONTINUE HANDLER FOR SQLEXCEPTION` ✅ idêntico |
| Estrutura do `IF … END IF` | `IF erro_sql = FALSE THEN COMMIT … ELSE ROLLBACK …` | idem ✅ idêntica |
| Mensagem de sucesso | `'Transação efetivada com sucesso!!!'` | `'Item do Pedido incluído com sucesso e Estoque atualizado!!!'` |

**Linhas idênticas:** abertura de transação, declaração da flag, declaração do handler, estrutura do `IF`. **Variam:** parâmetros, tabela alvo, mensagens.

34. **Esqueleto fixo:** "Declare a flag → declare o handler → abra a transação → execute as modificações → decida `COMMIT`/`ROLLBACK` com base na flag → retorne mensagem". O **conteúdo** (parâmetros, tabela, mensagens) muda; o **arcabouço** é sempre o mesmo.

---

### Parte 3

35. Porque `INSERT INTO ItemPedido` apenas insere uma linha — ele **não diz nada** ao MySQL sobre como o estoque deveria reagir. Para automatizar a atualização do estoque, é necessária uma **Trigger** `AFTER INSERT ON ItemPedido` que faça `UPDATE Produtos SET QTDESTOQUE = QTDESTOQUE - NEW.QTD WHERE …`. Você verá Triggers no Bloco 5 (focada em auditoria), e este padrão específico você já viu na ARQ11.

36. **Chave primária simples** identifica a linha por **uma única coluna** (ex.: `ISBN` em `LIVROS`). **Chave primária composta** identifica a linha pela **combinação** de duas ou mais colunas (ex.: `(CODIGOPRODUTO, CODIGOPEDIDO)` em `ItemPedido`). A composta é natural quando a entidade é uma **associação** entre outras duas — um item de pedido só faz sentido **a partir de um produto e um pedido específicos**, não isoladamente.

37. Manteria iguais: `DELIMITER //`, declaração da flag, declaração do handler, `START TRANSACTION`, estrutura do `IF … END IF`, `DELIMITER ;`. Adaptaria: nome da SP, parâmetros (que dependem das colunas de `Pedido`), o `INSERT INTO Pedido (...) VALUES (...)`, e as mensagens de sucesso/falha.

---

### Parte 4

38. **Erro 1062 — Duplicate entry '1-11' for key 'PRIMARY'**. A combinação `(1,11)` já existe na chave primária composta. O `CONTINUE HANDLER FOR SQLEXCEPTION` captura, vira `erro_sql = TRUE`, a SP executa `ROLLBACK` e retorna `'ATENÇÃO: Erro na transação, item do Pedido não incluído e Produto não atualizado!!!'`.

39. **1 linha**, com `QTD = 5` (o valor do INSERT bem-sucedido feito anteriormente). A tentativa com `QTD = 99` foi descartada pelo `ROLLBACK`. A integridade da chave primária está intacta.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Reconhecer o padrão transacional como um **arcabouço reusável**.  
✅ Identificar quais partes mudam e quais permanecem entre SPs.  
✅ Justificar a separação de responsabilidades entre SP (lógica) e Trigger (efeito colateral automático).  

> 💡 *"Padrão é o que sobra quando você tira o caso particular. Reusar padrão é o que separa o aluno do profissional."*
