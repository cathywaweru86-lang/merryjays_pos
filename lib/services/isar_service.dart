import 'package:isar/isar.dart';
import '../models/product.dart';

class IsarService {
  final Isar isar;

  IsarService(this.isar);

  // 1. CREATE / ADD PRODUCT
  Future<void> addProduct(Product newProduct) async {
    await isar.writeTxn(() async {
      await isar.products.put(newProduct);
    });
  }

  // 2. READ / GET ALL PRODUCTS
  Future<List<Product>> getAllProducts() async {
    return await isar.products.where().findAll();
  }

  // 3. LISTEN TO PRODUCTS (Live updates for UI)
  Stream<List<Product>> listenToProducts() async* {
    yield* isar.products.where().watch(fireImmediately: true);
  }

  // 4. UPDATE PRODUCT
  Future<void> updateProduct(Product updatedProduct) async {
    await isar.writeTxn(() async {
      await isar.products.put(updatedProduct);
    });
  }

  // 5. UPDATE STOCK AFTER SALE
  Future<void> reduceStock(int productId, int quantitySold) async {
    await isar.writeTxn(() async {
      final product = await isar.products.get(productId);
      if (product != null && product.stockQuantity >= quantitySold) {
        product.stockQuantity -= quantitySold;
        await isar.products.put(product);
      }
    });
  }

  // 6. DELETE PRODUCT
  Future<bool> deleteProduct(int id) async {
    return await isar.writeTxn(() async {
      return await isar.products.delete(id);
    });
  }
}