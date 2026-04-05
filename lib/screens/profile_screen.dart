import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/app_routes.dart';
import '../core/firebase_service.dart';
import '../core/widgets.dart';
import 'main_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.userProfileStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? 'GDG Member';
        final email = data?['email'] ?? user.email ?? '';
        final role = data?['role'] ?? 'Member';
        final eventsAttended = data?['eventsAttended'] ?? 0;
        final meetingsAttended = data?['meetingsAttended'] ?? 0;
        final volunteerHours = data?['volunteerHours'] ?? 0;
        final interests = List<String>.from(data?['interests'] ?? []);
        final skillLevel = data?['skillLevel'] ?? 'Beginner';

        final initials = name
            .trim()
            .split(' ')
            .where((String w) => w.isNotEmpty)
            .take(2)
            .map((String w) => w[0].toUpperCase())
            .join();

        return MainScaffold(
          currentIndex: 3,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeroHeader(name, email, role, initials),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCard(
                          eventsAttended, meetingsAttended, volunteerHours),
                      const SizedBox(height: 16),
                      _buildInterests(context, interests, user.uid),
                      const SizedBox(height: 16),
                      _buildSkillLevel(context, skillLevel, user.uid),
                      const SizedBox(height: 16),
                      _buildBadges(eventsAttended, meetingsAttended),
                      const SizedBox(height: 16),
                      _buildSettingsSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader(
      String name, String email, String role, String initials) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gdgBlue, AppColors.gdgBlueLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 50),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.gdgYellow, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gdgBlue),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(
                  color: AppColors.gdgBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      int eventsAttended, int meetingsAttended, int volunteerHours) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _stat('$eventsAttended', 'Events', AppColors.gdgBlue),
                _divider(),
                _stat('$meetingsAttended', 'Meetings', AppColors.gdgRed),
                _divider(),
                _stat('${volunteerHours}h', 'Volunteer', AppColors.gdgGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, color: AppColors.border);

  Widget _buildInterests(
      BuildContext context, List<String> interests, String uid) {
    final allInterests = [
      'AI / ML',
      'Web Dev',
      'Cloud',
      'Android',
      'Flutter',
      'DevOps',
      'UI/UX',
      'Security',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Interests',
          actionLabel: 'Edit',
          onAction: () =>
              _showInterestsDialog(context, interests, uid, allInterests),
        ),
        const SizedBox(height: 10),
        interests.isEmpty
            ? GestureDetector(
                onTap: () =>
                    _showInterestsDialog(context, interests, uid, allInterests),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Tap Edit to add your interests',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((i) {
                  final variants = {
                    'AI / ML': ChipVariant.blue,
                    'Web Dev': ChipVariant.red,
                    'Cloud': ChipVariant.green,
                    'Flutter': ChipVariant.blue,
                  };
                  // FIX: was ChipVariant.defaultVariant
                  return GdgChip(i, variant: variants[i] ?? ChipVariant.plain);
                }).toList(),
              ),
      ],
    );
  }

  void _showInterestsDialog(BuildContext context, List<String> current,
      String uid, List<String> all) {
    final selected = List<String>.from(current);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Select Interests'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: all.map((interest) {
              final isSelected = selected.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                selectedColor: AppColors.gdgBlueLight,
                checkmarkColor: AppColors.gdgBlue,
                onSelected: (val) {
                  setDialogState(() {
                    if (val) {
                      selected.add(interest);
                    } else {
                      selected.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseService.db
                    .collection('users')
                    .doc(uid)
                    .update({'interests': selected});
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillLevel(BuildContext context, String skillLevel, String uid) {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Skill Level'),
        const SizedBox(height: 10),
        Row(
          children: levels.map((level) {
            final isSelected = skillLevel == level;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () async {
                  await FirebaseService.db
                      .collection('users')
                      .doc(uid)
                      .update({'skillLevel': level});
                },
                // FIX: was ChipVariant.defaultVariant
                child: GdgChip(
                  level,
                  variant: isSelected ? ChipVariant.blue : ChipVariant.plain,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadges(int eventsAttended, int meetingsAttended) {
    final badges = [
      ('🚀', 'First Login', AppColors.gdgYellow, true),
      ('🎯', '5 Meetings', AppColors.gdgBlue, meetingsAttended >= 5),
      ('🎓', '10 Meetings', AppColors.gdgGreen, meetingsAttended >= 10),
      ('⭐', '5 Events', AppColors.gdgRed, eventsAttended >= 5),
      (
        '👑',
        'Super Active',
        AppColors.gdgPurple,
        eventsAttended >= 5 && meetingsAttended >= 10
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Badges'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: badges.map((b) {
              final earned = b.$4;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Opacity(
                  opacity: earned ? 1.0 : 0.4,
                  child: ColorFiltered(
                    colorFilter: earned
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.color)
                        : const ColorFilter.matrix([
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: b.$3, width: 2),
                      ),
                      child: SizedBox(
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Column(
                            children: [
                              Text(b.$1, style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(b.$2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final items = [
      (Icons.notifications_outlined, 'Notifications', AppColors.gdgBlue),
      (Icons.privacy_tip_outlined, 'Privacy', AppColors.gdgGreen),
      (Icons.help_outline, 'Help & Support', AppColors.gdgYellow),
      (Icons.logout, 'Sign Out', AppColors.gdgRed),
    ];

    return Card(
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.$3.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.$1, color: item.$3, size: 18),
                ),
                title: Text(item.$2,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary, size: 20),
                onTap: isLast
                    ? () async {
                        await FirebaseService.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.login, (_) => false);
                        }
                      }
                    : null,
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
