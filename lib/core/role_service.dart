import 'firebase_service.dart';

// ─────────────────────────────────────────────
// Role constants
// ─────────────────────────────────────────────

class AppRoles {
  static const String chapterLead = 'Chapter Lead';
  static const String teamLead = 'Team Lead';
  static const String member = 'Member';
}

// ─────────────────────────────────────────────
// Permission helpers  ─ call these everywhere
// ─────────────────────────────────────────────

class RoleService {
  /// Returns the current user's role from Firestore, or 'Member' as fallback.
  static Future<String> getCurrentUserRole() async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) return AppRoles.member;
    final profile = await FirebaseService.getUserProfile(uid);
    return (profile?['role'] as String?) ?? AppRoles.member;
  }

  // ── Permissions ──────────────────────────────

  /// Only Chapter Lead can create events.
  static bool canCreateEvents(String role) =>
      role == AppRoles.chapterLead;

  /// Chapter Lead and Team Lead can create meetings.
  static bool canCreateMeetings(String role) =>
      role == AppRoles.chapterLead || role == AppRoles.teamLead;

  /// Chapter Lead and Team Lead can mark / manage attendance.
  static bool canMarkAttendance(String role) =>
      role == AppRoles.chapterLead || role == AppRoles.teamLead;

  /// Chapter Lead and Team Lead can delete meetings.
  static bool canDeleteMeetings(String role) =>
      role == AppRoles.chapterLead || role == AppRoles.teamLead;

  /// Only Chapter Lead can delete events.
  static bool canDeleteEvents(String role) =>
      role == AppRoles.chapterLead;

  /// Only Chapter Lead can create teams and see delete/edit team options.
  static bool canCreateTeam(String role) =>
      role == AppRoles.chapterLead;

  /// Only Chapter Lead can delete/edit teams.
  static bool canManageTeam(String role) =>
      role == AppRoles.chapterLead;

  /// Chapter Lead and Team Lead can add/remove members from teams.
  static bool canAddRemoveMembers(String role) =>
      role == AppRoles.chapterLead || role == AppRoles.teamLead;
}
