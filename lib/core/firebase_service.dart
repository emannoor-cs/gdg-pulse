import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ── Auth ──────────────────────────────────────

  static User? get currentUser => auth.currentUser;

  static Stream<User?> get authStateChanges => auth.authStateChanges();

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  // ── Users ─────────────────────────────────────

  static Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String role = 'Member',
  }) async {
    await db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'interests': [],
      'skillLevel': 'Beginner',
      'volunteerHours': 0,
      'eventsAttended': 0,
      'meetingsAttended': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Stream<DocumentSnapshot> userProfileStream(String uid) {
    return db.collection('users').doc(uid).snapshots();
  }

  // ── Teams ─────────────────────────────────────

  static Stream<QuerySnapshot> teamsStream() {
    return db.collection('teams').orderBy('createdAt', descending: false).snapshots();
  }

  static Future<void> createTeam({
    required String name,
    required String description,
    required String color,
  }) async {
    await db.collection('teams').add({
      'name': name,
      'description': description,
      'color': color,
      'memberCount': 0,
      'members': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Meetings ──────────────────────────────────

  static Stream<QuerySnapshot> meetingsStream() {
    return db.collection('meetings').orderBy('date', descending: false).snapshots();
  }

  static Future<void> createMeeting({
    required String title,
    required String teamId,
    required DateTime date,
    required String location,
  }) async {
    await db.collection('meetings').add({
      'title': title,
      'teamId': teamId,
      'date': Timestamp.fromDate(date),
      'location': location,
      'attendees': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Attendance ────────────────────────────────

  static Future<void> markAttendance({
    required String meetingId,
    required String userId,
    required String status,
  }) async {
    await db
        .collection('meetings')
        .doc(meetingId)
        .collection('attendance')
        .doc(userId)
        .set({
      'userId': userId,
      'status': status,
      'markedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> attendanceStream(String meetingId) {
    return db
        .collection('meetings')
        .doc(meetingId)
        .collection('attendance')
        .snapshots();
  }

  // ── Events ────────────────────────────────────

  static Stream<QuerySnapshot> eventsStream() {
    return db.collection('events').orderBy('date', descending: false).snapshots();
  }

  static Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String type,
  }) async {
    await db.collection('events').add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'type': type,
      'registrations': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> registerForEvent(String eventId, String userId) async {
    await db.collection('events').doc(eventId).update({
      'registrations': FieldValue.arrayUnion([userId]),
    });
  }

  // ── Volunteer ─────────────────────────────────

  static Stream<QuerySnapshot> volunteerOpportunitiesStream() {
    return db.collection('volunteer_opportunities').snapshots();
  }

  static Future<void> signUpForVolunteer({
    required String userId,
    required String opportunityId,
    required String role,
    required String eventName,
    String notes = '',
  }) async {
    await db.collection('volunteer_signups').add({
      'userId': userId,
      'opportunityId': opportunityId,
      'role': role,
      'eventName': eventName,
      'notes': notes,
      'status': 'Pending',
      'hours': 0,
      'signedUpAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> volunteerHistoryStream(String userId) {
    return db
        .collection('volunteer_signups')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // ── Community ─────────────────────────────────

  static Stream<QuerySnapshot> communityPostsStream() {
    return db.collection('community_posts').orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> createPost({
    required String userId,
    required String userName,
    required String content,
    required String type,
  }) async {
    await db.collection('community_posts').add({
      'userId': userId,
      'userName': userName,
      'content': content,
      'type': type,
      'likes': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}