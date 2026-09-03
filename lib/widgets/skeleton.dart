import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors
            .white,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        shape: shape,
      ),
    );
  }
}

class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  const ShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey[300]!,
      highlightColor: isDark ? const Color(0xFF3A3A3C) : Colors.grey[100]!,
      child: child,
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(width: 150, height: 28),
          const SizedBox(height: 8),
          const Skeleton(width: 100, height: 16),
          const SizedBox(height: 24),

          const Skeleton(width: double.infinity, height: 250, borderRadius: 24),
          const SizedBox(height: 16),

          const Skeleton(width: double.infinity, height: 80, borderRadius: 16),
          const SizedBox(height: 16),

          const Skeleton(width: double.infinity, height: 56, borderRadius: 16),
          const SizedBox(height: 16),

          Row(
            children: const [
              Expanded(child: Skeleton(height: 120, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: Skeleton(height: 120, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),

          const Skeleton(width: 120, height: 20),
          const SizedBox(height: 12),

          const Skeleton(width: double.infinity, height: 80, borderRadius: 16),
          const SizedBox(height: 8),
          const Skeleton(width: double.infinity, height: 80, borderRadius: 16),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int itemCount;
  const ListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: const Skeleton(
            width: double.infinity,
            height: 80,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Skeleton(width: double.infinity, height: 110, borderRadius: 24),
          const SizedBox(height: 32),

          const Skeleton(width: 100, height: 24),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 110, borderRadius: 24),

          const SizedBox(height: 24),

          const Skeleton(width: 120, height: 24),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 220, borderRadius: 24),

          const SizedBox(height: 40),
          const Center(child: Skeleton(width: 100, height: 24)),
        ],
      ),
    );
  }
}

class HistoryDailySkeleton extends StatelessWidget {
  const HistoryDailySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(width: double.infinity, height: 250, borderRadius: 24),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(width: 150, height: 24),
              Skeleton(width: 24, height: 24, shape: BoxShape.circle),
            ],
          ),
          const SizedBox(height: 16),

          const Skeleton(width: double.infinity, height: 160, borderRadius: 28),
          const SizedBox(height: 24),

          const Skeleton(width: 140, height: 20),
          const SizedBox(height: 16),

          const Skeleton(width: double.infinity, height: 70, borderRadius: 16),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 70, borderRadius: 16),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 70, borderRadius: 16),
        ],
      ),
    );
  }
}
