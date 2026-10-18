import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/plant_journal_entry.dart';
import '../../models/plant_model.dart';
import '../../services/plant_photo_codec.dart';
import '../../services/plant_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/plant_image.dart';

class PlantJournalScreen extends StatefulWidget {
  final PlantModel plant;

  const PlantJournalScreen({super.key, required this.plant});

  @override
  State<PlantJournalScreen> createState() => _PlantJournalScreenState();
}

class _PlantJournalScreenState extends State<PlantJournalScreen> {
  final _picker = ImagePicker();
  final _plantService = PlantService();
  late PlantModel _plant;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${_plant.name} Journal')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showAddEntry,
      icon: const Icon(Icons.add_a_photo_rounded),
      label: const Text('Add update'),
    ),
    body: _plant.journalEntries.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start a plant journal',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save a dated note or progress photo to track how ${_plant.name} is doing.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _plant.journalEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _entryCard(_plant.journalEntries[index]),
          ),
  );

  Widget _entryCard(PlantJournalEntry entry) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDate(entry.createdAt), style: AppTextStyles.titleMedium),
          if (entry.imageData.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: PlantImage(source: entry.imageData),
              ),
            ),
          ],
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(entry.note, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    ),
  );

  Future<void> _showAddEntry() async {
    final note = TextEditingController();
    XFile? photo;
    PlantJournalEntry? savedEntry;
    var saving = false;
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Journal update'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: note,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText:
                      'New leaf, watering update, or anything you notice…',
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                icon: Icon(
                  photo == null
                      ? Icons.add_photo_alternate_outlined
                      : Icons.check_circle_outline_rounded,
                ),
                label: Text(
                  photo == null ? 'Add progress photo' : 'Photo selected',
                ),
                onPressed: saving
                    ? null
                    : () async {
                        final source = await _selectSource(context);
                        if (source == null) return;
                        final usableSource = _picker.supportsImageSource(source)
                            ? source
                            : ImageSource.gallery;
                        final selected = await _picker.pickImage(
                          source: usableSource,
                        );
                        if (selected != null) {
                          setDialogState(() => photo = selected);
                        }
                      },
              ),
              const SizedBox(height: 8),
              Text(
                'Up to 12 journal updates are kept per plant.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (note.text.trim().isEmpty && photo == null) {
                        return;
                      }
                      setDialogState(() => saving = true);
                      final imageData = photo == null
                          ? ''
                          : PlantPhotoCodec.thumbnailDataUri(
                              await photo!.readAsBytes(),
                            );
                      final entry = PlantJournalEntry(
                        id: 'journal_${DateTime.now().millisecondsSinceEpoch}',
                        note: note.text.trim(),
                        createdAt: DateTime.now(),
                        imageData: imageData,
                      );
                      savedEntry = entry;
                      final entries = [
                        entry,
                        ..._plant.journalEntries,
                      ].take(12).toList();
                      await _plantService.updatePlant(
                        _plant.copyWith(journalEntries: entries),
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save update'),
            ),
          ],
        ),
      ),
    );
    note.dispose();
    if (added == true && savedEntry != null && mounted) {
      setState(() {
        _plant = _plant.copyWith(
          journalEntries: [
            savedEntry!,
            ..._plant.journalEntries,
          ].take(12).toList(),
        );
      });
    }
  }

  Future<ImageSource?> _selectSource(BuildContext context) =>
      showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
