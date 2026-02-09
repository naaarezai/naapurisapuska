import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Apufunktiot yksityisyyden ja turvallisuuden parantamiseen
class PrivacyHelper {
  /// Anonymisoi käyttäjän nimen näyttämällä vain etunimen ja sukunimen ensimmäisen kirjaimen
  ///
  /// Esimerkit:
  /// - "Matti Meikäläinen" → "Matti M."
  /// - "Anna-Liisa Virtanen-Korhonen" → "Anna-Liisa V."
  /// - "Matti" → "Matti" (vain yksi sana)
  /// - null tai tyhjä → "Tuntematon"
  static String anonymizeName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Tuntematon';
    }

    final parts = fullName.trim().split(' ');

    // Jos vain yksi nimi (ei sukunimeä), palauta sellaisenaan
    if (parts.length == 1) {
      return parts[0];
    }

    // Etunimi + sukunimen ensimmäinen kirjain + piste
    final firstName = parts.first;
    final lastNameInitial = parts.last.isNotEmpty ? parts.last[0] : '';

    return '$firstName ${lastNameInitial.toUpperCase()}.';
  }

  /// Karkistaa koordinaatin haluttuun desimaalitarkkuuteen
  ///
  /// Desimaalitarkkuudet:
  /// - 6 desimaalia ≈ 10cm (VAARALLINEN - näyttää tarkan osoitteen)
  /// - 4 desimaalia ≈ 10m (PAREMPI)
  /// - 3 desimaalia ≈ 100m (HYVÄ - suojaa yksityisyyttä)
  /// - 2 desimaalia ≈ 1km (LIIAN EPÄTARKKA)
  ///
  /// Oletuksena 3 desimaalia (~100m tarkkuus)
  static double obscureCoordinate(double coordinate, {int decimals = 3}) {
    final multiplier = pow(10, decimals).toDouble();
    return (coordinate * multiplier).round() / multiplier;
  }

  /// Karkistaa latitude/longitude parin
  static LatLng obscureLocation(double latitude, double longitude,
      {int decimals = 3}) {
    return LatLng(
      obscureCoordinate(latitude, decimals: decimals),
      obscureCoordinate(longitude, decimals: decimals),
    );
  }

  /// Laskee kuinka paljon koordinaatin karkistus muuttaa tarkkuutta metreinä
  ///
  /// Käyttää karkeaa arviota: 1 aste latitude ≈ 111km
  static double getObscurationRadiusMeters(int decimals) {
    // Yksi desimaali-aste = 111000m / 10^decimals
    return 111000 / pow(10, decimals);
  }
}
