# 📝 Exercício 01 — Criar o DER e Gerar o Modelo Físico

> **Duração:** ~25 minutos  
> **Formato:** Individual  
> **Ferramentas:** MySQL Workbench + MySQL Server

---

## 🎯 Objetivo

Criar um DER completo no Workbench a partir do modelo abaixo, salvar o arquivo `.mwb`, gerar o script SQL via Forward Engineering e criar o banco físico no MySQL.

---

## 📋 Modelo a implementar

Você vai criar duas tabelas com um relacionamento 1:N entre elas:

```
┌──────────────────────────┐         ┌───────────────────────────────────┐
│         TabMae           │         │             TabFilha              │
├──────────────────────────┤         ├───────────────────────────────────┤
│ 🔑 CodTabMae  INT (AI)   │ 1 ──── N│ 🔑 CodTabFilha       INT          │
│    DescMae    VARCHAR(45)│         │ 🔑 TabMae_CodTabMae  INT    (FK)  │
└──────────────────────────┘         │    DescFilha         VARCHAR(45)  │
                                     └───────────────────────────────────┘
```

**Atenção às chaves:**
- `TabMae`: PK simples com `AUTO_INCREMENT`
- `TabFilha`: PK **composta** — `CodTabFilha` + `TabMae_CodTabMae` juntos formam a chave primária
- `TabMae_CodTabMae` é simultaneamente parte da PK e FK para `TabMae`

---

## 🖥️ Passo a Passo

### Parte A — Criar o DER no Workbench

1. Abra o **MySQL Workbench**
2. Conecte à instância local (`Local instance MySQL80`)
3. Crie um **novo modelo**: `File → New Model` (`Ctrl+N`)
4. Clique em **"Add Diagram"** para abrir o canvas EER
5. Adicione a tabela **TabMae** com as colunas:

   | Column Name | Datatype    | PK | NN | AI |
   |-------------|-------------|----|----|-----|
   | CodTabMae   | INT         | ✅ | ✅ | ✅ |
   | DescMae     | VARCHAR(45) |    | ✅ |    |

6. Adicione a tabela **TabFilha** com as colunas:

   | Column Name      | Datatype    | PK | NN |
   |------------------|-------------|----|----|
   | CodTabFilha      | INT         | ✅ | ✅ |
   | DescFilha        | VARCHAR(45) |    | ✅ |
   | TabMae_CodTabMae | INT         | ✅ | ✅ |

   > 💡 Para a PK composta, marque **PK em duas colunas**: `CodTabFilha` e `TabMae_CodTabMae`. O Workbench cria a chave primária composta automaticamente.

7. Na barra lateral, selecione o conector **1:n** e clique primeiro em **TabFilha** depois em **TabMae** para criar o relacionamento

8. Verifique o DER — deve estar semelhante a:

```
TabMae ──────────────────< TabFilha
(CodTabMae PK, AI)         (CodTabFilha + TabMae_CodTabMae: PK composta)
                            (TabMae_CodTabMae: FK → TabMae)
```

9. **Salve o modelo**: `File → Save Model` → escolha uma pasta e nomeie como `NovoEsquema.mwb`

---

### Parte B — Gerar o Script SQL

1. Com o modelo salvo, acesse **Database → Forward Engineer...** (`Ctrl+G`)
2. Selecione a conexão `Local instance MySQL80` → **Next**
3. Mantenha as opções padrão → **Next**
4. Confirme que as 2 tabelas estão selecionadas → **Next**
5. Na tela **Review SQL Script**, clique em **"Save to File..."**
6. Salve o script na mesma pasta com o nome `NovoEsquema.sql`
7. Anote o trecho gerado — ele deve ser parecido com:

```sql
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`TabMae`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`TabMae` (
  `CodTabMae` INT NOT NULL AUTO_INCREMENT,
  `DescMae` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CodTabMae`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`TabFilha`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`TabFilha` (
  `CodTabFilha` INT NOT NULL,
  `TabFilhacol` VARCHAR(45) NOT NULL,
  `TabMae_CodTabMae` INT NOT NULL,
  PRIMARY KEY (`CodTabFilha`),
  INDEX `fk_TabFilha_TabMae_idx` (`TabMae_CodTabMae` ASC) VISIBLE,
  CONSTRAINT `fk_TabFilha_TabMae`
    FOREIGN KEY (`TabMae_CodTabMae`)
    REFERENCES `mydb`.`TabMae` (`CodTabMae`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
```

8. Clique em **Next**, digite a senha do `root` e confirme
9. Aguarde: **"Forward Engineer Finished Successfully"** → **Close**

---

### Parte C — Verificar o banco criado

1. Clique na aba **"Local instance MySQL80"**
2. No painel **Schemas**, pressione o botão de **refresh** (🔄) se necessário
3. Expanda `mydb → Tables`
4. Confirme que `tabmae` e `tabfilha` aparecem com suas colunas

✅ **Checkpoint:** As duas tabelas existem no servidor com a estrutura correta.

---

## ✅ Critérios de conclusão

- [ ] Arquivo `NovoEsquema.mwb` salvo
- [ ] Arquivo `NovoEsquema.sql` salvo
- [ ] Banco físico criado no MySQL com as tabelas `tabmae` e `tabfilha`
- [ ] PK composta de `TabFilha` visível no Navigator (`CodTabFilha + TabMae_CodTabMae`)
- [ ] FK `fk_TabFilha_TabMae` visível em `tabfilha → Foreign Keys`

---

> 💡 **Guarde os arquivos `.mwb` e `.sql`** — você vai precisar deles no Exercício 02!
