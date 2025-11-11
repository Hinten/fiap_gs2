/// Authentication user model with custom claims support.
///
/// This model represents a Firebase authenticated user with additional
/// custom claims for role-based access control (RBAC).
class AuthUserModel {
  /// Unique user identifier (Firebase UID)
  final String uid;

  /// User email address
  final String email;

  /// User display name (optional)
  final String? displayName;

  /// Whether the email is verified
  final bool emailVerified;

  /// User role (e.g., 'admin', 'user', 'teacher', 'student')
  final String role;

  /// Tenant/organization identifier (optional)
  final String? tenantId;

  /// Additional custom claims from Firebase token
  final Map<String, dynamic> customClaims;

  /// User photo URL (optional)
  final String? photoURL;

  /// User phone number (optional)
  final String? phoneNumber;

  /// Whether the user account is disabled
  final bool disabled;

  AuthUserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.emailVerified = false,
    this.role = 'user',
    this.tenantId,
    this.customClaims = const {},
    this.photoURL,
    this.phoneNumber,
    this.disabled = false,
  });

  /// Check if user has a specific role
  ///
  /// Returns true if:
  /// - User has the specified role
  /// - User is an admin (admins have access to everything)
  bool hasRole(String requiredRole) {
    if (role == 'admin') return true;
    return role == requiredRole;
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    if (role == 'admin') return true;
    return roles.contains(role);
  }

  /// Check if user has a specific custom claim
  bool hasClaim(String claimKey, [dynamic claimValue]) {
    if (!customClaims.containsKey(claimKey)) return false;
    if (claimValue == null) return true;
    return customClaims[claimKey] == claimValue;
  }

  /// Create AuthUserModel from Firebase User
  factory AuthUserModel.fromFirebaseUser(
    dynamic firebaseUser,
    Map<String, dynamic>? tokenClaims,
  ) {
    return AuthUserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      emailVerified: firebaseUser.emailVerified,
      role: tokenClaims?['role'] ?? 'user',
      tenantId: tokenClaims?['tenant_id'],
      customClaims: tokenClaims ?? {},
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'role': role,
      'tenantId': tenantId,
      'customClaims': customClaims,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'disabled': disabled,
    };
  }

  /// Create from JSON
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      role: json['role'] as String? ?? 'user',
      tenantId: json['tenantId'] as String?,
      customClaims:
          json['customClaims'] as Map<String, dynamic>? ?? const {},
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      disabled: json['disabled'] as bool? ?? false,
    );
  }

  /// Create a copy with updated fields
  AuthUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? role,
    String? tenantId,
    Map<String, dynamic>? customClaims,
    String? photoURL,
    String? phoneNumber,
    bool? disabled,
  }) {
    return AuthUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      customClaims: customClaims ?? this.customClaims,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  String toString() {
    return 'AuthUserModel(uid: $uid, email: $email, role: $role, tenantId: $tenantId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthUserModel && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
