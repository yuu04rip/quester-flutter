// lib/utils/string_utils.dart

/// Utility per la manipolazione delle stringhe.
/// Equivalente a StringUtils in Kotlin.
class StringUtils {
  StringUtils._(); // Costruttore privato

  /// Capitalizza la prima lettera di ogni parola
  /// Es: "ciao mondo" → "Ciao Mondo"
  static String capitalizeWords(String text) {
    if (text.trim().isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }

  /// Capitalizza solo la prima lettera della frase
  /// Es: "ciao mondo" → "Ciao mondo"
  static String capitalizeFirstLetter(String text) {
    if (text.trim().isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalizza la prima lettera di ogni parola e mantiene il resto minuscolo
  /// Es: "ciaO MOnDo" → "Ciao Mondo"
  static String capitalizeWordsProper(String text) {
    if (text.trim().isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
  }

  /// Capitalizza la prima lettera e mantiene il resto minuscolo
  /// Es: "cIaO" → "Ciao"
  static String capitalizeFirstLetterProper(String text) {
    if (text.trim().isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}