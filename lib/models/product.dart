import 'package:isar/isar.dart';

part 'product.g.dart';

@Collection()
class Product {
  Id id = Isar.autoIncrement;

  late String name;
  late double price;
  late int stockQuantity;
  late String category;
}