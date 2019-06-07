import 'dart:ffi';
import 'dart:io';
import 'c_utils.dart';

typedef GlGetProcAddressNative = Int64 Function(CString name);
typedef GlGetProcAddress = int Function(CString name);

GlGetProcAddress glGetProcAddress;

DynamicLibrary loadLibrary() {
  var gl;
  if (Platform.isWindows) {
    gl = DynamicLibrary.open('Opengl32.dll');
  } else if (Platform.isLinux) {
    gl = DynamicLibrary.open('libGL.so.1');
  }

  var glGetProcAddressName;
  if (Platform.isWindows) {
    glGetProcAddressName = 'wglGetProcAddress';
  } else if (Platform.isLinux) {
    glGetProcAddressName = 'glXGetProcAddress';
  }
  
  glGetProcAddress = gl.lookupFunction<GlGetProcAddressNative, GlGetProcAddress>(glGetProcAddressName);
  return gl;
}

