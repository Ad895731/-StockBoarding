import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/add_product_page.dart';
void main() {
  runApp(const SmartStockApp());
}

class SmartStockApp extends StatelessWidget {
  const SmartStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartStock AI',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<dynamic>> products;

  @override
  void initState() {
    super.initState();
    products = ApiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartStock AI'),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductPage(),
      ),
    );

    if (result == true) {
      setState(() {
        products = ApiService.getProducts();
      });
    }
  },
  child: const Icon(Icons.add),
),
      body: FutureBuilder<List<dynamic>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final productList = snapshot.data ?? [];

          if (productList.isEmpty) {
            return const Center(
              child: Text('No products found'),
            );
          }

          return ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];

              return ListTile(
                title: Text(product['name']),
                subtitle: Text(
                  '${product['brand'] ?? ''} • ₹${product['selling_price'] ?? ''}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
