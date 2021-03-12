import 'dart:ffi';

import 'package:glfw/glfw.dart';
import 'package:opengl/opengl.dart';
import 'package:ffi/ffi.dart';

void main() {
  initGlfw();

  glfwInit();
  print('GLFW: ${Utf8.fromUtf8(glfwGetVersionString().cast<Utf8>())}');

  final window = glfwCreateWindow(
    640, 480,
    Utf8.toUtf8('Dart FFI + GLFW + OpenGL'),
    nullptr, nullptr);
  glfwMakeContextCurrent(window);

  // load OpenGL dynamic library and init all its functions
  initOpenGL();
  print('GL_VENDOR: ${Utf8.fromUtf8(glGetString(GL_VENDOR).cast<Utf8>())}');
  print('GL_RENDERER: ${Utf8.fromUtf8(glGetString(GL_RENDERER).cast<Utf8>())}');
  print('GL_VERSION: ${Utf8.fromUtf8(glGetString(GL_VERSION).cast<Utf8>())}');

  glClearColor(0.0, 0.7, 0.99, 0.0);
  glViewport(0, 0, 600, 400);

  while (glfwWindowShouldClose(window) != GLFW_TRUE) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glfwSwapBuffers(window);
    glfwPollEvents();
  }
}
