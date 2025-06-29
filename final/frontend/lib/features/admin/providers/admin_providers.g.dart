// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminSystemStatsHash() => r'd688c7873b31276dfa5e0fe1720472234221338c';

/// See also [adminSystemStats].
@ProviderFor(adminSystemStats)
final adminSystemStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  adminSystemStats,
  name: r'adminSystemStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminSystemStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminSystemStatsRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$allUsersHash() => r'4ced5c08a88253085d0200c965b5996d914a632d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [allUsers].
@ProviderFor(allUsers)
const allUsersProvider = AllUsersFamily();

/// See also [allUsers].
class AllUsersFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [allUsers].
  const AllUsersFamily();

  /// See also [allUsers].
  AllUsersProvider call({
    UserRole? roleFilter,
    String? searchQuery,
  }) {
    return AllUsersProvider(
      roleFilter: roleFilter,
      searchQuery: searchQuery,
    );
  }

  @override
  AllUsersProvider getProviderOverride(
    covariant AllUsersProvider provider,
  ) {
    return call(
      roleFilter: provider.roleFilter,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allUsersProvider';
}

/// See also [allUsers].
class AllUsersProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [allUsers].
  AllUsersProvider({
    UserRole? roleFilter,
    String? searchQuery,
  }) : this._internal(
          (ref) => allUsers(
            ref as AllUsersRef,
            roleFilter: roleFilter,
            searchQuery: searchQuery,
          ),
          from: allUsersProvider,
          name: r'allUsersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allUsersHash,
          dependencies: AllUsersFamily._dependencies,
          allTransitiveDependencies: AllUsersFamily._allTransitiveDependencies,
          roleFilter: roleFilter,
          searchQuery: searchQuery,
        );

  AllUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roleFilter,
    required this.searchQuery,
  }) : super.internal();

  final UserRole? roleFilter;
  final String? searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(AllUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllUsersProvider._internal(
        (ref) => create(ref as AllUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roleFilter: roleFilter,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _AllUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllUsersProvider &&
        other.roleFilter == roleFilter &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roleFilter.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllUsersRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `roleFilter` of this provider.
  UserRole? get roleFilter;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _AllUsersProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with AllUsersRef {
  _AllUsersProviderElement(super.provider);

  @override
  UserRole? get roleFilter => (origin as AllUsersProvider).roleFilter;
  @override
  String? get searchQuery => (origin as AllUsersProvider).searchQuery;
}

String _$allCoursesHash() => r'e1c9d3b858f819a34595cccdfece49f321e1ee00';

/// See also [allCourses].
@ProviderFor(allCourses)
const allCoursesProvider = AllCoursesFamily();

/// See also [allCourses].
class AllCoursesFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [allCourses].
  const AllCoursesFamily();

  /// See also [allCourses].
  AllCoursesProvider call({
    String? searchQuery,
  }) {
    return AllCoursesProvider(
      searchQuery: searchQuery,
    );
  }

  @override
  AllCoursesProvider getProviderOverride(
    covariant AllCoursesProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allCoursesProvider';
}

/// See also [allCourses].
class AllCoursesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [allCourses].
  AllCoursesProvider({
    String? searchQuery,
  }) : this._internal(
          (ref) => allCourses(
            ref as AllCoursesRef,
            searchQuery: searchQuery,
          ),
          from: allCoursesProvider,
          name: r'allCoursesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allCoursesHash,
          dependencies: AllCoursesFamily._dependencies,
          allTransitiveDependencies:
              AllCoursesFamily._allTransitiveDependencies,
          searchQuery: searchQuery,
        );

  AllCoursesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
  }) : super.internal();

  final String? searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(AllCoursesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllCoursesProvider._internal(
        (ref) => create(ref as AllCoursesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _AllCoursesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllCoursesProvider && other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllCoursesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _AllCoursesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with AllCoursesRef {
  _AllCoursesProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as AllCoursesProvider).searchQuery;
}

String _$allGeofencesHash() => r'2dc87bbbfd8840f47dc1b0fc64d1b41d06403dc3';

/// See also [allGeofences].
@ProviderFor(allGeofences)
const allGeofencesProvider = AllGeofencesFamily();

/// See also [allGeofences].
class AllGeofencesFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [allGeofences].
  const AllGeofencesFamily();

  /// See also [allGeofences].
  AllGeofencesProvider call({
    bool? activeOnly,
    String? searchQuery,
  }) {
    return AllGeofencesProvider(
      activeOnly: activeOnly,
      searchQuery: searchQuery,
    );
  }

  @override
  AllGeofencesProvider getProviderOverride(
    covariant AllGeofencesProvider provider,
  ) {
    return call(
      activeOnly: provider.activeOnly,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allGeofencesProvider';
}

/// See also [allGeofences].
class AllGeofencesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [allGeofences].
  AllGeofencesProvider({
    bool? activeOnly,
    String? searchQuery,
  }) : this._internal(
          (ref) => allGeofences(
            ref as AllGeofencesRef,
            activeOnly: activeOnly,
            searchQuery: searchQuery,
          ),
          from: allGeofencesProvider,
          name: r'allGeofencesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allGeofencesHash,
          dependencies: AllGeofencesFamily._dependencies,
          allTransitiveDependencies:
              AllGeofencesFamily._allTransitiveDependencies,
          activeOnly: activeOnly,
          searchQuery: searchQuery,
        );

  AllGeofencesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activeOnly,
    required this.searchQuery,
  }) : super.internal();

  final bool? activeOnly;
  final String? searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(AllGeofencesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllGeofencesProvider._internal(
        (ref) => create(ref as AllGeofencesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activeOnly: activeOnly,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _AllGeofencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllGeofencesProvider &&
        other.activeOnly == activeOnly &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activeOnly.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllGeofencesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `activeOnly` of this provider.
  bool? get activeOnly;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _AllGeofencesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with AllGeofencesRef {
  _AllGeofencesProviderElement(super.provider);

  @override
  bool? get activeOnly => (origin as AllGeofencesProvider).activeOnly;
  @override
  String? get searchQuery => (origin as AllGeofencesProvider).searchQuery;
}

String _$userDetailsHash() => r'b07fd45d3f5f352d4211344c6aa51826e324a8ca';

/// See also [userDetails].
@ProviderFor(userDetails)
const userDetailsProvider = UserDetailsFamily();

/// See also [userDetails].
class UserDetailsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [userDetails].
  const UserDetailsFamily();

  /// See also [userDetails].
  UserDetailsProvider call(
    String userId,
  ) {
    return UserDetailsProvider(
      userId,
    );
  }

  @override
  UserDetailsProvider getProviderOverride(
    covariant UserDetailsProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDetailsProvider';
}

/// See also [userDetails].
class UserDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [userDetails].
  UserDetailsProvider(
    String userId,
  ) : this._internal(
          (ref) => userDetails(
            ref as UserDetailsRef,
            userId,
          ),
          from: userDetailsProvider,
          name: r'userDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userDetailsHash,
          dependencies: UserDetailsFamily._dependencies,
          allTransitiveDependencies:
              UserDetailsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(UserDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserDetailsProvider._internal(
        (ref) => create(ref as UserDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _UserDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDetailsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with UserDetailsRef {
  _UserDetailsProviderElement(super.provider);

  @override
  String get userId => (origin as UserDetailsProvider).userId;
}

String _$courseDetailsHash() => r'00f631effca3d805c4576a6cacc3ebcb50957287';

/// See also [courseDetails].
@ProviderFor(courseDetails)
const courseDetailsProvider = CourseDetailsFamily();

/// See also [courseDetails].
class CourseDetailsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [courseDetails].
  const CourseDetailsFamily();

  /// See also [courseDetails].
  CourseDetailsProvider call(
    String courseId,
  ) {
    return CourseDetailsProvider(
      courseId,
    );
  }

  @override
  CourseDetailsProvider getProviderOverride(
    covariant CourseDetailsProvider provider,
  ) {
    return call(
      provider.courseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'courseDetailsProvider';
}

/// See also [courseDetails].
class CourseDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [courseDetails].
  CourseDetailsProvider(
    String courseId,
  ) : this._internal(
          (ref) => courseDetails(
            ref as CourseDetailsRef,
            courseId,
          ),
          from: courseDetailsProvider,
          name: r'courseDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$courseDetailsHash,
          dependencies: CourseDetailsFamily._dependencies,
          allTransitiveDependencies:
              CourseDetailsFamily._allTransitiveDependencies,
          courseId: courseId,
        );

  CourseDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseId,
  }) : super.internal();

  final String courseId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(CourseDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CourseDetailsProvider._internal(
        (ref) => create(ref as CourseDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseId: courseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _CourseDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CourseDetailsProvider && other.courseId == courseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CourseDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `courseId` of this provider.
  String get courseId;
}

class _CourseDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with CourseDetailsRef {
  _CourseDetailsProviderElement(super.provider);

  @override
  String get courseId => (origin as CourseDetailsProvider).courseId;
}

String _$instructorsListHash() => r'50481f74302939c9f531ad776b42466443efd8f7';

/// See also [instructorsList].
@ProviderFor(instructorsList)
final instructorsListProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  instructorsList,
  name: r'instructorsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$instructorsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InstructorsListRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$courseEnrollmentDetailsHash() =>
    r'7f94618b72e84a1fdf200c933e90cad13f8dc16a';

/// See also [courseEnrollmentDetails].
@ProviderFor(courseEnrollmentDetails)
const courseEnrollmentDetailsProvider = CourseEnrollmentDetailsFamily();

/// See also [courseEnrollmentDetails].
class CourseEnrollmentDetailsFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [courseEnrollmentDetails].
  const CourseEnrollmentDetailsFamily();

  /// See also [courseEnrollmentDetails].
  CourseEnrollmentDetailsProvider call(
    String courseId,
  ) {
    return CourseEnrollmentDetailsProvider(
      courseId,
    );
  }

  @override
  CourseEnrollmentDetailsProvider getProviderOverride(
    covariant CourseEnrollmentDetailsProvider provider,
  ) {
    return call(
      provider.courseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'courseEnrollmentDetailsProvider';
}

/// See also [courseEnrollmentDetails].
class CourseEnrollmentDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [courseEnrollmentDetails].
  CourseEnrollmentDetailsProvider(
    String courseId,
  ) : this._internal(
          (ref) => courseEnrollmentDetails(
            ref as CourseEnrollmentDetailsRef,
            courseId,
          ),
          from: courseEnrollmentDetailsProvider,
          name: r'courseEnrollmentDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$courseEnrollmentDetailsHash,
          dependencies: CourseEnrollmentDetailsFamily._dependencies,
          allTransitiveDependencies:
              CourseEnrollmentDetailsFamily._allTransitiveDependencies,
          courseId: courseId,
        );

  CourseEnrollmentDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseId,
  }) : super.internal();

  final String courseId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(CourseEnrollmentDetailsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CourseEnrollmentDetailsProvider._internal(
        (ref) => create(ref as CourseEnrollmentDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseId: courseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _CourseEnrollmentDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CourseEnrollmentDetailsProvider &&
        other.courseId == courseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CourseEnrollmentDetailsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `courseId` of this provider.
  String get courseId;
}

class _CourseEnrollmentDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with CourseEnrollmentDetailsRef {
  _CourseEnrollmentDetailsProviderElement(super.provider);

  @override
  String get courseId => (origin as CourseEnrollmentDetailsProvider).courseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
