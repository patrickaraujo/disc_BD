# 🧠 Atividade 2 — Identificando Entidades e Atributos na Prática

> **Duração:** 30 minutos  
> **Formato:** Individual ou em grupos  
> **Objetivo:** Praticar a identificação de entidades e atributos em diferentes mini-mundos

---

## 📋 Parte 1 — Análise de Mini-Mundos

Para cada mini-mundo descrito, identifique:
- Entidades (substantivos relevantes)
- Atributos de cada entidade

---

### Mini-Mundo 1: Sistema de Biblioteca

**Descrição:**

> *"Uma biblioteca precisa controlar seus livros e empréstimos. Cada livro possui ISBN, título, autor, editora e ano de publicação. Os usuários da biblioteca têm matrícula, nome, email e telefone. Quando um usuário pega um livro emprestado, é registrada a data de empréstimo e a data prevista de devolução."*

**Sua análise:**

**Entidades identificadas:**
1. _______________________
2. _______________________
3. _______________________

**Atributos:**

**Entidade 1:**  
_______________________

Atributos:
- _______________________
- _______________________
- _______________________

**Entidade 2:**  
_______________________

Atributos:
- _______________________
- _______________________
- _______________________

**Entidade 3:**  
_______________________

Atributos:
- _______________________
- _______________________

---

### Mini-Mundo 2: Clínica Veterinária

**Descrição:**

> *"Uma clínica veterinária atende animais de estimação. Cada animal tem nome, espécie, raça, data de nascimento e peso. Os donos dos animais possuem CPF, nome, endereço e telefone. As consultas registram data, hora, veterinário responsável e diagnóstico."*

**Sua análise:**

**Entidades identificadas:**
1. _______________________
2. _______________________
3. _______________________
4. _______________________

**Para cada entidade, liste os atributos:**

**_______________________ (Entidade):**
- _______________________
- _______________________
- _______________________
- _______________________

**_______________________ (Entidade):**
- _______________________
- _______________________
- _______________________
- _______________________

**_______________________ (Entidade):**
- _______________________
- _______________________
- _______________________
- _______________________

**_______________________ (Entidade):**
- _______________________

---

### Mini-Mundo 3: Sistema de Delivery

**Descrição:**

> *"Um aplicativo de delivery precisa gerenciar restaurantes, produtos e pedidos. Cada restaurante tem CNPJ, nome fantasia, endereço e categoria de cozinha. Os produtos possuem código, nome, descrição, preço e categoria. Clientes têm CPF, nome, telefone e endereço de entrega. Cada pedido registra número, data/hora, status, valor total e taxa de entrega."*

**Sua análise:**

**Quantas entidades você identificou?** _______

**Liste todas:**
1. _______________________
2. _______________________
3. _______________________
4. _______________________
5. _______________________

**Escolha 2 entidades e liste seus atributos:**

**Entidade escolhida 1:** _______________________
- _______________________
- _______________________
- _______________________
- _______________________

**Entidade escolhida 2:** _______________________
- _______________________
- _______________________
- _______________________
- _______________________

---

## 📋 Parte 2 — Evitando Erros Comuns

### Analise os casos e identifique o erro:

**Caso 1:**

```
Entidade: ENDEREÇO
Atributos: rua, número, bairro
```

**O que está errado?**  
_____________________________________________

**Como deveria ser?**  
_____________________________________________

---

**Caso 2:**

```
Entidade: ALUNO
Atributos: nome, matrícula, disciplinas
```

**O que está errado?**  
_____________________________________________

**Como deveria ser?**  
_____________________________________________

---

**Caso 3:**

```
Entidade: PRODUTO
Entidade: PREÇO
```

**O que está errado?**  
_____________________________________________

**Como deveria ser?**  
_____________________________________________

---

## 📋 Parte 3 — Desenho Simples

### Para o Mini-Mundo 1 (Biblioteca), desenhe as caixas:

Faça um desenho simples assim:

```
┌─────────────────┐
│     LIVRO       │
├─────────────────┤
│ ISBN            │
│ título          │
│ ...             │
└─────────────────┘
```

**Desenhe suas entidades aqui (pode ser no papel ou digital):**

---

## 📋 Parte 4 — Criando seu Próprio Mini-Mundo

**Escolha UM dos sistemas abaixo e descreva o mini-mundo:**

- [ ] Academia/Gym
- [ ] Locadora de veículos
- [ ] Sistema escolar (ensino fundamental)
- [ ] Consultório odontológico

**Sistema escolhido:** _______________________

**Descrição do mini-mundo (3-5 frases):**

_____________________________________________
_____________________________________________
_____________________________________________
_____________________________________________
_____________________________________________

**Entidades identificadas:**
1. _______________________
2. _______________________
3. _______________________
4. _______________________

**Atributos principais de cada entidade:**

_____________________________________________
_____________________________________________
_____________________________________________
_____________________________________________

---

## 📋 Parte 5 — Questões Reflexivas

**1. Por que identificar entidades ANTES de criar tabelas no banco?**

_____________________________________________
_____________________________________________

**2. Qual a diferença entre uma entidade e um atributo?**

_____________________________________________
_____________________________________________

**3. Dê um exemplo de algo que parece entidade mas é atributo:**

_____________________________________________

**4. O que acontece se você esquecer de modelar antes?**

_____________________________________________
_____________________________________________

**5. Complete: "Entidades são _____________ relevantes do mini-mundo."**

_____________________________________________

---

## ✅ Gabarito de Referência

### Parte 1 — Mini-Mundo 1 (Biblioteca)

**Entidades:**
1. LIVRO
2. USUÁRIO (ou CLIENTE)
3. EMPRÉSTIMO

**Atributos:**

**LIVRO:**
- ISBN
- título
- autor
- editora
- ano_publicação

**USUÁRIO:**
- matrícula
- nome
- email
- telefone

**EMPRÉSTIMO:**
- data_empréstimo
- data_prevista_devolução
- (livro e usuário são relacionamentos, não atributos simples)

---

### Parte 1 — Mini-Mundo 2 (Veterinária)

**Entidades:**
1. ANIMAL
2. DONO (ou PROPRIETÁRIO)
3. CONSULTA
4. VETERINÁRIO

**Atributos:**

**ANIMAL:** nome, espécie, raça, data_nascimento, peso  
**DONO:** CPF, nome, endereço, telefone  
**CONSULTA:** data, hora, diagnóstico  
**VETERINÁRIO:** (pode incluir: CRM, nome, especialidade)

---

### Parte 2 — Erros Comuns

**Caso 1:**  
Erro: Endereço geralmente é atributo, não entidade.  
Correto: CLIENTE (Atributos: rua, número, bairro...)

**Caso 2:**  
Erro: "disciplinas" não é atributo simples, é relacionamento.  
Correto: ALUNO relaciona-se com DISCIPLINA via MATRÍCULA

**Caso 3:**  
Erro: Preço é atributo de Produto, não entidade.  
Correto: PRODUTO (Atributos: código, nome, preço)

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Ler uma descrição e identificar entidades  
✅ Listar atributos relevantes de cada entidade  
✅ Evitar confundir entidades com atributos  
✅ Desenhar estruturas simples de dados  
✅ Compreender a importância de modelar antes  

> 💡 *"Identificar corretamente entidades e atributos é 50% do trabalho de modelagem. O restante é conectá-las adequadamente."*
