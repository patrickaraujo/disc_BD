# Modelo Conceitual - Clínica Veterinária

## Descrição da Situação-Problema

Uma clínica veterinária, especializada no tratamento de cães e gatos, pretende informatizar o seu sistema de controle de vacinas, de forma a melhorar a notificação aos clientes sobre a data e o tipo de vacina a ser aplicada em qualquer um dos animais cadastrados na clínica.

Os clientes, quando são cadastrados na clínica, são identificados por um código numérico, e devem fornecer o nome, sobrenome, telefone e endereço completo (rua, número, complemento, bairro, cidade, estado, CEP).

Para cada animal, que também é identificado por um código numérico, são registrados o nome, data de nascimento, espécie, raça, cor e sexo.

As vacinas, por sua vez, também são identificadas por um código numérico, e possuem nome, nome do laboratório, fabricante, e lote de fabricação.

Quando o animal é vacinado, deve ser feito o registro da data de aplicação, o código da próxima vacina a ser tomada, e a respectiva data.

---

## Diagrama de Banco de Dados

> Código para uso no [dbdiagram.io](https://dbdiagram.io/)

```
Table Clinica {
  codigo_clinica int [pk]
  nome varchar
  telefone varchar

  rua varchar
  numero varchar
  bairro varchar
  cidade varchar
  estado varchar
  cep varchar
}

Table Departamentos {
  codigo_departamento int [pk]
  nome varchar
  codigo_clinica int [ref: > Clinica.codigo_clinica]
}

Table Cargos {
  codigo_cargo int [pk]
  nome varchar
}

Table Funcionarios {
  cpf varchar [pk]
  nome varchar
  endereco varchar

  codigo_departamento int [ref: > Departamentos.codigo_departamento]
  supervisor_cpf varchar [ref: > Funcionarios.cpf]
}

Table Historico_Cargo {
  id int [pk]
  cpf_funcionario varchar [ref: > Funcionarios.cpf]
  codigo_cargo int [ref: > Cargos.codigo_cargo]
  data_inicio date
  data_fim date
}

Table Clientes {
  codigo_cliente int [pk]
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

  codigo_clinica int [ref: > Clinica.codigo_clinica]
}

Table Animais {
  codigo_animal int [pk]
  codigo_cliente int [ref: > Clientes.codigo_cliente]

  nome varchar
  data_nascimento date
  especie varchar
  raca varchar
  cor varchar
  sexo varchar
}

Table Vacinas {
  codigo_vacina int [pk]
  nome varchar
  laboratorio varchar
  fabricante varchar
  lote_fabricacao varchar
}

Table Vacinacao {
  id int [pk]

  codigo_animal int [ref: > Animais.codigo_animal]
  codigo_vacina int [ref: > Vacinas.codigo_vacina]
  cpf_funcionario varchar [ref: > Funcionarios.cpf]

  data_aplicacao date

  proxima_vacina int [ref: > Vacinas.codigo_vacina]
  data_proxima_aplicacao date
}
```
