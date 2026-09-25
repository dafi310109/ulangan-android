import 'package:flutter/material.dart';
import '../theme/neu_theme.dart';
import 'neu_box.dart';

class StatSummaryCard extends StatelessWidget {
  final int totalFlips;
  final int kepalaCount;
  final int ekorCount;
  final int currentStreak;
  final bool? streakSide; // true = Kepala, false = Ekor, null = none
  final int longestStreak;
  final bool? longestStreakSide;
  final NeuTheme theme;

  const StatSummaryCard({
    super.key,
    required this.totalFlips,
    required this.kepalaCount,
    required this.ekorCount,
    required this.currentStreak,
    required this.streakSide,
    required this.longestStreak,
    required this.longestStreakSide,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final double kepalaPercent = totalFlips > 0 ? (kepalaCount / totalFlips) * 100 : 50.0;
    final double ekorPercent = totalFlips > 0 ? (ekorCount / totalFlips) * 100 : 50.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header styled like "Popular Playlists" in reference
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Statistik Lemparan',
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
              depth: 3,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(
                'Total: $totalFlips',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Playlist-style cards (Kepala & Ekor) matching the reference image
        Row(
          children: [
            Expanded(
              child: _buildPlaylistCard(
                title: 'Kepala',
                subtitle: 'Sisi Garuda',
                count: kepalaCount,
                percent: kepalaPercent,
                color: theme.gold,
                icon: Icons.brightness_7_rounded,
                isKepala: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildPlaylistCard(
                title: 'Ekor',
                subtitle: 'Sisi 1000 Rp',
                count: ekorCount,
                percent: ekorPercent,
                color: theme.silver,
                icon: Icons.toll_rounded,
                isKepala: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Distribution Ratio Bar (Neumorphic Inset Slider)
        NeuBox(
          theme: theme,
          style: NeuStyle.flat,
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rasio Kepala vs Ekor',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.textSecondary,
                    ),
                  ),
                  Text(
                    '${kepalaPercent.toStringAsFixed(0)}% : ${ekorPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              NeuBox(
                theme: theme,
                style: NeuStyle.inset,
                height: 10,
                borderRadius: BorderRadius.circular(6),
                depth: 2,
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Flexible(
                        flex: (kepalaPercent * 10).round().clamp(1, 999),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.gold, const Color(0xFFF39C12)],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: (ekorPercent * 10).round().clamp(1, 999),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.silver, const Color(0xFF78909C)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Streaks Row (Pill-style badges)
        Row(
          children: [
            Expanded(
              child: _buildStreakTile(
                label: 'Streak Sekarang',
                streak: currentStreak,
                side: streakSide,
                icon: Icons.local_fire_department_rounded,
                iconColor: theme.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStreakTile(
                label: 'Rekor Terpanjang',
                streak: longestStreak,
                side: longestStreakSide,
                icon: Icons.emoji_events_rounded,
                iconColor: theme.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaylistCard({
    required String title,
    required String subtitle,
    required int count,
    required double percent,
    required Color color,
    required IconData icon,
    required bool isKepala,
  }) {
    return NeuBox(
      theme: theme,
      style: NeuStyle.convex,
      depth: 5,
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Artwork Container (Styled like the Disco/Hip Hop cards)
          Container(
            height: 95,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isKepala
                    ? [const Color(0xFF2E2415), const Color(0xFF6B4E1A)]
                    : [const Color(0xFF1E2632), const Color(0xFF3E4F66)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft glow circle behind icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.25),
                  ),
                ),
                Icon(
                  icon,
                  size: 34,
                  color: color,
                ),
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Card Text Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                      ),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStreakTile({
    required String label,
    required int streak,
    required bool? side,
    required IconData icon,
    required Color iconColor,
  }) {
    final String sideLabel = side == null
        ? '-'
        : side
            ? 'Kepala'
            : 'Ekor';

    return NeuBox(
      theme: theme,
      style: NeuStyle.convex,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.15),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streak > 0 ? '$streak' 'x $sideLabel' : '0x',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: streak > 0 ? theme.primary : theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
