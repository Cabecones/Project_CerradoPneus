import '../providers/product.dart';

final DUMMY_PRODUCTS = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red! ',
      price: 29.99,
      discountPercentage: 10,
      rating: 4.5,
      stock: 10,
      brand: 'Nike',
      category: 'Shirt',
      thumbnail:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
      image:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      discountPercentage: 10,
      rating: 4.5,
      stock: 10,
      brand: 'Nike',
      category: 'Pants',
      thumbnail:
          'https://cdn.pixabay.com/photo/2023/05/30/17/25/door-8029228_1280.jpg',
      image:
          'https://cdn.pixabay.com/photo/2023/05/30/17/25/door-8029228_1280.jpg',
    ),
  ];