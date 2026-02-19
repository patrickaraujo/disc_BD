# Controle de Contas-Corrente Bancárias

## Descrição da Situação-Problema

Uma instituição bancária deseja controlar o movimento de suas contas-corrente. A instituição possui agências espalhadas por várias cidades, e o seu cadastro contém informações sobre o código, nome e endereço onde a agência fica localizada. No cadastro de clientes, deve-se manter informações sobre nome, CPF e endereço de cada cliente. As informações sobre contas-corrente são identificadas por um número, e devem fornecer o saldo atualizado das mesmas.

---

## Diagrama de Banco de Dados

> Código para uso no [dbdiagram.io](https://dbdiagram.io/)

```
Table Departamento {
  Cod_Dep int [pk]
  Nome varchar
}

Table Curso {
  Cod_Curso int [pk]
  Nome varchar
  Sigla varchar
  Cod_Dep int [ref: > Departamento.Cod_Dep]
}

Table Curriculo {
  Cod_Curriculo int [pk]
  Cod_Curso int [ref: > Curso.Cod_Curso]
  Cod_Disc int [ref: > Disciplina.Cod_Disc]
  Carga_Horaria int
}

Table Disciplina {
  Cod_Disc int [pk]
  Nome varchar
  Ementa text
  Sigla varchar
  Cod_Dep int [ref: > Departamento.Cod_Dep]
}

Table Professor {
  Mat_Prof int [pk]
  Nome varchar
  Dt_Nasc date
  Dt_Adm date
  Formacao varchar
  Foto varchar
  Cod_Dep int [ref: > Departamento.Cod_Dep]
}

Table Aluno {
  Mat_Aluno int [pk]
  Nome varchar
  Email varchar
  Endereco varchar
  Cod_Curso int [ref: > Curso.Cod_Curso]
}

Table Prof_Disc {
  Cod_Prof_Disc int [pk]
  Mat_Prof int [ref: > Professor.Mat_Prof]
  Cod_Disc int [ref: > Disciplina.Cod_Disc]
}

Table Turma {
  Cod_Turma int [pk]
  Nome varchar
  Ano int
  Semestre int
  Cod_Curso int [ref: > Curso.Cod_Curso]
}

Table Sala {
  Cod_Sala int [pk]
  Nome varchar
  Capacidade int
}

Table Horario {
  Cod_Horario int [pk]
  Mat_Prof int [ref: > Professor.Mat_Prof]
  Cod_Turma int [ref: > Turma.Cod_Turma]
  Cod_Disc int [ref: > Disciplina.Cod_Disc]
  Cod_Sala int [ref: > Sala.Cod_Sala]
  Dia_Semana varchar
  Hora_Inicio time
  Hora_Fim time
}
```
