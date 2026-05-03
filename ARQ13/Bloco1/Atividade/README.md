# Atividade 1 — Diagrama e Forward Engineering

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ13 — Bloco 1  
> Origem: conversão da Atividade 1 (questões 1 a 10) em itens de múltipla escolha.

---

## Questão 1

Após executar os 3 `SET`s do Forward Engineering no início do roteiro, executa-se:

```sql
SELECT @@UNIQUE_CHECKS, @@FOREIGN_KEY_CHECKS, @@SQL_MODE;
```

Quais valores são retornados?

A) Os três valores retornam `1`, indicando que a sessão está em "modo permissivo" para acelerar a execução do script.

B) `@@UNIQUE_CHECKS = 0`, `@@FOREIGN_KEY_CHECKS = 0` e `@@SQL_MODE` contém múltiplas flags estritas, incluindo (entre outras): `ONLY_FULL_GROUP_BY`, `STRICT_TRANS_TABLES`, `NO_ZERO_IN_DATE`, `NO_ZERO_DATE`, `ERROR_FOR_DIVISION_BY_ZERO` e `NO_ENGINE_SUBSTITUTION`.

C) `@@UNIQUE_CHECKS` e `@@FOREIGN_KEY_CHECKS` retornam `NULL` porque foram redefinidas; apenas `@@SQL_MODE` exibe valor visível.

D) Os três retornam erro de "variável não definida", pois variáveis com `@@` exigem inicialização explícita por sessão antes da leitura.

---

## Questão 2

Após executar os 3 `SET`s, executa-se:

```sql
SELECT @OLD_UNIQUE_CHECKS, @OLD_FOREIGN_KEY_CHECKS;
```

Quais valores são retornados e por que essas variáveis são importantes (mesmo que não sejam restauradas ao final desta aula)?

A) Ambos retornam `0` — os mesmos valores definidos pelos `SET`s, apenas espelhados em outras variáveis para fins decorativos.

B) Em uma instalação padrão do MySQL 8, antes do roteiro `@@UNIQUE_CHECKS` e `@@FOREIGN_KEY_CHECKS` valem `1`, então `@OLD_UNIQUE_CHECKS = 1` e `@OLD_FOREIGN_KEY_CHECKS = 1`. São importantes porque permitem restaurar a sessão ao estado original ao final do script, com `SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;` (e análogos) — devolvendo o ambiente do usuário sem efeitos colaterais persistentes.

C) Ambos retornam `NULL`, pois o MySQL não preserva valores anteriores de variáveis de sistema entre comandos sucessivos.

D) Retornam o nome do schema corrente (`'Financeiro'`), pois `@OLD_*` armazena contexto de schema da última conexão, não valores de flags.

---

## Questão 3

Analise o diagrama ER do schema `Financeiro` (com as entidades `Cliente`, `TipoConta` e `Conta`). Qual alternativa descreve corretamente sua estrutura?

A) 4 tabelas, 4 chaves primárias simples, nenhuma chave primária composta, 3 chaves estrangeiras, e o atributo `FLOAT` está na tabela `Cliente`.

B) 3 tabelas (`Cliente`, `TipoConta`, `Conta`); 2 chaves primárias simples (`Cliente.idCliente` e `TipoConta.idTipoConta`); 1 chave primária composta (em `Conta`, formada por `NroConta`, `Cliente_idCliente` e `TipoConta_idTipoConta`); 2 chaves estrangeiras (ambas em `Conta`, uma para `Cliente` e outra para `TipoConta`); e o único atributo `FLOAT` (`saldo`) está em `Conta`.

C) 3 tabelas, 3 chaves primárias simples (uma em cada tabela), nenhuma chave primária composta, 4 chaves estrangeiras, e o `FLOAT` está em `TipoConta`.

D) 2 tabelas e 1 view materializada, 2 chaves primárias compostas, 1 chave estrangeira, e o `FLOAT` está em `Cliente.salario`.

---

## Questão 4

As cardinalidades das duas relações no diagrama são `1:N`. Qual alternativa descreve corretamente essas relações em forma de frase?

A) Cada cliente tem exatamente uma conta, e cada conta pode ter vários clientes; cada tipo de conta possui uma conta única, e cada conta possui um único tipo. (Cardinalidade `N:1` invertida.)

B) Cada cliente e cada tipo de conta são, simultaneamente, donos das mesmas contas (cardinalidade `N:M`); por isso, as duas relações no diagrama são bidirecionais.

C) Cliente ↔ Conta: "Cada cliente pode ter várias contas, e cada conta pertence a um único cliente". TipoConta ↔ Conta: "Cada tipo de conta pode ser usado por várias contas, e cada conta tem um único tipo de conta".

D) Cada conta tem várias contas-pai e várias contas-filhas, formando uma estrutura recursiva sobre a própria tabela `Conta`.

---

## Questão 5

Por que `idCliente` (em `Cliente`) e `idTipoConta` (em `TipoConta`) são declarados como `AUTO_INCREMENT`, mas `NroConta` (em `Conta`) **não** é?

A) Porque `NroConta` faz parte de uma PK composta, e `AUTO_INCREMENT` não pode ser aplicado a colunas que participam de chaves primárias compostas no MySQL.

B) Por inconsistência do roteiro original — todas as três colunas deveriam ser `AUTO_INCREMENT` para garantir unicidade automática em qualquer cenário.

C) Porque `NroConta` é a única coluna de tipo `INT NOT NULL` na tabela; as outras duas são `INT NULL` e, por isso, não podem ser `AUTO_INCREMENT` no MySQL 8.

D) Porque `idCliente` e `idTipoConta` são chaves substitutas ("surrogate keys") — o sistema gera o identificador único, e o valor concreto não tem significado de negócio (o cliente "1" não é especial, é só "o primeiro registrado"). Já `NroConta` é um valor de negócio — o número real da conta no banco, atribuído por regras externas. Não pode ser apenas "o próximo da sequência".

---

## Questão 6

Em uma sessão com `FOREIGN_KEY_CHECKS = 0`, considere as duas situações:

**(a)** Criar a tabela `Conta` com FK para `Cliente`, **antes** de `Cliente` existir.  
**(b)** Inserir uma linha em `Conta` apontando para um `idCliente` que **não existe** em `Cliente`.

Qual alternativa descreve corretamente os dois casos?

A) **(a)** Sim, é possível; **(b)** Não — o `INSERT` é sempre validado contra a FK, mesmo com o flag em `0`.

B) **(a)** Não, o flag não afeta `CREATE TABLE`; **(b)** Sim, o flag afeta apenas `INSERT/UPDATE/DELETE`.

C) **(a)** Sim — com `FOREIGN_KEY_CHECKS = 0`, o MySQL aceita criar `Conta` mesmo que `Cliente` ainda não exista. Sem o flag, o servidor recusa porque a referência aponta para uma tabela inexistente. **(b)** Sim — com o flag em `0`, o `INSERT` é aceito, mas isso deixa o banco em estado inconsistente (filhos órfãos). Quando o flag voltar a `1`, novas operações continuam funcionando, mas a integridade já foi quebrada e as linhas inválidas permanecem.

D) **(a)** Não, é proibido em qualquer configuração; **(b)** Não, é proibido em qualquer configuração — `FOREIGN_KEY_CHECKS` é apenas decorativo no MySQL 8.

---

## Questão 7

Imagine que, durante o desenvolvimento, você esqueceu de religar `FOREIGN_KEY_CHECKS = 1` ao final do script. Quais são **dois riscos práticos** dessa configuração permanecer em `0`?

A) **(1)** O servidor reinicia automaticamente após 24 horas para forçar a religagem; **(2)** o schema é exportado silenciosamente para um arquivo CSV externo.

B) **(1)** Dados inconsistentes podem ser inseridos sem que o MySQL reclame, levando a "filhos órfãos" (registros que apontam para pais inexistentes). **(2)** Operações `DELETE`/`UPDATE` que normalmente seriam bloqueadas por `RESTRICT`/`NO ACTION` passam a ser executadas, possivelmente quebrando relacionamentos críticos sem aviso ao usuário.

C) **(1)** Performance de consultas cai em torno de 90% por sobrecarga interna do otimizador; **(2)** o `AUTO_INCREMENT` deixa de funcionar em todas as tabelas do schema.

D) **(1)** O charset do banco muda silenciosamente para `latin1`; **(2)** `SHOW TRIGGERS` para de retornar resultados até que o flag seja religado.

---

## Questão 8

A flag `STRICT_TRANS_TABLES` faz parte do `SQL_MODE` definido pelo Workbench. Considere o comando abaixo executado em uma tabela com `NomeCli` declarada como `NOT NULL`:

```sql
INSERT INTO Cliente (idCliente, NomeCli) VALUES (1, NULL);
```

Como o MySQL se comporta **com** e **sem** essa flag ativa?

A) Com `STRICT_TRANS_TABLES` ativa, o MySQL aceita silenciosamente o `NULL`; sem ela, retorna erro. (O nome da flag é, na verdade, invertido em relação ao comportamento.)

B) Com ou sem a flag, o MySQL retorna erro — o nome `STRICT_TRANS_TABLES` afeta apenas operações em tabelas **não**-transacionais, como `MyISAM`.

C) Sem `STRICT_TRANS_TABLES`, o `INSERT` com `NomeCli = NULL` em uma coluna `NOT NULL` resultaria apenas em um aviso (warning) e um valor "padrão" silencioso (string vazia ou similar) — comportamento perigoso. Com `STRICT_TRANS_TABLES` ativa, o MySQL rejeita com erro `ER_BAD_NULL_ERROR`. Para sistemas profissionais, queremos sempre o erro.

D) Com a flag, o `INSERT` é aceito, mas registrado em uma "tabela paralela de strict mode"; sem a flag, é descartado completamente sem aviso.

---

## Questão 9

Por que o Workbench salva os valores antigos das variáveis em `@OLD_UNIQUE_CHECKS`, `@OLD_FOREIGN_KEY_CHECKS` e `@OLD_SQL_MODE` antes de modificá-las, em vez de simplesmente sobrescrever?

A) Porque o MySQL não permite alteração direta de variáveis de sistema sem antes copiar para variáveis de sessão — é uma exigência sintática do servidor.

B) Para criar um log automático de auditoria de alterações de configuração, exigido por regulações de proteção de dados (como a LGPD).

C) Porque a sessão pode estar sendo usada para outras coisas além desse script. Se simplesmente sobrescrevêssemos os valores, ao final do script a sessão ficaria com os flags do Workbench — possivelmente diferentes do que o usuário tinha antes. O padrão `@OLD_X = @@X` permite rastrear o estado original e, ao final, executar `SET X = @OLD_X` para reverter — devolvendo a sessão ao estado original sem efeitos colaterais.

D) Porque variáveis prefixadas com `@OLD_` são as únicas que persistem entre conexões — assim, os valores sobrevivem a desconexões acidentais durante o Forward Engineering.

---

## Questão 10

Após o Bloco 1, sua sessão está com `FOREIGN_KEY_CHECKS = 0`. No Bloco 3, você criará a tabela `Conta` com **duas chaves estrangeiras** (para `Cliente` e `TipoConta`). Qual seria o efeito prático se o flag estivesse em `1` durante essa criação?

A) Nenhum efeito prático — `FOREIGN_KEY_CHECKS` afeta apenas `INSERT`/`UPDATE`/`DELETE`, nunca `CREATE TABLE`.

B) Com `FOREIGN_KEY_CHECKS = 1`, ao criar `Conta` antes que `Cliente` ou `TipoConta` existam, o MySQL retornaria erro do tipo "Cannot resolve table name". A solução tradicional seria criar primeiro `Cliente`, depois `TipoConta`, depois `Conta` — a ordem importa. Com o flag em `0`, a ordem é irrelevante durante a criação. Isso é especialmente útil para scripts gerados automaticamente, que listam tabelas em ordem alfabética ou em ordem do diagrama.

C) O `CREATE TABLE` da `Conta` seria aceito normalmente em qualquer ordem, mas as FKs ficariam com status `INVALID` até `Cliente` ser criada — exigindo `ALTER TABLE` posterior para reativá-las.

D) O Workbench detecta automaticamente o estado do flag e o reverte para `0` em qualquer `CREATE TABLE` com FKs, evitando o erro mesmo se o usuário tiver definido `1` manualmente.
