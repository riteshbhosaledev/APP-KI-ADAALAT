import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nyaay_dhrishti/core/repositories/example_repository.dart';

void main() {
  group('Base Repository Tests', () {
    test('Example model should serialize correctly', () {
      final model = ExampleModel(
        id: 'test-id',
        name: 'Test Example',
        createdAt: DateTime.now(),
        metadata: {'key': 'value'},
      );

      final map = model.toMap();

      expect(map['name'], 'Test Example');
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['metadata'], {'key': 'value'});
    });

    test('Example model should deserialize correctly', () {
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      final map = {
        'name': 'Test Example',
        'createdAt': timestamp,
        'metadata': {'key': 'value'},
      };

      final model = ExampleModel.fromMap(map, 'test-id');

      expect(model.id, 'test-id');
      expect(model.name, 'Test Example');
      expect(
        model.createdAt.millisecondsSinceEpoch,
        closeTo(now.millisecondsSinceEpoch, 1000),
      ); // Allow 1 second tolerance
      expect(model.metadata, {'key': 'value'});
    });
  });
}
