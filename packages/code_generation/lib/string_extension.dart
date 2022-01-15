extension StringExtensions on String {
  String unCamelCase() {
    String word = this;
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').forEach((c) => word = word.replaceAll(c, '_${c.toLowerCase()}'));
    return word;
  }

  String capitalize() => "${this[0].toUpperCase()}${this.substring(1)}";
}
