import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/teams_screen.dart';
import '../screens/meetings_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/events_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/learning_screen.dart';
import '../screens/community_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/volunteer_screen.dart';
import 'attendance_args.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String teams = '/teams';
  static const String meetings = '/meetings';
  static const String attendance = '/attendance';
  static const String events = '/events';
  static const String profile = '/profile';
  static const String learning = '/learning';
  static const String community = '/community';
  static const String quiz = '/quiz';
  static const String volunteer = '/volunteer';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        dashboard: (_) => const DashboardScreen(),
        teams: (_) => const TeamsScreen(),
        meetings: (_) => const MeetingsScreen(),
        attendance: (_) => const AttendanceScreen(),
        events: (_) => const EventsScreen(),
        profile: (_) => const ProfileScreen(),
        learning: (_) => const LearningScreen(),
        community: (_) => const CommunityScreen(),
        quiz: (_) => const QuizScreen(),
        volunteer: (_) => const VolunteerScreen(),
      };

  static const List<String> bottomNavRoutes = [
    dashboard,
    meetings,
    events,
    profile,
  ];

  static int bottomNavIndex(String routeName) =>
      bottomNavRoutes.indexOf(routeName);

  static Future<T?> push<T>(BuildContext context, String routeName,
          {Object? arguments}) =>
      Navigator.pushNamed<T>(context, routeName, arguments: arguments);

  static Future<T?> pushAndClearStack<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.pushNamedAndRemoveUntil<T>(
        context,
        routeName,
        (_) => false,
        arguments: arguments,
      );

  static Future<T?> switchTab<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) =>
      Navigator.pushNamedAndRemoveUntil<T>(
        context,
        routeName,
        (route) => route.isFirst,
        arguments: arguments,
      );

  static void pop<T>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  static void popUntil(BuildContext context, String targetRoute) =>
      Navigator.popUntil(context, ModalRoute.withName(targetRoute));
}

class TeamsArgs {
  final String? highlightTeamId;
  const TeamsArgs({this.highlightTeamId});
}

class MeetingsArgs {
  final int initialTabIndex;
  const MeetingsArgs({this.initialTabIndex = 0});
}
