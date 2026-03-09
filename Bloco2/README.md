# 🟢 Bloco 2 — Do Banco para o DER: Reverse Engineering + Referência de Tipos

> **Duração estimada:** 50 minutos  
> **Local:** Laboratório  
> **Formato:** Prática individual + consulta de referência

---

## 🎯 O que você vai fazer neste bloco

- Alterar o banco físico via SQL e gerar/atualizar o DER a partir do banco via **Reverse Engineering**
- Consultar a referência de propriedades de colunas do Workbench (PK, NN, UQ, UN, ZF, AI, G, B)
- Consultar a referência completa dos tipos de dados do MySQL (numéricos, data/hora, texto)

---

## 💡 Quando usar cada direção?

No Bloco 1, você aprendeu o caminho **DER → BD** (Forward Engineering Sync). Agora vai aprender o caminho inverso: **BD → DER** (Reverse Engineering).

```
Situação A: Você tem o DER e quer atualizar o banco
  → Altera o DER → Synchronize Model → BD atualizado
  → Exercício 04 (Bloco 1)

Situação B: Você alterou o banco (ou recebeu um banco sem DER) e precisa do modelo
  → Altera o BD via SQL → Reverse Engineering → DER gerado/atualizado
  → Exercício 05 (este bloco)
```

| Situação | Direção | Ferramenta |
|----------|---------|-----------|
| Projeto novo, equipe disciplinada | DER → BD | Synchronize Model |
| Correção urgente em produção | BD → DER | Reverse Engineering |
| Banco legado sem documentação | BD → DER | Reverse Engineering |
| Evolução planejada do modelo | DER → BD | Synchronize Model |

---

## ✏️ Atividades

### [📁 Exercício 05 — Alterar o BD e Sincronizar com o DER](./Exercicio05/README.md)

Você vai executar um comando `ALTER TABLE` diretamente no banco e, em seguida, usar o **Reverse Engineering** para gerar um DER atualizado a partir do banco.

**Objetivo:** Comprovar que o Workbench pode "ler" a estrutura do banco e gerar o modelo visual automaticamente.

---

## 📚 Material de Referência

### [📋 Propriedades de Colunas no Workbench](./referencia/propriedades-colunas.md)

Quando você cria colunas no Workbench, há várias checkboxes disponíveis (PK, NN, UQ, UN, ZF, AI, G, B). Consulte este material para entender o que cada uma faz.

### [📋 Tipos de Dados do MySQL](./referencia/tipos-de-dados.md)

Referência completa dos tipos de dados organizados em três categorias: numéricos, data/hora e texto. Use como consulta rápida ao definir colunas nas suas tabelas.

---

## ✅ Critérios de conclusão do Bloco 2

- [ ] Banco físico alterado via SQL (nova coluna ou tabela adicionada)
- [ ] Reverse Engineering executado com sucesso
- [ ] DER gerado reflete a estrutura atual do banco
- [ ] Material de referência consultado (propriedades de colunas e tipos de dados)

---

## 🎯 O que você aprendeu nesta aula

```
Problema: Alterar BD manualmente → DER desatualizado
                                    ↓
Solução 1 (Exercício 04):   Altera DER → Synchronize Model → BD atualizado
Solução 2 (Exercício 05):   Altera BD  → Reverse Engineering → DER atualizado

Complemento: Propriedades de colunas + Tipos de dados do MySQL
```

> 💭 *"Alterar o banco sem atualizar o DER é como reformar a casa sem atualizar a planta — na próxima obra, ninguém sabe o que tem por trás da parede."*
