# 🔵 Bloco 1 — Criando o DER e o Modelo Físico no Workbench

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual guiada

---

## 🎯 O que você vai fazer neste bloco

- Criar um novo modelo `.mwb` no MySQL Workbench com duas tabelas
- Configurar uma **PK simples com AUTO_INCREMENT** e uma **PK composta**
- Desenhar o relacionamento 1:N entre as tabelas (FK gerada automaticamente)
- Salvar o modelo (`.mwb`) e gerar o script SQL (`.sql`) via Forward Engineering
- Criar o banco físico no MySQL e verificar a estrutura no Navigator

---

## 💡 Revisão Rápida — O que você já sabe

Nas aulas anteriores você aprendeu:

- **MER** → entidades, atributos e relacionamentos no papel
- **DER** → tabelas, colunas, PKs, FKs e cardinalidades no modelo lógico
- **Forward Engineering** → DER vira banco físico automaticamente

Hoje você aplica tudo isso no Workbench com um modelo novo.

---

## 📋 O modelo desta aula

```
┌──────────────────────────┐         ┌───────────────────────────────────┐
│         TabMae           │         │             TabFilha               │
├──────────────────────────┤         ├───────────────────────────────────┤
│ 🔑 CodTabMae  INT (AI)   │ 1 ──── N│ 🔑 CodTabFilha       INT          │
│    DescMae    VARCHAR(45)│         │ 🔑 TabMae_CodTabMae  INT  (FK)    │
└──────────────────────────┘         │    DescFilha         VARCHAR(45)  │
                                     └───────────────────────────────────┘
```

**Pontos de atenção:**

| Elemento | Detalhe |
|----------|---------|
| `CodTabMae` | PK simples com `AUTO_INCREMENT` — SGBD controla o valor |
| `CodTabFilha` + `TabMae_CodTabMae` | **PK composta** — dois campos juntos identificam o registro |
| `TabMae_CodTabMae` | É **simultaneamente** parte da PK e FK para `TabMae` |

---

## ✏️ Atividade

### [📁 Exercício 01 — Criar o DER e Gerar o Modelo Físico](./Exercicio01/README.md)

**Resumo dos passos:**
1. Criar novo modelo e abrir o canvas EER
2. Adicionar `TabMae` com PK simples + AUTO_INCREMENT
3. Adicionar `TabFilha` com PK composta + FK
4. Criar o relacionamento 1:N no canvas
5. Salvar o arquivo `.mwb`
6. Gerar o script `.sql` via Forward Engineering e salvar
7. Criar o banco físico no MySQL
8. Verificar tabelas e FK no Navigator

---

## ✅ Critérios de conclusão do Bloco 1

- [ ] Arquivo `NovoEsquema.mwb` salvo em pasta organizada
- [ ] Arquivo `NovoEsquema.sql` salvo na mesma pasta
- [ ] Banco físico `mydb` criado com `tabmae` e `tabfilha`
- [ ] PK composta de `tabfilha` visível no Navigator
- [ ] FK `fk_TabFilha_TabMae` visível em Foreign Keys

---

> 💡 **Guarde os dois arquivos** — o Bloco 2 começa exatamente de onde você parou aqui.
