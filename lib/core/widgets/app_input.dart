import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.value,
    this.placeholder = '',
    this.maxLines = 1,
  });

  final String? value;
  final String placeholder;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final displayValue = value?.trim().isNotEmpty == true
        ? value!.trim()
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: AppRadius.sm,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        displayValue ?? placeholder,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style:
            (displayValue == null
                    ? textTheme.bodyMedium?.copyWith(color: colors.textMuted)
                    : textTheme.bodyMedium)
                ?.copyWith(height: 1.4),
      ),
    );
  }
}
