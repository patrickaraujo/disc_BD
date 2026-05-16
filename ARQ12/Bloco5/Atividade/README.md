# 🧠 Atividade 5 — Auditoria + Trigger AFTER UPDATE

> **Duração:** 25 minutos  
> **Formato:** Individual  
> **Objetivo:** Verificar a Trigger criada e refletir sobre os pseudo-registros, `FOR EACH ROW` e funções de identidade do MySQL.

---

## 📋 Parte 1 — Execução

40. Após criar a Trigger, execute:

```sql
SHOW TRIGGERS;
```

Quais colunas aparecem no resultado? Identifique e descreva o que `Trigger`, `Event`, `Table` e `Timing` representam.

41. Execute:

```sql
SHOW CREATE TRIGGER Audita_Livros;
```

O MySQL devolve o "código fonte" da Trigger reconstituído. Identifique no retorno:
* O `DEFINER` (quem é o dono).
* O `event_object_table` (a tabela vigiada).
* As palavras-chave `AFTER`, `UPDATE`, `FOR EACH ROW`.

42. Execute `SELECT * FROM tab_audit;` e relate o número de linhas. Qual é a explicação para esse valor?

---

## 📋 Parte 2 — Questões Conceituais

43. Em uma Trigger `AFTER UPDATE`, qual pseudo-registro está disponível: apenas `OLD`, apenas `NEW` ou ambos? Por quê?

44. Em uma Trigger `BEFORE INSERT`, qual pseudo-registro está disponível: apenas `OLD`, apenas `NEW` ou ambos? Justifique.

45. E em uma Trigger `AFTER DELETE`?

46. Suponha um único `UPDATE LIVROS SET Precolivro = Precolivro * 1.10;` (aumento de 10% em todos os preços). Se a tabela `LIVROS` tem 4 livros e a Trigger `Audita_Livros` está ativa, quantas linhas serão inseridas em `tab_audit` por esse comando? Justifique com base em `FOR EACH ROW`.

47. Por que o autor escolheu `DECIMAL(10,4)` para `preco_unitario_novo` e `preco_unitario_antigo` em vez de `FLOAT`?

48. Qual é a diferença entre `CURRENT_USER`, `USER()` e `SESSION_USER()` no MySQL? Em que cenário concreto elas podem retornar valores diferentes?

---

## 📋 Parte 3 — Experimentação (mental)

49. Imagine que você executou `UPDATE LIVROS SET Precolivro = 99.99 WHERE ISBN = 9786525223742;`. Pense em **cada coluna** que será inserida em `tab_audit` para esse `UPDATE`:

* `codigo` → ?
* `usuario` → ?
* `estacao` → ?
* `dataautitoria` → ?
* `codigo_Produto` → ?
* `preco_unitario_novo` → ?
* `preco_unitario_antigo` → ?

(Você confirmará isso experimentalmente no Bloco 6.)

50. Suponha que, após criar a Trigger, você execute `DROP TRIGGER Audita_Livros;` e depois faça o mesmo `UPDATE` da questão 49. O que acontece? `tab_audit` é preenchida?

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

40. Aparecem (entre outras): **`Trigger`** (nome), **`Event`** (`UPDATE`/`INSERT`/`DELETE`), **`Table`** (`livros`), **`Timing`** (`AFTER` ou `BEFORE`), **`Statement`** (corpo), **`sql_mode`**, **`Definer`**, **`character_set_client`**, **`collation_connection`**.

41. No retorno do `SHOW CREATE TRIGGER` aparecem:
* `DEFINER='root'@'localhost'` (ou similar — o usuário que criou).
* `AFTER UPDATE ON livros FOR EACH ROW`.
* O bloco `BEGIN ... END` com o corpo.

42. **0 linhas.** A Trigger só dispara quando há um `UPDATE` em `LIVROS`. Como ainda não houve, `tab_audit` está vazia.

---

### Parte 2

43. **Ambos.** Em `UPDATE`, há um valor "antes" (`OLD`) e um valor "depois" (`NEW`) para cada coluna — naturalmente os dois estão acessíveis.

44. **Apenas `NEW`.** Em `INSERT`, não existe "valor antes" — a linha está sendo criada. `OLD` não existe.

45. **Apenas `OLD`.** Em `DELETE`, há um valor "antes" (a linha que será removida) mas não há "valor depois" — `NEW` não existe.

46. **4 linhas.** O `UPDATE` afeta as 4 linhas de `LIVROS`; o cabeçalho `FOR EACH ROW` faz a Trigger executar 4 vezes — uma para cada linha. Cada execução insere 1 linha em `tab_audit`. Total: 4 inserções.

47. **Precisão**. `FLOAT` é um tipo de **ponto flutuante binário** — sofre arredondamento de natureza não-decimal (ex.: `0.1 + 0.2 = 0.30000000000000004` em IEEE 754). `DECIMAL(10,4)` é **ponto fixo** — preserva exatamente 4 casas decimais. Em sistemas que registram dinheiro (preços), `DECIMAL` é a escolha correta. (A coluna `Precolivro` na tabela `LIVROS` é `FLOAT` por simplicidade do exemplo, mas em produção também deveria ser `DECIMAL`.)

48. * **`CURRENT_USER`** = o usuário sob cujo contexto de segurança o código está executando (importante quando `DEFINER` é usado em SP/Trigger).
* **`USER()`** = o usuário que originalmente conectou na sessão (formato `usuario@host`).
* **`SESSION_USER()`** = sinônimo de `USER()`.

Em uma SP/Trigger criada com `DEFINER='admin'@'localhost' SQL SECURITY DEFINER`, executada por outro usuário `joao`, `CURRENT_USER` retorna `'admin'@'localhost'` (o definer), enquanto `USER()` retorna `'joao'@'host'` (quem conectou).

---

### Parte 3

49. Resultado esperado:

* `codigo` → próximo `AUTO_INCREMENT` (provavelmente `1`).
* `usuario` → `'root@localhost'` ou similar (vem de `CURRENT_USER`).
* `estacao` → `'root@localhost'` ou similar (vem de `USER()`).
* `dataautitoria` → data corrente do servidor (ex.: `2025-04-28 00:00:00` — `CURRENT_DATE` retorna apenas a data, mas o tipo é `DATETIME`, então a hora vem como `00:00:00`).
* `codigo_Produto` → `9786525223742`.
* `preco_unitario_novo` → `99.9900`.
* `preco_unitario_antigo` → `74.9000` (preço inserido no Bloco 3).

50. **Sem Trigger, `tab_audit` não é preenchida.** O `UPDATE` em `LIVROS` acontece normalmente — o preço é alterado para `99.99`. Mas a auditoria deixou de existir, e essa alteração **não deixa rastro** em `tab_audit`. É uma demonstração concreta do papel da Trigger: **rastreabilidade automática que sobrevive ao esquecimento humano**.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Inspecionar Triggers com `SHOW TRIGGERS` e `SHOW CREATE TRIGGER`.  
✅ Diferenciar `OLD` e `NEW` em cada tipo de evento.  
✅ Justificar por que `FOR EACH ROW` é central no comportamento da Trigger.  
✅ Reconhecer que **sem Trigger, não há rastro** — e essa é a diferença entre um sistema que se lembra do passado e um que esquece.  

> 💡 *"Trigger é o jornalista invisível do banco — registra o que aconteceu, mesmo quando ninguém pediu."*
