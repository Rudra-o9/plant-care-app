import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Displays both remote plant photos and photos captured or selected locally.
class PlantImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final Widget? errorWidget;

  const PlantImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  bool get _isLocal => source.startsWith('/') || source.startsWith('file:');
  bool get _isDataImage => source.startsWith('data:image/');

  @override
  Widget build(BuildContext context) {
    final fallback =
        errorWidget ??
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.local_florist_outlined, size: 42),
        );
    if (_isDataImage) {
      try {
        final comma = source.indexOf(',');
        if (comma < 0) return fallback;
        return Image.memory(
          base64Decode(source.substring(comma + 1)),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      } on FormatException {
        return fallback;
      }
    }
    if (_isLocal) {
      final path = source.startsWith('file:')
          ? Uri.tryParse(source)?.toFilePath() ?? source
          : source;
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.network(
      source,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
