import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsProvider = FutureProvider<List<String>>((ref) async {
  await Future.delayed(const Duration(seconds: 2));

  return [
    'Laptop',
    'Mouse',
    'Keyboard',
  ];
});