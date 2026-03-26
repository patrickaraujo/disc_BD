# 🧠 Atividade 1 — Montagem do Ambiente e Verificação

> **Duração:** 20 minutos  
> **Formato:** Individual  
> **Objetivo:** Garantir que o banco `familia02` está funcional e consolidar os conceitos de transação e integridade referencial

---

## 📋 Parte 1 — Execução e Verificação

Execute o script completo do Bloco 1 (`COMANDOS-BD-01-bloco1.sql`) no MySQL Workbench e responda:

1. Quantos registros existem na tabela `pai` após a execução completa?

2. Quantos registros da tabela `filha` possuem `parente_id` diferente de `NULL`?

3. Quantos registros da tabela `filha` possuem `parente_id` igual a `NULL`?

---

## 📋 Parte 2 — Questões Conceituais

4. O que acontece se você executar `DELETE FROM pai WHERE id = 4` **sem** ter dado `COMMIT` antes, e logo em seguida executar `ROLLBACK`? Explique com suas palavras.

5. Por que ao excluir o registro `id = 4` da tabela `pai` (Manoel), a tabela `filha` **não foi afetada** na primeira demonstração (antes de criar a FK)?

6. Qual é a diferença entre `COMMIT` e `ROLLBACK`? Dê um exemplo prático de quando cada um seria usado.

7. O que significa a cláusula `ON DELETE CASCADE` na criação da FK? O que aconteceria se fosse `ON DELETE RESTRICT`?

8. Por que os registros 4 (Nando), 5 (Fernanda) e 6 (Igor) da tabela `filha` têm `parente_id = NULL`? Isso viola a integridade referencial?

---

## 📋 Parte 3 — Experimentação

9. Tente executar o comando abaixo e observe o resultado. O que acontece? Por quê?

```sql
INSERT INTO filha (id, nome, parente_id) VALUES (8, 'Humberto', 10);
```

10. Agora tente este. O que acontece de diferente? Por quê?

```sql
INSERT INTO filha (id, nome, parente_id) VALUES (7, 'Margareth', NULL);
```

---

## ✅ Gabarito (use apenas após tentar!)

### Parte 1

1. **7 registros** — João, Maria, Pedro, Manoel, Antônio, Sebastião, Evandro.

2. **3 registros** — Ana (parente_id = 1), Fabia (parente_id = 2), José (parente_id = 3).

3. **3 registros** — Nando, Fernanda, Igor (parente_id = NULL).

---

### Parte 2

4. O `DELETE` remove Manoel da tabela `pai` na sessão atual, mas como não houve `COMMIT`, a alteração está pendente. O `ROLLBACK` desfaz a exclusão e Manoel reaparece na consulta seguinte.

5. Porque naquele momento **não existia chave estrangeira** entre as tabelas. Elas eram independentes — excluir dados de uma não tinha nenhum impacto na outra.

6. **COMMIT** grava fisicamente as alterações no banco (definitivo, sem volta). **ROLLBACK** desfaz todas as alterações pendentes desde o último COMMIT. Exemplo prático: após inserir dados corretamente → `COMMIT`. Após perceber que inseriu dados errados → `ROLLBACK`.

7. `ON DELETE CASCADE` significa que ao excluir um registro pai, todos os registros filhos vinculados são **automaticamente excluídos**. Se fosse `ON DELETE RESTRICT`, o MySQL **impediria** a exclusão do pai enquanto existissem filhos vinculados (erro).

8. Porque a coluna `parente_id` foi criada com `ALTER TABLE` **sem** a cláusula `NOT NULL` — portanto, aceita valores nulos. Isso **não viola** a integridade referencial, pois `NULL` significa "sem vínculo" (não é o mesmo que apontar para um pai inexistente).

---

### Parte 3

9. **Erro 1452** — O MySQL rejeita a inserção porque o `parente_id = 10` não corresponde a nenhum `id` na tabela `pai`. A FK garante que só é possível referenciar pais que existam.

10. **Sucesso** — O registro é inserido normalmente porque `parente_id = NULL` é permitido. `NULL` não viola a FK; significa simplesmente que o registro filha não está vinculado a nenhum pai.

---

## 💭 Reflexão Final

Após completar esta atividade, você deve ser capaz de:

✅ Criar o banco `familia02` e verificar sua estrutura  
✅ Explicar o ciclo COMMIT/ROLLBACK  
✅ Compreender que tabelas sem FK são independentes  
✅ Distinguir `NULL` de valor inválido no contexto de FK  

> 💡 *"Integridade referencial não proíbe NULL — ela proíbe referências a registros que não existem."*
