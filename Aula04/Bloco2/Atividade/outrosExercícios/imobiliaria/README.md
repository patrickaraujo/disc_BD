# Imobiliária - Diagrama de Banco de Dados

## Descrição da Situação-Problema
Uma imobiliária especializada em aluguel de casas e apartamentos do litoral de Santa Catarina necessita de um software para ajudar no gerenciamento dos aluguéis e oferecer melhores ofertas para seus clientes. Após diversos contatos com a imobiliária, ficou estabelecido que os seguintes requisitos deveriam ser atendidos pelo banco de dados:

- **Para cada imóvel deverá ter registrado:** seu tipo (casa ou apartamento), quantidade de quartos e banheiros, se possui vista para o mar e preço da diária.

- As informações dos proprietários e dos inquilinos deverão ser armazenadas separadamente. Os proprietários podem ter vários imóveis que podem ser alugados para vários inquilinos.

- Além das informações sobre o município ao qual o imóvel pertence, deverá também ser informado o nome da praia mais próxima a ele.

- Os imóveis são todos os itens que compõem a mobília, e os mais verificados são: cama, geladeira, freezer, televisor, ar-condicionado, entre outros. Neste caso, é importante que seja informada a quantidade de cada item.

- Deverá ser realizado e registrado um contrato exclusivo para os aluguéis com os inquilinos e os imóveis respectivamente alugados por eles.

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
