import 'package:flutter/material.dart';

void main() => runApp(const CartAppBasico());

class CartAppBasico extends StatelessWidget {
  const CartAppBasico({super.key});

  @override
  Widget build(BuildContext context) {
    const imgUrl = 'https://static.netshoes.com.br/produtos/tenis-asics-gel-impression-11-feminino/24/2FW-0180-324/2FW-0180-324_zoom1.jpg?ts=1760238654&ims=1088x';

    Widget produtoCard() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(3),
        constraints: const BoxConstraints(minHeight: 130),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(imgUrl, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Air Max 270 React', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Color: ', style: TextStyle(color: Colors.black54)),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      const Text('Size: M', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('R\$ 150,00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                          const SizedBox(width: 6),
                          const Text('1'),
                          const SizedBox(width: 6),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: const Icon(Icons.add, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: const Color(0xFFFFEFF0), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFD93025)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black), onPressed: () {}),
          actions: [IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black), onPressed: () {})],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('CART', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    ),
                    produtoCard(),
                    produtoCard(),
                    produtoCard(),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Subtotal:', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        Text('R\$ 450,00', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4CF4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
