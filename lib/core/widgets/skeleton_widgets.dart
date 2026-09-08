import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// A shimmer-animated skeleton block
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for a KPI card row (5 cards)
class SkeletonKpiRow extends StatelessWidget {
  const SkeletonKpiRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
            5,
            (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Shimmer.fromColors(
                      baseColor: AppColors.card,
                      highlightColor: AppColors.border,
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                )),
      ),
    );
  }
}

/// Skeleton for a list item card (used in IMMEX, notifications, etc.)
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.border,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
                const Spacer(),
                Container(
                    width: 70,
                    height: 24,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const Spacer(),
            Container(
                height: 8,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4))),
                const Spacer(),
                Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full skeleton for the IMMEX/list screens
class SkeletonListScreen extends StatelessWidget {
  final bool showKpis;
  const SkeletonListScreen({super.key, this.showKpis = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showKpis) const SkeletonKpiRow(),
        const SizedBox(height: 8),
        // Search bar skeleton
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SkeletonBox(height: 44),
        ),
        // Cards
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: const [
              SkeletonCard(),
              SkeletonCard(),
              SkeletonCard(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton for the home screen dashboard
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.border,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 200,
                height: 24,
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 8),
            Container(
                width: 140,
                height: 14,
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12)))),
              ],
            ),
            const SizedBox(height: 20),
            Container(
                height: 160,
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            Container(
                height: 80,
                decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12))),
          ],
        ),
      ),
    );
  }
}
