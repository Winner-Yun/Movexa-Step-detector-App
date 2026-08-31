import 'package:flutter/material.dart';
import 'package:step_detector/core/theme/theme_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.onTap, required this.text});

  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              ThemeColors.getPrimaryGradientStart(context),
              ThemeColors.getPrimaryGradientEnd(context),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_walk_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
