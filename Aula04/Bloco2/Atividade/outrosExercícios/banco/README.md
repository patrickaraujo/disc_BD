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
