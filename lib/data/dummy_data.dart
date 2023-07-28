// import 'package:ecommerce/models/brand.dart';
// import 'package:ecommerce/models/category.dart';
// import 'package:ecommerce/models/product_item.dart';
// import 'package:ecommerce/models/type.dart';

// const availableCategories = [
//   Category(
//     id: 'c1',
//     name: 'Engine Oil',
//   ),
//   Category(
//     id: 'c2',
//     name: 'Brake Pad',
//   ),
//   Category(
//     id: 'c3',
//     name: 'Coolant',
//   ),
//   Category(
//     id: 'c4',
//     name: 'Tire',
//   ),
//   Category(
//     id: 'c5',
//     name: 'Battery',
//   ),
//   Category(
//     id: 'c6',
//     name: 'Car Filters',
//   ),
//   Category(
//     id: 'c7',
//     name: 'Timing Belt',
//   ),
// ];

// const availableType = [
//   Type(
//     id: 'g1',
//     type: 'Genuine',
//   ),
//   Type(
//     id: 'g2',
//     type: 'Not Genuine',
//   ),
// ];

// const availableBrands = [
//   Brand(
//     id: 'b1',
//     brand: 'Castrol',
//   ),
//   Brand(
//     id: 'b2',
//     brand: 'Shell',
//   ),
//   Brand(
//     id: 'b3',
//     brand: 'Avid',
//   ),
//   Brand(
//     id: 'b4',
//     brand: 'Sram',
//   ),
//   Brand(
//     id: 'b5',
//     brand: 'Valvoline',
//   ),
//   Brand(
//     id: 'b6',
//     brand: 'Motocraft',
//   ),
//   Brand(
//     id: 'b7',
//     brand: 'Yokohama',
//   ),
//   Brand(
//     id: 'b8',
//     brand: 'Bridgestone',
//   ),
//   Brand(
//     id: 'b9',
//     brand: 'Amaron',
//   ),
//   Brand(
//     id: 'b10',
//     brand: 'Banner',
//   ),
//   Brand(
//     id: 'b11',
//     brand: 'Fram',
//   ),
//   Brand(
//     id: 'b12',
//     brand: 'Mahle',
//   ),
//   Brand(
//     id: 'b13',
//     brand: 'Gaido',
//   ),
//   Brand(
//     id: 'b14',
//     brand: 'Saiko',
//   ),
// ];

// const dummyItems = [
//   ProductItem(
//     id: 'i1',
//     categories: ['c1'],
//     name: 'Castrol Edge',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b1'],
//     price: 30.00,
//     discount: 5.00,
//     discountedPrice: 25.00,
//     quantity: 30,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i2',
//     categories: ['c1'],
//     name: 'Shell Fast',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b2'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 35.30,
//     quantity: 25,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i3',
//     categories: ['c2'],
//     name: 'Avid Brake Pad',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b3'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 35.30,
//     quantity: 15,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i4',
//     categories: ['c2'],
//     name: 'Sram Brake Pad',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b4'],
//     price: 30.00,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 30,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i5',
//     categories: ['c3'],
//     name: 'Valvoline Collant 5L',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b5'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 35.30,
//     quantity: 25,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i6',
//     categories: ['c3'],
//     name: 'Motocraft Coolant 10L',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b6'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 35.30,
//     quantity: 15,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i7',
//     categories: ['c4'],
//     name: 'Yokohama 185/15/15',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b7'],
//     price: 30.00,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 30,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i8',
//     categories: ['c4'],
//     name: 'Bridgestone 195/20/20',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b8'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 35.30,
//     quantity: 25,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i9',
//     categories: ['c5'],
//     name: 'Amaron Battery',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b9'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 35.30,
//     quantity: 15,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i10',
//     categories: ['c5'],
//     name: 'Banner Battery',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b10'],
//     price: 30.00,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 30,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i11',
//     categories: ['c6'],
//     name: 'Fram car filter',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b11'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 25,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i12',
//     categories: ['c6'],
//     name: 'Mahle Car Filter',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b12'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 15,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i13',
//     categories: ['c7'],
//     name: 'Gaido Belt',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b14'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 25,
//     type: ['g1'],
//     partNumber: 12345678,
//   ),
//   ProductItem(
//     id: 'i14',
//     categories: ['c7'],
//     name: 'Saiko Belt',
//     imageUrl:
//         'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg/800px-Spaghetti_Bolognese_mit_Parmesan_oder_Grana_Padano.jpg',
//     brand: ['b14'],
//     price: 35.30,
//     discount: 0.00,
//     discountedPrice: 30.00,
//     quantity: 15,
//     type: ['g2'],
//     partNumber: 12345678,
//   ),
// ];
