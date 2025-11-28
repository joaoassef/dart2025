import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

// Lista global de palavras aprendidas
List<String> learnedWords = [];

// ========= FUNÇÃO SEM REGEXP (COMPATÍVEL COM DART NOVO) =========
String cleanWord(String w) {
  return w.split('').where((c) {
    final code = c.codeUnitAt(0);
    return (code >= 48 && code <= 57) || // 0–9
        (code >= 65 && code <= 90) || // A–Z
        (code >= 97 && code <= 122) || // a–z
        (code == 95); // underscore
  }).join('');
}

// ====================== TELA PRINCIPAL ===========================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();
  String paragraph = "";
  bool loading = false;
  List<String> words = [];

  // --- Buscar parágrafo da Wikipedia ---
  Future<void> loadWikipedia() async {
    setState(() => loading = true);

    try {
      final response = await http.get(Uri.parse(controller.text));
      final document = parser.parse(response.body);

      final p = document.querySelector('p');
      paragraph = p?.text ?? "Parágrafo não encontrado.";

      words = paragraph.split(' ');
    } catch (e) {
      paragraph = "Erro ao carregar página.";
      words = [];
    }

    setState(() => loading = false);
  }

  bool isLearned(String w) => learnedWords.contains(w.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("English with Wikipedia"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Cole o link da Wikipedia (em inglês)",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loadWikipedia,
              child: const Text("Carregar texto"),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading && words.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: words.map((w) {
                      final clean = cleanWord(w);
                      if (clean.isEmpty) return const SizedBox();

                      if (isLearned(clean)) {
                        return Chip(
                          label: Text(
                            clean,
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          backgroundColor: Colors.black12,
                        );
                      }

                      return ActionChip(
                        label: Text(clean),
                        backgroundColor: Colors.blue[50],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DefinitionPage(word: clean.toLowerCase()),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ====================== TELA DE DEFINIÇÃO ===========================
class DefinitionPage extends StatefulWidget {
  final String word;
  const DefinitionPage({required this.word, super.key});

  @override
  State<DefinitionPage> createState() => _DefinitionPageState();
}

class _DefinitionPageState extends State<DefinitionPage> {
  bool loading = true;
  String definition = "";
  String? audioUrl;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  Future<void> loadDefinition() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://api.dictionaryapi.dev/api/v2/entries/en/${widget.word}"),
      );

      if (response.statusCode != 200) {
        definition = "Definição não encontrada.";
      } else {
        final data = jsonDecode(response.body)[0];

        definition = data["meanings"]?[0]?["definitions"]?[0]?["definition"] ??
            "Definição não encontrada.";

        final audio = data["phonetics"]?[0]?["audio"];
        audioUrl = (audio is String && audio.isNotEmpty) ? audio : null;
      }
    } catch (e) {
      definition = "Erro ao buscar definição.";
    }

    setState(() => loading = false);
  }

  Future<void> playAudio() async {
    if (audioUrl == null) return;
    final player = AudioPlayer();
    await player.play(UrlSource(audioUrl!));
  }

  void markAsLearned() {
    if (!learnedWords.contains(widget.word)) {
      learnedWords.add(widget.word);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word),
        backgroundColor: Colors.blue,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Definition:",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    definition,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 25),
                  if (audioUrl != null)
                    ElevatedButton.icon(
                      onPressed: playAudio,
                      icon: const Icon(Icons.volume_up),
                      label: const Text("Ouvir Pronúncia"),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: markAsLearned,
                    child: const Text("Compreendi"),
                  ),
                ],
              ),
            ),
    );
  }
}
