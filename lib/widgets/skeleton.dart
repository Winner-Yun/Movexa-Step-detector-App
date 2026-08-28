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
            .white, // Color doesn't matter, just needs to be solid for Shimmer
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
          // Greeting
          const Skeleton(width: 150, height: 28),
          const SizedBox(height: 8),
          const Skeleton(width: 100, height: 16),
          const SizedBox(height: 24),

          // Progress Panel
          const Skeleton(width: double.infinity, height: 250, borderRadius: 24),
          const SizedBox(height: 16),

          // Toggle card
          const Skeleton(width: double.infinity, height: 80, borderRadius: 16),
          const SizedBox(height: 16),

          // Button
          const Skeleton(width: double.infinity, height: 56, borderRadius: 16),
          const SizedBox(height: 16),

          // Stats
          Row(
            children: const [
              Expanded(child: Skeleton(height: 120, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: Skeleton(height: 120, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),

          // Recent activities header
          const Skeleton(width: 120, height: 20),
          const SizedBox(height: 12),

          // Activities List
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
        children: [
          const SizedBox(height: 20),
          // Avatar
          const Skeleton(width: 100, height: 100, shape: BoxShape.circle),
          const SizedBox(height: 16),
          // Name
          const Skeleton(width: 150, height: 24),
          const SizedBox(height: 8),
          // Email
          const Skeleton(width: 200, height: 16),
          const SizedBox(height: 32),
          // Info Cards
          const Skeleton(width: double.infinity, height: 100, borderRadius: 16),
          const SizedBox(height: 24),
          // List tiles
          const Skeleton(width: double.infinity, height: 60, borderRadius: 12),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 60, borderRadius: 12),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 60, borderRadius: 12),
        ],
      ),
    );
  }
}
