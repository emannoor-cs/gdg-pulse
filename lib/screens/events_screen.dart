import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../core/firebase_service.dart';
import '../core/role_service.dart';
import '../core/widgets.dart';
import 'main_scaffold.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
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
    final canCreate = RoleService.canCreateEvents(_userRole);

    return MainScaffold(
      currentIndex: 2,
      // FAB only shown to Chapter Lead
      fab: canCreate
          ? FloatingActionButton(
              backgroundColor: AppColors.gdgBlue,
              onPressed: () => _showCreateEventSheet(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _UpcomingEvents(userRole: _userRole),
                _PastEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.gdgBlue,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.eventsStream(),
                  builder: (context, snap) {
                    final count = snap.data?.docs.length ?? 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Events',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
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
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$count events',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.db
                      .collection('events')
                      .orderBy('date')
                      .where('date', isGreaterThanOrEqualTo: Timestamp.now())
                      .limit(1)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData || snap.data!.docs.isEmpty) {
                      return _placeholderBanner();
                    }
                    final data =
                        snap.data!.docs.first.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Upcoming Event';
                    final date = data['date'] as Timestamp?;
                    final location = data['location'] ?? '';
                    final type = data['type'] ?? 'General';
                    final dateStr =
                        date != null ? _formatDate(date.toDate()) : 'TBD';

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 160,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.gdgBlue, AppColors.gdgRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _YellowBadge(type),
                                  const SizedBox(height: 6),
                                  Text(title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(
                                      '$dateStr${location.isNotEmpty ? ' · $location' : ''}',
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            dividerColor: Colors.white30,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
        ],
      ),
    );
  }

  Color _roleBadgeColor(String role) {
    switch (role) {
      case AppRoles.chapterLead:
        return AppColors.gdgGreen.withOpacity(0.8);
      case AppRoles.teamLead:
        return AppColors.gdgYellowDark.withOpacity(0.8);
      default:
        return Colors.white24;
    }
  }

  Widget _placeholderBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gdgBlue, AppColors.gdgRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No upcoming events yet',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            if (RoleService.canCreateEvents(_userRole))
              const Text('Tap + to create one',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month]} ${dt.day} · $h:$m $ampm';
  }

  void _showCreateEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateEventSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Upcoming Events Tab
// ─────────────────────────────────────────────

class _UpcomingEvents extends StatelessWidget {
  final String userRole;
  const _UpcomingEvents({required this.userRole});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db.collection('events').orderBy('date').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = Timestamp.now();
        final docs = (snap.data?.docs ?? []).where((d) {
          final date =
              (d.data() as Map<String, dynamic>)['date'] as Timestamp?;
          return date != null && date.compareTo(now) >= 0;
        }).toList();

        if (docs.isEmpty) {
          return GdgEmptyState(
            emoji: '📅',
            title: 'No upcoming events',
            subtitle: RoleService.canCreateEvents(userRole)
                ? 'Tap + to create your first event'
                : 'Events will appear here once scheduled',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _EventCard(
                eventId: doc.id, data: data, userRole: userRole);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Past Events Tab
// ─────────────────────────────────────────────

class _PastEventsTab extends StatelessWidget {
  final List<List<Color>> _gradients = const [
    [AppColors.gdgBlue, AppColors.gdgGreen],
    [AppColors.gdgRed, AppColors.gdgYellow],
    [AppColors.gdgGreen, AppColors.gdgBlue],
    [AppColors.gdgYellow, AppColors.gdgRed],
    [AppColors.gdgBlue, AppColors.gdgRed],
    [AppColors.gdgGreen, AppColors.gdgYellow],
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.db
          .collection('events')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = Timestamp.now();
        final docs = (snap.data?.docs ?? []).where((d) {
          final date =
              (d.data() as Map<String, dynamic>)['date'] as Timestamp?;
          return date != null && date.compareTo(now) < 0;
        }).toList();

        if (docs.isEmpty) {
          return const GdgEmptyState(
            emoji: '🗂',
            title: 'No past events yet',
            subtitle: 'Past events will appear here',
          );
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final title = data['title'] ?? '';
                  final gradientIndex = i % _gradients.length;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradients[gradientIndex],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Past event gallery',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Event Card
// ─────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> data;
  final String userRole;

  const _EventCard({
    required this.eventId,
    required this.data,
    required this.userRole,
  });

  static const _gradientSets = [
    [AppColors.gdgBlue, AppColors.gdgGreen],
    [AppColors.gdgRed, AppColors.gdgYellow],
    [AppColors.gdgGreen, AppColors.gdgBlue],
  ];

  String _countdown(Timestamp? ts) {
    if (ts == null) return 'TBD';
    final diff = ts.toDate().difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'Today';
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'TBD';
    final dt = ts.toDate();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month]} ${dt.day} · $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled Event';
    final date = data['date'] as Timestamp?;
    final location = data['location'] ?? 'TBD';
    final type = data['type'] ?? 'General';
    final registrations = List<String>.from(data['registrations'] ?? []);
    final gradients = _gradientSets[title.length % _gradientSets.length];
    final uid = FirebaseService.currentUser?.uid ?? '';
    final isRegistered = registrations.contains(uid);
    final canDelete = RoleService.canDeleteEvents(userRole);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradients,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _YellowBadge(type),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(_formatDate(date),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(location,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gdgBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(_countdown(date),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gdgBlue)),
                            const Text('remaining',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isRegistered
                            ? null
                            : () async {
                                if (uid.isEmpty) return;
                                await FirebaseService.registerForEvent(
                                    eventId, uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Registered successfully!'),
                                    backgroundColor: AppColors.gdgGreen,
                                  ));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                          backgroundColor:
                              isRegistered ? AppColors.gdgGreen : null,
                        ),
                        child: Text(
                            isRegistered ? '✓ Registered' : 'Register Now'),
                      ),
                    ),
                    // Delete button — Chapter Lead only
                    if (canDelete) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.gdgRed, size: 20),
                        onPressed: () =>
                            _deleteEvent(context, eventId, title),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(
      BuildContext context, String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
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
      await FirebaseService.db.collection('events').doc(id).delete();
    }
  }
}

// ─────────────────────────────────────────────
// Create Event Sheet  (Chapter Lead only — guarded by FAB visibility)
// ─────────────────────────────────────────────

class _CreateEventSheet extends StatefulWidget {
  const _CreateEventSheet();

  @override
  State<_CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<_CreateEventSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedType = 'Workshop';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final _types = [
    'Workshop', 'Study Jam', 'Summit', 'Bootcamp',
    'Hackathon', 'Meetup', 'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
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
            const Text('Create Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
                controller: _titleController,
                decoration:
                    const InputDecoration(hintText: 'Event title')),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(hintText: 'Event type'),
              items: _types
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedType = v ?? 'Workshop'),
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
                        context: context,
                        initialTime: TimeOfDay.now());
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
                hintText: 'Location or link',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createEvent,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create Event'),
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
                  color: filled
                      ? AppColors.textPrimary
                      : AppColors.textTertiary)),
        ],
      ),
    );
  }

  Future<void> _createEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter event title')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dt = DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      await FirebaseService.createEvent(
        title: title,
        description: _descController.text.trim(),
        date: dt,
        location: _locationController.text.trim().isEmpty
            ? 'TBD'
            : _locationController.text.trim(),
        type: _selectedType,
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
// Shared badge widget
// ─────────────────────────────────────────────

class _YellowBadge extends StatelessWidget {
  final String label;
  const _YellowBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gdgYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Color(0xFF5F4700),
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}
