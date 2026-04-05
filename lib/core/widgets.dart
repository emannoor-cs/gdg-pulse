import 'package:flutter/material.dart';
import 'app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  GDG PULSE  —  Shared Widget Library
//
//  Contents (in order):
//    1.  GdgChip            — coloured pill label (blue / red / green / yellow / plain)
//    2.  GdgBadge           — compact coloured label (used for "in 1d", "Chapter Lead")
//    3.  GdgAvatar          — circular initials avatar
//    4.  GdgAvatarStack     — overlapping avatar row with overflow indicator
//    5.  GdgProgressBar     — thin coloured linear progress bar
//    6.  GdgAnimatedProgressBar — same bar but animates from 0 on mount
//    7.  PulsingDot         — animated pulsing circle (branding / hub icons)
//    8.  GdgGradientDot     — gradient circle (decoration only)
//    9.  SectionTitle       — row of title + optional right-aligned action link
//   10.  GdgDivider         — standardised thin divider
//   11.  GdgCard            — wrapper with consistent padding + shadow
//   12.  GdgScreenHeader    — flat white header with optional back button + title
//   13.  GdgGradientHeader  — blue gradient header used on Dashboard / Events
//   14.  GdgStatRow         — horizontal stats strip (e.g. "3 Teams | 12 Members")
//   15.  GdgInfoRow         — icon + label row (date, location lines on cards)
//   16.  GdgEmptyState      — centred illustration + message when a list is empty
//   17.  GdgLoadingSpinner  — centred GDG-blue circular progress indicator
//   18.  GdgSnackbar        — helper to show styled snack bars
//   19.  GdgColorDot        — tiny static circle (legend, status indicators)
//   20.  GdgTabBarWrapper   — TabBar with a consistent bottom divider
// ═══════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────
// 1. GdgChip
// ─────────────────────────────────────────────────────────

/// Coloured pill label that mirrors the `.chip` class in the prototype.
///
/// ```dart
/// GdgChip('+ Create Team', variant: ChipVariant.blue, onTap: () { ... })
/// ```
enum ChipVariant { plain, blue, red, green, yellow }

class GdgChip extends StatelessWidget {
  final String label;
  final ChipVariant variant;
  final VoidCallback? onTap;
  final double fontSize;
  final EdgeInsets padding;

  const GdgChip(
    this.label, {
    super.key,
    this.variant = ChipVariant.plain,
    this.onTap,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      ChipVariant.blue   => (AppColors.gdgBlueLight, AppColors.gdgBlue),
      ChipVariant.red    => (AppColors.gdgRedLight, AppColors.gdgRed),
      ChipVariant.green  => (AppColors.gdgGreenLight, AppColors.gdgGreen),
      ChipVariant.yellow => (AppColors.gdgYellowLight, const Color(0xFF8A6500)),
      ChipVariant.plain  => (AppColors.surface, AppColors.textSecondary),
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: variant == ChipVariant.plain
              ? Border.all(color: AppColors.border)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.w500, color: fg),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 2. GdgBadge
// ─────────────────────────────────────────────────────────

/// Compact pill used for status labels ("in 1d", "Chapter Lead", "5/5 attended").
///
/// ```dart
/// GdgBadge('in 1d', backgroundColor: AppColors.gdgBlueLight, textColor: AppColors.gdgBlue)
/// ```
class GdgBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const GdgBadge(
    this.label, {
    super.key,
    this.backgroundColor = AppColors.gdgBlueLight,
    this.textColor = AppColors.gdgBlue,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 3. GdgAvatar
// ─────────────────────────────────────────────────────────

/// Circular initials avatar.
///
/// ```dart
/// GdgAvatar(initials: 'AJ', color: AppColors.gdgBlue, size: 42)
/// ```
class GdgAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final double? fontSize;
  final Color textColor;

  const GdgAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 40,
    this.fontSize,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-scale font size at 38 % of avatar size if not specified
    final effectiveFontSize = fontSize ?? size * 0.38;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 4. GdgAvatarStack
// ─────────────────────────────────────────────────────────

/// Horizontally overlapping row of [GdgAvatar]s with an overflow "+N" badge.
///
/// ```dart
/// GdgAvatarStack(
///   avatars: [('AJ', AppColors.gdgBlue), ('SK', AppColors.gdgRed)],
///   maxVisible: 4,
///   size: 30,
/// )
/// ```
class GdgAvatarStack extends StatelessWidget {
  final List<(String initials, Color color)> avatars;
  final int maxVisible;
  final double size;
  final double overlapOffset;

  const GdgAvatarStack({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.size = 30,
    this.overlapOffset = 8,
  });

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final overflow = avatars.length - maxVisible;

    return SizedBox(
      height: size,
      width: visible.length * (size - overlapOffset) +
          overlapOffset +
          (overflow > 0 ? (size - overlapOffset) + overlapOffset : 0),
      child: Stack(
        children: [
          ...visible.asMap().entries.map((e) {
            return Positioned(
              left: e.key * (size - overlapOffset),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: GdgAvatar(
                    initials: e.value.$1, color: e.value.$2, size: size),
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: visible.length * (size - overlapOffset),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface3,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 5. GdgProgressBar
// ─────────────────────────────────────────────────────────

/// Thin coloured progress bar with rounded ends.
///
/// ```dart
/// GdgProgressBar(value: 0.6, color: AppColors.gdgBlue)
/// ```
class GdgProgressBar extends StatelessWidget {
  /// Progress value from `0.0` (empty) to `1.0` (full).
  final double value;
  final Color color;
  final double height;

  const GdgProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: AppColors.surface3,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 6. GdgAnimatedProgressBar
// ─────────────────────────────────────────────────────────

/// Same as [GdgProgressBar] but animates from 0 → [value] when first rendered.
/// Great for profile stats and learning track cards.
class GdgAnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color color;
  final double height;
  final Duration duration;

  const GdgAnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<GdgAnimatedProgressBar> createState() =>
      _GdgAnimatedProgressBarState();
}

class _GdgAnimatedProgressBarState extends State<GdgAnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // Start animating after the first frame paints
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void didUpdateWidget(GdgAnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => GdgProgressBar(
        value: _animation.value,
        color: widget.color,
        height: widget.height,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 7. PulsingDot
// ─────────────────────────────────────────────────────────

/// Gently pulsing circle — used in the GDG logo, Dashboard hub, and login logo.
///
/// ```dart
/// PulsingDot(color: AppColors.gdgBlue, size: 28, delay: Duration(milliseconds: 500))
/// ```
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  /// Delays the start of animation so staggered groups look like a heartbeat.
  final Duration delay;

  const PulsingDot({
    super.key,
    required this.color,
    this.size = 18,
    this.delay = Duration.zero,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.delay != Duration.zero) {
      _controller.stop();
      Future.delayed(widget.delay, () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 8. GdgGradientDot
// ─────────────────────────────────────────────────────────

/// Static gradient circle — decoration only, no animation.
class GdgGradientDot extends StatelessWidget {
  final Gradient gradient;
  final double size;

  const GdgGradientDot({
    super.key,
    required this.gradient,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 9. SectionTitle
// ─────────────────────────────────────────────────────────

/// Row with a bold title on the left and an optional tappable "See all" action
/// on the right — used consistently above every list section.
///
/// ```dart
/// SectionTitle(
///   'Upcoming Meetings',
///   actionLabel: 'See all',
///   onAction: () => Navigator.pushNamed(context, AppRoutes.meetings),
/// )
/// ```
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const SectionTitle(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gdgBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 10. GdgDivider
// ─────────────────────────────────────────────────────────

/// Standardised 0.5 px divider that respects the [AppColors.border] token.
class GdgDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const GdgDivider({super.key, this.indent = 0, this.endIndent = 0});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.border,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

// ─────────────────────────────────────────────────────────
// 11. GdgCard
// ─────────────────────────────────────────────────────────

/// White card with the standard GDG shadow and 16-radius corners.
/// Prefer this over raw [Card] so shadow/border styles stay consistent.
///
/// ```dart
/// GdgCard(
///   onTap: () {},
///   child: Padding(padding: EdgeInsets.all(14), child: ...),
/// )
/// ```
class GdgCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? customBorder;

  const GdgCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16,
    this.backgroundColor,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: customBorder ??
            Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: child),
              )
            : child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 12. GdgScreenHeader
// ─────────────────────────────────────────────────────────

/// Standard flat white header with a back button, title, and optional subtitle.
/// Used on Attendance, Learning, Teams, Community, etc.
///
/// ```dart
/// GdgScreenHeader(
///   title: 'Attendance',
///   subtitle: 'Tomorrow · 3:00 PM · 5 members',
///   onBack: () => Navigator.pop(context),
///   trailing: ElevatedButton(onPressed: _markAll, child: Text('Mark All')),
/// )
/// ```
class GdgScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? superscript;
  final VoidCallback? onBack;
  final Widget? trailing;
  final List<Widget>? bottomWidgets;

  const GdgScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.superscript,
    this.onBack,
    this.trailing,
    this.bottomWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textPrimary,
                    onPressed: onBack,
                  )
                else
                  const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (superscript != null)
                        Text(superscript!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary)),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (bottomWidgets != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bottomWidgets!),
            ),
          const GdgDivider(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 13. GdgGradientHeader
// ─────────────────────────────────────────────────────────

/// Full-bleed blue gradient header used on Dashboard and Events screens.
///
/// ```dart
/// GdgGradientHeader(
///   child: Column(children: [ Text('Events', ...), ... ]),
/// )
/// ```
class GdgGradientHeader extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;

  const GdgGradientHeader({
    super.key,
    required this.child,
    this.gradient = AppColors.gradientBlueDark,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      padding: padding,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────
// 14. GdgStatRow
// ─────────────────────────────────────────────────────────

/// Horizontal row of numeric stats separated by translucent dividers.
/// Used in the Dashboard header and Profile card.
///
/// ```dart
/// GdgStatRow(
///   stats: [('3', 'Teams'), ('12', 'Members'), ('5', 'Events')],
///   foregroundColor: Colors.white,
///   dividerColor: Colors.white30,
/// )
/// ```
class GdgStatRow extends StatelessWidget {
  final List<(String value, String label)> stats;
  final Color foregroundColor;
  final Color dividerColor;

  const GdgStatRow({
    super.key,
    required this.stats,
    this.foregroundColor = Colors.white,
    this.dividerColor = Colors.white30,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (int i = 0; i < stats.length; i++) {
      if (i > 0) {
        widgets.add(Container(
            width: 1, height: 36, color: dividerColor));
      }
      widgets.add(Expanded(child: _statItem(stats[i])));
    }

    return IntrinsicHeight(
      child: Row(children: widgets),
    );
  }

  Widget _statItem((String, String) stat) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          stat.$1,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: foregroundColor),
        ),
        Text(
          stat.$2,
          style: TextStyle(
              fontSize: 10,
              color: foregroundColor.withOpacity(0.75)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 15. GdgInfoRow
// ─────────────────────────────────────────────────────────

/// Small icon + text row used for date/location lines inside cards.
///
/// ```dart
/// GdgInfoRow(icon: Icons.calendar_today_outlined, label: 'Tomorrow · 3:00 PM')
/// ```
class GdgInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;
  final double fontSize;

  const GdgInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
    this.iconSize = 13,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 16. GdgEmptyState
// ─────────────────────────────────────────────────────────

/// Centred placeholder shown when a list has no items.
///
/// ```dart
/// GdgEmptyState(
///   emoji: '📭',
///   title: 'No meetings yet',
///   subtitle: 'Tap + to schedule your first meeting',
/// )
/// ```
class GdgEmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Widget? action;

  const GdgEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 17. GdgLoadingSpinner
// ─────────────────────────────────────────────────────────

/// Centred GDG-blue circular progress indicator.
class GdgLoadingSpinner extends StatelessWidget {
  final double size;

  const GdgLoadingSpinner({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.gdgBlue,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 18. GdgSnackbar
// ─────────────────────────────────────────────────────────

/// Helper class for showing consistently-styled snack bars.
///
/// ```dart
/// GdgSnackbar.show(context, message: 'Attendance saved!', type: SnackType.success);
/// ```
enum SnackType { success, error, info, warning }

abstract final class GdgSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final (Color bg, IconData icon) = switch (type) {
      SnackType.success => (AppColors.gdgGreen, Icons.check_circle_outline),
      SnackType.error   => (AppColors.gdgRed,   Icons.error_outline),
      SnackType.warning => (AppColors.gdgYellow, Icons.warning_amber_outlined),
      SnackType.info    => (AppColors.gdgBlue,   Icons.info_outline),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 19. GdgColorDot
// ─────────────────────────────────────────────────────────

/// Tiny static circle — used in the attendance legend and status indicators.
///
/// ```dart
/// GdgColorDot(color: AppColors.gdgGreen, size: 10)
/// ```
class GdgColorDot extends StatelessWidget {
  final Color color;
  final double size;
  final BorderRadius? borderRadius;

  const GdgColorDot({
    super.key,
    required this.color,
    this.size = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: borderRadius != null ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: borderRadius,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 20. GdgTabBarWrapper
// ─────────────────────────────────────────────────────────

/// Wraps a [TabBar] and adds the correct bottom border consistent with the
/// prototype's `.tag-nav` style.
///
/// ```dart
/// GdgTabBarWrapper(
///   controller: _tabController,
///   tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')],
/// )
/// ```
class GdgTabBarWrapper extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;

  const GdgTabBarWrapper({
    super.key,
    required this.controller,
    required this.tabs,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        labelColor: labelColor ?? AppColors.gdgBlue,
        unselectedLabelColor:
            unselectedLabelColor ?? AppColors.textSecondary,
        indicatorColor: indicatorColor ?? AppColors.gdgBlue,
        dividerColor: Colors.transparent,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

