# 📘 Bloco 3 — Funções de Agregação e Ordenação

> **Duração estimada:** 50 minutos  
> **Objetivo:** Dominar as funções de agregação (COUNT, MIN, MAX, AVG, SUM) e os recursos de ordenação, agrupamento e filtragem de grupos

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Contar registros com `COUNT` (total e filtrado)
- Ordenar resultados com `ORDER BY` (ASC e DESC)
- Agrupar resultados com `GROUP BY`
- Filtrar grupos com `HAVING`
- Eliminar duplicatas com `DISTINCT`
- Usar `MIN`, `MAX`, `AVG`, `SUM` e `ROUND`
- Criar expressões aritméticas em consultas
- Verificar registros com `IS NULL` e `IS NOT NULL`
- Contar filhos por pai usando JOIN + GROUP BY

---

## 💡 Conceitos Fundamentais

### O que são Funções de Agregação?

Funções de agregação processam um **conjunto de valores** e retornam um **único resultado**. São essenciais para relatórios e análises.

| Função | O que faz | Exemplo |
|--------|-----------|---------|
| `COUNT(*)` | Conta o número de registros | Quantos pais existem? |
| `MIN(col)` | Retorna o menor valor | Qual a menor idade? |
| `MAX(col)` | Retorna o maior valor | Qual a maior idade? |
| `AVG(col)` | Calcula a média | Qual a idade média? |
| `SUM(col)` | Soma todos os valores | Qual a soma das idades? |
| `ROUND(val)` | Arredonda um valor | Idade média arredondada? |

---

### COUNT — Contando Registros

#### Contagem total

```sql
SELECT COUNT(*) AS 'Total de Pais' FROM pai;
SELECT COUNT(*) AS 'Total de Filhas' FROM filha;
```

#### Contagem com filtro

```sql
-- Quantos pais têm 30 anos?
SELECT COUNT(*) FROM pai WHERE idade = 30;
```

Resultado: **3** (João, Pedro, Antônio)

```sql
-- Quantos pais têm menos de 45 anos?
SELECT COUNT(*) FROM pai WHERE idade < 45;

-- Quantos pais têm 45 anos ou menos?
SELECT COUNT(*) FROM pai WHERE idade <= 45;
```

📌 **`COUNT(*)` conta todas as linhas.** Se usar `COUNT(coluna)`, conta apenas as linhas onde a coluna **não é NULL**.

---

### ORDER BY — Ordenando Resultados

```sql
-- Do mais novo para o mais velho (ascendente)
SELECT * FROM pai ORDER BY idade ASC;

-- Do mais velho para o mais novo (descendente)
SELECT * FROM pai ORDER BY idade DESC;
```

📌 **`ASC` é o padrão** — se omitir, o MySQL ordena em ordem crescente.

---

### GROUP BY — Agrupando Registros

O `GROUP BY` reúne registros com o mesmo valor em grupos e permite aplicar funções de agregação em cada grupo.

```sql
-- Quantos pais existem em cada faixa de idade?
SELECT idade, COUNT(*) AS quantidade FROM pai GROUP BY idade;
```

| idade | quantidade |
|-------|------------|
| 29    | 1          |
| 30    | 3          |
| 45    | 2          |
| 50    | 1          |

```sql
-- Mesma consulta, ordenada por quantidade (ascendente)
SELECT idade, COUNT(*) AS quantidade FROM pai
GROUP BY idade
ORDER BY (2) ASC;
```

📌 **`ORDER BY (2)`** ordena pela segunda coluna do resultado (a contagem). Pode usar `ORDER BY quantidade` também.

---

### DISTINCT — Eliminando Duplicatas

```sql
-- Quantas idades distintas existem?
SELECT COUNT(DISTINCT idade) FROM pai;
```

Resultado: **4** (29, 30, 45, 50)

```sql
-- Quais são as idades distintas?
SELECT DISTINCT idade FROM pai;
```

---

### Contando Filhos por Pai (JOIN + GROUP BY)

```sql
-- Verificando o estado atual
SELECT * FROM filha, pai WHERE filha.parente_id = pai.id;

-- Quantos filhos cada pai tem?
SELECT pai.nome, COUNT(*) AS Quantidade_Filhos
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY filha.parente_id;
```

| nome  | Quantidade_Filhos |
|-------|-------------------|
| João  | 1                 |
| Maria | 1                 |
| Pedro | 1                 |

Agora, vinculamos mais um registro:

```sql
UPDATE filha SET parente_id = 1 WHERE id = 4;
COMMIT;
```

Executando novamente a contagem:

| nome  | Quantidade_Filhos |
|-------|-------------------|
| João  | 2                 |
| Maria | 1                 |
| Pedro | 1                 |

📌 **João agora tem 2 filhos** (Ana e Nando).

---

### HAVING — Filtrando Grupos

O `HAVING` filtra o resultado **após o agrupamento** — é o "WHERE do GROUP BY".

```sql
-- Somente pais com MAIS de 1 filho
SELECT pai.nome, COUNT(*) AS Quantidade_Filhos
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY filha.parente_id
HAVING COUNT(*) > 1;
```

| nome | Quantidade_Filhos |
|------|-------------------|
| João | 2                 |

📌 **`WHERE` filtra linhas ANTES do agrupamento. `HAVING` filtra grupos DEPOIS.**

```
WHERE  → filtra LINHAS individuais     → antes do GROUP BY
HAVING → filtra GRUPOS de resultados   → depois do GROUP BY
```

---

### Expressões Aritméticas em Consultas

```sql
-- Pais com 45 anos: idade atual e idade no próximo ano
SELECT nome, idade AS 'Idade atual', (idade + 1) AS 'Idade no próximo ano'
FROM pai
WHERE idade = 45;
```

| nome      | Idade atual | Idade no próximo ano |
|-----------|-------------|----------------------|
| Maria     | 45          | 46                   |
| Sebastião | 45          | 46                   |

```sql
-- Todos os pais, do mais novo ao mais velho, com projeção de idade
SELECT nome, idade AS 'Idade atual', (idade + 1) AS 'Idade no próximo ano'
FROM pai
ORDER BY idade ASC;
```

📌 **Você pode usar operadores aritméticos** (`+`, `-`, `*`, `/`) em qualquer coluna numérica dentro do SELECT.

---

### IS NULL e IS NOT NULL

```sql
-- Filhas SEM pai vinculado
SELECT id, nome, parente_id FROM filha WHERE parente_id IS NULL;

-- Filhas COM pai vinculado
SELECT id, nome, parente_id FROM filha WHERE parente_id IS NOT NULL;
```

📌 **Nunca use `= NULL` ou `!= NULL`!** O operador correto é `IS NULL` e `IS NOT NULL`.

---

### MIN, MAX, AVG, SUM e ROUND

```sql
-- Menor e maior idade
SELECT MIN(idade) AS 'Menor Idade' FROM pai;
SELECT MAX(idade) AS 'Maior Idade' FROM pai;

-- Tudo junto
SELECT MIN(idade) AS 'Menor', MAX(idade) AS 'Maior', AVG(idade) AS 'Média' FROM pai;

-- Média de idade
SELECT AVG(idade) AS Média_Idade FROM pai;

-- Média arredondada
SELECT ROUND(AVG(idade)) AS 'Média Arredondada' FROM pai;

-- Soma de todas as idades
SELECT SUM(idade) AS 'Total das Idades' FROM pai;
```

---

### Resumo: Ordem de Execução de uma Query

```
1. FROM       → Define as tabelas
2. WHERE      → Filtra linhas individuais
3. GROUP BY   → Agrupa os resultados
4. HAVING     → Filtra os grupos
5. SELECT     → Define as colunas de saída
6. ORDER BY   → Ordena o resultado final
```

Entender essa ordem ajuda a saber **onde** colocar cada cláusula e **por que** `HAVING` não pode ser substituído por `WHERE`.

---

## ✏️ Atividades Práticas

### 📝 Atividade 3 — Funções de Agregação

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Escrever queries com COUNT, MIN, MAX, AVG, SUM
- Usar GROUP BY e HAVING
- Criar expressões aritméticas e filtros com IS NULL

---

## 📂 Código-fonte

O script SQL completo deste bloco está disponível em:

➡️ [codigo-fonte/COMANDOS-BD-01-bloco3.sql](./codigo-fonte/COMANDOS-BD-01-bloco3.sql)

---

## ✅ Resumo do Bloco 3

Neste bloco você aprendeu:

- A contar registros com `COUNT(*)` e `COUNT(coluna)`
- A ordenar com `ORDER BY ASC` e `DESC`
- A agrupar com `GROUP BY` e contar por grupo
- A filtrar grupos com `HAVING` (o "WHERE do GROUP BY")
- A eliminar duplicatas com `DISTINCT`
- A usar `MIN`, `MAX`, `AVG`, `SUM` e `ROUND`
- A criar expressões aritméticas no SELECT
- A testar nulos com `IS NULL` / `IS NOT NULL`

---

## 🎯 Conceitos-chave para fixar

💡 **WHERE filtra LINHAS → HAVING filtra GRUPOS**

💡 **IS NULL ≠ = NULL → nunca use `= NULL`**

💡 **COUNT(*) conta tudo | COUNT(coluna) ignora NULLs**

💡 **ORDER BY (2) = ordena pela segunda coluna do resultado**

---

## ➡️ Próximos Passos

No Bloco 4 você vai aprender filtros avançados e subqueries:

- `LIKE`, `BETWEEN`, `IN` / `NOT IN`
- `EXISTS` / `NOT EXISTS`
- `TRUNCATE`
- Variáveis SQL e `GROUP_CONCAT`

Acesse: [📁 Bloco 4](../Bloco4/README.md)

---

> 💭 *"Funções de agregação transformam dados brutos em informação. O GROUP BY é o mapa; o HAVING é o filtro."*
