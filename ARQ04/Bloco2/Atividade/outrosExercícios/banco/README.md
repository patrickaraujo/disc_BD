# Modelo Conceitual - Instituição Bancária

## Descrição da Situação-Problema

Uma instituição bancária deseja controlar o movimento de suas contas-corrente. A instituição possui agências espalhadas por várias cidades, e o seu cadastro contém informações sobre o código, nome e endereço onde a agência fica localizada. No cadastro de clientes, deve-se manter informações sobre nome, CPF e endereço de cada cliente. As informações sobre contas-corrente são identificadas por um número, e devem fornecer o saldo atualizado das mesmas.

---

## Diagrama de Banco de Dados

> Código para uso no [dbdiagram.io](https://dbdiagram.io/)

```
Table Agencias {
  codigo_agencia int [pk]
  nome varchar
  endereco varchar
  cidade varchar
}

Table Clientes {
  cpf varchar [pk]
  nome varchar
  endereco varchar
}

Table Contas_Corrente {
  numero_conta int [pk]
  saldo decimal
  codigo_agencia int [not null, ref: > Agencias.codigo_agencia]
}

Table Cliente_Conta {
  cpf varchar [ref: > Clientes.cpf]
  numero_conta int [ref: > Contas_Corrente.numero_conta]
  indexes {
    (cpf, numero_conta) [pk]
  }
}
```
