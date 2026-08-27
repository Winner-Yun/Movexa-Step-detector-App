import 'package:flutter/material.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/models/workout_session.dart';

class StepWorkoutDetailPage extends StatelessWidget {
  final WorkoutSession session;

  const StepWorkoutDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ThemeColors.getText(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'សេចក្តីលម្អិត',
          style: textTheme.titleMedium?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          children: [
            _buildHeaderInfo(context, textTheme),
            SizedBox(height: 24),
            _buildMainHeroCard(context, textTheme),
            SizedBox(height: 24),
            _buildMetricsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeColors.getBrandAccent(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.directions_run_rounded,
            color: ThemeColors.getBrandAccent(context),
            size: 32,
          ),
        ),
        SizedBox(height: 16),
        Text(
          session.title,
          style: textTheme.headlineSmall?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}',
          style: textTheme.bodyMedium?.copyWith(
            color: ThemeColors.getMutedText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMainHeroCard(BuildContext context, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryGradientStart(context),
            ThemeColors.getPrimaryGradientEnd(context),
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
          Text(
            'សរុបជំហាន (Total Steps)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatBox(
                context,
                Icons.timer_rounded,
                'រយៈពេល',
                session.formattedDuration,
                'នាទី',
                Colors.orange,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSimpleStatBox(
                context,
                Icons.route_rounded,
                'ចម្ងាយ',
                session.distance.toStringAsFixed(2),
                'KM',
                const Color(0xFF2980B9),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatBox(
                context,
                Icons.local_fire_department_rounded,
                'កាឡូរី',
                session.calories.toStringAsFixed(0),
                'KCAL',
                const Color(0xFFD45529),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSimpleStatBox(
                context,
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
    BuildContext context,
    IconData icon,
    String title,
    String value,
    String unit,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: ThemeColors.getMutedText(context),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
