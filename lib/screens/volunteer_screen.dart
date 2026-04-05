import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/firebase_service.dart';
import '../core/widgets.dart';
import 'main_scaffold.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.currentUser?.uid ?? '';

    return MainScaffold(
      currentIndex: -1,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
              child: _buildHeader(uid)),
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.gdgBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.gdgBlue,
              tabs: const [
                Tab(text: 'Opportunities'),
                Tab(text: 'Sign Up'),
                Tab(text: 'My History'),
                Tab(text: 'Leaderboard'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OpportunitiesTab(onSignUp: () => _tabController.animateTo(1)),
            _SignUpTab(),
            _HistoryTab(uid: uid),
            _LeaderboardTab(currentUid: uid),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.volunteerHistoryStream(uid),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final totalHours = docs.fold<int>(
            0,
            (sum, d) =>
                sum +
                ((d.data() as Map<String, dynamic>)['hours'] as int? ??
                    0));
        final eventsHelped = docs.length;
        final tier = totalHours >= 100
            ? 'Platinum'
            : totalHours >= 50
                ? 'Gold'
                : totalHours >= 20
                    ? 'Silver'
                    : 'Bronze';

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gdgGreen, AppColors.gdgBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Volunteer Hub',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Make an impact with your community',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _headerStat('$totalHours', 'Total Hours'),
                  const SizedBox(width: 24),
                  _headerStat('$eventsHelped', 'Events Helped'),
                  const SizedBox(width: 24),
                  _headerStat(tier, 'Your Tier'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Opportunities Tab
// ─────────────────────────────────────────────

class _OpportunitiesTab extends StatelessWidget {
  final VoidCallback onSignUp;
  const _OpportunitiesTab({required this.onSignUp});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.volunteerOpportunitiesStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Column(
            children: [
              const GdgEmptyState(
                emoji: '🙋',
                title: 'No opportunities yet',
                subtitle: 'Check back later for volunteer roles',
              ),
              const SizedBox(height: 12),
              // Seed button for admins
              ElevatedButton.icon(
                onPressed: () => _seedOpportunities(),
                icon: const Icon(Icons.add),
                label: const Text('Add Sample Opportunities'),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _OpportunityCard(
                opportunityId: doc.id,
                data: data,
                onSignUp: onSignUp);
          },
        );
      },
    );
  }

  Future<void> _seedOpportunities() async {
    final samples = [
      {
        'title': 'Event Setup Crew',
        'event': 'Google I/O Extended 2025',
        'date': 'May 15, 2025',
        'hours': 4,
        'spots': 3,
        'color': 'blue',
        'icon': 'build',
      },
      {
        'title': 'Registration Desk',
        'event': 'Flutter Workshop',
        'date': 'May 22, 2025',
        'hours': 3,
        'spots': 2,
        'color': 'red',
        'icon': 'reg',
      },
      {
        'title': 'Social Media Coverage',
        'event': 'ML Summit',
        'date': 'June 5, 2025',
        'hours': 5,
        'spots': 1,
        'color': 'green',
        'icon': 'camera',
      },
    ];

    for (final s in samples) {
      await FirebaseService.db
          .collection('volunteer_opportunities')
          .add({...s, 'createdAt': FieldValue.serverTimestamp()});
    }
  }
}

class _OpportunityCard extends StatelessWidget {
  final String opportunityId;
  final Map<String, dynamic> data;
  final VoidCallback onSignUp;

  const _OpportunityCard({
    required this.opportunityId,
    required this.data,
    required this.onSignUp,
  });

  Color _colorFromStr(String? s) {
    switch (s) {
      case 'red':
        return AppColors.gdgRed;
      case 'green':
        return AppColors.gdgGreen;
      case 'yellow':
        return AppColors.gdgYellow;
      case 'purple':
        return AppColors.gdgPurple;
      default:
        return AppColors.gdgBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Volunteer Role';
    final event = data['event'] ?? '';
    final date = data['date'] ?? '';
    final hours = data['hours'] ?? 0;
    final spots = data['spots'] ?? 0;
    final color = _colorFromStr(data['color'] as String?);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.volunteer_activism,
                  color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(event,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(date,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('${hours}h',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_outline,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('$spots spots',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(60, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sign Up Tab
// ─────────────────────────────────────────────

class _SignUpTab extends StatefulWidget {
  @override
  State<_SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<_SignUpTab> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  String? _selectedEvent;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final _roles = [
    'Event Setup',
    'Registration Desk',
    'Social Media',
    'Speaker Coordinator',
    'Tech Support',
    'Photography',
    'Logistics',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Volunteer Sign Up'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Event',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),

                    // Events pulled from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseService.eventsStream(),
                      builder: (context, snap) {
                        final events = snap.data?.docs
                                .map((d) =>
                                    (d.data() as Map<String,
                                        dynamic>)['title'] as String? ??
                                    '')
                                .where((t) => t.isNotEmpty)
                                .toList() ??
                            [];

                        return DropdownButtonFormField<String>(
                          value: _selectedEvent,
                          hint: const Text('Choose an event'),
                          decoration: const InputDecoration(),
                          items: events
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedEvent = v),
                          validator: (v) => v == null
                              ? 'Please select an event'
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Role',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      hint: const Text('Choose a role'),
                      decoration: const InputDecoration(),
                      items: _roles
                          .map((r) => DropdownMenuItem(
                              value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedRole = v),
                      validator: (v) =>
                          v == null ? 'Please select a role' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Additional Notes',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Any skills, availability, or notes...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Submit Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseService.signUpForVolunteer(
        userId: uid,
        opportunityId: '',
        role: _selectedRole!,
        eventName: _selectedEvent!,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed up!'),
            backgroundColor: AppColors.gdgGreen,
          ),
        );
        _formKey.currentState?.reset();
        setState(() {
          _selectedEvent = null;
          _selectedRole = null;
        });
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ─────────────────────────────────────────────
// History Tab
// ─────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  final String uid;
  const _HistoryTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.volunteerHistoryStream(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return const GdgEmptyState(
            emoji: '📋',
            title: 'No history yet',
            subtitle: 'Sign up for a volunteer role to get started',
          );
        }

        final totalHours = docs.fold<int>(
            0,
            (sum, d) =>
                sum +
                ((d.data() as Map<String, dynamic>)['hours'] as int? ??
                    0));

        final tier = totalHours >= 100
            ? 'Platinum'
            : totalHours >= 50
                ? 'Gold'
                : totalHours >= 20
                    ? 'Silver'
                    : 'Bronze';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('$totalHours', 'Total Hours',
                        AppColors.gdgBlue),
                    _stat('${docs.length}', 'Events',
                        AppColors.gdgGreen),
                    _stat(tier, 'Tier', AppColors.gdgYellow),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionTitle('Past Volunteering'),
            const SizedBox(height: 10),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final role = data['role'] ?? 'Volunteer';
              final event = data['eventName'] ?? '';
              final hours = data['hours'] ?? 0;
              final status = data['status'] ?? 'Pending';
              final signedUpAt = data['signedUpAt'] as Timestamp?;
              final dateStr = signedUpAt != null
                  ? _formatDate(signedUpAt.toDate())
                  : 'N/A';

              final statusColor = status == 'Completed'
                  ? AppColors.gdgGreen
                  : status == 'Pending'
                      ? AppColors.gdgYellow
                      : AppColors.gdgRed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.volunteer_activism,
                          color: statusColor, size: 20),
                    ),
                    title: Text(role,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    subtitle: Text('$event · $dateStr',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${hours}h',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.gdgBlue)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(status,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}

// ─────────────────────────────────────────────
// Leaderboard Tab
// ─────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  final String currentUid;
  const _LeaderboardTab({required this.currentUid});

  Color _tierColor(String tier) {
    switch (tier) {
      case 'Platinum':
        return AppColors.gdgPurple;
      case 'Gold':
        return AppColors.gdgYellow;
      case 'Silver':
        return AppColors.textTertiary;
      default:
        return const Color(0xFFCD7F32);
    }
  }

  String _tierFromHours(int hours) {
    if (hours >= 100) return 'Platinum';
    if (hours >= 50) return 'Gold';
    if (hours >= 20) return 'Silver';
    return 'Bronze';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db
          .collection('volunteer_signups')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Aggregate hours per user
        final hoursMap = <String, int>{};
        final nameMap = <String, String>{};

        for (final doc in snap.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          final uid = data['userId'] as String? ?? '';
          final hours = data['hours'] as int? ?? 0;
          hoursMap[uid] = (hoursMap[uid] ?? 0) + hours;
        }

        // Sort descending
        final sorted = hoursMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sorted.isEmpty) {
          return const GdgEmptyState(
            emoji: '🏆',
            title: 'No volunteers yet',
            subtitle: 'Sign up to appear on the leaderboard',
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchNames(sorted.map((e) => e.key).toList()),
          builder: (context, nameSnap) {
            final names = nameSnap.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTierLegend(),
                const SizedBox(height: 16),
                const SectionTitle('Top Volunteers'),
                const SizedBox(height: 10),
                ...sorted.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final uid = entry.value.key;
                  final hours = entry.value.value;
                  final tier = _tierFromHours(hours);
                  final isMe = uid == currentUid;
                  final nameData = names.firstWhere(
                      (n) => n['uid'] == uid,
                      orElse: () => {'name': 'GDG Member'});
                  final name = nameData['name'] ?? 'GDG Member';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isMe
                            ? const BorderSide(
                                color: AppColors.gdgBlue, width: 2)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text('#$rank',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: rank <= 3
                                          ? _tierColor(tier)
                                          : AppColors.textTertiary)),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.avatarColor(rank),
                              child: Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(name,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w600)),
                                      if (isMe) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.gdgBlueLight,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text('You',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      AppColors.gdgBlue,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(tier,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: _tierColor(tier))),
                                ],
                              ),
                            ),
                            Text('${hours}h',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gdgBlue)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchNames(
      List<String> uids) async {
    if (uids.isEmpty) return [];
    final results = <Map<String, dynamic>>[];
    for (final uid in uids) {
      final profile = await FirebaseService.getUserProfile(uid);
      if (profile != null) results.add({...profile, 'uid': uid});
    }
    return results;
  }

  Widget _buildTierLegend() {
    final tiers = [
      ('Platinum', AppColors.gdgPurple),
      ('Gold', AppColors.gdgYellow),
      ('Silver', AppColors.textTertiary),
      ('Bronze', const Color(0xFFCD7F32)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tiers.map((t) {
            return Column(
              children: [
                Icon(Icons.workspace_premium, color: t.$2, size: 22),
                const SizedBox(height: 4),
                Text(t.$1,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.$2)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}