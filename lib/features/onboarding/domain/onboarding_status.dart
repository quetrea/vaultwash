const currentOnboardingVersion = 1;

class OnboardingStatus {
  const OnboardingStatus({
    required this.isCompleted,
    required this.version,
    this.completedAt,
  });

  const OnboardingStatus.unseen()
    : isCompleted = false,
      version = 0,
      completedAt = null;

  final bool isCompleted;
  final int version;
  final DateTime? completedAt;

  bool get shouldShow => !isCompleted || version < currentOnboardingVersion;

  OnboardingStatus copyWith({
    bool? isCompleted,
    int? version,
    DateTime? completedAt,
  }) {
    return OnboardingStatus(
      isCompleted: isCompleted ?? this.isCompleted,
      version: version ?? this.version,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
