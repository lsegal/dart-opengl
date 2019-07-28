import 'package:glfw/glfw.dart';
import 'package:opengl/opengl.dart';
import 'package:opengl/src/opengl_init.dart';
import 'package:opengl/src/c_utils.dart';
import 'package:glfw/src/glfw_init.dart';

void main() {
  // create OpenGL context and make it current
  initGlfw();

  glfwInit();
  print('GLFW: ${CString.fromPointer(glfwGetVersionString()).toString()}');

  var monitor = glfwGetPrimaryMonitor();
  var vm = glfwGetVideoMode(monitor).cast<GLFWvidmode>();
  var name = glfwGetMonitorName(monitor).cast<CString>().toString();
  print(name);

  bool isFullscreen = false;
  glfwWindowHint(GLFW_RED_BITS, vm.redBits);
  glfwWindowHint(GLFW_GREEN_BITS, vm.greenBits);
  glfwWindowHint(GLFW_BLUE_BITS, vm.blueBits);
  glfwWindowHint(GLFW_REFRESH_RATE, vm.refreshRate);
  //glfwWindowHint(GLFW_DECORATED, GLFW_FALSE);
  //glfwWindowHint(GLFW_FLOATING, GLFW_TRUE);
  glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER, GLFW_TRUE);
  

  var window = glfwCreateWindow(isFullscreen ? vm.width : 480, 
    isFullscreen ? vm.height : 480, CString.fromString('Dart FFI + GLFW + OpenGL'), 
    isFullscreen ? monitor : null, null);
  if (isFullscreen) glfwSetWindowPos(window, 0, 0); 
  glfwMakeContextCurrent(window);

  // load OpenGL dynamic library and init all its functions
  initOpenGL();
  print("GL_VENDOR: ${CString.fromPointer(glGetString(GL_VENDOR))}");
  print("GL_RENDERER: ${CString.fromPointer(glGetString(GL_RENDERER))}");
  print("GL_VERSION: ${CString.fromPointer(glGetString(GL_VERSION))}");
  
  glClearColor(0.1, 0.1, 0.1, 0.4);
  glViewport(0, 0, 600, 400);

  while (glfwWindowShouldClose(window) != GLFW_TRUE)
  {
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      glfwSwapBuffers(window);
      glfwPollEvents();
  }
}
