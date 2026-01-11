/// Helper-luokka käyttäjäystävällisille virheilmoituksille
class ErrorHelper {
  /// Muuntaa teknisen virheen käyttäjäystävälliseksi viestiksi
  static String getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Ei internetyhteyttä. Tarkista verkkoyhteys.';
    } else if (errorString.contains('permission') || 
               errorString.contains('denied')) {
      return 'Käyttöoikeusvirhe. Ota yhteys tukeen.';
    } else if (errorString.contains('timeout')) {
      return 'Toiminto kesti liian kauan. Yritä uudelleen.';
    } else if (errorString.contains('not found')) {
      return 'Tietoja ei löytynyt.';
    } else if (errorString.contains('unavailable')) {
      return 'Palvelu ei ole saatavilla. Yritä myöhemmin.';
    }
    
    return 'Jotain meni pieleen. Yritä uudelleen.';
  }
}
