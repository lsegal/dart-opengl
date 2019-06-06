import 'dart:ffi';
import 'dart:typed_data';
import 'dart:convert';

List<Pointer> links = [];

class CString extends Pointer<Uint8> {
  CString elementAt(int index) => super.elementAt(index).cast();

  String toUtf8({int length}) {
    List<int> units = [];
    int len = 0;
    while (true) {
      int char = elementAt(len++).load<int>();
      if ((length == null && char == 0) || (length != null && len >= length)) break;
      units.add(char);
    }
    return Utf8Decoder().convert(units);
  }

  factory CString.fromUtf8(String s) {
    CString result = allocate<Uint8>(count: s.length + 1).cast();
    List<int> units = Utf8Encoder().convert(s);
    for (int i = 0; i < s.length; i++) {
      result.elementAt(i).store(units[i]);
    }
    result.elementAt(s.length).store(0);
    links.add(result);
    return result;
  }

  factory CString.fromLength(int length) {
    CString result = allocate<Uint8>(count: length).cast();
    for (int i = 0; i < length; i++) { 
      result.elementAt(i).store(0);
    }
    return result;
  }

  factory CString.fromPointer(Pointer pointer) {
    CString result = fromAddress(pointer.address);
    return result;
  }

  String toString() {
    return toUtf8();
  }
}

class CBufferX {
  CBuffer pointer;
  int _elementSizeInBytes;

  CBufferX();

  factory CBufferX.fromTyped(TypedData d) {
    CBufferX result = new CBufferX();
    result.pointer = CBuffer.fromTyped(d);
    result._elementSizeInBytes = d.elementSizeInBytes;
    return result;
  }

  operator [](int i) {
    switch (_elementSizeInBytes) {
      case 1:
        return pointer.cast<Pointer<Int8>>().elementAt(i).load<int>();
      case 2:
        return pointer.cast<Pointer<Int16>>().elementAt(i).load<int>();
      case 4:
        return pointer.cast<Pointer<Int32>>().elementAt(i).load<int>();
      case 8:
        return pointer.cast<Pointer<Int64>>().elementAt(i).load<int>();
    }
  }
}

class CBuffer extends Pointer<Uint8> {
  factory CBuffer.fromTyped(TypedData d) {
    CBuffer result = allocate<Uint8>(count: d.lengthInBytes).cast();
    List<int> bytes = d.buffer.asUint8List();
    for (int i = 0; i < d.lengthInBytes; i++) {
      result.elementAt(i).store(bytes[i]);
    }
    links.add(result);
    return result;
  }
}

class CStringList extends Pointer<IntPtr> {
  factory CStringList.fromList(List<String> l) {
    CStringList result = allocate<IntPtr>(count: l.length).cast();
    List<int> pointers = l.map((s) => CString.fromUtf8(s).address).toList();
    for (int i = 0; i < l.length; i++) {
      result.elementAt(i).store(pointers[i]);
    }
    links.add(result);
    return result;
  }
}
