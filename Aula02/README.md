# Aula 02 - Arquitetura de Sistemas de BD e Primeiros Passos na Modelagem

Bem-vindo à segunda aula da disciplina de **Banco de Dados**. Nesta etapa, vamos além dos conceitos básicos e começamos a entender como sistemas de BD são estruturados, quem trabalha com eles, e daremos os primeiros passos práticos na modelagem de dados.

## 🎯 Objetivos da Aula
* Compreender a arquitetura de sistemas de banco de dados.
* Conhecer os diferentes papéis profissionais (DBA, analista, programador, usuário).
* Entender o conceito de mini-mundo e sua importância.
* Instalar e configurar o MySQL Community.
* Iniciar o processo de modelagem conceitual.
* Criar seu primeiro schema no MySQL Workbench.

---

## 📂 Organização dos Blocos

Esta aula está dividida em quatro blocos fundamentais:

### [Bloco 01 — Arquitetura de Sistemas de BD e Papéis Profissionais](./Bloco1/README.md)
* **Foco:** Compreender como sistemas de BD são organizados em camadas e quem trabalha com eles.
* **Destaque:** Arquitetura em três níveis (externo, conceitual, interno) e os diferentes papéis: DBA, analista de dados, desenvolvedor e usuário final.

### [Bloco 02 — Mini-Mundo e a Importância da Modelagem](./Bloco2/README.md)
* **Foco:** Entender por que modelar antes de criar o banco de dados.
* **Destaque:** Conceito de mini-mundo, identificação de entidades e atributos, e os problemas de criar tabelas sem planejamento.

### [Bloco 03 — Instalação e Configuração do MySQL Community](./Bloco3/README.md)
* **Foco:** Preparação do ambiente de desenvolvimento.
* **Destaque:** Passo a passo completo para instalar o MySQL Community Server e o MySQL Workbench, configurar o serviço e realizar a primeira conexão.

### [Bloco 04 — Primeiros Passos Práticos: Criando seu Primeiro Schema](./Bloco4/README.md)
* **Foco:** Colocar a mão na massa.
* **Destaque:** Navegação avançada no Workbench, criação do primeiro schema vazio, e preparação para as próximas aulas de SQL.

---

## 🚀 Como estudar este conteúdo
1. Comece pelo **Bloco 1** para entender a arquitetura e os papéis profissionais.
2. Siga para o **Bloco 2** para compreender a importância da modelagem.
3. Continue no **Bloco 3** para instalar o MySQL (se ainda não tiver).
4. Finalize com o **Bloco 4** criando seu primeiro schema na prática.

---

## 📌 Importante
* Esta aula **mistura teoria e prática**.
* Você vai instalar software no seu computador.
* Começará a pensar como um modelador de dados.
* Criará estruturas vazias (sem SQL ainda).

---

## 🔗 Conexão com a Aula Anterior

Na Aula 01 você aprendeu:
- ✅ O que são dados e informação
- ✅ A Pirâmide DIKW
- ✅ Diferença entre BD, SGBD e Sistema de BD
- ✅ Como observar dados no MySQL Workbench

Agora você vai:
- 🆕 Entender quem trabalha com BD e como
- 🆕 Começar a **criar** ao invés de apenas observar
- 🆕 Aprender a **pensar** antes de **fazer**

---

### Estrutura de pastas da `Aula02`:

```
Aula02/
├── Bloco1/
│   ├── README.md (Arquitetura e Papéis)
│   └── Atividade1/
│       └── README.md
├── Bloco2/
│   ├── README.md (Mini-Mundo e Modelagem)
│   └── Atividade2/
│       └── README.md
├── Bloco3/
│   ├── README.md (Instalação MySQL)
│   └── guia-instalacao/
│       ├── windows.md
│       ├── linux.md
│       └── macos.md
├── Bloco4/
│   ├── README.md (Criando Schema)
│   └── Atividade4/
│       └── README.md
└── README.md (Este arquivo introdutório da Aula 02)
```

---

## ⚠️ Pré-requisitos

Antes de iniciar esta aula:
- ✅ Ter concluído a Aula 01
- ✅ Compreender o que é um SGBD
- ✅ Ter acesso administrativo ao seu computador (para instalação)
- ✅ Ter pelo menos 2GB de espaço livre em disco

---

> 💭 *"A diferença entre um banco de dados bem projetado e um mal projetado é a modelagem. SQL não conserta arquitetura ruim."*
