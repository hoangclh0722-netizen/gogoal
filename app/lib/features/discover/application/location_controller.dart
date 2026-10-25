import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/domain/entities/geo_point.dart';
import '../data/location_service.dart';

class LocationState {
  const LocationState({this.granted = false, this.position});

  final bool granted;
  final GeoPoint? position;
}

class LocationController extends Notifier<LocationState> {
  final _service = const LocationService();

  @override
  LocationState build() => const LocationState();

  Future<void> request() async {
    final granted = await _service.requestPermission();
    state = LocationState(granted: granted);
    if (granted) {
      final position = await _service.currentPosition();
      state = LocationState(granted: true, position: position);
    }
  }

  Future<void> enable() async {
    await request();
    if (!state.granted) await _service.openSettings();
  }
}

final locationProvider = NotifierProvider<LocationController, LocationState>(LocationController.new);
