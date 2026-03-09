# Aula ARQ07 — Sincronização DER ↔ Banco de Dados + Tipos de Dados no MySQL

Bem-vindo à **Aula ARQ07**, aula de laboratório da disciplina de **Banco de Dados**. O foco desta aula é resolver um problema real que surge quando alteramos a estrutura do banco: **como manter o DER e o banco físico sempre sincronizados?** Além disso, você vai conhecer as propriedades das colunas e os tipos de dados disponíveis no MySQL.

## 🎯 Objetivos da Aula
* Compreender o risco de desatualização entre o DER e o banco físico ao executar comandos manuais.
* Alterar o DER no Workbench e sincronizar as mudanças com o banco via **Forward Engineering (Synchronize Model)**.
* Alterar o banco físico via SQL e sincronizar o DER via **Reverse Engineering**.
* Conhecer as propriedades de colunas do Workbench (PK, NN, UQ, UN, ZF, AI, G, B).
* Consultar a referência completa dos tipos de dados do MySQL (numéricos, data/hora e texto).

---

## 📂 Organização dos Blocos

### [Bloco 01 — Do DER para o Banco: Forward Engineering Sync](./Bloco1/README.md)
* **Foco:** Alterar o DER (modelo `.mwb`) e propagar as mudanças para o banco físico sem recriá-lo do zero.
* **Exercício:**
  * [Exercício 04 — Alterar o DER e Sincronizar com o BD](./Bloco1/Exercicio04/README.md)

### [Bloco 02 — Do Banco para o DER: Reverse Engineering + Referência de Tipos](./Bloco2/README.md)
* **Foco:** Alterar o banco físico via SQL e gerar/atualizar o DER a partir do banco existente. Material de referência sobre propriedades de colunas e tipos de dados.
* **Exercício:**
  * [Exercício 05 — Alterar o BD e Sincronizar com o DER](./Bloco2/Exercicio05/README.md)
* **Material de Referência:**
  * [Propriedades de Colunas no Workbench](./Bloco2/referencia/propriedades-colunas.md)
  * [Tipos de Dados do MySQL](./Bloco2/referencia/tipos-de-dados.md)

---

## 🚀 Como estudar este conteúdo
1. Certifique-se de ter o schema `mydb` com `TabMae` e `TabFilha` criados (resultado da Aula 06).
2. No **Bloco 1**, siga o Exercício 04 — altere o DER e sincronize com o banco.
3. Consulte o **material de referência** do Bloco 2 para entender as propriedades de colunas e tipos de dados.
4. No **Bloco 2**, siga o Exercício 05 — altere o banco e sincronize com o DER.
5. Ao finalizar, garanta que DER e banco estejam sincronizados para as próximas aulas.

---

## 📌 Importante
* O problema central desta aula é a **desatualização** — se você altera o banco manualmente (como fez no Exercício 03), o DER fica desatualizado e vice-versa.
* Existem **duas direções** de sincronização: DER → BD (Forward) e BD → DER (Reverse). Você precisa dominar ambas.
* Ao executar scripts de alteração, respeite sempre a **ordem**: script principal primeiro, depois os scripts de alteração na sequência (2, 3, 4, ... N).

---

## 📍 Posição no Cronograma

| Aula | Data | Conteúdo |
|------|------|----------|
| 01 | 04/02 | Apresentação, plano pedagógico, contexto (ARQ01) |
| 02 | 09/02 | Introdução a BD — SGBD, arquitetura, papéis (ARQ02) |
| 03 | 11/02, 23/02, 25/02 | Modelagem Conceitual — MER (ARQ03) |
| 04 | 04/03 | DER + primeira prática no Workbench (ARQ04) |
| 05 | 09/03 | Normalização — 1ª a 4ª Forma Normal (ARQ05) |
| 06 | 11/03 | Laboratório: DER, Forward Engineering e DDL manual (ARQ06) |
| **07** | **16/03** | **← VOCÊ ESTÁ AQUI** — Sincronização DER ↔ BD + Tipos de Dados (ARQ07) |

---

### Estrutura de pastas da Aula `ARQ07`:

```
ARQ07/
├── Bloco1/
│   ├── README.md (Forward Engineering Sync)
│   └── Exercicio04/
│       └── README.md (Alterar DER → Sincronizar com BD)
├── Bloco2/
│   ├── README.md (Reverse Engineering + Referência)
│   ├── Exercicio05/
│   │   └── README.md (Alterar BD → Sincronizar com DER)
│   └── referencia/
│       ├── propriedades-colunas.md (PK, NN, UQ, UN, ZF, AI, G, B)
│       └── tipos-de-dados.md (Numéricos, Data/Hora, Texto)
└── README.md (Este arquivo)
```

---

> 💭 *"Alterar o banco sem atualizar o DER é como reformar a casa sem atualizar a planta — na próxima obra, ninguém sabe o que tem por trás da parede."*
