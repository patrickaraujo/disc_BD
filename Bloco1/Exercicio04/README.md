# 📝 Exercício 04 — Alterar o DER e Sincronizar com o BD

> **Duração:** ~25 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Aula 06 concluída — schema `novoesquema` com `TabMae` e `TabFilha` criados, modelo `NovoEsquema.mwb` salvo

---

## 🎯 Objetivo

Alterar o DER no MySQL Workbench — adicionando uma **coluna gerada (Generated)** — e propagar as mudanças para o banco físico existente usando o **Synchronize Model**, sem precisar recriar o banco do zero.

---

## 💡 Por que isso importa?

Em projetos reais, o banco de dados evolui constantemente: novas tabelas, novas colunas, novos relacionamentos. Recriar o banco inteiro a cada mudança é inviável — especialmente quando já existem dados. O **Synchronize Model** compara o DER com o banco físico e gera apenas os comandos necessários para alinhar os dois.

```
DER (modelo .mwb)               Banco Físico (MySQL)
  ┌──────────────────┐           ┌──────────────────┐
  │ TabMae           │           │ TabMae           │
  │  CodTabMae       │           │  CodTabMae       │
  │  DescMae         │           │  DescMae         │
  │  + NovaColuna (G)│  ←DIFF→   │                  │
  └──────────────────┘           └──────────────────┘
                       ↓
         Synchronize Model gera:
         ALTER TABLE ... ADD COLUMN `NovaColuna` ... GENERATED
```

---

## 🖥️ Passo a Passo

### Parte A — Abrir o modelo no Workbench

1. Abra o **MySQL Workbench** e conecte à instância local (`Local instance MySQL80`)
2. Abra o modelo salvo: `File → Open Model...` → navegue até a pasta `Banco-de-Dados` e selecione `NovoEsquema.mwb`
3. Clique na aba **EER Diagram** para visualizar o DER com as tabelas `TabMae` e `TabFilha`

---

### Parte B — Adicionar uma Coluna Gerada (Generated) no DER

1. No canvas do EER Diagram, clique duas vezes na tabela **TabMae** para abrir o editor de colunas
2. Adicione uma nova coluna com as seguintes configurações:

   | Propriedade | Valor |
   |-------------|-------|
   | Column Name | `NovaColuna` |
   | Datatype | `VARCHAR(40)` |
   | NN (Not Null) | ✅ |
   | G (Generated) | ✅ |

3. Na parte inferior do editor, configure a expressão da coluna gerada:

   | Campo | Valor |
   |-------|-------|
   | Expression | `` `DescMae` `` |
   | Storage | **Virtual** |

> 💡 **O que é uma coluna gerada?** É uma coluna cujo valor é calculado automaticamente a partir de uma expressão — você não insere dados nela. Neste caso, `NovaColuna` vai "espelhar" automaticamente o valor de `DescMae`. O campo **Default/Expression** no Workbench mostra a expressão, não um valor padrão.

> 💡 **Virtual vs. Stored:** `Virtual` significa que o valor é calculado em tempo de leitura (não ocupa espaço em disco). `Stored` calcula e armazena fisicamente.

4. Confirme que o DER atualizado mostra `NovaColuna VARCHAR(40)` na tabela `TabMae`
5. **Salve o modelo** (`Ctrl+S`)

---

### Parte C — Sincronizar o DER com o Banco (Synchronize Model)

1. Com o modelo alterado e salvo, acesse **Database → Synchronize Model...** (`Ctrl+Shift+Z`)

   > ⚠️ **Não use** `Forward Engineer` (`Ctrl+G`) — ele tenta criar tudo do zero. Use **Synchronize Model** para aplicar apenas as diferenças.

2. Na tela **Connection Options**, selecione `Local instance MySQL80` → **Next**
3. Em **Sync Options**, mantenha as opções padrão → **Next**
4. Em **Connect to DBMS**, informe a senha se solicitado → **Next**
5. Em **Select Schemas**, confirme que o schema `novoesquema` está selecionado → **Next**
6. Em **Retrieve Objects**, aguarde a leitura das tabelas → **Next**
7. Na tela **Select Changes to Apply**, o Workbench mostra as diferenças encontradas:

   ```
   Model           Update    Source
   ─────────────────────────────────
   TabMae            →→      tabmae       (diferença detectada)
   TabFilha          →→      tabfilha
   ```

   Na parte inferior, observe o SQL gerado:

   ```sql
   ALTER TABLE `novoesquema`.`TabMae`
   CHARACTER SET = utf8 , COLLATE = utf8_general_ci ,
   ADD COLUMN `NovaColuna` VARCHAR(40) GENERATED ALWAYS AS (`DescMae`) VIRTUAL AFTER `DescMae`
   ```

   > 💡 Se aparecerem diferenças em `TabFilha` que você não quer aplicar (por exemplo, resquícios do Exercício 03), selecione a linha da `TabFilha` e clique em **Ignore** para ignorá-la.

8. Clique em **Next** para avançar para **Review DB Changes**

---

### Parte D — Salvar o script e executar

1. Na tela **Review DB Changes**, revise o script SQL completo que será aplicado
2. Clique em **"Save to File..."** para salvar o script
3. Salve com o nome **`NovoEsquema-Seq02.sql`** na mesma pasta dos outros arquivos

   > ⚠️ **Cuidado com o nome!** Não sobrescreva o script original (`NovoEsquema.sql`). Use nomes sequenciais (`-Seq02`, `-Seq03`, etc.) para manter o histórico de alterações.

4. Clique em **Execute >** para aplicar as alterações no banco
5. Aguarde: **"Synchronize Finished Successfully"**

---

### Parte E — Verificar a sincronização

1. Na aba da conexão local (`Local instance MySQL80`), acesse o painel **Schemas**
2. Pressione **refresh** (🔄) se necessário
3. Expanda `novoesquema → Tables → tabmae → Columns`
4. Confirme que `NovaColuna` aparece na lista de colunas

✅ **Checkpoint:** DER e banco físico estão sincronizados — a coluna gerada aparece no banco.

---

## 🔍 O que acabou de acontecer?

O **Synchronize Model** executou os seguintes passos internamente:

```
1. Leu a estrutura do DER (modelo .mwb)
2. Conectou ao MySQL e leu a estrutura do banco físico
3. Calculou as DIFERENÇAS (diff) entre modelo e banco
4. Gerou APENAS o ALTER TABLE necessário para alinhar o banco ao DER
5. Executou o comando no banco
```

O SQL gerado usou `GENERATED ALWAYS AS` — isso é diferente de um simples `ADD COLUMN`. A cláusula diz ao MySQL que o valor da coluna é **sempre calculado** a partir da expressão fornecida (neste caso, `` `DescMae` ``), e `VIRTUAL` indica que o cálculo é feito em tempo de leitura.

---

## 📋 Sobre a ordem dos scripts

A partir de agora, se precisar recriar o banco do zero em outro servidor, execute os scripts **na ordem**:

```sql
-- 1. Script principal (estrutura base)
SOURCE NovoEsquema.sql;

-- 2. Scripts de alteração, na sequência
SOURCE NovoEsquema-Seq02.sql;
-- SOURCE NovoEsquema-Seq03.sql;  (futuras alterações)
```

> 💡 Essa prática é similar ao conceito de **migrations** usado em frameworks modernos (Django, Rails, Laravel) — cada script é uma "migração" incremental.

---

## ✅ Critérios de conclusão

- [ ] Modelo `NovoEsquema.mwb` aberto no Workbench
- [ ] Coluna gerada `NovaColuna` adicionada em `TabMae` (G marcado, Expression: `` `DescMae` ``, Storage: Virtual)
- [ ] Modelo `.mwb` salvo com as alterações
- [ ] **Synchronize Model** executado com sucesso (não Forward Engineer)
- [ ] Script de alteração salvo como `NovoEsquema-Seq02.sql`
- [ ] Banco físico reflete a coluna gerada — verificado no Navigator
- [ ] Script original (`NovoEsquema.sql`) não foi sobrescrito

---

> 💭 *"O DER é a planta da casa. O banco é a casa construída. Synchronize Model é o pedreiro que reforma a casa conforme a planta atualizada."*
