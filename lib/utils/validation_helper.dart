/// Helper-luokka validointiin
class ValidationHelper {
  /// Validoi puhelinnumeron
  /// Palauttaa null jos validi, muuten virheviestin
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Syötä puhelinnumero';
    }

    // Poista välilyönnit ja erikoismerkit
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.isEmpty) {
      return 'Puhelinnumero ei voi olla tyhjä';
    }

    if (cleanPhone.length < 10) {
      return 'Puhelinnumero on liian lyhyt (vähintään 10 numeroa)';
    }

    if (cleanPhone.length > 15) {
      return 'Puhelinnumero on liian pitkä (enintään 15 numeroa)';
    }

    return null; // Valid
  }

  /// Validoi hinnan
  /// Palauttaa null jos validi, muuten virheviestin
  static String? validatePrice(String? value, bool isFree) {
    if (isFree) {
      return null; // Ilmainen, ei validointia tarvita
    }

    if (value == null || value.trim().isEmpty) {
      return 'Syötä hinta';
    }

    // Yritä muuntaa numeroksi
    final price = double.tryParse(value.replaceAll(',', '.'));

    if (price == null) {
      return 'Hinnan täytyy olla numero';
    }

    if (price < 0) {
      return 'Hinta ei voi olla negatiivinen';
    }

    if (price > 10000) {
      return 'Hinta on liian suuri (enintään 10000€)';
    }

    return null; // Valid
  }

  /// Validoi otsikon
  /// Palauttaa null jos validi, muuten virheviestin
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Syötä otsikko';
    }

    if (value.trim().length < 3) {
      return 'Otsikko on liian lyhyt (vähintään 3 merkkiä)';
    }

    if (value.trim().length > 100) {
      return 'Otsikko on liian pitkä (enintään 100 merkkiä)';
    }

    return null; // Valid
  }

  /// Validoi salasanan
  /// Palauttaa null jos validi, muuten virheviestin
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Syötä salasana';
    }

    if (value.length < 6) {
      return 'Salasana on liian lyhyt (vähintään 6 merkkiä)';
    }

    if (value.length > 128) {
      return 'Salasana on liian pitkä (enintään 128 merkkiä)';
    }

    return null; // Valid
  }

  /// Validoi nimen
  /// Palauttaa null jos validi, muuten virheviestin
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Syötä nimi';
    }

    if (value.trim().length < 2) {
      return 'Nimi on liian lyhyt (vähintään 2 merkkiä)';
    }

    if (value.trim().length > 50) {
      return 'Nimi on liian pitkä (enintään 50 merkkiä)';
    }

    return null; // Valid
  }
}
