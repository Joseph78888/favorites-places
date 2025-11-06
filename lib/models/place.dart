import 'dart:math';

var random = Random();

class Place {
  Place({required this.title}) : id = random.nextInt(100);
  final int id;
  final String title;
}
