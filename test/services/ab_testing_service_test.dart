import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/ab_testing_service.dart';

/// A/B Testing Service Tests
void main() {
  late ABTestingService abTestingService;

  setUpAll(() {
    ABTestingService.isTestMode = true;
  });

  setUp(() {
    abTestingService = ABTestingService();
    abTestingService.clearAssignments(); // Clear between tests
  });

  group('Variant Assignment', () {
    test('getVariant returns string', () {
      final variant = abTestingService.getVariant('test_experiment');
      expect(variant, isA<String>());
    });

    test('getVariant returns consistent value for same experiment', () {
      final variant1 = abTestingService.getVariant('consistent_test');
      final variant2 = abTestingService.getVariant('consistent_test');
      expect(variant1, equals(variant2));
    });

    test('forceVariant overrides assignment', () {
      abTestingService.forceVariant('forced_experiment', 'variant_b');
      final variant = abTestingService.getVariant('forced_experiment');
      expect(variant, equals('variant_b'));
    });

    test('clearAssignments resets cache', () {
      abTestingService.forceVariant('cached_experiment', 'forced_value');
      abTestingService.clearAssignments();

      // After clear, should get fresh value (may be same or different)
      final variant = abTestingService.getVariant('cached_experiment');
      expect(variant, isA<String>());
    });
  });

  group('isVariant helper', () {
    test('isVariant returns true for matching variant', () {
      abTestingService.forceVariant('check_experiment', 'variant_a');
      expect(
        abTestingService.isVariant('check_experiment', 'variant_a'),
        isTrue,
      );
    });

    test('isVariant returns false for non-matching variant', () {
      abTestingService.forceVariant('check_experiment', 'variant_a');
      expect(
        abTestingService.isVariant('check_experiment', 'variant_b'),
        isFalse,
      );
    });
  });

  group('Active Experiments', () {
    test('getActiveExperiments returns map', () {
      final experiments = abTestingService.getActiveExperiments();
      expect(experiments, isA<Map<String, String>>());
    });

    test('getActiveExperiments includes expected keys', () {
      final experiments = abTestingService.getActiveExperiments();
      expect(experiments.keys, contains('onboarding_flow'));
    });
  });
}
