import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:code_generation_annotation/code_generation_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'localize_lookup_generator.dart';

class LocalizeEnumGenerator extends GeneratorForAnnotation<LocalizationEnum> {
  const LocalizeEnumGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind == ElementKind.ENUM && element is ClassElement) {
      return LocalizeLookupGenerator(element, annotation).generate();
    } else {
      throw InvalidGenerationSourceError(
        '''@LocalizeEnum can only be applied on enum types. NOT on a ${element.kind} ${element.name}.''',
        element: element,
      );
    }
  }
}
