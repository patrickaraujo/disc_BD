# 🔗 Relacionamentos Identificadores vs Não Identificadores

Em bancos de dados relacionais, a diferença entre esses dois tipos de relacionamento está em como a **chave estrangeira** participa da **chave primária** da tabela filha.

---

## ✅ Relacionamento Identificador (Identifying Relationship)

A **chave estrangeira faz parte da chave primária** da tabela filha.
Isso significa que a entidade filha **não pode ser identificada de forma única sem a referência à entidade pai** — sua própria existência depende do pai.

### 📌 Exemplo

Imagine duas tabelas:

- 🧾 `Pedido`
- 📦 `ItemPedido`

Um item de pedido só faz sentido dentro de um pedido específico.

A chave primária de `ItemPedido` poderia ser:

```
(pedido_id, item_numero)
```

Onde:

- `pedido_id` → é **chave estrangeira** 🔑
- `pedido_id` → também é **parte da chave primária** 🗝️

> 💡 Portanto, a identidade do item **depende** do pedido.

---

## ❌ Relacionamento Não Identificador (Non-Identifying Relationship)

A **chave estrangeira existe na tabela filha**, mas **não faz parte da chave primária**.

Isso significa que a entidade filha possui **identidade própria**, independente do pai.

### 📌 Exemplo

Considere:

- 👤 `Funcionario`
- 🏢 `Departamento`

A tabela `Funcionario` possui:

```
funcionario_id  (PK)
departamento_id (FK)
```

Nesse caso:

- `funcionario_id` identifica o funcionário de forma independente
- `departamento_id` apenas indica a qual departamento ele pertence

> 💡 Ou seja, o funcionário **existe independentemente** do departamento.

---

## 📊 Resumo Comparativo

| Tipo | Característica Principal | Dependência |
|---|---|---|
| ✅ **Identificador** | FK **faz parte** da PK da entidade filha | Filho **depende** do pai |
| ❌ **Não identificador** | FK **não faz parte** da PK | Filho tem **identidade própria** |

---

## 🖊️ Representação em Diagramas ER

| Tipo | Representação |
|---|---|
| ✅ Identificador | Linha **contínua** ─── |
| ❌ Não identificador | Linha **tracejada** - - - |

---

## 🧠 Dica Final

- **Identificador →** o filho *não existe* sem o pai (a identidade do filho inclui o pai)
- **Não identificador →** o filho tem **identidade própria** e apenas referencia o pai como um atributo
