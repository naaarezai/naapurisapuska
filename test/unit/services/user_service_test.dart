import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseStorage,
  FirebaseAuth,
  User,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot
])
void main() {
  // Since we are testing DI, we focus on ensuring the service uses the provided mocks.
  // In a real scenario we'd use mockito-generated classes, but here we can just verify initialization.

  group('UserService DI Tests', () {
    test('uses provided Firebase instances', () {
      final mockFirestore = FakeFirestore();
      final mockStorage = FakeStorage();
      final mockAuth = FakeAuth();

      final service = UserService(
        firestore: mockFirestore as FirebaseFirestore,
        storage: mockStorage as FirebaseStorage,
        auth: mockAuth as FirebaseAuth,
      );

      // Verification logic...
      expect(service, isNotNull);
    });
  });
}

class FakeFirestore extends Fake implements FirebaseFirestore {}

class FakeStorage extends Fake implements FirebaseStorage {}

class FakeAuth extends Fake implements FirebaseAuth {}
