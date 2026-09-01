import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';
import 'package:step_detector/data/controller/activity_controller.dart';
import 'package:step_detector/data/controller/profile_controller.dart';
import 'package:step_detector/data/controller/settings_controller.dart';
import 'package:step_detector/data/models/daily_step_record.dart';
import 'package:step_detector/data/models/workout_session.dart';
import 'package:step_detector/modules/workout/step_workout_detail_page.dart';
import 'package:step_detector/widgets/share_image_dialog.dart';
import 'package:step_detector/widgets/skeleton.dart';

class StepHistoryPage extends StatefulWidget {
  const StepHistoryPage({super.key});

  @override
  State<StepHistoryPage> createState() => _StepHistoryPageState();
}

class _StepHistoryPageState extends State<StepHistoryPage> {
  int _selectedTabIndex = 0;

  int _selectedDay = DateTime.now().day;

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year}, $hour:$min $ampm';
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WorkoutSession session,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeColors.getSurface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'deleteWorkout'.tr(context),
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'confirmDeleteWorkout'.tr(context),
            style: TextStyle(color: ThemeColors.getMutedText(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel'.tr(context),
                style: TextStyle(
                  color: ThemeColors.getMutedText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ActivityController>().deleteWorkoutSession(
                  session.id,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'delete'.tr(context),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    final activityCtrl = context.read<ActivityController>();
    final profileCtrl = context.read<ProfileController>();
    final settingsCtrl = context.read<SettingsController>();

    if (activityCtrl.isFetching) return;

    activityCtrl.setFetching(true);
    
    await Future.wait([
      profileCtrl.fetchProfile(),
      settingsCtrl.fetchSettings(),
      activityCtrl.fetchTodayRecord(dailyGoal: settingsCtrl.settings.dailyStepGoal),
      activityCtrl.fetchWorkoutHistory(),
      activityCtrl.fetchMonthlyStepHistory(),
    ]);

    activityCtrl.setFetching(false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final activityCtrl = context.watch<ActivityController>();

    return Scaffold(
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
            SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                color: ThemeColors.getBrandAccent(context),
                backgroundColor: ThemeColors.getSurface(context),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: activityCtrl.isFetching
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _selectedTabIndex == 0 
                                  ? const HistoryDailySkeleton()
                                  : const ListSkeleton(),
                            ),
                          ],
                        )
                      : _selectedTabIndex == 0
                      ? _buildDailyView(
                          textTheme,
                          activityCtrl.monthlyStepHistory,
                        )
                      : _buildSessionView(textTheme, activityCtrl.workoutHistory),
                ),
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
            color: ThemeColors.getBrandAccent(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.history_rounded,
            color: ThemeColors.getBrandAccent(context),
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'activityHistory'.tr(context),
          style: textTheme.titleLarge?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getText(context).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('daily'.tr(context), 0)),

          Expanded(child: _buildTabButton('workout'.tr(context), 1)),
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
          color: isSelected
              ? ThemeColors.getBrandAccent(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ThemeColors.getBrandAccent(
                      context,
                    ).withValues(alpha: 0.3),
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
            color: isSelected
                ? Colors.white
                : ThemeColors.getMutedText(context),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDailyView(
    TextTheme textTheme,
    List<DailyStepRecord> monthlyData,
  ) {
    if (monthlyData.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          SizedBox(height: 100),
          Center(
            child: Text(
              'noDataYet'.tr(context),
              style: TextStyle(color: ThemeColors.getMutedText(context)),
            ),
          ),
        ],
      );
    }

    final selectedDayData = monthlyData.firstWhere(
      (record) => record.date.day == _selectedDay,
      orElse: () => monthlyData.first,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDay != selectedDayData.date.day) {
        setState(() => _selectedDay = selectedDayData.date.day);
      }
    });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthChart(textTheme, monthlyData),
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ThemeColors.getBrandAccent(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${'summaryFor'.tr(context)} $_selectedDay',
                      style: textTheme.titleMedium?.copyWith(
                        color: ThemeColors.getText(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ShareDailySummaryDialog(
                        record: selectedDayData,
                        stepGoal: context
                            .read<SettingsController>()
                            .settings
                            .dailyStepGoal,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    color: ThemeColors.getBrandAccent(context),
                  ),
                  tooltip: 'saveImage'.tr(context),
                  style: IconButton.styleFrom(
                    backgroundColor: ThemeColors.getBrandAccent(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildDailySummaryCard(selectedDayData, textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChart(TextTheme textTheme, List<DailyStepRecord> data) {
    final goal = context.read<SettingsController>().settings.dailyStepGoal;
    final avgSteps =
        data.fold<num>(0, (sum, record) => sum + record.steps) ~/ data.length;

    final chartData = data.reversed.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getText(context).withValues(alpha: 0.05),
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
                    'monthlyAvg'.tr(context),
                    style: textTheme.titleSmall?.copyWith(
                      color: ThemeColors.getMutedText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$avgSteps',
                        style: textTheme.headlineMedium?.copyWith(
                          color: ThemeColors.getText(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4),
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'steps'.tr(context),
                          style: TextStyle(
                            color: ThemeColors.getBrandAccent(context),
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
                  color: ThemeColors.getScaffoldSoft(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: ThemeColors.getBrandAccent(context),
                  size: 28,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: chartData.length,
              itemBuilder: (context, i) {
                final record = chartData[i];
                final double percentage = record.getProgress(goal);

                final bool reachedGoal = record.isGoalReached(goal);
                final bool isSelected = record.date.day == _selectedDay;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = record.date.day),
                  child: Container(
                    width: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ThemeColors.getBrandAccent(
                              context,
                            ).withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: ThemeColors.getBrandAccent(
                                context,
                              ).withValues(alpha: 0.3),
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
                            style: TextStyle(
                              color: ThemeColors.getBrandAccent(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 16,
                              height: 100,

                              decoration: BoxDecoration(
                                color: ThemeColors.getScaffoldSoft(context),
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
                                          ThemeColors.getProgressValue(context),
                                          ThemeColors.getProgressValue(
                                            context,
                                          ).withValues(alpha: 0.7),
                                        ]
                                      : [
                                          ThemeColors.getBrandAccent(context),
                                          ThemeColors.getPrimaryGradientStart(
                                            context,
                                          ),
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
                                                      ? ThemeColors.getProgressValue(
                                                          context,
                                                        )
                                                      : ThemeColors.getBrandAccent(
                                                          context,
                                                        ))
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
                        SizedBox(height: 12),
                        Text(
                          record.date.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? ThemeColors.getBrandAccent(context)
                                : ThemeColors.getMutedText(context),
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
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

  Widget _buildDailySummaryCard(DailyStepRecord record, TextTheme textTheme) {
    final goal = context.read<SettingsController>().settings.dailyStepGoal;
    final now = DateTime.now();
    final isToday =
        record.date.year == now.year &&
        record.date.month == now.month &&
        record.date.day == now.day;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:
                (record.isGoalReached(goal)
                        ? ThemeColors.getProgressValue(context)
                        : ThemeColors.getBrandAccent(context))
                    .withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color:
              (record.isGoalReached(goal)
                      ? ThemeColors.getProgressValue(context)
                      : ThemeColors.getBrandAccent(context))
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
                  color: record.isGoalReached(goal)
                      ? ThemeColors.getProgressChip(context)
                      : ThemeColors.getScaffoldSoft(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      record.isGoalReached(goal)
                          ? Icons.emoji_events_rounded
                          : isToday
                          ? Icons.directions_walk_rounded
                          : Icons.close_rounded,
                      color: record.isGoalReached(goal)
                          ? ThemeColors.getProgressChipText(context)
                          : isToday
                          ? ThemeColors.getMutedText(context)
                          : Colors.redAccent,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      record.isGoalReached(goal)
                          ? 'goalReachedShort'.tr(context)
                          : isToday
                          ? 'inProgress'.tr(context)
                          : 'failed'.tr(context),
                      style: TextStyle(
                        color: record.isGoalReached(goal)
                            ? ThemeColors.getProgressChipText(context)
                            : isToday
                            ? ThemeColors.getMutedText(context)
                            : Colors.redAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${'stepGoal'.tr(context)}: $goal',
                style: TextStyle(
                  color: ThemeColors.getMutedText(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: record.getProgress(goal),
                  strokeWidth: 12,
                  backgroundColor: ThemeColors.getScaffoldSoft(context),
                  color: record.isGoalReached(goal)
                      ? ThemeColors.getProgressValue(context)
                      : ThemeColors.getBrandAccent(context),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.directions_run_rounded,
                    color: record.isGoalReached(goal)
                        ? ThemeColors.getProgressValue(context)
                        : ThemeColors.getBrandAccent(context),
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${record.steps}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.getScaffoldSoft(context),
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
                  color: ThemeColors.getProgressTrack(
                    context,
                  ).withValues(alpha: 0.5),
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

          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/Movexa.png', width: 20, height: 20),
              SizedBox(width: 8),
              Text(
                'Movexa',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
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
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: ThemeColors.getMutedText(context),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionView(TextTheme textTheme, List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          SizedBox(height: 100),
          Center(
            child: Text(
              'noDataYet'.tr(context),
              style: TextStyle(color: ThemeColors.getMutedText(context)),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                  builder: (context) => StepWorkoutDetailPage(session: session),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColors.getSurface(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.getText(context).withValues(alpha: 0.03),
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
                          Icon(
                            Icons.route_rounded,
                            color: ThemeColors.getBrandAccent(context),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${session.distance.toStringAsFixed(2)} KM',
                            style: TextStyle(
                              color: ThemeColors.getText(context),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${session.steps}',
                            style: TextStyle(
                              color: ThemeColors.getBrandAccent(context),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, session);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    _formatDateTime(session.startTime),

                    style: TextStyle(
                      color: ThemeColors.getMutedText(context),
                      fontSize: 13,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: ThemeColors.getScaffoldSoft(context),
                      height: 1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSessionMiniStat(
                        Icons.schedule_rounded,
                        session.formattedDuration,

                        'minutes'.tr(context),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: ThemeColors.getScaffoldSoft(context),
                      ),
                      _buildSessionMiniStat(
                        Icons.local_fire_department_rounded,
                        session.calories.toStringAsFixed(0),
                        'KCAL',
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: ThemeColors.getScaffoldSoft(context),
                      ),
                      _buildSessionMiniStat(
                        Icons.speed_rounded,
                        session.speedKmh.toStringAsFixed(1),
                        'KM/H',
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
        Icon(icon, color: ThemeColors.getMutedText(context), size: 16),
        SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4),
        Text(
          unit,
          style: TextStyle(
            color: ThemeColors.getMutedText(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
