<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.27+-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black"/>
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Provider-6.x-7C4DFF?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge"/>

<br/><br/>

```
   ██████╗ ██████╗  ██████╗     ██████╗ ██╗   ██╗██╗     ███████╗███████╗
  ██╔════╝ ██╔══██╗██╔════╝     ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
  ██║  ███╗██║  ██║██║  ███╗    ██████╔╝██║   ██║██║     ███████╗█████╗
  ██║   ██║██║  ██║██║   ██║    ██╔═══╝ ██║   ██║██║     ╚════██║██╔══╝
  ╚██████╔╝██████╔╝╚██████╔╝    ██║     ╚██████╔╝███████╗███████║███████╗
   ╚═════╝ ╚═════╝  ╚═════╝     ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝
```

# ⚡ GDG Pulse

### *Your GDG chapter, alive.*

**A dual-purpose Flutter app for Google Developer Group chapters —**  
internal chapter operations meet a smart, animated community hub.

<br/>

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev)

</div>

---

## 📖 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Role-Based Access Control](#-role-based-access-control)
- [Data Model](#-data-model)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Dependencies](#-dependencies)
- [Firestore Security Rules](#-firestore-security-rules)
- [Contributing](#-contributing)

---

## 🌟 About

**GDG Pulse** is a Flutter-based mobile application built for Google Developer Group chapter organizers and members. It solves two problems at once:

**For organizers** — a clean, role-gated operations tool to manage teams, schedule meetings, and track attendance with real-time Firestore sync.

**For members** — a living community hub with events, a learning zone, tech quizzes, social links, and a badge system that rewards engagement.

Built with **Flutter 3.x**, **Firebase**, and **Provider**, following Clean Architecture principles with strict **Role-Based Access Control (RBAC)** enforced at both the UI layer and the Firestore Security Rules layer.

---

## ✨ Features

### 🔒 Core — Chapter Operations

| Feature | Description |
|--------|-------------|
| **Auth + RBAC** | Email/Password login with 3 distinct roles. `RoleGuard` widget controls UI visibility. Firebase Security Rules enforce backend access. |
| **Team Management** | Chapter Leads create/rename/archive teams, assign Team Leads, and manage member rosters with multi-select. |
| **Meeting Management** | Full CRUD for meetings with calendar picker, countdown timers, and upcoming/past filtering. |
| **Attendance Tracking** | Mark Present / Absent / Late / Excused per member. `AnimatedContainer` tiles transition color on status change. Bulk-mark and duplicate prevention included. |
| **Attendance Insights** | Personal history for members, team summaries for Team Leads, chapter-wide trend charts for Chapter Leads using `fl_chart`. |
| **Role-Sensitive Dashboard** | Upcoming meetings, team overview, activity feed, and context-aware FAB — all filtered by role. |

### 🚀 Smart Hub — Community Features

| Feature | Description |
|--------|-------------|
| **Animated GDG Logo** | Custom Rive widget with 4 tappable Google-color dots — each navigates to a section. Idle pulse animation + time-based theme switching. |
| **Social Connect Hub** | Platform cards (Instagram, LinkedIn, YouTube, WhatsApp, Discord) with animated Join buttons and a live rolling member count. |
| **Smart Event System** | Public events with countdown timers, difficulty tags (Beginner / Intermediate / Advanced), photo galleries for past events, and Add to Calendar integration. |
| **Personalized Profile** | Interests, skill level, events attended, and a GDG Badges system with animated unlock reveals. |
| **Learning Zone** | Four sections (Web Dev, AI/ML, Android, Cloud) with resources, roadmaps, and a personal progress tracker. |
| **Community Vibes** | Member spotlight, Quote of the Day, Tip of the Day, and success stories feed — all editable by the Chapter Lead. |
| **Tech Quiz & Polls** | Multiple-choice quizzes with Lottie celebration on completion. Live poll results with animated bar charts. |
| **QR Code System** | Generate QR codes for event registration; scan to join WhatsApp groups or register for events. |
| **Smart Notifications** | FCM push notifications for event reminders and meeting alerts. In-app notification bell with unread badge. |
| **Feedback System** | Star ratings + comments on past events. Chapter Lead sees aggregated ratings per event. |

---

## 📱 Screenshots

### 🔐 Authentication
| Sign In | Sign Up |
|---------|---------|
| ![Sign In](docs/screenshots/signin.png) | ![Sign Up](docs/screenshots/signup.png) |

### 🏠 Dashboard & Navigation
| Dashboard | Teams |
|-----------|-------|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Teams](docs/screenshots/teams.png) |

### 📅 Meetings
| Meetings List | Schedule Meeting |
|---------------|-----------------|
| ![Meetings](docs/screenshots/meetings.png) | ![Schedule](docs/screenshots/schedulemeeting.png) |

### 🎪 Events
| Events | Create Event |
|--------|-------------|
| ![Events](docs/screenshots/events.png) | ![Create Event](docs/screenshots/createevents.png) |

### 📚 Learning Zone
| Learning Zone | Resources |
|---------------|-----------|
| ![Learning](docs/screenshots/learning_zone.png) | ![Learning 2](docs/screenshots/learning_zone2.png) |

### 👤 Profile & Community
| Profile | Community | New Post |
|---------|-----------|----------|
| ![Profile](docs/screenshots/profile.png) | ![Community](docs/screenshots/community.png) | ![New Post](docs/screenshots/newpost.png) |

### 🤝 Volunteer
| Volunteer | Leaderboard |
|-----------|-------------|
| ![Volunteer](docs/screenshots/voluteer.png) | ![Leaderboard](docs/screenshots/voluteerleaderboard.png) |
| ![Volunteer 1](docs/screenshots/voluteer1.png) | |

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.27+ / Dart 3.6+ |
| **Authentication** | Firebase Authentication (Email/Password) |
| **Database** | Cloud Firestore (real-time streams) |
| **State Management** | Provider 6.x (`ChangeNotifier` + `StreamProvider`) |
| **Animations** | Lottie (JSON), Rive (StateMachine `.riv`), Flutter implicit animations |
| **Navigation** | `animated_drawer` + `NavigationRail` (tablet) + `BottomNavigationBar` (phone) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **QR Codes** | `qr_flutter` (generate) + `mobile_scanner` (scan) |
| **Charts** | `fl_chart` + `percent_indicator` |
| **Calendar** | `table_calendar` + `add_2_calendar` |
| **Design** | Material 3, Google color scheme, Google Fonts |

---

## 🏗 Architecture

GDG Pulse follows a layered Clean Architecture:

```
┌─────────────────────────────────────────────────┐
│                 Presentation Layer               │
│         Screens · Widgets · Animations           │
├─────────────────────────────────────────────────┤
│               Application Layer                  │
│    Providers (ChangeNotifier) · ViewModels       │
├─────────────────────────────────────────────────┤
│                  Domain Layer                    │
│         Models · Repository Interfaces           │
├─────────────────────────────────────────────────┤
│                   Data Layer                     │
│      Firebase Services · Local Cache             │
└─────────────────────────────────────────────────┘
```

**Key patterns used:**
- `AuthProvider` is the single source of truth for role throughout the entire app
- All Firestore calls go through service classes — screens never touch Firebase directly
- `RoleGuard` widget wraps any UI element and shows/hides based on the current user's role
- Firestore Security Rules mirror the same RBAC logic as a server-side safety net

---

## 🔐 Role-Based Access Control

Three roles are stored in `/users/{uid}.role` in Firestore:

```
chapter_lead  →  Full access: manage teams, assign leads, all data, reports, notifications
team_lead     →  Own team only: create meetings, mark attendance
member        →  Read-only: own meetings, own attendance, all community features
```

### Permission Matrix

| Action | Chapter Lead | Team Lead | Member |
|--------|:---:|:---:|:---:|
| Create / manage teams | ✅ | ❌ | ❌ |
| Assign team leads | ✅ | ❌ | ❌ |
| Create meetings (any team) | ✅ | ❌ | ❌ |
| Create meetings (own team) | ✅ | ✅ | ❌ |
| Mark attendance (any team) | ✅ | ❌ | ❌ |
| Mark attendance (own team) | ✅ | ✅ | ❌ |
| View own attendance | ✅ | ✅ | ✅ |
| Chapter-wide reports | ✅ | ❌ | ❌ |
| Send push notifications | ✅ | ❌ | ❌ |
| Community features | ✅ | ✅ | ✅ |
| Edit community content | ✅ | ❌ | ❌ |

### RoleGuard Usage

```dart
// Wrap any widget — it auto-hides if the user's role isn't allowed
RoleGuard(
  allowedRoles: ['chapter_lead'],
  child: ElevatedButton(
    onPressed: createTeam,
    child: const Text('Create Team'),
  ),
)
```

---

## 🗄 Data Model

```
/users/{uid}
  name, email, role, chapterId, teamIds[], interests[],
  skillLevel, eventsAttended, badges[], createdAt

/teams/{teamId}
  chapterId, name, leadId, memberIds[], createdAt

/meetings/{meetingId}
  teamId, topic, scheduledAt, location, notes, createdBy, createdAt

/attendance/{meetingId_memberId}
  meetingId, memberId, status, markedBy, markedAt, updatedAt
  status: 'present' | 'absent' | 'late' | 'excused'

/events/{eventId}
  title, description, date, tags[], difficulty, imageUrl,
  registrationUrl, isPublished, createdBy

/events/{eventId}/feedback/{uid}
  rating, comment, submittedAt

/learning/{category}/resources/{id}
  title, description, url, type ('video'|'article'|'roadmap'), addedBy

/community/spotlight
  memberId, achievement, featuredDate

/community/daily
  quote, tip, date

/polls/{pollId}
  question, options[], votes{option: count}, expiresAt

/notifications/{uid}/items/{id}
  title, body, isRead, createdAt
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.27.0`
- Dart SDK `>=3.6.0`
- A Firebase project with **Authentication** and **Firestore** enabled
- FlutterFire CLI

### 1. Clone the repository

```bash
git clone https://github.com/emannoor-cs/gdg-pulse.git
cd gdg-pulse
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Install the FlutterFire CLI if you haven't already:

```bash
dart pub global activate flutterfire_cli
```

Run Firebase configuration (select Android + iOS):

```bash
flutterfire configure --project=your-firebase-project-id
```

This generates `lib/firebase_options.dart` automatically.

### 4. Enable Firebase services

In the [Firebase Console](https://console.firebase.google.com):

- **Authentication** → Enable Email/Password sign-in
- **Firestore** → Create database (start in test mode, add rules later)
- **Cloud Messaging** → Enable for push notifications

### 5. Add Lottie animation assets

Download `.json` animation files from [lottiefiles.com](https://lottiefiles.com) and place them in:

```
assets/animations/
  login_anim.json
  success_anim.json
  empty_state.json
  loading.json
  celebration.json
```

### 6. Add Rive animation asset

Design or download a `.riv` file from [rive.app](https://rive.app) and place it in:

```
assets/animations/
  gdg_logo.riv
  attendance_btn.riv
```

### 7. Run the app

```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point, MultiProvider setup
├── firebase_options.dart            # Auto-generated by FlutterFire CLI
│
├── constants/
│   ├── app_colors.dart              # GDG color palette
│   ├── app_strings.dart             # All string constants
│   └── app_routes.dart              # Named route definitions
│
├── models/
│   ├── app_user.dart                # User model with role helpers
│   ├── team.dart
│   ├── meeting.dart
│   ├── attendance.dart
│   ├── event.dart
│   ├── badge.dart
│   └── poll.dart
│
├── services/
│   ├── auth_service.dart            # Firebase Auth wrapper
│   ├── firestore_service.dart       # All Firestore reads/writes
│   ├── notification_service.dart    # FCM integration
│   └── calendar_service.dart        # Add to Calendar
│
├── providers/
│   ├── auth_provider.dart           # RBAC core — role, isChapterLead, etc.
│   ├── team_provider.dart
│   ├── meeting_provider.dart
│   ├── attendance_provider.dart
│   ├── event_provider.dart
│   ├── notification_provider.dart
│   └── theme_provider.dart          # Dark/Light + time-based switching
│
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── teams_screen.dart
│   ├── meetings_screen.dart
│   ├── attendance_screen.dart
│   ├── events_screen.dart
│   ├── profile_screen.dart
│   ├── learning_screen.dart
│   ├── community_screen.dart
│   ├── quiz_screen.dart
│   └── qr_screen.dart
│
└── widgets/
    ├── role_guard.dart              # Role-based visibility wrapper
    ├── gdg_logo_widget.dart         # Animated Rive GDG logo
    ├── animated_attendance_tile.dart
    ├── countdown_timer.dart
    ├── badge_card.dart
    ├── social_connect_card.dart
    ├── rolling_counter.dart         # Animated number counter
    └── meeting_card.dart

assets/
└── animations/
    ├── login_anim.json
    ├── success_anim.json
    ├── empty_state.json
    ├── loading.json
    ├── celebration.json
    ├── gdg_logo.riv
    └── attendance_btn.riv
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.4.0
  firebase_messaging: ^15.1.0

  # State Management
  provider: ^6.1.2

  # Animations
  lottie: ^3.1.0
  rive: ^0.13.16

  # Navigation & UI
  animated_drawer: ^1.0.0
  google_fonts: ^6.2.1

  # Calendar & Date
  table_calendar: ^3.1.2
  add_2_calendar: ^3.0.1
  intl: ^0.19.0

  # Charts & Indicators
  fl_chart: ^0.69.0
  percent_indicator: ^4.2.3

  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.2.3

  # Multi-select dropdowns
  multi_select_flutter: ^4.1.3
  dropdown_button2: ^2.3.9

  # Utilities
  url_launcher: ^6.3.0
  shared_preferences: ^2.3.2
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
```

---

## 🔒 Firestore Security Rules

Deploy these rules from the Firebase Console under **Firestore → Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuth() {
      return request.auth != null;
    }
    function userRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    function isChapterLead() {
      return isAuth() && userRole() == 'chapter_lead';
    }
    function isTeamLead() {
      return isAuth() && userRole() == 'team_lead';
    }
    function isTeamLeadOf(teamId) {
      return isAuth() && get(/databases/$(database)/documents/teams/$(teamId)).data.leadId == request.auth.uid;
    }
    function isMemberOf(teamId) {
      return isAuth() && request.auth.uid in get(/databases/$(database)/documents/teams/$(teamId)).data.memberIds;
    }

    match /users/{uid} {
      allow read:  if request.auth.uid == uid || isChapterLead();
      allow write: if isChapterLead();
      allow update: if request.auth.uid == uid
        && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'chapterId']);
    }

    match /teams/{teamId} {
      allow read:  if isMemberOf(teamId) || isChapterLead();
      allow write: if isChapterLead();
    }

    match /meetings/{meetingId} {
      allow read:   if isMemberOf(resource.data.teamId) || isChapterLead();
      allow create: if isTeamLeadOf(request.resource.data.teamId) || isChapterLead();
      allow update, delete: if isTeamLeadOf(resource.data.teamId) || isChapterLead();
    }

    match /attendance/{id} {
      allow read:   if request.auth.uid == resource.data.memberId
                    || isTeamLeadOf(resource.data.teamId)
                    || isChapterLead();
      allow create: if isTeamLeadOf(request.resource.data.teamId) || isChapterLead();
      allow update: if (isTeamLeadOf(resource.data.teamId) || isChapterLead())
                    && request.time < resource.data.markedAt + duration.value(24, 'h');
    }

    match /events/{eventId} {
      allow read:  if isAuth();
      allow write: if isChapterLead();

      match /feedback/{uid} {
        allow read:   if isChapterLead() || request.auth.uid == uid;
        allow create: if request.auth.uid == uid;
        allow update: if request.auth.uid == uid;
      }
    }

    match /learning/{category}/resources/{id} {
      allow read:  if isAuth();
      allow write: if isChapterLead();
    }

    match /community/{doc} {
      allow read:  if isAuth();
      allow write: if isChapterLead();
    }

    match /polls/{pollId} {
      allow read:  if isAuth();
      allow write: if isChapterLead();
    }

    match /notifications/{uid}/items/{id} {
      allow read, delete: if request.auth.uid == uid;
      allow create: if isChapterLead();
    }
  }
}
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-feature-name`
3. **Commit** your changes: `git commit -m 'feat: add your feature'`
4. **Push** to the branch: `git push origin feature/your-feature-name`
5. **Open** a Pull Request

### Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Use for |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `ui:` | UI/UX changes |
| `refactor:` | Code restructure (no feature change) |
| `docs:` | Documentation only |
| `chore:` | Config, dependencies, tooling |

### Code Style

- Run `flutter analyze` before committing — zero warnings policy
- Use `const` constructors wherever possible
- All Provider access via `context.watch` / `context.read` — no `setState` inside provider-backed screens
- All Firestore calls through service classes only

---

## 📋 Roadmap

- [x] Firebase Auth + RBAC foundation
- [x] AppUser model with role helpers
- [x] AuthProvider + AuthGate routing
- [x] Login Screen with Lottie animation
- [ ] Dashboard Screen (role-sensitive)
- [ ] Team Management module
- [ ] Meeting Management module
- [ ] Attendance module with AnimatedContainer tiles
- [ ] Attendance history & fl_chart insights
- [ ] Animated GDG Logo widget (Rive)
- [ ] Events module with countdown timers
- [ ] Profile + Badges system
- [ ] Learning Zone
- [ ] Community Vibes section
- [ ] Tech Quiz + Polls
- [ ] QR Code system
- [ ] FCM push notifications
- [ ] Dark / Light mode + time-based theme
- [ ] Tablet adaptive layout (NavigationRail)

---

## 👤 Author

**Eman Noor**  
BSCS — COMSATS University Islamabad, Attock Campus  
GitHub: [@emannoor-cs](https://github.com/emannoor-cs)

---

<div align="center">

Built with ❤️ for the GDG community

<img src="https://img.shields.io/badge/Google%20Developer%20Groups-4285F4?style=for-the-badge&logo=google&logoColor=white"/>

*If this helped you, leave a ⭐ on the repo!*

</div>
