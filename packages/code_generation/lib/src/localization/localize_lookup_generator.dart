import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import '../../string_extension.dart';

part 'localize_helper_class_generator_mixin.dart';

enum SupportedLanguages {
  de,
  es,
  ko,
  en, //English must remain last option per i69n translations
}

class LocalizeLookupGenerator {
  final ClassElement element;
  final ConstantReader annotations;

  final _generated = StringBuffer();

  LocalizeLookupGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.ENUM);

  String get i69nKey => annotations.read('i69nKey').stringValue;
  String get helperClassName => annotations.read('helperClassName').stringValue;
  bool get generateHelperClass => annotations.read('generateHelperClass').boolValue;

  String generate() {
    _generateHelperClass();
    _generateLocalization();
    return _generated.toString();
  }

  void _generateLocalization() {
    _generateExtensionHeader();

    /// Skip first two elements ('index' and 'values'), and start with actual enum-properties
    element.fields.skip(2).forEach(_generateCase);
    _generateLookupFooter();
    _generateByLanguageCode();
    _generateByLocale();
    _generateText();
    _generated.writeln('}');
  }

  void _generateByLanguageCode() {
    _generated.writeln('');
    _generated.writeln('  String byLanguageCode(String code) {');
    _generated.writeln('    switch(code) {');
    for (SupportedLanguages lng in SupportedLanguages.values) {
      _generated.writeln('      case \'${lng.name}\':');
      if (lng.name != 'en') {
        _generated.writeln('        return _lookup(this, Local_${lng.name}().$i69nKey);');
      } else {
        _generated.writeln('      default:');
        _generated.writeln('        return _lookup(this, Local().$i69nKey);');
      }
    }
    _generated.writeln('    }');
    _generated.writeln('  }');
    _generated.writeln('');
  }

  void _generateByLocale() {
    _generated.writeln('');
    _generated.writeln('  String byLocale(Locale locale) => byLanguageCode(locale.languageCode);');
    _generated.writeln('');
  }

  /// For each enum property this is called to generate the 'case: return .....;' statements
  void _generateCase(FieldElement e) {
    var name = e.name;
    _generated.writeln('case ${element.name}.$name:');
    _generated.writeln('  return $i69nKey.$name;');
  }

  /// Top of the code
  void _generateExtensionHeader() {
    _generated.writeln('//NOTE: ${element.name} look-up and translation for ${i69nKey.capitalize()}');
    _generated.writeln('extension ${element.name}Lookup on ${element.name}{');
    _generated.writeln('  String _lookup(${element.name} key, ${i69nKey.capitalize()}Local $i69nKey) {');
    _generated.writeln('    switch (key) {');
  }

  /// Close the generated code with close '}'
  void _generateLookupFooter() {
    _generated.writeln('    }');
    _generated.writeln('  }');
  }

  void _generateText() {
    _generated.writeln('');
    _generated.writeln('  String get text => byLocale(${helperClassName}.locale);');
    _generated.writeln('');
  }
}
