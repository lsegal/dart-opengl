import 'dart:ffi';
import 'dart:typed_data';
import 'dart:convert';

List<Pointer> links = [];

class CString extends Pointer<Uint8> {
  
  factory CString.fromBytes(List<int> bytes) {
    CString result = allocate<Uint8>(count: bytes.length + 1).cast();
    for (int i = 0; i < bytes.length; i++) {
      result.elementAt(i).store(bytes[i]);
    }
    result.elementAt(bytes.length).store(0);
    links.add(result);    
    return result;
  }
  
  factory CString.fromString(String s) {
    List<int> bytes = Utf8Encoder().convert(s);
    return CString.fromBytes(bytes);
  }

  factory CString.filled(int length, {int char = 0}) {
    return CString.fromBytes(List.filled(length, char));
  }

  factory CString.fromPointer(Pointer pointer) {
    CString result = fromAddress(pointer.address);
    return result;
  }

  String toString({int length}) {
    List<int> units = [];
    int len = 0;
    while (true) {
      int char = elementAt(len++).load<int>();
      if ((length == null && char == 0) || (length != null && len >= length)) break;
      units.add(char);
    }
    return Utf8Decoder().convert(units);
  }
}

class CBuffer extends Pointer<Uint8> {  
  factory CBuffer.fromBytes(List<int> bytes) {
    CBuffer result = allocate<Uint8>(count: bytes.length).cast();
    for (int i = 0; i < bytes.length; i++) {
      result.elementAt(i).store(bytes[i]);
    }
    links.add(result);
    return result;
  }

  factory CBuffer.fromTyped(TypedData data) {
    List<int> bytes = data.buffer.asUint8List();
    return CBuffer.fromBytes(bytes);
  }
}

class CStringList extends Pointer<IntPtr> {
  factory CStringList.fromList(List<String> l) {
    CStringList result = allocate<IntPtr>(count: l.length).cast();
    List<int> pointers = l.map((s) => CString.fromString(s).address).toList();
    for (int i = 0; i < l.length; i++) {
      result.elementAt(i).store(pointers[i]);
    }
    links.add(result);
    return result;
  }  
}


class CIntArray {
  CBuffer buffer;
  int _elementSizeInBytes;

  CIntArray();

  factory CIntArray.fromTyped(TypedData d) {
    CIntArray result = new CIntArray();
    result.buffer = CBuffer.fromTyped(d);
    result._elementSizeInBytes = d.elementSizeInBytes;
    return result;
  }

  operator [](int i) {
    switch (_elementSizeInBytes) {
      case 1:
        return buffer.cast<Pointer<Int8>>().elementAt(i).load<int>();
      case 2:
        return buffer.cast<Pointer<Int16>>().elementAt(i).load<int>();
      case 4:
        return buffer.cast<Pointer<Int32>>().elementAt(i).load<int>();
      case 8:
        return buffer.cast<Pointer<Int64>>().elementAt(i).load<int>();
    }
  }
}
