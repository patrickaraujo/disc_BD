# 📝 Exercício 02 — Apagar o Schema e Recriar via Script SQL

> **Duração:** ~10 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Exercício 01 concluído — arquivos `.mwb` e `.sql` salvos

---

## 🎯 Objetivo

Compreender que o script SQL é **independente do Workbench**: o banco pode ser destruído e recriado a qualquer momento a partir do arquivo `.sql`, sem precisar redesenhar o DER.

---

## 💡 Por que isso importa?

O script gerado pelo Forward Engineering é o **backup estrutural** do seu banco. Em produção, é ele que garante que o banco pode ser recriado em outro servidor, após uma falha ou durante uma migração.

```
.mwb  → arquivo do modelo visual (DER)
.sql  → script de criação do banco físico (independente do Workbench)
```

---

## 🖥️ Passo a Passo

### Parte A — Apagar o schema

1. No painel **Schemas** do Workbench, clique com o **botão direito** sobre `mydb`
2. Selecione **"Drop Schema..."**
3. Uma caixa de confirmação aparece — leia com atenção e clique em **"Drop Now"**

> ⚠️ **Atenção:** esta ação é irreversível. O banco e todos os dados são apagados permanentemente. Por isso o script salvo é tão importante.

4. Pressione **refresh** (🔄) no painel Schemas — `mydb` não deve mais aparecer

✅ **Checkpoint:** Schema apagado com sucesso.

---

### Parte B — Recriar o banco via script SQL

1. No menu superior, clique em **File → Open SQL Script...** (`Ctrl+Shift+O`)
2. Navegue até a pasta onde você salvou e selecione o arquivo `NovoEsquema.sql`
3. O script abre no **Query Editor**
4. Selecione **todo o conteúdo** do script (`Ctrl+A`)
5. Execute clicando no ícone de **raio** ⚡ (Execute) ou pressione `Ctrl+Shift+Enter`
6. Observe o painel **Output** — todas as linhas devem aparecer com ✅ verde
7. Pressione **refresh** (🔄) no painel Schemas

✅ **Checkpoint:** `mydb` reaparece com as tabelas `tabmae` e `tabfilha` recriadas.

---

## 🔍 O que acabou de acontecer?

O script executou os seguintes comandos em sequência:

```sql
-- 1. Criou o schema caso não existisse
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;

-- 2. Selecionou o schema para uso
USE `mydb`;

-- 3. Criou a tabela pai
CREATE TABLE IF NOT EXISTS `mydb`.`TabMae` ( ... );

-- 4. Criou a tabela filha com FK
CREATE TABLE IF NOT EXISTS `mydb`.`TabFilha` ( ... );
```

A cláusula `IF NOT EXISTS` é importante: ela evita erro caso o schema ou a tabela já existam.

---

## ✅ Critérios de conclusão

- [ ] Schema `mydb` apagado com sucesso
- [ ] Script `NovoEsquema.sql` aberto e executado no Query Editor
- [ ] Schema `mydb` recriado com as tabelas `tabmae` e `tabfilha`
- [ ] Nenhum erro (❌) no painel Output

---

> 💡 **Conclusão:** o `.sql` é sua garantia. O DER pode ser perdido, o servidor pode falhar — mas com o script, você recria tudo em minutos.
