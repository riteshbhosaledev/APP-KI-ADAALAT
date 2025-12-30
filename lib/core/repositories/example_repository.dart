import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_repository.dart';

/// Example model class
class ExampleModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ExampleModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.metadata,
  });

  factory ExampleModel.fromMap(Map<String, dynamic> map, String id) {
    return ExampleModel(
      id: id,
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

/// Example repository demonstrating the base repository pattern
class ExampleRepository extends BaseRepository<ExampleModel> {
  @override
  String get collectionName => 'examples';

  @override
  ExampleModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ExampleModel.fromMap(data, doc.id);
  }

  @override
  Map<String, dynamic> toFirestore(ExampleModel item) {
    return item.toMap();
  }

  /// Custom method specific to this repository
  Future<List<ExampleModel>> getRecentExamples({int limit = 10}) async {
    try {
      final querySnapshot = await collection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream recent examples
  Stream<List<ExampleModel>> streamRecentExamples({int limit = 10}) {
    return collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
        );
  }
}
