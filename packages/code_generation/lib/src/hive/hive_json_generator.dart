import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class HiveJsonGenerator {
  final ClassElement element;
  final ConstantReader annotations;

  final _generated = StringBuffer();

  HiveJsonGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.CLASS);

  String get className => annotations.peek('className') != null ? annotations.read('className').stringValue : throw Exception('Missing class name in @HiveJsonSerialExtender\n');
  String get key => annotations.peek('key') != null ? annotations.read('key').stringValue : 'key$className';
  String get boxName => annotations.read('boxName').stringValue;

  String generate() {
    if (boxName.isEmpty) throw Exception('Hive requires an non-empty box name in @HiveJsonSerialExtender for $className\n');
    _body();
    return _generated.toString();
  }

  void _body() {
    String keyName = key.isNotEmpty ? key : 'key$className';
    _generated.writeln('// Extension on $className to persist using Hive');
    _generated.writeln('extension ${className}Hive on $className {');
    _generated.writeln("  static const _boxName = '$boxName';");
    _generated.writeln("  static const _key = '$keyName';");
    _generated.writeln('  static Box? _box;');
    _generated.writeln('  static bool get setupComplete => (_box != null);');
    _generated.writeln('');
    _generated.writeln('  //! Should be called high in the widget tree {preferably in main()}');
    _generated.writeln('  static Future<void> setup() async {');
    _generated.writeln('    if (setupComplete) return;');
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
    _generated.writeln('  void save() => (setupComplete) ? _box?.put(_key, jsonEncode(this)) : throw FlutterError("Not setup");');
    _generated.writeln('');
    _generated.writeln('  void close() => (setupComplete) ? _box?.close() : throw FlutterError("Not setup");');
    _generated.writeln('');
    _generated.writeln('  void delete() => (setupComplete) ? _box?.delete(_key) : throw FlutterError("Not setup");');
    _generated.writeln('');
    _generated.writeln('  static $className? reload() {');
    _generated.writeln('    if (!setupComplete) throw FlutterError("Not setup");');
    _generated.writeln('    String? storedValue = _box?.get(_key);');
    _generated.writeln('    if (storedValue == null) return null;');
    _generated.writeln('    Map<String, dynamic> map = jsonDecode(storedValue);');
    _generated.writeln('    return $className.fromJson(map);');
    _generated.writeln('  }');
    _generated.writeln('');
    _generated.writeln('  static $className fromString(String string) => $className.fromJson(jsonDecode(string));');
    _generated.writeln('}');
  }
}
