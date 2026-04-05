import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/firebase_service.dart';
import '../core/widgets.dart';

class _Question {
  final String question;
  final List<String> options;
  final int correctIndex;
  const _Question(this.question, this.options, this.correctIndex);
}

final _questions = [
  const _Question(
    'Which company created Flutter?',
    ['Facebook', 'Apple', 'Google', 'Microsoft'],
    2,
  ),
  const _Question(
    'What language does Flutter use?',
    ['JavaScript', 'Kotlin', 'Swift', 'Dart'],
    3,
  ),
  const _Question(
    'What is Firebase?',
    ['A SQL database', 'A BaaS platform', 'A CSS framework', 'A testing tool'],
    1,
  ),
  const _Question(
    'What does RBAC stand for?',
    [
      'Role-Based Access Control',
      'Reactive Backend API Core',
      'Runtime Binary App Config',
      'Resource Binding and Caching'
    ],
    0,
  ),
  const _Question(
    'Which chart library is commonly used in Flutter?',
    ['Chart.js', 'Recharts', 'fl_chart', 'Victory'],
    2,
  ),
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _finished = false;
  bool _saving = false;

  void _answer(int chosen) {
    if (_answered) return;
    final correct = _questions[_questionIndex].correctIndex == chosen;
    setState(() {
      _selectedOption = chosen;
      _answered = true;
      if (correct) _score++;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_questionIndex < _questions.length - 1) {
        setState(() {
          _questionIndex++;
          _selectedOption = null;
          _answered = false;
        });
      } else {
        setState(() => _finished = true);
        _saveScore();
      }
    });
  }

  Future<void> _saveScore() async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);

    try {
      await FirebaseService.db
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .add({
        'score': _score,
        'total': _questions.length,
        'percentage': (_score / _questions.length * 100).round(),
        'takenAt': DateTime.now(),
      });

      // Optionally update best score on user profile
      final profile = await FirebaseService.getUserProfile(uid);
      final prevBest = profile?['quizBestScore'] as int? ?? 0;
      if (_score > prevBest) {
        await FirebaseService.db
            .collection('users')
            .doc(uid)
            .update({'quizBestScore': _score});
      }
    } catch (_) {
      // Silently fail — quiz result saving is non-critical
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _selectedOption = null;
      _answered = false;
      _finished = false;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface2,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _finished ? _buildResultView() : _buildQuestion(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _finished ? 1.0 : (_questionIndex + 1) / _questions.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gdgBlue, Color(0xFF0052CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text('Tech Quiz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 48),
            ],
          ),
          if (!_finished) ...[
            Text(
              'Question ${_questionIndex + 1} of ${_questions.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white30,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.gdgYellow),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_questionIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView(
        key: ValueKey(_questionIndex),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Text(
            q.question,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
          ),
          const SizedBox(height: 24),
          ...q.options.asMap().entries.map((e) {
            final i = e.key;
            final opt = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionButton(
                label: '${String.fromCharCode(65 + i)}. $opt',
                state: _getOptionState(i, q.correctIndex),
                onTap: () => _answer(i),
              ),
            );
          }),
        ],
      ),
    );
  }

  _OptionState _getOptionState(int i, int correct) {
    if (!_answered) return _OptionState.normal;
    if (i == correct) return _OptionState.correct;
    if (i == _selectedOption) return _OptionState.wrong;
    return _OptionState.normal;
  }

  Widget _buildResultView() {
    final emoji = _score >= 4
        ? '🎉'
        : _score >= 2
            ? '👍'
            : '😅';
    final message = _score >= 4
        ? 'Outstanding! You know your GDG tech!'
        : _score >= 2
            ? 'Good effort! Keep learning!'
            : 'Time to hit the Learning Zone!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('$_score / ${_questions.length}',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gdgBlue)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 12),

            // Saving indicator
            if (_saving)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.gdgBlue),
                  ),
                  SizedBox(width: 8),
                  Text('Saving score...',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                ],
              )
            else
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.gdgGreen),
                  SizedBox(width: 6),
                  Text('Score saved',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.gdgGreen)),
                ],
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scoreChip('$_score Correct', AppColors.gdgGreenLight,
                    AppColors.gdgGreen),
                const SizedBox(width: 12),
                _scoreChip('${_questions.length - _score} Wrong',
                    AppColors.gdgRedLight, AppColors.gdgRed),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _restart,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style:
              TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

enum _OptionState { normal, correct, wrong }

class _OptionButton extends StatelessWidget {
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionButton(
      {required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg, borderColor, textColor;
    switch (state) {
      case _OptionState.correct:
        bg = AppColors.gdgGreenLight;
        borderColor = AppColors.gdgGreen;
        textColor = const Color(0xFF1B6B35);
        break;
      case _OptionState.wrong:
        bg = AppColors.gdgRedLight;
        borderColor = AppColors.gdgRed;
        textColor = const Color(0xFFC5221F);
        break;
      default:
        bg = AppColors.surface;
        borderColor = AppColors.border;
        textColor = AppColors.textPrimary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: state == _OptionState.normal ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: state != _OptionState.normal
                            ? FontWeight.w600
                            : FontWeight.w400)),
              ),
              if (state == _OptionState.correct)
                const Icon(Icons.check_circle,
                    color: AppColors.gdgGreen, size: 18),
              if (state == _OptionState.wrong)
                const Icon(Icons.cancel, color: AppColors.gdgRed, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
