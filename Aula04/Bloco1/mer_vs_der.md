# MER vs DER: Diferenças e Conceitos em Modelagem de Banco de Dados

## 📌 Resumo Executivo

- **MER (Modelo Entidade-Relacionamento)**: modelo conceitual teórico que descreve entidades, atributos e relacionamentos.
- **DER (Diagrama Entidade-Relacionamento)**: representação gráfica visual do MER.
- **Ambos pertencem à fase CONCEITUAL** — nenhum deles é modelo lógico.

> ⚠️ **Erro comum**: Confundir DER com modelo lógico. O DER é apenas um *desenho* do modelo conceitual, não uma fase diferente de modelagem.

---

## 🔍 Definições

### MER (Modelo Entidade-Relacionamento)
- Modelo conceitual abstrato e independente de tecnologia.
- Descreve:
  - **Entidades**: objetos do domínio (ex: `Cliente`, `Produto`).
  - **Atributos**: propriedades das entidades (ex: `nome`, `CPF`).
  - **Relacionamentos**: associações entre entidades (ex: `COMPRA`).

### DER (Diagrama Entidade-Relacionamento)
- Representação visual gráfica do MER.
- Utiliza notações padronizadas:
  - **Chen** (clássica): losangos para relacionamentos.
  - **Crow's Foot** (moderna): "pés de corvo" para cardinalidades.
- Ferramenta de comunicação entre stakeholders técnicos e não técnicos.

---

## 📊 Comparação MER × DER

| Característica       | MER                                      | DER                                      |
|----------------------|------------------------------------------|------------------------------------------|
| **Natureza**         | Modelo conceitual (abstração lógica)     | Representação gráfica do MER             |
| **Formato**          | Pode ser descrito textualmente           | Diagrama com símbolos visuais            |
| **Independência**    | Independente de SGBD                     | Independente de SGBD                     |
| **Propósito**        | Definir semântica dos dados              | Comunicar visualmente a estrutura        |
| **Fase do projeto**  | Conceitual                               | Conceitual (mesma fase)                  |

> 💡 **Analogia**: O MER é a "planta baixa descrita em texto"; o DER é o "desenho arquitetônico" dessa planta.

---

## 🔄 Fases da Modelagem de Banco de Dados

```
┌─────────────────────────────┐
│  Modelo CONCEITUAL (MER/DER)│  ← entidades, atributos, relacionamentos
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│  Modelo LÓGICO (Relacional) │  ← tabelas, PK, FK, normalização
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│  Modelo FÍSICO              │  ← implementação em SGBD específico
└─────────────────────────────┘
```

### 1. Modelo Conceitual (MER/DER)
- Foco no negócio, não na tecnologia.
- Elementos: entidades, atributos, relacionamentos e cardinalidades.
- Independente de SGBD.

### 2. Modelo Lógico (ex: Modelo Relacional)
- Adaptação ao tipo de SGBD (relacional, hierárquico, etc.).
- Define:
  - Tabelas e colunas
  - Chaves primárias (PK) e estrangeiras (FK)
  - Normalização
- Ainda independente de SGBD específico.

### 3. Modelo Físico
- Implementação concreta em SGBD específico (PostgreSQL, MySQL, Oracle...).
- Define:
  - Tipos de dados exatos (`VARCHAR(100)`, `INT`, etc.)
  - Índices, particionamento, tablespaces
  - Otimizações específicas do SGBD

---

## 💡 Exemplo Prático

### DER (Conceitual)
```
[Cliente] ────(realiza)──── [Pedido]
   │                            │
   ├─ nome                      ├─ data
   ├─ CPF                       ├─ valor_total
   └─ email                     └─ status
```

### Modelo Lógico (Relacional)
```sql
Cliente (
    cpf VARCHAR(14) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150)
)

Pedido (
    id_pedido SERIAL PRIMARY KEY,
    cpf_cliente VARCHAR(14) NOT NULL REFERENCES Cliente(cpf),
    data TIMESTAMP NOT NULL,
    valor_total DECIMAL(10,2),
    status VARCHAR(20)
)
```

> 🔑 **Diferença-chave**: No modelo lógico aparecem **PK/FK**, **tipos de dados** e **estrutura tabular** — elementos ausentes no DER conceitual.

---

## ✅ Checklist: Conceitual vs Lógico

| Elemento                     | Conceitual (MER/DER) | Lógico (Relacional) |
|-----------------------------|----------------------|---------------------|
| Entidades/Relacionamentos   | ✅ Sim               | ❌ Não (vira tabela)|
| Cardinalidades (1:N, N:N)   | ✅ Sim               | ❌ Não (vira FK)    |
| Chaves primárias (PK)       | ❌ Não               | ✅ Sim              |
| Chaves estrangeiras (FK)    | ❌ Não               | ✅ Sim              |
| Tipos de dados              | ❌ Não               | ✅ Sim (genéricos)  |
| Normalização                | ❌ Não               | ✅ Sim              |

---

## 📚 Conclusão

1. **MER e DER são a mesma coisa em essência**: um é o modelo teórico, o outro sua representação visual.
2. **Ambos são conceituais** — não confunda DER com modelo lógico.
3. O fluxo correto é:  
   **MER/DER (conceitual) → Modelo Relacional (lógico) → Implementação (físico)**.
4. Manter essa distinção evita erros de projeto e facilita a comunicação entre equipes.

> 🎯 **Dica final**: Use o DER para conversar com o cliente/negócio; use o modelo lógico para conversar com desenvolvedores/DBAs.
