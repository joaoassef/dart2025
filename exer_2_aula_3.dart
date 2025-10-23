import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() {

  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const ConsumoApp());
  });
}

class ConsumoApp extends StatelessWidget {
  const ConsumoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consumo',
      debugShowCheckedModeBanner: false,
      home: const ConsumoScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E35B1)),
        useMaterial3: true,
      ),
    );
  }
}

class ConsumoScreen extends StatefulWidget {
  const ConsumoScreen({super.key});

  @override
  State<ConsumoScreen> createState() => _ConsumoScreenState();
}

class _ConsumoScreenState extends State<ConsumoScreen> {
  final kmCtrl = TextEditingController();
  final litrosCtrl = TextEditingController();
  final historico = <Map<String, dynamic>>[];
  int aba = 1;

  @override
  void dispose() {
    kmCtrl.dispose();
    litrosCtrl.dispose();
    super.dispose();
  }

  void calcular() {
    final km = double.tryParse(kmCtrl.text.replaceAll(',', '.'));
    final lt = double.tryParse(litrosCtrl.text.replaceAll(',', '.'));
    if (km == null || lt == null || lt == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe valores válidos')));
      return;
    }
    final c = km / lt;
    final d = DateTime.now();
    setState(() {
      historico.insert(0, {"data": d, "consumo": c});
      kmCtrl.clear();
      litrosCtrl.clear();
    });
  }

  void limparHistorico() {
    if (historico.isEmpty) return;
    setState(() {
      historico.clear();
    });
  }

  String fData(DateTime d) => DateFormat('dd/MM').format(d);
  String fMes(DateTime d) => DateFormat('MMM', 'pt_BR').format(d).toUpperCase();
  String fConsumo(double v) => "${v.toStringAsFixed(1)} km/l";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo de Combustível'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: kmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quilômetros',
                        hintText: 'ex: 425.7',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: litrosCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Litros',
                        hintText: 'ex: 29.4',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: calcular,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Calcular'),
                ),
              ),
              const SizedBox(height: 16),

              
              historico.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0), 
                        child: Text('Sem lançamentos'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(), 
                      itemCount: historico.length,
                      itemBuilder: (context, i) {
                        final item = historico[i];
                        final d = item["data"] as DateTime;
                        final v = item["consumo"] as double;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xfff5f5f7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(fMes(d), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(height: 2),
                                    Text(fData(d), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(fConsumo(v), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Registro ${i + 1}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.local_gas_station_outlined, color: Colors.black54),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: limparHistorico,
        child: const Icon(Icons.delete),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: aba,
        onTap: (i) => setState(() => aba = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5E35B1),
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), label: 'Calcular'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Opções'),
        ],
      ),
    );
  }
}
