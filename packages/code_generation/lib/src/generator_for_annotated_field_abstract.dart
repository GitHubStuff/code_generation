import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

abstract class GeneratorForAnnotatedFieldAbstract<T> extends Generator {
  /// Returns the annotation of type [T] of the given [element],
  /// or [null] if it doesn't have any.
  const GeneratorForAnnotatedFieldAbstract() : super();

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final Set<String> setOfCodeStrings = <String>{};

    for (final Element element in library.allElements) {
      if (element is ClassElement && !element.isEnum) {
        for (final FieldElement field in element.fields) {
          final DartObject? annotation = getAnnotation(field);
          if (annotation != null)
            setOfCodeStrings.add(
              await generateForAnnotatedField(
                field,
                ConstantReader(annotation),
              ),
            );
        }
      }
    }
    return setOfCodeStrings.join('\n\n');
  }

  DartObject? getAnnotation(FieldElement element) {
    final Iterable<DartObject> annotations = TypeChecker.fromRuntime(T).annotationsOf(element);
    if (annotations.isEmpty) {
      return null;
    }
    if (annotations.length > 1) {
      throw Exception("You tried to add multiple @$T() annotations to the "
          "same element (${element.name}), but that's not possible.");
    }
    return annotations.single;
  }

  FutureOr<String> generateForAnnotatedField(FieldElement field, ConstantReader annotation);
}
