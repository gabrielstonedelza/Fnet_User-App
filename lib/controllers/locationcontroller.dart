import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  String locationName = "";
  String localDistrict = "";

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // fetchLocation();
  }

  Future<void> fetchLocation() async {
    // Request location permissions
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Get the user's current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode the coordinates to get the location name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (kDebugMode) {
        print(localDistrict);
      }

      locationName = placemarks[3].name!;
      localDistrict = placemarks[0].subAdministrativeArea!;
      update();
    } else {
      locationName = "Permission denied";
    }
  }
}
