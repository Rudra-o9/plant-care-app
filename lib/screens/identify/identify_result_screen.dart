import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

import '../../models/plant_identification_model.dart';
import '../../models/plant_model.dart';
import '../../services/plant_care_guide_service.dart';
import '../../services/plant_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';

class IdentifyResultScreen extends StatefulWidget {
  final PlantIdentificationModel identification;
  final Uint8List imageBytes;
  final String imagePath;
  const IdentifyResultScreen({
    super.key,
    required this.identification,
    required this.imageBytes,
    required this.imagePath,
  });
  @override
  State<IdentifyResultScreen> createState() => _IdentifyResultScreenState();
}

class _IdentifyResultScreenState extends State<IdentifyResultScreen> {
  late PlantIdentificationResult? _selected = widget.identification.bestMatch;
  final _name = TextEditingController();
  PlantCareGuide? get _care =>
      _selected == null ? null : PlantCareGuideService.forMatch(_selected!);
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      title: Text(
        _selected == null ? 'Name your plant' : 'Identification result',
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              widget.imageBytes,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 24),
          if (_selected == null) _unknown(context) else _identified(context),
        ],
      ),
    ),
  );

  Widget _unknown(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'No confident match found',
        style: AppTextStyles.headlineLarge.copyWith(fontSize: 23),
      ),
      const SizedBox(height: 8),
      Text(
        'Give this plant a name and add it now. You can update its species later when a similar plant is identified.',
        style: AppTextStyles.bodyMedium,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Plant name',
          hintText: 'e.g. Balcony fern',
        ),
      ),
      const SizedBox(height: 20),
      _careCard(PlantCareGuideService.general()),
      const SizedBox(height: 28),
      AppButton(
        text: 'Add to My Plants',
        icon: Icons.add_rounded,
        onPressed: _addUnknown,
      ),
    ],
  );

  Widget _identified(BuildContext context) {
    final match = _selected!;
    final care = _care!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          match.commonName,
          style: AppTextStyles.displayMedium.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          match.displayName,
          style: AppTextStyles.titleLarge.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(match.score * 100).round()}% confidence',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          'Care guide',
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        _careCard(care),
        const SizedBox(height: 28),
        Text(
          'Top possible matches',
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the most likely plant before adding it.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 12),
        RadioGroup<PlantIdentificationResult>(
          groupValue: _selected,
          onChanged: (value) => setState(() => _selected = value),
          child: Column(
            children: widget.identification.topMatches
                .map(_matchOption)
                .toList(),
          ),
        ),
        const SizedBox(height: 22),
        AppButton(
          text: 'Add ${match.commonName} to My Plants',
          icon: Icons.add_rounded,
          onPressed: _addPlant,
        ),
      ],
    );
  }

  Widget _matchOption(PlantIdentificationResult candidate) => Card(
    child: RadioListTile<PlantIdentificationResult>(
      value: candidate,
      title: Text(candidate.commonName, style: AppTextStyles.titleMedium),
      subtitle: Text(
        '${candidate.displayName}\n${(candidate.score * 100).round()}% match',
      ),
    ),
  );

  Widget _careCard(PlantCareGuide care) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _careLine('Water', care.watering),
          _careLine('Sunlight', care.sunlight),
          _careLine('Temperature', care.temperature),
          _careLine('Soil', care.soil),
          const SizedBox(height: 6),
          Text(care.note, style: AppTextStyles.caption),
        ],
      ),
    ),
  );
  Widget _careLine(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );

  Future<void> _addUnknown() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for this plant.')),
      );
      return;
    }
    await _save(
      name,
      'Species not identified',
      PlantCareGuideService.general(),
      0,
    );
  }

  Future<void> _addPlant() async {
    final match = _selected!;
    await _save(match.commonName, match.displayName, _care!, match.score);
  }

  Future<void> _save(
    String name,
    String scientificName,
    PlantCareGuide care,
    double confidence,
  ) async {
    final plantId = 'identified_${DateTime.now().millisecondsSinceEpoch}';
    try {
      await PlantService().addPlant(
        PlantModel(
          id: plantId,
          name: name,
          scientificName: scientificName,
          description: confidence == 0
              ? 'Named by you after no confident identification match.'
              : 'Identified by Pl@ntNet with ${(confidence * 100).round()}% confidence. ${care.note}',
          // A small thumbnail is stored in Firestore so it survives app
          // reinstalls without requiring paid Firebase Storage.
          imageUrl: _thumbnailDataUri(widget.imageBytes),
          careLevel: care.careLevel,
          wateringFrequencyDays: care.wateringFrequencyDays,
          sunlight: care.sunlight,
          temperature: care.temperature,
          soilType: care.soil,
          lastWatered: DateTime.now(),
          matchConfidence: confidence,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save this plant: $error')),
        );
      }
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to your collection!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  String _thumbnailDataUri(Uint8List bytes) {
    final original = image.decodeImage(bytes);
    if (original == null) return '';
    const longestSide = 256;
    final thumbnail = original.width >= original.height
        ? image.copyResize(original, width: longestSide)
        : image.copyResize(original, height: longestSide);
    final jpeg = image.encodeJpg(thumbnail, quality: 60);
    return 'data:image/jpeg;base64,${base64Encode(jpeg)}';
  }
}
