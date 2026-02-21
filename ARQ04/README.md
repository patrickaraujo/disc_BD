# Aula ARQ04 — Modelo Lógico (DER) + Primeira Prática no MySQL Workbench

Bem-vindo à **Aula ARQ04**, a primeira aula com prática guiada da disciplina de **Banco de Dados**. Após três aulas de fundamentos conceituais e modelagem, chegou o momento de colocar as mãos na ferramenta e ver o DER virar banco de dados real.

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

## 🛠️ Pré-requisito: MySQL e MySQL Workbench instalados?

Para acompanhar a parte prática desta aula você precisa ter o **MySQL** e o **MySQL Workbench** instalados e funcionando na sua máquina.

> ⚠️ **Ainda não instalou, ou está com dúvidas na configuração?** Acesse o guia de instalação correspondente ao seu sistema operacional antes de continuar:

➡️ [Guia de Instalação — MySQL e MySQL Workbench](./instalacao/README.md)

O guia cobre instalação no **Windows**, **macOS** e **Linux Mint/Ubuntu**, além de explicar como configurar a conexão no Workbench após a instalação.

---

## 📌 Importante
* Esta é a **primeira aula prática** da disciplina — o objetivo é familiarização com a ferramenta.
* O modelo construído aqui (Estado × Cidade) é simples de propósito: o foco é o **processo**, não a complexidade.
* Nas próximas aulas de laboratório você vai construir modelos com mais tabelas.

---

### Estrutura de pastas da Aula `ARQ04`:

```
ARQ04/
├── Bloco1/
│   └── README.md (Do MER ao DER: revisão conceitual)
├── Bloco2/
│   ├── README.md (Prática no Workbench — Forward Engineering)
│   └── Atividade/
│       └── README.md (Tutorial passo a passo)
├── instalacao/
│   └── README.md (Guia de instalação — Windows, macOS e Linux)
└── README.md (Este arquivo)
```
---

> 💭 *"O DER é o projeto. O Forward Engineering é a obra. Sem um bom projeto, a obra vai ao chão."*
