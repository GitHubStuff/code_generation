library code_generation_annotation;

export 'package:meta/meta.dart';

class AssetsEnum {
  final String assetTitle;
  final String packageName;
  final bool includeMixin;
  final String colorClassAndMapName;
  final String gradientClassAndMapName;
  const AssetsEnum({
    required this.assetTitle,
    required this.packageName,
    required this.includeMixin,
    required this.colorClassAndMapName,
    required this.gradientClassAndMapName,
  });
}

class LocalizeCubit {
  final String prefix;
  final String enumName;
  const LocalizeCubit(this.prefix, this.enumName);
}

class LocalizeEnum {
  final String i69nRoot;
  final String helperClassName;
  final bool generateHelperClass;
  const LocalizeEnum({required this.i69nRoot, required this.helperClassName, this.generateHelperClass = false});
}

class HiveJsonSerialExtender {
  final String className;
  final String key;
  final String boxName;
  const HiveJsonSerialExtender({
    required this.className,
    required this.key,
    this.boxName = 'com.shared.hive.data.store',
  });
}
