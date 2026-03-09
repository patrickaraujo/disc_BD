# 📋 Tipos de Dados do MySQL

Os tipos de dados no MySQL são classificados em três categorias: **Numéricos**, **Data e Hora** e **Texto**. Este documento serve como referência rápida para consulta ao definir colunas nas suas tabelas.

---

## 🔢 Tipos Numéricos

### Inteiros

| Tipo | Bytes | Faixa com sinal | Faixa Unsigned |
|------|-------|-----------------|---------------|
| `TINYINT` | 1 | -128 a 127 | 0 a 255 |
| `SMALLINT` | 2 | -32.768 a 32.767 | 0 a 65.535 |
| `MEDIUMINT` | 3 | -8.388.608 a 8.388.607 | 0 a 16.777.215 |
| `INT` / `INTEGER` | 4 | -2.147.483.648 a 2.147.483.647 | 0 a 4.294.967.295 |
| `BIGINT` | 8 | -9.223.372.036.854.775.808 a 9.223.372.036.854.775.807 | 0 a 18.446.744.073.709.551.615 |

> 💡 `INT` é o tipo mais usado para IDs e contadores. Use `BIGINT` apenas quando a faixa do `INT` não for suficiente.

### Ponto flutuante

| Tipo | Precisão | Descrição |
|------|----------|-----------|
| `FLOAT` | Simples (~7 dígitos) | Valores de ±1,175×10⁻³⁸ a ±3,403×10³⁸ |
| `DOUBLE` / `DOUBLE PRECISION` | Dupla (~15 dígitos) | Valores de ±2,225×10⁻³⁰⁸ a ±1,798×10³⁰⁸ |

> ⚠️ Tipos de ponto flutuante podem ter **erros de arredondamento**. Para valores monetários, use `DECIMAL`.

### Ponto fixo

| Tipo | Sintaxe | Descrição |
|------|---------|-----------|
| `DECIMAL` / `NUMERIC` | `DECIMAL(M,D)` | M = total de dígitos, D = casas decimais. Precisão exata. |

Exemplo: `DECIMAL(10,2)` → até 99.999.999,99

> 💡 Use `DECIMAL` para valores que exigem precisão exata: preços, salários, notas.

---

## 📅 Tipos Data e Hora

| Tipo | Formato | Faixa | Descrição |
|------|---------|-------|-----------|
| `DATE` | `YYYY-MM-DD` | 1000-01-01 a 9999-12-31 | Apenas data (sem hora) |
| `DATETIME` | `YYYY-MM-DD HH:MM:SS` | 1000-01-01 00:00:00 a 9999-12-31 23:59:59 | Data e hora combinadas |
| `TIMESTAMP` | `YYYY-MM-DD HH:MM:SS` | 1970-01-01 00:00:01 UTC a 2038-01-19 03:14:07 UTC | Data/hora armazenada como segundos desde a época Unix |
| `TIME` | `HH:MM:SS` | -838:59:59 a 838:59:59 | Apenas hora (pode ultrapassar 24h) |
| `YEAR` | `YYYY` | 1901 a 2155 (e 0000) | Apenas ano, formato de 4 dígitos |

### Quando usar cada um?

| Situação | Tipo recomendado |
|----------|-----------------|
| Data de nascimento | `DATE` |
| Data e hora de criação do registro | `DATETIME` ou `TIMESTAMP` |
| Registro de log com fuso horário | `TIMESTAMP` |
| Duração de uma atividade | `TIME` |
| Ano de fabricação | `YEAR` |

> 💡 **DATETIME vs. TIMESTAMP:** `DATETIME` armazena o valor literal (sem conversão de fuso). `TIMESTAMP` converte para UTC ao salvar e reconverte ao ler — útil para sistemas com múltiplos fusos horários.

---

## 📝 Tipos Texto

### Strings de tamanho fixo e variável

| Tipo | Tamanho máximo | Comportamento |
|------|---------------|---------------|
| `CHAR(M)` | 255 caracteres | Comprimento **fixo** — preenche com espaços à direita. Se M for omitido, assume 1. |
| `VARCHAR(M)` | 65.535 caracteres | Comprimento **variável** — armazena apenas os caracteres necessários + 1-2 bytes de controle. |

> 💡 Use `CHAR` para valores de tamanho fixo (UF com 2 caracteres, CEP com 8). Use `VARCHAR` para textos de tamanho variável (nomes, descrições).

### Tipos binários

| Tipo | Tamanho máximo | Descrição |
|------|---------------|-----------|
| `BINARY(M)` | 255 bytes | Similar a `CHAR`, mas armazena bytes binários |
| `VARBINARY(M)` | 65.535 bytes | Similar a `VARCHAR`, mas armazena bytes binários |

### Tipos BLOB (Binary Large Object)

| Tipo | Tamanho máximo | Prefixo |
|------|---------------|---------|
| `TINYBLOB` | 255 bytes | 1 byte |
| `BLOB` | 65.535 bytes (~64 KB) | 2 bytes |
| `MEDIUMBLOB` | 16.777.215 bytes (~16 MB) | 3 bytes |
| `LONGBLOB` | 4.294.967.295 bytes (~4 GB) | 4 bytes |

> 💡 Tipos BLOB são usados para armazenar dados binários grandes: imagens, documentos, arquivos.

### Tipos TEXT

| Tipo | Tamanho máximo | Prefixo |
|------|---------------|---------|
| `TINYTEXT` | 255 caracteres | 1 byte |
| `TEXT` | 65.535 caracteres (~64 KB) | 2 bytes |
| `MEDIUMTEXT` | 16.777.215 caracteres (~16 MB) | 3 bytes |
| `LONGTEXT` | 4.294.967.295 caracteres (~4 GB) | 4 bytes |

> 💡 Use `TEXT` para textos longos que ultrapassam o limite do `VARCHAR`. Para a maioria dos campos de texto comuns, `VARCHAR` é suficiente.

### Tipos especiais

| Tipo | Descrição |
|------|-----------|
| `ENUM('val1', 'val2', ...)` | Aceita **apenas um valor** da lista definida. Armazenado internamente como inteiro. |
| `SET('val1', 'val2', ...)` | Aceita **zero ou mais valores** da lista definida. Armazenado internamente como inteiro. |

Exemplos:

```sql
-- ENUM: só pode ter UM valor da lista
sexo ENUM('M', 'F', 'Outro')

-- SET: pode ter VÁRIOS valores da lista
interesses SET('Esportes', 'Música', 'Cinema', 'Leitura')
```

---

## 🎯 Guia Rápido — Qual tipo usar?

| Dado | Tipo recomendado |
|------|-----------------|
| ID / código numérico | `INT` + `AUTO_INCREMENT` |
| Nome de pessoa | `VARCHAR(100)` |
| CPF | `CHAR(11)` |
| UF (estado) | `CHAR(2)` |
| Email | `VARCHAR(255)` |
| Preço / salário | `DECIMAL(10,2)` |
| Quantidade | `INT UNSIGNED` |
| Data de nascimento | `DATE` |
| Data de cadastro | `DATETIME` ou `TIMESTAMP` |
| Descrição longa | `TEXT` |
| Foto / arquivo | `MEDIUMBLOB` ou `LONGBLOB` |
| Sexo | `ENUM('M','F','Outro')` |
| Status (ativo/inativo) | `TINYINT(1)` ou `ENUM('Ativo','Inativo')` |
