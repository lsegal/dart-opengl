import 'dart:ffi';
import 'dart:io';

typedef GlGetProcAddressNative = Int64 Function(Pointer name);
typedef GlGetProcAddress = int Function(Pointer name);

GlGetProcAddress glGetProcAddress;

DynamicLibrary loadLibrary() {
  DynamicLibrary gl;
  try {
    if (Platform.isWindows) {
      gl = DynamicLibrary.open('Opengl32.dll');
    } else if (Platform.isLinux) {
      gl = DynamicLibrary.open('libGL.so.1');
    } else {
      throw UnsupportedError('');
    }
  } catch(ex) {
    throw Exception('failed to load OpenGL library');
  }

  var glGetProcAddressName;
  try {
    if (Platform.isWindows) {
      glGetProcAddressName = 'wglGetProcAddress';
    } else if (Platform.isLinux) {
      glGetProcAddressName = 'glXGetProcAddress';
    }
    glGetProcAddress = gl.lookupFunction<GlGetProcAddressNative, GlGetProcAddress>(glGetProcAddressName);
  } catch(ex) {
    throw Exception('failed to loookup $glGetProcAddressName function');
  }

  return gl;
}

