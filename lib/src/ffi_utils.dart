import 'dart:ffi';
import 'dart:convert';

class CString extends Struct<CString> {
  @Uint8()
  int char;

  static String fromUtf8(Pointer<CString> str) {
    List<int> units = [];
    int len = 0;
    while (true) {
      int char = str.elementAt(len++).load<CString>().char;
      if (char == 0) break;
      units.add(char);
    }
    return Utf8Decoder().convert(units);
  }

  static Pointer<CString> toUtf8(String s) {
    List<int> units = Utf8Encoder().convert(s);
    Pointer<CString> result =
        Pointer<CString>.allocate(count: units.length + 1).cast();
    for (int i = 0; i < units.length; i++) {
      result.elementAt(i).load<CString>().char = units[i];
    }
    result.elementAt(units.length).load<CString>().char = 0;
    return result;
  }
} 