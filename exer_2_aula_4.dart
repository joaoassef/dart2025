import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CotacaoPage(),
    );
  }
}

class CotacaoPage extends StatefulWidget {
  const CotacaoPage({super.key});

  @override
  State<CotacaoPage> createState() => _CotacaoPageState();
}

class _CotacaoPageState extends State<CotacaoPage> {
  bool _loading = false;
  String? _erro;
  String? _high;
  String? _low;
  String? _atualizado;

  Future<void> _buscar() async {
    setState(() {
      _loading = true;
      _erro = null;
      _high = null;
      _low = null;
      _atualizado = null;
    });

    try {
      final url = Uri.parse('https://economia.awesomeapi.com.br/last/USD-BRL');
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final usdb = data['USDBRL'];

        if (usdb == null) {
          setState(() => _erro = 'Resposta inesperada da API.');
        } else {
          String formatar(String v) {
            final d = double.tryParse(v.replaceAll(',', '.'));
            return d == null ? v : d.toStringAsFixed(2);
          }

          setState(() {
            _high = formatar(usdb['high'] ?? '');
            _low = formatar(usdb['low'] ?? '');
            _atualizado = usdb['create_date']?.toString();
          });
        }
      } else {
        setState(() => _erro = 'Erro ${resp.statusCode} ao consultar a API.');
      }
    } catch (e) {
      setState(() => _erro = 'Falha de rede: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _card(String titulo, String valor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 16)),
            Text('R\$ $valor', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temDados = _high != null && _low != null;

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _buscar,
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Verificar cotação do Dolar!'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_erro != null)
                  Text(_erro!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                if (temDados) ...[
                  _card('Maior cotação (high)', _high!),
                  _card('Menor cotação (low)', _low!),
                  if (_atualizado != null) ...[
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
