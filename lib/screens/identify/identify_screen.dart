import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../services/plant_identifier_service.dart';
import '../../utils/page_transitions.dart';
import 'identify_result_screen.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final ImagePicker _picker = ImagePicker();
  final PlantIdentifierService _identifierService = PlantIdentifierService();
  final List<XFile> _selectedImages = [];
  final List<String> _selectedSources = [];
  String? _errorMessage;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _identifierService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      setState(
        () => _errorMessage = 'You can add up to 5 photos of the same plant.',
      );
      return;
    }
    setState(() => _errorMessage = null);
    try {
      // image_picker's desktop implementation supports the file picker but not
      // a native camera UI unless an app supplies a camera delegate. Falling
      // back to the same photo picker keeps laptop users able to select a
      // photo from the existing Take Photo action.
      final effectiveSource = _picker.supportsImageSource(source)
          ? source
          : ImageSource.gallery;
      // Do not set dimensions or quality: Plant.id receives the original picked
      // image, not a preview-sized or re-encoded copy.
      final picked = await _picker.pickImage(source: effectiveSource);
      if (picked == null) return;
      if ((await picked.readAsBytes()).isEmpty) {
        throw const PlantIdentifierException(
          PlantIdentifierErrorType.invalidImage,
        );
      }
      if (!mounted) return;
      setState(() {
        _selectedImages.add(picked);
        _selectedSources.add(
          effectiveSource == ImageSource.camera ? 'Camera' : 'Gallery',
        );
        _errorMessage = null;
      });
    } on PlantIdentifierException catch (error) {
      if (mounted) setState(() => _errorMessage = error.userMessage);
    } on Exception catch (error) {
      final message = error.toString().toLowerCase();
      final userMessage = message.contains('denied')
          ? 'Camera or photo access was denied. Please allow access in Settings.'
          : 'We could not open that image. Please try again.';
      if (mounted) setState(() => _errorMessage = userMessage);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _selectedSources.removeAt(index);
      _errorMessage = null;
    });
  }

  Future<void> _startIdentification() async {
    if (_selectedImages.isEmpty || _isAnalyzing) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });
    try {
      final identification = await _identifierService.identifyPlants(
        _selectedImages,
      );
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      Navigator.of(context).push(
        AppPageRoute.slideUp(
          IdentifyResultScreen(
            identification: identification,
            imageBytes: await _selectedImages.first.readAsBytes(),
            imagePath: _selectedImages.first.path,
          ),
        ),
      );
    } on PlantIdentifierException catch (error) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = error.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Something went wrong while identifying the plant. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = _selectedImages.isNotEmpty;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Identify Plant')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: hasImages ? _buildPreviewCard() : _buildEmptyState(),
            ),
            if (_errorMessage != null) _buildErrorMessage(),
            const SizedBox(height: 20),
            if (!hasImages)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Take Photo',
                      icon: Icons.camera_alt_rounded,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      text: 'Gallery',
                      type: ButtonType.secondary,
                      icon: Icons.photo_library_rounded,
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Add Photo',
                      type: ButtonType.outlined,
                      icon: Icons.add_photo_alternate_rounded,
                      onPressed: _isAnalyzing ? null : _showAddPhotoOptions,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      text: 'Identify Plant',
                      isLoading: _isAnalyzing,
                      icon: Icons.auto_awesome_rounded,
                      onPressed: _startIdentification,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPhotoOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null && mounted) await _pickImage(source);
  }

  Widget _buildEmptyState() => Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.accentMint.withAlpha(102),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withAlpha(76),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.center_focus_strong_rounded,
                size: 70,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Identify Any Plant',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            'Take a clear photo or choose an existing photo from your gallery to discover species details and care instructions.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    ),
  );

  Widget _buildPreviewCard() => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withAlpha(18),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: _selectedImages.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildImagePreview(index),
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.accentMint,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Identifying your plant...',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(top: 16, left: 16, child: _sourceBadge()),
        ],
      ),
    ),
  );

  Widget _buildImagePreview(int index) => Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 0.82,
          child: FutureBuilder<Uint8List>(
            future: _selectedImages[index].readAsBytes(),
            builder: (context, snapshot) => snapshot.hasData
                ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          tooltip: 'Remove photo',
          onPressed: _isAnalyzing ? null : () => _removeImage(index),
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: Colors.black54),
        ),
      ),
    ],
  );

  Widget _sourceBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '${_selectedImages.length}/5 photos',
      style: AppTextStyles.caption.copyWith(color: Colors.white),
    ),
  );

  Widget _buildErrorMessage() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.errorBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.error.withAlpha(80)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty)
          TextButton(
            onPressed: _startIdentification,
            child: const Text('Try Again'),
          ),
      ],
    ),
  );
}
