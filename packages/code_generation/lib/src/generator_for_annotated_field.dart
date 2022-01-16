import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../string_extension.dart';

abstract class GeneratorForAnnotatedField<T> extends Generator {
  /// Returns the annotation of type [T] of the given [element],
  /// or [null] if it doesn't have any.
  const GeneratorForAnnotatedField() : super();

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final values = <String>{};

    for (final Element element in library.allElements) {
      if (element is ClassElement && !element.isEnum) {
        for (final field in element.fields) {
          final String? parseItem = getAnnotationParseItem(field);
          if (parseItem != null) values.add(parseItem);
        }
      }
    }
    print('VALUE: ${values.join('\n')}');
    return values.join('\n\n');
  }

  String? getAnnotationParseItem(Element element) {
    final annotations = TypeChecker.fromRuntime(T).annotationsOf(element);
    if (annotations.isEmpty) {
      return null;
    }

    final String className = element.enclosingElement?.name ?? 'ERROR#No Class name';

    String setter = '';
    final List<String> setterName = annotations.toString().split("'");
    if (setterName.isEmpty) {
      setter = element.name?.makePublic ?? 'ERROR#No element name#';
    } else {
      setter = setterName[1].isNotEmpty ? setterName[1] : (element.name?.makePublic ?? 'ERROR#No element name#');
    }
    if (setter == element.name) setter = 'ERROR#Setter and Property in $className cannot both be "$setter"#';

    final String dataType = element.declaration?.toString().split(' ').first ?? (element.name ?? 'ERROR#No Data Type#');

    final String varName = element.name ?? 'ERROR#No variable name#';

    final String result = '//$className\t$setter\t$dataType\t$varName';
    print('RESULT: $result');
    return result;
  }

  DartObject? getAnnotation(Element element) {
    final annotations = TypeChecker.fromRuntime(T).annotationsOf(element);
    if (annotations.isEmpty) {
      return null;
    }
    if (annotations.length > 1) {
      throw Exception("You tried to add multiple @$T() annotations to the "
          "same element (${element.name}), but that's not possible.");
    }
    return annotations.single;
  }

  String generateForAnnotatedField(FieldElement field, ConstantReader annotation);
}
