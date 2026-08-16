import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const goldenModeEnvironmentVariable = 'GOLDEN_MODE';
const allowCanonicalGoldenUpdateEnvironmentVariable =
    'ALLOW_CANONICAL_GOLDEN_UPDATE';

enum GoldenMode { local, ci }

void configureGoldenFileComparator() {
  if (goldenFileComparator is EnvironmentAwareGoldenFileComparator) {
    return;
  }

  final environment = Platform.environment;
  final mode = switch (environment[goldenModeEnvironmentVariable] ?? 'local') {
    'local' => GoldenMode.local,
    'ci' => GoldenMode.ci,
    final value => throw StateError(
      'Unsupported $goldenModeEnvironmentVariable value: "$value". '
      'Use "local" or "ci".',
    ),
  };

  goldenFileComparator = EnvironmentAwareGoldenFileComparator(
    delegate: goldenFileComparator,
    mode: mode,
    operatingSystem: Platform.operatingSystem,
    environment: environment,
  );
}

class EnvironmentAwareGoldenFileComparator extends GoldenFileComparator {
  EnvironmentAwareGoldenFileComparator({
    required this.delegate,
    required this.mode,
    required this.operatingSystem,
    required Map<String, String> environment,
  }) : environment = Map.unmodifiable(environment);

  final GoldenFileComparator delegate;
  final GoldenMode mode;
  final String operatingSystem;
  final Map<String, String> environment;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) {
    return delegate.compare(imageBytes, golden);
  }

  @override
  Uri getTestUri(Uri key, int? version) {
    final canonicalUri = delegate.getTestUri(key, version);
    if (mode == GoldenMode.ci) {
      return canonicalUri;
    }

    return _localGoldenUri(canonicalUri);
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) {
    if (mode == GoldenMode.ci && !_canUpdateCanonicalGoldens) {
      throw StateError(
        'Canonical golden files can only be updated by the Linux GitHub '
        'Actions workflow. Run the local golden update command instead.',
      );
    }

    return delegate.update(golden, imageBytes);
  }

  bool get _canUpdateCanonicalGoldens =>
      environment[allowCanonicalGoldenUpdateEnvironmentVariable] == 'true' &&
      environment['GITHUB_ACTIONS'] == 'true' &&
      environment['RUNNER_OS'] == 'Linux';

  Uri _localGoldenUri(Uri canonicalUri) {
    if (canonicalUri.isAbsolute) {
      throw StateError('Golden file paths must be relative: "$canonicalUri".');
    }

    final segments = canonicalUri.pathSegments;
    final goldenDirectoryIndex = segments.indexWhere(
      (segment) => segment == 'golden' || segment == 'goldens',
    );
    if (goldenDirectoryIndex == -1) {
      throw StateError(
        'Golden files must be stored under a golden or goldens directory: '
        '"$canonicalUri".',
      );
    }

    return Uri(
      pathSegments: [
        ...segments.take(goldenDirectoryIndex + 1),
        '.local',
        operatingSystem,
        ...segments.skip(goldenDirectoryIndex + 1),
      ],
    );
  }
}
