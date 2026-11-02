import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

class SummaryRow {
  const SummaryRow(this.label, this.value);

  final String label;
  final String value;
}

/// Kartu ringkasan biaya: subtotal, pajak, biaya layanan, lalu total.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.rows,
    required this.totalLabel,
    required this.totalValue,
    this.title = 'Ringkasan Pesanan',
    this.titleFontSize = 15.5,
    this.labelFontSize = 13.5,
    this.totalFontSize = 18,
    this.padding = const EdgeInsets.all(16),
    this.radius = 12,
  });

  final List<SummaryRow> rows;
  final String title;
  final String totalLabel;
  final String totalValue;
  final double titleFontSize;
  final double labelFontSize;
  final double totalFontSize;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      radius: radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _row(rows[i]),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: TextStyle(
                  fontSize: totalFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                totalValue,
                style: TextStyle(
                  fontSize: totalFontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.espresso,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(SummaryRow row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          row.label,
          style: TextStyle(fontSize: labelFontSize, color: AppColors.bark),
        ),
        Text(
          row.value,
          style: TextStyle(fontSize: labelFontSize, color: AppColors.bark),
        ),
      ],
    );
  }
}
