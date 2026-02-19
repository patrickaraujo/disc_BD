# 🧩 Entendendo a Chave Substituta (Surrogate Key)

## 1. O que é uma chave primária (PK)
Toda tabela precisa de uma **chave primária (Primary Key)** — é o campo (ou conjunto de campos) que **identifica unicamente cada linha** da tabela.

Exemplo:

| CPF | Nome         |
|-----|--------------|
| 123 | João Silva   |
| 456 | Maria Souza  |

Aqui, o **CPF** é naturalmente único, então pode ser a **PK**.

---

## 2. Quando não existe um campo naturalmente único
Agora imagine a tabela de **Cidades**:

| Cidade        | Estado |
|----------------|--------|
| Santos         | SP     |
| Campinas       | SP     |
| Santos         | BA     |

Percebe que **“Cidade”** sozinha **não é única**?  
Podem existir **nomes repetidos em estados diferentes**.  
Não há um campo que identifique *sozinho* cada cidade de forma segura.

---

## 3. Criando uma *chave substituta* (surrogate key)
Como não existe um campo natural que sirva de PK, criamos **um identificador artificial** — por exemplo:

| CodCidade | Cidade    | Estado |
|------------|------------|--------|
| 1          | Santos    | SP     |
| 2          | Campinas  | SP     |
| 3          | Santos    | BA     |

Esse campo `CodCidade` é uma **chave substituta** — também chamada **surrogate key** — porque:
- **Não vem dos dados reais**, e sim é **criada artificialmente**;  
- Serve apenas para **identificar cada linha** de forma única;  
- É **gerada automaticamente** (por exemplo, com `AUTO_INCREMENT` no MySQL).

---

## 4. Por que usar o `AUTO_INCREMENT`
O `AUTO_INCREMENT` faz o SGBD (no caso, o MySQL) **gerar automaticamente um número sequencial** para cada novo registro:

```sql
INSERT INTO cidade (Cidade, Estado_SiglaUF) VALUES ('Campinas', 'SP');
-- O MySQL cria automaticamente CodCidade = 2
