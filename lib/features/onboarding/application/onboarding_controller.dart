import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultwash/features/onboarding/domain/onboarding_status.dart';
import 'package:vaultwash/features/onboarding/infrastructure/onboarding_local_data_source.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingStatus>(
      OnboardingController.new,
    );

class OnboardingController extends AsyncNotifier<OnboardingStatus> {
  @override
  Future<OnboardingStatus> build() async {
    return ref.read(onboardingLocalDataSourceProvider).load();
  }

  Future<void> complete() async {
    try {
      final next = await ref
          .read(onboardingLocalDataSourceProvider)
          .markCompleted();
      state = AsyncData(next);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
