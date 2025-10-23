import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  DateTime atual = DateTime.now();
  int aba = 3;

  final eventos = [
    {"date": DateTime(2024, 4, 1), "title": "Aniversário do João", "time": "18:30"},
    {"date": DateTime(2024, 4, 12), "title": "Aniversário da Nayara", "time": "20:00"},
    {"date": DateTime(2024, 4, 20), "title": "Reunião no Zoom", "time": "10:30 - 12:30"},
    {"date": DateTime(2024, 5, 5), "title": "Partida de Futebol", "time": "14:30 - 17:30"},
  ];

  List<DateTime> diasDoMes(DateTime d) {
    final fim = DateTime(d.year, d.month + 1, 0);
    return List.generate(fim.day, (i) => DateTime(d.year, d.month, i + 1));
  }

  String mesNome(int m) {
    const meses = [
      "Janeiro","Fevereiro","Março","Abril","Maio","Junho",
      "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"
    ];
    return meses[m - 1];
  }

  String mesCurto(int m) {
    const meses = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
    return meses[m - 1];
  }

  String diaSemanaCurto(int w) {
    const dias = ["Seg","Ter","Qua","Qui","Sex","Sáb","Dom"];
    return dias[w - 1];
  }

  void anterior() {
    setState(() {
      atual = DateTime(atual.year, atual.month - 1, 1);
    });
  }

  void proximo() {
    setState(() {
      atual = DateTime(atual.year, atual.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dias = diasDoMes(atual);
    final tituloMes = "${mesNome(atual.month)} ${atual.year}";
    final agrupado = <String, List<Map<String, dynamic>>>{};
    for (var e in eventos) {
      final d = e["date"] as DateTime;
      final chave = "${mesNome(d.month).toUpperCase()} ${d.year}";
      agrupado.putIfAbsent(chave, () => []);
      agrupado[chave]!.add(e);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        titleSpacing: 8,
        title: Row(
          children: [
            IconButton(onPressed: anterior, icon: const Icon(Icons.chevron_left, color: Colors.black87)),
            Text(tituloMes, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
            IconButton(onPressed: proximo, icon: const Icon(Icons.chevron_right, color: Colors.black87)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.tune, color: Colors.black54),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 78,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dias.length,
              itemBuilder: (context, i) {
                final d = dias[i];
                final selecionado = d.day == atual.day && d.month == atual.month && d.year == atual.year;
                return GestureDetector(
                  onTap: () => setState(() => atual = d),
                  child: Container(
                    width: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(diaSemanaCurto(d.weekday), style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selecionado ? const Color(0xFF5E35B1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF5E35B1)),
                          ),
                          child: Text(
                            "${d.day}",
                            style: TextStyle(
                              color: selecionado ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final chave in agrupado.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
                        child: Text(chave, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: .2)),
                      ),
                      for (final e in agrupado[chave]!)
                        _EventoCard(
                          data: e["date"] as DateTime,
                          titulo: e["title"].toString(),
                          horario: e["time"].toString(),
                          mesCurtoFn: mesCurto,
                        ),
                    ],
                  ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF5E35B1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5E35B1).withOpacity(0.06),
          border: const Border(top: BorderSide(color: Color(0x11000000))),
        ),
        child: BottomNavigationBar(
          currentIndex: aba,
          onTap: (i) => setState(() => aba = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF5E35B1),
          unselectedItemColor: Colors.black45,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.email_outlined), label: 'Email'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt_outlined), label: 'Tarefas'),
            BottomNavigationBarItem(icon: Icon(Icons.video_call_outlined), label: 'Reunião'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.cloud_outlined), label: 'Arquivos'),
          ],
        ),
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final DateTime data;
  final String titulo;
  final String horario;
  final String Function(int) mesCurtoFn;

  const _EventoCard({
    required this.data,
    required this.titulo,
    required this.horario,
    required this.mesCurtoFn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 58,
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mesCurtoFn(data.month), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(data.day.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(horario, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.event_available_outlined, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
