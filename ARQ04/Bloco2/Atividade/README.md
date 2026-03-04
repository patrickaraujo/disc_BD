# 🛠️ Tutorial — Forward Engineering no MySQL Workbench

> **Duração estimada:** 30 minutos  
> **Formato:** Prática individual guiada  
> **Objetivo:** Criar um DER no MySQL Workbench e gerar o banco de dados físico automaticamente via Forward Engineering

---

## 🎯 O que você vai aprender

Ao final deste tutorial, você será capaz de:

- Criar um novo modelo (`.mwb`) no MySQL Workbench
- Adicionar tabelas e definir colunas, tipos e chaves (PK)
- Criar relacionamentos entre tabelas (FK gerada automaticamente)
- Executar o **Forward Engineering** para gerar o banco físico no MySQL
- Verificar as tabelas criadas no servidor

---

## 📋 Pré-requisitos

- MySQL Server instalado e rodando (`localhost:3306`)
- MySQL Workbench instalado
- Conexão local configurada (`Local instance MySQL80`)

---

## 🖥️ Passo a Passo

---

### Passo 1 — Abrir o MySQL Workbench e conectar

1. Abra o **MySQL Workbench**
2. Na tela inicial, você verá a seção **MySQL Connections**
3. Clique duas vezes em **"Local instance MySQL80"**
4. Digite a senha do usuário `root` quando solicitado e clique em **OK**

✅ **Checkpoint:** Você está conectado. O ambiente principal do Workbench abre com o painel de Schemas à esquerda e o Query Editor ao centro.

---

### Passo 2 — Criar um novo modelo (arquivo `.mwb`)

O modelo é o arquivo onde o DER será desenhado. É diferente da conexão ao servidor.

1. No menu superior, clique em **File → New Model** (`Ctrl+N`)
2. Uma nova aba **"MySQL Model"** abre
3. Você verá a seção **Physical Schemas** com um schema padrão chamado `mydb`
4. Clique em **"Add Diagram"** para abrir o canvas do EER Diagram

✅ **Checkpoint:** O canvas do EER Diagram abre — uma grade em branco onde você vai desenhar as tabelas.

---

### Passo 3 — Adicionar tabelas ao diagrama

Na barra de ferramentas lateral do canvas, localize o ícone de tabela (parece uma grade pequena) e clique nele para ativar o modo de inserção de tabela.

1. Com o modo de tabela ativo, **clique no canvas** para posicionar a primeira tabela — ela aparece como `table1`
2. Clique novamente em outro ponto do canvas para posicionar a segunda tabela — `table2`

> 💡 Você pode reposicionar as tabelas arrastando-as pelo canvas a qualquer momento.

---

### Passo 4 — Configurar a primeira tabela

1. **Clique duas vezes** sobre `table1` para abrir o editor de tabela no painel inferior
2. No campo **Table Name**, substitua `table1` pelo nome desejado — exemplo: `Estado`
3. Na grade de colunas, adicione os campos clicando na linha em branco:

| Column Name | Datatype     | PK | NN |
|-------------|--------------|----|----|
| SiglaUF     | VARCHAR(2)   | ✅ | ✅ |
| Estado      | VARCHAR(45)  |    | ✅ |

- **PK** = Primary Key (marque para o campo identificador)
- **NN** = Not Null (campo obrigatório)

> 💡 O ícone de chave amarela (🔑) indica a coluna PK. O ícone de losango azul indica coluna comum.

---

### Passo 5 — Configurar a segunda tabela

1. Clique duas vezes sobre `table2` e renomeie para `Cidade`
2. Adicione os campos:

| Column Name | Datatype     | PK | NN | AI |
|-------------|--------------|----|----|-----|
| CodCidade   | INT          | ✅ | ✅ | ✅ |
| Cidade      | VARCHAR(45)  |    | ✅ |    |

- **AI** = Auto Increment — o SGBD preenche o valor automaticamente ([chave substituta/surrogate](./rodape/SurrogateKey.md))

> 💡 **CodCidade** é um exemplo de **chave substituta (surrogate key)**: um inteiro auto-incremento criado pelo SGBD quando não existe um campo naturalmente único na entidade.

---

### Passo 6 — Criar o relacionamento entre as tabelas

O relacionamento define a **chave estrangeira (FK)** automaticamente.

1. Na barra lateral, localize o conector identificador **1:n** ([relacionamento identificador um para muitos](./rodape/Relacionamentos-id_Nid.md)) e clique nele
2. Clique primeiro na tabela **filho** (`Cidade`) e depois na tabela **pai** (`Estado`)
3. O Workbench cria a FK automaticamente: a coluna `Estado_SiglaUF` aparece em `Cidade`

> 💡 **Pé-de-Galinha:** a ponta do conector na tabela `Cidade` indica o lado "muitos" (N). A ponta reta em `Estado` indica o lado "um" (1). Um estado pode ter muitas cidades; cada cidade pertence a um estado.

✅ **Checkpoint:** Seu DER está pronto com duas tabelas e um relacionamento 1:N.

---

### Passo 7 — Forward Engineering: gerar o banco físico

Agora vamos transformar o DER em banco de dados real no MySQL.

1. No menu superior, clique em **Database → Forward Engineer...** (`Ctrl+G`)
2. **Connection Options:** confirme que a conexão é `Local instance MySQL80` e clique em **Next**
3. **Options:** mantenha as opções padrão e clique em **Next**
4. **Select Objects:** o Workbench lista os objetos a exportar — confirme que as 2 tabelas estão selecionadas (`2 Total Objects, 2 Selected`) e clique em **Next**
5. **Review SQL Script:** você verá o script SQL que será executado. Você pode **salvar o script** clicando em "Save to File..." antes de continuar

```sql
-- Trecho do script gerado automaticamente pelo Workbench:

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
-- Table `mydb`.`Estado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Estado` (
  `UF` VARCHAR(2) NOT NULL,
  `Estado` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`UF`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Cidade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Cidade` (
  `codCidade` INT NOT NULL AUTO_INCREMENT,
  `Cidade` VARCHAR(45) NOT NULL,
  `Estado_UF` VARCHAR(2) NOT NULL,
  PRIMARY KEY (`codCidade`, `Estado_UF`),
  INDEX `fk_Cidade_Estado_idx` (`Estado_UF` ASC) VISIBLE,
  CONSTRAINT `fk_Cidade_Estado`
    FOREIGN KEY (`Estado_UF`)
    REFERENCES `mydb`.`Estado` (`UF`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
```

> 💡 Observe que a FK `Estado_SiglaUF` foi gerada automaticamente a partir do relacionamento que você desenhou.

6. Salve o script se desejar, então clique em **Next**
7. Digite a senha do `root` quando solicitado
8. **Commit Progress:** aguarde a conclusão. Você verá todos os itens com ✅:

```
✅ Connect to DBMS
✅ Execute Forward Engineered Script
✅ Read Back Changes Made by Server
✅ Save Synchronization State

Forward Engineer Finished Successfully
```

9. Clique em **Close**

---

### Passo 8 — Verificar o banco criado no servidor

1. Clique na aba **"Local instance MySQL80"** (a conexão ao servidor)
2. No painel **Schemas** à esquerda, expanda `mydb → Tables`
3. Você verá as tabelas `cidade` e `estado` com suas colunas listadas

✅ **Checkpoint:** O banco físico foi criado! O DER que você desenhou virou estrutura real no MySQL.

---

### Passo 9 — BÔNUS: Inserir dados e consultar

Com o banco criado, você pode inserir dados e verificar a integridade referencial na prática.

No Query Editor, execute:

```sql
-- Selecionar o schema
USE mydb;

-- Inserir um estado
INSERT INTO Estado VALUES ('SP', 'SÃO PAULO');

-- Consultar o estado inserido
SELECT * FROM Estado;
```

Agora insira uma cidade vinculada ao estado:

```sql
-- Inserir cidade com FK válida
INSERT INTO Cidade (Cidade, Estado_siglaUF) VALUES ('CARAPICUÍBA', 'SP');

-- Tentar inserir cidade com FK inválida (vai falhar!)
INSERT INTO Cidade (Cidade, Estado_siglaUF) VALUES ('CARAPICUÍBA', 'RJ');
-- Erro: Cannot add or update a child row: a foreign key constraint fails

-- Consultar as tabelas
SELECT * FROM Estado;
SELECT * FROM Cidade;
```

> 💡 **Integridade Referencial na prática:** o MySQL bloqueou a inserção de uma cidade com `estado_siglaUF = 'RJ'` porque não existe o estado `'RJ'` cadastrado. A FK garante que os dados sempre sejam consistentes.

---

## ✅ Resumo do Tutorial

Neste tutorial você aprendeu a:

- Criar um modelo `.mwb` no MySQL Workbench
- Adicionar tabelas com colunas, tipos e chaves (PK simples e surrogate key)
- Criar relacionamentos 1:N que geram FKs automaticamente
- Executar o Forward Engineering para gerar o script SQL e criar o banco físico
- Verificar as tabelas criadas e testar a integridade referencial com INSERTs

---

## 🎯 Conceitos-chave fixados

💡 **Forward Engineering = DER → Banco Físico (script SQL gerado automaticamente)**

💡 **FK gerada automaticamente pelo relacionamento no canvas**

💡 **Integridade Referencial = MySQL rejeita dados inconsistentes na FK**

💡 **AUTO_INCREMENT = chave substituta gerenciada pelo SGBD**

---

## ➡️ Próximos Passos

Nas próximas aulas você vai:

- Construir um DER mais complexo com mais tabelas no Workbench (**Aula 09/03 — Laboratório**)
- Aprender o processo de Normalização para validar a estrutura do DER (**Aula 11/03**)

---

> 💭 *"O Workbench não escreve o SQL por mágica — ele traduz as decisões que você tomou no DER. Quanto melhor o modelo, melhor o banco."*
