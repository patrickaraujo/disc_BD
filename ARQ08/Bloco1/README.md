# 🔵 Bloco 1 — Criar o DER da Imobiliária e Gerar o Modelo Físico

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual guiada

---

## 🎯 O que você vai fazer neste bloco

- Criar um novo modelo `.mwb` no MySQL Workbench com **8 tabelas** inter-relacionadas
- Utilizar tipos de dados variados: INT, SMALLINT, VARCHAR, DECIMAL, DATE e **ENUM**
- Definir PKs simples, FKs e relacionamentos 1:N
- Gerar o script SQL e o banco físico via Forward Engineering
- Verificar a estrutura criada no Navigator

---

## 💡 Revisão Rápida — O que há de novo

Nas aulas anteriores você trabalhou com modelos simples (2 tabelas). Agora o modelo cresce:

```
Aulas 04–07:  TabMae ←→ TabFilha  (2 tabelas, 1 relacionamento)
     ↓
Aula 08:  8 tabelas, múltiplos relacionamentos, ENUM, DECIMAL, DATE
```

O tipo **ENUM** é uma novidade: ele restringe os valores que uma coluna pode receber a uma lista pré-definida. Por exemplo, uma coluna `UF` do tipo `ENUM('AC','AL','AM',...)` só aceita siglas válidas de estados brasileiros.

---

## 📋 Exercício

### [Exercício 06 — Criar o DER da Imobiliária](./Exercicio06/README.md)

Você vai construir o DER de um sistema de imobiliária para aluguel de imóveis, com as tabelas: TipoImovel, Cidade, Praia, Proprietario, Imovel, Inquilino, ContratoAluguel, Mobilia e ItensMobilia.

---

> 💡 Ao finalizar este bloco, mantenha o banco criado — você vai usá-lo no Bloco 2 para praticar os comandos DML.
