# 📝 Exercício 10 — UPDATE em Massa, DELETE e ROLLBACK

> **Duração:** ~20 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Exercício 09 concluído — tabela `Cidade` com 10 registros  
> **Referência nos slides:** Exercício 09

---

## 🎯 Objetivo

Experimentar o comportamento do `UPDATE` sem WHERE (alteração em massa), testar o `ROLLBACK`, praticar `DELETE` com e sem condição e compreender os limites do ROLLBACK no MySQL.

---

## ⚠️ Antes de começar — Autocommit

O comportamento do `ROLLBACK` depende do modo **autocommit** do MySQL. Por padrão, o autocommit está **ligado** (`= 1`), o que significa que cada comando é confirmado automaticamente.

Para que o ROLLBACK funcione nos testes abaixo, **desative o autocommit** antes de começar:

```sql
SET autocommit = 0;
```

> 💡 Com `autocommit = 0`, as alterações só são efetivadas após um `COMMIT` explícito. O `ROLLBACK` consegue desfazer operações pendentes.

---

## 🖥️ Passo a Passo

### Parte A — UPDATE sem WHERE + ROLLBACK

**1.** Altere **todas** as cidades para `'Santa Cruz das Palmeiras'`:

```sql
UPDATE Cidade SET Cidade = 'Santa Cruz das Palmeiras';
```

**2.** Consulte para confirmar que todos os nomes mudaram:

```sql
SELECT * FROM Cidade;
```

> Observe: todas as 10 linhas agora têm o mesmo nome de cidade. As UFs não foram alteradas (não estavam no SET).

**3.** Tente reverter a operação:

```sql
ROLLBACK;
```

**4.** Consulte novamente para verificar se voltou ao estado anterior:

```sql
SELECT * FROM Cidade;
```

✅ **Checkpoint (autocommit = 0):** Os nomes originais das cidades devem ter retornado.

⚠️ **Checkpoint (autocommit = 1):** Se o autocommit estava ligado, o ROLLBACK **não** tem efeito — as alterações já foram confirmadas automaticamente.

---

### Parte B — DELETE sem WHERE + ROLLBACK

**5.** Apague **todos** os registros da tabela:

```sql
DELETE FROM Cidade;
```

**6.** Consulte para confirmar que a tabela está vazia:

```sql
SELECT * FROM Cidade;
```

**7.** Reverta a exclusão:

```sql
ROLLBACK;
```

**8.** Consulte novamente:

```sql
SELECT * FROM Cidade;
```

✅ **Checkpoint (autocommit = 0):** Os 10 registros devem ter retornado.

---

### Parte C — DELETE com WHERE (registro específico)

**9.** Apague apenas 1 registro (por exemplo, `CodCidade = 3`):

```sql
DELETE FROM Cidade WHERE CodCidade = 3;
```

**10.** Consulte para confirmar:

```sql
SELECT * FROM Cidade;
```

✅ **Checkpoint:** A tabela deve ter 9 registros. O registro de `CodCidade = 3` (Manaus) não aparece mais.

**11.** Confirme as alterações pendentes:

```sql
COMMIT;
```

> 💡 Após o COMMIT, o ROLLBACK não consegue mais desfazer. A exclusão do registro 3 é definitiva.

---

### Parte D — Restaurar o autocommit

**12.** Ao finalizar os testes, restaure o autocommit ao padrão:

```sql
SET autocommit = 1;
```

---

## 🔍 O que observar

- `UPDATE` e `DELETE` **sem WHERE** afetam **todas** as linhas — são operações perigosas. No dia a dia, sempre verifique o WHERE antes de executar.
- `ROLLBACK` só funciona para operações **não confirmadas**. Com `autocommit = 1` (padrão), cada comando é confirmado imediatamente e o ROLLBACK não tem efeito.
- `DELETE FROM Tabela` apaga os dados mas mantém a estrutura da tabela. Diferente do `TRUNCATE TABLE`, que também apaga os dados mas **não** pode ser revertido com ROLLBACK (é DDL, não DML).
- `COMMIT` torna as alterações permanentes. Após o COMMIT, não há como voltar atrás com ROLLBACK.

---

## 📄 Gabarito

O script completo está disponível em [`codigo-fonte/Gabarito_Exercicio10.sql`](./codigo-fonte/Gabarito_Exercicio10.sql).
