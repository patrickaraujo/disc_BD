# Modelo Conceitual - Locadora de Fitas de Vídeo

## Descrição da Situação-Problema

Uma pequena locadora de fitas de vídeo possui cerca de 3000 fitas cujas locações devem ser controladas. Cada fita possui um número e para cada filme é necessário saber seu título e sua categoria (comédia, drama, aventura, etc). Para cada filme há pelo menos uma fita e cada fita contém somente um filme.

Os clientes podem desejar locar os filmes estrelados pelo seu ator predileto. Por isso, é necessário manter a informação dos atores que estrelam cada filme. Nem todo filme possui estrelas. Para cada ator os clientes podem desejar saber o nome real, bem como a data de nascimento.

A locadora possui muitos clientes cadastrados, cada um podendo ter vários dependentes, que também podem locar fitas sob a responsabilidade do cliente cadastrado. Um cliente só é cadastrado quando loca uma fita, podendo cadastrar também todos os seus dependentes.

O proprietário da locadora deseja saber que fitas cada cliente tem emprestadas e a data de devolução de cada uma delas, mantendo um registro histórico das fitas locadas por cada cliente.

---

## Diagrama de Banco de Dados

> Código para uso no [dbdiagram.io](https://dbdiagram.io/)

```
Table Filmes {
  id_filme int [pk]
  titulo varchar
  categoria varchar
}

Table Fitas {
  numero_fita int [pk]
  id_filme int [not null, ref: > Filmes.id_filme]
}

Table Atores {
  id_ator int [pk]
  nome_real varchar
  data_nascimento date
}

Table Filme_Ator {
  id_filme int [ref: > Filmes.id_filme]
  id_ator int [ref: > Atores.id_ator]
  indexes {
    (id_filme, id_ator) [pk]
  }
}

Table Clientes {
  id_cliente int [pk]
  nome varchar
  telefone varchar
  endereco varchar
}

Table Dependentes {
  id_dependente int [pk]
  id_cliente int [not null, ref: > Clientes.id_cliente]
  nome varchar
  data_nascimento date
}

Table Locacoes {
  id_locacao int [pk]
  numero_fita int [not null, ref: > Fitas.numero_fita]
  id_cliente int [ref: > Clientes.id_cliente]
  id_dependente int [ref: > Dependentes.id_dependente]
  data_locacao date
  data_devolucao_prevista date
  data_devolucao_real date
}
```
