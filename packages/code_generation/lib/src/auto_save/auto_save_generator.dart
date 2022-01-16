import 'package:analyzer/dart/element/element.dart';
import 'package:code_generation_annotation/code_generation_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../generator_for_annotated_field.dart';

class AutoSaveGenerator extends GeneratorForAnnotatedField<AutoSave> {
  const AutoSaveGenerator();

  @override
  String generateForAnnotatedField(FieldElement field, ConstantReader annotation) {
    return '//!! SNARK!';
  }
}
