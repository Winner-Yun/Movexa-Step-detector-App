import 'package:flutter/material.dart';
import 'package:step_detector/shared/models/workout_session.dart';

import '../../../core/constants/app_colors.dart';
// Import your WorkoutSession model

class StepWorkoutDetailPage extends StatelessWidget {
  final WorkoutSession session; // Using the real Firebase Model now!

  const StepWorkoutDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'សេចក្តីលម្អិត',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          children: [
            _buildHeaderInfo(textTheme),
            const SizedBox(height: 24),
            _buildMainHeroCard(textTheme),
            const SizedBox(height: 24),
            _buildMetricsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_run_rounded,
            color: AppColors.brandAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          session.title,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        // Simple date formatting for now
        Text(
          '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }

  Widget _buildMainHeroCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            session.steps.toString(),
            style: textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'សរុបជំហាន (Total Steps)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatBox(
                Icons.timer_rounded,
                'រយៈពេល',
                session.formattedDuration,
                'នាទី',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSimpleStatBox(
                Icons.route_rounded,
                'ចម្ងាយ',
                session.distance.toStringAsFixed(2),
                'KM',
                const Color(0xFF2980B9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatBox(
                Icons.local_fire_department_rounded,
                'កាឡូរី',
                session.calories.toStringAsFixed(0),
                'KCAL',
                const Color(0xFFD45529),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSimpleStatBox(
                Icons.speed_rounded,
                'ល្បឿន',
                session.averagePace,
                '/KM',
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleStatBox(
    IconData icon,
    String title,
    String value,
    String unit,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
