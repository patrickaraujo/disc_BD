# Aula 04 — Modelo Lógico (DER) + Primeira Prática no MySQL Workbench

Bem-vindo à **Aula 04**, a primeira aula com prática guiada da disciplina de **Banco de Dados**. Após três aulas de fundamentos conceituais e modelagem, chegou o momento de colocar as mãos na ferramenta e ver o DER virar banco de dados real.

## 🎯 Objetivos da Aula
* Consolidar os conceitos do Modelo Lógico (DER): tabelas, atributos, chaves e cardinalidades.
* Compreender os tipos de chave: primária, composta, substituta, secundária e estrangeira.
* Criar um DER no MySQL Workbench usando o editor visual (EER Diagram).
* Executar o **Forward Engineering** para gerar o banco físico automaticamente.
* Verificar na prática o funcionamento da integridade referencial.

---

## 📂 Organização dos Blocos

### [Bloco 01 — Do MER ao DER: Revisão e Preparação para a Prática](./Bloco1/README.md)
* **Foco:** Revisão conceitual do DER antes de usar a ferramenta.
* **Destaque:** Tipos de chave (PK, composta, surrogate, secundária, FK), notação de Pé-de-Galinha e Dicionário de Dados.

### [Bloco 02 — Mãos na Massa: DER e Modelo Físico no MySQL Workbench](./Bloco2/README.md)
* **Foco:** Prática guiada no MySQL Workbench.
* **Destaque:** Criar tabelas, definir colunas e chaves, relacionar tabelas e gerar o banco físico via Forward Engineering.
  * [Tutorial Passo a Passo — Forward Engineering](./Bloco2/Atividade/README.md)

---

## 🚀 Como estudar este conteúdo
1. Leia o **Bloco 1** para revisar os conceitos e entender o que você vai fazer na ferramenta.
2. Abra o **MySQL Workbench** e siga o tutorial do **Bloco 2** passo a passo.
3. Não pule etapas — cada clique no Workbench corresponde a uma decisão de modelagem que você aprendeu na teoria.

---

## 📌 Importante
* Esta é a **primeira aula prática** da disciplina — o objetivo é familiarização com a ferramenta.
* O modelo construído aqui (Estado × Cidade) é simples de propósito: o foco é o **processo**, não a complexidade.
* Nas próximas aulas de laboratório você vai construir modelos com mais tabelas.

---

## 📍 Posição no Cronograma

| Aula | Data | Conteúdo |
|------|------|----------|
| 01 | 04/02 | Apresentação, plano pedagógico, contexto (ARQ01) |
| 02 | 09/02 | Introdução a BD — SGBD, arquitetura, papéis (ARQ02) |
| 03 | 11/02, 23/02, 25/02 | Modelagem Conceitual — MER (ARQ03) |
| **04** | **04/03** | **← VOCÊ ESTÁ AQUI** — DER + primeira prática no Workbench (ARQ04) |
| 05 | 09/03 | Laboratório — DER completo no Workbench |
| 06 | 11/03 | Normalização — 1ª a 4ª Forma Normal |

---

### Estrutura de pastas da `Aula04`:

```
Aula04/
├── Bloco1/
│   └── README.md (Do MER ao DER: revisão conceitual)
├── Bloco2/
│   ├── README.md (Prática no Workbench — Forward Engineering)
│   └── Atividade/
│       └── README.md (Tutorial passo a passo)
└── README.md (Este arquivo)
```

---

> 💭 *"O DER é o projeto. O Forward Engineering é a obra. Sem um bom projeto, a obra vai ao chão."*
