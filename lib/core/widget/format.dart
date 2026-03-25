// Date: 23/10/2024
// Last update: 23/10/2024



List<String> abbreviation = [
  "it",
  "hr",
  'utils ux',
  'log',
  'qa',
  'pr',
  'dev',
  'ceo',
  "grc",
  "mena",
  "ksa",
  "uae",
  "coo",
  "cfo",
  "cdo",
  "cso",
  "cbo",
  "cmo",
  "cto",
  "cno",
  "cco",
  "chro",
  "cxo"
];


abstract class FormatHelper {
  static  String capitalize(String input) {
    input.toLowerCase();
    input = applyAbbreviation(input);

    if (input.isEmpty) {
      return "";
    }

    List<String> words = input.split(" ");
    words = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return "";
      }
    }).toList();
    // print('words: $words');
    return words.join(" ");
  }

  static String applyAbbreviation(String input) {
    for (String abbreviation in abbreviation) {
      RegExp regex = RegExp(r'\b' + abbreviation + r'\b', caseSensitive: false);
      if (regex.hasMatch(input)) {
        input = input.replaceAllMapped(regex, (match) => abbreviation.toUpperCase());
      }
    }
    return input;
  }}
