import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class HiveJsonGenerator {
  final ClassElement element;
  final ConstantReader annotations;

  final _generated = StringBuffer();

  HiveJsonGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.CLASS);

  String get className => annotations.read('className').stringValue;
  String get key => annotations.read('key').stringValue;
  String get boxName => annotations.read('boxName').stringValue;

  String generate() {
    //_generated.writeln('/*');
    _body();
    //_generated.writeln('*/');
    return _generated.toString();
  }

  void _body() {
    String keyName = key.isNotEmpty ? key : 'key$className';
    _generated.writeln('// Extension on $className to persist using Hive');
    _generated.writeln('extension ${className}Hive on $className {');
    _generated.writeln("  static const _boxName = '$boxName';");
    _generated.writeln("  static const _key = '$keyName';");
    _generated.writeln('  static Box? _box;');
    _generated.writeln('');
    _generated.writeln('  //! Should be called high in the widget tree {preferably in main()}');
    _generated.writeln('  static Future<void> setup() async {');
    _generated.writeln('    try {');
    _generated.writeln('      await Hive.initFlutter();');
    _generated.writeln('      _box = await Hive.openBox<String>(_boxName);');
    _generated.writeln('    } on NullThrownError {');
    _generated.writeln('    } on MissingPluginException {');
    _generated.writeln('    } catch (e) {');
    _generated.writeln('      throw FlutterError(e.toString());');
    _generated.writeln('    }');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  void save() {');
    _generated.writeln('    final String jsonString = jsonEncode(this);');
    _generated.writeln('    _box?.put(_key, jsonString);');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  void close() {');
    _generated.writeln('    _box?.close();');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static $className? reload() {');
    _generated.writeln('    String? storedValue = _box?.get(_key);');
    _generated.writeln('    if (storedValue == null) return null;');
    _generated.writeln('    Map<String, dynamic> map = jsonDecode(storedValue);');
    _generated.writeln('    return MyObject.fromJson(map);');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static $className fromString(String string) => $className.fromJson(jsonDecode(string));');
    _generated.writeln('}');
  }
}
