# 🧠 Atividade 2 — Observando ROLLBACK e COMMIT na prática

> **Duração:** 20 minutos  
> **Formato:** Individual  
> **Objetivo:** Verificar, com seus próprios dados, o efeito de `ROLLBACK` e `COMMIT`, e refletir sobre o conceito de transação.

---

## 📋 Parte 1 — Execução

10. Antes de começar, garanta que a tabela `LIVROS` está **vazia** (após o `TRUNCATE` do roteiro). Execute o `SELECT *` que confirma isso e relate o resultado.

11. Abra uma nova transação. Insira **dois livros à sua escolha** (use ISBNs fictícios distintos dos do roteiro). Em seguida, execute um `SELECT *` e confirme as 2 linhas.

12. Execute `ROLLBACK;` e relate o resultado do `SELECT *` seguinte. Quantas linhas restaram?

13. Repita o passo 11 (insira novamente os 2 livros), e desta vez execute `COMMIT;`. Em seguida, execute o `SELECT *` final e relate o número de linhas.

14. Limpe a tabela ao final (`TRUNCATE TABLE LIVROS;`) — para deixar o ambiente preparado para o Bloco 3.

---

## 📋 Parte 2 — Questões Conceituais

15. Imagine que, durante a transação do passo 11, **antes do `ROLLBACK`**, um colega seu (em outra sessão do MySQL Workbench) executou `SELECT * FROM LIVROS;`. Quantas linhas ele veria? Justifique.

16. Em uma transação aberta com `START TRANSACTION`, suponha que você execute, em sequência, **três** `INSERT`s: o primeiro e o terceiro são válidos, mas o segundo gera um erro de constraint. Você **não** trata esse erro manualmente. Após os 3 comandos, você executa `COMMIT`. Quais registros são gravados? Justifique.

17. Defina, com suas próprias palavras, **atomicidade**. Por que ela é tão importante para sistemas como o de uma livraria, um banco ou um e-commerce?

18. O `TRUNCATE TABLE` poderia ser revertido com `ROLLBACK`? Por quê?

---

## 📋 Parte 3 — Experimentação

19. Execute o experimento abaixo, **na ordem indicada**, e relate o que aparece em cada `SELECT`:

```sql
START TRANSACTION;
INSERT INTO LIVROS VALUES (1234567890123, 'Autor A', 'Livro A', 19.90);
SELECT * FROM LIVROS; -- (a) quantas linhas?
INSERT INTO LIVROS VALUES (1234567890123, 'Autor B', 'Livro B', 29.90);
-- (b) o que aconteceu? por quê?
SELECT * FROM LIVROS; -- (c) quantas linhas?
COMMIT;
SELECT * FROM LIVROS; -- (d) quantas linhas?
```

20. Explique, com base no que você observou na questão 19, por que **dentro de uma SP** seria útil ter um mecanismo automático para detectar o erro do segundo `INSERT` e disparar um `ROLLBACK` em vez de um `COMMIT`. (Esse mecanismo é o `DECLARE CONTINUE HANDLER`, que você verá no Bloco 3.)

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

10. **0 linhas.** A tabela foi truncada ao final do roteiro do bloco.

11. **2 linhas** após o `INSERT` (visíveis para a sua sessão, ainda não confirmadas).

12. **0 linhas.** O `ROLLBACK` descartou os 2 inserts pendentes.

13. **2 linhas.** O `COMMIT` persistiu definitivamente os 2 inserts.

14. **0 linhas** após o `TRUNCATE TABLE LIVROS;`. Ambiente pronto para o Bloco 3.

---

### Parte 2

15. **0 linhas.** O isolamento padrão do InnoDB é `REPEATABLE READ`. Outras sessões só enxergam dados confirmados (`COMMIT`-ados). Como você ainda não tinha confirmado, os 2 livros eram visíveis somente para você.

16. **Os três `INSERT`s tentariam ser gravados pelo `COMMIT`, mas o segundo já falhou no momento da execução** — o registro inválido nunca chega a entrar na transação. Os outros dois (válidos) são confirmados normalmente. Em outras palavras: o MySQL **não** desfaz automaticamente os comandos anteriores quando um deles falha; ele simplesmente rejeita o comando errôneo. Quem precisa decidir "desfazer tudo se algo der errado" é **você** (ou um handler dentro da SP).

17. **Atomicidade** é a propriedade que garante que uma transação é tratada como uma **unidade indivisível**: ou **todas** as suas operações são confirmadas, ou **nenhuma**. Em sistemas críticos (banco, e-commerce, livraria), isso é essencial — imagine debitar o saldo de uma conta e **não creditar** na outra: meia operação ≠ operação correta.

18. **Não.** No MySQL, `TRUNCATE TABLE` faz **commit implícito** — encerra qualquer transação em aberto e descarta o efeito do `ROLLBACK`. Trate-o como definitivo.

---

### Parte 3

19. (a) **1 linha.** O primeiro `INSERT` foi pendente. (b) **Erro 1062 — Duplicate entry para a chave primária `1234567890123`**. O segundo `INSERT` é rejeitado, mas a transação **continua aberta**. (c) **1 linha** (apenas o primeiro `INSERT`, que continua válido na transação). (d) **1 linha** (o `COMMIT` persistiu o primeiro registro; o segundo nunca chegou a fazer parte da transação).

20. Porque, sem detecção automática, a SP **vai confirmar parcialmente** uma operação que devia ser "tudo ou nada". O `DECLARE CONTINUE HANDLER FOR SQLEXCEPTION` permite que a SP **detecte** que algo deu errado durante a transação e, em vez de fazer `COMMIT` cego, faça `ROLLBACK` — preservando a atomicidade.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Diferenciar com clareza estado **pendente** de estado **persistido**.  
✅ Entender que outras sessões só enxergam dados após `COMMIT`.  
✅ Reconhecer que o MySQL **não** dispara `ROLLBACK` automaticamente em caso de erro pontual — é responsabilidade do código.  

> 💡 *"Transação não é um detalhe técnico — é uma promessa de consistência."*
