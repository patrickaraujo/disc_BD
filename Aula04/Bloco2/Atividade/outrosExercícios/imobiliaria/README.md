# Imobiliária - Diagrama de Banco de Dados

## Descrição da Situação-Problema
Seu chefe necessita de ajuda no levantamento das entidades envolvidas no próximo banco de dados a ser desenvolvido. Você precisa realizar o levantamento das entidades para uma escola de ensino fundamental e médio que necessita de um banco de dados para controle acadêmico.
Será necessário armazenar informações sobre alunos, professores, disciplinas, cursos e departamentos. Um dos principais desafios da escola é a geração dos horários dos alunos, considerando que cada aluno pode cursar várias disciplinas em diferentes horários ao longo do período letivo.

---

## Diagrama de Banco de Dados

> Código para uso no [dbdiagram.io](https://dbdiagram.io/)

```
Table TipoImovel {
  IdTpImovel int [pk]
  TipoImovel varchar
}

Table Cidade {
  CodCidade int [pk]
  Cidade varchar
  Campo varchar
}

Table Praia {
  IdPraia int [pk]
  NmPraia varchar
}

Table Proprietario {
  IdProprietario int [pk]
  Nome varchar
  RG varchar
}

Table Imovel {
  NrImovel int [pk]
  QtdeQuartos int
  QtdeBanheiros int
  VistaParaMar boolean
  Endereco varchar
  IdTpImovel int [ref: > TipoImovel.IdTpImovel]
  CodCidade int [ref: > Cidade.CodCidade]
  IdPraia int [ref: > Praia.IdPraia]
  IdProprietario int [ref: > Proprietario.IdProprietario]
}

Table Inquilino {
  CodInquilino int [pk]
  Nome varchar
  CPF varchar
}

Table ContratoAluguel {
  NrContrato int [pk]
  NrImovel int [ref: > Imovel.NrImovel]
  CodInquilino int [ref: > Inquilino.CodInquilino]
  DataContrato date
  CPF varchar
  DtInicio date
  DtFim date
  ValorAluguel decimal
}

Table Mobilia {
  CodMobilia int [pk]
  Descricao varchar
}

Table ItensMobilia {
  CodItensMobilia int [pk]
  CodMobilia int [ref: > Mobilia.CodMobilia]
  NrImovel int [ref: > Imovel.NrImovel]
  Quantidade int
}
```

---

## Explicação das entidades

**TipoImovel** — armazena os tipos possíveis (casa ou apartamento).

**Cidade** — município ao qual o imóvel pertence.

**Praia** — praia mais próxima do imóvel, relacionada a ele.

**Proprietario** — dados do dono do imóvel; um proprietário pode ter vários imóveis.

**Imovel** — entidade central, com quartos, banheiros, vista para o mar, endereço e preço da diária, vinculada ao tipo, cidade, praia e proprietário.

**Inquilino** — armazenado separadamente do proprietário, com nome e CPF.

**ContratoAluguel** — registra o contrato exclusivo entre um inquilino e um imóvel, com datas e valor.

**Mobilia** — catálogo dos itens de mobília (cama, geladeira, freezer, etc.).

**ItensMobilia** — tabela associativa que registra quais móveis estão em cada imóvel e em qual quantidade.
