# 🧠 Atividade 8 — Resolução Documentada do Exercício Integrador

> **Duração:** 60 minutos  
> **Formato:** Individual  
> **Objetivo:** Documentar passo a passo a sua resolução do exercício integrador, explicando suas escolhas e reflexões finais.

> ⚠️ **Esta atividade é avaliativa.** Resolva o exercício do Bloco 8 antes de responder. Não consulte o gabarito até concluir.

---

## 📋 Parte 1 — Sua Resolução

72. Cole, abaixo, o `CREATE TABLE tab_audit (...)` que você executou. Em seguida, descreva quais cuidados você teve ao redigi-lo (especialmente quanto ao tipo de `codigo_Produto`).

73. Cole o `DROP TRIGGER IF EXISTS Audita_Livros;` (se aplicável) seguido do seu `CREATE TRIGGER Audita_Livros … FOR EACH ROW BEGIN … END`. Que pseudo-registros você usou (`OLD` ou `NEW`)? Em quais variáveis de sessão você capturou os valores?

74. Cole o seu `CREATE PROCEDURE sp_altera_livros(...) BEGIN … END`. Especificamente, identifique:
* Em qual linha aparece o `DECLARE erro_sql`?
* Em qual linha aparece o handler?
* Em qual linha aparece o `START TRANSACTION`?
* Em qual linha está o `IF erro_sql = FALSE THEN COMMIT … ELSE ROLLBACK … END IF`?

---

## 📋 Parte 2 — Bateria de Testes

75. Liste as chamadas que você fez à SP. Para cada uma, indique:

| Chamada | Comando completo | Resultado esperado | Resultado obtido |
|---------|------------------|-------------------|------------------|
| #1 | _____ | _____ | _____ |
| #2 | _____ | _____ | _____ |
| #3 | _____ | _____ | _____ |

76. Cole o resultado de `SELECT * FROM tab_audit;` ao final da bateria. Quantas linhas aparecem? Confira: **o número de linhas é igual ao número de chamadas bem-sucedidas?**

77. Cole o resultado de `SELECT * FROM LIVROS;`. Os preços alterados correspondem exatamente às chamadas bem-sucedidas?

---

## 📋 Parte 3 — Reflexão Final

78. Identifique, no exercício, **três padrões/conceitos** que vieram dos blocos anteriores e que você reconheceu ao implementar:

| Padrão / conceito | Veio do Bloco | Como apareceu no Bloco 8 |
|------------------|---------------|--------------------------|
| _____ | _____ | _____ |
| _____ | _____ | _____ |
| _____ | _____ | _____ |

79. Em uma frase, descreva o que mais te ajudou a resolver o exercício: foi o conhecimento prévio dos conceitos (vindos da aula anterior), foi a prática dos Blocos 1-7, ou foi alguma outra coisa?

80. Imagine que, na próxima aula, sua tarefa seja **adicionar uma Trigger `BEFORE INSERT ON LIVROS`** que valide o `Precolivro` (rejeita valores negativos). Sem implementar, descreva em poucas linhas como você adaptaria o que aprendeu nos Blocos 5 e 6 para essa nova tarefa.

---

## ✅ Gabarito sugestivo (use apenas após tentar!)

### Parte 1

72. O `CREATE TABLE tab_audit` deve ter:
* `codigo INT AUTO_INCREMENT PRIMARY KEY`
* As 6 colunas `usuario`, `estacao`, `dataautitoria`, `codigo_Produto`, `preco_unitario_novo`, `preco_unitario_antigo` com seus tipos.
* O cuidado central: **`codigo_Produto BIGINT`** (não `INT`), para acomodar `ISBN` de 13 dígitos.
* Detalhe ortográfico: preservar `dataautitoria` (com a digitação do roteiro do professor).

73. A Trigger deve ter:
* `DROP TRIGGER IF EXISTS Audita_Livros;` (recomendado, para evitar erro se já existir).
* `CREATE TRIGGER Audita_Livros AFTER UPDATE ON LIVROS FOR EACH ROW BEGIN … END //`.
* Variáveis de sessão `@ISBN`, `@PRECONOVO`, `@PRECOANTIGO` capturando `OLD.ISBN`, `NEW.PRECOLIVRO`, `OLD.PRECOLIVRO`.
* `INSERT INTO TAB_AUDIT (...) VALUES (CURRENT_USER, USER(), CURRENT_DATE, @ISBN, @PRECONOVO, @PRECOANTIGO);`.

74. Estrutura esperada da SP:
* Linha 1: `DECLARE erro_sql boolean DEFAULT FALSE;` — logo após `BEGIN`.
* Linha 2: `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro_sql = TRUE;` — logo abaixo.
* Linha 3 (em branco) — Linha 4: `START TRANSACTION;`.
* Após o `UPDATE`: `IF erro_sql = FALSE THEN COMMIT; SELECT 'sucesso…' AS RESULTADO, ISBN, PRECOLIVRO AS 'PREÇO NOVO' FROM LIVROS WHERE ISBN = v_ISBN; ELSE ROLLBACK; SELECT 'falha…' AS RESULTADO; END IF;`.

---

### Parte 2

75. Exemplo de bateria correta:

| Chamada | Comando | Resultado esperado | Resultado obtido |
|---------|---------|-------------------|------------------|
| #1 | `CALL sp_altera_livros(9786525223742, 49.90);` | sucesso (3 colunas) | ✅ sucesso |
| #2 | `CALL sp_altera_livros(8888888888888, 65.00);` | sucesso (3 colunas) | ✅ sucesso |
| #3 | `CALL sp_altera_livros(9999999999999, NULL);` | falha (`ATENÇÃO…`) | ✅ falha conforme esperado |

76. **2 linhas** em `tab_audit`, correspondendo às chamadas #1 e #2. Linhas com `codigo_Produto = 9786525223742` (com seus preços antigo e novo) e `codigo_Produto = 8888888888888`.

77. Em `LIVROS`:
* `9786525223742` com `Precolivro = 49.90`.
* `9999999999999` inalterado (`34.50`).
* `8888888888888` com `Precolivro = 65.00`.
* `7777777777777` inalterado (`29.90`).

(Os valores podem variar conforme as alterações feitas nos Blocos 6 — o ponto é que **as chamadas bem-sucedidas refletem em `LIVROS`** e **as falhas não**.)

---

### Parte 3

78. Exemplos de padrões reusados:

| Padrão | Veio do Bloco | Como apareceu no Bloco 8 |
|--------|---------------|--------------------------|
| Trio `DECLARE erro_sql / DECLARE CONTINUE HANDLER / START TRANSACTION` | Bloco 3 | Início do `BEGIN` da `sp_altera_livros` |
| Cabeçalho `FOR EACH ROW BEGIN` em Trigger AFTER UPDATE | Bloco 5 | Trigger `Audita_Livros` recriada |
| Mensagem de sucesso enriquecida (3 colunas com `ISBN` e `PREÇO NOVO`) | Bloco 6 | `SELECT … FROM LIVROS WHERE ISBN = v_ISBN` na SP |
| `IF erro_sql = FALSE THEN COMMIT … ELSE ROLLBACK …` | Blocos 3, 4, 6 | Decisão final de `sp_altera_livros` |

79. Resposta livre. Espera-se que o aluno reconheça que **o exercício foi possível porque os blocos anteriores construíram, por repetição, os padrões necessários** — e que mera leitura teórica seria insuficiente.

80. Adaptação esperada:
* Em vez de `AFTER UPDATE ON LIVROS`, criar **`BEFORE INSERT ON LIVROS`**.
* Em vez de capturar `OLD`/`NEW`, validar `NEW.Precolivro`.
* Se `NEW.Precolivro < 0`, sinalizar erro com `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Preço inválido';` (esse `SIGNAL` será capturado pelo `CONTINUE HANDLER` da SP — abortando o `INSERT`).
* O **padrão SP transacional** continua o mesmo do Bloco 3 — mudaria apenas a Trigger, que passa a impor uma regra de negócio antes da gravação.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Construir, do zero, um sistema completo de auditoria de alterações.  
✅ Reconhecer padrões reusáveis e aplicá-los em novos cenários.  
✅ Documentar suas decisões de implementação.  
✅ Antecipar como adaptar o que aprendeu para próximos desafios.  

> 💡 *"Aprender é entender. Praticar é fixar. Aplicar em algo novo, sem rede, é dominar."*

---

## 🎓 Encerramento da Aula ARQ12

Parabéns! Ao chegar até aqui, você conquistou um conjunto de habilidades raro entre estudantes do mesmo nível:

* Pensar em **transação** antes de pensar em SQL.
* Construir SP **resilientes a erro** sem precisar de exemplo.
* Usar **Triggers** para automatizar **rastreabilidade**.
* Gerenciar **usuários e privilégios** com responsabilidade.

Use bem o que aprendeu. Em produção, são esses cuidados que separam um banco confiável de um arquivo bagunçado.

> 💭 *"O profissional que você será amanhã é construído pela escolha de não pular o exercício de hoje."*
