import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/firebase_service.dart';
import '../core/role_service.dart';
import '../core/widgets.dart';
import '../core/attendance_args.dart'; // single source of truth

// ─────────────────────────────────────────────
// Status enum
// ─────────────────────────────────────────────

enum AttendanceStatus { unset, present, late, absent, excused }

extension AttendanceStatusExt on AttendanceStatus {
  Color get color {
    switch (this) {
      case AttendanceStatus.unset:
        return const Color(0xFF9E9E9E);
      case AttendanceStatus.present:
        return AppColors.gdgGreen;
      case AttendanceStatus.late:
        return AppColors.gdgYellow;
      case AttendanceStatus.absent:
        return AppColors.gdgRed;
      case AttendanceStatus.excused:
        return AppColors.gdgPurple;
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.unset:
        return '—';
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  String get firestoreValue => name;

  static AttendanceStatus fromString(String? val) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name == val,
      orElse: () => AttendanceStatus.unset,
    );
  }

  AttendanceStatus get next {
    final values = AttendanceStatus.values;
    return values[(index + 1) % values.length];
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<String, AttendanceStatus> _localStatus = {};
  bool _isSaving = false;
  String _userRole = AppRoles.member;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RoleService.getCurrentUserRole();
    if (mounted) setState(() => _userRole = role);
  }

  AttendanceStatus _statusForMember(
      String memberId, Map<String, dynamic>? firestoreData) {
    if (_localStatus.containsKey(memberId)) return _localStatus[memberId]!;
    return AttendanceStatusExt.fromString(
        firestoreData?['status'] as String?);
  }

  Future<void> _cycleStatus(
      String meetingId, String memberId, AttendanceStatus current) async {
    final next = current.next;
    setState(() => _localStatus[memberId] = next);
    await FirebaseService.markAttendance(
      meetingId: meetingId,
      userId: memberId,
      status: next.firestoreValue,
    );
  }

  Future<void> _markAllPresent(
      String meetingId, List<QueryDocumentSnapshot> members) async {
    setState(() {
      for (final m in members) {
        _localStatus[m.id] = AttendanceStatus.present;
      }
      _isSaving = true;
    });

    final batch = FirebaseService.db.batch();
    for (final m in members) {
      final ref = FirebaseService.db
          .collection('meetings')
          .doc(meetingId)
          .collection('attendance')
          .doc(m.id);
      batch.set(ref, {
        'userId': m.id,
        'status': AttendanceStatus.present.firestoreValue,
        'markedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _saveAll(
      String meetingId, List<QueryDocumentSnapshot> members) async {
    setState(() => _isSaving = true);

    final batch = FirebaseService.db.batch();
    for (final m in members) {
      final status = _localStatus[m.id] ?? AttendanceStatus.unset;
      final ref = FirebaseService.db
          .collection('meetings')
          .doc(meetingId)
          .collection('attendance')
          .doc(m.id);
      batch.set(ref, {
        'userId': m.id,
        'status': status.firestoreValue,
        'markedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved!'),
          backgroundColor: AppColors.gdgGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as AttendanceArgs?;

    final meetingId = args?.meetingId ?? '';
    final meetingTitle = args?.meetingTitle ?? 'Meeting';
    final meetingSubtitle = args?.meetingSubtitle ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.db
              .collection('meetings')
              .doc(meetingId)
              .snapshots(),
          builder: (context, meetingSnap) {
            final meetingData =
                meetingSnap.data?.data() as Map<String, dynamic>?;
            final teamId =
                (meetingData?['teamId'] as String?) ?? '';

            return StreamBuilder<QuerySnapshot>(
              stream: teamId.isNotEmpty
                  ? FirebaseService.db
                      .collection('teams')
                      .doc(teamId)
                      .collection('members')
                      .snapshots()
                  : const Stream.empty(),
              builder: (context, membersSnap) {
                final members = membersSnap.data?.docs ?? [];

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.attendanceStream(meetingId),
                  builder: (context, attendanceSnap) {
                    final attendanceMap =
                        <String, Map<String, dynamic>>{};
                    for (final doc in attendanceSnap.data?.docs ?? []) {
                      attendanceMap[doc.id] =
                          doc.data() as Map<String, dynamic>;
                    }

                    int presentCount = 0;
                    for (final m in members) {
                      if (_statusForMember(m.id, attendanceMap[m.id]) ==
                          AttendanceStatus.present) {
                        presentCount++;
                      }
                    }

                    final canEdit =
                        RoleService.canMarkAttendance(_userRole);

                    return Column(
                      children: [
                        _buildHeader(
                          context,
                          meetingTitle: meetingTitle,
                          meetingSubtitle: meetingSubtitle,
                          presentCount: presentCount,
                          totalCount: members.length,
                          canEdit: canEdit,
                          onMarkAll: (canEdit && members.isNotEmpty)
                              ? () => _markAllPresent(meetingId, members)
                              : null,
                          onSaveAll: (canEdit && members.isNotEmpty)
                              ? () => _saveAll(meetingId, members)
                              : null,
                        ),
                        Expanded(
                          child: membersSnap.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : members.isEmpty
                                  ? _buildEmptyState(teamId)
                                  : ListView(
                                      padding: const EdgeInsets.all(16),
                                      children: [
                                        ...members.map((m) {
                                          final mData = m.data()
                                              as Map<String, dynamic>;
                                          final name =
                                              (mData['name'] as String?) ??
                                                  'Unknown';
                                          final initials = name
                                              .trim()
                                              .split(' ')
                                              .where((String w) =>
                                                  w.isNotEmpty)
                                              .take(2)
                                              .map((String w) =>
                                                  w[0].toUpperCase())
                                              .join();
                                          final idx = members.indexOf(m);
                                          final status = _statusForMember(
                                              m.id, attendanceMap[m.id]);

                                          return _buildAttendanceTile(
                                            memberId: m.id,
                                            name: name,
                                            initials: initials.isEmpty
                                                ? '?'
                                                : initials,
                                            color:
                                                AppColors.avatarColor(idx),
                                            status: status,
                                            // Only tappable for Chapter Lead / Team Lead
                                            onTap: canEdit
                                                ? () => _cycleStatus(
                                                    meetingId, m.id, status)
                                                : null,
                                          );
                                        }),
                                        const SizedBox(height: 12),
                                        _buildLegend(),
                                        const SizedBox(height: 80),
                                      ],
                                    ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _isSaving
          ? FloatingActionButton(
              backgroundColor: AppColors.gdgBlue,
              onPressed: null,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required String meetingTitle,
    required String meetingSubtitle,
    required int presentCount,
    required int totalCount,
    required bool canEdit,
    VoidCallback? onMarkAll,
    VoidCallback? onSaveAll,
  }) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meetingTitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary)),
                    const Text('Attendance',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Text(meetingSubtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              // Role badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: canEdit ? AppColors.gdgGreen : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  canEdit ? _userRole : 'View Only',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (canEdit) ...[
                ElevatedButton(
                  onPressed: onMarkAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gdgGreen,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Mark All Present'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onSaveAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gdgBlue,
                    side: const BorderSide(color: AppColors.gdgBlue),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Save'),
                ),
              ] else
                // Members see a read-only label instead of action buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 14, color: AppColors.textTertiary),
                      SizedBox(width: 6),
                      Text('Read-only view',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              const Spacer(),
              GdgBadge(
                '$presentCount / $totalCount Present',
                backgroundColor: AppColors.gdgGreenLight,
                textColor: AppColors.gdgGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTile({
    required String memberId,
    required String name,
    required String initials,
    required Color color,
    required AttendanceStatus status,
    required VoidCallback? onTap,
  }) {
    final isPresent = status == AttendanceStatus.present;

    return GestureDetector(
      onTap: onTap, // null = non-interactive for Members
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: status.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(isPresent ? 20 : 8),
          border: Border.all(color: status.color, width: 1.5),
        ),
        child: Row(
          children: [
            GdgAvatar(
                initials: initials, color: color, size: 36, fontSize: 13),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                status.label,
                key: ValueKey(status),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: status.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String teamId) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group_outlined,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          const Text('No members found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            teamId.isEmpty
                ? 'This meeting has no team assigned'
                : 'Add members to the team first',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      (const Color(0xFF9E9E9E), 'Unset'),
      (AppColors.gdgGreen, 'Present'),
      (AppColors.gdgYellow, 'Late'),
      (AppColors.gdgRed, 'Absent'),
      (AppColors.gdgPurple, 'Excused'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LEGEND',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: items.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: item.$1,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 4),
                  Text(item.$2,
                      style: const TextStyle(fontSize: 11)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Text('Tap a member to cycle through statuses',
              style: TextStyle(
                  fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}