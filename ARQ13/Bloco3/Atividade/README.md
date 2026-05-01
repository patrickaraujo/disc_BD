# 🧠 Atividade 3 — Conta, PK composta e FKs

> **Duração:** 25 minutos  
> **Formato:** Individual  
> **Objetivo:** Verificar a estrutura criada para `Conta` e refletir sobre as opções de `ON DELETE` em cenários reais.

---

## 📋 Parte 1 — Inspeção

21. Execute:

```sql
SHOW CREATE TABLE Conta;
```

Localize, no retorno, as duas cláusulas `CONSTRAINT … FOREIGN KEY …`. Anote os nomes das constraints.

22. Execute:

```sql
SELECT
    CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Financeiro' AND TABLE_NAME = 'Conta'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

Quantas linhas aparecem? O que cada uma representa?

23. Execute:

```sql
SELECT INDEX_NAME, COLUMN_NAME, IS_VISIBLE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'Financeiro' AND TABLE_NAME = 'Conta';
```

Quantos índices aparecem? Liste todos e identifique quais são da PK e quais são das FKs.

---

## 📋 Parte 2 — Experimentos com FK

24. Tente inserir uma conta apontando para um cliente **inexistente**:

```sql
INSERT INTO Conta VALUES (9999, 500, 99, 1);
```

O que acontece? Por quê?

> 💡 **Atenção:** se o seu `FOREIGN_KEY_CHECKS` ainda estiver em `0` (do Bloco 1), o `INSERT` será aceito (incorretamente). Para o experimento fazer sentido, religue temporariamente:
>
> ```sql
> SET FOREIGN_KEY_CHECKS = 1;
> ```
>
> Refaça o `INSERT` acima e relate. Em seguida, volte a `FOREIGN_KEY_CHECKS = 0` se quiser manter a configuração da aula.

25. Tente excluir o cliente Rubens (que tem 2 contas):

```sql
DELETE FROM Cliente WHERE idCliente = 1;
```

(Garanta que `FOREIGN_KEY_CHECKS = 1` antes de tentar.) O que acontece? Qual mensagem o MySQL retorna?

26. Após o experimento da questão 25, faça `ROLLBACK` (se a operação tiver tido efeito) ou simplesmente prossiga (se foi bloqueada), e confirme que `Cliente` e `Conta` continuam com seus 2 e 4 registros respectivamente.

---

## 📋 Parte 3 — Comparação ON DELETE

27. Para cada cenário abaixo, indique qual opção de `ON DELETE` seria mais adequada e justifique:

| Cenário | Opção (`NO ACTION` / `CASCADE` / `SET NULL`) | Justificativa |
|---------|---------------------------------------------|---------------|
| `Pedido` ↔ `ItemPedido` (item depende do pedido) | _____ | _____ |
| `Cliente` ↔ `Conta` (financeiro) | _____ | _____ |
| `Categoria` ↔ `Produto` (loja) | _____ | _____ |
| `Autor` ↔ `Livro` (com livros assumindo "Autor desconhecido") | _____ | _____ |
| `Funcionario` ↔ `RegistroPonto` (auditoria) | _____ | _____ |

---

## 📋 Parte 4 — Questões Conceituais

28. Por que **a coluna FK precisa de um índice**? Explique pensando em performance de `JOIN` e validação de FK.

29. Em uma FK com `ON DELETE NO ACTION`, qual seria a alternativa de design para conseguir excluir o cliente sem violar a integridade referencial?

30. A `Conta.NroConta` é uma coluna sem `AUTO_INCREMENT`. Quem é responsável por garantir que dois clientes não tenham contas com o mesmo `NroConta`? Existe alguma proteção no modelo atual contra isso?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

21. As duas constraints são:
* `fk_Conta_Cliente` — sobre `Cliente_idCliente`, refs `Cliente.idCliente`.
* `fk_Conta_TipoConta1` — sobre `TipoConta_idTipoConta`, refs `TipoConta.idTipoConta`.

22. **2 linhas** — uma para cada FK. Cada linha mostra o nome da constraint, a coluna desta tabela, a tabela referenciada e a coluna referenciada.

23. Aparecem **3 índices** (cada índice composto pode aparecer em múltiplas linhas, uma por coluna):
* `PRIMARY` (3 linhas — uma para cada coluna da PK composta).
* `fk_Conta_Cliente_idx` (1 linha).
* `fk_Conta_TipoConta1_idx` (1 linha).

Todos com `IS_VISIBLE = 'YES'`.

---

### Parte 2

24. **Com `FOREIGN_KEY_CHECKS = 1`:** o MySQL retorna erro `1452 — Cannot add or update a child row: a foreign key constraint fails (...)`. A FK protege a integridade referencial.

25. Erro `1451 — Cannot delete or update a parent row: a foreign key constraint fails (...)`. O `ON DELETE NO ACTION` impediu a exclusão porque há contas referenciando esse cliente.

26. Após o erro, nenhum registro foi removido — `Cliente` continua com 2 linhas, `Conta` com 4 linhas.

---

### Parte 3

27. Sugestões:

| Cenário | Opção | Justificativa |
|---------|-------|---------------|
| `Pedido` ↔ `ItemPedido` | `CASCADE` | Itens existem **por causa** do pedido — se o pedido é apagado, faz sentido apagar os itens. |
| `Cliente` ↔ `Conta` (financeiro) | `NO ACTION` | Excluir cliente com saldo é perigoso — exige decisão manual sobre o que fazer com a conta. |
| `Categoria` ↔ `Produto` | `SET NULL` ou `NO ACTION` | Se categoria é apagada, produto pode ser "sem categoria" (`SET NULL`) ou bloquear exclusão. |
| `Autor` ↔ `Livro` (com fallback) | `SET NULL` | Livro continua existindo mesmo sem autor cadastrado — a coluna `Autor` aceita `NULL`. |
| `Funcionario` ↔ `RegistroPonto` | `NO ACTION` | Auditoria nunca pode ser apagada por exclusão de funcionário — a história do ponto é imutável. |

---

### Parte 4

28. Sem índice na FK, **toda inserção em `Conta`** dispararia uma busca linear em `Cliente` para validar `Cliente_idCliente` — `O(n)`. Com índice, é `O(log n)`. Em `JOIN`s entre `Conta` e `Cliente` pelo `idCliente`, sem índice o MySQL precisa fazer "loop em todas as combinações"; com índice, percorre só os registros relevantes. Performance pode mudar de **segundos para microssegundos**.

29. Antes de excluir o cliente, **excluir as contas** dele (`DELETE FROM Conta WHERE Cliente_idCliente = 1`) — isso libera as referências, e a exclusão do cliente passa a ser permitida. Outra alternativa seria mudar a FK para `ON DELETE CASCADE` — mas isso é arriscado em sistemas financeiros (apaga dados sem confirmação humana).

30. **Ninguém** garante automaticamente. A PK composta `(NroConta, Cliente_idCliente, TipoConta_idTipoConta)` permite que dois clientes diferentes tenham contas com mesmo `NroConta` (diferentes só pelo `Cliente_idCliente`). No mundo bancário, isso seria um problema. Para impor unicidade global de `NroConta`, seria necessário adicionar uma constraint extra: `UNIQUE (NroConta)` — mas isso conflita com o desenho atual. **Lição:** a escolha entre PK simples e PK composta tem implicações profundas — vale repensar para sistemas reais.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Inspecionar índices e FKs via `information_schema`.  
✅ Justificar a escolha entre `NO ACTION`, `CASCADE` e `SET NULL` em cada cenário.  
✅ Reconhecer **limitações** do desenho atual e quando vale a pena revê-lo.  

> 💡 *"FK não é só sintaxe — é uma promessa do banco: 'enquanto eu existir, esses dois mundos ficam coerentes'."*
