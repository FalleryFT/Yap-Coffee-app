import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';

class PickupDate {
  final String day;
  final String date;
  final String month;

  const PickupDate(this.day, this.date, this.month);
}

class PickupWindow {
  final String time;
  final String batch;

  const PickupWindow(this.time, this.batch);
}

/// Kartu jadwal pre-order: pilih tanggal, jam pengambilan, dan titik temu.
class PickupScheduleCard extends StatelessWidget {
  const PickupScheduleCard({
    super.key,
    required this.dates,
    required this.windows,
    required this.selectedDate,
    required this.selectedWindow,
    required this.onDateSelected,
    required this.onWindowSelected,
    this.location = '',
    this.area = '',
  });

  /// Titik temu dan keterangan area dari jadwal yang dipilih.
  final String location;
  final String area;

  final List<PickupDate> dates;
  final List<PickupWindow> windows;
  final int selectedDate;
  final int selectedWindow;
  final ValueChanged<int> onDateSelected;
  final ValueChanged<int> onWindowSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Pengambilan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pilih Tanggal Pre-Order',
            style: TextStyle(fontSize: 12.5, color: AppColors.bark),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _dateChip(index),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Jam Pengambilan (Pickup Window)',
            style: TextStyle(fontSize: 12.5, color: AppColors.bark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < windows.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _windowChip(i)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.cardLine),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.espresso,
              ),
              SizedBox(width: 8),
              Text(
                'TITIK TEMU PENGAMBILAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.espresso,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            location,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 16, color: AppColors.bark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  area,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.bark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateChip(int index) {
    final data = dates[index];
    final selected = index == selectedDate;

    return GestureDetector(
      onTap: () => onDateSelected(index),
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          color: selected ? AppColors.espresso : AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.espresso : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.day,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.buttonPeach : AppColors.bark,
              ),
            ),
            Text(
              data.date,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.15,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
            Text(
              data.month,
              style: TextStyle(
                fontSize: 10.5,
                color: selected ? AppColors.buttonPeach : AppColors.mocha,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _windowChip(int index) {
    final data = windows[index];
    final selected = index == selectedWindow;

    return GestureDetector(
      onTap: () => onWindowSelected(index),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.espresso : AppColors.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.espresso : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.batch,
              style: TextStyle(
                fontSize: 10.5,
                color: selected ? AppColors.buttonPeach : AppColors.mocha,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
