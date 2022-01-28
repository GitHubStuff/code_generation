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
    _generated.writeln('// Extending features on $className to persist using Hive');
    _generated.writeln('/* Cut/Paste for main file....');
    _generated.writeln('  static Future<void> setup() => _\$setup();');
    _generated.writeln('  static $className from({required String string}) => _\$fromString(string);');
    _generated.writeln('  static $className? reload([String? key]) => _\$reload(key);');
    _generated.writeln('');
    _generated.writeln('  void close() => _\$close();');
    _generated.writeln('  void delete([String key?]) => _\$delete(key);');
    _generated.writeln('  void save([String key?]) => _\$save(toJson(), key);');
    _generated.writeln('*/');
    _generated.writeln('');
    _generated.writeln("const _boxName = '$boxName';");
    _generated.writeln("const _key = '$keyName';");
    _generated.writeln('Box? _box;');
    _generated.writeln('bool get _\$setupComplete => (_box != null);');
    _generated.writeln('');
    _generated.writeln('Future<void> _\$setup() async {');
    _generated.writeln('  if (_\$setupComplete) return;');
    _generated.writeln('  try {');
    _generated.writeln('    await Hive.initFlutter();');
    _generated.writeln('    _box = await Hive.openBox<String>(_boxName);');
    _generated.writeln('  } on NullThrownError {');
    _generated.writeln('  } on MissingPluginException {');
    _generated.writeln('  } catch (e) {');
    _generated.writeln('    throw FlutterError(e.toString());');
    _generated.writeln('  }');
    _generated.writeln('}');
    _generated.writeln('');
    _generated.writeln('void _\$save([String? key]) => (_\$setupComplete) ? _box?.put(key ?? _key, jsonEncode(this)) : throw FlutterError("Not setup");');
    _generated.writeln('');
    _generated.writeln('void _\$close() => (_\$setupComplete) ? _box?.close() : throw FlutterError("Not setup");');
    _generated.writeln('');
    _generated.writeln('void _\$delete([String? key]) => (_\$setupComplete) ? _box?.delete(key ?? _key) : throw FlutterError("Not setup");');
    _generated.writeln('');
    _generated.writeln('$className? _\$reload([String? key]) {');
    _generated.writeln('  if (!_\$setupComplete) throw FlutterError("Not setup");');
    _generated.writeln('  String? storedValue = _box?.get(key ?? _key);');
    _generated.writeln('  if (storedValue == null) return null;');
    _generated.writeln('  Map<String, dynamic> map = jsonDecode(storedValue);');
    _generated.writeln('  return $className.fromJson(map);');
    _generated.writeln('}');
    _generated.writeln('');
    _generated.writeln('$className _\$fromString(String string) => $className.fromJson(jsonDecode(string));');
  }
}
