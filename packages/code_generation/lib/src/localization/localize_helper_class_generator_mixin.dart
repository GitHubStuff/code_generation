part of 'localize_lookup_generator.dart';

extension LocalizeHelperClassGeneratorMixin on LocalizeLookupGenerator {
  String get cubitName => '${helperClassName}Cubit';
  String get cubitState => '${helperClassName}State';
  String get cubitHiveManager => '${helperClassName}HiveManager';

  void _generateHelperClass() {
    if (generateHelperClass) {
      _generateClass();
      _generateCubit();
      _generateCubitStates();
      _generateCubitHiveManager();
    } else {
      _generateExtension();
    }
  }

  void _generateClass() {
    _generated.writeln('//! await ${helperClassName}.setup() should be called at App start to persist Locale');
    _generated.writeln('// MARK: Helper class $helperClassName for getting and setting Locale');
    _generated.writeln("// NOTE: calling as => await ${helperClassName}.setup(locale: Locale('en');");
    _generated.writeln("// will disable persisting Locale. [To be used for unit tests]");
    _generated.writeln('class $helperClassName {');
    _generated.writeln('  static Future<void> setup({Locale? locale}) => ${cubitName}.setup(locale:locale);');
    _generated.writeln('  static Cubit<$cubitState> get cubit => ${cubitName}.cubit;');
    _generated.writeln('  static Locale get locale => ${cubitName}.locale;');
    _generated.writeln('  static set locale(Locale newLocale) => ${cubitName}.locale = newLocale;');
    _generated.writeln('  static String translate${i69nKey.capitalize()}(${this.element.name} token, {Locale? locale}) => token.byLocale(locale ??  $cubitName.locale);');
    _generated.writeln('}');
  }

  void _generateExtension() {
    _generated.writeln('// MARK: Extension to $helperClassName for ${i69nKey.capitalize()} token');
    _generated.writeln('extension $helperClassName$i69nKey on $helperClassName {');
    _generated
        .writeln('  static String translate${i69nKey.capitalize()}(${this.element.name} token, {Locale? locale}) => token.byLocale(locale ??  ${helperClassName}Cubit.locale);');
    _generated.writeln('}');
  }

  void _generateCubit() {
    _generated.writeln('//MARK $cubitName');
    _generated.writeln('class $cubitName extends Cubit<$cubitState> {');
    _generated.writeln('  static final $cubitName _singleton = $cubitName._internal();');
    _generated.writeln('  factory $cubitName() => _singleton;');
    _generated.writeln('  $cubitName._internal() : super(${cubitState}Initial());');
    _generated.writeln('  static $cubitName get cubit => _singleton;');
    _generated.writeln('');
    _generated.writeln('  bool _usingHiveStore = false;');
    _generated.writeln('');
    _generated.writeln('  static Future<void> setup({Locale? locale}) async {');
    _generated.writeln('    cubit._locale = locale;');
    _generated.writeln('    cubit._usingHiveStore = (locale == null);');
    _generated.writeln('    if (cubit._usingHiveStore) await $cubitHiveManager.setup();');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  Locale? _locale;');
    _generated.writeln('  static Locale get locale {');
    _generated.writeln('    if (cubit._usingHiveStore) cubit._locale = $cubitHiveManager._get();');
    _generated.writeln("    return cubit._locale ?? Locale('en');");
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static set locale(Locale locale) {');
    _generated.writeln('    cubit._locale = locale;');
    _generated.writeln('    if(cubit._usingHiveStore) $cubitHiveManager._save(locale: locale);');
    _generated.writeln('    cubit.emit(${cubitState}Updated(locale));');
    _generated.writeln('  }');
    _generated.writeln('}');
  }

  void _generateCubitStates() {
    _generated.writeln('//MARK $cubitState');
    _generated.writeln('@immutable');
    _generated.writeln('abstract class $cubitState {}');
    _generated.writeln('');
    _generated.writeln('class ${cubitState}Initial extends $cubitState {}');
    _generated.writeln('');
    _generated.writeln('class ${cubitState}Updated extends $cubitState {');
    _generated.writeln('  final Locale updatedLocale;');
    _generated.writeln('  ${cubitState}Updated(this.updatedLocale);');
    _generated.writeln('}');
    _generated.writeln('');
  }

  void _generateCubitHiveManager() {
    _generated.writeln('//MARK $cubitHiveManager to persist locale');
    _generated.writeln('bool _isLocaleHiveSetup = false;');
    _generated.writeln('');
    _generated.writeln('class $cubitHiveManager {');
    _generated.writeln("  static const _boxName = 'com.${cubitHiveManager}.${helperClassName}.hive.locale';");
    _generated.writeln('  static Box? _box;');
    _generated.writeln('');
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
    _generated.writeln("    if (!_isLocaleHiveSetup) throw FlutterError('$helperClassName.setup() not called!');");
    _generated.writeln('    final String languageCode = locale.languageCode;');
    _generated.writeln('    _box?.put(_boxName, languageCode);');
    _generated.writeln('    return Locale(languageCode);');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static Locale _get() {');
    _generated.writeln("    if (!_isLocaleHiveSetup) throw FlutterError('$helperClassName.setup() not called!');");
    _generated.writeln("    String storedValue = _box?.get(_boxName, defaultValue: 'en'); // 'en' - english");
    _generated.writeln('    return Locale(storedValue);');
    _generated.writeln('  }');
    _generated.writeln('}');
  }
}
