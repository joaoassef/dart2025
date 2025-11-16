import 'package:geolocator/geolocator.dart';

class ContLocalizacao {
  double latitude = 0.0;
  double longitude = 0.0;

  Future<void> mostraLaLo() async {
    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('ALGO ERRADO ACONTECEU');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error(
        'ALGO ERRADO ACONTECEU',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    latitude = position.latitude;
    longitude = position.longitude;
  }
}
