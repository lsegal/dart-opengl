//  Copyright 2019 root.ext@gmail.com
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import 'dart:ffi';
import 'dart:io';

typedef GlGetProcAddressNative = Int64 Function(Pointer name);
typedef GlGetProcAddress = int Function(Pointer name);

GlGetProcAddress glGetProcAddress;

DynamicLibrary loadLibrary() {
  DynamicLibrary library;

  var name;
  if (Platform.isWindows) {
    name = 'Opengl32.dll';
  } else if (Platform.isLinux) {
    name = 'libGL.so.1';
  } else {
    throw UnsupportedError('unsupported platform ${Platform.operatingSystem}');
  }

  try {
    library = DynamicLibrary.open(name);
  } catch (ex) {
    throw Exception('failed to load OpenGL library ${name}');
  }

  var glGetProcAddressName;
  if (Platform.isWindows) {
    glGetProcAddressName = 'wglGetProcAddress';
  } else if (Platform.isLinux) {
    glGetProcAddressName = 'glXGetProcAddress';
  } else {
    throw UnsupportedError('unsupported platform ${Platform.operatingSystem}');
  }

  try {    
    glGetProcAddress = library.lookupFunction<GlGetProcAddressNative, GlGetProcAddress>(glGetProcAddressName);
    if (glGetProcAddress == null) throw Error();
  } catch (ex) {
    throw Exception('failed to loookup $glGetProcAddressName function');
  }

  return library;
}

