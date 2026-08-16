import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'golden_test_config.dart';

void main() {
  group(EnvironmentAwareGoldenFileComparator, () {
    test('localモードではOS別のlocalパスを使用すること', () {
      final comparator = EnvironmentAwareGoldenFileComparator(
        delegate: _RecordingGoldenFileComparator(),
        mode: GoldenMode.local,
        operatingSystem: 'windows',
        environment: const {},
      );

      expect(
        comparator.getTestUri(Uri.parse('golden/example.png'), null),
        Uri.parse('golden/.local/windows/example.png'),
      );
      expect(
        comparator.getTestUri(
          Uri.parse('goldens/name-editing/example.png'),
          null,
        ),
        Uri.parse('goldens/.local/windows/name-editing/example.png'),
      );
    });

    test('localモードでもversionを維持すること', () {
      final comparator = EnvironmentAwareGoldenFileComparator(
        delegate: _RecordingGoldenFileComparator(),
        mode: GoldenMode.local,
        operatingSystem: 'linux',
        environment: const {},
      );

      expect(
        comparator.getTestUri(Uri.parse('golden/example.png'), 2),
        Uri.parse('golden/.local/linux/example.2.png'),
      );
    });

    test('CIモードではcanonicalパスを使用すること', () {
      final comparator = EnvironmentAwareGoldenFileComparator(
        delegate: _RecordingGoldenFileComparator(),
        mode: GoldenMode.ci,
        operatingSystem: 'linux',
        environment: const {},
      );

      expect(
        comparator.getTestUri(Uri.parse('golden/example.png'), null),
        Uri.parse('golden/example.png'),
      );
    });

    test('localモードではgoldenディレクトリ外のパスを拒否すること', () {
      final comparator = EnvironmentAwareGoldenFileComparator(
        delegate: _RecordingGoldenFileComparator(),
        mode: GoldenMode.local,
        operatingSystem: 'windows',
        environment: const {},
      );

      expect(
        () => comparator.getTestUri(Uri.parse('example.png'), null),
        throwsStateError,
      );
    });

    test('CI外からのcanonical更新を拒否すること', () {
      final comparator = EnvironmentAwareGoldenFileComparator(
        delegate: _RecordingGoldenFileComparator(),
        mode: GoldenMode.ci,
        operatingSystem: 'linux',
        environment: const {},
      );

      expect(
        () => comparator.update(Uri.parse('golden/example.png'), Uint8List(0)),
        throwsStateError,
      );
    });

    test('Linux GitHub Actionsからのcanonical更新を許可すること', () async {
      final delegate = _RecordingGoldenFileComparator();
      final comparator = EnvironmentAwareGoldenFileComparator(
        delegate: delegate,
        mode: GoldenMode.ci,
        operatingSystem: 'linux',
        environment: const {
          allowCanonicalGoldenUpdateEnvironmentVariable: 'true',
          'GITHUB_ACTIONS': 'true',
          'RUNNER_OS': 'Linux',
        },
      );
      final golden = Uri.parse('golden/example.png');

      await comparator.update(golden, Uint8List(0));

      expect(delegate.updatedGolden, golden);
    });
  });
}

class _RecordingGoldenFileComparator extends GoldenFileComparator {
  Uri? updatedGolden;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async => true;

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    updatedGolden = golden;
  }
}
