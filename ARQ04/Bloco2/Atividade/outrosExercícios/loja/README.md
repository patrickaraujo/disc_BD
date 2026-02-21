# Modelo Conceitual - Loja de Artigos de Informática

## Descrição da Situação-Problema

Uma loja que comercializa artigos de informática resolveu expandir a sua forma de atuação no mercado, e passou a aceitar pedidos de compra por telefone. Os clientes, ao ligarem para a loja para fazerem seus pedidos, são obrigados a fornecer o nome, sobrenome, telefone e endereço completo (rua, número, complemento, bairro, cidade, estado, CEP).

Os pedidos de compra são identificados por um número de controle, e contém as informações da data em que foi feito o pedido, e a forma de pagamento (cheque, dinheiro, ou cartão).

Os artigos comercializados na loja possuem um código, nome e preço unitário.

---

## Diagrama de Banco de Dados

> Código para uso no [dbdiagram.io](https://dbdiagram.io/)

```
Table Clientes {
  id_cliente int [pk]
  nome varchar
  sobrenome varchar
  telefone varchar

  rua varchar
  numero varchar
  complemento varchar
  bairro varchar
  cidade varchar
  estado varchar
  cep varchar
}

Table Pedidos {
  numero_pedido int [pk]
  data_pedido date
  forma_pagamento varchar

  id_cliente int [not null, ref: > Clientes.id_cliente]
}

Table Artigos {
  codigo_artigo int [pk]
  nome varchar
  preco_unitario decimal
}

Table Itens_Pedido {
  numero_pedido int [ref: > Pedidos.numero_pedido]
  codigo_artigo int [ref: > Artigos.codigo_artigo]
  quantidade int
  preco_unitario_no_momento decimal
  indexes {
    (numero_pedido, codigo_artigo) [pk]
  }
}
```
