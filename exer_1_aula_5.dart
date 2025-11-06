import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _contador = 0;
  double _fontSize = 48.0;
  int _buttonColorValue = Colors.blue.value;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contador = prefs.getInt('contador') ?? 0;
      _fontSize = prefs.getDouble('fontSize') ?? 48.0;
      _buttonColorValue = prefs.getInt('buttonColor') ?? Colors.blue.value;
    });
  }

  Future<void> _salvarContador(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('contador', valor);
  }

  Color get _buttonColor => Color(_buttonColorValue);

  Future<void> _abrirAjustes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjustesPage()),
    );
    await _carregarPreferencias(); 
  }

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(backgroundColor: _buttonColor);

    return Scaffold(
      appBar: AppBar(title: const Text('Contador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Contagem: $_contador', style: TextStyle(fontSize: _fontSize)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: btnStyle,
                  onPressed: () async {
                    setState(() => _contador--);
                    await _salvarContador(_contador);
                  },
                  child: const Text('Reduzir'),
                ),
                ElevatedButton(
                  style: btnStyle,
                  onPressed: () async {
                    setState(() => _contador++);
                    await _salvarContador(_contador);
                  },
                  child: const Text('Aumentar'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _abrirAjustes,
              child: const Text('Ajustes (fonte e cor)'),
            ),
          ],
        ),
      ),
    );
  }
}

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  double _fontSize = 48.0;
  int _colorValue = Colors.blue.value;

  final List<Color> _opcoes = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 48.0;
      _colorValue = prefs.getInt('buttonColor') ?? Colors.blue.value;
    });
  }

  Future<void> _salva() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setInt('buttonColor', _colorValue);
  }

  @override
  Widget build(BuildContext context) {
    final corAtual = Color(_colorValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Pré-visualização', style: TextStyle(fontSize: _fontSize)),
            const SizedBox(height: 16),
            Slider(
              value: _fontSize,
              min: 16,
              max: 72,
              divisions: 56,
              label: _fontSize.toStringAsFixed(0),
              onChanged: (v) => setState(() => _fontSize = v),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Cor dos botões:'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _opcoes.map((c) {
                final selected = _colorValue == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c.value),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: selected ? 4 : 2,
                        color: selected ? Colors.black : Colors.white,
                      ),
                      boxShadow: const [BoxShadow(blurRadius: 3, offset: Offset(0, 2))],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: corAtual),
              onPressed: () async {
                await _salva();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
