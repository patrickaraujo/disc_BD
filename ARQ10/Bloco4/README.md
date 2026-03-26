# 📘 Bloco 4 — Filtros Avançados, Subqueries e Variáveis SQL

> **Duração estimada:** 50 minutos  
> **Objetivo:** Dominar filtros de padrão, intervalos, listas, subqueries aninhadas, TRUNCATE, variáveis SQL e GROUP_CONCAT

---

## 🎯 O que você vai aprender neste bloco

Ao final deste bloco, você será capaz de:

- Filtrar textos por padrão com `LIKE` e `NOT LIKE`
- Filtrar intervalos numéricos com `BETWEEN`
- Filtrar por lista de valores com `IN` e `NOT IN`
- Usar subqueries com `EXISTS` e `NOT EXISTS`
- Entender a diferença entre `DELETE` e `TRUNCATE`
- Trabalhar com variáveis SQL (`SET @var`)
- Concatenar resultados agrupados com `GROUP_CONCAT`

---

## 💡 Conceitos Fundamentais

### LIKE — Filtro por Padrão de Texto

O `LIKE` permite buscar registros onde um campo de texto **segue um padrão**. Usa dois curingas:

| Curinga | Significado | Exemplo |
|---------|-------------|---------|
| `%` | Qualquer sequência de caracteres (inclusive vazia) | `'J%'` = começa com J |
| `_` | Exatamente um caractere | `'_oão'` = 4 letras, terminando em "oão" |

#### Exemplos práticos

```sql
-- Nomes que começam com "J"
SELECT * FROM pai WHERE nome LIKE 'J%';
```

| id | nome | idade |
|----|------|-------|
| 1  | João | 30    |

```sql
-- Nomes que NÃO começam com "J"
SELECT * FROM pai WHERE nome NOT LIKE 'J%';
```

```sql
-- Nomes que terminam com "l"
SELECT * FROM pai WHERE nome LIKE '%l';
```

| id | nome   | idade |
|----|--------|-------|
| 4  | Manoel | 50    |

```sql
-- Nomes que contêm "an" em qualquer posição
SELECT * FROM pai WHERE nome LIKE '%an%';
```

| id | nome    | idade |
|----|---------|-------|
| 7  | Evandro | 29    |

📌 **`LIKE` é case insensitive** no MySQL com `utf8_general_ci` (nosso collation). Então `'j%'` e `'J%'` trazem o mesmo resultado.

---

### BETWEEN — Filtro por Intervalo

O `BETWEEN` seleciona valores dentro de um intervalo **inclusivo** (inclui os extremos).

```sql
-- Pais com idade entre 45 e 50 (inclusive)
SELECT * FROM pai
WHERE idade BETWEEN 45 AND 50
ORDER BY idade;
```

| id | nome      | idade |
|----|-----------|-------|
| 2  | Maria     | 45    |
| 6  | Sebastião | 45    |
| 4  | Manoel    | 50    |

A query acima é equivalente a:

```sql
SELECT * FROM pai
WHERE idade >= 45 AND idade <= 50
ORDER BY idade;
```

Para **excluir** os extremos, use `>` e `<`:

```sql
-- Idade entre 46 e 49 (exclusive nos limites)
SELECT * FROM pai
WHERE idade > 45 AND idade < 50
ORDER BY idade;
```

Resultado: **nenhum registro** (não há ninguém com idade entre 46 e 49).

```sql
-- Outro exemplo: idades entre 29 (exclusive) e 45 (exclusive)
SELECT * FROM pai
WHERE idade > 29 AND idade < 45
ORDER BY idade;
```

| id | nome    | idade |
|----|---------|-------|
| 1  | João    | 30    |
| 3  | Pedro   | 30    |
| 5  | Antônio | 30    |

---

### IN e NOT IN — Filtro por Lista

O `IN` verifica se o valor está **dentro de uma lista** de valores fornecidos.

```sql
-- Pais cujo nome está na lista
SELECT * FROM pai
WHERE nome IN ('rubens', 'joao', 'pedro', 'sebastião', 'jorge', 'Humberto');
```

```sql
-- Pais cujo nome NÃO está na lista
SELECT * FROM pai
WHERE nome NOT IN ('rubens', 'joao', 'pedro', 'sebastião', 'jorge', 'Humberto');
```

📌 **Atenção:** O `IN` compara os valores exatamente como estão. Com collation `ci` (case insensitive), `'joao'` pode encontrar `'João'` dependendo da acentuação configurada.

---

### EXISTS e NOT EXISTS — Subqueries

Subqueries (queries aninhadas) permitem usar o resultado de uma consulta como filtro de outra. O `EXISTS` retorna `TRUE` se a subquery encontrar **pelo menos um registro**.

#### Pais que POSSUEM filhos vinculados

```sql
SELECT pai.id, pai.nome FROM pai
WHERE EXISTS (
  SELECT filha.parente_id FROM filha
  WHERE filha.parente_id = pai.id
);
```

| id | nome  |
|----|-------|
| 1  | João  |
| 2  | Maria |
| 3  | Pedro |

📌 **Como funciona:** Para cada linha da tabela `pai`, o MySQL executa a subquery verificando se existe **alguma filha** com `parente_id` igual ao `id` daquele pai. Se existir → inclui no resultado.

---

#### Pais que NÃO POSSUEM filhos vinculados

```sql
SELECT pai.id, pai.nome FROM pai
WHERE NOT EXISTS (
  SELECT filha.parente_id FROM filha
  WHERE filha.parente_id = pai.id
);
```

| id | nome      |
|----|-----------|
| 4  | Manoel    |
| 5  | Antônio   |
| 6  | Sebastião |
| 7  | Evandro   |

---

#### ⚠️ Cuidado com EXISTS + INNER JOIN

```sql
-- ESTA QUERY NÃO TRAZ RESULTADO!
SELECT pai.id, pai.nome FROM pai INNER JOIN filha
ON filha.parente_id = pai.id
WHERE NOT EXISTS (SELECT filha.parente_id FROM filha);
```

**Por quê?** O `INNER JOIN` já filtra os pais que possuem filhos. Depois, o `NOT EXISTS` verifica se a tabela filha está vazia (o que não está). Resultado: nenhum registro. Essa combinação não faz sentido lógico.

📌 **Regra prática:** Para buscar registros **sem correspondência**, use `NOT EXISTS` **sem** INNER JOIN. Use a subquery correlacionada diretamente.

---

### TRUNCATE — Exclusão Física Sem Volta

O `TRUNCATE` exclui **todos os registros** de uma tabela de forma irreversível (sem possibilidade de ROLLBACK). Também reinicia sequências de `AUTO_INCREMENT`.

```sql
-- FALHA: tabela pai tem FK referenciada pela filha (erro 1701)
TRUNCATE TABLE pai;

-- FUNCIONA: nenhuma tabela depende de filha
TRUNCATE TABLE filha;
```

📌 **Diferença entre DELETE e TRUNCATE:**

| Característica | `DELETE` | `TRUNCATE` |
|----------------|----------|------------|
| Pode ter WHERE | Sim | Não (apaga tudo) |
| ROLLBACK possível | Sim (antes do COMMIT) | Não |
| AUTO_INCREMENT | Continua de onde parou | Reinicia do zero |
| Respeita FK | Sim (CASCADE) | Não permite se há FK apontando |
| Velocidade | Mais lento | Mais rápido |

Após o TRUNCATE, reinserimos os dados:

```sql
INSERT INTO filha (id, nome, parente_id)
VALUES (1, 'Ana', 1), (2, 'Fabia', 2), (3, 'José', 3),
       (4, 'Nando', 1), (5, 'Fernanda', NULL), (6, 'Igor', NULL);
```

---

### Variáveis SQL — Parametrizando Queries

Até agora, nossas queries usavam valores fixos ("hardcoded"). Com variáveis, podemos tornar as queries dinâmicas.

```sql
-- Definindo variáveis
SET @chave_filha = 5;
SET @chave_pai = 7;

-- Usando variáveis em um UPDATE
UPDATE filha
SET parente_id = @chave_pai
WHERE id = @chave_filha;
```

Esse comando vincula Fernanda (id = 5) ao pai Evandro (id = 7).

```sql
SELECT * FROM filha;
```

📌 **Variáveis SQL no MySQL começam com `@`.** Elas existem apenas na sessão atual e são úteis para parametrizar operações repetitivas.

---

### GROUP_CONCAT — Concatenando Valores Agrupados

O `GROUP_CONCAT` junta múltiplos valores de um grupo em uma única string, separados por um delimitador.

```sql
SELECT pai.nome, GROUP_CONCAT(filha.nome SEPARATOR ' | ') AS 'Nome dos Filhos'
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY pai.nome;
```

| nome    | Nome dos Filhos |
|---------|-----------------|
| Evandro | Fernanda        |
| João    | Ana \| Nando    |
| Maria   | Fabia           |
| Pedro   | José            |

📌 **Muito útil em relatórios** onde você quer ver todos os itens de um grupo em uma única linha. O `SEPARATOR` define o caractere de separação (padrão: vírgula).

---

## ✏️ Atividades Práticas

### 📝 Atividade 4 — Filtros Avançados e Subqueries

Acesse a atividade completa em: [📁 Atividade/README.md](./Atividade/README.md)

**Resumo da atividade:**
- Escrever queries com LIKE, BETWEEN, IN
- Usar EXISTS e NOT EXISTS com subqueries
- Trabalhar com variáveis SQL
- Aplicar GROUP_CONCAT

---

## 📂 Código-fonte

O script SQL completo deste bloco está disponível em:

➡️ [codigo-fonte/COMANDOS-BD-01-bloco4.sql](./codigo-fonte/COMANDOS-BD-01-bloco4.sql)

---

## ✅ Resumo do Bloco 4

Neste bloco você aprendeu:

- A buscar padrões em texto com `LIKE` (`%` = qualquer sequência, `_` = um caractere)
- A filtrar intervalos com `BETWEEN` (inclusivo) e `>` / `<` (exclusivo)
- A verificar se valores estão em uma lista com `IN` / `NOT IN`
- A usar subqueries com `EXISTS` e `NOT EXISTS` para verificar a existência de registros relacionados
- A diferença entre `DELETE` (reversível, seletivo) e `TRUNCATE` (irreversível, total)
- A parametrizar queries com variáveis SQL (`SET @var`)
- A concatenar valores agrupados com `GROUP_CONCAT`

---

## 🎯 Conceitos-chave para fixar

💡 **LIKE '%texto%' = contém | 'texto%' = começa com | '%texto' = termina com**

💡 **BETWEEN inclui os extremos (>=  e <=)**

💡 **EXISTS verifica existência — NOT EXISTS verifica ausência**

💡 **TRUNCATE = DELETE sem volta + reinicia AUTO_INCREMENT**

💡 **@variavel = parametrização dentro da sessão SQL**

---

## 🏁 Conclusão da Aula ARQ10

Parabéns! Ao completar os 4 blocos desta aula, você agora domina os principais recursos do comando `SELECT`:

```
Bloco 1 → Preparação do ambiente (CREATE, INSERT, FK, COMMIT/ROLLBACK)
Bloco 2 → Junções (INNER, LEFT, RIGHT, FULL JOIN)
Bloco 3 → Agregação (COUNT, MIN, MAX, AVG, SUM, GROUP BY, HAVING)
Bloco 4 → Filtros avançados (LIKE, BETWEEN, IN, EXISTS, variáveis, GROUP_CONCAT)
```

Esses são os fundamentos que serão usados em **todas as próximas aulas** de SQL.

---

> 💭 *"SQL é como falar com o banco de dados. Quanto mais vocabulário você tem, perguntas melhores consegue fazer."*
