library code_generation;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/assets/asset_enum_generator.dart';
import 'src/hive/hive_generator.dart';
import 'src/localization/localize_enum_generator.dart';

Builder assetEnum(BuilderOptions options) {
  return SharedPartBuilder([const AssetEnumGenerator()], 'asset_enum');
}

Builder hiveJsonBuilder(BuilderOptions options) {
  return SharedPartBuilder([const HiveGenerator()], 'hive_json_generator');
}

Builder localizationEnum(BuilderOptions options) {
  return SharedPartBuilder([const LocalizeEnumGenerator()], 'localize_enum');
}
