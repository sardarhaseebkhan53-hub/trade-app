class FeatureFlags {
  static const bool aiChatEnabled = true;
  static const bool marketRegimeEnabled = true;
  static const bool professionalChartsEnabled = true;
  static const bool twoFactorEnabled = false; // coming soon
  static const bool newsEnabled = false;
  static const bool advancedAlertsEnabled = true;

  // Cost control
  static const int maxAiRequestsPerDay = 50;
}
