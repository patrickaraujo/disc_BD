# 🔵 Bloco 1 — Do DER para o Banco: Forward Engineering Sync

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual guiada

---

## 🎯 O que você vai fazer neste bloco

- Entender por que alterar o banco manualmente causa desatualização com o DER
- Alterar o DER no Workbench (adicionar uma **coluna gerada** em `TabMae`)
- Usar o **Forward Engineering — Synchronize Model** para propagar as alterações para o banco físico
- Salvar o script de alteração com um nome sequencial
- Verificar que o banco foi atualizado corretamente

---

## 💡 O problema: Desatualização DER ↔ BD

Na aula anterior (Exercício 03), você executou comandos DDL diretamente no banco — `ALTER TABLE`, `DROP`, `CREATE`. Isso alterou o banco físico, mas o DER permaneceu com a versão antiga.

```
Exercício 03 (Aula 06):
   Você alterou o BD manualmente via SQL
           ↓
   O DER ficou DESATUALIZADO
           ↓
   DER ≠ BD → problema em equipe, migração, documentação
```

**Pergunta da aula:** Quais os riscos dessa prática?

| Risco | Consequência |
|-------|-------------|
| DER desatualizado | Documentação não reflete a realidade do banco |
| Conflito entre desenvolvedores | Cada um olha uma "verdade" diferente |
| Script de criação inválido | Recriar o banco a partir do DER gera estrutura errada |
| Migração perigosa | Mover para outro servidor sem saber o que realmente existe |

**Solução:** Duas formas de manter a sincronia:

```
Caminho 1 (Exercício 04): Alterar o DER  → Sincronizar com o BD (Forward Engineering)
Caminho 2 (Exercício 05): Alterar o BD   → Sincronizar com o DER (Reverse Engineering)
```

---

## ✏️ Atividade

### [📁 Exercício 04 — Alterar o DER e Sincronizar com o BD](./Exercicio04/README.md)

**Resumo dos passos:**
1. Abrir o modelo `NovoEsquema.mwb` e visualizar o EER Diagram
2. Adicionar coluna gerada `NovaColuna` em `TabMae` (G marcado, Expression: `` `DescMae` ``, Storage: Virtual)
3. Salvar o modelo
4. Executar `Database → Synchronize Model...` (`Ctrl+Shift+Z`)
5. Revisar as diferenças e o script SQL gerado
6. Salvar o script como `NovoEsquema-Seq02.sql`
7. Aplicar as alterações no banco
8. Verificar que a coluna gerada aparece no Navigator
7. Verificar que DER e BD estão sincronizados

---

## ⚠️ Atenção: Forward Engineer vs. Synchronize Model

| Ação | Quando usar |
|------|-------------|
| **Forward Engineer** (`Ctrl+G`) | Para criar o banco **do zero** a partir do DER |
| **Synchronize Model** | Para **atualizar** um banco já existente com as alterações feitas no DER |

> 💡 Se você usar o Forward Engineer comum em um banco que já existe, ele vai tentar recriar tudo e pode gerar erros. Use o **Synchronize Model** para aplicar apenas as diferenças.

---

## ✅ Critérios de conclusão do Bloco 1

- [ ] DER alterado no Workbench (coluna gerada `NovaColuna` adicionada em `TabMae`)
- [ ] `Synchronize Model` executado com sucesso
- [ ] Script de alteração salvo como `NovoEsquema-Seq02.sql`
- [ ] Banco físico reflete a coluna gerada
- [ ] Modelo `.mwb` salvo com as alterações

---

## 📋 Ordem de execução dos scripts

Quando precisar recriar o banco do zero, execute os scripts **na ordem correta**:

```
1. NovoEsquema.sql          ← Script principal (cria a estrutura base)
2. NovoEsquema-Seq02.sql    ← Primeira alteração (coluna gerada)
3. NovoEsquema-Seq03.sql    ← Segunda alteração
   ...
N. NovoEsquema-SeqN.sql     ← Última alteração
```

> 💡 **Guarde todos os scripts organizados** — eles formam o histórico de evolução do seu banco.
