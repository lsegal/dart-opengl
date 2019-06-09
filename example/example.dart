import 'package:opengl/opengl.dart';
import 'package:opengl/src/opengl_init.dart';

void main() {
  // create OpenGL context and make it current
  //...

  // load OpenGL dynamic library and init all its functions
  initOpenGL();

  // use OpenGL
  //...
  var result = glGetError();

  // glGetError returns GL_NO_ERROR if successful, 
  // or GL_INVALID_OPERATION = 0x0502 (1282) without context in our case
  print('glGetError() result is ${result == GL_NO_ERROR ? "GL_NO_ERROR" : result}');
}
