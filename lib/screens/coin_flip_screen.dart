import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neu_theme.dart';
import '../models/flip_record.dart';
import '../widgets/neu_box.dart';
import '../widgets/neu_button.dart';
import '../widgets/neu_icon_button.dart';
import '../widgets/coin_widget.dart';
import '../widgets/stat_badge.dart';
import '../widgets/confetti_particles.dart';

class CoinFlipScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeToggle;

  const CoinFlipScreen({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with TickerProviderStateMixin {
  final math.Random _random = math.Random();
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late final AnimationController _flipController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _heightProgressAnimation;

  // Secondary flip controller for 2-coin mode
  late final AnimationController _flipController2;
  late final Animation<double> _rotationAnimation2;

  // State variables
  bool _isFlipping = false;
  bool _showKepala = true; // Current visible face
  bool _targetKepala = true; // Next outcome

  // For 2-coin mode
  bool _showKepala2 = false;
  bool _targetKepala2 = false;

  // Stats
  int _totalFlips = 0;
  int _kepalaCount = 0;
  int _ekorCount = 0;
  int _currentStreak = 0;
  bool? _streakSide;
  int _longestStreak = 0;
  bool? _longestStreakSide;

  // Guess Mode
  int _activeMode = 0; // 0: Bebas, 1: Tebak, 2: Koin Ganda
  bool? _selectedGuess = true; // true = Kepala, false = Ekor
  int _guessWins = 0;
  int _guessAttempts = 0;
  int _guessStreak = 0;
  int _longestGuessStreak = 0;
  bool _triggerConfetti = false;

  // Coin Material
  CoinMaterial _selectedMaterial = CoinMaterial.gold;

  // History
  final List<FlipRecord> _history = [];

  // Latest result text & banner
  String _resultTitle = 'Siap Melempar';
  String _resultSubtitle = 'Tekan tombol lempar atau ketuk koin';
  Color? _resultAccentColor;

  // Heart toggle
  bool _isHearted = false;

  @override
  void initState() {
    super.initState();

    // Primary flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6 * math.pi, // 3 full 360-degree rotations
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeOutCubic,
    ));

    _heightProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finalizeFlip();
      }
    });

    // Secondary flip animation for 2-coin mode
    _flipController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1550),
    );

    _rotationAnimation2 = Tween<double>(
      begin: 0.0,
      end: 7 * math.pi,
    ).animate(CurvedAnimation(
      parent: _flipController2,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _flipController2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
      _triggerConfetti = false;
      _resultTitle = 'Koin Berputar di Udara...';
      _resultSubtitle = 'Menentukan takdir...';
      _resultAccentColor = null;

      // Random outcome generation: 50% chance
      _targetKepala = _random.nextBool();
      if (_activeMode == 2) {
        _targetKepala2 = _random.nextBool();
      }
    });

    HapticFeedback.heavyImpact();

    _flipController.forward(from: 0.0);
    if (_activeMode == 2) {
      _flipController2.forward(from: 0.0);
    }
  }

  void _finalizeFlip() {
    setState(() {
      _isFlipping = false;
      _showKepala = _targetKepala;
      if (_activeMode == 2) {
        _showKepala2 = _targetKepala2;
      }

      _totalFlips++;
      if (_showKepala) {
        _kepalaCount++;
      } else {
        _ekorCount++;
      }

      // Streak tracking
      if (_streakSide == _showKepala) {
        _currentStreak++;
      } else {
        _streakSide = _showKepala;
        _currentStreak = 1;
      }

      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
        _longestStreakSide = _showKepala;
      }

      // Result Messages & Guess Logic
      if (_activeMode == 1 && _selectedGuess != null) {
        _guessAttempts++;
        final bool isWon = _selectedGuess == _showKepala;

        if (isWon) {
          _guessWins++;
          _guessStreak++;
          if (_guessStreak > _longestGuessStreak) {
            _longestGuessStreak = _guessStreak;
          }
          _resultTitle = 'Tebakan Benar! 🎉';
          _resultSubtitle =
              'Hasil: ${_showKepala ? "KEPALA" : "EKOR"} • Streak: $_guessStreak' 'x';
          _resultAccentColor = const Color(0xFF2A9D8F);
          _triggerConfetti = true;
          HapticFeedback.vibrate();
        } else {
          _guessStreak = 0;
          _resultTitle = 'Kurang Beruntung! 😅';
          _resultSubtitle =
              'Hasil: ${_showKepala ? "KEPALA" : "EKOR"} (Kamu tebak ${_selectedGuess! ? "Kepala" : "Ekor"})';
          _resultAccentColor = const Color(0xFFE63946);
        }

        _history.insert(
          0,
          FlipRecord(
            index: _totalFlips,
            isKepala: _showKepala,
            timestamp: DateTime.now(),
            guessedKepala: _selectedGuess,
          ),
        );
      } else if (_activeMode == 2) {
        // 2-coin mode
        final String c1 = _showKepala ? 'Kepala' : 'Ekor';
        final String c2 = _showKepala2 ? 'Kepala' : 'Ekor';
        _resultTitle = '$c1 & $c2!';
        _resultSubtitle = 'Hasil 2 Koin Sekaligus';
        _resultAccentColor = const Color(0xFF2B5C8F);

        _history.insert(
          0,
          FlipRecord(
            index: _totalFlips,
            isKepala: _showKepala,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        // Free Mode
        final String sideName = _showKepala ? 'KEPALA (HEADS)' : 'EKOR (TAILS)';
        _resultTitle = sideName;
        _resultSubtitle = 'Streak: $_currentStreak' 'x berturut-turut!';
        _resultAccentColor = _showKepala ? const Color(0xFFF5B041) : const Color(0xFF5D7A9C);

        if (_currentStreak >= 3) {
          _triggerConfetti = true;
        }

        _history.insert(
          0,
          FlipRecord(
            index: _totalFlips,
            isKepala: _showKepala,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }

  void _cycleMode() {
    if (_isFlipping) return;
    setState(() {
      _activeMode = (_activeMode + 1) % 3;
    });
    HapticFeedback.selectionClick();
  }

  void _scrollToStats() {
    _scrollController.animateTo(
      450,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _resetAll() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = NeuTheme(isDark: widget.isDark);
        return AlertDialog(
          backgroundColor: theme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Reset Data?',
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Semua riwayat, statistik lemparan, dan catatan streak akan direset kembali ke nol.',
            style: TextStyle(color: theme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Batal', style: TextStyle(color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _totalFlips = 0;
                  _kepalaCount = 0;
                  _ekorCount = 0;
                  _currentStreak = 0;
                  _streakSide = null;
                  _longestStreak = 0;
                  _longestStreakSide = null;
                  _guessWins = 0;
                  _guessAttempts = 0;
                  _guessStreak = 0;
                  _longestGuessStreak = 0;
                  _history.clear();
                  _resultTitle = 'Statistik Direset';
                  _resultSubtitle = 'Siap untuk lemparan baru';
                  _resultAccentColor = null;
                });
                HapticFeedback.mediumImpact();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog() {
    final theme = NeuTheme(isDark: widget.isDark);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: theme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Speed Code Challenge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Peserta', 'Dafi Al Fajar', theme),
            _buildInfoRow('Topik', 'Coin Flip Simulator', theme),
            _buildInfoRow('Gaya Desain', 'Neumorphism (Soft UI)', theme),
            _buildInfoRow('Fitur Utama', 'Acak Koin, Hasil, Hitung K/E, Streak', theme),
            const SizedBox(height: 12),
            Text(
              'Aplikasi ini dirancang dengan gaya Neumorphism (Soft UI) murni, '
              'dilengkapi fisika putaran koin 3D, bayangan dinamis, pengenalan sisi Garuda & Rupiah 1000, '
              'serta mode tebak streak interaktif.',
              style: TextStyle(fontSize: 12, color: theme.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, NeuTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuTheme(isDark: widget.isDark);

    return Scaffold(
      backgroundColor: theme.bg,
      body: ConfettiParticles(
        trigger: _triggerConfetti,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // 1. Signature Header (Styled after "Dancing Man" reference)
                  _buildReferenceHeader(theme),
                  const SizedBox(height: 20),

                  // 2. Stage with Vertical Floating Pill Dock & Concentric Disc Arena
                  _buildInteractiveStage(theme),
                  const SizedBox(height: 18),

                  // 3. Result Banner (Status & Streak notification)
                  _buildResultBanner(theme),
                  const SizedBox(height: 16),

                  // 4. Mode Switcher (Bebas, Tebak, 2 Koin)
                  _buildModeSelector(theme),
                  const SizedBox(height: 16),

                  // 5. Guess Controls (Only in Guess Mode)
                  if (_activeMode == 1) ...[
                    _buildGuessControls(theme),
                    const SizedBox(height: 16),
                  ],

                  // 6. Primary Action Button
                  _buildFlipActionButton(theme),
                  const SizedBox(height: 24),

                  // 7. "Trending" Material Selector (3 Circular Avatars from Reference)
                  _buildTrendingMaterialSection(theme),
                  const SizedBox(height: 24),

                  // 8. "Popular Playlists" Style Stats Section (Kepala & Ekor Cards)
                  StatSummaryCard(
                    totalFlips: _totalFlips,
                    kepalaCount: _kepalaCount,
                    ekorCount: _ekorCount,
                    currentStreak: _currentStreak,
                    streakSide: _streakSide,
                    longestStreak: _longestStreak,
                    longestStreakSide: _longestStreakSide,
                    theme: theme,
                  ),
                  const SizedBox(height: 24),

                  // 9. "News" Style Riwayat Lemparan Section (Horizontal Pill Items)
                  _buildNewsHistorySection(theme),
                  const SizedBox(height: 30),

                  // 10. Footer Credits
                  _buildFooter(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header inspired by "Dancing Man / Heating Up wave / Katy Perry"
  Widget _buildReferenceHeader(NeuTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coin Flip',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Speed Code Challenge',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Dafi Al Fajar • Soft UI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeuIconButton(
              theme: theme,
              size: 38,
              iconSize: 18,
              icon: Icons.info_outline_rounded,
              tooltip: 'Info Praktikum',
              onTap: _showInfoDialog,
            ),
            const SizedBox(width: 8),
            NeuIconButton(
              theme: theme,
              size: 38,
              iconSize: 18,
              icon: Icons.restart_alt_rounded,
              tooltip: 'Reset Statistik',
              iconColor: theme.danger,
              onTap: _resetAll,
            ),
            const SizedBox(width: 8),
            NeuIconButton(
              theme: theme,
              size: 38,
              iconSize: 18,
              icon: widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              tooltip: widget.isDark ? 'Mode Terang' : 'Mode Gelap',
              iconColor: widget.isDark ? Colors.amber : theme.primary,
              onTap: () {
                widget.onThemeToggle(!widget.isDark);
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ],
    );
  }

  // Interactive Stage: Vertical Floating Pill Dock on left + Concentric Disc on right
  Widget _buildInteractiveStage(NeuTheme theme) {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Concentric Disc Arena (Emerging Plate from left screen of reference)
          Positioned(
            right: 0,
            left: 55,
            top: 0,
            bottom: 0,
            child: NeuBox(
              theme: theme,
              shape: BoxShape.circle,
              style: NeuStyle.convex,
              depth: 7,
              blur: 16,
              child: Center(
                // Inset ring channel
                child: NeuBox(
                  theme: theme,
                  width: 220,
                  height: 220,
                  shape: BoxShape.circle,
                  style: NeuStyle.inset,
                  depth: 4,
                  child: Center(
                    // Inner plate with 3D Coin
                    child: AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) {
                        final rot = _rotationAnimation.value;
                        final prog = _heightProgressAnimation.value;

                        if (_activeMode == 2) {
                          // Dual Coin Mode
                          final rot2 = _rotationAnimation2.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CoinWidget(
                                showKepala: _showKepala,
                                size: 85,
                                flipProgress: prog,
                                rotationAngle: rot,
                                material: _selectedMaterial,
                                theme: theme,
                                onTap: _flipCoin,
                              ),
                              const SizedBox(width: 6),
                              CoinWidget(
                                showKepala: _showKepala2,
                                size: 85,
                                flipProgress: prog,
                                rotationAngle: rot2,
                                material: _selectedMaterial == CoinMaterial.gold
                                    ? CoinMaterial.silver
                                    : CoinMaterial.gold,
                                theme: theme,
                                onTap: _flipCoin,
                              ),
                            ],
                          );
                        }

                        // Single Coin
                        return CoinWidget(
                          showKepala: _showKepala,
                          size: 155,
                          flipProgress: prog,
                          rotationAngle: rot,
                          material: _selectedMaterial,
                          theme: theme,
                          onTap: _flipCoin,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Vertical Floating Neumorphic Control Pill (Left Dock from reference image!)
          Positioned(
            left: 0,
            top: 15,
            bottom: 15,
            child: NeuBox(
              theme: theme,
              width: 52,
              style: NeuStyle.convex,
              depth: 6,
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Replay / Quick Flip
                  _buildDockIconButton(
                    icon: Icons.replay_rounded,
                    tooltip: 'Putar Cepat',
                    color: theme.textSecondary,
                    onTap: _flipCoin,
                  ),
                  // Cycle Mode (Next icon)
                  _buildDockIconButton(
                    icon: Icons.skip_next_rounded,
                    tooltip: 'Ganti Mode',
                    color: theme.textSecondary,
                    onTap: _cycleMode,
                  ),
                  // Main Play / Pause icon
                  _buildDockIconButton(
                    icon: _isFlipping
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    tooltip: 'Lempar Koin',
                    color: theme.primary,
                    size: 26,
                    onTap: _flipCoin,
                  ),
                  // Stats Navigation
                  _buildDockIconButton(
                    icon: Icons.bar_chart_rounded,
                    tooltip: 'Lihat Statistik',
                    color: theme.textSecondary,
                    onTap: _scrollToStats,
                  ),
                  // Signature Red Heart Icon from Reference!
                  _buildDockIconButton(
                    icon: Icons.favorite_rounded,
                    tooltip: 'Favorit & Selebrasi',
                    color: theme.danger,
                    onTap: () {
                      setState(() {
                        _isHearted = !_isHearted;
                        _triggerConfetti = true;
                      });
                      HapticFeedback.mediumImpact();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
    double size = 20,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }

  Widget _buildResultBanner(NeuTheme theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: NeuBox(
        key: ValueKey<String>('$_resultTitle-$_resultSubtitle'),
        theme: theme,
        style: NeuStyle.flat,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        border: _resultAccentColor != null
            ? Border.all(color: _resultAccentColor!.withValues(alpha: 0.5), width: 1.5)
            : null,
        child: Row(
          children: [
            NeuBox(
              theme: theme,
              shape: BoxShape.circle,
              width: 40,
              height: 40,
              style: NeuStyle.inset,
              depth: 3,
              child: Icon(
                _isFlipping
                    ? Icons.autorenew_rounded
                    : _showKepala
                        ? Icons.brightness_7_rounded
                        : Icons.toll_rounded,
                color: _resultAccentColor ?? theme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resultTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _resultAccentColor ?? theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _resultSubtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(NeuTheme theme) {
    final modes = [
      {'title': 'Bebas', 'icon': Icons.casino_rounded},
      {'title': 'Tebak', 'icon': Icons.sports_esports_rounded},
      {'title': '2 Koin', 'icon': Icons.filter_2_rounded},
    ];

    return NeuBox(
      theme: theme,
      style: NeuStyle.inset,
      depth: 3,
      padding: const EdgeInsets.all(5),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: List.generate(modes.length, (index) {
          final isSelected = _activeMode == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isFlipping) return;
                setState(() => _activeMode = index);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected ? theme.cardBg : Colors.transparent,
                  boxShadow: isSelected
                      ? theme.getShadows(offset: 3, blur: 6)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      modes[index]['icon'] as IconData,
                      size: 15,
                      color: isSelected ? theme.primary : theme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      modes[index]['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? theme.primary : theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGuessControls(NeuTheme theme) {
    final double winPercent = _guessAttempts > 0 ? (_guessWins / _guessAttempts) * 100 : 0.0;

    return NeuBox(
      theme: theme,
      style: NeuStyle.convex,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Tebakanmu:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              Text(
                'Akurasi: $_guessWins/$_guessAttempts (${winPercent.toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NeuButton(
                  theme: theme,
                  isSelected: _selectedGuess == true,
                  isEnabled: !_isFlipping,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onTap: () {
                    setState(() => _selectedGuess = true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.brightness_7_rounded,
                        size: 16,
                        color: _selectedGuess == true ? theme.gold : theme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KEPALA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _selectedGuess == true ? theme.primary : theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeuButton(
                  theme: theme,
                  isSelected: _selectedGuess == false,
                  isEnabled: !_isFlipping,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onTap: () {
                    setState(() => _selectedGuess = false);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.toll_rounded,
                        size: 16,
                        color: _selectedGuess == false ? theme.silver : theme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'EKOR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _selectedGuess == false ? theme.primary : theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlipActionButton(NeuTheme theme) {
    return NeuButton(
      theme: theme,
      isEnabled: !_isFlipping,
      height: 54,
      borderRadius: BorderRadius.circular(20),
      onTap: _flipCoin,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isFlipping ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
              size: 22,
              color: theme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _isFlipping ? 'SEDANG MELEMPAR...' : 'LEMPAR KOIN SEKARANG',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: theme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section 7: "Trending" 3 Circular Avatars from Reference Image!
  Widget _buildTrendingMaterialSection(NeuTheme theme) {
    final materials = [
      {
        'mat': CoinMaterial.gold,
        'name': 'Emas',
        'color': theme.gold,
        'icon': Icons.monetization_on_rounded,
      },
      {
        'mat': CoinMaterial.silver,
        'name': 'Perak',
        'color': theme.silver,
        'icon': Icons.circle_outlined,
      },
      {
        'mat': CoinMaterial.bronze,
        'name': 'Perunggu',
        'color': const Color(0xFFCD7F32),
        'icon': Icons.shield_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with three-dot button (identical to reference!)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trending',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            NeuBox(
              theme: theme,
              style: NeuStyle.convex,
              depth: 2,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                '•••',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Three circular avatars with sunken outer ring
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: materials.map((item) {
            final mat = item['mat'] as CoinMaterial;
            final isSelected = _selectedMaterial == mat;
            final color = item['color'] as Color;
            final name = item['name'] as String;
            final icon = item['icon'] as IconData;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedMaterial = mat);
                HapticFeedback.selectionClick();
              },
              child: Column(
                children: [
                  // Outer sunken moat ring
                  NeuBox(
                    theme: theme,
                    shape: BoxShape.circle,
                    width: 62,
                    height: 62,
                    style: NeuStyle.inset,
                    depth: 3,
                    child: Center(
                      // Inner raised avatar circle
                      child: NeuBox(
                        theme: theme,
                        shape: BoxShape.circle,
                        width: 46,
                        height: 46,
                        style: isSelected ? NeuStyle.flat : NeuStyle.convex,
                        depth: isSelected ? 1 : 4,
                        border: isSelected
                            ? Border.all(color: color, width: 2.0)
                            : null,
                        child: Icon(
                          icon,
                          size: 22,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? theme.primary : theme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Section 9: "News" Style History Pills from Reference Image!
  Widget _buildNewsHistorySection(NeuTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with three-dot button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'News',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            NeuBox(
              theme: theme,
              style: NeuStyle.convex,
              depth: 2,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                '•••',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_history.isEmpty)
          NeuBox(
            theme: theme,
            style: NeuStyle.flat,
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Center(
              child: Text(
                'Belum ada riwayat lemparan. Tekan tombol untuk mulai!',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Column(
            children: _history.take(5).map((item) {
              final isKepala = item.isKepala;
              final isGuessCorrect = item.isGuessedCorrectly;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeuBox(
                  theme: theme,
                  style: NeuStyle.convex,
                  depth: 4,
                  borderRadius: BorderRadius.circular(25),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      // Circular Avatar on left (as seen in News item)
                      NeuBox(
                        theme: theme,
                        shape: BoxShape.circle,
                        width: 36,
                        height: 36,
                        style: NeuStyle.inset,
                        depth: 2,
                        child: Icon(
                          isKepala
                              ? Icons.brightness_7_rounded
                              : Icons.toll_rounded,
                          size: 18,
                          color: isKepala ? theme.gold : theme.silver,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lemparan #${item.index} • ${isKepala ? "Kepala" : "Ekor"}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Pukul ${item.formattedTime}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isGuessCorrect != null)
                        Icon(
                          isGuessCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 16,
                          color: isGuessCorrect ? theme.success : theme.danger,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFooter(NeuTheme theme) {
    return Column(
      children: [
        Text(
          'Flutter Speed Code Challenge • Topik: Coin Flip',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dafi Al Fajar • Soft UI Neumorphism',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: theme.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
