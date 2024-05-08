import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/all.dart';
import 'package:highlight/languages/plaintext.dart';

enum CodeViewLanguage {
  text('Plain Text', 'plaintext'),
  java('Java', 'java'),
  kotlin('Kotlin', 'kotlin'),
  python('Python', 'python'),
  cpp('C++', 'cpp'),
  sql('SQL', 'sql'),
  json('JSON', 'json'),
  typescript('TypeScript', 'typescript'),
  javascript('JavaScript', 'javascript'),
  html('HTML', 'htmlbars'),
  xml('XML', 'xml'),
  php('PHP', 'php'),
  css('CSS', 'css'),
  jsp('JSP', 'plaintext');

  final String title;
  final String langCode;
  const CodeViewLanguage(this.title, this.langCode);

  Mode get mode {
    return allLanguages[langCode] ?? plaintext;
  }
}
