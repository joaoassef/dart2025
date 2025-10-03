void main() {
  DateTime agora = DateTime.now();

  int informado = 12;
  int atual = agora.month;

  if (informado > atual) {
    print('O mês $atual é menor que o mês $informado');
  } else if (informado == atual) {
    print('O mês $atual é igual ao mês $informado');
  } else {
    print('O mês $atual é maior que o mês $informado');
  }
  
}
