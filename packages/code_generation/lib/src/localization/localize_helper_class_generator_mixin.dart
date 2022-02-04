part of 'localize_lookup_generator.dart';

extension LocalizeHelperClassGeneratorMixin on LocalizeLookupGenerator {
  String get cubitName => '${helperClassName}Cubit';
  String get cubitState => '${helperClassName}State';
  String get cubitHiveManager => '${helperClassName}HiveManager';

  void _generateHelperClass() {
    if (generateHelperClass) {
      _generateClass();
    } else {
      _generateExtension();
    }
  }

  void _generateClass() {
    _generated.writeln('// ignore_for_file: lines_longer_than_80_chars');
    _generated.writeln('//! await ${helperClassName}.setup() should be called at App start to persist Locale');
  }

  void _generateExtension() {
    _generated.writeln('// MARK: Extension to $helperClassName for ${i69nKey.capitalize} token');
    _generated.writeln('extension $helperClassName${i69nKey.capitalize} on $helperClassName {');
    _generated.writeln('  static String translate${i69nKey.capitalize}(${this.element.name} token, {Locale? locale}) => token.byLocale(locale ??  ${helperClassName}.locale);');
    _generated.writeln('}');
  }
}
