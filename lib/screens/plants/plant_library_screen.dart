import 'package:flutter/material.dart';

import '../../models/plant_model.dart';
import '../../services/plant_library_service.dart';
import '../../services/plant_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PlantLibraryScreen extends StatefulWidget {
  const PlantLibraryScreen({super.key});

  @override
  State<PlantLibraryScreen> createState() => _PlantLibraryScreenState();
}

class _PlantLibraryScreenState extends State<PlantLibraryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches = PlantLibraryService.entries.where((plant) {
      final text = '${plant.name} ${plant.scientificName}'.toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Care Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search plants, e.g. Tulsi or Monstera',
              ),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? Center(
                    child: Text(
                      'No plants found.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: matches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final plant = matches[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plant.name, style: AppTextStyles.titleLarge),
                              const SizedBox(height: 2),
                              Text(
                                plant.scientificName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                plant.description,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Water: ${plant.care.watering}',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                'Light: ${plant.care.sunlight}',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add to My Plants'),
                                  onPressed: () => _addPlant(plant),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPlant(PlantLibraryEntry entry) async {
    final plant = PlantModel(
      id: 'library_${DateTime.now().millisecondsSinceEpoch}',
      name: entry.name,
      scientificName: entry.scientificName,
      description: '${entry.description} ${entry.care.note}',
      imageUrl: '',
      careLevel: entry.care.careLevel,
      wateringFrequencyDays: entry.care.wateringFrequencyDays,
      sunlight: entry.care.sunlight,
      temperature: entry.care.temperature,
      soilType: entry.care.soil,
      lastWatered: DateTime.now(),
    );
    await PlantService().addPlant(plant);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.name} added to My Plants.'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
