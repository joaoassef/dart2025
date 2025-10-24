import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegar por IDs',
      debugShowCheckedModeBanner: false,
      home: const AlbumViewer(),
    );
  }
}

class AlbumViewer extends StatefulWidget {
  const AlbumViewer({super.key});

  @override
  State<AlbumViewer> createState() => _AlbumViewerState();
}

class _AlbumViewerState extends State<AlbumViewer> {
  int _id = 1; // começa no ID 1
  String? _title;
  String? _error;
  bool _loading = false;

  // limite superior da API de exemplo (jsonplaceholder tem 100 álbuns)
  static const int _minId = 1;
  static const int _maxId = 100;

  @override
  void initState() {
    super.initState();
    _fetchAlbum(_id);
  }

  Future<void> _fetchAlbum(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _title = data['title']?.toString();
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Falha na conexão: $e';
        _title = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _next() {
    if (_id < _maxId) {
      setState(() => _id += 1);
      _fetchAlbum(_id);
    } else {
      _showLimit('Você já está no último ID ($_maxId).');
    }
  }

  void _prev() {
    if (_id > _minId) {
      setState(() => _id -= 1);
      _fetchAlbum(_id);
    } else {
      _showLimit('Você já está no primeiro ID ($_minId).');
    }
  }

  void _showLimit(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ID atual: $_id', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                if (_loading) const CircularProgressIndicator(),
                if (!_loading && _error != null)
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (!_loading && _error == null && _title != null)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Título:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _title!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _id == _minId || _loading ? null : _prev,
                      child: const Text('Anterior'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _id == _maxId || _loading ? null : _next,
                      child: const Text('Próximo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
