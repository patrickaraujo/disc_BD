# Atividade 3 — Conta, PK Composta e FKs

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 3  
> Origem: conversão da Atividade 3 (questões 21 a 30) em itens de múltipla escolha.

---

## Questão 1

Após executar o comando abaixo na tabela `Conta` (criada conforme o roteiro do Bloco 3):

```sql
SHOW CREATE TABLE Conta;
```

Qual alternativa identifica corretamente as **duas constraints `FOREIGN KEY`** declaradas na tabela?

A) `fk_Cliente_Conta` e `fk_TipoConta_Conta` — os nomes seguem o padrão `fk_<tabelaPai>_<tabelaFilha>`.

B) **`fk_Conta_Cliente` (sobre `Cliente_idCliente`, referenciando `Cliente.idCliente`) e `fk_Conta_TipoConta1` (sobre `TipoConta_idTipoConta`, referenciando `TipoConta.idTipoConta`). Os nomes seguem o padrão `fk_<tabelaFilha>_<tabelaPai>`, convenção típica do MySQL Workbench.** ✅

C) Não há constraints nomeadas — o MySQL gera nomes internos automáticos como `Conta_ibfk_1` e `Conta_ibfk_2` quando não definidas explicitamente.

D) Apenas uma constraint composta: `fk_Conta_Refs`, cobrindo ambas as FKs simultaneamente em uma única declaração.

---

## Questão 2

Considere a consulta abaixo, que filtra apenas registros de FK em `Conta`:

```sql
SELECT
    CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'Financeiro' AND TABLE_NAME = 'Conta'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

Quantas linhas aparecem no resultado, e o que cada uma representa?

A) 4 linhas — uma para cada coluna da PK composta (3) + uma para a chave primária inteira, totalizando os registros de chaves da tabela.

B) **2 linhas — uma para cada FK em `Conta`. Cada linha mostra o nome da constraint, a coluna desta tabela (`Conta`), a tabela referenciada (`Cliente` ou `TipoConta`) e a coluna referenciada (`idCliente` ou `idTipoConta`).** ✅

C) 0 linhas — `KEY_COLUMN_USAGE` não inclui informações sobre FKs, apenas sobre chaves primárias e índices únicos.

D) 8 linhas — `KEY_COLUMN_USAGE` registra cada FK em quatro perspectivas (origem, destino, schema origem, schema destino), gerando 4 linhas por constraint.

---

## Questão 3

Considere a consulta abaixo, que inspeciona os índices da tabela `Conta`:

```sql
SELECT INDEX_NAME, COLUMN_NAME, IS_VISIBLE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'Financeiro' AND TABLE_NAME = 'Conta';
```

Quantos índices distintos aparecem (e quantas linhas no total), considerando a estrutura criada?

A) **3 índices distintos, totalizando 5 linhas: o índice `PRIMARY` (3 linhas — uma por coluna da PK composta), `fk_Conta_Cliente_idx` (1 linha, sobre `Cliente_idCliente`) e `fk_Conta_TipoConta1_idx` (1 linha, sobre `TipoConta_idTipoConta`). Todos com `IS_VISIBLE = 'YES'`.** ✅

B) Apenas 1 índice — o `PRIMARY`. As FKs reusam automaticamente o índice da PK composta, sem necessidade de índices próprios.

C) 2 índices — apenas os dois índices das FKs aparecem; o `PRIMARY` não é registrado em `information_schema.STATISTICS`.

D) 6 índices — o MySQL cria automaticamente um índice por coluna da tabela (`NroConta`, `saldo`, `Cliente_idCliente`, `TipoConta_idTipoConta`) mais os dois nomeados.

---

## Questão 4

Considere o `INSERT` abaixo, executado com `FOREIGN_KEY_CHECKS = 1` (flag religado para o experimento):

```sql
INSERT INTO Conta VALUES (9999, 500, 99, 1);
```

Sabendo que o cliente com `idCliente = 99` **não existe** em `Cliente`, o que acontece?

A) O `INSERT` é aceito normalmente — a constraint só é validada quando o valor é **alterado** (`UPDATE`), não na inserção inicial.

B) **O MySQL retorna erro `1452 — Cannot add or update a child row: a foreign key constraint fails`. A FK `fk_Conta_Cliente` bloqueia a inserção porque a referência (`Cliente_idCliente = 99`) aponta para um cliente inexistente. Esse é o papel da constraint: proteger a integridade referencial.** ✅

C) O `INSERT` é aceito, mas a coluna `Cliente_idCliente` é silenciosamente substituída por `NULL` para preservar a FK.

D) O servidor reinicia a sessão para "limpar" o estado e impede o `INSERT`, exigindo nova autenticação antes da próxima operação.

---

## Questão 5

Considerando que o cliente Rubens (`idCliente = 1`) tem **2 contas** associadas em `Conta`, e com `FOREIGN_KEY_CHECKS = 1`, o que acontece ao executar:

```sql
DELETE FROM Cliente WHERE idCliente = 1;
```

A) A operação é aceita — Rubens é removido, e suas contas tornam-se "órfãs" (mantêm `Cliente_idCliente = 1` apontando para um cliente que não existe mais).

B) **O MySQL retorna erro `1451 — Cannot delete or update a parent row: a foreign key constraint fails`. O `ON DELETE NO ACTION` da FK `fk_Conta_Cliente` impede a exclusão porque ainda há contas em `Conta` que referenciam `idCliente = 1`. Esse é o comportamento defensivo do `NO ACTION`: bloqueia exclusões que quebrariam a integridade referencial.** ✅

C) A operação é aceita silenciosamente — o servidor remove Rubens e cascateia o `DELETE` para suas 2 contas, mesmo com `NO ACTION` (que se comportaria como `CASCADE` em tabelas InnoDB).

D) O `DELETE` entra em "estado pendente" até que as contas órfãs sejam apagadas manualmente; até lá, Rubens fica em estado intermediário (visível em `Cliente` mas marcado como "marked for deletion").

---

## Questão 6

Após o erro `1451` da questão anterior (`DELETE` bloqueado pela FK), qual é o estado das tabelas `Cliente` e `Conta`?

A) `Cliente` tem 1 linha (Rubens removido apesar do erro) e `Conta` mantém 4 linhas — o `DELETE` foi parcial, removendo apenas o cliente.

B) `Cliente` tem 0 linhas e `Conta` tem 0 linhas — a tentativa frustrada acionou um `ROLLBACK` automático que afetou todas as tabelas relacionadas.

C) **`Cliente` continua com 2 linhas e `Conta` com 4 linhas — nenhum registro foi removido. Quando o erro `1451` é disparado pela validação da FK, o servidor **não executa** a operação. O estado das tabelas permanece exatamente como estava antes da tentativa.** ✅

D) `Cliente` continua com 2 linhas, mas `Conta` agora tem apenas 2 linhas (somente as contas de Oswaldo) — o servidor removeu silenciosamente as contas de Rubens **antes** de detectar o erro na exclusão do pai.

---

## Questão 7

Em um cenário onde a tabela `ItemPedido` tem FK para `Pedido` (cada item pertence a um pedido), qual opção de `ON DELETE` é **mais adequada** para a FK?

A) `NO ACTION` — apagar pedidos é sempre arriscado, mesmo com itens; melhor exigir intervenção manual.

B) **`CASCADE` — itens existem **por causa** do pedido. Se o pedido é apagado (cancelado, por exemplo), faz sentido apagar os itens automaticamente; eles perdem seu sentido isolados do pedido associado.** ✅

C) `SET NULL` — itens viram "órfãos" mas continuam existindo, podendo ser reagrupados em outros pedidos posteriormente.

D) `SET DEFAULT` — itens herdam o "pedido 0" (pedido padrão), criando uma área de pendências automatizadas para revisão posterior.

---

## Questão 8

No relacionamento `Cliente ↔ Conta` (em sistema financeiro), qual opção de `ON DELETE` é **mais adequada** para a FK em `Conta` apontando para `Cliente`?

A) `CASCADE` — apagar cliente apaga suas contas automaticamente; é a escolha mais simples e eficiente para limpeza de dados.

B) `SET NULL` — contas viram contas "anônimas" (sem dono), úteis para manter rastros de saldos para auditoria histórica.

C) `SET DEFAULT` — contas migram para um "cliente padrão" (`idCliente = 0`), preservando os saldos sob nova titularidade simbólica.

D) **`NO ACTION` — excluir cliente com saldo é uma operação perigosa que exige decisão manual: o que fazer com o saldo? Transferir para outra conta? Devolver ao cliente? Bloquear a exclusão e exigir intervenção humana é a escolha defensiva correta em sistemas financeiros.** ✅

---

## Questão 9

No relacionamento `Categoria ↔ Produto` (em loja de e-commerce), qual opção de `ON DELETE` é **mais adequada**?

A) **`SET NULL` ou `NO ACTION` — se uma categoria é apagada, o produto pode ficar "sem categoria" (com `SET NULL`, exibido como "Outros" no front-end) ou a exclusão pode ser bloqueada (`NO ACTION`) para forçar reclassificação manual antes da remoção. Ambas as opções são razoáveis dependendo da regra de negócio. `CASCADE` seria perigoso, pois apagaria produtos junto com a categoria.** ✅

B) `CASCADE` sempre — se uma categoria é descontinuada, faz sentido remover todos os produtos dela em uma única operação.

C) `SET DEFAULT` — produtos migram automaticamente para a categoria "Genérico" (`id = 0`), sem perda de dados, mas com reclassificação automática visível ao usuário final.

D) Não usar FK — categorias e produtos devem ser tabelas independentes, com a relação implícita por nome em `VARCHAR` para permitir reclassificações livres.

---

## Questão 10

Em um sistema de catálogo onde livros podem assumir o status **"Autor desconhecido"** caso o autor cadastrado seja removido, qual opção de `ON DELETE` é **mais adequada** na FK de `Livro` apontando para `Autor`?

A) `NO ACTION` — autor não pode ser apagado enquanto tiver livros; o livro deve manter seu autor cadastrado obrigatoriamente.

B) `CASCADE` — apagar autor apaga os livros associados, simplificando a manutenção do catálogo.

C) **`SET NULL` — livro continua existindo mesmo sem autor cadastrado; a coluna `Autor` aceita `NULL` e é exibida como "Autor desconhecido" no front-end. É exatamente o cenário descrito no enunciado.** ✅

D) `SET DEFAULT` — livros migram para o "autor padrão" (`id = 0`, "Anônimo"), preservando integridade referencial mas sem refletir o status real "desconhecido".

---

## Questão 11

No relacionamento `Funcionario ↔ RegistroPonto` (sistema de auditoria de ponto eletrônico), qual opção de `ON DELETE` é **mais adequada** na FK em `RegistroPonto` apontando para `Funcionario`?

A) `CASCADE` — quando um funcionário é desligado, seus registros de ponto antigos podem ser removidos para limpar o banco e liberar espaço.

B) `SET NULL` — registros de ponto viram registros "anônimos" mas permanecem na tabela como histórico genérico.

C) `SET DEFAULT` — registros migram para um "funcionário padrão" representando o histórico genérico desligado.

D) **`NO ACTION` — a auditoria nunca pode ser apagada por exclusão de funcionário. A história do ponto (quem entrou, saiu, atrasou) é imutável e legalmente protegida (CLT, fiscalização trabalhista). Mesmo após desligamento, os registros permanecem como prova; o funcionário deveria ser marcado como "inativo", não removido.** ✅

---

## Questão 12

Por que **a coluna FK precisa de um índice**? Considere especificamente o impacto em `JOIN`s entre `Conta` e `Cliente` pelo `idCliente`, e na validação de cada `INSERT`/`UPDATE`.

A) Porque o MySQL exige sintaticamente um `INDEX` explícito antes de qualquer `CONSTRAINT FOREIGN KEY`; sem o `INDEX`, o servidor recusa a criação da tabela.

B) Porque o índice serve como "pré-validação" do valor da FK no momento do `INSERT`, **pulando** a verificação na tabela pai e tornando o INSERT mais permissivo.

C) **Por questões de **performance**. Sem índice na FK: toda inserção em `Conta` dispararia uma busca linear (`O(n)`) em `Cliente` para validar `Cliente_idCliente`; com índice, a busca é `O(log n)`. Em `JOIN`s entre `Conta` e `Cliente`, sem índice o MySQL faria "loop em todas as combinações"; com índice, percorre só os registros relevantes. Performance pode mudar de **segundos para microssegundos**. (O MySQL cria o índice automaticamente se não declarado, mas a boa prática é nomeá-lo explicitamente para facilitar manutenção.)** ✅

D) Porque o `INDEX` armazena uma **cópia local** dos dados da FK, dispensando consultas à tabela pai durante validações — o que economiza I/O.

---

## Questão 13

Em uma FK com `ON DELETE NO ACTION`, qual é a **alternativa de design** mais correta para conseguir excluir um cliente que tem contas associadas, sem violar a integridade referencial?

A) Mudar `autocommit` para `0` e executar o `DELETE` — operações em transação aberta podem violar a FK temporariamente sem disparar erro.

B) Usar `SET FOREIGN_KEY_CHECKS = 0` antes do `DELETE` — desativa a validação e permite a exclusão direta. É a abordagem padrão em produção quando há urgência.

C) Usar `DELETE FROM Cliente ... LIMIT 1` — a cláusula `LIMIT` faz o servidor pular a validação de FK em algumas versões do MySQL para operações de linha única.

D) **Antes de excluir o cliente, **excluir as contas dele primeiro**: `DELETE FROM Conta WHERE Cliente_idCliente = 1;` — isso libera as referências, e a exclusão do cliente passa a ser permitida. Outra alternativa seria mudar a FK para `ON DELETE CASCADE` — mas isso é arriscado em sistemas financeiros (apagaria saldos sem confirmação humana).** ✅

---

## Questão 14

A coluna `Conta.NroConta` foi declarada **sem** `AUTO_INCREMENT`. No modelo atual, quem é responsável por garantir que dois clientes diferentes **não** tenham contas com o mesmo `NroConta`?

A) O MySQL, automaticamente — a PK composta `(NroConta, Cliente_idCliente, TipoConta_idTipoConta)` impõe unicidade global de `NroConta` como efeito colateral da composição.

B) A FK `fk_Conta_Cliente` — ela valida tanto a existência do cliente quanto a unicidade de `NroConta` entre clientes diferentes durante cada `INSERT`.

C) **Ninguém garante automaticamente. A PK composta `(NroConta, Cliente_idCliente, TipoConta_idTipoConta)` permite que dois clientes diferentes tenham contas com mesmo `NroConta` (basta variarem em `Cliente_idCliente`). No mundo bancário real, isso seria um problema sério. Para impor unicidade global de `NroConta`, seria necessário adicionar uma constraint extra: `UNIQUE (NroConta)` — mas isso conflita com o desenho atual da PK composta. **Lição:** a escolha entre PK simples e PK composta tem implicações profundas; vale repensar o modelo para sistemas reais.** ✅

D) A aplicação cliente (front-end), exclusivamente — bancos de dados não devem se preocupar com unicidade de números de conta; isso é regra de negócio que pertence à camada de aplicação.
