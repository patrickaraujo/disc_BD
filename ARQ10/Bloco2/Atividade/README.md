# 🧠 Atividade 2 — Praticando JOINs

> **Duração:** 20 minutos  
> **Formato:** Individual ou em duplas  
> **Objetivo:** Consolidar o entendimento dos tipos de JOIN e suas diferenças

---

## 📋 Parte 1 — Interpretação de Resultados

Considerando o estado atual do banco `familia02` (após o Bloco 1), responda **sem executar** as queries:

1. Quantas linhas retorna `SELECT * FROM filha, pai;` (sem WHERE)?

2. Quantas linhas retorna `SELECT * FROM filha INNER JOIN pai ON filha.parente_id = pai.id;`?

3. Quantas linhas retorna o `LEFT JOIN` de filha com pai?

4. Quantas linhas retorna o `RIGHT JOIN` de filha com pai?

5. No resultado do `RIGHT JOIN`, quais pais aparecem com `NULL` na coluna "Nome da Filha"?

---

## 📋 Parte 2 — Escrevendo Queries

Escreva as queries SQL para cada situação:

6. Liste o nome de cada filha e o nome do seu pai, usando a sintaxe `INNER JOIN ... ON`.

7. Liste **todas** as filhas (inclusive as sem pai vinculado), mostrando o nome da filha e o nome do pai (ou NULL). Qual tipo de JOIN você precisa?

8. Liste **todos** os pais (inclusive os sem filhos vinculados), mostrando o nome do pai e o nome da filha (ou NULL). Qual tipo de JOIN você precisa?

9. Liste o nome da filha, o nome do pai e a idade do pai, mas **somente** para pais com idade igual a 45.

10. Escreva uma query que traga **todos os registros de ambos os lados** (FULL JOIN). Lembre-se: MySQL não tem FULL JOIN nativo.

---

## 📋 Parte 3 — Análise Conceitual

11. Explique com suas palavras: qual é a diferença entre `ON` e `WHERE` em uma query com JOIN?

12. Por que o Produto Cartesiano é considerado um "erro comum"? Em que situação ele poderia ser útil?

13. Observe a query abaixo. O que acontece se executá-la? Justifique.

```sql
DELETE FROM pai WHERE id = 1;
SELECT * FROM filha;
```

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1. **42 linhas** — Produto Cartesiano: 6 filhas × 7 pais = 42.

2. **3 linhas** — Apenas Ana/João, Fabia/Maria e José/Pedro possuem `parente_id` preenchido.

3. **6 linhas** — Todas as 6 filhas aparecem. As 3 sem vínculo mostram NULL na coluna do pai.

4. **7 linhas** — Todos os 7 pais aparecem. Os 4 sem filhos vinculados mostram NULL na coluna da filha.

5. Manoel, Antônio, Sebastião e Evandro — pois nenhuma filha está vinculada a eles.

---

### Parte 2

6.
```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha INNER JOIN pai
ON filha.parente_id = pai.id;
```

7. **LEFT JOIN** — traz todas as filhas (esquerda), inclusive sem match:
```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha LEFT JOIN pai
ON filha.parente_id = pai.id;
```

8. **RIGHT JOIN** — traz todos os pais (direita), inclusive sem match:
```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha RIGHT JOIN pai
ON filha.parente_id = pai.id;
```

9.
```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai', pai.idade AS 'Idade do Pai'
FROM filha INNER JOIN pai
ON filha.parente_id = pai.id
WHERE pai.idade = 45;
```

10.
```sql
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha LEFT JOIN pai ON filha.parente_id = pai.id
UNION ALL
SELECT filha.nome AS 'Nome da Filha', pai.nome AS 'Nome do Pai'
FROM filha RIGHT JOIN pai ON filha.parente_id = pai.id;
```

---

### Parte 3

11. O `ON` define **como** as tabelas se conectam (condição de junção — qual campo da tabela A corresponde a qual campo da tabela B). O `WHERE` filtra o **resultado** da junção (ex: "somente pais com idade = 30"). São complementares: `ON` une, `WHERE` filtra.

12. É um erro comum porque iniciantes esquecem de colocar a condição de junção, e o MySQL combina cada linha de uma tabela com **todas** as linhas da outra, gerando resultados inflados e sem sentido. Em raríssimos casos pode ser útil — por exemplo, para gerar todas as combinações possíveis entre dois conjuntos pequenos (como combinar tamanhos × cores de um produto).

13. Como o `pai` com `id = 1` é João, e Ana (filha `id = 1`) está vinculada a ele via `parente_id = 1`, a exclusão de João ativará o **ON DELETE CASCADE**. Resultado: João é excluído da tabela `pai`, e Ana é **automaticamente excluída** da tabela `filha`. Nando (filha `id = 4`) também seria excluído se já tivesse sido vinculado ao `parente_id = 1`.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Prever o número de linhas de diferentes JOINs sem executar a query  
✅ Escolher o tipo de JOIN correto para cada necessidade  
✅ Distinguir `ON` (junção) de `WHERE` (filtro)  
✅ Compreender as consequências do CASCADE em exclusões

> 💡 *"Escolher o JOIN errado não dá erro de sintaxe — dá erro de resultado. O MySQL faz exatamente o que você pede, não o que você quer."*
