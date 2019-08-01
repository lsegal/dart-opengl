import 'dart:ffi';
import 'dart:io';
import 'package:ffi_utils/ffi_utils.dart';

typedef GlGetProcAddressNative = Int64 Function(CString name);
typedef GlGetProcAddress = int Function(CString name);

GlGetProcAddress glGetProcAddress;

DynamicLibrary loadLibrary() {
  var gl;
  try {
    if (Platform.isWindows) {
      gl = DynamicLibrary.open('Opengl32.dll');
    } else if (Platform.isLinux) {
      gl = DynamicLibrary.open('libGL.so.1');
    }
  } catch(ex) {
    throw Exception('failed to load OpenGL library');
  }

  try {
    var glGetProcAddressName;
    if (Platform.isWindows) {
      glGetProcAddressName = 'wglGetProcAddress';
    } else if (Platform.isLinux) {
      glGetProcAddressName = 'glXGetProcAddress';
    }
    glGetProcAddress = gl.lookupFunction<GlGetProcAddressNative, GlGetProcAddress>(glGetProcAddressName);
  } catch(ex) {
    throw Exception('failed to loookup $glGetProcAddress function');
  }

  return gl;
}

