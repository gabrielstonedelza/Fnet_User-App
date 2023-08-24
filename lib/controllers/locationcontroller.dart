import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  String locationName = "";

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchLocation();
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

      locationName = placemarks[3].name!;
      update();
    } else {
      locationName = "Permission denied";
    }
  }
}
