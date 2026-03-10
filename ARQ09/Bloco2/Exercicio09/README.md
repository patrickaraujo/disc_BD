# 📝 Exercício 09 — INSERT e UPDATE na Tabela Cidade

> **Duração:** ~15 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Banco `imobiliaria` criado (Exercício 06 / ARQ08) com tabela `Cidade` vazia  
> **Referência nos slides:** Exercício 08

---

## 🎯 Objetivo

Inserir 10 registros na tabela `Cidade` do banco da imobiliária, consultar os dados e praticar a alteração de um registro específico com `UPDATE ... WHERE`.

---

## 🖥️ Passo a Passo

Abra o **Query Editor** no Workbench (`Ctrl+T`) e selecione o banco da imobiliária:

```sql
USE imobiliaria;
```

---

### Parte A — Inserir 10 cidades

**1.** Insira 10 cidades com UFs válidas (lembre-se: o campo `UF` é do tipo ENUM):

```sql
INSERT INTO Cidade (CodCidade, Cidade, UF) VALUES
(1, 'São Paulo', 'SP'),
(2, 'Belo Horizonte', 'MG'),
(3, 'Manaus', 'AM'),
(4, 'Ouro Preto', 'MG'),
(5, 'Porto Alegre', 'RS'),
(6, 'Curitiba', 'PR'),
(7, 'Salvador', 'BA'),
(8, 'Recife', 'PE'),
(9, 'Florianópolis', 'SC'),
(10, 'Goiânia', 'GO');
```

**2.** Consulte a tabela para confirmar a inserção:

```sql
SELECT * FROM Cidade;
```

✅ **Checkpoint:** A consulta deve retornar 10 linhas com as cidades e UFs inseridas.

---

### Parte B — Alterar o 5º registro

**3.** Altere o 5º registro, trocando o nome da cidade para `'JALAPÃO'` e a UF para `'TO'`:

```sql
UPDATE Cidade SET Cidade = 'JALAPÃO', UF = 'TO' WHERE CodCidade = 5;
```

**4.** Confirme a alteração:

```sql
SELECT * FROM Cidade WHERE CodCidade = 5;
```

✅ **Checkpoint:** O registro de `CodCidade = 5` agora deve exibir `JALAPÃO / TO` em vez de `Porto Alegre / RS`.

**5.** Consulte a tabela completa para visualizar o estado final:

```sql
SELECT * FROM Cidade;
```

---

## 🔍 O que observar

- O campo `UF` aceita apenas valores presentes na lista ENUM. Se tentar usar `'TO'`, funciona porque é um valor válido. Tente inserir um valor inválido (ex: `'XX'`) e observe o erro.
- O `WHERE CodCidade = 5` garante que **apenas** o registro desejado seja alterado. Sem o WHERE, **todas** as cidades seriam renomeadas para `JALAPÃO`.
- O campo `CodCidade` é SMALLINT (não AUTO_INCREMENT nesta tabela), por isso os valores foram inseridos manualmente.

---

## 📄 Gabarito

O script completo está disponível em [`codigo-fonte/Gabarito_Exercicio09.sql`](./codigo-fonte/Gabarito_Exercicio09.sql).
