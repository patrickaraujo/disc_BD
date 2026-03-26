# 🧠 Atividade 4 — Filtros Avançados, Subqueries e Variáveis SQL

> **Duração:** 20 minutos  
> **Formato:** Individual ou em duplas  
> **Objetivo:** Consolidar o uso de LIKE, BETWEEN, IN, EXISTS, variáveis SQL e GROUP_CONCAT

---

## 📋 Parte 1 — LIKE (Padrões de Texto)

Escreva as queries SQL para cada situação:

1. Liste todos os pais cujo nome **começa** com a letra "M".

2. Liste todos os pais cujo nome **termina** com a letra "o".

3. Liste todos os pais cujo nome **contém** a sequência "eb".

4. Liste todos os pais cujo nome **NÃO contém** a letra "a".

---

## 📋 Parte 2 — BETWEEN e IN

5. Liste os pais com idade **entre 30 e 45 anos** (inclusive), ordenados por idade.

6. Liste os pais com idade **estritamente entre 30 e 45** (sem incluir 30 e 45), ordenados por idade.

7. Liste os pais cujo nome **está** na seguinte lista: 'João', 'Pedro', 'Evandro'.

8. Liste os pais cujo nome **NÃO está** na lista: 'João', 'Pedro', 'Evandro'.

---

## 📋 Parte 3 — EXISTS e Subqueries

9. Escreva uma query que liste as filhas que **possuem** um pai vinculado, usando `EXISTS`.

10. Escreva uma query que liste as filhas que **NÃO possuem** um pai vinculado, usando `NOT EXISTS`.

11. Reescreva a query da questão 9 usando `IS NOT NULL` em vez de `EXISTS`. Compare a legibilidade.

---

## 📋 Parte 4 — Variáveis e GROUP_CONCAT

12. Usando variáveis SQL, escreva um script que vincule Igor (id = 6) ao pai Sebastião (id = 6). Use `SET @var` para definir os valores.

13. Após vincular Igor, escreva uma query com `GROUP_CONCAT` que mostre cada pai e a lista de seus filhos separada por vírgula.

14. Escreva uma query que mostre **quantos filhos** cada pai tem E a **lista de nomes** dos filhos na mesma linha.

---

## 📋 Parte 5 — Desafio Integrado

15. Sem executar, analise a query abaixo e preveja o resultado:

```sql
SELECT pai.nome, COUNT(filha.id) AS total_filhos,
       GROUP_CONCAT(filha.nome ORDER BY filha.nome SEPARATOR ', ') AS filhos
FROM pai LEFT JOIN filha ON pai.id = filha.parente_id
GROUP BY pai.nome
HAVING total_filhos > 0
ORDER BY total_filhos DESC;
```

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1.
```sql
SELECT * FROM pai WHERE nome LIKE 'M%';
```
Resultado: Maria e Manoel.

2.
```sql
SELECT * FROM pai WHERE nome LIKE '%o';
```
Resultado: nenhum (nenhum nome termina com "o" minúsculo exatamente — porém com collation `ci`, depende da configuração). Se não encontrar, teste `'%o'` vs `'%O'`.

3.
```sql
SELECT * FROM pai WHERE nome LIKE '%eb%';
```
Resultado: Sebastião (contém "eb").

4.
```sql
SELECT * FROM pai WHERE nome NOT LIKE '%a%';
```
Resultado: Pedro (os demais possuem "a" — lembre que `ci` ignora caso: João → "ão" contém "a").

---

### Parte 2

5.
```sql
SELECT * FROM pai WHERE idade BETWEEN 30 AND 45 ORDER BY idade;
```
Resultado: João (30), Pedro (30), Antônio (30), Maria (45), Sebastião (45).

6.
```sql
SELECT * FROM pai WHERE idade > 30 AND idade < 45 ORDER BY idade;
```
Resultado: **nenhum registro** (não há ninguém com idade entre 31 e 44).

7.
```sql
SELECT * FROM pai WHERE nome IN ('João', 'Pedro', 'Evandro');
```

8.
```sql
SELECT * FROM pai WHERE nome NOT IN ('João', 'Pedro', 'Evandro');
```

---

### Parte 3

9.
```sql
SELECT filha.id, filha.nome FROM filha
WHERE EXISTS (
  SELECT pai.id FROM pai WHERE pai.id = filha.parente_id
);
```

10.
```sql
SELECT filha.id, filha.nome FROM filha
WHERE NOT EXISTS (
  SELECT pai.id FROM pai WHERE pai.id = filha.parente_id
);
```

11.
```sql
SELECT filha.id, filha.nome FROM filha
WHERE parente_id IS NOT NULL;
```
A versão com `IS NOT NULL` é mais simples e legível. O `EXISTS` é mais poderoso em cenários complexos onde a verificação envolve condições compostas na subquery.

---

### Parte 4

12.
```sql
SET @chave_filha = 6;
SET @chave_pai = 6;

UPDATE filha
SET parente_id = @chave_pai
WHERE id = @chave_filha;
```

13.
```sql
SELECT pai.nome, GROUP_CONCAT(filha.nome SEPARATOR ', ') AS 'Filhos'
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY pai.nome;
```

14.
```sql
SELECT pai.nome,
       COUNT(*) AS 'Quantidade',
       GROUP_CONCAT(filha.nome SEPARATOR ', ') AS 'Lista de Filhos'
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY pai.nome;
```

---

### Parte 5

15. A query usa `LEFT JOIN` (todos os pais), depois agrupa por nome com `GROUP BY`. O `COUNT(filha.id)` conta corretamente (ignora NULL). O `GROUP_CONCAT` lista os filhos **em ordem alfabética** separados por vírgula. O `HAVING total_filhos > 0` exclui pais sem filhos do resultado. O `ORDER BY total_filhos DESC` mostra primeiro quem tem mais filhos. Resultado esperado (com Igor vinculado a Sebastião):

| nome      | total_filhos | filhos          |
|-----------|--------------|-----------------|
| João      | 2            | Ana, Nando      |
| Evandro   | 1            | Fernanda        |
| Maria     | 1            | Fabia           |
| Pedro     | 1            | José            |
| Sebastião | 1            | Igor            |

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Filtrar textos com LIKE usando curingas `%` e `_`  
✅ Usar BETWEEN para intervalos e IN para listas  
✅ Construir subqueries com EXISTS / NOT EXISTS  
✅ Parametrizar queries com variáveis SQL  
✅ Concatenar resultados agrupados com GROUP_CONCAT

> 💡 *"Quanto mais ferramentas de filtro você domina, perguntas mais inteligentes consegue fazer ao banco de dados."*
