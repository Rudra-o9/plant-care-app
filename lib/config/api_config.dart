/// Runtime configuration for remote APIs.
///
/// PlantNet key: https://my.plantnet.org
/// Gemini key:   https://aistudio.google.com/apikey  (free, instant)
class ApiConfig {
  const ApiConfig._();

  static const plantNetApiKey = String.fromEnvironment(
    'PLANTNET_API_KEY',
    defaultValue: '2b10cTs9AMgOZIxdpaVfOxFJMe',
  );
  static const plantNetIdentificationUrl =
      'https://my-api.plantnet.org/v2/identify/all';
  static const plantNetLanguage = 'en';

  /// Get your free Gemini key at https://aistudio.google.com/apikey
  /// Then paste it here OR pass via:
  ///   flutter run --dart-define=GEMINI_API_KEY=your_key
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}
