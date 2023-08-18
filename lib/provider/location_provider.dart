import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_map/ui/map/map_screen_.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../utils/ui_utils/util_function.dart';

class LocationProvider with ChangeNotifier {
  LocationProvider() {
    getLocation();
  }

  LatLng? latLong;

  Future<void> getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    latLong = LatLng(
      locationData.latitude!,
      locationData.longitude!,
    );
    location.onLocationChanged.listen((LocationData newLocation) {
      LatLng latLng = LatLng(newLocation.latitude!, newLocation.longitude!);
      addNewMarker(latLng);
      debugPrint("LONGITUDE:${newLocation.longitude}");
    });

    latLong = LatLng(
      locationData.latitude!,
      locationData.longitude!,
    );

    notifyListeners();
  }

  delate(int id) async {}

  updateLatLong(LatLng newLatLng) {
    latLong = newLatLng;
    notifyListeners();
  }

  addNewMarker(LatLng latLng) async {
    Uint8List uint8list =
        await getBytesFromAsset("assets/images/courier.png", 50);
    markers.add(Marker(
        markerId: MarkerId(
          DateTime.now().toString(),
        ),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(uint8list),
        //BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(
            title: 'Toshkent', snippet: "Falonchi Ko'chasi 45-uy ")));
  }
}
