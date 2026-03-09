# 📝 Exercício 05 — Alterar o BD e Sincronizar com o DER

> **Duração:** ~25 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Exercício 04 concluído — DER e banco sincronizados

---

## 🎯 Objetivo

Alterar a estrutura do banco de dados diretamente via SQL e, em seguida, usar o **Reverse Engineering** do Workbench para gerar um DER atualizado que reflita o estado real do banco.

---

## 💡 Quando você precisaria disso?

- Você recebeu um banco de dados legado **sem nenhum DER** e precisa documentá-lo
- Uma alteração urgente foi feita diretamente no servidor de produção e agora o DER precisa ser atualizado
- Outro desenvolvedor alterou o banco sem passar pelo modelo e você precisa sincronizar

```
Banco Físico (MySQL)             DER (modelo .mwb)
  ┌──────────────┐                ┌──────────────┐
  │ TabMae       │                │ TabMae       │
  │ TabFilha     │                │ TabFilha     │
  │ + NovaColunaX│  ──REVERSE──→  │ + NovaColunaX│
  └──────────────┘                └──────────────┘
                        ↓
          Reverse Engineering gera o DER
          a partir do banco existente
```

---

## 🖥️ Passo a Passo

### Parte A — Alterar o banco físico via SQL

1. Abra o **MySQL Workbench** e conecte à instância local
2. Abra uma nova aba no **Query Editor** (`Ctrl+T`)
3. Execute um comando `ALTER TABLE` para modificar a estrutura — por exemplo:

```sql
USE `mydb`;

ALTER TABLE `TabMae`
ADD `TelefoneMae` VARCHAR(20);
```

4. Confirme a alteração com `DESCRIBE`:

```sql
DESCRIBE TabMae;
```

Resultado esperado — a nova coluna `TelefoneMae` deve aparecer:

| Field       | Type        | Null | Key | Default | Extra          |
|-------------|-------------|------|-----|---------|----------------|
| CodTabMae   | int         | NO   | PRI | NULL    | auto_increment |
| DescMae     | varchar(45) | NO   |     | NULL    |                |
| TelefoneMae | varchar(20) | YES  |     | NULL    |                |

✅ **Checkpoint:** Banco alterado com sucesso. O DER ainda não sabe dessa mudança.

---

### Parte B — Gerar o DER via Reverse Engineering

1. No menu superior, acesse **Database → Reverse Engineer...**
2. Selecione a conexão `Local instance MySQL80` → **Next**
3. O Workbench lista os schemas disponíveis — marque `mydb` → **Next**
4. Aguarde a leitura das tabelas → **Next**
5. Confirme que as tabelas `TabMae` e `TabFilha` estão selecionadas → **Next**
6. Revise o resultado — o Workbench informa os objetos importados
7. Clique em **Finish**

O Workbench abre automaticamente um **novo diagrama EER** com as tabelas e relacionamentos do banco.

---

### Parte C — Verificar o DER gerado

1. No diagrama EER gerado, clique duas vezes em **TabMae**
2. Verifique que a coluna `TelefoneMae` (ou a alteração que você fez) aparece na lista de colunas
3. Confirme que o relacionamento entre `TabMae` e `TabFilha` está representado com a FK

✅ **Checkpoint:** O DER agora reflete a estrutura real do banco — incluindo a alteração feita via SQL.

---

### Parte D — Salvar o novo modelo

1. Salve o modelo gerado: `File → Save Model As...`
2. Escolha um nome que identifique a origem: `NovoEsquema_ReverseEng.mwb`

> 💡 Salve com um nome diferente do modelo original para manter o histórico. Você pode ter:
> - `NovoEsquema.mwb` — modelo original (Aula 06)
> - `NovoEsquema_ReverseEng.mwb` — modelo gerado a partir do banco

---

## 🔍 O que acabou de acontecer?

O **Reverse Engineering** executou os seguintes passos internamente:

```
1. Conectou ao servidor MySQL
2. Leu a estrutura do schema selecionado (mydb)
3. Identificou tabelas, colunas, tipos, PKs, FKs e índices
4. Gerou um modelo visual (EER Diagram) representando essa estrutura
5. Criou um novo arquivo .mwb com o DER gerado
```

Diferente do Synchronize Model (que compara e aplica diferenças), o Reverse Engineering **gera um DER novo** a partir do banco.

---

## ⚠️ Atenção: Scripts na ordem correta

Quando for necessário recriar o banco em outro ambiente, lembre-se de executar os scripts na sequência:

```
1. NovoEsquema.sql           ← Script principal
2. Alteracao_01.sql           ← Alteração via Forward Engineering (Ex. 04)
3. Alteracao_02.sql           ← Futuras alterações
   ...
```

> 💡 Alterações feitas via SQL diretamente no banco **não geram scripts automaticamente**. Se você alterar o banco manualmente e não salvar o comando, a única forma de recuperar a estrutura é via Reverse Engineering.

---

## ✅ Critérios de conclusão

- [ ] Banco físico alterado via SQL (`ALTER TABLE` executado)
- [ ] `DESCRIBE` confirmou a alteração na tabela
- [ ] **Reverse Engineering** executado com sucesso
- [ ] DER gerado contém todas as tabelas e colunas do banco (incluindo a alteração)
- [ ] Modelo `.mwb` salvo com nome distinto do original

---

## 🔄 Resumo das duas direções

| Direção | Exercício | Ferramenta | Quando usar |
|---------|-----------|-----------|-------------|
| DER → BD | Ex. 04 | Synchronize Model | Evolução planejada do modelo |
| BD → DER | Ex. 05 | Reverse Engineering | Banco alterado sem modelo, banco legado |

---

> 💭 *"O Reverse Engineering é o 'raio-X' do banco — ele mostra a estrutura real, independente do que o DER dizia antes."*
