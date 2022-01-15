import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class LocalizeCubitClassGenerator {
  final ClassElement element;
  final ConstantReader annotations;

  final _generated = StringBuffer();

  LocalizeCubitClassGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.CLASS);

  String get name => element.name;
  String get prefix => annotations.peek('prefix') == null ? 'YYY' : annotations.read('prefix').stringValue;
  String get enumName => annotations.peek('enumName') == null ? '' : annotations.read('enumName').stringValue;

  String generate() {
    _generateHelperClass();
    _generateCubit();
    _generateState();
    _generateHive();
    return _generated.toString();
  }

  void _generateHelperClass() {
    _generated.writeln('MARK: Helper class ${prefix}Language for getting/setting Locale');
    _generated.writeln('//! await ${prefix}Language.setup() should be called at App start to persist');
    _generated.writeln('//! Locale across App restarts.');
    _generated.writeln('class ${prefix}Language {');
    _generated.writeln('  static Future<void> setup({Locale? locale}) => _${enumName}Cubit.setup(locale: locale);');
    _generated.writeln('  static Cubit<${prefix}LocalizationState> get cubit => _${enumName}Cubit.cubit;');
    _generated.writeln('  static Locale get locale => _${enumName}Cubit.locale;');
    _generated.writeln('  static set locale(Locale newLocale) => _${enumName}Cubit.locale = newLocale;');
    _generated.writeln('  static String translate(${enumName} token, {Locale? locale}) => token.byLocale(locale ?? _${enumName}Cubit.locale);');
    _generated.writeln('}');
  }

  void _generateCubit() {
    _generated.writeln('');
    _generated.writeln('//MARK: Cubit');
    _generated.writeln('class _${enumName}Cubit extends Cubit<${prefix}LocalizationState> {');
    _generated.writeln('  static final _${enumName}Cubit _singleton = _${enumName}Cubit._internal();');
    _generated.writeln('  factory _${enumName}Cubit() => _singleton;');
    _generated.writeln('  _${enumName}Cubit._internal() : super(${prefix}LocaleInitial());');
    _generated.writeln('  static _${enumName}Cubit _localizationCubit = _${enumName}Cubit();');
    _generated.writeln('  static _${enumName}Cubit get cubit => _localizationCubit;');
    _generated.writeln('');
    _generated.writeln('  bool _usingHiveStore = false;');
    _generated.writeln('');
    _generated.writeln('  static Future<void> setup({Locale? locale}) async {');
    _generated.writeln('    _localizationCubit._locale = locale;');
    _generated.writeln('    _localizationCubit._usingHiveStore = (locale == null);');
    _generated.writeln('    if (_localizationCubit._usingHiveStore) await ${prefix}HiveManager.setup();');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  //MARK: Locale');
    _generated.writeln('  Locale? _locale;');
    _generated.writeln('  static Locale get locale {');
    _generated.writeln('    if (_localizationCubit._usingHiveStore) _localizationCubit._locale = ${prefix}HiveManager._get();');
    _generated.writeln("    return _localizationCubit._locale ?? Locale('en');");
    _generated.writeln('  }');
    _generated.writeln('  static set locale(Locale locale) {');
    _generated.writeln('    _localizationCubit._locale = locale;');
    _generated.writeln('    if (_localizationCubit._usingHiveStore) ${prefix}HiveManager._save(locale: locale);');
    _generated.writeln('    _localizationCubit.emit(${prefix}LocaleUpdated(locale));');
    _generated.writeln('  }');
    _generated.writeln('}');
    _generated.writeln('');
  }

  void _generateState() {
    _generated.writeln('//MARK: State');
    _generated.writeln('@immutable');
    _generated.writeln('abstract class ${prefix}LocalizationState {}');
    _generated.writeln('');
    _generated.writeln('class ${prefix}LocaleInitial extends ${prefix}LocalizationState {}');
    _generated.writeln('');
    _generated.writeln('class ${prefix}LocaleUpdated extends ${prefix}LocalizationState {');
    _generated.writeln('  final Locale updatedLocale;');
    _generated.writeln('  ${prefix}LocaleUpdated(this.updatedLocale);');
    _generated.writeln('}');
    _generated.writeln('');
  }

  void _generateHive() {
    _generated.writeln('//MARK: Hive');
    _generated.writeln('bool _isLocaleHiveSetup = false; poop');
    _generated.writeln('class ${prefix}HiveManager {');
    _generated.writeln("  static const _boxName = 'com.${enumName.toLowerCase()}.hive.saved_locale.language_code';");
    _generated.writeln('  static Box? _box;');
    _generated.writeln('  static Future<void> setup() async {');
    _generated.writeln('    try {');
    _generated.writeln('      await Hive.initFlutter();');
    _generated.writeln('      _box = await Hive.openBox<String>(_boxName);');
    _generated.writeln('    } on NullThrownError {');
    _generated.writeln('    } on MissingPluginException {');
    _generated.writeln('    } catch (e) {');
    _generated.writeln('      throw FlutterError(e.toString());');
    _generated.writeln('    }');
    _generated.writeln('    _isLocaleHiveSetup = true;');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static Locale _save({required Locale locale}) {');
    _generated.writeln("    if (!_isLocaleHiveSetup) throw FlutterError('${prefix}Language.setup() not called!');");
    _generated.writeln('    final String languageCode = locale.languageCode;');
    _generated.writeln('    _box?.put(_boxName, languageCode);');
    _generated.writeln('    return Locale(languageCode);');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static Locale _get() {');
    _generated.writeln("    if (!_isLocaleHiveSetup) throw FlutterError('${prefix}Language.setup() not called!');");
    _generated.writeln("    String storedValue = _box?.get(_boxName, defaultValue: 'en'); // 'en' - english");
    _generated.writeln('    return Locale(storedValue);');
    _generated.writeln('  }');
    _generated.writeln('}');
  }
}
