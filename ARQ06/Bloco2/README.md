# 🟢 Bloco 2 — Recriar via Script e Praticar DDL Manual

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual

---

## 🎯 O que você vai fazer neste bloco

- Apagar o schema criado no Bloco 1 e recriá-lo inteiro a partir do script `.sql`
- Executar comandos DDL manualmente para entender o que o Workbench gera automaticamente
- Praticar `CREATE`, `DROP`, `ALTER TABLE`, `DESCRIBE` e `SHOW`

---

## 💡 Por que executar SQL manualmente?

O Workbench é uma ferramenta — mas o SQL é a linguagem. Em situações reais você vai precisar:

- Corrigir uma coluna diretamente no servidor sem abrir o Workbench
- Executar um script de migração em produção
- Entender um erro gerado pelo banco e saber onde está o problema

```
Workbench   →   gera o SQL para você   →   útil para criar
SQL manual  →   você controla tudo     →   essencial para manter
```

---

## ✏️ Atividades

### [📁 Exercício 02 — Apagar o Schema e Recriar via Script](./Exercicio02/README.md)

Você vai apagar o `mydb` pelo Workbench e recriá-lo abrindo e executando o script `.sql` no Query Editor.

**Objetivo:** Comprovar que o script é independente do Workbench — o banco pode ser destruído e recriado em minutos.

---

### [📁 Exercício 03 — Praticando SQL Manualmente (DDL)](./Exercicio03/README.md)

Você vai executar os seguintes comandos um por vez, observando o efeito de cada um:

| Etapa | Comando | O que faz |
|-------|---------|-----------|
| 1 | `SHOW DATABASES` / `SHOW TABLES` | Lista schemas e tabelas |
| 2 | `DROP DATABASE` / `CREATE DATABASE` / `USE` | Remove e recria schema |
| 3 | `CREATE TABLE TabMae (...)` | Cria tabela pai com AUTO_INCREMENT |
| 4 | `DESCRIBE tabmae` | Inspeciona a estrutura |
| 5 | `CREATE TABLE TabFilha (...)` | Cria tabela filha com PK composta e FK |
| 6 | `DESCRIBE tabfilha` | Confirma PK composta e FK |
| 7 | `ALTER TABLE ... ADD` | Adiciona nova coluna |
| 8 | `ALTER TABLE ... MODIFY` | Altera tipo/constraint de coluna |
| 9 | `ALTER TABLE ... DROP COLUMN` | Remove coluna |
| 10 | `ALTER TABLE ... DROP CONSTRAINT` | Remove FK |
| 11 | `ALTER TABLE ... ADD CONSTRAINT` | Recria FK |
| 12 | `DROP TABLE` | Remove tabela |

> ⚠️ **Ao finalizar:** apague o schema de exercício e recrie o `mydb` a partir do script `.sql`. Isso é necessário para as próximas aulas.

---

## ✅ Critérios de conclusão do Bloco 2

- [ ] Schema `mydb` apagado e recriado com sucesso via script (Ex. 02)
- [ ] Todos os 12 comandos DDL executados sem erros (Ex. 03)
- [ ] `DESCRIBE` usado após cada `ALTER TABLE` para confirmar as mudanças
- [ ] FK removida e recriada manualmente com sucesso
- [ ] Schema de exercício apagado e `mydb` restaurado ao final

---

## 🎯 O que você aprendeu nesta aula

```
DER no Workbench
    ↓ Forward Engineering
Script SQL (.sql)        ← pode ser executado em qualquer servidor
    ↓ Execute no Query Editor
Banco Físico no MySQL
    ↓ ALTER TABLE
Manutenção direta via DDL
```

> 💭 *"O Workbench gera o SQL por você — mas entender o SQL garante que você não depende do Workbench."*
