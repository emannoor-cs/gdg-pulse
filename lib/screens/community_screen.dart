import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/firebase_service.dart';
import '../core/widgets.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.db.collection('users').snapshots(),
                    builder: (context, snap) {
                      final count = snap.data?.docs.length ?? 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Community',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          Text('GDG Chapter · $count members',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildQuoteCard(),
                  const SizedBox(height: 16),
                  _buildMemberSpotlight(),
                  const SizedBox(height: 16),
                  _buildPoll(),
                  const SizedBox(height: 16),

                  // ── Live posts from Firestore ──
                  const SectionTitle('Community Posts'),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.communityPostsStream(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snap.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return const GdgEmptyState(
                          emoji: '💬',
                          title: 'No posts yet',
                          subtitle: 'Be the first to share something!',
                        );
                      }

                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPostCard(
                              context: context,
                              postId: doc.id,
                              data: data,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gdgBlue,
        onPressed: () => _showCreatePostSheet(context),
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }

  // ── Post Card ──────────────────────────────

  Widget _buildPostCard({
    required BuildContext context,
    required String postId,
    required Map<String, dynamic> data,
  }) {
    final userName = data['userName'] ?? 'GDG Member';
    final content = data['content'] ?? '';
    final type = data['type'] ?? 'General';
    final likes = List<String>.from(data['likes'] ?? []);
    final createdAt = data['createdAt'] as Timestamp?;
    final uid = FirebaseService.currentUser?.uid ?? '';
    final isLiked = likes.contains(uid);

    final initials = userName
        .trim()
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w[0].toUpperCase())
        .join();

    final timeAgo = _timeAgo(createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GdgAvatar(
                  initials: initials.isEmpty ? '?' : initials,
                  color: AppColors.avatarColor(userName.length),
                  size: 38,
                  fontSize: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('$timeAgo · $type',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (data['userId'] == uid)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.gdgRed, size: 18),
                  onPressed: () => _deletePost(context, postId),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(postId, uid, likes),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color:
                          isLiked ? AppColors.gdgRed : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text('${likes.length}',
                        style: TextStyle(
                            fontSize: 12,
                            color: isLiked
                                ? AppColors.gdgRed
                                : AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(
      String postId, String uid, List<String> currentLikes) async {
    if (uid.isEmpty) return;
    final isLiked = currentLikes.contains(uid);
    await FirebaseService.db.collection('community_posts').doc(postId).update({
      'likes': isLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> _deletePost(BuildContext context, String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Delete this post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gdgRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseService.db
          .collection('community_posts')
          .doc(postId)
          .delete();
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return 'just now';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreatePostSheet(),
    );
  }

  // ── Static sections ────────────────────────

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border(left: BorderSide(color: AppColors.gdgBlue, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💬  Community Thought',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8)),
          SizedBox(height: 10),
          Text(
            '"The strength of a community is not in the number of people, but in how they lift each other up."',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
                fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 8),
          Text('— Shared by Chapter Lead',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildMemberSpotlight() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db
          .collection('users')
          .orderBy('eventsAttended', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        final data = snap.data?.docs.isNotEmpty == true
            ? snap.data!.docs.first.data() as Map<String, dynamic>
            : null;

        final name = data?['name'] ?? 'Top Member';
        final role = data?['role'] ?? 'Member';
        final initials = name
            .trim()
            .split(' ')
            .where((String w) => w.isNotEmpty)
            .take(2)
            .map((String w) => w[0].toUpperCase())
            .join();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MEMBER SPOTLIGHT ⭐',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gdgYellow,
                        letterSpacing: 1.0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GdgAvatar(
                        initials: initials.isEmpty ? '?' : initials,
                        color: AppColors.gdgRed,
                        size: 52,
                        fontSize: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(role,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.emoji_events,
                                color: AppColors.gdgGreen, size: 14),
                            SizedBox(width: 4),
                            Text('Most Active Member',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.gdgGreen)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoll() {
    final options = [
      ('AI / ML', 0.45, AppColors.gdgRed),
      ('Flutter', 0.30, AppColors.gdgBlue),
      ('Cloud', 0.15, AppColors.gdgYellow),
      ('Android', 0.10, AppColors.gdgGreen),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('POLL OF THE WEEK',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gdgRed,
                    letterSpacing: 1.0)),
            const SizedBox(height: 8),
            const Text('Which GDG topic excites you most for 2025?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            ...options.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(o.$1, style: const TextStyle(fontSize: 12)),
                          Text('${(o.$2 * 100).toInt()}%',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      GdgProgressBar(value: o.$2, color: o.$3),
                    ],
                  ),
                )),
            const Text('47 votes · expires Sunday',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Create Post Sheet
// ─────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _contentController = TextEditingController();
  String _selectedType = 'General';
  bool _isLoading = false;

  final _types = [
    'General',
    'Achievement',
    'Question',
    'Resource',
    'Event',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.currentUser;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('New Post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(hintText: 'Post type'),
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v ?? 'General'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share something with the community...',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _submitPost(user),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPost(user) async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write something')));
      return;
    }
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Get name from Firestore
      final profile = await FirebaseService.getUserProfile(user.uid);
      final name = profile?['name'] ?? user.email ?? 'GDG Member';

      await FirebaseService.createPost(
        userId: user.uid,
        userName: name,
        content: content,
        type: _selectedType,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
