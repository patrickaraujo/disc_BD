# 📘 Bloco 8 — Exercício Integrador: Auditoria de Alteração de Preço

> **Duração estimada:** 60 minutos  
> **Objetivo:** Resolver, **de forma autônoma**, um exercício que reúne tudo o que você aprendeu nos sete blocos anteriores: tabela de auditoria, Trigger, Stored Procedure transacional e bateria de testes.  
> **Modalidade:** **Exercício avaliativo** — você implementa **sem código guia**, apenas com requisitos e critérios de validação.

---

## 🚦 Antes de começar

Este é o **bloco de fechamento da aula**. Aqui não há esqueleto pronto, exemplos reescritos nem comandos exibidos. O que existe é uma **especificação de requisitos** — e cabe a você traduzi-la em SQL.

> 💡 **Use os Blocos 1-7 como sua biblioteca pessoal.** Releia os guias quando precisar do padrão, mas **não copie-cole o código-fonte**. O objetivo é você **construir** — não transcrever.

> 🚨 **Não consulte o `codigo-fonte/COMANDOS-BD-03-bloco8.sql` antes de fazer sua tentativa completa.** É um gabarito de referência, não um ponto de partida.

---

## 🎯 Cenário

Você está implementando, em uma livraria, um sistema de **auditoria de preços de livros**. Precisa garantir que:

1. **Toda alteração de preço** de um livro fique registrada em uma tabela de auditoria, com rastro completo (usuário, estação, data, ISBN, preço antigo e preço novo).
2. **A alteração de preço** seja feita por uma Stored Procedure **transacional** — em caso de erro, nada é alterado.
3. As mensagens retornadas para o usuário do sistema sejam **claras** em ambos os casos (sucesso/falha).

---

## 📋 Especificação Funcional

### Requisito 1 — Recriar a tabela `tab_audit`

> ⚠️ **Importante:** mesmo que `tab_audit` já exista (criada no Bloco 5), o exercício pede que você a **recrie**. Antes de criar, **faça `DROP TABLE`** se ela existir.

A tabela tem o nome **`tab_audit`** e as seguintes colunas:

| Coluna | Tipo | Restrições |
|--------|------|------------|
| `codigo` | `INT` | `AUTO_INCREMENT`, **chave primária** |
| `usuario` | `CHAR(30)` | `NOT NULL` |
| `estacao` | `CHAR(30)` | `NOT NULL` |
| `dataautitoria` | `DATETIME` | `NOT NULL` |
| `codigo_Produto` | **`BIGINT`** | `NOT NULL` |
| `preco_unitario_novo` | `DECIMAL(10,4)` | `NOT NULL` |
| `preco_unitario_antigo` | `DECIMAL(10,4)` | `NOT NULL` |

> 📌 **Atenção:** o tipo de `codigo_Produto` é **`BIGINT`** (não `INT`) — porque a tabela auditará o `ISBN` da tabela `LIVROS`, que é `BIGINT UNSIGNED`. Esse é o mesmo tipo do Bloco 5.

> 📌 **Preserve o nome `dataautitoria`** exatamente assim (com a digitação do roteiro original do professor) — para que seu código fique compatível com o gabarito.

---

### Requisito 2 — (Re)criar a Trigger de auditoria

> ⚠️ **Importante:** se a Trigger `Audita_Livros` já existe (criada no Bloco 5), faça **`DROP TRIGGER`** antes de recriá-la — afinal, recriamos a tabela `tab_audit` e a Trigger ficou apontando para uma tabela "antiga" (referência por nome, mas a estrutura é nova).

Especificações:

* **Nome:** `Audita_Livros`.
* **Tipo:** `AFTER UPDATE ON LIVROS`.
* **Cabeçalho:** `FOR EACH ROW BEGIN`.
* **Comportamento:** capturar `OLD.ISBN`, `NEW.PRECOLIVRO` e `OLD.PRECOLIVRO` em variáveis de sessão (`@ISBN`, `@PRECONOVO`, `@PRECOANTIGO`) e inserir uma linha em `tab_audit` com `CURRENT_USER`, `USER()`, `CURRENT_DATE` e os três valores capturados.

> 💡 **Se em dúvida**, consulte o **guia do Bloco 5** — não o código-fonte.

---

### Requisito 3 — Criar a Stored Procedure transacional

Crie uma SP chamada **`sp_altera_livros`** com as seguintes características:

* **Parâmetros:**
  * `v_ISBN` do tipo `BIGINT`.
  * `v_PRECOLIVRO` do tipo `FLOAT`.

* **Estrutura:**
  * Use o **trio padrão**: `DECLARE erro_sql boolean DEFAULT FALSE;`, `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;`, `START TRANSACTION;`.
  * Faça um `UPDATE LIVROS SET Precolivro = v_PRECOLIVRO WHERE ISBN = v_ISBN;`.
  * Decida entre `COMMIT` e `ROLLBACK` com base na flag `erro_sql`.

* **Mensagem de sucesso (3 colunas):**
  * `RESULTADO` = `'Preço do Livro alterado com sucesso:'`
  * `ISBN` = ISBN do livro alterado
  * `'PREÇO NOVO'` = `Precolivro` atual da linha (após o `UPDATE`)
  * → use um `SELECT … FROM LIVROS WHERE ISBN = v_ISBN`.

* **Mensagem de falha:**
  * `RESULTADO` = `'ATENÇÃO: Erro na transação, preço do livro não alterado!!!'`

> 💡 **Se em dúvida**, releia os **Blocos 3 e 6** para o padrão.

---

### Requisito 4 — Bateria de testes

Você deve provar, com chamadas concretas, que **a SP funciona em ambos os caminhos**:

#### 4.1 — Chamadas que **devem** ser bem-sucedidas (mínimo de 2):

```sql
CALL sp_altera_livros(<ISBN_existente_1>, <preco_novo_1>);
CALL sp_altera_livros(<ISBN_existente_2>, <preco_novo_2>);
```

> 💡 Use ISBNs que **existem** na tabela (os 4 livros do Bloco 3) e preços positivos.

#### 4.2 — Chamadas que **devem** falhar (mínimo de 1):

```sql
CALL sp_altera_livros(<ISBN_existente>, NULL);
```

> 💡 `NULL` em uma coluna `NOT NULL` é a forma mais fácil de provocar `SQLEXCEPTION`.

#### 4.3 — Verificação dos resultados

Ao final da bateria, execute:

```sql
SELECT * FROM tab_audit;
```

E confirme que:

* O número de linhas em `tab_audit` é **exatamente igual** ao número de chamadas **bem-sucedidas** (2 no exemplo acima).
* Cada linha tem o `codigo_Produto` correto, e os valores de `preco_unitario_antigo`/`preco_unitario_novo` correspondem exatamente à alteração feita.
* **Nenhuma chamada que falhou** deixou rastro em `tab_audit`.

Confirme também que a tabela `LIVROS` reflete **exatamente** as alterações bem-sucedidas — nem mais, nem menos.

---

## ✅ Critérios de Avaliação

Sua resolução é considerada correta se, e somente se:

| Critério | Como validar |
|----------|--------------|
| ✓ A tabela `tab_audit` existe com a estrutura correta | `SHOW CREATE TABLE tab_audit;` mostra os 7 campos com tipos exatos |
| ✓ A Trigger `Audita_Livros` está registrada | `SHOW TRIGGERS;` lista `Audita_Livros` em `LIVROS`, evento `UPDATE`, timing `AFTER` |
| ✓ A SP `sp_altera_livros` está registrada | `SHOW PROCEDURE STATUS WHERE Db = 'procs_armazenados';` lista a SP |
| ✓ Cada chamada bem-sucedida da SP retorna **3 colunas** com a mensagem combinada | Mensagem de sucesso com `RESULTADO`, `ISBN` e `'PREÇO NOVO'` |
| ✓ Cada chamada falha retorna **1 coluna** com a mensagem `'ATENÇÃO…'` | Texto exato da mensagem de erro |
| ✓ `tab_audit` tem exatamente uma linha por alteração bem-sucedida | Conferir contagem antes e depois |
| ✓ `tab_audit` **não tem** linhas correspondentes a chamadas que falharam | Conferir `codigo_Produto` em cada linha |
| ✓ A tabela `LIVROS` reflete exatamente as alterações bem-sucedidas | Conferir `Precolivro` de cada linha |

---

## ✏️ Atividade Prática

### 📝 Atividade 8 — Resolução Documentada

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Documentar sua resolução: o `CREATE` de cada objeto, as chamadas feitas, o resultado de cada uma e a verificação final.
- Refletir sobre como os 7 blocos anteriores se conectam neste exercício.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa completa.** Comparar sua solução com o gabarito após resolver é um excelente exercício; consultá-lo antes invalida o aprendizado.

➡️ [codigo-fonte/COMANDOS-BD-03-bloco8.sql](./codigo-fonte/COMANDOS-BD-03-bloco8.sql)

---

## 🎯 Conclusão da Aula

Você implementou, ao longo de 8 blocos:

1. ✅ Configuração do ambiente para transações manuais.
2. ✅ Transações com `START TRANSACTION` + `COMMIT`/`ROLLBACK`.
3. ✅ Stored Procedure transacional (`sp_insere_livros`).
4. ✅ Reuso do padrão em outro contexto (`sp_insere_itempedido`).
5. ✅ Tabela de auditoria + Trigger `AFTER UPDATE`.
6. ✅ Integração SP + Trigger (`sp_altera_livros`).
7. ✅ Gestão de usuários e privilégios.
8. ✅ Exercício integrador autoral.

> 💭 *"Saber é poder explicar. Aplicar é poder construir. Construir sob pressão, sem cola, é poder fazer profissionalmente."*

---

## 📚 Próximas Aulas

A partir da próxima aula, a disciplina avança para tópicos como:
* Replicação e backup.
* Tuning e índices.
* Segurança avançada (TLS, criptografia em repouso).

Mas o tripé que você consolidou — **transação · auditoria · privilégio** — é o alicerce sobre o qual tudo isso se constrói. Bom trabalho!

---

> 💭 *"Banco de dados não confiável é só um arquivo grande. Banco de dados confiável é uma fonte da verdade."*
