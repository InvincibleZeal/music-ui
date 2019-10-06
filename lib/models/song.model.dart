import 'package:flutter/foundation.dart';

class Song {
  String name;
  Duration duration;
  String author;
  String cover;

  Song({
    @required this.name,
    @required this.duration,
    @required this.author,
    @required this.cover,
  });
}
