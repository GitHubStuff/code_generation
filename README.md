# localize_enum

This is a specially crafted package that creates an enum extension that is improves the use custom localizations used by the [rae_localization_package](https://github.com/RAE-Health/rae_localization_package.git). Running this code generation package will create a lookup-table of localized strings that can be used by [RAEHealth](https://www.raehealth.com).

## Usage

This package generates code FROM the [rae_localization_package](https://github.com/RAE-Health/rae_localization_package.git).

```text
% # From the command prompt
% flutter pub run build_runner build --delete-conflicting-outputs
% #
% # generates rae_locatization.g.dart
% #
```

The generated file [rae_localizations.g.dart](https://github.com/RAE-Health/rae_localization_package/blob/main/lib/src/rae_localization.g.dart) is lookup-table that allows localized text be returned based on an enum {which is safer than string lookup}

When a ***localization*** is added to the three(3) ***.i69n.yaml** files, the say 'key' value should be added to
*[enum RAELocation](https://github.com/RAE-Health/rae_localization_package/blob/main/lib/src/rae_localization.dart)*

```dart
/// each property matches the key in the .i69n.yaml files
@localizeEnum
enum RAELocalization {
  btnAccept,
  btnContinue,
  btnOk,
  btnDecline,
  btnDismiss,
  captionPdfTitleTerms,
  captionPressToContinue,
  captionDialogTextTerms,
}
```

## Final Note

Be kind to each other
