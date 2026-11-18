import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import 'pickup_map_view.dart';

/// Kartu peta titik pengambilan: peta nyata yang bisa digeser, atau keterangan bila titiknya belum diatur.
class PickupMapCard extends StatelessWidget {
  const PickupMapCard({
    super.key,
    required this.routeGuide,
    required this.onOpenMaps,
    this.latitude,
    this.longitude,
  });

  final String routeGuide;

  /// Koordinat titik pengambilan; keduanya null bila admin belum mengisinya.
  final double? latitude;
  final double? longitude;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, size: 9, color: Color(0xFF1DB87A)),
                  SizedBox(width: 8),
                  Text(
                    'Peta Titik Pengambilan',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onOpenMaps,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EBE0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE6D3C0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Buka di Google Maps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 12,
                        color: AppColors.textDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (latitude != null && longitude != null)
            PickupMapView(latitude: latitude!, longitude: longitude!)
          else
            const _MapUnavailable(),
          if (routeGuide.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF4EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECE0D2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2E2D4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    size: 17,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patokan Rute Pengambilan:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        routeGuide,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.bark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Buka Penunjuk Arah (Navigasi Maps)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pengganti peta bila admin belum mengisi koordinat titik pengambilan.
class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE0D2)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 26, color: AppColors.bark),
          SizedBox(height: 8),
          Text(
            'Titik lokasi belum ditandai di peta. '
            'Gunakan tombol di bawah untuk membuka Google Maps.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.bark),
          ),
        ],
      ),
    );
  }
}
