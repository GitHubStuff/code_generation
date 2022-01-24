import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class HiveCodeGenerator {
  final ClassElement element;
  final ConstantReader annotations;

  final _generated = StringBuffer();

  HiveCodeGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.CLASS);

  String get name => element.name;
  String get prefix => annotations.peek('prefix') == null ? 'YYY' : annotations.read('prefix').stringValue;
  String get enumName => annotations.peek('enumName') == null ? '' : annotations.read('enumName').stringValue;

  String generate() {
    _generated.writeln('// ignore_for_file: lines_longer_than_80_chars');
    _generateHive();
    return _generated.toString();
  }

  void _generateHive() {
    _generated.writeln('//MARK: Hive');
    // _generated.writeln('bool _isLocaleHiveSetup = false;');
    // _generated.writeln('class ${prefix}HiveManager {');
    // _generated.writeln("  static const _boxName = 'com.${enumName.toLowerCase()}.hive.saved_locale.language_code';");
    // _generated.writeln('  static Box? _box;');
    // _generated.writeln('  static Future<void> setup() async {');
    // _generated.writeln('    try {');
    // _generated.writeln('      await Hive.initFlutter();');
    // _generated.writeln('      _box = await Hive.openBox<String>(_boxName);');
    // _generated.writeln('    } on NullThrownError {');
    // _generated.writeln('    } on MissingPluginException {');
    // _generated.writeln('    } catch (e) {');
    // _generated.writeln('      throw FlutterError(e.toString());');
    // _generated.writeln('    }');
    // _generated.writeln('    _isLocaleHiveSetup = true;');
    // _generated.writeln('  }');
    // _generated.writeln('');
    // _generated.writeln('  static Locale _save({required Locale locale}) {');
    // _generated.writeln("    if (!_isLocaleHiveSetup) throw FlutterError('${prefix}LocalizationCubit.setupLocalization not called!');");
    // _generated.writeln('    final String languageCode = locale.languageCode;');
    // _generated.writeln('    _box?.put(_boxName, languageCode);');
    // _generated.writeln('    return Locale(languageCode);');
    // _generated.writeln('  }');
    // _generated.writeln('');
    // _generated.writeln('  static Locale _get() {');
    // _generated.writeln("    if (!_isLocaleHiveSetup) throw FlutterError('${prefix}LocalizationCubit.setupLocalization not called!');");
    // _generated.writeln("    String storedValue = _box?.get(_boxName, defaultValue: 'en'); // 'en' - english");
    // _generated.writeln('    return Locale(storedValue);');
    // _generated.writeln('  }');
    // _generated.writeln('}');
  }
}
