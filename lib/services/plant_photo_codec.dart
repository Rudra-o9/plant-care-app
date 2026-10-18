import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

/// Creates small JPEG data URLs that fit safely in a Firestore plant document.
class PlantPhotoCodec {
  static String thumbnailDataUri(Uint8List bytes, {int longestSide = 180}) {
    final original = image.decodeImage(bytes);
    if (original == null) return '';
    final thumbnail = original.width >= original.height
        ? image.copyResize(original, width: longestSide)
        : image.copyResize(original, height: longestSide);
    final jpeg = image.encodeJpg(thumbnail, quality: 55);
    return 'data:image/jpeg;base64,${base64Encode(jpeg)}';
  }
}
