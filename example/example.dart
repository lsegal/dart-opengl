import 'package:opengl/src/opengl_init.dart';

void main() {
  // create OpenGL context and make it current
  //...

  // load OpenGL dynamic library and init all OpenGL functions
  initOpenGL();

  // use OpenGL
  //...

  // glGetError must return GL_INVALID_OPERATION = 0x0502 without context
  print(glGetError());
}
