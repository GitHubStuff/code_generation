import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class HiveCodeGenerator {
  static bool _addIgnoreLines = true;
  final ClassElement element;
  final ConstantReader annotations;

  final _generated = StringBuffer();

  HiveCodeGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.CLASS);

  String get name => element.name;
  String get prefix => annotations.peek('prefix') == null ? 'YYY' : annotations.read('prefix').stringValue;
  String get enumName => annotations.peek('enumName') == null ? '' : annotations.read('enumName').stringValue;

  String generate() {
    if (_addIgnoreLines) _generated.writeln('// ignore_for_file: lines_longer_than_80_chars');
    _addIgnoreLines = false;
    _generateHive();
    return _generated.toString();
  }

  void _generateHive() {
    _generated.writeln('//MARK: Hive');
  }
}
