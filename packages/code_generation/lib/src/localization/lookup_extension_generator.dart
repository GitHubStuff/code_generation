import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class LookupExtensionGenerator {
  final ClassElement element;
  final ConstantReader annotations;
  final _generated = StringBuffer();

  LookupExtensionGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.ENUM);

  String get name => element.name;
  String get i69nRoot => annotations.read('i69nRoot').stringValue;

  String generate() {
    _generated.writeln('/* name:[$name] i69n:[$i69nRoot] */');
    return _generated.toString();
  }
}
