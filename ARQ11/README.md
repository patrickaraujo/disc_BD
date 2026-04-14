# Aula 11 - Objetos Avançados de BD: Automatização e Reutilização

Bem-vindo à aula sobre **Objetos Avançados de Banco de Dados**. Até agora você aprendeu a criar tabelas, inserir dados e fazer consultas. Mas e se você pudesse **automatizar tarefas repetitivas**, **proteger a integridade dos dados automaticamente** e **reutilizar lógica complexa**?

## 🎯 Objetivos da Aula

* Compreender quando e por que usar Stored Procedures
* Criar triggers que respondem automaticamente a eventos
* Desenvolver functions para cálculos reutilizáveis
* Utilizar views para simplificar consultas complexas
* Entender as vantagens e limitações de cada objeto

---

## 🔥 Problematização Inicial

### Cenário Real: Sistema de E-commerce

Imagine que você é responsável pelo banco de dados de um e-commerce. Todos os dias você enfrenta os seguintes problemas:

**Problema 1: Código Repetitivo**
```sql
-- Todo dia, em vários lugares do sistema, você precisa inserir usuários
-- E sempre valida a mesma coisa: CPF não pode ser nulo, email não pode ser vazio...
INSERT INTO usuario VALUES (...);
-- Depois repete isso em 10 lugares diferentes do código!
```

**Problema 2: Atualização de Estoque**
```sql
-- Quando alguém compra um produto, você precisa:
-- 1. Inserir o item no pedido
-- 2. LEMBRAR de atualizar o estoque
-- 3. LEMBRAR de registrar no histórico
-- 4. LEMBRAR de notificar se ficou abaixo do mínimo
-- Se esquecer UMA dessas etapas = PROBLEMA!
```

**Problema 3: Cálculos Complexos Repetidos**
```sql
-- Calcular desconto de 10% em TODOS os produtos
SELECT nome, preco, (preco * 0.90) AS preco_desconto FROM produto;
-- Amanhã muda para 15%... você precisa alterar em 50 lugares!
```

**Problema 4: Consultas Gigantes e Repetidas**
```sql
-- Toda vez que precisa ver pedidos com cliente e produto:
SELECT p.numero, c.nome, pr.descricao, p.valor_total
FROM pedido p
INNER JOIN cliente c ON p.cliente_id = c.id
INNER JOIN item_pedido ip ON p.id = ip.pedido_id
INNER JOIN produto pr ON ip.produto_id = pr.id
WHERE p.status = 'ATIVO';
-- E escreve isso 100 vezes por semana!
```

### 💡 A Solução: Objetos Avançados de BD

| Problema | Solução | Objeto BD |
|----------|---------|-----------|
| Código repetitivo | Encapsular lógica reutilizável | **Stored Procedure** |
| Ações automáticas | Disparar ações em eventos | **Trigger** |
| Cálculos repetidos | Criar funções reutilizáveis | **Function** |
| Consultas complexas repetidas | Criar "tabelas virtuais" | **View** |

---

## 📂 Organização dos Blocos

Esta aula está dividida em quatro blocos práticos:

### [Bloco 01 — Stored Procedures: Automatizando Tarefas Repetitivas](./Bloco1/README.md)
* **Foco:** Criar procedimentos armazenados para reutilizar lógica
* **Destaque:** Validações, inserções, consultas e exclusões via procedures com parâmetros

### [Bloco 02 — Triggers: Ações Automáticas em Eventos](./Bloco2/README.md)
* **Foco:** Criar gatilhos que disparam automaticamente
* **Destaque:** BEFORE vs AFTER, INSERT/UPDATE/DELETE, auditoria automática e atualização de estoque

### [Bloco 03 — Functions: Cálculos Reutilizáveis](./Bloco3/README.md)
* **Foco:** Criar funções para cálculos e transformações
* **Destaque:** Functions determinísticas, cálculo de descontos, formatação de dados

### [Bloco 04 — Views: Simplificando Consultas Complexas](./Bloco4/README.md)
* **Foco:** Criar tabelas virtuais para consultas recorrentes
* **Destaque:** Views simples, views com JOINs, views atualizáveis, segurança com views

---

## 🚀 Como estudar este conteúdo

1. **Leia a problematização** e identifique situações que você já enfrentou
2. Comece pelo **Bloco 1** (Stored Procedures) - a base para os demais
3. Continue no **Bloco 2** (Triggers) - veja como automatizar ações
4. Siga para o **Bloco 3** (Functions) - aprenda a criar cálculos reutilizáveis
5. Finalize com o **Bloco 4** (Views) - simplifique suas consultas

---

## 📌 Importante

* **Cada bloco tem atividades práticas obrigatórias**
* Use o arquivo `COMANDOS-BD-02.sql` como referência
* Todos os exemplos são baseados em situações reais
* Você vai criar seu próprio banco `Procs_Armazenados` para praticar

---

## 🎯 Ao Final desta Aula

Você será capaz de:

✅ Criar procedures para encapsular lógica de negócio  
✅ Desenvolver triggers que garantem integridade automática  
✅ Construir functions para cálculos complexos  
✅ Implementar views para simplificar acesso aos dados  
✅ Escolher qual objeto usar em cada situação  

---

## 📊 Comparação Rápida dos Objetos

| Objeto | Retorna Valor? | Pode Modificar Dados? | Quando Usar? |
|--------|----------------|----------------------|--------------|
| **Stored Procedure** | Opcional | ✅ Sim | Lógica de negócio complexa |
| **Trigger** | ❌ Não | ✅ Sim | Ações automáticas em eventos |
| **Function** | ✅ Sempre | ⚠️ Não recomendado | Cálculos e transformações |
| **View** | ✅ Sim (tabela virtual) | ⚠️ Limitado | Consultas recorrentes complexas |

---

### Estrutura de pastas da `Aula11`:

```
Aula11/
├── Bloco1/ (Stored Procedures)
│   ├── README.md
│   └── Atividade/
│       └── README.md
├── Bloco2/ (Triggers)
│   ├── README.md
│   └── Atividade/
│       └── README.md
├── Bloco3/ (Functions)
│   ├── README.md
│   └── Atividade/
│       └── README.md
├── Bloco4/ (Views)
│   ├── README.md
│   └── Atividade/
│       └── README.md
├── codigo-fonte/
│   └── COMANDOS-BD-02.sql
└── README.md (Este arquivo introdutório)
```

---

## 🔗 Pré-requisitos

Antes de iniciar esta aula:
- ✅ Saber criar tabelas e inserir dados
- ✅ Dominar SELECT básico e JOINs
- ✅ Compreender chaves primárias e estrangeiras
- ✅ Ter MySQL instalado e funcionando

---

> 💭 *"Bancos de dados modernos não são apenas repositórios de dados — são sistemas inteligentes que podem automatizar, validar e proteger seus dados sozinhos."*
