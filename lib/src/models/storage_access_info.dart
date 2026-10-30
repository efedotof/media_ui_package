enum StorageAccessMode {
  manage,

  saf,

  none;

  static StorageAccessMode fromString(String? value) {
    if (value == null) return StorageAccessMode.none;
    return StorageAccessMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StorageAccessMode.none,
    );
  }
}

class StorageAccessInfo {
  final bool supported;
  final StorageAccessMode accessMode;
  final bool hasAccess;
  final bool requiresSaf;
  final bool requiresManage;
  final String reason;

  const StorageAccessInfo({
    required this.supported,
    required this.accessMode,
    required this.hasAccess,
    required this.requiresSaf,
    required this.requiresManage,
    required this.reason,
  });

  factory StorageAccessInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const StorageAccessInfo(
        supported: false,
        accessMode: StorageAccessMode.none,
        hasAccess: false,
        requiresSaf: false,
        requiresManage: false,
        reason: 'Unknown platform state',
      );
    }
    return StorageAccessInfo(
      supported: map['supported'] == true,
      accessMode: StorageAccessMode.fromString(map['accessMode']?.toString()),
      hasAccess: map['hasAccess'] == true,
      requiresSaf: map['requiresSaf'] == true,
      requiresManage: map['requiresManage'] == true,
      reason: map['reason']?.toString() ?? '',
    );
  }

  factory StorageAccessInfo.unsupported(String reason) {
    return StorageAccessInfo(
      supported: false,
      accessMode: StorageAccessMode.none,
      hasAccess: false,
      requiresSaf: false,
      requiresManage: false,
      reason: reason,
    );
  }

  bool get isGranted => supported && hasAccess;

  bool get needsUserAction =>
      supported && !hasAccess && (requiresSaf || requiresManage);

  bool get needsSafPicker => needsUserAction && requiresSaf;

  bool get needsManageSettings => needsUserAction && requiresManage;

  Map<String, dynamic> toMap() => {
    'supported': supported,
    'accessMode': accessMode.name,
    'hasAccess': hasAccess,
    'requiresSaf': requiresSaf,
    'requiresManage': requiresManage,
    'reason': reason,
  };

  StorageAccessInfo copyWith({
    bool? supported,
    StorageAccessMode? accessMode,
    bool? hasAccess,
    bool? requiresSaf,
    bool? requiresManage,
    String? reason,
  }) {
    return StorageAccessInfo(
      supported: supported ?? this.supported,
      accessMode: accessMode ?? this.accessMode,
      hasAccess: hasAccess ?? this.hasAccess,
      requiresSaf: requiresSaf ?? this.requiresSaf,
      requiresManage: requiresManage ?? this.requiresManage,
      reason: reason ?? this.reason,
    );
  }
}
