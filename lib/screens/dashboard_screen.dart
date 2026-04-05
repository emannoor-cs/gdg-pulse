import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/app_routes.dart';
import '../core/firebase_service.dart';
import '../core/widgets.dart';
import 'main_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.currentUser;

    return MainScaffold(
      currentIndex: 0,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: StreamBuilder<DocumentSnapshot>(
              stream: user != null
                  ? FirebaseService.userProfileStream(user.uid)
                  : const Stream.empty(),
              builder: (context, snap) {
                final data =
                    snap.data?.data() as Map<String, dynamic>?;
                final name = (data?['name'] as String?) ?? 'GDG Member';
                final role = (data?['role'] as String?) ?? 'Member';

                // explicit String — no dynamic leaking into .isNotEmpty
                final initials = name
                    .trim()
                    .split(' ')
                    .where((String w) => w.isNotEmpty)
                    .take(2)
                    .map((String w) => w[0].toUpperCase())
                    .join();

                return _buildHeader(context, name, role, initials);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildHubCard(context),
                  const SizedBox(height: 20),
                  _buildUpcomingMeetings(context),
                  const SizedBox(height: 20),
                  _buildMyTeams(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String role,
      String initials) {
    return Container(
      color: AppColors.gdgBlue,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(role,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.profile),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.teamsStream(),
            builder: (context, teamsSnap) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.eventsStream(),
                builder: (context, eventsSnap) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.db
                        .collection('users')
                        .snapshots(),
                    builder: (context, usersSnap) {
                      final teams =
                          teamsSnap.data?.docs.length ?? 0;
                      final events =
                          eventsSnap.data?.docs.length ?? 0;
                      final members =
                          usersSnap.data?.docs.length ?? 0;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              _statItem('$teams', 'Teams'),
                              _divider(),
                              _statItem('$members', 'Members'),
                              _divider(),
                              _statItem('$events', 'Events'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 🌙';
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, color: Colors.white30);

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GdgChip('+ Create Team',
              variant: ChipVariant.blue,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.teams)),
          const SizedBox(width: 8),
          GdgChip('+ Meeting',
              variant: ChipVariant.red,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.meetings)),
          const SizedBox(width: 8),
          GdgChip('Mark Attend.',
              variant: ChipVariant.green,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.attendance)),
          const SizedBox(width: 8),
          GdgChip('+ Event',
              variant: ChipVariant.yellow,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.events)),
        ],
      ),
    );
  }

  Widget _buildHubCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('GDG PULSE HUB',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _hubItem(context, AppColors.gdgBlue, 'Events',
                    AppRoutes.events, 0),
                _hubItem(context, AppColors.gdgRed, 'Community',
                    AppRoutes.community, 500),
                _hubItem(context, AppColors.gdgYellow, 'Learning',
                    AppRoutes.learning, 1000),
                _hubItem(context, AppColors.gdgGreen, 'Volunteer',
                    AppRoutes.volunteer, 1500),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _hubItem(BuildContext context, Color color, String label,
      String? route, int delayMs) {
    return GestureDetector(
      onTap: route != null
          ? () => Navigator.pushNamed(context, route)
          : null,
      child: Column(
        children: [
          PulsingDot(
              color: color,
              size: 28,
              delay: Duration(milliseconds: delayMs)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildUpcomingMeetings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Upcoming Meetings',
          actionLabel: 'See all',
          onAction: () =>
              Navigator.pushNamed(context, AppRoutes.meetings),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.db
              .collection('meetings')
              .orderBy('date')
              .where('date',
                  isGreaterThanOrEqualTo: Timestamp.now())
              .limit(3)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            final docs = snap.data?.docs ?? [];

            if (docs.isEmpty) {
              return const GdgEmptyState(
                emoji: '📅',
                title: 'No upcoming meetings',
                subtitle: 'Tap + Meeting to schedule one',
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title =
                    (data['title'] as String?) ?? 'Meeting';
                final teamName =
                    (data['teamName'] as String?) ?? 'General';
                final date = data['date'] as Timestamp?;
                final diff = date != null
                    ? date
                        .toDate()
                        .difference(DateTime.now())
                        .inDays
                    : 999;
                final badgeLabel = diff == 0
                    ? 'Today'
                    : diff == 1
                        ? 'in 1d'
                        : 'in ${diff}d';
                final badgeBg = diff <= 1
                    ? AppColors.gdgRedLight
                    : diff <= 3
                        ? AppColors.gdgYellowLight
                        : AppColors.gdgGreenLight;
                final badgeFg = diff <= 1
                    ? AppColors.gdgRed
                    : diff <= 3
                        ? AppColors.gdgYellowDark
                        : AppColors.gdgGreen;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.meetings),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text(teamName,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors
                                              .textSecondary)),
                                ],
                              ),
                            ),
                            GdgBadge(badgeLabel,
                                backgroundColor: badgeBg,
                                textColor: badgeFg),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMyTeams(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'My Teams',
          actionLabel: 'See all',
          onAction: () =>
              Navigator.pushNamed(context, AppRoutes.teams),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.teamsStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            final docs = snap.data?.docs ?? [];

            if (docs.isEmpty) {
              return const GdgEmptyState(
                emoji: '👥',
                title: 'No teams yet',
                subtitle: 'Tap + Create Team to get started',
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    docs.take(5).toList().asMap().entries.map((e) {
                  final data =
                      e.value.data() as Map<String, dynamic>;
                  final name =
                      (data['name'] as String?) ?? 'Team';
                  final colorStr = data['color'] as String?;
                  final color = _colorFromStr(colorStr);
                  final initial = name.isNotEmpty
                      ? name[0].toUpperCase()
                      : 'T';
                  final memberCount =
                      (data['memberCount'] as int?) ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.teams),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              GdgAvatar(
                                  initials: initial,
                                  color: color,
                                  size: 32,
                                  fontSize: 13),
                              const SizedBox(height: 6),
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w600)),
                              Text('$memberCount members',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

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
}