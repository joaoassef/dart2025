import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CounterScreen()));

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Contador de Carreiras', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => count = count > 0 ? count - 1 : 0),
                    child: const Text('-1'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => count++),
                    child: const Text('+1'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => count = 0),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
