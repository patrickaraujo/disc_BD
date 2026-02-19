# 🧠 Atividade 4 — Explorando o MySQL Workbench na Prática

> **Duração:** 30 minutos  
> **Formato:** Prática individual guiada  
> **Objetivo:** Familiarizar-se com o MySQL Workbench e compreender estruturas de dados relacionais

---

## 🎯 Importante: Modo Observação

⚠️ **Regra de Ouro:** Nesta atividade você vai apenas **OBSERVAR e ANOTAR**.  
❌ **Não modifique, não delete, não crie nada ainda!**

---

## 📋 Parte 1 — Conectando ao MySQL

### Tarefa 1: Abrir o MySQL Workbench

1. ☐ Abra o MySQL Workbench
2. ☐ Identifique as conexões disponíveis
3. ☐ Clique duas vezes na conexão local (geralmente "Local instance MySQL80")
4. ☐ Digite a senha, se solicitado

✅ **Checkpoint:** Você deve ver o ambiente de trabalho do Workbench aberto.

---

### Tarefa 2: Explorar a Interface

**Identifique e descreva cada área:**

1. **Painel esquerdo (Navigator):**  
   O que você vê aqui?  
   _______________________________________

2. **Área central (Query Editor):**  
   Para que serve?  
   _______________________________________

3. **Painel inferior:**  
   O que aparece aqui?  
   _______________________________________

---

## 📋 Parte 2 — Explorando Schemas

### Tarefa 3: Visualizar Schemas Disponíveis

1. ☐ Clique em "Schemas" no painel esquerdo
2. ☐ Liste os schemas que aparecem

**Schemas encontrados:**
- _______________________________________
- _______________________________________
- _______________________________________
- _______________________________________

---

### Tarefa 4: Identificar Schemas de Sistema

**Marque quais você identificou:**

- ☐ `information_schema`
- ☐ `mysql`
- ☐ `performance_schema`
- ☐ `sys`

💡 **Nota:** Estes são schemas do sistema MySQL. **Não mexa neles!**

---

### Tarefa 5: Escolher um Schema para Explorar

**Se houver outros schemas além dos de sistema, escolha um.**  
**Se não houver, use o schema `mysql` (com cuidado!).**

**Schema escolhido:**  
_______________________________________

**Por que escolheu este:**  
_______________________________________

---

## 📋 Parte 3 — Explorando Tabelas

### Tarefa 6: Expandir o Schema

1. ☐ Clique na seta ao lado do schema escolhido
2. ☐ Expanda "Tables"

**Quantas tabelas existem neste schema?**  
_______________________________________

**Liste 5 tabelas que você vê:**
1. _______________________________________
2. _______________________________________
3. _______________________________________
4. _______________________________________
5. _______________________________________

---

### Tarefa 7: Escolher uma Tabela para Analisar

**Escolha uma tabela que pareça interessante.**

**Tabela escolhida:**  
_______________________________________

**Por que esta tabela chamou sua atenção?**  
_______________________________________

---

## 📋 Parte 4 — Visualizando Dados

### Tarefa 8: Ver os Dados da Tabela

1. ☐ Clique com botão direito na tabela escolhida
2. ☐ Selecione **"Select Rows - Limit 1000"**
3. ☐ Aguarde os dados aparecerem

✅ **Checkpoint:** Você deve ver uma grade com linhas e colunas.

---

### Tarefa 9: Analisar a Estrutura

**Responda sobre a tabela que você visualizou:**

**1. Quantas colunas (atributos) a tabela tem?**  
_______________________________________

**2. Liste as 5 primeiras colunas:**
- _______________________________________
- _______________________________________
- _______________________________________
- _______________________________________
- _______________________________________

**3. Quantas linhas (registros) aparecem?**  
_______________________________________

**4. Escolha uma linha qualquer e descreva o que ela representa:**  
_______________________________________
_______________________________________

---

## 📋 Parte 5 — Identificando Tipos de Dados

### Tarefa 10: Classificar Colunas por Tipo

**Para cada coluna que você identificou, tente descobrir o tipo de dado:**

| Coluna | Tipo (texto/número/data/booleano) | Dado Qualitativo ou Quantitativo? |
|--------|-----------------------------------|-----------------------------------|
| | | |
| | | |
| | | |
| | | |
| | | |

---

## 📋 Parte 6 — Análise Conceitual

### Tarefa 11: Conexão com Conceitos Anteriores

**Sobre os dados que você visualizou, responda:**

**1. Esses dados são estruturados ou não estruturados? Por quê?**  
_______________________________________
_______________________________________

**2. Dê um exemplo de como esses dados (isolados) são apenas "dados":**  
_______________________________________

**3. Como esses dados se tornariam "informação"? (dê um exemplo)**  
_______________________________________
_______________________________________

**4. Qual seria um possível "conhecimento" extraído desses dados?**  
_______________________________________
_______________________________________

**5. Qual ação (sabedoria) poderia ser tomada com base nesse conhecimento?**  
_______________________________________
_______________________________________

---

## 📋 Parte 7 — Explorando Múltiplas Tabelas

### Tarefa 12: Comparar Estruturas

**Visualize pelo menos 3 tabelas diferentes e preencha:**

| Tabela | Nº de Colunas | Nº de Linhas | Finalidade Provável |
|--------|---------------|--------------|---------------------|
| | | | |
| | | | |
| | | | |

---

### Tarefa 13: Identificar Relacionamentos (Observação Visual)

**Olhe para os nomes das colunas. Você consegue identificar possíveis ligações entre tabelas?**

**Exemplo:**  
Se uma tabela tem `cliente_id` e outra tem `id_cliente`, provavelmente estão relacionadas.

**Relacionamentos que você identificou:**

Tabela 1: _______________ + Tabela 2: _______________  
**Coluna em comum:** _______________

---

## 📋 Parte 8 — Reflexão Final

### Tarefa 14: Responda

**1. O que mais te surpreendeu ao ver os dados organizados dessa forma?**  
_______________________________________
_______________________________________

**2. Por que você acha que os dados são organizados em tabelas com linhas e colunas?**  
_______________________________________
_______________________________________

**3. Como isso se compara a uma planilha Excel?**  
**Semelhanças:**  
_______________________________________

**Diferenças:**  
_______________________________________

**4. Você consegue imaginar como seria armazenar esses mesmos dados de forma NÃO estruturada? Dê um exemplo.**  
_______________________________________
_______________________________________

---

## 📋 Parte 9 — Desafio de Observação

### Tarefa 15: Caça ao Tesouro

**Encontre e anote:**

**1. Uma tabela que parece armazenar informações de usuários ou pessoas:**  
Tabela: _______________  
Como você identificou: _______________

**2. Uma tabela com data/timestamp:**  
Tabela: _______________  
Nome da coluna: _______________

**3. Uma tabela com valores booleanos (true/false ou 0/1):**  
Tabela: _______________  
Nome da coluna: _______________

**4. A tabela com maior número de colunas:**  
Tabela: _______________  
Número de colunas: _______________

**5. A tabela com maior número de registros (linhas):**  
Tabela: _______________  
Número aproximado de linhas: _______________

---

## 📋 Parte 10 — Questionário de Autoavaliação

Marque sua compreensão de cada tópico:

| Conceito | ⭐ Não entendi | ⭐⭐ Entendi parcialmente | ⭐⭐⭐ Entendi bem |
|----------|----------------|--------------------------|-------------------|
| O que é o MySQL Workbench | | | |
| Como navegar entre schemas | | | |
| Como visualizar tabelas | | | |
| O que são linhas/colunas | | | |
| Dados estruturados | | | |
| Diferença de tipos de dados | | | |

---

## ✅ Checklist de Conclusão

Ao final desta atividade, você deve ter:

- ☐ Conectado ao MySQL com sucesso
- ☐ Explorado pelo menos 1 schema
- ☐ Visualizado pelo menos 3 tabelas
- ☐ Identificado linhas e colunas
- ☐ Classificado tipos de dados
- ☐ Conectado conceitos teóricos com a prática
- ☐ Perdido o medo do ambiente de BD

---

## 🎯 Perguntas para Discussão em Sala

Prepare-se para discutir:

1. **Qual foi sua primeira impressão ao ver os dados organizados em tabelas?**

2. **Por que você acha que bancos de dados profissionais usam esse formato?**

3. **Quais vantagens você identifica em ter dados estruturados dessa forma versus dados soltos em arquivos de texto?**

4. **Como você imagina que aplicativos (sites, apps) acessam esses dados?**

5. **O que você ainda gostaria de saber sobre bancos de dados?**

---

## 💭 Reflexão Final

Escreva um parágrafo resumindo sua experiência:

**O que eu aprendi hoje sobre bancos de dados:**

_____________________________________________
_____________________________________________
_____________________________________________
_____________________________________________
_____________________________________________

---

## 📌 Próximos Passos

Na próxima aula você vai aprender:

- ✅ Como criar seu próprio schema
- ✅ Como criar tabelas
- ✅ Seus primeiros comandos SQL
- ✅ Como inserir dados

> 💡 *"Hoje você observou. Em breve, você será o criador."*

---

## 🆘 Problemas Comuns e Soluções

**Problema:** Não consigo conectar ao MySQL  
**Solução:** Verifique se o MySQL está rodando. Vá em Serviços do Windows e procure por "MySQL80" (ou sua versão).

**Problema:** Não vejo nenhum schema além dos de sistema  
**Solução:** Tudo bem! Use o schema `mysql` ou `information_schema` para praticar.

**Problema:** A visualização de dados não aparece  
**Solução:** Clique com o botão direito na tabela novamente e escolha "Select Rows - Limit 1000".

**Problema:** Aparece muita informação técnica que não entendo  
**Solução:** Normal! Foque apenas em observar linhas, colunas e valores. O resto virá com o tempo.
