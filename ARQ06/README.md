# Aula ARQ06 — Praticar a Construção do DER e Modelo Físico com o Workbench

Bem-vindo à **Aula ARQ06**, aula de laboratório da disciplina de **Banco de Dados**. O foco desta aula é 100% prático: você vai criar um DER no Workbench, gerar o banco físico, destruí-lo, recriá-lo a partir do script e, por fim, praticar os principais comandos DDL do SQL diretamente no Query Editor.

## 🎯 Objetivos da Aula
* Criar um DER com PK simples, PK composta e FK no MySQL Workbench.
* Salvar o modelo (`.mwb`) e gerar o script de criação (`.sql`) via Forward Engineering.
* Comprovar que o script recria o banco independentemente do Workbench.
* Executar e compreender os principais comandos DDL: `CREATE`, `DROP`, `ALTER TABLE`, `DESCRIBE`, `SHOW`.

---

## 📂 Organização dos Blocos

### [Bloco 01 — Criando o DER e o Modelo Físico no Workbench](./Bloco1/README.md)
* **Foco:** Criar o DER com duas tabelas (TabMae e TabFilha), gerar o script via Forward Engineering e verificar o banco criado.
* **Exercício:**
  * [Exercício 01 — Criar o DER e Gerar o Modelo Físico](./Bloco1/Exercicio01/README.md)

### [Bloco 02 — Recriar via Script e Praticar DDL Manual](./Bloco2/README.md)
* **Foco:** Destruir e recriar o banco via script; executar comandos DDL manualmente para entender a sintaxe por trás da ferramenta.
* **Exercícios:**
  * [Exercício 02 — Apagar o Schema e Recriar via Script](./Bloco2/Exercicio02/README.md)
  * [Exercício 03 — Praticando SQL Manualmente (DDL)](./Bloco2/Exercicio03/README.md)

---

## 🚀 Como estudar este conteúdo
1. No **Bloco 1**, siga o Exercício 01 do início ao fim — não pule etapas.
2. **Guarde os arquivos** `.mwb` e `.sql` antes de passar para o Bloco 2.
3. No **Bloco 2**, comece pelo Exercício 02 (apagar e recriar via script), depois avance para o Exercício 03 (DDL manual).
4. Ao finalizar o Exercício 03, restaure o `mydb` a partir do script — isso garante continuidade nas próximas aulas.

---

## 📌 Importante
* Esta é uma aula de **laboratório** — sem exposição teórica. Dúvidas conceituais: consulte os READMEs da Aula 04.
* Os arquivos `.mwb` e `.sql` gerados hoje serão usados nas próximas aulas — **não os apague**.
* Se travar em algum passo, consulte o [Tutorial da Aula 04](../Aula04/Bloco2/Atividade/README.md) como referência.

---

## 📍 Posição no Cronograma

| Aula | Data | Conteúdo |
|------|------|----------|
| 01 | 04/02 | Apresentação, plano pedagógico, contexto (ARQ01) |
| 02 | 09/02 | Introdução a BD — SGBD, arquitetura, papéis (ARQ02) |
| 03 | 11/02, 23/02, 25/02 | Modelagem Conceitual — MER (ARQ03) |
| 04 | 04/03 | DER + primeira prática no Workbench (ARQ04) |
| **05** | **09/03** | **← VOCÊ ESTÁ AQUI** — Laboratório: DER, Forward Engineering e DDL manual (ARQ06) |
| 06 | 11/03 | Normalização — 1ª a 4ª Forma Normal |

---

### Estrutura de pastas da Aula `ARQ06`:

```
ARQ06/
├── Bloco1/
│   ├── README.md
│   └── Exercicio01/
│       └── README.md (Criar DER e Modelo Físico)
├── Bloco2/
│   ├── README.md
│   ├── Exercicio02/
│   │   └── README.md (Apagar e recriar via script)
│   └── Exercicio03/
│       └── README.md (DDL manual — 12 comandos)
└── README.md (Este arquivo)
```

---

> 💭 *"O Workbench gera o SQL por você — mas entender o SQL garante que você não depende do Workbench."*
