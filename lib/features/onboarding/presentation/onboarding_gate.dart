import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/app/app_strings.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';
import 'package:vaultwash/core/widgets/app_button.dart';
import 'package:vaultwash/core/widgets/app_surface_card.dart';
import 'package:vaultwash/features/onboarding/application/onboarding_controller.dart';
import 'package:vaultwash/features/onboarding/domain/onboarding_status.dart';

class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate> {
  bool _presentedThisSession = false;

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);

    if (!_presentedThisSession &&
        onboardingState is AsyncData<OnboardingStatus> &&
        onboardingState.value.shouldShow) {
      final status = onboardingState.value;
      _presentedThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboarding(context, status);
      });
    }

    return widget.child;
  }

  Future<void> _showOnboarding(
    BuildContext context,
    OnboardingStatus status,
  ) async {
    if (!mounted || !status.shouldShow) {
      return;
    }

    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _OnboardingWelcomeDialog(),
    );

    if (completed == true) {
      await ref.read(onboardingControllerProvider.notifier).complete();
    }
  }
}

class _OnboardingWelcomeDialog extends StatelessWidget {
  const _OnboardingWelcomeDialog();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: AppRadius.sm,
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  'First launch',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Welcome to ${AppStrings.appName}',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Clean broken citation artifacts from Obsidian vaults with a calm, review-first workflow.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _OnboardingStep(
                stepNumber: '1',
                title: 'Choose your vault',
                message:
                    'Pick the Obsidian folder you want VaultWash to inspect.',
                icon: Icons.folder_open_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _OnboardingStep(
                stepNumber: '2',
                title: 'Scan before writing',
                message:
                    'VaultWash scans markdown files first and never mutates files during the scan.',
                icon: Icons.search_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _OnboardingStep(
                stepNumber: '3',
                title: 'Review every change',
                message:
                    'Inspect affected files and compare original versus cleaned excerpts before approving cleanup.',
                icon: Icons.preview_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _OnboardingStep(
                stepNumber: '4',
                title: 'Clean safely',
                message:
                    'Clean selected files or everything affected, with optional .bak backups when you want extra reassurance.',
                icon: Icons.cleaning_services_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _OnboardingStep(
                stepNumber: '5',
                title: 'Personalize the workspace',
                message:
                    'Use settings to switch between system, light, and dark appearance modes.',
                icon: Icons.tune_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                backgroundColor: colors.surfaceMuted,
                child: Text(
                  'Nothing is written until you review the results and confirm cleanup.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Open VaultWash',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.stepNumber,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String stepNumber;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      backgroundColor: colors.surfaceRaised,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.sm,
              border: Border.all(color: colors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 18, color: colors.textSecondary),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Text(
                    stepNumber,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
