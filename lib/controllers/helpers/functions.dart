import 'dart:math';

// String type is "numbers" or "letters" or "mixed"
List<String> generateUniqueRandomStrings({
  required int count,
  int length = 7,
  String prefix = "",
  String suffix = "",
  String type = "numbers", // "numbers", "letters", "mixed"
  List<String> users=const []
}) {
  const String letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  const String digits = "0123456789";
  const String mix = "012345678901234567890123456789";

  String characters;
  switch (type) {
    case "letters":
      characters = letters;
      break;
    case "mixed":
      characters = letters + mix;
      break;
    case "numbers":
    default:
      characters = digits;
      break;
  }

  Random random = Random();
  Set<String> uniqueValues = {};

  while (uniqueValues.length < count) {
    String randomString = List.generate(
      length,
      (index) => characters[random.nextInt(characters.length)],
    ).join();
    String cardText="$prefix$randomString$suffix";

    if (!users.contains(cardText)) {
      uniqueValues.add(cardText);
    }
  }

  return uniqueValues.toList();
}




// for help Selected Menu
// getAttrFromQuery
// widget.items
// widget.selectedKeyName, 
// widget.selectedValueName, 
// val).toString();

dynamic getAttrFromQuery(List items, var feature, var key, var value) {
  List<dynamic> ids = [];
  List<dynamic> names = [];
  for (var item in items) {
    ids.add(item[feature]);
    names.add(item[key]);
  }
  Map x = {
    feature: ids,
    key: names,
  };
  int index = x[key].indexOf(value);
  return x[feature][index];
}





