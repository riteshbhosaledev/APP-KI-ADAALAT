import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Base repository class providing common Firestore operations
abstract class BaseRepository<T> {
  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection name for this repository
  String get collectionName;

  /// Convert Firestore document to model object
  T fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc);

  /// Convert model object to Firestore data
  Map<String, dynamic> toFirestore(T item);

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(collectionName);

  /// Create a new document
  Future<String> create(T item) async {
    try {
      final docRef = await collection.add(toFirestore(item));
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating document in $collectionName: $e');
      rethrow;
    }
  }

  /// Create a document with specific ID
  Future<void> createWithId(String id, T item) async {
    try {
      await collection.doc(id).set(toFirestore(item));
    } catch (e) {
      debugPrint('Error creating document with ID in $collectionName: $e');
      rethrow;
    }
  }

  /// Get document by ID
  Future<T?> getById(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting document from $collectionName: $e');
      rethrow;
    }
  }

  /// Update document
  Future<void> update(String id, T item) async {
    try {
      await collection.doc(id).update(toFirestore(item));
    } catch (e) {
      debugPrint('Error updating document in $collectionName: $e');
      rethrow;
    }
  }

  /// Update specific fields
  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    try {
      await collection.doc(id).update(fields);
    } catch (e) {
      debugPrint('Error updating fields in $collectionName: $e');
      rethrow;
    }
  }

  /// Delete document
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting document from $collectionName: $e');
      rethrow;
    }
  }

  /// Get all documents
  Future<List<T>> getAll() async {
    try {
      final querySnapshot = await collection.get();
      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting all documents from $collectionName: $e');
      rethrow;
    }
  }

  /// Get documents with query
  Future<List<T>> getWhere(String field, dynamic value) async {
    try {
      final querySnapshot = await collection
          .where(field, isEqualTo: value)
          .get();
      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error querying documents from $collectionName: $e');
      rethrow;
    }
  }

  /// Stream all documents
  Stream<List<T>> streamAll() {
    return collection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
    );
  }

  /// Stream document by ID
  Stream<T?> streamById(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    });
  }

  /// Stream documents with query
  Stream<List<T>> streamWhere(String field, dynamic value) {
    return collection
        .where(field, isEqualTo: value)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
        );
  }

  /// Batch operations
  WriteBatch get batch => _firestore.batch();

  /// Execute batch
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Error committing batch operation: $e');
      rethrow;
    }
  }

  /// Transaction operations
  Future<R> runTransaction<R>(
    Future<R> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      debugPrint('Error running transaction: $e');
      rethrow;
    }
  }
}
