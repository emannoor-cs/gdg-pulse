import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/app_routes.dart';
import '../core/firebase_service.dart';
import '../core/role_service.dart';
import '../core/widgets.dart';
import 'main_scaffold.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _userRole = AppRoles.member;
  bool _roleLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RoleService.getCurrentUserRole();
    if (mounted) {
      setState(() {
        _userRole = role;
        _roleLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Block rendering until role is confirmed — prevents permission flash
    if (!_roleLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final canCreateTeam = RoleService.canCreateTeam(_userRole);

    return MainScaffold(
      currentIndex: 0,
      fab: canCreateTeam
          ? FloatingActionButton(
              backgroundColor: AppColors.gdgBlue,
              onPressed: () => _showCreateTeamSheet(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.teamsStream(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Teams',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        Text('$count active teams',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    );
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleBadgeColor(_userRole),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_userRole,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.teamsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_outlined,
                            size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        const Text('No teams yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text(
                          canCreateTeam
                              ? 'Tap + to create your first team'
                              : 'Teams will appear here once created',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary),
                        ),
                        if (canCreateTeam) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateTeamSheet(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Team'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    final doc = snapshot.data!.docs[i];
                    return _TeamCard(
                      teamId: doc.id,
                      data: doc.data() as Map<String, dynamic>,
                      userRole: _userRole,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _roleBadgeColor(String role) {
    switch (role) {
      case AppRoles.chapterLead:
        return AppColors.gdgGreen;
      case AppRoles.teamLead:
        return AppColors.gdgYellowDark;
      default:
        return AppColors.textTertiary;
    }
  }

  void _showCreateTeamSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateTeamSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Team Card
// ─────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final String teamId;
  final Map<String, dynamic> data;
  final String userRole;

  const _TeamCard({
    required this.teamId,
    required this.data,
    required this.userRole,
  });

  Color _colorFromString(String? colorStr) {
    switch (colorStr) {
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
    final name = data['name'] ?? 'Unnamed Team';
    final description = data['description'] ?? '';
    final color = _colorFromString(data['color']);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'T';

    final canManageTeam = RoleService.canManageTeam(userRole);
    final canAddRemoveMembers = RoleService.canAddRemoveMembers(userRole);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .snapshots(),
      builder: (context, memberSnapshot) {
        final members = memberSnapshot.data?.docs ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Team Header ──
                Row(
                  children: [
                    GdgAvatar(
                        initials: initial,
                        color: color,
                        size: 40,
                        fontSize: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text(description,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    // 3-dot menu — Chapter Lead only
                    if (canManageTeam)
                      IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: AppColors.textTertiary),
                        onPressed: () =>
                            _showTeamOptions(context, teamId, name),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Members Avatars Row ──
                Row(
                  children: [
                    ...members.take(4).toList().asMap().entries.map((e) {
                      final m = e.value.data() as Map<String, dynamic>;
                      final mName = m['name'] ?? '';
                      final initials = mName
                          .trim()
                          .split(' ')
                          .where((String w) => w.isNotEmpty)
                          .take(2)
                          .map((String w) => w[0].toUpperCase())
                          .join();
                      return Transform.translate(
                        offset: Offset(-e.key * 8.0, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          child: GdgAvatar(
                              initials: initials.isEmpty ? '?' : initials,
                              color: AppColors.avatarColor(e.key),
                              size: 30,
                              fontSize: 11),
                        ),
                      );
                    }),
                    if (members.length > 4)
                      Transform.translate(
                        offset: const Offset(-32, 0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface3,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text('+${members.length - 4}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)),
                        ),
                      ),
                    const Spacer(),
                    GdgBadge('${members.length} members'),
                  ],
                ),

                // ── Member List ──
                if (members.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...members.map((m) {
                    final mData = m.data() as Map<String, dynamic>;
                    final mName = mData['name'] ?? 'Unknown';
                    final mRole = mData['role'] ?? 'Member';
                    final initials = mName
                        .trim()
                        .split(' ')
                        .where((String w) => w.isNotEmpty)
                        .take(2)
                        .map((String w) => w[0].toUpperCase())
                        .join();
                    final idx = members.indexOf(m);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          GdgAvatar(
                              initials: initials.isEmpty ? '?' : initials,
                              color: AppColors.avatarColor(idx),
                              size: 34,
                              fontSize: 12),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                Text(mRole,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          if (mRole == 'Team Lead')
                            GdgBadge('Lead',
                                backgroundColor: color.withOpacity(0.15),
                                textColor: color),
                          // Remove button — Chapter Lead & Team Lead ONLY
                          if (canAddRemoveMembers)
                            IconButton(
                              icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.gdgRed,
                                  size: 18),
                              onPressed: () => _removeMember(
                                  context, teamId, m.id, mName),
                            ),
                        ],
                      ),
                    );
                  }),
                ],

                if (members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      canAddRemoveMembers
                          ? 'No members yet. Add members to get started.'
                          : 'No members yet.',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ),

                const SizedBox(height: 12),

                // ── Action Buttons ──
                Row(
                  children: [
                    // Add Member — Chapter Lead & Team Lead only
                    if (canAddRemoveMembers) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showAddMemberSheet(context, teamId),
                          icon: const Icon(Icons.person_add_outlined,
                              size: 14),
                          label: const Text('Add Member'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gdgBlue,
                            side: const BorderSide(
                                color: AppColors.gdgBlue),
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.meetings),
                        icon: const Icon(Icons.calendar_today_outlined,
                            size: 14),
                        label: const Text('Meeting'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gdgGreen,
                          side: const BorderSide(
                              color: AppColors.gdgGreen),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
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

  void _showTeamOptions(
      BuildContext context, String teamId, String teamName) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.gdgBlue),
              title: const Text('Edit Team'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.gdgRed),
              title: const Text('Delete Team',
                  style: TextStyle(color: AppColors.gdgRed)),
              onTap: () async {
                Navigator.pop(context);
                await _deleteTeam(context, teamId, teamName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTeam(
      BuildContext context, String teamId, String teamName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Team'),
        content:
            Text('Are you sure you want to delete "$teamName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gdgRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseService.db.collection('teams').doc(teamId).delete();
    }
  }

  void _showAddMemberSheet(BuildContext context, String teamId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemberSheet(teamId: teamId),
    );
  }

  Future<void> _removeMember(BuildContext context, String teamId,
      String memberId, String memberName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove $memberName from this team?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gdgRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseService.db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(memberId)
          .delete();
      await FirebaseService.db
          .collection('teams')
          .doc(teamId)
          .update({'memberCount': FieldValue.increment(-1)});
    }
  }
}

// ─────────────────────────────────────────────
// Create Team Sheet  (Chapter Lead only)
// ─────────────────────────────────────────────

class _CreateTeamSheet extends StatefulWidget {
  const _CreateTeamSheet();

  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedColor = 'blue';
  bool _isLoading = false;

  final _colorOptions = [
    ('blue', AppColors.gdgBlue),
    ('red', AppColors.gdgRed),
    ('green', AppColors.gdgGreen),
    ('yellow', AppColors.gdgYellow),
    ('purple', AppColors.gdgPurple),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Create New Team',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Team name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration:
                const InputDecoration(hintText: 'Team description'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text('Team Color',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: _colorOptions.map((c) {
              final isSelected = _selectedColor == c.$1;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c.$1),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.$2,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _createTeam,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Create Team'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTeam() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a team name')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseService.createTeam(
        name: name,
        description: _descController.text.trim(),
        color: _selectedColor,
      );
      if (mounted) Navigator.pop(context);
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
// Add Member Sheet
// ─────────────────────────────────────────────

class _AddMemberSheet extends StatefulWidget {
  final String teamId;
  const _AddMemberSheet({required this.teamId});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameController = TextEditingController();
  String _selectedRole = 'Member';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Add Member',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration:
                const InputDecoration(hintText: 'Member full name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(hintText: 'Role'),
            items: [
              'Member', 'Team Lead', 'Developer',
              'Designer', 'Researcher', 'DevOps', 'Architect'
            ]
                .map((r) =>
                    DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedRole = v ?? 'Member'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _addMember,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMember() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter member name')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseService.db
          .collection('teams')
          .doc(widget.teamId)
          .collection('members')
          .add({
        'name': name,
        'role': _selectedRole,
        'addedAt': FieldValue.serverTimestamp(),
      });
      await FirebaseService.db
          .collection('teams')
          .doc(widget.teamId)
          .update({'memberCount': FieldValue.increment(1)});
      if (mounted) Navigator.pop(context);
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
