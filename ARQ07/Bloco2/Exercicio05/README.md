# 📝 Exercício 05 — Alterar o BD e Sincronizar com o DER

> **Duração:** ~25 minutos  
> **Formato:** Individual  
> **Pré-requisito:** Exercício 04 concluído — DER e banco sincronizados

---

## 🎯 Objetivo

Este arquivo demonstra, passo a passo, como **alterar a estrutura de uma tabela** existente no MySQL Workbench — tanto pela interface gráfica quanto via código SQL — e, em seguida, como usar o **Reverse Engineering** para gerar um DER atualizado que reflita o estado real do banco.

---

## Parte A — Alterar o banco de dados

Existem duas formas de alterar a estrutura de uma tabela no MySQL Workbench. Ambas produzem o mesmo resultado final; a escolha depende da preferência do desenvolvedor e do contexto de trabalho.

---

### Opção 1 — Pela interface gráfica (Alter Table)

#### Passo 1 — Acessar a opção "Alter Table"

No painel **Navigator**, dentro do schema `novoesquema`, a tabela `tabmae` é selecionada com o botão direito do mouse. No menu de contexto que aparece, a opção **"Alter Table..."** é escolhida. Essa opção permite modificar a estrutura da tabela (adicionar, remover ou alterar colunas) sem precisar recriá-la.

#### Passo 2 — Adicionar uma nova coluna

Na tela de edição da tabela `tabmae`, que já possui as colunas `CodTabMae` (INT, PK, AI), `DescMae` (VARCHAR(45)) e `NovaColuna` (VARCHAR(40), com default `DescMae`), é adicionada uma nova coluna chamada **`MaisUmaColuna`** com as seguintes propriedades:

- **Tipo de dado:** INT
- **Zero Fill (ZF):** marcado
- **Demais restrições:** sem PK, sem NN, sem UQ, sem AI

Após preencher os dados da nova coluna, o botão **"Apply"** é clicado para prosseguir.

#### Passo 3 — Revisar o script SQL gerado

O MySQL Workbench exibe uma tela de revisão com o script SQL que será executado no banco:

```sql
ALTER TABLE `mydb`.`TabMae`
ADD COLUMN `MaisUmaColuna` INT ZEROFILL NULL AFTER `NovaColuna`;
```

Esse comando adiciona a coluna `MaisUmaColuna` do tipo INT com ZEROFILL, permitindo valores nulos, posicionada logo após a coluna `NovaColuna`. O botão **"Apply"** é clicado para confirmar a execução.

#### Passo 4 — Confirmar a execução

A tela seguinte mostra a mensagem **"SQL script was successfully applied to the database"**, indicando que o comando foi executado com sucesso. O botão **"Finish"** encerra o assistente.

#### Passo 5 — Verificar a alteração

De volta à tela principal do Workbench, a tabela `tabmae` agora exibe a nova coluna `MaisUmaColuna` com tipo `INT(10)`, marcada como Unsigned e Zero Fill, com valor padrão `NULL`. No painel de saída (Output), o log confirma a operação com a mensagem **"Changes applied"** no registro de ações.

---

### Opção 2 — Via código SQL (Query Editor)

#### Passo 1 — Abrir o Query Editor

Abra uma nova aba no Query Editor usando `Ctrl+T` ou clicando no ícone de nova aba SQL na barra de ferramentas.

#### Passo 2 — Executar o comando ALTER TABLE

Digite e execute o comando SQL para adicionar a coluna desejada:

```sql
USE `mydb`;

ALTER TABLE `TabMae`
ADD `TelefoneMae` VARCHAR(20);
```

Selecione o comando e clique no ícone de raio (⚡) ou pressione `Ctrl+Shift+Enter` para executar.

#### Passo 3 — Confirmar a alteração com DESCRIBE

Execute o comando abaixo para verificar que a nova coluna foi adicionada:

```sql
DESCRIBE tabmae;
```

Resultado esperado:

| Field         | Type        | Null | Key | Default | Extra          |
|---------------|-------------|------|-----|---------|----------------|
| CodTabMae     | int         | NO   | PRI | NULL    | auto_increment |
| DescMae       | varchar(45) | NO   |     | NULL    |                |
| NovaColuna    | varchar(40) | YES  |     | DescMae |                |
| MaisUmaColuna | int(10) unsigned zerofill | YES |  | NULL   |                |

> 💡 **Dica:** a opção via SQL é mais rápida para alterações simples e permite salvar os comandos em arquivos `.sql` para controle de versão. A opção gráfica é mais visual e gera o script automaticamente, o que pode ajudar quem ainda está aprendendo a sintaxe.

---

## Parte B — Sincronizar com o DER via Reverse Engineering

Após alterar o banco diretamente (por qualquer uma das opções acima), o DER existente **não sabe dessa mudança**. Para gerar um diagrama atualizado que reflita o estado real do banco, utiliza-se o **Reverse Engineering**.

### Quando usar o Reverse Engineering?

- Você recebeu um banco de dados legado **sem nenhum DER** e precisa documentá-lo
- Uma alteração urgente foi feita diretamente no servidor e o DER precisa ser atualizado
- Outro desenvolvedor alterou o banco sem passar pelo modelo e você precisa sincronizar

```
Banco Físico (MySQL)             DER (modelo .mwb)
  ┌──────────────┐                ┌──────────────┐
  │ tabmae       │                │ tabmae       │
  │ tabfilha     │                │ tabfilha     │
  │ + MaisUmaCol │  ──REVERSE──→  │ + MaisUmaCol │
  └──────────────┘                └──────────────┘
                        ↓
          Reverse Engineering gera o DER
          a partir do banco existente
```

### Passo a passo

1. No menu superior do Workbench, acesse **Database → Reverse Engineer...**
2. Selecione a conexão `Local instance MySQL80` → clique em **Next**
3. O Workbench lista os schemas disponíveis — marque `novoesquema` → **Next**
4. Aguarde a leitura das tabelas → **Next**
5. Confirme que as tabelas `tabmae` e `tabfilha` estão selecionadas → **Next**
6. Revise o resultado — o Workbench informa os objetos importados
7. Clique em **Finish**

O Workbench abre automaticamente um **novo diagrama EER** com as tabelas e relacionamentos do banco.

### Verificar o DER gerado

1. No diagrama EER gerado, clique duas vezes em **tabmae**
2. Verifique que a coluna `MaisUmaColuna` (ou a alteração feita) aparece na lista de colunas
3. Confirme que o relacionamento entre `tabmae` e `tabfilha` está representado com a FK

### Salvar o novo modelo

Salve o modelo gerado em **File → Save Model As...** com um nome que identifique a origem, por exemplo: `NovoEsquema_ReverseEng.mwb`.

> 💡 Salve com um nome diferente do modelo original para manter o histórico.

---

## O que o Reverse Engineering faz internamente?

O processo executa os seguintes passos de forma automática:

1. Conecta ao servidor MySQL
2. Lê a estrutura do schema selecionado
3. Identifica tabelas, colunas, tipos, PKs, FKs e índices
4. Gera um modelo visual (EER Diagram) representando essa estrutura
5. Cria um novo arquivo `.mwb` com o DER gerado

Diferente do **Synchronize Model** (que compara e aplica diferenças entre modelo e banco), o Reverse Engineering **gera um DER completamente novo** a partir do banco.

---

## Resumo da estrutura final da tabela `tabmae`

| Coluna         | Tipo         | PK | NN | Observações              |
|----------------|--------------|----|----|--------------------------|
| CodTabMae      | INT          | Sim| Sim| Auto Increment           |
| DescMae        | VARCHAR(45)  | —  | Sim| —                        |
| NovaColuna     | VARCHAR(40)  | —  | —  | Default: `DescMae`       |
| MaisUmaColuna  | INT(10)      | —  | —  | Unsigned, Zero Fill, NULL|

---

## Resumo das duas direções de sincronização

| Direção  | Ferramenta            | Quando usar                                      |
|----------|-----------------------|--------------------------------------------------|
| DER → BD | Synchronize Model     | Evolução planejada do modelo                     |
| BD → DER | Reverse Engineering   | Banco alterado sem modelo, banco legado           |

---

> 💭 *"O Reverse Engineering é o 'raio-X' do banco — ele mostra a estrutura real, independente do que o DER dizia antes."*
