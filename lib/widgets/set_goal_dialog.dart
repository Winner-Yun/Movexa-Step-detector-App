import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';

class SetGoalDialog extends StatefulWidget {
  final int currentGoal;
  final Function(int) onGoalChanged;

  const SetGoalDialog({
    super.key,
    required this.currentGoal,
    required this.onGoalChanged,
  });

  @override
  State<SetGoalDialog> createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends State<SetGoalDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<int> _quickGoals = [5000, 8000, 10000, 15000, 20000];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGoal.toString());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() {
    final newGoal = int.tryParse(_controller.text);
    if (newGoal != null && newGoal > 0) {
      widget.onGoalChanged(newGoal);
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = context.read<AppTranslations>().tr(
          'pleaseEnterValidNumber',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: ThemeColors.getSurface(context),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.getBrandAccent(context).withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: -10,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildQuickPicks(),
                    const SizedBox(height: 24),
                    _buildInput(),
                    const SizedBox(height: 32),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getPrimaryGradientStart(context),
                ThemeColors.getPrimaryGradientEnd(context),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ThemeColors.getBrandAccent(context).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.flag_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          context.read<AppTranslations>().tr('setNewGoal'),
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.read<AppTranslations>().tr('setDailyStepGoal'),
          style: TextStyle(
            color: ThemeColors.getMutedText(context),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPicks() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _quickGoals.map((goal) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _controller.text = goal.toString();
              _errorMessage = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeColors.getScaffoldSoft(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ThemeColors.getBrandAccent(context).withOpacity(0.1),
              ),
            ),
            child: Text(
              goal.toString(),
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInput() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getScaffoldSoft(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _errorMessage != null
              ? Colors.redAccent
              : ThemeColors.getBrandAccent(context).withOpacity(0.1),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        cursorColor: ThemeColors.getBrandAccent(context),
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: ThemeColors.getBrandAccent(context),
        ),
        onChanged: (value) {
          if (_errorMessage != null) {
            setState(() => _errorMessage = null);
          }
        },
        decoration: InputDecoration(
          hintText: '10000',
          hintStyle: TextStyle(
            color: ThemeColors.getBrandAccent(context).withOpacity(0.2),
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 16,
          ),
          errorText: _errorMessage,
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.read<AppTranslations>().tr('cancel'),
              style: TextStyle(
                color: ThemeColors.getMutedText(context),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryGradientStart(context),
                  ThemeColors.getPrimaryGradientEnd(context),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.getBrandAccent(context).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.read<AppTranslations>().tr('save'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
