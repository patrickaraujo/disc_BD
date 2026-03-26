# 🧠 Atividade 3 — Funções de Agregação na Prática

> **Duração:** 20 minutos  
> **Formato:** Individual ou em duplas  
> **Objetivo:** Consolidar o uso de funções de agregação, agrupamento e ordenação

---

## 📋 Parte 1 — Escrevendo Queries de Agregação

Considerando o estado atual do banco `familia02` (7 pais, filhas vinculadas), escreva as queries SQL:

1. Conte quantos pais possuem idade **maior ou igual a 30**.

2. Liste todas as idades distintas da tabela `pai`, ordenadas do menor para o maior.

3. Calcule a média de idade dos pais e exiba arredondada.

4. Encontre a diferença entre a maior e a menor idade (use `MAX` e `MIN` na mesma query).

5. Liste todos os pais em ordem alfabética (por nome).

---

## 📋 Parte 2 — GROUP BY e HAVING

6. Conte quantos pais existem em cada faixa de idade. Ordene pelo número de pais (descendente).

7. Usando a mesma query da questão 6, filtre para mostrar **apenas as idades que possuem mais de 1 pai**.

8. Liste o nome de cada pai e a quantidade de filhos, **somente para pais que possuem pelo menos 1 filho**.

9. Qual é a diferença entre as duas queries abaixo? Qual é o resultado de cada uma?

```sql
-- Query A
SELECT COUNT(*) FROM pai WHERE idade = 30;

-- Query B
SELECT idade, COUNT(*) FROM pai GROUP BY idade HAVING idade = 30;
```

---

## 📋 Parte 3 — Expressões e NULL

10. Escreva uma query que mostre o nome, a idade atual e a idade daqui a **5 anos** para todos os pais, ordenados do mais velho para o mais novo.

11. Escreva uma query que liste **apenas as filhas que NÃO possuem pai vinculado**.

12. Escreva uma query que conte quantas filhas **possuem** pai vinculado e quantas **não possuem** (dica: use duas queries separadas ou `COUNT` com `CASE`).

---

## 📋 Parte 4 — Desafio

13. Sem executar, preveja o resultado desta query e justifique:

```sql
SELECT pai.nome, COUNT(*) AS filhos
FROM pai LEFT JOIN filha ON pai.id = filha.parente_id
GROUP BY pai.nome
ORDER BY filhos DESC;
```

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1.
```sql
SELECT COUNT(*) FROM pai WHERE idade >= 30;
```
Resultado: **6** (todos exceto Evandro com 29).

2.
```sql
SELECT DISTINCT idade FROM pai ORDER BY idade ASC;
```
Resultado: 29, 30, 45, 50.

3.
```sql
SELECT ROUND(AVG(idade)) AS 'Média Arredondada' FROM pai;
```

4.
```sql
SELECT (MAX(idade) - MIN(idade)) AS 'Diferença' FROM pai;
```
Resultado: **21** (50 - 29).

5.
```sql
SELECT * FROM pai ORDER BY nome ASC;
```

---

### Parte 2

6.
```sql
SELECT idade, COUNT(*) AS quantidade
FROM pai
GROUP BY idade
ORDER BY quantidade DESC;
```

7.
```sql
SELECT idade, COUNT(*) AS quantidade
FROM pai
GROUP BY idade
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;
```
Resultado: idade 30 (3 pais) e idade 45 (2 pais).

8.
```sql
SELECT pai.nome, COUNT(*) AS Quantidade_Filhos
FROM pai, filha
WHERE pai.id = filha.parente_id
GROUP BY pai.nome;
```

9. Ambas retornam a contagem de pais com idade 30, mas por caminhos diferentes. A **Query A** usa `WHERE` para filtrar linhas **antes** de contar — resultado: um número (3). A **Query B** agrupa por idade, depois usa `HAVING` para filtrar o grupo 30 — resultado: uma linha com idade = 30 e COUNT = 3. O resultado numérico é o mesmo, mas a Query B mostra a coluna `idade` junto.

---

### Parte 3

10.
```sql
SELECT nome, idade AS 'Idade atual', (idade + 5) AS 'Idade em 5 anos'
FROM pai
ORDER BY idade DESC;
```

11.
```sql
SELECT id, nome FROM filha WHERE parente_id IS NULL;
```

12. Com duas queries:
```sql
SELECT COUNT(*) AS 'Com pai' FROM filha WHERE parente_id IS NOT NULL;
SELECT COUNT(*) AS 'Sem pai' FROM filha WHERE parente_id IS NULL;
```

---

### Parte 4

13. O `LEFT JOIN` traz **todos** os pais, inclusive os sem filhos. Porém, o `COUNT(*)` conta linhas (não registros de filha), então pais sem filhos aparecem com `filhos = 1` (a própria linha com NULL). Para contar corretamente, seria necessário usar `COUNT(filha.id)` em vez de `COUNT(*)`. O resultado mostra todos os 7 pais, mas a contagem está inflada para os sem filhos.

**Query corrigida:**
```sql
SELECT pai.nome, COUNT(filha.id) AS filhos
FROM pai LEFT JOIN filha ON pai.id = filha.parente_id
GROUP BY pai.nome
ORDER BY filhos DESC;
```

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Usar funções de agregação para extrair estatísticas  
✅ Combinar GROUP BY com HAVING para filtrar grupos  
✅ Criar expressões aritméticas em consultas  
✅ Distinguir COUNT(*) de COUNT(coluna) em contextos com NULL

> 💡 *"COUNT(*) conta linhas. COUNT(coluna) conta valores. Em queries com JOIN, essa diferença muda tudo."*
