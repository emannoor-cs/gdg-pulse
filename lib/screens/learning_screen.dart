import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/firebase_service.dart';
import '../core/widgets.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String? _expandedTrack;

  final _tracks = const [
    _Track('🌐', 'Web Dev', AppColors.gdgBlue, '8 resources'),
    _Track('🤖', 'AI / ML', AppColors.gdgRed, '12 resources'),
    _Track('☁', 'Cloud', AppColors.gdgGreen, '6 resources'),
    _Track('📱', 'Android', AppColors.gdgYellow, '9 resources'),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Learning Zone',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                      Text('Grow with your GDG chapter',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                // Per-user learning progress stored at users/{uid}/learning/progress
                stream: uid.isNotEmpty
                    ? FirebaseService.db
                        .collection('users')
                        .doc(uid)
                        .collection('learning')
                        .doc('progress')
                        .snapshots()
                    : const Stream.empty(),
                builder: (context, progressSnap) {
                  final progressData = progressSnap.data?.data()
                      as Map<String, dynamic>?;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Track Grid ──
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _tracks.length,
                        itemBuilder: (_, i) {
                          final track = _tracks[i];
                          final progress = (progressData?[track.name]
                                  as num?)
                              ?.toDouble() ??
                              0.0;
                          return _buildTrackCard(
                              track, progress, uid);
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Expanded Resources ──
                      if (_expandedTrack != null) ...[
                        _buildExpandedResources(
                            _tracks.firstWhere(
                                (t) => t.name == _expandedTrack),
                            progressData,
                            uid),
                        const SizedBox(height: 20),
                      ],

                      // ── Featured Resource ──
                      const SectionTitle('Featured Resource'),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.gdgBlueLight,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.play_circle_outline,
                                    color: AppColors.gdgBlue,
                                    size: 28),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Flutter for Beginners — Full Course',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w700)),
                                    SizedBox(height: 3),
                                    Text(
                                        'Video · 2h 15m · Google Developers',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors
                                                .textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.bookmark_border,
                                  color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Weekly Challenge (live from Firestore) ──
                      _buildWeeklyChallenge(uid),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(
      _Track track, double progress, String uid) {
    final isExpanded = _expandedTrack == track.name;

    return GestureDetector(
      onTap: () => setState(() {
        _expandedTrack = isExpanded ? null : track.name;
      }),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isExpanded
              ? BorderSide(color: track.color, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                Border(left: BorderSide(color: track.color, width: 4)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(track.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(track.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: track.color)),
              const SizedBox(height: 2),
              Text(track.subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary)),
              const SizedBox(height: 6),
              GdgAnimatedProgressBar(
                  value: progress, color: track.color),
              const SizedBox(height: 3),
              Text('${(progress * 100).toInt()}% done',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedResources(
    _Track track,
    Map<String, dynamic>? progressData,
    String uid,
  ) {
    final resources = [
      ('📄', 'Intro to ${track.name}', 'article', '${track.name}_intro'),
      ('▶', '${track.name} Fundamentals', 'video',
          '${track.name}_fundamentals'),
      ('🗺', '${track.name} Roadmap 2025', 'roadmap',
          '${track.name}_roadmap'),
    ];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('${track.name} Resources',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          ...resources.map((r) {
            final isCompleted =
                progressData?['${track.name}_${r.$4}'] == true;

            return ListTile(
              leading: Text(r.$1,
                  style: const TextStyle(fontSize: 18)),
              title: Text(r.$2,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null)),
              subtitle: Text(r.$3,
                  style: const TextStyle(fontSize: 11)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted)
                    const Icon(Icons.check_circle,
                        color: AppColors.gdgGreen, size: 18),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () =>
                        _markResourceDone(uid, track, r.$4),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: track.color,
                      side: BorderSide(color: track.color),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    child: Text(isCompleted ? 'Done' : 'Open'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _markResourceDone(
      String uid, _Track track, String resourceKey) async {
    if (uid.isEmpty) return;

    final docRef = FirebaseService.db
        .collection('users')
        .doc(uid)
        .collection('learning')
        .doc('progress');

    // Mark resource as done
    await docRef.set(
      {'${track.name}_$resourceKey': true},
      SetOptions(merge: true),
    );

    // Recalculate track progress (3 resources per track)
    final snap = await docRef.get();
    final data = snap.data() ?? {};
    final completed = ['intro', 'fundamentals', 'roadmap']
        .where((r) => data['${track.name}_${track.name}_$r'] == true ||
            data['${track.name}_$r'] == true)
        .length;
    final progress = completed / 3.0;

    await docRef.set(
      {track.name: progress},
      SetOptions(merge: true),
    );
  }

  Widget _buildWeeklyChallenge(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db
          .collection('weekly_challenges')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        final doc = snap.data?.docs.isNotEmpty == true
            ? snap.data!.docs.first
            : null;
        final data = doc?.data() as Map<String, dynamic>?;

        final title =
            data?['title'] ?? 'Build a Flutter Todo App';
        final participants = data?['participants'] ?? 0;
        final daysLeft = data != null
            ? _daysLeft(data['endsAt'] as Timestamp?)
            : 3;
        final challengeId = doc?.id ?? '';
        final joined = List<String>.from(data?['joinedBy'] ?? []);
        final hasJoined = joined.contains(uid);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gdgBlue, Color(0xFF0052CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Challenge 🏆',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      '$participants participants · $daysLeft days left',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: hasJoined || challengeId.isEmpty
                    ? null
                    : () => _joinChallenge(
                        uid, challengeId, participants),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasJoined
                      ? Colors.white38
                      : AppColors.gdgYellow,
                  foregroundColor: hasJoined
                      ? Colors.white
                      : const Color(0xFF5F4700),
                  minimumSize: const Size(80, 36),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                child: Text(hasJoined ? 'Joined ✓' : 'Join'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _joinChallenge(
      String uid, String challengeId, int currentCount) async {
    if (uid.isEmpty) return;
    await FirebaseService.db
        .collection('weekly_challenges')
        .doc(challengeId)
        .update({
      'participants': FieldValue.increment(1),
      'joinedBy': FieldValue.arrayUnion([uid]),
    });
  }

  int _daysLeft(Timestamp? ts) {
    if (ts == null) return 0;
    final diff = ts.toDate().difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}

class _Track {
  final String emoji, name, subtitle;
  final Color color;
  const _Track(this.emoji, this.name, this.color, this.subtitle);
}