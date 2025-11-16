import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hello_web/localizacao.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String la = '';
  String lo = '';

  double? temperatura;
  double? umidade;
  double? velocidadeVento;

  String? erro;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    inicial();
  }

  Future<void> inicial() async {
    try {
      // 1. Pega a localização atual
      var contLocalizacao = ContLocalizacao();
      await contLocalizacao.mostraLaLo();

      final lat = contLocalizacao.latitude;
      final lon = contLocalizacao.longitude;

      // 2. Busca o clima na API do OpenWeather
      final dadosClima = await buscarClima(lat, lon);

      setState(() {
        la = lat.toStringAsFixed(5);
        lo = lon.toStringAsFixed(5);
        temperatura = dadosClima['temp'];
        umidade = dadosClima['humidity'];
        velocidadeVento = dadosClima['wind_speed'];
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  Future<Map<String, double>> buscarClima(double latitude, double longitude) async {
    const apiKey = 'c1ade390f11942d76c77c177f48a8aa5'; 
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=pt_br';

    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar clima: ${resposta.statusCode}');
    }

    final body = jsonDecode(resposta.body);

    final temp = (body['main']['temp'] as num).toDouble();
    final humidity = (body['main']['humidity'] as num).toDouble();
    final windSpeed = (body['wind']['speed'] as num).toDouble();

    return {
      'temp': temp,
      'humidity': humidity,
      'wind_speed': windSpeed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Clima pela Localização'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: carregando
                ? const CircularProgressIndicator()
                : erro != null
                    ? Text(
                        'Erro: $erro',
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Localização Atual',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Latitude: $la'),
                          Text('Longitude: $lo'),
                          const SizedBox(height: 24),
                          const Text(
                            'Condições do Tempo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Temperatura: ${temperatura?.toStringAsFixed(1)} °C'),
                          Text('Umidade: ${umidade?.toStringAsFixed(0)} %'),
                          Text('Velocidade do vento: ${velocidadeVento?.toStringAsFixed(1)} m/s'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                carregando = true;
                              });
                              inicial(); 
                            },
                            child: const Text('Atualizar'),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
