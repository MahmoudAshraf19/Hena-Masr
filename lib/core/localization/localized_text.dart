import 'package:flutter/widgets.dart';

/// Multilingual content stored in Firestore / local DB, e.g.
/// { "ar": "أهرامات الجيزة", "en": "Pyramids of Giza" }
@immutable
class LocalizedText {
  const LocalizedText(this._values);

  const LocalizedText.empty() : _values = const {};

  factory LocalizedText.fromJson(Object? json) {
    if (json is Map) {
      return LocalizedText(
        json.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    return const LocalizedText.empty();
  }

  final Map<String, String> _values;

  /// Requested language -> English -> any available -> empty.
  String resolve(Locale locale) =>
      _values[locale.languageCode] ??
      _values['en'] ??
      (_values.values.isEmpty ? '' : _values.values.first);

  String of(BuildContext context) => resolve(Localizations.localeOf(context));

  bool get isEmpty => _values.isEmpty;

  Map<String, String> toJson() => Map.of(_values);
}