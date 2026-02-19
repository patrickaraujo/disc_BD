# 🧠 Atividade 1 — Identificando Papéis, Níveis e Responsabilidades

> **Duração:** 20 minutos  
> **Formato:** Individual ou em duplas  
> **Objetivo:** Consolidar a compreensão sobre arquitetura de BD e papéis profissionais

---

## 📋 Parte 1 — Classificando por Nível de Arquitetura

Para cada situação, identifique o nível de arquitetura correspondente:
- **(E)** Nível Externo
- **(C)** Nível Conceitual
- **(I)** Nível Interno

| # | Situação | Nível |
|---|----------|-------|
| 1 | Um aluno visualiza apenas suas notas no portal acadêmico | |
| 2 | O DBA muda o índice de B-tree para Hash em uma tabela | |
| 3 | Um diagrama mostra todas as tabelas e relacionamentos do BD | |
| 4 | Professor vê apenas as turmas que leciona | |
| 5 | DBA decide particionar a tabela de vendas por ano | |
| 6 | Analista define que Pedido se relaciona com Cliente | |
| 7 | Sistema de RH mostra apenas salários para gerentes | |
| 8 | DBA otimiza o tamanho dos blocos de armazenamento | |
| 9 | Cliente vê histórico de compras em um e-commerce | |
| 10 | Modelador cria diagrama ER com todas as entidades | |

---

## 📋 Parte 2 — Identificando Papéis Profissionais

Para cada tarefa, identifique quem deve realizá-la:
- **(DBA)** Administrador de BD
- **(AN)** Analista de Dados
- **(DEV)** Desenvolvedor
- **(USR)** Usuário Final

| # | Tarefa | Papel |
|---|--------|-------|
| 1 | Fazer backup diário do banco de dados | |
| 2 | Cadastrar novo cliente no sistema | |
| 3 | Criar diagrama de entidade-relacionamento | |
| 4 | Escrever consulta SQL para relatório | |
| 5 | Definir política de senhas do SGBD | |
| 6 | Consultar vendas do mês no painel gerencial | |
| 7 | Identificar entidades do negócio | |
| 8 | Otimizar query que está lenta | |
| 9 | Criar usuário e definir permissões | |
| 10 | Normalizar estrutura de dados | |
| 11 | Desenvolver API REST que acessa o BD | |
| 12 | Aplicar patch de segurança no MySQL | |
| 13 | Filtrar pedidos por status na tela | |
| 14 | Definir cardinalidade entre entidades | |
| 15 | Monitorar consumo de memória do SGBD | |

---

## 📋 Parte 3 — Cenários Reais

### Cenário 1: Sistema Bancário

**Situação:**  
Um banco precisa implementar um novo sistema de contas correntes.

**Tarefas:**

1. Quem deve identificar as entidades (Conta, Cliente, Transação)?  
   **Resposta:** _______________________

2. Quem decide usar índices para otimizar consultas de saldo?  
   **Resposta:** _______________________

3. Quem cria a tela onde o cliente consulta extrato?  
   **Resposta:** _______________________

4. Quem usa o sistema para transferir dinheiro entre contas?  
   **Resposta:** _______________________

5. Quem faz backup automático toda madrugada?  
   **Resposta:** _______________________

---

### Cenário 2: E-commerce

**Situação:**  
Uma loja online está expandindo e precisa melhorar seu BD.

**Identifique o papel responsável por cada ação:**

| Ação | Papel Responsável |
|------|-------------------|
| Modelar relacionamento entre Produto e Categoria | |
| Criar índice na coluna mais consultada | |
| Desenvolver carrinho de compras | |
| Fazer uma compra no site | |
| Restaurar BD após falha de hardware | |
| Definir que cada Pedido tem vários Itens | |
| Criar stored procedure para cálculo de frete | |
| Configurar replicação master-slave | |

---

## 📋 Parte 4 — Independência de Dados

### Verdadeiro ou Falso

Marque V ou F e corrija as falsas:

1. ( ) Independência física permite mudar a estrutura de armazenamento sem afetar as aplicações.

   **Correção:** _______________________________

2. ( ) Se o DBA trocar o tipo de índice, todos os desenvolvedores precisam reescrever suas consultas SQL.

   **Correção:** _______________________________

3. ( ) Independência lógica significa que posso adicionar uma nova tabela sem quebrar visões existentes.

   **Correção:** _______________________________

4. ( ) Usuários finais precisam saber como os dados estão fisicamente organizados no disco.

   **Correção:** _______________________________

5. ( ) A arquitetura em três níveis dificulta a manutenção do sistema.

   **Correção:** _______________________________

---

## 📋 Parte 5 — Mapeamento Papel × Nível

Complete a tabela:

| Papel | Nível(is) que atua | Principal responsabilidade |
|-------|--------------------|----------------------------|
| DBA | | |
| Analista | | |
| Desenvolvedor | | |
| Usuário Final | | |

---

## 📋 Parte 6 — Caso Completo

### 🏥 Sistema Hospitalar

**Contexto:**  
Um hospital vai implementar um sistema de prontuário eletrônico.

**Situações:**

1. **Maria é analista de dados.** O que ela deve fazer primeiro?

   a) ( ) Instalar o MySQL  
   b) ( ) Criar diagrama ER com entidades Paciente, Médico, Consulta  
   c) ( ) Escrever código SQL  
   d) ( ) Fazer backup do sistema  

---

2. **João é DBA.** Qual NÃO é responsabilidade dele?

   a) ( ) Configurar backup automático  
   b) ( ) Definir relacionamento entre tabelas  
   c) ( ) Criar usuários para médicos e enfermeiros  
   d) ( ) Otimizar índices para consultas rápidas  

---

3. **Ana é desenvolvedora.** O que ela faz?

   a) ( ) Só escreve SQL  
   b) ( ) Cria telas e integra com BD  
   c) ( ) Define estrutura física do banco  
   d) ( ) Usa o sistema para atender pacientes  

---

4. **Dr. Paulo é médico (usuário final).** Como ele interage com o BD?

   a) ( ) Escreve queries SQL  
   b) ( ) Acessa via interface gráfica do sistema  
   c) ( ) Configura permissões de acesso  
   d) ( ) Faz modelagem de dados  

---

## 📋 Parte 7 — Reflexão Crítica

### Questão 1
**Por que é importante ter diferentes papéis ao invés de uma pessoa fazer tudo?**

_____________________________________________
_____________________________________________
_____________________________________________

---

### Questão 2
**Explique com suas palavras o benefício da arquitetura em três níveis:**

_____________________________________________
_____________________________________________
_____________________________________________

---

### Questão 3
**Se você pudesse escolher um papel profissional agora, qual seria e por quê?**

**Papel escolhido:** _______________________

**Justificativa:**  
_____________________________________________
_____________________________________________

---

### Questão 4
**Dê um exemplo prático de independência física:**

_____________________________________________
_____________________________________________

---

### Questão 5
**Por que usuários finais não precisam saber SQL?**

_____________________________________________
_____________________________________________

---

## ✅ Gabarito de Referência

### Parte 1 — Níveis de Arquitetura

1. E (Externo)
2. I (Interno)
3. C (Conceitual)
4. E (Externo)
5. I (Interno)
6. C (Conceitual)
7. E (Externo)
8. I (Interno)
9. E (Externo)
10. C (Conceitual)

---

### Parte 2 — Papéis

1. DBA
2. USR
3. AN
4. DEV
5. DBA
6. USR
7. AN
8. DBA ou DEV
9. DBA
10. AN
11. DEV
12. DBA
13. USR
14. AN
15. DBA

---

### Parte 4 — Verdadeiro ou Falso

1. V
2. F — A independência física permite mudar índices sem afetar consultas
3. V
4. F — Usuários só veem suas visões, não precisam saber detalhes físicos
5. F — A arquitetura em três níveis facilita a manutenção

---

### Parte 6 — Caso Hospitalar

1. b
2. b (isso é responsabilidade do Analista)
3. b
4. b

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Distinguir os três níveis de arquitetura  
✅ Identificar responsabilidades de cada papel  
✅ Compreender independência de dados  
✅ Relacionar papéis com níveis de arquitetura  
✅ Aplicar conceitos em situações reais  

> 💡 *"A separação em papéis e níveis não é burocracia — é organização profissional que permite sistemas complexos funcionarem."*
