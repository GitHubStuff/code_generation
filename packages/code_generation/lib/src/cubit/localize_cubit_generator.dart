import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:code_generation_annotation/code_generation_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'localize_cubit_class_generator.dart';

class LocalizeCubitGenerator extends GeneratorForAnnotation<LocalizeCubit> {
  const LocalizeCubitGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind == ElementKind.CLASS && element is ClassElement) {
      return LocalizeCubitClassGenerator(element, annotation).generate();
    } else {
      throw InvalidGenerationSourceError(
        '''@LocalizeCubit can only be applied on class types. NOT on a ${element.kind} ${element.name}.''',
        element: element,
      );
    }
  }
}
