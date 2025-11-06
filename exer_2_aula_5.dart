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

  Future<void> _abrirEAtualizar(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _carregarPreferencias();
  }

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(backgroundColor: _buttonColor);

    return Scaffold(
      appBar: AppBar(title: const Text('Contador + Drawer')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text('Menu', style: TextStyle(fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Ajustar contador'),
              onTap: () => _abrirEAtualizar(const AjusteContadorPage()),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Tamanho da fonte'),
              onTap: () => _abrirEAtualizar(const TamanhoFontePage()),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Cor'),
              onTap: () => _abrirEAtualizar(const CorBotoesPage()),
            ),
          ],
        ),
      ),
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
          ],
        ),
      ),
    );
  }
}

class AjusteContadorPage extends StatefulWidget {
  const AjusteContadorPage({super.key});

  @override
  State<AjusteContadorPage> createState() => _AjusteContadorPageState();
}

class _AjusteContadorPageState extends State<AjusteContadorPage> {
  final _controller = TextEditingController();
  int _atual = 0;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _atual = prefs.getInt('contador') ?? 0;
    });
    _controller.text = _atual.toString();
  }

  Future<void> _salva(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('contador', valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustar contador')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Valor atual: $_atual', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Novo valor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final txt = _controller.text.trim();
                final valor = int.tryParse(txt);
                if (valor == null) return;
                _salva(valor).then((_) => Navigator.pop(context));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class TamanhoFontePage extends StatefulWidget {
  const TamanhoFontePage({super.key});

  @override
  State<TamanhoFontePage> createState() => _TamanhoFontePageState();
}

class _TamanhoFontePageState extends State<TamanhoFontePage> {
  double _fontSize = 48.0;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 48.0;
    });
  }

  Future<void> _salva(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tamanho da fonte')),
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _salva(_fontSize);
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

class CorBotoesPage extends StatefulWidget {
  const CorBotoesPage({super.key});

  @override
  State<CorBotoesPage> createState() => _CorBotoesPageState();
}

class _CorBotoesPageState extends State<CorBotoesPage> {
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

  int _selecionada = Colors.blue.value;

  @override
  void initState() {
    super.initState();
    _carrega();
  }

  Future<void> _carrega() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selecionada = prefs.getInt('buttonColor') ?? Colors.blue.value;
    });
  }

  Future<void> _salva(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('buttonColor', colorValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cor dos botões')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _opcoes.map((c) {
                final isSelected = _selecionada == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _selecionada = c.value),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: isSelected ? 4 : 2,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _salva(_selecionada);
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
