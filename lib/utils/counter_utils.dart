int formatCounter(String counter) {
  //Remove all 0s at the start and takes away any spaces
  String firstLine = counter.trim().split('\n')[0];
  String result = firstLine.replaceAll(' ', '').replaceAll(RegExp(r'^0+'), '');
  return int.parse(result);
}
