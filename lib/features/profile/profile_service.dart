
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

class ProfileService {
  final CollectionReference<UserProfile> _profilesRef;

  ProfileService() 
      : _profilesRef = FirebaseFirestore.instance.collection('profiles').withConverter<UserProfile>(
          fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
          toFirestore: (profile, _) => profile.toJson(),
        );

  Future<UserProfile?> getProfile(String userId) async {
    final snapshot = await _profilesRef.doc(userId).get();
    return snapshot.data();
  }

  Future<void> createProfile(UserProfile profile) async {
    await _profilesRef.doc(profile.id).set(profile);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _profilesRef.doc(profile.id).update(profile.toJson());
  }
}
