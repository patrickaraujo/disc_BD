# Atividade 7 — DCL aplicado

> **Banco de Questões em formato Microsoft Forms**  
> Disciplina: Banco de Dados | Aula ARQ12 — Bloco 7  
> Origem: conversão da Atividade 7 (questões 61 a 71) em itens de múltipla escolha.

> ⚠️ **Pré-requisito assumido pelas questões.** Os comandos discutidos exigem que a sessão MySQL esteja conectada como `root` (ou outro superusuário com privilégios de `CREATE USER` e `GRANT`).

---

## Questão 1

Em uma instalação padrão do MySQL 8 (recém-instalada e sem alterações posteriores), executa-se:

```sql
SELECT User, Host FROM mysql.user;
```

Quais usuários você esperaria encontrar listados?

A) Apenas `'root'@'localhost'`, pois é o único usuário criado por padrão; eventuais contas de sistema são virtuais e não aparecem em `mysql.user`.

B) **Tipicamente entre 4 e 7 usuários, incluindo contas internas reservadas pelo servidor (como `'mysql.session'@'localhost'`, `'mysql.sys'@'localhost'`, `'mysql.infoschema'@'localhost'`) e o administrador `'root'@'localhost'`. As contas internas servem ao próprio MySQL e não devem ser modificadas pelo usuário.** ✅

C) Apenas usuários criados explicitamente após a instalação; em uma instalação limpa, a saída é vazia (0 linhas).

D) Centenas de usuários, pois o MySQL pré-instala uma conta para cada banco do sistema (`information_schema`, `performance_schema`, `sys` etc.).

---

## Questão 2

Qual comando cria corretamente um novo usuário **`aluno_leitura`** que se conecta a partir de `localhost` com a senha `senha_segura@2025`?

A) `CREATE USER aluno_leitura@localhost PASSWORD 'senha_segura@2025';`

B) `INSERT INTO mysql.user (User, Host, Password) VALUES ('aluno_leitura', 'localhost', 'senha_segura@2025');`

C) **`CREATE USER 'aluno_leitura'@'localhost' IDENTIFIED BY 'senha_segura@2025';`** ✅

D) `GRANT USER 'aluno_leitura'@'localhost' WITH PASSWORD 'senha_segura@2025';`

---

## Questão 3

Para conceder a `'aluno_leitura'@'localhost'` **apenas o privilégio `SELECT` em todas as tabelas do banco `procs_armazenados`** (e nada além disso), qual é o comando correto?

A) `GRANT SELECT ON *.* TO 'aluno_leitura'@'localhost';` — concede `SELECT` em todos os bancos, o que excede o pedido.

B) **`GRANT SELECT ON procs_armazenados.* TO 'aluno_leitura'@'localhost';` — restringe o privilégio apenas às tabelas do banco `procs_armazenados`, exatamente como solicitado.** ✅

C) `GRANT ALL PRIVILEGES ON procs_armazenados.* TO 'aluno_leitura'@'localhost';` — equivalente, pois `ALL` resume-se a `SELECT` em bancos sem dados sensíveis.

D) `GRANT SELECT ON procs_armazenados.LIVROS TO 'aluno_leitura'@'localhost';` — necessário restringir tabela a tabela, pois o MySQL não suporta sintaxe para "todas as tabelas do banco".

---

## Questão 4

Após executar o `GRANT SELECT ON procs_armazenados.* ...` da questão anterior, executa-se:

```sql
SHOW GRANTS FOR 'aluno_leitura'@'localhost';
```

O que aparece no resultado?

A) Apenas a linha `GRANT SELECT ON procs_armazenados.* TO aluno_leitura@localhost`. O privilégio `USAGE` não aparece porque é um valor padrão implícito que o `SHOW GRANTS` esconde.

B) **Duas linhas: `GRANT USAGE ON *.* TO 'aluno_leitura'@'localhost'` e `GRANT SELECT ON 'procs_armazenados'.* TO 'aluno_leitura'@'localhost'`. O `USAGE ON *.*` é o privilégio "vazio" automático de qualquer usuário criado — significa "pode se conectar, mas não pode fazer mais nada por padrão". A segunda linha registra o `SELECT` concedido explicitamente.** ✅

C) Apenas `GRANT ALL PRIVILEGES ON *.* TO aluno_leitura@localhost`, pois o MySQL consolida os privilégios menores em "ALL" para simplificar a leitura.

D) Erro — `aluno_leitura` ainda não fez login, e `SHOW GRANTS` só funciona para usuários com sessões ativas no momento.

---

## Questão 5

Após executar `DROP USER 'aluno_leitura'@'localhost';` e em seguida:

```sql
SELECT User, Host FROM mysql.user WHERE User = 'aluno_leitura';
```

Qual é o resultado esperado?

A) Uma linha com `User = 'aluno_leitura'` e `Host = 'DROPPED'`, indicando o estado lógico de remoção.

B) Erro de execução — `DROP USER` exige antes um `REVOKE ALL PRIVILEGES` explícito sobre cada banco em que houve concessão.

C) **0 linhas. O `DROP USER` removeu o registro da tabela `mysql.user` e revogou automaticamente todos os privilégios associados ao par usuário+host.** ✅

D) Múltiplas linhas, uma para cada banco em que o usuário tinha privilégios concedidos, listando os privilégios revogados como histórico de auditoria.

---

## Questão 6

Por que `'rzampar'@'localhost'` e `'rzampar'@'%'` podem ter privilégios completamente diferentes? Em que cenário concreto faz sentido criar as duas contas?

A) Não podem — o MySQL trata o nome do usuário como identificador único e força que ambas tenham os mesmos privilégios.

B) **Porque o MySQL trata `'usuario'@'host'` como um par único: `'rzampar'@'localhost'` e `'rzampar'@'%'` são duas contas distintas, com privilégios independentes. Cenário típico: o mesmo desenvolvedor acessa o banco localmente com privilégios completos (durante o desenvolvimento) e remotamente com apenas privilégios de leitura (por motivos de segurança).** ✅

C) Podem, mas apenas se forem criadas em bancos diferentes; dentro do mesmo banco, há uma constraint que impede privilégios divergentes para o mesmo nome de usuário.

D) Podem, mas apenas em versões antigas do MySQL (< 5.7); a partir do 8.0, contas com mesmo nome são automaticamente unificadas pelo servidor.

---

## Questão 7

Considere os dois `GRANT`s abaixo:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'usuario1'@'localhost';
GRANT SELECT, INSERT ON procs_armazenados.LIVROS TO 'usuario2'@'localhost';
```

Qual afirmação descreve corretamente a diferença entre eles e identifica qual representa melhor o **princípio do menor privilégio**?

A) Os dois são equivalentes na prática; a sintaxe difere apenas por preferência estilística do DBA.

B) `usuario2` tem mais privilégios que `usuario1`, pois pode fazer `INSERT`, que é uma operação considerada mais arriscada que `ALL PRIVILEGES` em servidores de produção.

C) **`usuario1` recebe todos os privilégios em todos os bancos e tabelas — pode criar/excluir bancos, alterar tabelas do sistema, criar outros usuários etc. `usuario2` recebe apenas `SELECT` e `INSERT` em uma única tabela (`LIVROS` do banco `procs_armazenados`) — não pode `UPDATE`, `DELETE`, alterar estrutura nem acessar outras tabelas. O segundo representa o princípio do menor privilégio: conceder só o necessário. Se a aplicação for comprometida, o atacante herda apenas o que aquele usuário podia fazer, limitando o estrago.** ✅

D) `usuario1` representa o menor privilégio, pois `*.*` é mais restritivo que `procs_armazenados.LIVROS` (que abriria espaço para SQL injection).

---

## Questão 8

Em qual cenário o comando `FLUSH PRIVILEGES` é **necessário** (e não apenas redundante)?

A) Após qualquer `CREATE USER`, pois sem ele o usuário recém-criado não consegue se conectar.

B) **Após manipular diretamente as tabelas de privilégios (`mysql.user`, `mysql.db`, `mysql.tables_priv` etc.) com `INSERT`/`UPDATE`/`DELETE`, em vez de usar os comandos DCL apropriados. Nesses casos, o servidor não recarrega automaticamente as tabelas de privilégios em memória — `FLUSH PRIVILEGES` força essa recarga. Após `CREATE USER`/`GRANT`/`DROP USER`/`REVOKE`, o servidor já recarrega sozinho, e `FLUSH` é redundante (embora inofensivo).** ✅

C) Após qualquer `GRANT`, pois sem ele o privilégio recém-concedido só passa a valer na próxima reinicialização do servidor.

D) Sempre, em todas as sessões — sem ele, mudanças DDL/DML em geral não são persistidas em disco.

---

## Questão 9

Após executar `DROP USER 'fulano'@'localhost';`, o que acontece com as **sessões abertas** desse usuário no momento exato do `DROP`?

A) São derrubadas instantaneamente; toda transação aberta é desfeita por `ROLLBACK` automático.

B) **Continuam funcionando até serem encerradas — o `DROP USER` não força desconexão. Mas qualquer comando subsequente que dependa dos privilégios revogados pode começar a falhar com erro de permissão.** ✅

C) Permanecem ativas indefinidamente, com todos os privilégios congelados no estado anterior ao `DROP`, até que o servidor seja reiniciado.

D) São automaticamente reconectadas como o usuário `'anonymous'@'localhost'`, herdando os privilégios padrão de visitante.

---

## Questão 10

Após `DROP USER 'fulano'@'localhost';`, o que acontece com **novas tentativas de conexão** desse usuário?

A) São aceitas, mas em modo somente-leitura, até que o usuário seja recriado.

B) São aceitas e o usuário recebe uma sessão temporária com privilégios `USAGE ON *.*`.

C) **São imediatamente recusadas — o usuário não existe mais em `mysql.user`, e o servidor rejeita a autenticação com erro de credenciais inválidas.** ✅

D) Ficam em fila aguardando a recriação do usuário; se ele for recriado em até 60 segundos, a conexão é estabelecida automaticamente.

---

## Questão 11

Após `DROP USER 'fulano'@'localhost';`, o que acontece com os **dados criados** por esse usuário (tabelas, registros, índices, views, SPs)?

A) São automaticamente removidos por cascata, junto com a conta — o `DROP USER` é definitivo nesse aspecto também.

B) **Não são afetados. Tabelas, linhas, índices, views, SPs etc. permanecem intactos. O `DROP USER` afeta apenas a conta do usuário, não os objetos do banco. Os dados continuam acessíveis a outros usuários com privilégios apropriados.** ✅

C) São transferidos automaticamente para o usuário `root@localhost`, que assume a posse dos objetos órfãos.

D) Ficam marcados como "órfãos" em uma área isolada e só podem ser recuperados se o usuário for recriado com o mesmo nome dentro de 24 horas.

---

## Questão 12

Por que `SHOW GRANTS FOR 'usuario'@'host';` é geralmente preferível a tentar interpretar diretamente as colunas da tabela `mysql.user`?

A) Porque `SHOW GRANTS` é uma operação significativamente mais rápida no servidor e consome menos CPU em servidores com muitas tabelas.

B) Porque a tabela `mysql.user` é restrita a superusuários e não pode ser consultada em laboratórios escolares, enquanto `SHOW GRANTS` está sempre disponível.

C) **Porque `mysql.user` tem dezenas de colunas booleanas (uma para cada privilégio possível) e mais de uma tabela está envolvida no controle de privilégios (`mysql.user`, `mysql.db`, `mysql.tables_priv`, `mysql.columns_priv`). Interpretar tudo manualmente é trabalhoso e propenso a erro. `SHOW GRANTS` consolida tudo em uma forma legível e idêntica à sintaxe do próprio `GRANT` — você lê o privilégio do mesmo jeito que o concederia.** ✅

D) Porque `mysql.user` está depreciada desde o MySQL 5.7 e será removida em versões futuras; `SHOW GRANTS` é a única forma compatível com versões recentes.

---

## Questão 13

Considere uma **aplicação web (front-end de loja)** que apenas exibe o catálogo de produtos para visitantes, **sem permitir nenhuma escrita**. Qual `GRANT` representa melhor o princípio do menor privilégio para o usuário associado a essa aplicação?

A) `GRANT ALL PRIVILEGES ON loja.* TO 'app_catalogo'@'%';`

B) **`GRANT SELECT ON loja.Produtos TO 'app_catalogo'@'%';`** ✅

C) `GRANT SELECT, INSERT, UPDATE, DELETE ON loja.* TO 'app_catalogo'@'%';`

D) `GRANT ALL PRIVILEGES ON *.* TO 'app_catalogo'@'%' WITH GRANT OPTION;`

---

## Questão 14

Considere um **sistema de checkout** que insere pedidos, registra itens de pedido e atualiza o estoque dos produtos vendidos. Qual abordagem reflete melhor o princípio do menor privilégio?

A) `GRANT ALL PRIVILEGES ON *.* TO 'app_checkout'@'%';` — para garantir que nenhum erro de permissão atrapalhe a venda em momento crítico.

B) `GRANT SELECT ON loja.Produtos TO 'app_checkout'@'%';` — apenas leitura é suficiente, pois o checkout consulta o estoque mas não o altera.

C) **`GRANT SELECT, INSERT, UPDATE ON loja.Pedido TO 'app_checkout'@'%';` (e privilégios análogos para `ItemPedido`, com `UPDATE` restrito a `Produtos.QTDESTOQUE`). Ainda melhor: conceder `EXECUTE` em SPs específicas (como `sp_insere_itempedido`) em vez de DML direto, encapsulando as regras de negócio dentro do próprio banco.** ✅

D) `GRANT DELETE ON loja.* TO 'app_checkout'@'%';` — apenas `DELETE` é necessário, pois o checkout limpa o carrinho ao final da compra.

---

## Questão 15

Considere um **DBA junior** responsável por administrar tabelas e índices em um banco específico (`loja`), mas **sem permissão para criar usuários** ou modificar tabelas do sistema. Qual `GRANT` é mais apropriado?

A) `GRANT ALL PRIVILEGES ON *.* TO 'dba_junior'@'%';` — DBA precisa de acesso total para ser eficaz em qualquer banco.

B) **`GRANT ALL PRIVILEGES ON loja.* TO 'dba_junior'@'%';` — concede privilégios completos apenas no banco específico (`loja`), sem privilégios em `mysql.*` ou outros bancos críticos. Isso impede que o DBA junior crie usuários, altere privilégios globais ou modifique metadados sensíveis do servidor.** ✅

C) `GRANT SELECT ON loja.* TO 'dba_junior'@'%';` — apenas leitura, para evitar qualquer alteração estrutural acidental.

D) `GRANT EXECUTE ON loja.* TO 'dba_junior'@'%';` — apenas execução de SPs, sem DDL nem DML diretos.

---

## Questão 16

Considere um **DBA sênior** que é o superusuário responsável pela administração geral do servidor, incluindo criação de outros usuários, concessão de privilégios e manutenção de bancos do sistema. Qual `GRANT` é mais apropriado?

A) `GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'dba_senior'@'localhost';` — DML completo em todos os bancos é suficiente para a maioria das tarefas de DBA.

B) `GRANT ALL PRIVILEGES ON loja.* TO 'dba_senior'@'%';` — restrito ao banco da aplicação para minimizar risco de exposição.

C) **`GRANT ALL PRIVILEGES ON *.* TO 'dba_senior'@'localhost' WITH GRANT OPTION;` — todos os privilégios em todos os bancos, com a capacidade adicional de conceder privilégios a outros usuários (`WITH GRANT OPTION`). O `localhost` restringe a conexão à máquina do servidor, evitando exposição remota dessa conta crítica.** ✅

D) `GRANT EXECUTE ON *.* TO 'dba_senior'@'%';` — apenas execução de procedures, pois um DBA sênior nunca executa DML diretamente em produção.
