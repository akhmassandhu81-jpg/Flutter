/// Student profile stored in Firebase Realtime Database at users/{uid}.
/// Passwords are NEVER stored here — Firebase Auth manages credentials.
///
/// RTDB stores timestamps as int (milliseconds-since-epoch).
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String? classLevel;
  final String? curriculum;

  /// Map of subjectId → true  e.g. {'mathematics': true, 'physics': true}
  final Map<String, bool> selectedSubjects;

  /// true once the student completes Class→Curriculum→Subject onboarding.
  final bool onboardingCompleted;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.classLevel,
    this.curriculum,
    this.selectedSubjects = const {},
    this.onboardingCompleted = false,
  });

  // ── Factory: brand-new student (onboarding not yet complete) ──────────────
  factory UserModel.newStudent({
    required String uid,
    required String fullName,
    required String email,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid:                 uid,
      fullName:            fullName,
      email:               email,
      role:                'student',
      classLevel:          null,
      curriculum:          null,
      selectedSubjects:    const {},
      onboardingCompleted: false,
      createdAt:           now,
      updatedAt:           now,
    );
  }

  // ── Deserialise from RTDB snapshot (Map<dynamic,dynamic>) ─────────────────
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    // Parse selectedSubjects — stored as {subjectId: true} in RTDB
    Map<String, bool> parsedSubjects = {};
    final rawSubjects = map['selectedSubjects'];
    if (rawSubjects is Map) {
      rawSubjects.forEach((k, v) {
        if (k != null && v == true) {
          parsedSubjects[k.toString()] = true;
        }
      });
    }

    return UserModel(
      uid:                 _str(map['uid'])      ?? '',
      fullName:            _str(map['fullName']) ?? '',
      email:               _str(map['email'])    ?? '',
      role:                _str(map['role'])     ?? 'student',
      classLevel:          _str(map['classLevel']),
      curriculum:          _str(map['curriculum']),
      selectedSubjects:    parsedSubjects,
      onboardingCompleted: map['onboardingCompleted'] == true,
      createdAt:           _parseTs(map['createdAt']),
      updatedAt:           _parseTs(map['updatedAt']),
    );
  }

  // ── Serialise to RTDB ─────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'uid':                 uid,
    'fullName':            fullName,
    'email':               email,
    'role':                role,
    'classLevel':          classLevel,
    'curriculum':          curriculum,
    'selectedSubjects':    selectedSubjects,
    'onboardingCompleted': onboardingCompleted,
    'createdAt':           createdAt.millisecondsSinceEpoch,
    'updatedAt':           updatedAt.millisecondsSinceEpoch,
  };

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String? _str(dynamic v) => v?.toString();

  static DateTime _parseTs(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int)    return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    try { return (v as dynamic).toDate() as DateTime; } catch (_) {}
    return DateTime.now();
  }

  // ── Convenience ───────────────────────────────────────────────────────────
  /// Returns the list of subject IDs the student has selected.
  List<String> get selectedSubjectIds =>
      selectedSubjects.entries.where((e) => e.value).map((e) => e.key).toList();

  bool get hasSelectedSubjects => selectedSubjects.values.any((v) => v);

  // ── copyWith ───────────────────────────────────────────────────────────────
  UserModel copyWith({
    String?            fullName,
    String?            email,
    String?            role,
    String?            classLevel,
    String?            curriculum,
    Map<String, bool>? selectedSubjects,
    bool?              onboardingCompleted,
    DateTime?          updatedAt,
  }) =>
      UserModel(
        uid:                 uid,
        fullName:            fullName            ?? this.fullName,
        email:               email               ?? this.email,
        role:                role                ?? this.role,
        classLevel:          classLevel          ?? this.classLevel,
        curriculum:          curriculum          ?? this.curriculum,
        selectedSubjects:    selectedSubjects    ?? this.selectedSubjects,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        createdAt:           createdAt,
        updatedAt:           updatedAt           ?? this.updatedAt,
      );

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $fullName, class: $classLevel, '
      'curriculum: $curriculum, onboarded: $onboardingCompleted)';
}
