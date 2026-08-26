String formatNumber(int value) {
  final valueString = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < valueString.length; i++) {
    final reverseIndex = valueString.length - i;
    buffer.write(valueString[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}
