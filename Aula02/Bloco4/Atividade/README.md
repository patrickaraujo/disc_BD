# 🧠 Atividade 4 — Praticando Criação e Gerenciamento de Schemas

> **Duração:** 25 minutos  
> **Formato:** Prática individual hands-on  
> **Objetivo:** Ganhar confiança criando e gerenciando schemas no MySQL Workbench

---

## 🎯 Objetivo da Atividade

Você vai criar vários schemas, praticar navegação e preparar-se para criar tabelas na próxima aula.

⚠️ **Importante:** Anote cada passo que realizar. Isso ajuda a fixar o aprendizado.

---

## 📋 Parte 1 — Criando Schemas (Via Interface Gráfica)

### Tarefa 1: Criar schema para Biblioteca

1. ☐ Abra o MySQL Workbench
2. ☐ Conecte-se ao servidor local
3. ☐ Clique com botão direito na área de Schemas
4. ☐ Selecione "Create Schema..."
5. ☐ Nome: `biblioteca`
6. ☐ Charset: `utf8mb4`
7. ☐ Collation: `utf8mb4_general_ci`
8. ☐ Clique em "Apply"
9. ☐ **Anote o SQL gerado:**

```sql
_______________________________________
_______________________________________
```

10. ☐ Clique em "Apply" novamente
11. ☐ Clique em "Finish"
12. ☐ Atualize (F5) e verifique se aparece

✅ **Checkpoint:** Schema `biblioteca` criado com sucesso

---

### Tarefa 2: Criar mais três schemas

Repita o processo para criar:

1. ☐ `loja_online`
2. ☐ `clinica_veterinaria`
3. ☐ `sistema_delivery`

**Quantos schemas você tem agora (incluindo os de sistema)?**  
_______________________

---

## 📋 Parte 2 — Criando Schemas (Via SQL)

### Tarefa 3: Usar comandos SQL

No Query Editor, digite e execute os comandos para criar:

**Schema 1:**
```sql
CREATE DATABASE controle_estoque
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
```

**Schema 2:**
```sql
CREATE DATABASE academia
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
```

**Schema 3:**
```sql
CREATE DATABASE escola
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;
```

☐ Execute cada um (Ctrl + Enter)  
☐ Atualize a lista de schemas  

✅ **Checkpoint:** 3 schemas criados via SQL

---

## 📋 Parte 3 — Navegando e Explorando

### Tarefa 4: Explorar estrutura

Para o schema `biblioteca`:

1. ☐ Expanda clicando na seta
2. ☐ Expanda "Tables"
3. ☐ **O que você vê?** _______________________
4. ☐ Explore também: Views, Stored Procedures, Functions

**Por que estão vazios?**  
_______________________________________

---

### Tarefa 5: Definir schema padrão

1. ☐ Clique com botão direito em `biblioteca`
2. ☐ Selecione "Set as Default Schema"
3. ☐ **O que mudou visualmente?** _______________________

Ou

1. ☐ Dê duplo clique em `loja_online`
2. ☐ Observe o resultado

💡 Schema padrão fica em **negrito**.

---

## 📋 Parte 4 — Comandos SQL de Consulta

### Tarefa 6: Ver schemas existentes

No Query Editor, execute:

```sql
SHOW DATABASES;
```

**Quantos schemas aparecem no resultado?** _______

**Liste 5 deles:**
1. _______________________
2. _______________________
3. _______________________
4. _______________________
5. _______________________

---

### Tarefa 7: Selecionar schema ativo

Execute:

```sql
USE biblioteca;
```

**Qual é a mensagem no Output?**  
_______________________________________

---

### Tarefa 8: Ver schema atual

Execute:

```sql
SELECT DATABASE();
```

**Qual é o resultado?** _______________________

---

## 📋 Parte 5 — Boas Práticas de Nomenclatura

### Tarefa 9: Identificar problemas

Indique se cada nome é ✅ BOM ou ❌ RUIM:

| Nome do Schema | Avaliação | Por quê? |
|----------------|-----------|----------|
| `sistema_vendas` | | |
| `Banco De Dados` | | |
| `bd1` | | |
| `controle-de-estoque` | | |
| `app_delivery_v2` | | |
| `SISTEMA` | | |
| `meu_projeto_final_tcc_2024` | | |

---

## 📋 Parte 6 — Deletando Schemas

⚠️ **CUIDADO:** Você vai praticar deletar, mas lembre-se que é irreversível!

### Tarefa 10: Deletar via interface

1. ☐ Clique com botão direito em `escola`
2. ☐ Selecione "Drop Schema..."
3. ☐ **O que o MySQL pede para você fazer?**  
   _______________________________________
4. ☐ Digite o nome do schema para confirmar
5. ☐ Clique em "Drop Now"
6. ☐ Atualize e verifique que sumiu

---

### Tarefa 11: Deletar via SQL

Execute:

```sql
DROP DATABASE academia;
```

☐ Atualize a lista  
☐ Verifique que sumiu  

**Qual foi a mensagem no Output?**  
_______________________________________

---

## 📋 Parte 7 — Cenário Prático

### Tarefa 12: Criar schema para projeto pessoal

**Imagine que você vai criar um sistema.** Escolha um:

- [ ] Gerenciador de tarefas
- [ ] Controle financeiro pessoal
- [ ] Catálogo de filmes/séries
- [ ] Sistema de receitas culinárias

**Sistema escolhido:** _______________________

**Crie o schema para este sistema:**

1. ☐ Escolha um nome apropriado
2. ☐ Use as boas práticas aprendidas
3. ☐ Crie via SQL (escreva o comando abaixo)

```sql
_______________________________________
_______________________________________
```

4. ☐ Execute e verifique
5. ☐ Defina como schema padrão

---

## 📋 Parte 8 — Documentação

### Tarefa 13: Documente seus schemas

Para cada schema que você criou e manteve, preencha:

| Schema | Finalidade | Charset | Padrão? |
|--------|------------|---------|---------|
| biblioteca | Sistema de empréstimo de livros | utf8mb4 | Não |
| | | | |
| | | | |
| | | | |
| | | | |

---

## 📋 Parte 9 — Reflexão

### Questões para responder:

**1. Por que é importante escolher utf8mb4 como charset?**

_____________________________________________
_____________________________________________

---

**2. Qual a diferença entre criar schema via GUI vs SQL?**

_____________________________________________
_____________________________________________

---

**3. Por que schemas de sistema (mysql, information_schema) não devem ser deletados?**

_____________________________________________
_____________________________________________

---

**4. O que acontece se você deletar um schema que tem tabelas com dados?**

_____________________________________________
_____________________________________________

---

**5. Complete a frase:**

"Schema é para o MySQL como _____________ é para o sistema operacional."

_____________________________________________

---

## 📋 Parte 10 — Desafio Final

### Tarefa 14: Criar estrutura completa para estudo

Crie a seguinte estrutura de schemas para usar no resto do curso:

```
☐ bd_exercicios (para praticar comandos)
☐ bd_projeto_final (para seu projeto)
☐ bd_testes (para experimentar sem medo)
```

**Comandos SQL usados:**

```sql
_______________________________________
_______________________________________
_______________________________________
```

**Defina `bd_exercicios` como padrão.**

---

## ✅ Checklist de Conclusão

Ao final desta atividade, você deve ter:

- [ ] Criado pelo menos 5 schemas via GUI
- [ ] Criado pelo menos 3 schemas via SQL
- [ ] Navegado pela estrutura de schemas
- [ ] Definido schemas como padrão
- [ ] Deletado schemas (com segurança)
- [ ] Executado comandos SHOW DATABASES, USE, SELECT DATABASE()
- [ ] Compreendido boas práticas de nomenclatura
- [ ] Preparado ambiente para próximas aulas

---

## 🎯 Comandos SQL que Você Praticou

```sql
-- Ver todos os schemas
SHOW DATABASES;

-- Criar schema
CREATE DATABASE nome_schema
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

-- Deletar schema
DROP DATABASE nome_schema;

-- Selecionar schema ativo
USE nome_schema;

-- Ver qual schema está ativo
SELECT DATABASE();
```

---

## 💭 Reflexão Final

**Escreva um parágrafo sobre sua experiência:**

_____________________________________________
_____________________________________________
_____________________________________________
_____________________________________________

---

**O que você achou mais fácil?**

_____________________________________________

**O que achou mais difícil?**

_____________________________________________

**Está pronto para criar tabelas na próxima aula?**

_____________________________________________

---

## 🆘 Problemas Encontrados?

**Liste qualquer problema que enfrentou e como resolveu:**

_____________________________________________
_____________________________________________
_____________________________________________

---

> ✅ **Parabéns! Você completou a Atividade 4 e está pronto para a Aula 03!**

💡 **Dica:** Mantenha os schemas `bd_exercicios`, `bd_projeto_final` e `bd_testes` para usar nas próximas aulas.
