// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminSystemStatsHash() => r'0a83f4f32c81175037494db18edb1f6d72728f38';

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
String _$allUsersHash() => r'd85f4328b7c505c2007de43d91fe7cc510e1c348';

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

String _$allCoursesHash() => r'e4aafd4fe525cd91b9a611b93c7fbfa61fa1cb0c';

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

String _$allGeofencesHash() => r'3e310c49074a0ddbaf4347723dddd5f61e8b1492';

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
    String? searchQuery,
  }) {
    return AllGeofencesProvider(
      searchQuery: searchQuery,
    );
  }

  @override
  AllGeofencesProvider getProviderOverride(
    covariant AllGeofencesProvider provider,
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
  String? get name => r'allGeofencesProvider';
}

/// See also [allGeofences].
class AllGeofencesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [allGeofences].
  AllGeofencesProvider({
    String? searchQuery,
  }) : this._internal(
          (ref) => allGeofences(
            ref as AllGeofencesRef,
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
          searchQuery: searchQuery,
        );

  AllGeofencesProvider._internal(
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
    return other is AllGeofencesProvider && other.searchQuery == searchQuery;
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
mixin AllGeofencesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _AllGeofencesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with AllGeofencesRef {
  _AllGeofencesProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as AllGeofencesProvider).searchQuery;
}

String _$instructorsListHash() => r'a47d4411dc124be47ba8935137b08c53810679d9';

/// See also [instructorsList].
@ProviderFor(instructorsList)
final instructorsListProvider =
    AutoDisposeFutureProvider<List<Map<String, String>>>.internal(
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
    = AutoDisposeFutureProviderRef<List<Map<String, String>>>;
String _$courseEnrollmentDetailsHash() =>
    r'5e9f1c49cec08656456f6edcdd4d384af74f8bda';

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
