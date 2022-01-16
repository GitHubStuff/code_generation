import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class AutoSaveCodeGenerator {
  final ClassElement element;
  final ConstantReader annotations;

  AutoSaveCodeGenerator(this.element, this.annotations);
}
