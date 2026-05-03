# Atividade 7 — Auditoria Financeira

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 7  
> Origem: conversão da Atividade 7 (questões 69 a 80) em itens de múltipla escolha.

> **Bateria do Bloco 7 (referência para várias questões):**  
> Após criar `AuditFin` e `tg_Audita_Fin` com saldos restaurados (`1111 = 10000`, `2222 = 0`, `5555 = 10000`, `6666 = 1000`), executam-se 4 chamadas:  
> #1: `sp_transf_bancaria02(1111, 2222, 5000)` — sucesso  ·  #2: `sp_transf_bancaria02(5555, 6666, 1600)` — sucesso  
> #3: `sp_transf_bancaria02(1111, NULL, 2000)` — falha (parâmetros inadequados)  ·  #4: `sp_transf_bancaria02(1111, 2222, 450.55)` — sucesso

---

## Questão 1

Após criar a tabela `AuditFin`, executa-se:

```sql
SHOW CREATE TABLE AuditFin;
```

Quais são os tipos das colunas centrais para auditoria financeira?

A) `dataautitoria` é `DATETIME` (data + hora); `saldo_antigo`, `valor_transacao` e `saldo_novo` são `FLOAT` para flexibilidade aritmética.

B) `dataautitoria` é `TIMESTAMP` (com fuso horário); `saldo_antigo`, `valor_transacao` e `saldo_novo` são `DOUBLE` por questões de precisão estendida.

C) `dataautitoria` é `DATE` (apenas data, sem hora); `saldo_antigo`, `valor_transacao` e `saldo_novo` são todos `DECIMAL(9,2)` — tipo de ponto fixo, ideal para valores monetários (precisão exata sem arredondamento binário).

D) `dataautitoria` é `VARCHAR(10)` no formato `DD/MM/AAAA`; os campos de saldo são `INT` representando centavos para evitar ponto flutuante.

---

## Questão 2

Após criar a Trigger `tg_Audita_Fin`, executa-se:

```sql
SHOW TRIGGERS LIKE 'Conta';
```

Em qual evento e timing a Trigger está vinculada?

A) `Event = INSERT`, `Timing = BEFORE` — registra a auditoria antes da inserção da nova conta para garantir trilha completa.

B) `Event = UPDATE`, `Timing = AFTER` — a Trigger dispara depois que o `UPDATE` em `CONTA` foi efetivado, garantindo que apenas alterações realmente confirmadas gerem registro de auditoria.

C) `Event = UPDATE`, `Timing = BEFORE` — a Trigger registra a tentativa antes da modificação, permitindo cancelamento se necessário.

D) `Event = INSERT, UPDATE, DELETE`, `Timing = AFTER` — a Trigger é genérica e cobre todos os eventos transacionais sobre a tabela.

---

## Questão 3

Após executar as 4 chamadas obrigatórias do roteiro, executa-se:

```sql
SELECT * FROM AuditFin ORDER BY idAuditoria;
```

Quantas linhas aparecem e por quê?

A) 4 linhas — uma por chamada à SP, independente de sucesso ou falha (a Trigger registra a tentativa de cada operação).

B) 6 linhas. Justificativa: cada chamada bem-sucedida da `sp_transf_bancaria02` executa 2 UPDATEs (debitar origem + creditar destino), e a Trigger `AFTER UPDATE FOR EACH ROW` dispara uma vez por linha afetada. Logo: chamada #1 → 2 linhas; chamada #2 → 2 linhas; chamada #3 → 0 linhas (falhou na validação, nenhum UPDATE foi executado); chamada #4 → 2 linhas. Total: 2 + 2 + 0 + 2 = 6 linhas.

C) 8 linhas — 2 por chamada (todas as 4), pois a chamada #3 também gera registros de auditoria do tipo "tentativa cancelada".

D) 12 linhas — cada UPDATE gera 3 entradas (uma para `OLD`, uma para `NEW`, uma para `valor_transacao`), totalizando 6 UPDATEs × 2 = 12 linhas.

---

## Questão 4

Considere as 6 linhas de `AuditFin` após a bateria, agrupadas por par (linhas 1-2, 3-4, 5-6 — cada par corresponde a uma chamada bem-sucedida da SP). A soma dos valores de `valor_transacao` em **cada par** é zero?

A) Não. A soma de cada par é o **valor da transferência** (R\$ 5.000, R\$ 1.600 e R\$ 450,55 respectivamente) — a Trigger registra `OLD.SALDO + NEW.SALDO` em ambas as linhas.

B) Sim, cada par soma exatamente zero. Para a chamada #1: linha 1 (conta `1111`) tem `valor_transacao = -5000{,}00` (saída) e linha 2 (conta `2222`) tem `valor_transacao = +5000{,}00` (entrada) → soma = 0. Mesma estrutura para os outros pares (`±1600{,}00` e `±450{,}55`). Princípio físico-contábil: uma transferência conserva o dinheiro — o que sai de um lado entra no outro com sinal oposto. A Trigger calcula `NEW.SALDO - OLD.SALDO`, que é negativo no débito e positivo no crédito — daí a simetria.

C) Apenas o primeiro par soma zero; os demais somam o valor da transferência por questão de arredondamento em `DECIMAL(9,2)`.

D) Os pares somam zero apenas em transferências internas; transferências entre clientes diferentes (como entre Rubens e Oswaldo) gravam valores positivos em ambas as linhas.

---

## Questão 5

Após a bateria, executa-se:

```sql
SELECT SUM(valor_transacao) FROM AuditFin;
```

O resultado é zero, e o que isso prova sobre a integridade do sistema?

A) Não — a soma é o total movimentado no banco (R\$ 7.050,55), evidência da liquidez do sistema.

B) Sim, é zero — mas isso é apenas coincidência aritmética; não prova nada além de que valores positivos e negativos estão balanceados localmente.

C) Sim, é exatamente zero. Como cada par soma zero e há 3 pares (`5000 + 1600 + 450{,}55` em débitos e `5000 + 1600 + 450{,}55` em créditos), a soma global também é zero. Isso prova que toda transferência registrada foi simétrica — o dinheiro sempre saiu de algum lugar e chegou a outro. Nenhuma "fuga" no sistema — princípio de conservação do dinheiro preservado matematicamente. Em sistema bancário real, esse invariante é a primeira verificação de saúde da contabilidade.

D) Sim — mas isso prova apenas que a coluna `valor_transacao` é declarada como `DECIMAL`, não há informação contábil real envolvida.

---

## Questão 6

Considere a linha 5 de `AuditFin` (`idAuditoria = 5`), correspondente à conta `1111` na chamada #4. O valor de `saldo_antigo` registrado é `5000{,}00`, **não** `10000{,}00` (saldo inicial original). Qual é a explicação correta?

A) A Trigger registra sempre o saldo médio do dia, calculado como média entre o saldo de abertura e o saldo do momento.

B) A Trigger tem um bug que arredonda o saldo antigo para baixo nas auditorias subsequentes a uma falha (a chamada #3 falhou).

C) Porque a chamada #1 (que aconteceu antes da #4) já havia debitado R\$ 5.000 da conta `1111`. Quando a #4 começou, o saldo vigente de `1111` era `10000 - 5000 = 5000`. A Trigger registra o `OLD.SALDO` no exato momento em que o UPDATE ocorre — não o saldo histórico inicial. A trilha de auditoria reflete o estado real da conta a cada operação, encadeando-se ao longo do tempo.

D) Porque a chamada #3, que falhou, ainda assim debitou R\$ 5.000 da conta `1111` antes de ser revertida — efeito colateral do `CONTINUE HANDLER` da v2.

---

## Questão 7

Considere as duas expressões abaixo, executadas no MySQL:

```sql
SELECT 0.1 + 0.2 AS soma_float;
SELECT CAST(0.1 AS DECIMAL(5,2)) + CAST(0.2 AS DECIMAL(5,2)) AS soma_decimal;
```

Os resultados são iguais a `0{,}3`? Qual é a importância dessa diferença em sistema financeiro?

A) Ambos retornam exatamente `0{,}3` — o MySQL 8 implementa aritmética exata para constantes literais em qualquer tipo numérico.

B) Não. `0.1 + 0.2` em ponto flutuante (FLOAT/DOUBLE) retorna `0{,}30000000000000004` (ou valor similar — depende da plataforma) devido à representação binária IEEE 754, que não consegue expressar `0{,}1` e `0{,}2` exatamente. Em DECIMAL (ponto fixo) retorna exatamente `0{,}30`. Em finanças, mesmo um centavo de erro não é aceitável — clientes, contadores e fiscalização exigem cálculo exato. Erros se acumulam em milhares de operações; uma diferença de R\$ 0,000001 por transação vira reais ao final do mês. `DECIMAL` é o tipo obrigatório em colunas monetárias.

C) `FLOAT` retorna `0{,}30` e `DECIMAL` retorna `0{,}300000` — a diferença é apenas de exibição, não de armazenamento.

D) Ambos retornam o mesmo valor, mas `DECIMAL` é mais lento. Em sistemas financeiros, prefere-se `FLOAT` justamente pela performance — a precisão é compensada por arredondamento manual no aplicativo.

---

## Questão 8

Suponha que a coluna `saldo` da tabela `Conta` fosse alterada de `FLOAT` para `DECIMAL(10,2)`. A Trigger `tg_Audita_Fin` continuaria funcionando, ou seria preciso recriá-la?

A) Seria necessário recriar a Trigger — o MySQL bloqueia automaticamente Triggers que referenciam colunas com tipo alterado, exigindo `DROP TRIGGER` + `CREATE TRIGGER` novo.

B) A Trigger continuaria funcionando sem necessidade de recriação. O MySQL faz conversão implícita entre `FLOAT` e `DECIMAL` em operações aritméticas (como `NEW.SALDO - OLD.SALDO`). Pelo contrário, a precisão da auditoria poderia até melhorar se a fonte (`Conta.saldo`) fosse `DECIMAL` em vez de `FLOAT`, eliminando o erro de arredondamento na origem dos dados antes de chegar à coluna `valor_transacao DECIMAL(9,2)`.

C) A Trigger continuaria funcionando, mas com perda de precisão — `FLOAT` para `DECIMAL` envolve truncamento que pode acumular erros em transações de alto valor.

D) A Trigger seria automaticamente desativada pelo MySQL como medida de segurança, exigindo reativação manual com `ALTER TRIGGER ... ENABLE`.

---

## Questão 9

Imagine que a Trigger fosse **`BEFORE UPDATE`** em vez de `AFTER UPDATE`. Qual seria o efeito **prático**, considerando especificamente o caso de uma falha durante o `UPDATE` (ex.: SQL exception capturada pelo `CONTINUE HANDLER` da SP)?

A) Não haveria diferença prática — `BEFORE` e `AFTER` são equivalentes em Triggers de auditoria; a escolha é puramente estilística.

B) Com `BEFORE UPDATE`, a Trigger nem teria acesso a `NEW.SALDO`, pois o valor proposto só estaria disponível após o UPDATE. A auditoria ficaria incompleta, registrando apenas `OLD.SALDO`.

C) Com `BEFORE UPDATE`, a Trigger executaria antes do UPDATE modificar a linha. `OLD.SALDO` ainda seria o saldo atual, mas `NEW.SALDO` seria o valor proposto — não confirmado. Se o UPDATE falhasse depois (violação de constraint, deadlock, falha de I/O), o registro de auditoria já teria sido inserido — registrando uma alteração que não aconteceu. Dentro da SP, o `ROLLBACK` desfaria o INSERT em `AuditFin` (atomicidade da transação), mas em código fora de transação, o registro ficaria órfão. `AFTER UPDATE` é a escolha correta para garantir que só o que efetivamente aconteceu seja registrado.

D) Com `BEFORE UPDATE`, a Trigger entraria em loop infinito ao tentar acessar `NEW.SALDO`, pois a referência cíclica entre Trigger e UPDATE não permitiria a leitura do valor proposto.

---

## Questão 10

Suponha que a Trigger **não calculasse** `valor_transacao = NEW.SALDO - OLD.SALDO`, mas registrasse apenas `OLD.SALDO` em `saldo_antigo` e `NEW.SALDO` em `saldo_novo`. Qual expressão é necessária em uma consulta posterior para reconstruir `valor_transacao`?

A) `(saldo_antigo - saldo_novo)` — a convenção contábil do MySQL exige que o saldo antigo venha primeiro na subtração.

B) `ABS(saldo_novo - saldo_antigo)` — o valor absoluto preserva a magnitude, e o sinal pode ser inferido pelo contexto.

C) `(saldo_novo - saldo_antigo) AS valor_transacao` — o cálculo é o mesmo que a Trigger faria internamente, mas executado sob demanda. Em SQL: `SELECT idAuditoria, conta, (saldo_novo - saldo_antigo) AS valor_transacao FROM AuditFin;`. Saldo aumentou (entrada) → valor positivo; saldo diminuiu (saída) → valor negativo, mantendo a simetria do princípio de conservação.

D) `(saldo_novo + saldo_antigo) / 2` — média móvel é o cálculo padrão para reconstruir o valor de transação a partir de saldos.

---

## Questão 11

Quais são as **vantagens práticas** de calcular `valor_transacao` **na Trigger** (e armazenar como coluna persistida) em vez de calcular sob demanda em consultas?

A) Nenhuma vantagem prática — calcular na Trigger é apenas redundância; a consulta sob demanda é igualmente eficiente em qualquer cenário.

B) Quatro vantagens: (1) Performance — o cálculo já está feito; relatórios e dashboards são mais rápidos. (2) Indexabilidade — pode-se criar índice em `valor_transacao` (`CREATE INDEX idx_valor ON AuditFin(valor_transacao)`), mas índice em expressão calculada exige `GENERATED COLUMN` ou suporte a "functional indexes". (3) Filtros legíveis e rápidos — `WHERE valor_transacao < 0` (saídas) é mais claro e mais rápido que `WHERE saldo_novo < saldo_antigo`. (4) Imutabilidade do passado — o valor registrado no momento da operação não muda mesmo se o cálculo lógico mudar no futuro (proteção contra "reescrita histórica").

C) Apenas uma vantagem: economiza espaço em disco, pois `DECIMAL(9,2)` ocupa menos espaço que duas colunas de saldo.

D) A vantagem é puramente estética — relatórios ficam mais "organizados" com a coluna pré-calculada, sem benefício técnico real.

---

## Questão 12

Suponha que a Trigger fosse `INSERT, UPDATE, DELETE` em vez de só `UPDATE`. Quais cenários adicionais ela cobriria, e quais novos riscos surgiriam?

A) Cobriria todos os cenários sem novos riscos — Triggers compostas são equivalentes a Triggers simples, com apenas uma restrição de performance.

B) Cobriria os mesmos cenários da Trigger atual — `INSERT` e `DELETE` em `Conta` são bloqueados pelo MySQL quando há FKs ativas, então a Trigger composta seria redundante.

C) Cenários adicionais cobertos: (a) `INSERT` em `Conta` registraria a criação de novas contas (saldo inicial); (b) `DELETE` em `Conta` registraria a remoção. Novos riscos: (1) Em `INSERT`, `OLD.SALDO` não existe — referenciá-lo gera erro; é preciso tratamento especial (`IF OLD.NROCONTA IS NULL` ou separação por `INSERTING`/`UPDATING`/`DELETING` em outros SGBDs; no MySQL, exige Triggers separadas). (2) Em `DELETE`, `NEW.SALDO` não existe — mesma observação. (3) A Trigger ficaria mais complexa, com mais ramificações condicionais. Em geral, é melhor ter 3 Triggers separadas (uma para cada evento), cada uma especializada em seu contexto — mais legível e mais fácil de manter.

D) Cobriria os cenários, mas o MySQL não suporta Triggers múltiplas em uma única declaração (`INSERT, UPDATE, DELETE`) — exigiria criar 3 Triggers separadas, mas com nomes obrigatoriamente prefixados por `tg_multi_`.
