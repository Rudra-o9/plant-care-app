import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Reusable empty state view when list search or records are empty.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 28),
            AppButton(
              text: buttonText!,
              onPressed: onButtonPressed,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}
