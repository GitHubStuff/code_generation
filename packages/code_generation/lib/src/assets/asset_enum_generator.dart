import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_generation_annotation/code_generation_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'asset_extension_generator.dart';

class AssetEnumGenerator extends GeneratorForAnnotation<AssetsEnum> {
  const AssetEnumGenerator();

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind == ElementKind.ENUM && element is ClassElement) {
      return AssetExtensionGenerator(element, annotation).generate();
    } else {
      throw InvalidGenerationSourceError(
        '''@LocalizeEnum can only be applied on enum types. NOT on a ${element.kind} ${element.name}.''',
        element: element,
      );
    }
  }
}
