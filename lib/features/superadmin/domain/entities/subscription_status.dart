/// Subscription status enumeration.
///
/// Defines the different subscription tiers a school can have
/// in the Classio application.
enum SubscriptionStatus {
  /// Trial period - limited time access (school year: Sept 1 to July 1).
  trial,

  /// Pro subscription - paid tier with standard features.
  pro,

  /// Max subscription - paid tier with all features.
  max,

  /// Subscription has expired or payment failed.
  expired,

  /// School has been suspended by superadmin.
  suspended;

  /// Converts a string to a [SubscriptionStatus].
  ///
  /// Returns null if the string doesn't match any status.
  static SubscriptionStatus? fromString(String? status) {
    if (status == null) return null;
    try {
      return SubscriptionStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == status.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Converts the status to a string.
  String toJson() => name;

  /// Returns a human-readable display name for the status.
  String get displayName {
    switch (this) {
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.pro:
        return 'Pro';
      case SubscriptionStatus.max:
        return 'Max';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.suspended:
        return 'Suspended';
    }
  }

  /// Returns an icon for the subscription tier.
  String get icon {
    switch (this) {
      case SubscriptionStatus.trial:
        return 'hourglass_empty';
      case SubscriptionStatus.pro:
        return 'star';
      case SubscriptionStatus.max:
        return 'diamond';
      case SubscriptionStatus.expired:
        return 'warning';
      case SubscriptionStatus.suspended:
        return 'block';
    }
  }

  /// Returns whether this subscription is in a usable state.
  bool get isUsable =>
      this == SubscriptionStatus.trial ||
      this == SubscriptionStatus.pro ||
      this == SubscriptionStatus.max;

  /// Returns whether this is a paid subscription tier.
  bool get isPaid =>
      this == SubscriptionStatus.pro || this == SubscriptionStatus.max;
}
