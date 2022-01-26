import 'package:analyzer/dart/element/element.dart';
import 'package:code_generation_annotation/code_generation_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../../string_extension.dart';
import '../generator_for_annotated_field_abstract.dart';

class AutoSaveGenerator extends GeneratorForAnnotatedFieldAbstract<AutoSave> {
  const AutoSaveGenerator();
  static bool _addIgnoreLines = true;

  /// Defined in GeneratorForAnnotatedFieldAbstract
  @override
  String generateForAnnotatedField(FieldElement field, ConstantReader annotation) {
    return _getAnnotationParseItem(field) ?? '';
  }

  String? _getAnnotationParseItem(FieldElement fieldElement) {
    final annotations = TypeChecker.fromRuntime(AutoSave).annotationsOf(fieldElement);
    if (annotations.isEmpty) {
      return null;
    }
    String token = annotations.first.toString();
    final String className = fieldElement.enclosingElement.name ?? 'ERROR#No Class name';

    bool generateGetter = false;
    String defGet = '';
    String defSet = '';
    List<String> classSplit = token.split("AutoSave (");
    String newToken = classSplit[1].substring(0, classSplit[1].length - 1);
    List<String> tokens = newToken.split('; ');
    for (String aToken in tokens) {
      if (aToken.startsWith('generateGetter')) {
        generateGetter = aToken.contains('(true)') || fieldElement.isPrivate;
        if (generateGetter && defGet.isEmpty) defGet = fieldElement.name.makePublic;
        continue;
      }
      if (aToken.startsWith('getter =')) {
        generateGetter = generateGetter || aToken.contains('String');
        if (aToken.contains('getter = Null')) continue;
        List<String> getterList = aToken.split("'");
        defGet = getterList[1];
        continue;
      }
      if (aToken.startsWith('setter =')) {
        if (aToken.contains("String ('')")) {
          defSet = fieldElement.name.makePublic;
        } else {
          defSet = aToken.split("'")[1];
        }
        continue;
      }
    }
    final String dataType = fieldElement.declaration.toString().split(' ').first;
    if (defSet == fieldElement.name) defSet = 'ERROR#Property and Setter in $className cannot both be $defSet#';
    if (defGet == fieldElement.name) defGet = 'ERROR#Property and Getter in $className cannot both be $defGet#';
    return _dataParser('$className\t$defSet\t${defGet.isEmpty ? "*" : defGet}\t$dataType\t${fieldElement.name}');
  }

  String _dataParser(String token) {
    if (token.contains('ERROR#')) {
      final String errorMessage = token.split('#')[1] + '\n';
      throw Exception(errorMessage);
    }

    List<String> tokenItems = token.split('\t');
    String className() => tokenItems[0];
    String setterName() => tokenItems[1];
    String getterName() => tokenItems[2];
    String dataType() => tokenItems[3];
    String variableName() => tokenItems[4];
    String getterCode = (getterName() == '*') ? '' : '${dataType()} get ${getterName()} => ${variableName()};';
    String headerLine = (_addIgnoreLines) ? '// ignore_for_file: lines_longer_than_80_chars' : '';
    _addIgnoreLines = false;
    String result = """
$headerLine
    extension ${className()}AutoSave${setterName().capitalize} on ${className()} {
      set ${setterName()}(${dataType()} newValue) {
        ${variableName()} = newValue;
        save();
      }
      $getterCode
    }""";
    return result;
  }
}
