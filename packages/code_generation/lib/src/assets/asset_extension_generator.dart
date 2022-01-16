import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import '../../string_extension.dart';

class AssetExtensionGenerator {
  final ClassElement element;
  final ConstantReader annotations;
  final _generated = StringBuffer();

  AssetExtensionGenerator(this.element, this.annotations) : assert(element.kind == ElementKind.ENUM);

  String get name => element.name;
  String get assetTitle => annotations.read('assetTitle').stringValue;
  String get packageName => annotations.read('packageName').stringValue;
  bool get includeMixin => annotations.read('includeMixin').boolValue;
  String get colorClassAndMapName => annotations.read('colorClassAndMapName').stringValue;
  String get gradientClassAndMapName => annotations.read('gradientClassAndMapName').stringValue;

  String generate() {
    _generated.writeln('/* name:[$name] assetTitle:[$assetTitle] */');
    _generateAssets();
    return _generated.toString();
  }

  //String get assetRoot => element.name.substring(0, element.name.length - 2);

  void _generateAssets() {
    _generated.writeln('class ${assetTitle} {');
    _walkList();
    _generated.writeln('}');
    if (includeMixin) _generateMixin();
  }

  void _generateMixin() {
    _generated.writeln('');
    _generated.writeln('mixin ${assetTitle}Mixin {');
    _generated.writeln('  List<Widget> get${assetTitle}({double size = 90.0}) {');
    _generated.writeln('    final List<Widget> result = [];');
    _generated.writeln('    ${element.name}.values.forEach((element) {');
    _generated.writeln("      Widget image = Text('Empty');");
    _generated.writeln('      switch (element) {');
    element.fields.skip(2).forEach(_generateMixinCase);
    _generatedMixinFooter();
    _generated.writeln('}');
  }

  void _generatedMixinFooter() {
    _generated.writeln('      }');
    _generated.writeln('      Widget description = Column(');
    _generated.writeln('        children: [');
    _generated.writeln('          Container(height: size, width: size, child: image),');
    _generated.writeln('          Text(');
    _generated.writeln('            element.name,');
    _generated.writeln('            style: TextStyle(fontSize: 16),');
    _generated.writeln('          ),');
    _generated.writeln('        ],');
    _generated.writeln('      );');
    _generated.writeln("      if (!element.name.startsWith('json')) {");
    _generated.writeln('        result.add(Padding(');
    _generated.writeln('          padding: const EdgeInsets.all(8.0),');
    _generated.writeln('          child: description,');
    _generated.writeln('        ));');
    _generated.writeln('      }');
    _generated.writeln('    },');
    _generated.writeln('    );');
    _generated.writeln('    return result;');
    _generated.writeln('  }');
  }

  void _generateMixinCase(FieldElement e) {
    _generated.writeln('        case ${element.name}.${e.name}:');
    if (e.name.startsWith('json')) {
      _generated.writeln('      // No widget for ${element.name}.${e.name}, content ignored');
    }
    if (e.name.startsWith('colors')) {
      _generated.writeln('          image = Row(');
      _generated.writeln('            children: [');
      _generated.writeln('              Container(');
      _generated.writeln('                height: size,');
      _generated.writeln('                width: size / 2.0,');
      _generated.writeln('                color: ${assetTitle}.${e.name}.dark,');
      _generated.writeln('              ),');
      _generated.writeln('              Container(');
      _generated.writeln('                height: size,');
      _generated.writeln('                width: size / 2.0,');
      _generated.writeln('                color: ${assetTitle}.${e.name}.light,');
      _generated.writeln('              ),');
      _generated.writeln('            ],');
      _generated.writeln('          );');
    }
    if (e.name.startsWith('gradient')) {
      //_generated.writeln('');
      _generated.writeln('          image = Row(');
      _generated.writeln('            children: [');
      _generated.writeln('              LinearGradientContainer(');
      _generated.writeln('                height: size,');
      _generated.writeln('                width: size / 2.0,');
      _generated.writeln('                themeGradients: ${assetTitle}.${e.name},');
      _generated.writeln('                circularBorderRadius: 5.0,');
      _generated.writeln('                overridingBrightness: Brightness.dark,');
      _generated.writeln('              ),');
      _generated.writeln('              LinearGradientContainer(');
      _generated.writeln('                height: size,');
      _generated.writeln('                width: size / 2.0,');
      _generated.writeln('                themeGradients: ${assetTitle}.${e.name},');
      _generated.writeln('                circularBorderRadius: 5.0,');
      _generated.writeln('                overridingBrightness: Brightness.light,');
      _generated.writeln('              ),');
      _generated.writeln('            ],');
      _generated.writeln('          );');
      //_generated.writeln('*/');
    }
    if (e.name.startsWith('png') || e.name.startsWith('gif')) {
      _generated.writeln('          image = Image(image: ${assetTitle}.${e.name});');
    }
    _generated.writeln('          break;');
  }

  void _walkList() {
    element.fields.skip(2).forEach(_generateGet);
  }

  void _generateGet(FieldElement e) {
    if (e.name.startsWith('png')) _assetImage('png', e.name);
    if (e.name.startsWith('gif')) _assetImage('gif', e.name);
    if (e.name.startsWith('colors')) _themeColors(e.name);
    if (e.name.startsWith('json')) _json(e.name);
    if (e.name.startsWith('gradients')) _gradientColors(e.name);
  }

  void _assetImage(String dir, String name) {
    final fullname = 'assets/$dir/${name.unCamelCase}.$dir';
    _generated.writeln(" static AssetImage get $name => AssetImage('$fullname', package: '$packageName');");
  }

  void _json(String name) {
    final fullname = 'assets/json/${name.unCamelCase}.json';
    _generated.writeln("  static Future<String> get $name => rootBundle.loadString('$fullname');");
  }

  void _themeColors(String name) {
    _generated.writeln('  static ThemeColors get $name => $colorClassAndMapName[${element.name}.$name]!;');
  }

  void _gradientColors(String name) {
    _generated.writeln('  static ThemeGradients get $name => $gradientClassAndMapName[${element.name}.$name]!;');
  }
}
