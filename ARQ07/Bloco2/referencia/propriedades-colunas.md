# 📋 Propriedades de Colunas no MySQL Workbench

Quando você cria ou edita colunas no MySQL Workbench, a interface apresenta várias **checkboxes** ao lado de cada coluna. Este documento explica o que cada uma significa e quando usá-la.

---

## Tabela Resumo

| Sigla | Nome completo | Descrição |
|-------|--------------|-----------|
| **PK** | Primary Key | Chave primária — identifica cada registro de forma única |
| **NN** | Not Null | Não permite valores nulos — o campo é obrigatório |
| **UQ** | Unique | Valor único — não permite duplicatas na coluna |
| **B** | Binary | Armazena dados binários (ex: imagens) |
| **UN** | Unsigned | Somente valores positivos — amplia a faixa numérica |
| **ZF** | Zero Fill | Preenche com zeros à esquerda para uniformizar o tamanho |
| **AI** | Auto Increment | Incremento automático — o SGBD gera o valor sequencialmente |
| **G** | Generated | Coluna gerada automaticamente — valor calculado, não digitado |

---

## Detalhamento

### 🔑 PK — Primary Key (Chave Primária)

Marca a coluna como **chave primária** da tabela. Garante que cada registro tenha um valor único e não nulo nesse campo.

- Automaticamente implica `NOT NULL` e `UNIQUE`
- Pode ser combinada com `AI` (Auto Increment) para gerar IDs automáticos
- Uma tabela pode ter **PK composta** (duas ou mais colunas marcadas como PK)

---

### ❗ NN — Not Null (Não Nulo)

Impede que a coluna aceite valores `NULL`. O campo se torna **obrigatório** — toda inserção deve fornecer um valor.

- Use em campos essenciais: nomes, descrições, chaves
- Campos opcionais (telefone secundário, observação) podem ficar sem NN

---

### 🔒 UQ — Unique (Valor Único)

Garante que **nenhum valor se repita** na coluna (exceto `NULL`, que pode aparecer múltiplas vezes).

- Diferente de PK: uma tabela pode ter várias colunas `UNIQUE`, mas apenas uma PK (ou PK composta)
- Use em campos como email, CPF ou código alternativo

---

### 💾 B — Binary (Binário)

Indica que a coluna armazena **dados binários** em vez de texto. Relevante para campos `CHAR` e `VARCHAR` quando se deseja comparação byte a byte (case-sensitive e sensível a acentos).

- Raramente usado em colunas comuns
- Para armazenar arquivos/imagens, prefira os tipos `BLOB`

---

### ➕ UN — Unsigned (Sem Sinal)

Restringe a coluna a **somente valores positivos** (≥ 0), dobrando a faixa positiva disponível.

| Tipo | Faixa com sinal | Faixa Unsigned |
|------|----------------|---------------|
| `INT` | -2.147.483.648 a 2.147.483.647 | 0 a 4.294.967.295 |
| `SMALLINT` | -32.768 a 32.767 | 0 a 65.535 |
| `TINYINT` | -128 a 127 | 0 a 255 |

- Use em colunas que nunca terão valores negativos: IDs, quantidades, idades

---

### 0️⃣ ZF — Zero Fill (Preenchimento com Zeros)

Preenche com **zeros à esquerda** para que todos os valores tenham o mesmo número de dígitos visualmente.

Exemplo com `INT(5) ZEROFILL`:

| Valor real | Valor exibido |
|-----------|---------------|
| 42 | 00042 |
| 7 | 00007 |
| 12345 | 12345 |

- Ativa automaticamente `UNSIGNED`
- Útil para códigos padronizados (número de matrícula, código de produto)

---

### 🔄 AI — Auto Increment (Incremento Automático)

O SGBD gera o valor da coluna **automaticamente**, incrementando a cada novo registro inserido.

- Normalmente combinado com `PK` para criar IDs automáticos
- O valor nunca é reutilizado — se um registro for apagado, o número não volta
- Não é possível alterar manualmente um valor gerado por AI

```sql
-- Exemplo: tabela com PK auto-incrementada
CREATE TABLE Exemplo (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(50) NOT NULL
);

INSERT INTO Exemplo (nome) VALUES ('João');   -- id = 1
INSERT INTO Exemplo (nome) VALUES ('Maria');  -- id = 2
DELETE FROM Exemplo WHERE id = 2;
INSERT INTO Exemplo (nome) VALUES ('Pedro');  -- id = 3 (não reutiliza o 2)
```

---

### ⚙️ G — Generated (Coluna Gerada)

Coluna cujo valor é **calculado automaticamente** a partir de outras colunas. Você não insere dados nela — o MySQL calcula.

```sql
-- Exemplo: coluna gerada que calcula o total
CREATE TABLE Pedido (
  quantidade INT NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED
);
```

- `VIRTUAL`: calculada em tempo de leitura (não ocupa espaço)
- `STORED`: calculada e armazenada fisicamente (ocupa espaço, mais rápida para leitura)

---

## 🎯 Combinações comuns

| Cenário | Propriedades |
|---------|-------------|
| ID automático | PK + NN + AI |
| Nome obrigatório | NN |
| Email único e obrigatório | NN + UQ |
| Quantidade (só positivos) | NN + UN |
| Código padronizado com zeros | NN + UN + ZF |
| Subtotal calculado | G |
