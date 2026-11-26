import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_providers.dart';
import '../../discover/application/location_controller.dart';
import '../../discover/data/location_service.dart';
import '../../profile/application/profile_providers.dart';
import '../../sport/domain/sport.dart';
import '../application/match_providers.dart';
import '../domain/entities/geo_point.dart';
import '../domain/entities/match.dart';

const _hcm = LatLng(10.7769, 106.7009);
const _nearMeters = 200;

/// Chủ kèo thêm sân chưa có trong danh sách. Trả về sân vừa thêm, hoặc sân có sẵn nếu chọn từ cảnh báo trùng.
class AddVenueScreen extends ConsumerStatefulWidget {
  const AddVenueScreen({super.key, required this.sport});

  final Sport sport;

  @override
  ConsumerState<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends ConsumerState<AddVenueScreen> {
  final _map = MapController();
  final _name = TextEditingController();
  final _address = TextEditingController();
  late LatLng _center;
  late final Set<String> _sports = {widget.sport.id};
  String? _district;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = ref.read(locationProvider).position;
    _center = p == null ? _hcm : LatLng(p.lat, p.lng);
    _district = ref.read(myProfileProvider).value?.district;
  }

  @override
  void dispose() {
    _map.dispose();
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  bool get _valid {
    final n = _name.text.trim().length, a = _address.text.trim().length;
    return n >= 2 && n <= 60 && a >= 1 && a <= 120 && _district != null && _sports.isNotEmpty;
  }

  void _onMapEvent(MapEvent e) {
    final settled = e is MapEventMoveEnd || e is MapEventFlingAnimationEnd || e is MapEventDoubleTapZoomEnd
        || (e is MapEventMove && e.source == MapEventSource.mapController);
    if (settled) setState(() => _center = e.camera.center);
  }

  Future<void> _myLocation() async {
    final p = await const LocationService().currentPosition();
    if (p == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không lấy được vị trí, hãy bật định vị')));
      }
      return;
    }
    _map.move(LatLng(p.lat, p.lng), 17);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final v = await ref.read(matchRepositoryProvider).addVenue(
            uid: ref.read(authStateProvider).value!.uid,
            name: _name.text.trim(),
            address: _address.text.trim(),
            district: _district!,
            sportIds: Sport.all.map((s) => s.id).where(_sports.contains).toList(),
            geo: GeoPoint(_center.latitude, _center.longitude),
          );
      for (final s in _sports) {
        ref.invalidate(venuesProvider(s));
      }
      if (mounted) Navigator.of(context).pop(v);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không lưu được sân, thử lại');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final here = GeoPoint(_center.latitude, _center.longitude);
    final near = (ref.watch(venuesProvider(widget.sport.id)).value ?? const <VenueOption>[])
        .map((v) => (v, v.geo.distanceTo(here)))
        .where((x) => x.$2 < _nearMeters)
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sân')),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(initialCenter: _center, initialZoom: 16, onMapEvent: _onMapEvent),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'vn.gogoal.app',
                    ),
                    RichAttributionWidget(
                      showFlutterMapAttribution: false,
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap',
                          onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
                        ),
                      ],
                    ),
                  ],
                ),
                // Mũi ghim nằm đúng tâm bản đồ
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 44),
                      child: Icon(Icons.place, size: 48, color: context.colors.primaryDark),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    tooltip: 'Vị trí của tôi',
                    onPressed: _myLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Kéo bản đồ để ghim đúng vị trí sân', style: TextStyle(color: context.colors.muted, fontSize: 13)),
                const SizedBox(height: 12),
                if (near.isNotEmpty) ...[
                  _NearBanner(venue: near.first.$1, meters: near.first.$2, onPick: () => Navigator.of(context).pop(near.first.$1)),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _name,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Tên sân', counterText: ''),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _address,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Địa chỉ', hintText: 'Ví dụ: 12 Phan Văn Trị', counterText: ''),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _district,
                  decoration: const InputDecoration(labelText: 'Quận'),
                  items: [for (final c in districtCodes) DropdownMenuItem(value: c, child: Text(districtName(c)))],
                  onChanged: (c) => setState(() => _district = c),
                ),
                const SizedBox(height: 16),
                const Text('Môn chơi được', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in Sport.all)
                      FilterChip(
                        label: Text(s.displayName),
                        selected: _sports.contains(s.id),
                        // Môn đang tạo kèo luôn được chọn, bấm không bỏ được (null sẽ làm chip xám như bị khóa)
                        onSelected: (on) => setState(() {
                          if (s.id == widget.sport.id) return;
                          on ? _sports.add(s.id) : _sports.remove(s.id);
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: TextStyle(color: context.colors.dangerText, fontWeight: FontWeight.w500)),
              ),
            AppButton(label: _saving ? 'Đang lưu…' : 'Lưu sân', onPressed: _valid && !_saving ? _save : null),
          ],
        ),
      ),
    );
  }
}

class _NearBanner extends StatelessWidget {
  const _NearBanner({required this.venue, required this.meters, required this.onPick});

  final VenueOption venue;
  final double meters;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: context.colors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.warningBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.warningInk, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Gần đây đã có '),
                TextSpan(text: venue.venue.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: ' (${meters.round()} m). Có phải sân này?'),
              ]),
              style: TextStyle(color: context.colors.warningText, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onPick, child: const Text('Chọn sân này')),
        ],
      ),
    );
  }
}
