import 'package:flutter/material.dart';
import 'package:merryjays_pos/models/product.dart';
import 'package:merryjays_pos/services/isar_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class PosScreen extends StatefulWidget {
  final IsarService isarService;

  const PosScreen({super.key, required this.isarService});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<CartItem> _cart = [];

  void _addToCart(Product product) {
    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item is out of stock!')),
      );
      return;
    }

    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        if (_cart[existingIndex].quantity < product.stockQuantity) {
          _cart[existingIndex].quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot add more than available stock!')),
          );
        }
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  double get _totalAmount {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _processCheckout() async {
    if (_cart.isEmpty) return;

    for (var item in _cart) {
      await widget.isarService.reduceStock(item.product.id, item.quantity);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale completed successfully! Inventory updated.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _cart.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merryjays POS Terminal'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Available Products Grid/List (Top Half)
          Expanded(
            flex: 1,
            child: StreamBuilder<List<Product>>(
              stream: widget.isarService.listenToProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products available for sale.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return InkWell(
                      onTap: () => _addToCart(product),
                      child: Card(
                        color: product.stockQuantity > 0
                            ? Colors.deepPurple.shade50
                            : Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('KSh ${product.price.toStringAsFixed(2)}'),
                              Text(
                                'Stock: ${product.stockQuantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product.stockQuantity > 0 ? Colors.grey[700] : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1, thickness: 2),

          // Active Cart Section (Bottom Half)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text('Tap items above to add to cart'))
                        : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          dense: true,
                          title: Text(item.product.name),
                          subtitle: Text(
                            'KSh ${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'KSh ${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => _removeFromCart(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: KSh ${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _cart.isEmpty ? null : _processCheckout,
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text('Checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}