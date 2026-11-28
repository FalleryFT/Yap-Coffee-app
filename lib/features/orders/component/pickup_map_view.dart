import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';

/// Peta nyata titik pengambilan (OpenStreetMap) yang bisa digeser dan diperbesar.
/// Titik diatur admin di web pada jadwal pre-order.
class PickupMapView extends StatefulWidget {
  const PickupMapView({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  State<PickupMapView> createState() => _PickupMapViewState();
}

class _PickupMapViewState extends State<PickupMapView> {
  static const double _zoom = 17;

  /// Peta mengikuti lebar kartu (bukan tinggi tetap) agar tidak melar/terjepit
  /// saat jendela diubah ukurannya.
  static const double _aspectRatio = 4 / 3;

  final MapController _controller = MapController();

  LatLng get _point => LatLng(widget.latitude, widget.longitude);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: _point,
                initialZoom: _zoom,
                minZoom: 3,
                maxZoom: 19,
                // Geser dan cubit boleh; memutar peta tidak diperlukan.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Wajib diisi menurut kebijakan OpenStreetMap; samakan dengan applicationId aplikasi.
                  userAgentPackageName: 'com.yapcoffee.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _point,
                      width: 48,
                      height: 48,
                      // Ujung pin tepat di koordinat, bukan tengah ikon.
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 44,
                        color: Color(0xFFD93025),
                      ),
                    ),
                  ],
                ),
                const _MapAttribution(),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.white,
                elevation: 2,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _controller.move(_point, _zoom),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.my_location_rounded,
                      size: 20,
                      color: AppColors.espresso,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              // Sisi kanan disisakan untuk tombol lokasi supaya teks tidak
              // menabraknya dan tidak meluber keluar peta.
              right: 58,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Geser dan cubit untuk melihat sekitar',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: AppColors.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Atribusi wajib OpenStreetMap.
///
/// SimpleAttributionWidget bawaan flutter_map menyusun teksnya dalam Row tanpa
/// Flexible, sehingga meluber saat font diperbesar. Satu blok teks di bawah
/// bisa dipotong dengan ellipsis dan tetap terlihat.
class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Text(
            '© OpenStreetMap contributors',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textDark),
          ),
        ),
      ),
    );
  }
}
