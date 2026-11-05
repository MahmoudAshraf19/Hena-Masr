/// Centralized Firestore collections and document paths for Hana Masr.
abstract final class FirestorePaths {
  // --- Public Collections (Read-only for users, managed via Admin/CMS) ---
  static const String cities = 'cities';
  static const String categories = 'categories';
  static const String places = 'places';
  static const String transportOptions = 'transport_options';
  static const String scamTips = 'scam_tips';
  static const String offlinePacks = 'offline_packs';
  static const String emergencyContacts = 'emergency_contacts';
  static const String phrases = 'phrases';

  // --- User-Scoped Collections (Private per user) ---
  static const String users = 'users';

  /// Returns path to user document: `users/{userId}`
  static String user(String userId) => '$users/$userId';

  /// Returns path to user favorites: `users/{userId}/favorites`
  static String userFavorites(String userId) => '$users/$userId/favorites';

  /// Returns path to a specific favorite: `users/{userId}/favorites/{favoriteId}`
  static String userFavorite(String userId, String favoriteId) =>
      '$users/$userId/favorites/$favoriteId';

  /// Returns path to user trips: `users/{userId}/trips`
  static String userTrips(String userId) => '$users/$userId/trips';

  /// Returns path to a specific trip: `users/{userId}/trips/{tripId}`
  static String userTrip(String userId, String tripId) =>
      '$users/$userId/trips/$tripId';

  /// Returns path to user trip days: `users/{userId}/trips/{tripId}/days`
  static String userTripDays(String userId, String tripId) =>
      '$users/$userId/trips/$tripId/days';

  /// Returns path to AI chat history: `users/{userId}/ai_chats`
  static String userAiChats(String userId) => '$users/$userId/ai_chats';
}
