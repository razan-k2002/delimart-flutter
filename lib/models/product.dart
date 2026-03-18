enum ProductType{unit,weight}

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final ProductType type;
  final bool isPopular;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.type,
    this.isPopular=false,
  });
}
