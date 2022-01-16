import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_generation_annotation/code_generation_annotation.dart';
import 'package:source_gen/source_gen.dart';


abstract class GeneratorForAnnotatedField<AnnotationType> extends Generator {
  /// Returns the annotation of type [AnnotationType] of the given [element],
  /// or [null] if it doesn't have any.
  const GeneratorForAnnotatedField() : super();
  DartObject? getAnnotation(Element element) {
    final annotations = TypeChecker.fromRuntime(AnnotationType).annotationsOf(element);
    if (annotations.isEmpty) {
      return null;
    }
    Element? e = element.enclosingElement;
    var k = element.kind;
    var m = element.declaration;
    var t = m?.toString().split(' ').first ?? '~';
    // final visitor = ModelVisitor();
    // e?.visitChildren(visitor);
    // for (final field in visitor.fields.values) {
    //   print('//!! VALUES:${field}');
    // }
    // print('//!!! ${visitor.toString()}');
    final z = element.isPrivate;
    final wibble = annotations.toString().split("'");
    print('WIBBLE [${wibble[1]}]');
    annotations.forEach((e) => print('//------ ${e.getField("setter")?.toSetValue()}'));
    print('/!!!!$z! ${annotations.toString()} name:(${element.name}/${t}) parent:|${e?.name}|K:${k.toString()}');
    if (annotations.length > 1) {
      throw Exception("You tried to add multiple @$AnnotationType() annotations to the "
          "same element (${element.name}), but that's not possible.");
    }
    return annotations.single;
  }

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final values = <String>{};

    for (final element in library.allElements) {
      if (element is ClassElement && !element.isEnum) {
        for (final field in element.fields) {
          final annotation = getAnnotation(field);
          if (annotation != null) {
            values.add(generateForAnnotatedField(
              field,
              ConstantReader(annotation),
            ));
          }
        }
      }
    }

    return values.join('\n\n');
  }

  String generateForAnnotatedField(FieldElement field, ConstantReader annotation);
}

class AutoSaveGenerator extends GeneratorForAnnotatedField<AutoSave> {
  const AutoSaveGenerator();
  @override
  String generateForAnnotatedField(FieldElement field, ConstantReader annotation) {
    return '//!! SNARK!';
  }
}

class AdapterField {
  final int index;
  final String name;
  final DartType type;
  final DartObject? defaultValue;

  AdapterField(this.index, this.name, this.type, this.defaultValue);
}

class AutoSaveGeneratorX extends GeneratorForAnnotation<AutoSave> {
  const AutoSaveGeneratorX();

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    final str = '[E]${element.toString()} [A]${annotation.toString()} [B]${buildStep.toString()}';
    print('$str');
    final library = await buildStep.inputLibrary;
    print('LIB:<${library.toString()}>');
    var gettersAndSetters = getAccessors((element as ClassElement), library);
    return ('//!! $str [L]<${gettersAndSetters.toString()}>');
    // if (element.kind == ElementKind.FIELD && element is ClassElement) {
    //   return AutoSaveCodeGenerator(element, annotation).generate();
    // } else {
    //   throw InvalidGenerationSourceError(
    //     '''@AutoSaveCodeGenerator can only be applied on class types. NOT on a ${element.kind} ${element.name}.''',
    //     element: element,
    //   );
    // }
  }

  List<List<AdapterField>> getAccessors(ClassElement cls, LibraryElement library) {
    var accessorNames = getAllAccessorNames(cls);
    print('AccessorNames :[${accessorNames.toString()}]');
    var getters = <AdapterField>[];
    var setters = <AdapterField>[];
    for (var name in accessorNames) {
      var getter = cls.lookUpGetter(name, library);
      if (getter != null) {
        print('GETTER => ${getter.toString()}');
        // var getterAnn = getHiveFieldAnn(getter.variable) ?? getHiveFieldAnn(getter);
        // if (getterAnn != null) {
        //   var field = getter.variable;
        //   getters.add(AdapterField(
        //     getterAnn.index,
        //     field.name,
        //     field.type,
        //     getterAnn.defaultValue,
        //   ));
      }

      var setter = cls.lookUpSetter('$name=', library);
      if (setter != null) {
        print('Setter => ${setter.toString()}');
        // var setterAnn = getHiveFieldAnn(setter.variable) ?? getHiveFieldAnn(setter);
        // if (setterAnn != null) {
        // var field = setter.variable;
        // setters.add(AdapterField(
        //   setterAnn.index,
        //   field.name,
        //   field.type,
        //   setterAnn.defaultValue,
        // ));
      }
    }

    return [getters, setters];
  }

  Set<String> getAllAccessorNames(ClassElement cls) {
    var accessorNames = <String>{};

    var supertypes = cls.allSupertypes.map((it) => it.element);
    for (var type in [cls, ...supertypes]) {
      for (var accessor in type.accessors) {
        if (accessor.isSetter) {
          var name = accessor.name;
          accessorNames.add(name.substring(0, name.length - 1));
        } else {
          accessorNames.add(accessor.name);
        }
      }
    }

    return accessorNames;
  }
}
