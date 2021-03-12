import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:glfw/glfw.dart';
import 'package:opengl/opengl.dart';
import 'package:ffi/ffi.dart';
import 'package:ffi_utils/ffi_utils.dart';

const int width = 640;
const int height = 480;
Pointer<Uint32> arrays;
Pointer<Uint32> textures;
int program;
int locationTime;
int locationTexture;

void main() {
  // load GLFW dynamic library and init all its functions
  initGlfw();

  glfwInit();
  print('GLFW: ${Utf8.fromUtf8(glfwGetVersionString().cast<Utf8>())}');

  final window = glfwCreateWindow(
    width, height,
    Utf8.toUtf8('Dart FFI + GLFW + OpenGL'),
    nullptr, nullptr);
  glfwMakeContextCurrent(window);

  // load OpenGL dynamic library and init all its functions
  initOpenGL();
  print('GL_VENDOR: ${Utf8.fromUtf8(glGetString(GL_VENDOR).cast<Utf8>())}');
  print('GL_RENDERER: ${Utf8.fromUtf8(glGetString(GL_RENDERER).cast<Utf8>())}');
  print('GL_VERSION: ${Utf8.fromUtf8(glGetString(GL_VERSION).cast<Utf8>())}');

  prepare(width, height);

  while (glfwWindowShouldClose(window) != GLFW_TRUE) {
    draw(DateTime.now().millisecondsSinceEpoch);

    glfwSwapBuffers(window);
    glfwPollEvents();
  }
}

void draw(int timeMs) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glUseProgram(program);
  final phase = (timeMs % 1000) / 1000.0 * 2 * pi;
  glUniform1f(locationTime, sin(phase) * 0.2 + 0.8);

  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textures[0]);
  glUniform1i(locationTexture, 0);

  glBindVertexArray(arrays[0]);
  glDrawArrays(GL_TRIANGLES, 0, 6);

  glBindVertexArray(0);
}

void prepare(int width, int height) {
  glInfo();

  glClearColor(0.0, 0.7, 0.99, 0.0);
  glViewport(0, 0, width, height);

  final vertexShader = glCreateShader(GL_VERTEX_SHADER);
  shader(vertexShader, vertexCode);

  final fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  shader(fragmentShader, fragmentCode);

  program = glCreateProgram();
  glAttachShader(program, vertexShader);
  glAttachShader(program, fragmentShader);

  glBindAttribLocation(program, 0, NativeString.fromString('in_Position'));
  glBindAttribLocation(program, 1, NativeString.fromString('in_Color'));
  glBindAttribLocation(program, 2, NativeString.fromString('in_Texture'));

  glLinkProgram(program);
  locationTime = glGetUniformLocation(program, NativeString.fromString('in_Time'));
  locationTexture = glGetUniformLocation(program, NativeString.fromString('texture1'));

  arrays = allocate<Uint32>();
  glGenVertexArrays(1, arrays);

  final buffers = allocate<Uint32>(count: 3);
  glGenBuffers(3, buffers);
  
  glBindVertexArray(arrays[0]);

  glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
  glBufferData(GL_ARRAY_BUFFER, positionData.lengthInBytes, NativeBuffer.fromTyped(positionData), GL_STATIC_DRAW);

  glVertexAttribPointer(0, 3, GL_FLOAT, 0/*false*/, 0, 0);
  glEnableVertexAttribArray(0);

  glBindBuffer(GL_ARRAY_BUFFER, buffers[1]);
  glBufferData(GL_ARRAY_BUFFER, colorData.lengthInBytes, NativeBuffer.fromTyped(colorData), GL_STATIC_DRAW);
  glVertexAttribPointer(1, 3, GL_FLOAT, 0/*false*/, 0, 0);
  glEnableVertexAttribArray(1);

  glBindBuffer(GL_ARRAY_BUFFER, buffers[2]);
  glBufferData(GL_ARRAY_BUFFER, uvData.lengthInBytes, NativeBuffer.fromTyped(uvData), GL_STATIC_DRAW);
  glVertexAttribPointer(2, 2, GL_FLOAT, 0/*false*/, 0, 0);
  glEnableVertexAttribArray(2);

  textures = allocate<Uint32>();
  glGenTextures(1, textures);
  
  glBindTexture(GL_TEXTURE_2D, textures[0]);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 2, 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, NativeBuffer.fromTyped(textureData));
}

void shader(int shader, String text) {
  final lines = text.split('\n').map((l) => l + '\n').toList();
  
  glShaderSource(shader, lines.length, NativeStringArray.fromList(lines), nullptr.cast());
  glCompileShader(shader);

  final status = allocate<Int32>();
  glGetShaderiv(shader, GL_COMPILE_STATUS, status);
  if (status.value != GL_TRUE) {
    print('shader status ${status.value}');

    final length = allocate<Int32>();
    final infoLog = NativeString.fromLength(1024 + 1);
    glGetShaderInfoLog(shader, 1024, length, infoLog);

    if (length.value > 0) {
      print(infoLog.ref);
    }
  }
}

void glInfo() {
  print('GL_VENDOR: ${NativeString.fromPointer(glGetString(GL_VENDOR))}');
  print('GL_RENDERER: ${NativeString.fromPointer(glGetString(GL_RENDERER))}');
  print('GL_VERSION: ${NativeString.fromPointer(glGetString(GL_VERSION))}');
}

const vertexCode = '''
#version 130

uniform float in_Time;
in vec3 in_Position;
in vec3 in_Color;
in vec2 in_Texture;
out vec3 ex_Color;
out vec2 ex_Texture;

void main(void)
{
  gl_Position = vec4(in_Position.x*in_Time, in_Position.y*in_Time, in_Position.z*in_Time, 1.0);
  ex_Color = vec3(in_Color.r, in_Color.g, in_Color.b);
  ex_Texture = in_Texture;
}
''';

const fragmentCode = '''
#version 130

precision highp float; // needed only for version 1.30

uniform sampler2D texture1;
in vec3 ex_Color;
in vec2 ex_Texture;
out vec4 out_Color;

void main(void)
{
  vec4 tex = texture(texture1, ex_Texture).xyzw;
  vec4 color = vec4(ex_Color,1.0);
  out_Color = mix(tex, color, 0.9);
}
''';

var positionData = Float32List.fromList([
  1.0, 1.0, -1.0, -1.0, -1.0,-1.0, 1.0, -1.0, -1.0,
  1.0, 1.0, -1.0, -1.0, -1.0,-1.0, -1.0, 1.0, -1.0]);

var colorData = Float32List.fromList([
  1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
  1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]);

var uvData = Float32List.fromList([
  0.0, 0.0, 1.0, 1.0, 0.0, 1.0,
  0.0, 0.0, 1.0, 1.0, 1.0, 0.0]);

var textureData = Uint8List.fromList([
  255,0,255,255, 255,255,255,255, 
  255,255,255,255, 255,0,255,128]); 