// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instructor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$instructorCoursesHash() => r'f8004001654389d04ebd349112963394ebfe3733';

/// See also [instructorCourses].
@ProviderFor(instructorCourses)
final instructorCoursesProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  instructorCourses,
  name: r'instructorCoursesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$instructorCoursesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InstructorCoursesRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$instructorActiveSessionsHash() =>
    r'c56aaa2406211b03ca9d8f35499bb25ea99570a0';

/// See also [instructorActiveSessions].
@ProviderFor(instructorActiveSessions)
final instructorActiveSessionsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  instructorActiveSessions,
  name: r'instructorActiveSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$instructorActiveSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InstructorActiveSessionsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$instructorTodayStatsHash() =>
    r'e52a687ff85ee31aa9fbd4d10d9f3503f55b9f9a';

/// See also [instructorTodayStats].
@ProviderFor(instructorTodayStats)
final instructorTodayStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  instructorTodayStats,
  name: r'instructorTodayStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$instructorTodayStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InstructorTodayStatsRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$sessionDetailsHash() => r'aee3b98314cacc22823f85a6afd7904d784114db';

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

/// See also [sessionDetails].
@ProviderFor(sessionDetails)
const sessionDetailsProvider = SessionDetailsFamily();

/// See also [sessionDetails].
class SessionDetailsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [sessionDetails].
  const SessionDetailsFamily();

  /// See also [sessionDetails].
  SessionDetailsProvider call(
    String sessionId,
  ) {
    return SessionDetailsProvider(
      sessionId,
    );
  }

  @override
  SessionDetailsProvider getProviderOverride(
    covariant SessionDetailsProvider provider,
  ) {
    return call(
      provider.sessionId,
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
  String? get name => r'sessionDetailsProvider';
}

/// See also [sessionDetails].
class SessionDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [sessionDetails].
  SessionDetailsProvider(
    String sessionId,
  ) : this._internal(
          (ref) => sessionDetails(
            ref as SessionDetailsRef,
            sessionId,
          ),
          from: sessionDetailsProvider,
          name: r'sessionDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionDetailsHash,
          dependencies: SessionDetailsFamily._dependencies,
          allTransitiveDependencies:
              SessionDetailsFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SessionDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final String sessionId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(SessionDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionDetailsProvider._internal(
        (ref) => create(ref as SessionDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _SessionDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionDetailsProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionDetailsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _SessionDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with SessionDetailsRef {
  _SessionDetailsProviderElement(super.provider);

  @override
  String get sessionId => (origin as SessionDetailsProvider).sessionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
