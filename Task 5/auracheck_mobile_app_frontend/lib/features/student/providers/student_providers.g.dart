// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeSessionsForStudentHash() =>
    r'59c7ec705aaaa611477d88210230edd17a7b8437';

/// See also [activeSessionsForStudent].
@ProviderFor(activeSessionsForStudent)
final activeSessionsForStudentProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  activeSessionsForStudent,
  name: r'activeSessionsForStudentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSessionsForStudentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSessionsForStudentRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$studentAttendanceStatsHash() =>
    r'8010ac76ae58b67829cf7bc4747e4071ea51d545';

/// See also [studentAttendanceStats].
@ProviderFor(studentAttendanceStats)
final studentAttendanceStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  studentAttendanceStats,
  name: r'studentAttendanceStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentAttendanceStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentAttendanceStatsRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$studentAttendanceHistoryHash() =>
    r'6d034a1292b742805387dcaa2e8ce8c307808fa9';

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

/// See also [studentAttendanceHistory].
@ProviderFor(studentAttendanceHistory)
const studentAttendanceHistoryProvider = StudentAttendanceHistoryFamily();

/// See also [studentAttendanceHistory].
class StudentAttendanceHistoryFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [studentAttendanceHistory].
  const StudentAttendanceHistoryFamily();

  /// See also [studentAttendanceHistory].
  StudentAttendanceHistoryProvider call({
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StudentAttendanceHistoryProvider(
      courseId: courseId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  StudentAttendanceHistoryProvider getProviderOverride(
    covariant StudentAttendanceHistoryProvider provider,
  ) {
    return call(
      courseId: provider.courseId,
      startDate: provider.startDate,
      endDate: provider.endDate,
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
  String? get name => r'studentAttendanceHistoryProvider';
}

/// See also [studentAttendanceHistory].
class StudentAttendanceHistoryProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [studentAttendanceHistory].
  StudentAttendanceHistoryProvider({
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
          (ref) => studentAttendanceHistory(
            ref as StudentAttendanceHistoryRef,
            courseId: courseId,
            startDate: startDate,
            endDate: endDate,
          ),
          from: studentAttendanceHistoryProvider,
          name: r'studentAttendanceHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studentAttendanceHistoryHash,
          dependencies: StudentAttendanceHistoryFamily._dependencies,
          allTransitiveDependencies:
              StudentAttendanceHistoryFamily._allTransitiveDependencies,
          courseId: courseId,
          startDate: startDate,
          endDate: endDate,
        );

  StudentAttendanceHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String? courseId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
            StudentAttendanceHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentAttendanceHistoryProvider._internal(
        (ref) => create(ref as StudentAttendanceHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseId: courseId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _StudentAttendanceHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentAttendanceHistoryProvider &&
        other.courseId == courseId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentAttendanceHistoryRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `courseId` of this provider.
  String? get courseId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _StudentAttendanceHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with StudentAttendanceHistoryRef {
  _StudentAttendanceHistoryProviderElement(super.provider);

  @override
  String? get courseId => (origin as StudentAttendanceHistoryProvider).courseId;
  @override
  DateTime? get startDate =>
      (origin as StudentAttendanceHistoryProvider).startDate;
  @override
  DateTime? get endDate => (origin as StudentAttendanceHistoryProvider).endDate;
}

String _$studentEnrolledCoursesHash() =>
    r'316afd28f8192f7ffaee429aaa3420c0872737e7';

/// See also [studentEnrolledCourses].
@ProviderFor(studentEnrolledCourses)
final studentEnrolledCoursesProvider =
    AutoDisposeFutureProvider<List<Map<String, String>>>.internal(
  studentEnrolledCourses,
  name: r'studentEnrolledCoursesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentEnrolledCoursesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentEnrolledCoursesRef
    = AutoDisposeFutureProviderRef<List<Map<String, String>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
