// ── Holetportalen License Data ────────────────────────────────────────────────
// Models the per-user license status for the two Holetportalen modules:
//   • Checklist
//   • Forms
//
// In production these come from the tenant licence endpoint on the core API.

enum LicenseStatus {
  active,   // user has a valid, paid seat
  inactive, // seat was never procured or was revoked
  pending,  // request submitted — awaiting activation
}

class UserLicenseStatus {
  final String userId;
  final String name;
  final String initials; // 2-letter avatar fallback
  final LicenseStatus checklist;
  final LicenseStatus forms;

  const UserLicenseStatus({
    required this.userId,
    required this.name,
    required this.initials,
    required this.checklist,
    required this.forms,
  });
}

class HoletportalenLicenseData {
  final List<UserLicenseStatus> users;

  const HoletportalenLicenseData({required this.users});

  int get totalUsers => users.length;
  int get checklistActive =>
      users.where((u) => u.checklist == LicenseStatus.active).length;
  int get formsActive =>
      users.where((u) => u.forms == LicenseStatus.active).length;
  int get checklistPending =>
      users.where((u) => u.checklist == LicenseStatus.pending).length;
  int get formsPending =>
      users.where((u) => u.forms == LicenseStatus.pending).length;

  // ── Convenience: single record for the logged-in user ────────────────────
  /// Returns the status record for the currently logged-in user.
  /// In production, filter by the authenticated userId from the auth provider.
  static UserLicenseStatus mockCurrentUser() => const UserLicenseStatus(
        userId: 'u2',
        name: 'Kari Pedersen',
        initials: 'KP',
        checklist: LicenseStatus.active,
        forms: LicenseStatus.pending,
      );

  // ── Full-team mock (admin use) ────────────────────────────────────────────
  static HoletportalenLicenseData mock() => const HoletportalenLicenseData(
        users: [
          UserLicenseStatus(
            userId: 'u1',
            name: 'Erik Hansen',
            initials: 'EH',
            checklist: LicenseStatus.active,
            forms: LicenseStatus.active,
          ),
          UserLicenseStatus(
            userId: 'u2',
            name: 'Kari Pedersen',
            initials: 'KP',
            checklist: LicenseStatus.active,
            forms: LicenseStatus.inactive,
          ),
          UserLicenseStatus(
            userId: 'u3',
            name: 'Ole Larsen',
            initials: 'OL',
            checklist: LicenseStatus.inactive,
            forms: LicenseStatus.inactive,
          ),
          UserLicenseStatus(
            userId: 'u4',
            name: 'Mari Nilsen',
            initials: 'MN',
            checklist: LicenseStatus.active,
            forms: LicenseStatus.pending,
          ),
          UserLicenseStatus(
            userId: 'u5',
            name: 'Thomas Berg',
            initials: 'TB',
            checklist: LicenseStatus.pending,
            forms: LicenseStatus.inactive,
          ),
          UserLicenseStatus(
            userId: 'u6',
            name: 'Ida Solberg',
            initials: 'IS',
            checklist: LicenseStatus.active,
            forms: LicenseStatus.active,
          ),
          UserLicenseStatus(
            userId: 'u7',
            name: 'Lars Moen',
            initials: 'LM',
            checklist: LicenseStatus.inactive,
            forms: LicenseStatus.active,
          ),
          UserLicenseStatus(
            userId: 'u8',
            name: 'Sigrid Dahl',
            initials: 'SD',
            checklist: LicenseStatus.active,
            forms: LicenseStatus.pending,
          ),
        ],
      );
}
