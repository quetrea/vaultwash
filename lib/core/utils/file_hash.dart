import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashContent(String content) {
  return sha1.convert(utf8.encode(content)).toString();
}
