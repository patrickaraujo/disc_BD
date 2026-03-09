# 📝 Exercício 06 — Criar o DER da Imobiliária e Gerar o Modelo Físico

> **Duração:** ~40 minutos  
> **Formato:** Individual  
> **Pré-requisito:** MySQL Workbench e MySQL Server instalados e funcionando

---

## 🎯 Objetivo

Criar um DER completo no Workbench com 8 tabelas representando um sistema de **imobiliária para aluguel de imóveis**, gerar o script SQL via Forward Engineering e criar o banco físico no MySQL.

---

## 📋 Modelo a implementar

O sistema possui as seguintes tabelas e relacionamentos:

```
TipoImovel ─────────┐
                    │
Cidade ─────────┐   │
                │   │
Praia ──────┐   │   │
            │   │   │
Proprietario┐   │   │
            │   │   │
            ▼   ▼   ▼ 
           Imovel ──────────────┐
                                │
           Inquilino ──────┐    │
                           ▼    ▼
                      ContratoAluguel
                                │
           Mobilia ────────┐    │
                           ▼    ▼
                       ItensMobilia
```

---

## 📊 Dicionário de Dados

### TipoImovel

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| idTipoImovel | SMALLINT | ✅ | ✅ | |
| TipoImovel | VARCHAR(45) | | ✅ | Ex.: Casa, Apartamento, Kitnet |

### Cidade

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| CodCidade | SMALLINT | ✅ | ✅ | |
| Cidade | VARCHAR(100) | | ✅ | |
| UF | ENUM('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO') | | | Siglas dos 26 estados + DF |

### Praia

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| idPraia | SMALLINT | ✅ | ✅ | |
| NomePraia | VARCHAR(45) | | | |

### Proprietario

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| idProprietario | INT | ✅ | ✅ | |
| Nome | VARCHAR(100) | | | |
| RG | VARCHAR(15) | | | |

### Imovel

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| idImovel | INT | ✅ | ✅ | |
| QtdeQuartos | SMALLINT | | | |
| QtdeBanheiros | SMALLINT | | | |
| VistaMar | ENUM('N','S') | | | N = Não, S = Sim |
| Logradouro | VARCHAR(50) | | | |
| Numero | SMALLINT | | | |
| Complemento | VARCHAR(25) | | | |
| Bairro | VARCHAR(35) | | | |
| CEP | INT | | | |
| idTipoImovel | SMALLINT | | | FK → TipoImovel |
| CodCidade | SMALLINT | | | FK → Cidade |
| idPraia | SMALLINT | | | FK → Praia |
| idProprietario | INT | | | FK → Proprietario |

### Inquilino

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| CodInquilino | INT | ✅ | ✅ | |
| Nome | VARCHAR(100) | | | |
| CPF | INT | | | |

### ContratoAluguel

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| NroContrato | INT | ✅ | ✅ | |
| Inquilino_CodInquilino | INT | | | FK → Inquilino |
| Imovel_idImovel | INT | | | FK → Imovel |
| DtContrato | DATE | | | |
| DtInicio | DATE | | | |
| DtFim | DATE | | | |
| ValorAluguel | DECIMAL(5,2) | | | |

### Mobilia

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| idMobilia | INT | ✅ | ✅ | |
| Descricao | VARCHAR(45) | | | |

### ItensMobilia

| Coluna | Tipo | PK | NN | Observações |
|--------|------|----|----|-------------|
| CodItemMobilia | INT | ✅ | ✅ | |
| Mobilia_idMobilia | INT | | ✅ | FK → Mobilia |
| Imovel_idImovel | INT | | ✅ | FK → Imovel |
| Qtde | SMALLINT(2) | | | |

---

## 🖥️ Passo a Passo

### Parte A — Criar o DER no Workbench

1. Abra o **MySQL Workbench** e conecte à instância local
2. Crie um novo modelo: `File → New Model` (`Ctrl+N`)
3. Clique em **"Add Diagram"** para abrir o canvas EER
4. Crie cada uma das 8 tabelas conforme o Dicionário de Dados acima
5. Para os campos **ENUM**:
   - Na coluna `UF` da tabela `Cidade`, defina o tipo como `ENUM('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO')`
   - Na coluna `VistaMar` da tabela `Imovel`, defina o tipo como `ENUM('N','S')`
6. Crie os **relacionamentos 1:N** usando o conector na barra lateral:
   - TipoImovel → Imovel (via `idTipoImovel`)
   - Cidade → Imovel (via `CodCidade`)
   - Praia → Imovel (via `idPraia`)
   - Proprietario → Imovel (via `idProprietario`)
   - Inquilino → ContratoAluguel (via `Inquilino_CodInquilino`)
   - Imovel → ContratoAluguel (via `Imovel_idImovel`)
   - Mobilia → ItensMobilia (via `Mobilia_idMobilia`)
   - Imovel → ItensMobilia (via `Imovel_idImovel`)

7. Salve o modelo: `File → Save Model As...` → `Imobiliaria.mwb`

### Parte B — Gerar o Modelo Físico

1. Acesse **Database → Forward Engineer...** (`Ctrl+G`)
2. Selecione a conexão `Local instance MySQL80` → **Next**
3. Mantenha as opções padrão → **Next**
4. Confirme que todas as 8 tabelas estão selecionadas → **Next**
5. Na tela **Review SQL Script**, clique em **"Save to File..."**
6. Salve como `Imobiliaria.sql` na mesma pasta do `.mwb`
7. Clique em **Next** para executar e criar o banco

### Parte C — Verificar o banco criado

1. No painel **Schemas**, pressione o botão de **refresh** (🔄)
2. Expanda o schema criado → Tables
3. Confirme que as 8 tabelas aparecem com suas colunas e FKs

✅ **Checkpoint:** Banco criado com 8 tabelas, ENUMs configurados e relacionamentos com FK.

---

## ✅ Critérios de conclusão

- [ ] Arquivo `Imobiliaria.mwb` salvo
- [ ] Arquivo `Imobiliaria.sql` salvo
- [ ] Banco físico criado no MySQL com as 8 tabelas
- [ ] Coluna `UF` da tabela `Cidade` é do tipo ENUM com 27 valores
- [ ] Coluna `VistaMar` da tabela `Imovel` é do tipo ENUM('N','S')
- [ ] Todos os relacionamentos (FKs) visíveis no Navigator

---

> 💡 O script SQL de gabarito está disponível em [`Arquivos/Imobiliaria.sql`](./Arquivos/Imobiliaria.sql) para conferência.
