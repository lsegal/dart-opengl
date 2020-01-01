import 'dart:ffi';

import 'package:glfw/glfw.dart';
import 'package:opengl/opengl.dart';
import 'package:ffi_utils/ffi_utils.dart';
import 'package:opengl/src/opengl_init.dart';
import 'package:glfw/src/glfw_init.dart';

void main() {
  initGlfw();

  glfwInit();
  print('GLFW: ${NativeString.fromPointer(glfwGetVersionString())}');
        
  var window = glfwCreateWindow(
    640, 
    480, 
    NativeString.fromString('Dart FFI + GLFW + OpenGL'), 
    nullptr.cast(), nullptr.cast());
  glfwMakeContextCurrent(window);
  
  // load OpenGL dynamic library and init all its functions
  initOpenGL();
  print("GL_VENDOR: ${NativeString.fromPointer(glGetString(GL_VENDOR))}");
  print("GL_RENDERER: ${NativeString.fromPointer(glGetString(GL_RENDERER))}");
  print("GL_VERSION: ${NativeString.fromPointer(glGetString(GL_VERSION))}");
  
  glClearColor(0.0, 0.7, 0.99, 0.0);
  glViewport(0, 0, 600, 400);

  while (glfwWindowShouldClose(window) != GLFW_TRUE)
  {
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      glfwSwapBuffers(window);
      glfwPollEvents();
  }
}
