# 📘 Bloco 2 — Junções (JOINs) entre Tabelas

> **Duração estimada:** 50 minutos  
> **Objetivo:** Dominar os diferentes tipos de junção (JOIN) para consultar dados de múltiplas tabelas simultaneamente

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Identificar e evitar o Produto Cartesiano indevido
- Usar a cláusula `WHERE` para juntar tabelas corretamente
- Aplicar `INNER JOIN` com a cláusula `ON`
- Combinar `INNER JOIN` com filtros `WHERE`
- Usar `LEFT JOIN` e `RIGHT JOIN` para incluir registros sem correspondência
- Simular um `FULL JOIN` com `UNION ALL`
- Compreender a exclusão em cascata na prática
- Verificar a integridade referencial em tentativas de INSERT inválido

---

## 💡 Conceitos Fundamentais

### O que é uma Junção?

Quando os dados que você precisa estão espalhados em **duas ou mais tabelas**, é necessário juntá-las em uma única consulta. Essa operação chama-se **junção (JOIN)**.

```
Tabela FILHA          Tabela PAI
┌────┬──────────┐     ┌────┬───────────┬───────┐
│ id │ nome     │     │ id │ nome      │ idade │
├────┼──────────┤     ├────┼───────────┼───────┤
│ 1  │ Ana      │──→  │ 1  │ João      │ 30    │
│ 2  │ Fabia    │──→  │ 2  │ Maria     │ 45    │
│ 3  │ José     │──→  │ 3  │ Pedro     │ 30    │
│ 4  │ Nando    │     │ 4  │ Manoel    │ 50    │
│ 5  │ Fernanda │     │ 5  │ Antônio   │ 30    │
│ 6  │ Igor     │     │ 6  │ Sebastião │ 45    │
└────┴──────────┘     │ 7  │ Evandro   │ 29    │
                      └────┴───────────┴───────┘
```

A seta indica o vínculo via `parente_id` → `id`. Nando, Fernanda e Igor ainda não estão vinculados (parente_id = NULL).

---

### ❌ O Produto Cartesiano — O que NÃO fazer

```sql
SELECT * FROM filha, pai;
```

**Resultado:** Para cada registro da `filha`, o MySQL combina com **todos** os registros da `pai`. Com 6 filhas × 7 pais = **42 linhas** sem sentido!

Isso acontece porque não especificamos **como** as tabelas se relacionam. O MySQL, sem critério, combina tudo com tudo.

📌 **Regra de ouro:** Nunca liste duas tabelas no `FROM` sem uma condição de junção no `WHERE` ou `ON`.

---

### ✅ Junção Correta com WHERE

#### Exemplo 1 — Todas as colunas, junção via WHERE

```sql
SELECT * FROM filha, pai
WHERE filha.parente_id = pai.id;
```

Agora o MySQL retorna **apenas** os registros da `filha` que possuem um `pai` correspondente. Resultado: 3 linhas (Ana/João, Fabia/Maria, José/Pedro).

---

#### Exemplo 2 — Colunas específicas com alias

```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha, pai
WHERE filha.parente_id = pai.id;
```

| Nome da Filha | Nome do Pai |
|---------------|-------------|
| Ana           | João        |
| Fabia         | Maria       |
| José          | Pedro       |

📌 **Quando as colunas possuem o mesmo nome** (como `nome`), é obrigatório usar o prefixo da tabela (`filha.nome`, `pai.nome`). O `AS` cria um apelido (alias) para facilitar a leitura.

---

### 🔗 INNER JOIN — Junção Interna

O `INNER JOIN` faz exatamente o mesmo que a junção via `WHERE`, mas com sintaxe mais moderna e legível:

#### Exemplo 3 — INNER JOIN básico

```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha INNER JOIN pai
ON filha.parente_id = pai.id;
```

**Resultado idêntico ao Exemplo 2.** A diferença é apenas na sintaxe:
- `FROM filha, pai WHERE ...` → sintaxe antiga (implícita)
- `FROM filha INNER JOIN pai ON ...` → sintaxe moderna (explícita)

📌 **A cláusula `ON` substitui o `WHERE` para definir a condição de junção.** O `WHERE` fica livre para filtros adicionais.

---

#### Exemplo 4 — INNER JOIN com filtro WHERE

```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai', pai.idade AS 'Idade do Pai'
FROM filha INNER JOIN pai
ON filha.parente_id = pai.id
WHERE pai.idade = 30;
```

| Nome da Filha | Nome do Pai | Idade do Pai |
|---------------|-------------|--------------|
| Ana           | João        | 30           |
| José          | Pedro       | 30           |

📌 **O `ON` faz a junção. O `WHERE` filtra o resultado.** São coisas diferentes — não confunda!

---

### ◀️ LEFT JOIN — Todos da Esquerda

```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha LEFT JOIN pai
ON filha.parente_id = pai.id;
```

| Nome da Filha | Nome do Pai |
|---------------|-------------|
| Ana           | João        |
| Fabia         | Maria       |
| José          | Pedro       |
| Nando         | NULL        |
| Fernanda      | NULL        |
| Igor          | NULL        |

**O `LEFT JOIN` traz TODOS os registros da tabela da esquerda (`filha`)**, mesmo que não tenham correspondência na tabela da direita (`pai`). Onde não há match, aparece `NULL`.

---

### ▶️ RIGHT JOIN — Todos da Direita

```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha RIGHT JOIN pai
ON filha.parente_id = pai.id;
```

| Nome da Filha | Nome do Pai |
|---------------|-------------|
| Ana           | João        |
| Fabia         | Maria       |
| José          | Pedro       |
| NULL          | Manoel      |
| NULL          | Antônio     |
| NULL          | Sebastião   |
| NULL          | Evandro     |

**O `RIGHT JOIN` traz TODOS os registros da tabela da direita (`pai`)**, mesmo que não tenham filhos vinculados.

---

### ↔️ FULL JOIN — Todos de Ambos os Lados

O MySQL **não possui** `FULL JOIN` nativo. Simulamos com `UNION ALL`:

```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha LEFT JOIN pai ON filha.parente_id = pai.id
UNION ALL
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha RIGHT JOIN pai ON filha.parente_id = pai.id;
```

Esse comando combina o resultado do `LEFT JOIN` com o `RIGHT JOIN`, trazendo **todos os registros de ambas as tabelas**.

---

### Resumo Visual dos JOINs

```
INNER JOIN      → Apenas os que combinam (interseção)
LEFT JOIN       → Todos da esquerda + combinações da direita (ou NULL)
RIGHT JOIN      → Todos da direita + combinações da esquerda (ou NULL)
FULL JOIN       → Todos de ambos os lados (simulado via UNION ALL)
```

---

### 🗑️ Demonstração: Exclusão em Cascata

Lembra do `ON DELETE CASCADE`? Vamos testá-lo:

```sql
-- Estado antes da exclusão
SELECT * FROM filha, pai WHERE filha.parente_id = pai.id;

-- Excluindo Maria (id = 2)
DELETE FROM pai WHERE id = 2;

-- Estado depois: Fabia sumiu da junção! (CASCADE)
SELECT * FROM filha, pai WHERE filha.parente_id = pai.id;

-- Desfazendo
ROLLBACK;
```

📌 Ao excluir Maria da tabela `pai`, **Fabia foi excluída automaticamente** da tabela `filha` porque estava vinculada via FK com CASCADE.

---

### 🛡️ Integridade Referencial — Tentativa de INSERT Inválido

```sql
-- Este funciona (parente_id = NULL é permitido)
INSERT INTO filha (id, nome, parente_id) VALUES (7, 'Margareth', NULL);

-- Este FALHA com erro 1452 (pai com id=10 não existe)
INSERT INTO filha (id, nome, parente_id) VALUES (8, 'Humberto', 10);
```

📌 A FK permite `NULL` (sem vínculo), mas **não permite apontar para um pai inexistente**.

---

## ✏️ Atividades Práticas

### 📝 Atividade 2 — Praticando JOINs

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Escrever consultas com diferentes tipos de JOIN
- Interpretar resultados de LEFT e RIGHT JOIN
- Identificar quando usar cada tipo de junção

---

## 📂 Código-fonte

O script SQL completo deste bloco está disponível em:

➡️ [codigo-fonte/COMANDOS-BD-01-bloco2.sql](./codigo-fonte/COMANDOS-BD-01-bloco2.sql)

---

## ✅ Resumo do Bloco 2

Neste bloco você aprendeu:

- Que o Produto Cartesiano combina **tudo com tudo** — sempre use uma condição de junção
- A juntar tabelas via `WHERE` (sintaxe antiga) e `INNER JOIN ... ON` (sintaxe moderna)
- Que `INNER JOIN` retorna apenas registros com correspondência em ambas as tabelas
- Que `LEFT JOIN` traz todos da esquerda (NULL onde não há match)
- Que `RIGHT JOIN` traz todos da direita (NULL onde não há match)
- A simular `FULL JOIN` com `UNION ALL`
- Que `ON DELETE CASCADE` propaga exclusões automaticamente
- Que a FK rejeita referências a registros inexistentes (erro 1452)

---

## 🎯 Conceitos-chave para fixar

💡 **Produto Cartesiano = FROM sem WHERE/ON → combina tudo com tudo → ERRADO**

💡 **INNER JOIN = só registros com match → interseção**

💡 **LEFT JOIN = todos da esquerda + match (ou NULL)**

💡 **ON = condição de junção | WHERE = filtro do resultado**

---

## ➡️ Próximos Passos

No Bloco 3 você vai aprender a extrair estatísticas com funções de agregação:

- `COUNT`, `MIN`, `MAX`, `AVG`, `SUM`
- `ORDER BY`, `GROUP BY`, `HAVING`
- `DISTINCT` e expressões aritméticas

Acesse: [📁 Bloco 3](../Bloco3/README.md)

---

> 💭 *"JOIN é a ponte entre tabelas. Sem ponte, cada tabela é uma ilha isolada."*
