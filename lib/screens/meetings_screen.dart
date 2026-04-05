import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/app_routes.dart';
import '../core/firebase_service.dart';
import '../core/role_service.dart';
import '../core/widgets.dart';
import 'main_scaffold.dart';
import '../core/attendance_args.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userRole = AppRoles.member;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RoleService.getCurrentUserRole();
    if (mounted) setState(() => _userRole = role);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = RoleService.canCreateMeetings(_userRole);

    return MainScaffold(
      currentIndex: 1,
      // FAB only shown to Chapter Lead and Team Lead
      fab: canCreate
          ? FloatingActionButton(
              backgroundColor: AppColors.gdgBlue,
              onPressed: () => _showCreateMeetingSheet(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text('Meetings',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      // Role badge
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
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.gdgBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.gdgBlue,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MeetingsList(upcoming: true, userRole: _userRole),
                _MeetingsList(upcoming: false, userRole: _userRole),
              ],
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

  void _showCreateMeetingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateMeetingSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Meetings List (Upcoming & Past)
// ─────────────────────────────────────────────

class _MeetingsList extends StatelessWidget {
  final bool upcoming;
  final String userRole;
  const _MeetingsList({required this.upcoming, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db
          .collection('meetings')
          .orderBy('date', descending: !upcoming)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(context);
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] as Timestamp?;
          if (date == null) return false;
          return upcoming
              ? date.compareTo(now) >= 0
              : date.compareTo(now) < 0;
        }).toList();

        if (docs.isEmpty) return _emptyState(context);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: upcoming
                  ? _UpcomingMeetingCard(
                      meetingId: doc.id, data: data, userRole: userRole)
                  : _PastMeetingCard(
                      meetingId: doc.id, data: data, userRole: userRole),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            upcoming
                ? Icons.calendar_today_outlined
                : Icons.history_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            upcoming ? 'No upcoming meetings' : 'No past meetings',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            upcoming
                ? (RoleService.canCreateMeetings(userRole)
                    ? 'Tap + to schedule a meeting'
                    : 'Meetings will appear here once scheduled')
                : 'Past meetings will appear here',
            style:
                const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Upcoming Meeting Card
// ─────────────────────────────────────────────

class _UpcomingMeetingCard extends StatelessWidget {
  final String meetingId;
  final Map<String, dynamic> data;
  final String userRole;

  const _UpcomingMeetingCard({
    required this.meetingId,
    required this.data,
    required this.userRole,
  });

  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'TBD';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = dt.difference(now).inDays;
    final time =
        '${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    if (diff == 0) return 'Today · $time';
    if (diff == 1) return 'Tomorrow · $time';
    return '${_monthName(dt.month)} ${dt.day} · $time';
  }

  String _badgeLabel(Timestamp? ts) {
    if (ts == null) return 'TBD';
    final diff = ts.toDate().difference(DateTime.now()).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'in 1d';
    return 'in ${diff}d';
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled Meeting';
    final location = data['location'] ?? 'TBD';
    final date = data['date'] as Timestamp?;
    final teamName = data['teamName'] ?? 'General';
    final isOnline = location.toLowerCase().contains('meet') ||
        location.toLowerCase().contains('zoom') ||
        location.toLowerCase().contains('http');

    final diff = date != null
        ? date.toDate().difference(DateTime.now()).inDays
        : 999;
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

    final canAttendance = RoleService.canMarkAttendance(userRole);
    final canDelete = RoleService.canDeleteMeetings(userRole);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      GdgChip(teamName, variant: ChipVariant.blue),
                    ],
                  ),
                ),
                GdgBadge(_badgeLabel(date),
                    backgroundColor: badgeBg, textColor: badgeFg),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(_formatDate(date),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(
                  isOnline
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(location,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 12),
            Row(
              children: [
                // Attendance button — Chapter Lead & Team Lead only
                if (canAttendance) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.attendance,
                          arguments: AttendanceArgs(
                            meetingId: meetingId,
                            meetingTitle: title,
                            meetingSubtitle: _formatDate(date),
                          )),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gdgGreen,
                        side: const BorderSide(color: AppColors.gdgGreen),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Attendance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Join Meeting'),
                  ),
                ),
                // Delete button — Chapter Lead & Team Lead only
                if (canDelete) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.gdgRed, size: 20),
                    onPressed: () =>
                        _deleteMeeting(context, meetingId, title),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMeeting(
      BuildContext context, String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: Text('Delete "$title"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.gdgRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseService.db.collection('meetings').doc(id).delete();
    }
  }
}

// ─────────────────────────────────────────────
// Past Meeting Card
// ─────────────────────────────────────────────

class _PastMeetingCard extends StatelessWidget {
  final String meetingId;
  final Map<String, dynamic> data;
  final String userRole;

  const _PastMeetingCard({
    required this.meetingId,
    required this.data,
    required this.userRole,
  });

  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'TBD';
    final dt = ts.toDate();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final time =
        '${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    return '${months[dt.month]} ${dt.day} · $time';
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled Meeting';
    final date = data['date'] as Timestamp?;
    final canAttendance = RoleService.canMarkAttendance(userRole);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.attendanceStream(meetingId),
      builder: (context, snapshot) {
        final attendanceCount = snapshot.data?.docs
                .where((d) =>
                    (d.data() as Map<String, dynamic>)['status'] ==
                    'present')
                .length ??
            0;
        final totalCount = snapshot.data?.docs.length ?? 0;
        final rate =
            totalCount > 0 ? (attendanceCount / totalCount * 100).round() : 0;
        final chipVariant = rate >= 80
            ? ChipVariant.green
            : rate >= 50
                ? ChipVariant.yellow
                : ChipVariant.red;

        return Opacity(
          opacity: 0.8,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(_formatDate(date),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      totalCount > 0
                          ? GdgChip('$attendanceCount/$totalCount attended',
                              variant: chipVariant)
                          : const GdgChip('No attendance data'),
                      // View Report — Chapter Lead & Team Lead only
                      if (canAttendance)
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.attendance,
                              arguments: AttendanceArgs(
                                meetingId: meetingId,
                                meetingTitle: title,
                                meetingSubtitle: _formatDate(date),
                              )),
                          child: const Text('View Report',
                              style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Create Meeting Sheet  (Chapter Lead + Team Lead only — guarded by FAB)
// ─────────────────────────────────────────────

class _CreateMeetingSheet extends StatefulWidget {
  const _CreateMeetingSheet();

  @override
  State<_CreateMeetingSheet> createState() => _CreateMeetingSheetState();
}

class _CreateMeetingSheetState extends State<_CreateMeetingSheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _teamController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _teamController.dispose();
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
      child: SingleChildScrollView(
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
            const Text('Schedule Meeting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration:
                  const InputDecoration(hintText: 'Meeting title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teamController,
              decoration: const InputDecoration(hintText: 'Team name'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: _pickerBox(
                    icon: Icons.calendar_today,
                    label: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    filled: _selectedDate != null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                  child: _pickerBox(
                    icon: Icons.access_time,
                    label: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    filled: _selectedTime != null,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Location or meeting link',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createMeeting,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create Meeting'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerBox(
      {required IconData icon, required String label, required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color:
                      filled ? AppColors.textPrimary : AppColors.textTertiary)),
        ],
      ),
    );
  }

  Future<void> _createMeeting() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final team = _teamController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meeting title')),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseService.createMeeting(
        title: title,
        teamId: team,
        date: dateTime,
        location: location.isEmpty ? 'TBD' : location,
      );

      // Also save teamName for display
      await FirebaseService.db
          .collection('meetings')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get()
          .then((snap) {
        if (snap.docs.isNotEmpty) {
          snap.docs.first.reference.update({'teamName': team});
        }
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
