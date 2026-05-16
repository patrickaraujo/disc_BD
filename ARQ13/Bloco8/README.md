# 📘 Bloco 8 — Exercício Integrador: `sp_saque` e `sp_deposito`

> **Duração estimada:** 75 minutos  
> **Objetivo:** Resolver, **de forma autônoma**, um exercício que aplica tudo o que você aprendeu nos sete blocos anteriores: SP transacional, validação robusta, integração com Trigger de auditoria.  
> **Modalidade:** **Exercício avaliativo** — você implementa **sem código guia**, apenas com requisitos, especificação e critérios de validação.

---

## 🚦 Antes de começar

Este é o **bloco de fechamento da aula**. Aqui não há esqueleto pronto, exemplos reescritos ou comandos exibidos. O que existe é uma **especificação de requisitos** — e cabe a você traduzi-la em SQL.

> 💡 **Use os Blocos 1-7 como sua biblioteca pessoal.** Releia os guias quando precisar de um padrão, mas **não copie-cole o código-fonte**. O objetivo é você **construir** — não transcrever.

> 🚨 **Não consulte o `codigo-fonte/COMANDOS-BD-03-bloco8.sql` antes de fazer sua tentativa completa.** É um gabarito de referência, não um ponto de partida.

---

## 🎯 Cenário

Até agora, sua livraria-banco implementou apenas a operação de **transferência** (entre duas contas). Mas operações bancárias unitárias — **saque** (debita uma conta) e **depósito** (credita uma conta) — também são fundamentais.

Sua tarefa: criar **duas SPs unitárias**, cada uma operando sobre **uma única conta**, mantendo as garantias que você aprendeu:

* Validação robusta (existência da conta, valor positivo).
* Tratamento transacional (caso `UPDATE` falhe por motivo inesperado).
* Integração automática com a Trigger `tg_Audita_Fin` já criada no Bloco 7.

> 💡 **Diferença crítica em relação à transferência:** cada chamada de saque ou depósito gera **uma única linha** em `AuditFin` (porque há **um único `UPDATE`**), não duas. Isso significa que `valor_transacao` em saques é sempre **negativo** e em depósitos sempre **positivo**.

---

## 📋 Especificação Funcional

### Requisito 1 — `sp_saque`

* **Nome:** `sp_saque`.
* **Parâmetros:**
  * `v_conta` do tipo `INT`.
  * `v_valor` do tipo `FLOAT`.
* **Validações (em ordem):**
  1. A conta existe (use o padrão `@conta = (SELECT NroConta FROM Conta WHERE NroConta = v_conta)`).
  2. O valor é positivo (`v_valor > 0`).
  3. O saldo atual da conta é suficiente (`saldo_atual >= v_valor`).
* **Operação:** `UPDATE Conta SET saldo = saldo - v_valor WHERE NroConta = v_conta;` dentro de transação.
* **Mensagens:**
  * Sucesso: `'Saque efetuado com sucesso:'` + `'NOVO SALDO'` (1 coluna com novo saldo).
  * Falha de validação combinada: `'ATENÇÃO: Parâmetros inadequados, saque cancelado!!!'`.
  * Falha de saldo: `'ATENÇÃO: Saldo Insuficiente, saque cancelado!!!'`.
  * Falha transacional (`SQLEXCEPTION`): `'ATENÇÃO: Erro na transação, saque não efetuado!!!'`.

### Requisito 2 — `sp_deposito`

* **Nome:** `sp_deposito`.
* **Parâmetros:**
  * `v_conta` do tipo `INT`.
  * `v_valor` do tipo `FLOAT`.
* **Validações (em ordem):**
  1. A conta existe.
  2. O valor é positivo.
  3. **Sem validação de saldo** (depósito não exige saldo prévio).
* **Operação:** `UPDATE Conta SET saldo = saldo + v_valor WHERE NroConta = v_conta;` dentro de transação.
* **Mensagens:**
  * Sucesso: `'Depósito efetuado com sucesso:'` + `'NOVO SALDO'`.
  * Falha de validação: `'ATENÇÃO: Parâmetros inadequados, depósito cancelado!!!'`.
  * Falha transacional: `'ATENÇÃO: Erro na transação, depósito não efetuado!!!'`.

---

## 📐 Estrutura recomendada

Cada SP segue o **mesmo esqueleto** que você dominou na ARQ12 e nas SPs deste módulo:

```text
DELIMITER //
CREATE PROCEDURE sp_X (parâmetros)
BEGIN
    -- (1) DECLARE erro_sql + handler
    -- (2) Capturar variáveis necessárias com SELECT (existência + valor)
    -- (3) IF de validação combinada (existência + v_valor > 0)
    --     [- Em sp_saque: IF aninhado para validação de saldo]
    --     - START TRANSACTION
    --     - UPDATE
    --     - IF erro_sql = FALSE THEN COMMIT + mensagem sucesso
    --                          ELSE ROLLBACK + mensagem falha transacional
    --     - END IF
    --     [ELSE da validação de saldo: 'Saldo Insuficiente'] (só sp_saque)
    -- ELSE: 'Parâmetros inadequados'
    -- END IF
END //
DELIMITER ;
```

> 💡 **`sp_saque` é estruturalmente idêntica à v2 da transferência** (`sp_transf_bancaria02`), apenas removendo a validação de destino e simplificando para um único `UPDATE`. **`sp_deposito` é ainda mais simples** (sem o IF de saldo).

---

## 🧪 Bateria de Testes Obrigatória

Antes dos testes, restaure o estado dos saldos:

```sql
TRUNCATE Conta;
INSERT INTO Conta VALUES (1111, 10000, 1, 1), (2222, 0, 1, 2);
INSERT INTO Conta VALUES (5555, 10000, 2, 1), (6666, 1000, 2, 2);
COMMIT;
TRUNCATE AUDITFIN;
```

### Testes para `sp_saque`

```sql
CALL sp_saque(1111, 3000);    -- ✅ sucesso
CALL sp_saque(1111, 100000);  -- ❌ saldo insuficiente
CALL sp_saque(9999, 100);     -- ❌ conta inexistente
CALL sp_saque(1111, -500);    -- ❌ valor negativo
CALL sp_saque(1111, 0);       -- ❌ valor zero
```

### Testes para `sp_deposito`

```sql
CALL sp_deposito(2222, 5000); -- ✅ sucesso (saldo 0 → 5000)
CALL sp_deposito(9999, 100);  -- ❌ conta inexistente
CALL sp_deposito(2222, -200); -- ❌ valor negativo
CALL sp_deposito(2222, 0);    -- ❌ valor zero
```

### Verificações

```sql
SELECT * FROM Conta;
SELECT * FROM AuditFin ORDER BY idAuditoria;
SELECT SUM(valor_transacao) FROM AuditFin;
```

---

## ✅ Critérios de Avaliação

Sua resolução é correta se, e somente se:

| Critério | Como validar |
|----------|--------------|
| ✓ Ambas as SPs existem | `SHOW PROCEDURE STATUS WHERE Db='Financeiro';` lista as duas |
| ✓ `sp_saque` rejeita conta inexistente, valor inválido e saldo insuficiente | Cada teste retorna mensagem específica |
| ✓ `sp_deposito` rejeita conta inexistente e valor inválido | Idem |
| ✓ Cada chamada bem-sucedida gera **1 linha** em `AuditFin` | Diferente da transferência (que gerava 2) |
| ✓ Saques têm `valor_transacao` **negativo** | Conferir no `SELECT * FROM AuditFin` |
| ✓ Depósitos têm `valor_transacao` **positivo** | Idem |
| ✓ A soma `SUM(valor_transacao)` **NÃO** é zero (diferente da transferência) | Saques e depósitos alteram a soma total do banco |
| ✓ Cada falha retorna mensagem específica conforme spec | Conferir cada uma das mensagens |
| ✓ A Trigger `tg_Audita_Fin` é disparada automaticamente | Sem necessidade de modificar a Trigger |

> 💡 **Por que `SUM(valor_transacao) ≠ 0` aqui?** Porque saques e depósitos são operações **assimétricas** — dinheiro entra ou sai do sistema. Em uma transferência, dinheiro **circula internamente** (soma zero). Em um depósito, dinheiro **vem de fora**. Em um saque, dinheiro **sai do sistema**.

---

## ✏️ Atividade Prática

### 📝 Atividade 8 — Resolução Documentada

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Documentar sua resolução: estrutura do código, chamadas, resultados, verificações.
- Refletir sobre **por que** a soma de `valor_transacao` não é mais zero.
- Conectar tudo o que aprendeu na ARQ13 ao exercício.

---

## 📂 Código-fonte (gabarito)

> 🚨 **Use somente após sua tentativa completa.**

➡️ [codigo-fonte/COMANDOS-BD-03-bloco8.sql](./codigo-fonte/COMANDOS-BD-03-bloco8.sql)

---

## 🎯 Conclusão da Aula ARQ13

Você implementou, ao longo de 8 blocos:

1. ✅ Modelagem ER e Forward Engineering com 3 SETs.
2. ✅ Schema `Financeiro` + tabelas-catálogo (`Cliente`, `TipoConta`).
3. ✅ Tabela central `Conta` com PK composta e 2 FKs `NO ACTION`.
4. ✅ SP `sp_transf_bancaria` (v1) com IF aninhado de 3 níveis.
5. ✅ Análise crítica das falhas da v1 (3 cenários, incluindo "dinheiro some").
6. ✅ SP `sp_transf_bancaria02` (v2) com validação robusta.
7. ✅ Tabela `AuditFin` + Trigger `tg_Audita_Fin` com cálculo `NEW − OLD`.
8. ✅ Exercício integrador autoral (saque + depósito).

> 💭 *"A primeira versão funciona. A segunda versão não falha. A versão final é a que **você consegue construir sozinho**, sem cola."*

---

## 📚 Continuidade

A próxima aula avançará para tópicos como **stored functions** (parente próximo de SP, mas que retornam um valor único), **eventos agendados** (`CREATE EVENT`) e **stored programs com cursores**. Tudo construído sobre o tripé que você consolidou nas ARQ12 e ARQ13:

* **Transação** (atomicidade).
* **Auditoria** (rastreabilidade).
* **Validação** (robustez).

Bom trabalho! 🎓

---

> 💭 *"Em finanças, o sistema mais elegante é aquele em que **tudo o que entra, sai, ou se move** deixa rastro — e onde **nada se cria nem se destrói**, salvo onde explicitamente registrado."*
