import 'package:glfw/glfw.dart';
import 'package:opengl/opengl.dart';
import 'package:opengl/src/opengl_init.dart';
import 'package:opengl/src/c_utils.dart';
import 'package:glfw/src/glfw_init.dart';

void main() {
  initGlfw();

  glfwInit();
  print('GLFW: ${glfwGetVersionString().cast<CString>().toString()}');

  var monitor = glfwGetPrimaryMonitor();
  var monitorName = glfwGetMonitorName(monitor).cast<CString>().toString();
  var videomode = glfwGetVideoMode(monitor).cast<GLFWvidmode>();
  print('$monitorName ${videomode.width}x${videomode.height}');
    
  bool isFullscreen = false;
  bool isFullscreenExclusive = false;
  glfwWindowHint(GLFW_RED_BITS, videomode.redBits);
  glfwWindowHint(GLFW_GREEN_BITS, videomode.greenBits);
  glfwWindowHint(GLFW_BLUE_BITS, videomode.blueBits);
  glfwWindowHint(GLFW_REFRESH_RATE, videomode.refreshRate);
  if (isFullscreen) glfwWindowHint(GLFW_DECORATED, GLFW_FALSE);
        
  var window = glfwCreateWindow(
    isFullscreen ? videomode.width : 640, 
    isFullscreen ? videomode.height : 480, 
    CString.fromString('Dart FFI + GLFW + OpenGL'), 
    (isFullscreen && isFullscreenExclusive) ? monitor : null, null);
  if (isFullscreen) glfwSetWindowPos(window, 0, 0); 
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
