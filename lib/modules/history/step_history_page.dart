import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/data/controller/activity_controller.dart';

import 'package:step_detector/core/constants/app_colors.dart';
import 'package:step_detector/modules/workout/step_workout_detail_page.dart';

class StepHistoryPage extends StatefulWidget {
  const StepHistoryPage({super.key});

  @override
  State<StepHistoryPage> createState() => _StepHistoryPageState();
}

class _StepHistoryPageState extends State<StepHistoryPage> {
  int _selectedTabIndex = 0;

  // Track which day is currently selected in the chart
  int _selectedDay = DateTime.now().day;

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year}, $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final activityCtrl = context.watch<ActivityController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: _buildHeader(textTheme),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSegmentedControl(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTabIndex == 0
                    ? _buildDailyView(
                        textTheme,
                        activityCtrl.monthlyStepHistory,
                      )
                    : _buildSessionView(textTheme, activityCtrl.workoutHistory),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: AppColors.brandAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'ប្រវត្តិសកម្មភាព',

          style: textTheme.titleLarge?.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('ប្រចាំថ្ងៃ', 0)),

          Expanded(child: _buildTabButton('ការហាត់ប្រាណ', 1)),

        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.mutedText,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- DAILY VIEW (Uses DailyStepRecord) ---

  Widget _buildDailyView(TextTheme textTheme, List<dynamic> monthlyData) {
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text(
          'មិនទាន់មានទិន្នន័យ (No data yet)',
          style: TextStyle(color: AppColors.mutedText),
        ),
      );
    }

    // Find the data for the selected day, default to the most recent if not found
    final selectedDayData = monthlyData.firstWhere(
      (record) => record.date.day == _selectedDay,
      orElse: () => monthlyData.first,
    );

    // Ensure the selected day matches the fallback if we had to use it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDay != selectedDayData.date.day) {
        setState(() => _selectedDay = selectedDayData.date.day);
      }
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthChart(textTheme, monthlyData),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'សេចក្តីសង្ខេប ថ្ងៃទី $_selectedDay',

                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildDailySummaryCard(selectedDayData, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChart(TextTheme textTheme, List<dynamic> data) {
    // Calculate average steps
    final avgSteps =
        data.fold<num>(0, (sum, record) => sum + record.steps) ~/ data.length;

    // Firebase usually fetches descending (newest first).
    // We reverse it so the chart reads left-to-right (oldest to newest).
    final chartData = data.reversed.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'មធ្យមប្រចាំខែ',

                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$avgSteps',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'ជំហាន',
                          style: TextStyle(
                            color: AppColors.brandAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.brandAccent,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: chartData.length,
              itemBuilder: (context, i) {
                final record = chartData[i];
                final double percentage =
                    record.progress;

                final bool reachedGoal = record.isGoalReached;
                final bool isSelected = record.date.day == _selectedDay;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = record.date.day),
                  child: Container(
                    width: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandAccent.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.brandAccent.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            )
                          : Border.all(color: Colors.transparent, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isSelected)
                          Text(
                            '${(record.steps / 1000).toStringAsFixed(1)}k',
                            style: const TextStyle(
                              color: AppColors.brandAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 16,
                              height: 100,

                              decoration: BoxDecoration(
                                color: AppColors.scaffoldSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              width: 16,
                              height: 100 * percentage,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: reachedGoal
                                      ? [
                                          AppColors.progressValue,
                                          AppColors.progressValue.withValues(
                                            alpha: 0.7,
                                          ),
                                        ]
                                      : [
                                          AppColors.brandAccent,
                                          AppColors.primaryGradientStart,
                                        ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              (reachedGoal
                                                      ? AppColors.progressValue
                                                      : AppColors.brandAccent)
                                                  .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          record.date.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.brandAccent
                                : AppColors.mutedText,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(dynamic record, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:
                (record.isGoalReached
                        ? AppColors.progressValue
                        : AppColors.brandAccent)
                    .withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color:
              (record.isGoalReached
                      ? AppColors.progressValue
                      : AppColors.brandAccent)
                  .withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: record.isGoalReached
                      ? AppColors.progressChip
                      : AppColors.scaffoldSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      record.isGoalReached
                          ? Icons.emoji_events_rounded
                          : Icons.directions_walk_rounded,
                      color: record.isGoalReached
                          ? AppColors.progressChipText
                          : AppColors.mutedText,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.isGoalReached
                          ? 'សម្រេចគោលដៅ'
                          : 'កំពុងដំណើរការ',

                      style: TextStyle(
                        color: record.isGoalReached
                            ? AppColors.progressChipText
                            : AppColors.mutedText,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'គោលដៅ: ${record.target}',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Big Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: record.progress,
                  strokeWidth: 12,
                  backgroundColor: AppColors.scaffoldSoft,
                  color: record.isGoalReached
                      ? AppColors.progressValue
                      : AppColors.brandAccent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.do_not_step_rounded,
                    color: record.isGoalReached
                        ? AppColors.progressValue
                        : AppColors.brandAccent,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.steps}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Bottom Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.scaffoldSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCardMiniStat(
                  Icons.local_fire_department_rounded,
                  const Color(0xFFD45529),
                  record.calories.toStringAsFixed(0),
                  'KCAL',
                ),
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.progressTrack.withValues(alpha: 0.5),
                ),
                _buildCardMiniStat(
                  Icons.route_rounded,
                  const Color(0xFF2980B9),
                  record.distance.toStringAsFixed(2),
                  'KM',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMiniStat(
    IconData icon,
    Color color,
    String value,
    String unit,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- SESSION VIEW (Uses WorkoutSession) ---

  Widget _buildSessionView(TextTheme textTheme, List<dynamic> sessions) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'មិនទាន់មានទិន្នន័យហាត់ប្រាណ (No workouts yet)',
          style: TextStyle(color: AppColors.mutedText),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StepWorkoutDetailPage(
                    session: session,
                  ),

                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkText.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: AppColors.brandAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.title,
                            style: const TextStyle(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${session.steps}',
                        style: const TextStyle(
                          color: AppColors.brandAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDateTime(
                      session.startTime,
                    ),

                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.scaffoldSoft, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSessionMiniStat(
                        Icons.schedule_rounded,
                        session.formattedDuration,

                        'នាទី',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.scaffoldSoft,
                      ),
                      _buildSessionMiniStat(
                        Icons.local_fire_department_rounded,
                        session.calories.toStringAsFixed(0),
                        'KCAL',
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

  Widget _buildSessionMiniStat(IconData icon, String value, String unit) {
    return Row(
      children: [
        Icon(icon, color: AppColors.mutedText, size: 16),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
        ),
      ],
    );
  }
}
