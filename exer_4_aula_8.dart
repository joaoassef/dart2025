import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WikiEnglishApp(),
    ),
  );
}

// ==================== LISTA GLOBAL DE PALAVRAS APRENDIDAS ====================
List<String> learnedWords = [];

// ==================== LIMPAR PALAVRAS ====================
String cleanWord(String w) {
  return w
      .split('')
      .where((c) {
        final code = c.codeUnitAt(0);
        return (code >= 48 && code <= 57) || // 0-9
            (code >= 65 && code <= 90) || // A-Z
            (code >= 97 && code <= 122) || // a-z
            (code == 95); // underscore
      })
      .join('');
}

// ==================== TELA PRINCIPAL ====================
class WikiEnglishApp extends StatefulWidget {
  const WikiEnglishApp({super.key});

  @override
  State<WikiEnglishApp> createState() => _WikiEnglishAppState();
}

class _WikiEnglishAppState extends State<WikiEnglishApp> {
  final TextEditingController controller = TextEditingController();
  String paragraph = "";
  List<String> words = [];
  bool loading = false;

  Future<void> loadParagraph() async {
    setState(() {
      loading = true;
      paragraph = "";
      words = [];
    });

    try {
      final response = await http.get(Uri.parse(controller.text));
      final document = parser.parse(response.body);
      final p = document.querySelector('p');

      if (p == null) {
        paragraph = "Parágrafo não encontrado.";
        words = [];
      } else {
        paragraph = p.text;
        words = paragraph
            .split(' ')
            .map(cleanWord)
            .where((w) => w.isNotEmpty)
            .toList();
      }
    } catch (e) {
      paragraph = "Erro ao carregar página.";
      words = [];
    }

    setState(() {
      loading = false;
    });
  }

  bool isLearned(String w) {
    return learnedWords.contains(w.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wiki English"),
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
                labelText: "Cole o link da Wikipedia em inglês",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loadParagraph,
              child: const Text("Carregar Parágrafo"),
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
                      if (w.isEmpty) return const SizedBox();

                      if (isLearned(w)) {
                        return Chip(
                          label: Text(
                            w,
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          backgroundColor: Colors.black12,
                        );
                      }

                      return ActionChip(
                        label: Text(w),
                        backgroundColor: Colors.blue[50],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DefinitionPage(word: w.toLowerCase()),
                            ),
                          ).then(
                            (_) => setState(() {}),
                          ); // Atualiza após voltar
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

// ==================== TELA DE DEFINIÇÃO ====================
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
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  Future<void> loadDefinition() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://api.dictionaryapi.dev/api/v2/entries/en/${widget.word}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)[0];

        try {
          definition = data["meanings"][0]["definitions"][0]["definition"];
        } catch (_) {
          definition = "Definição não encontrada.";
        }

        try {
          audioUrl = data["phonetics"][0]["audio"];
          if (audioUrl != null && audioUrl!.isEmpty) audioUrl = null;
        } catch (_) {}
      } else {
        definition = "Definição não encontrada.";
      }
    } catch (e) {
      definition = "Erro ao buscar definição.";
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> playAudio() async {
    if (audioUrl != null) {
      await player.play(UrlSource(audioUrl!));
    }
  }

  void markAsLearned() {
    if (!learnedWords.contains(widget.word)) {
      learnedWords.add(widget.word);
    }
    Navigator.pop(context); // volta para o texto
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.word), backgroundColor: Colors.blue),
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
                  Text(definition, style: const TextStyle(fontSize: 18)),
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
