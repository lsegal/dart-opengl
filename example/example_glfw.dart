import 'package:glfw/glfw.dart';
import 'package:opengl/opengl.dart';
import 'package:opengl/src/opengl_init.dart';
import 'package:opengl/src/c_utils.dart';
import 'package:glfw/src/glfw_init.dart';

void main() {
  // create OpenGL context and make it current
  initGlfw();

  glfwInit();
  print('GLFW: ${CString.fromPointer(glfwGetVersionString()).toUtf8()}');
  var window = glfwCreateWindow(600, 400, CString.fromUtf8('Dart FFI + GLFW + OpenGL'), null, null);
  glfwMakeContextCurrent(window);

  // load OpenGL dynamic library and init all its functions
  initOpenGL();
  print("GL_VENDOR: ${CString.fromPointer(glGetString(GL_VENDOR))}");
  print("GL_RENDERER: ${CString.fromPointer(glGetString(GL_RENDERER))}");
  print("GL_VERSION: ${CString.fromPointer(glGetString(GL_VERSION))}");
  
  glClearColor(0.0, 0.7, 0.99, 0.0);
  glViewport(0, 0, 600, 400);

  while (glfwWindowShouldClose(window) != GLFW_TRUE)
  {
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      glfwSwapBuffers(window);
      glfwPollEvents();
  }
}
