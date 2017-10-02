

import std.stdio : stdout, stderr;
import std.traits : isSomeString;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.gfx.gfx;
import derelict.sdl2.gfx.primitives;
import derelict.sdl2.mixer;
import derelict.sdl2.ttf;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

/*
instead of this glBegin, glEnd crap do like this:
https://github.com/progschj/OpenGL-Examples/blob/master/03texture.cpp
or:
https://github.com/WorkhorsyTest/glfw_texture/blob/master/glwf_version/main.cpp
*/

void InitDerelict() {
	import std.file : chdir;

	// Change to the directory with the Windows libraries
	chdir("lib/windows/x86_64");

	string[] errors;

	try {
		DerelictSDL2.load(SharedLibVersion(2, 0, 2));
	} catch (Throwable) {
		errors ~= "Failed to find the library SDL2.";
	}

	try {
		DerelictSDL2Image.load();
	} catch (Throwable) {
		errors ~= "Failed to find the library SDL2 Image.";
	}
/*
	try {
		DerelictSDL2Gfx.load();
	} catch (Throwable) {
		errors ~= "Failed to find the library SDL2 GFX.";
	}
*/
///*
	// Load SDL2 GFX normal
	bool is_sdl_gfx_loaded = false;
	if (! is_sdl_gfx_loaded) {
		try {
			DerelictSDL2Gfx.load();
			is_sdl_gfx_loaded = true;
		} catch (Throwable) {
		}
	}

	// Load SDL2 GFX on Linux with strange paths
	immutable string[] libNames = [
		"/usr/lib64/libSDL2_gfx-1.0.so.0",
		"/usr/lib/x86_64-linux-gnu/libSDL2_gfx-1.0.so.0"
	];
	if (! is_sdl_gfx_loaded) {
		foreach (libName ; libNames) {
			try {
				DerelictSDL2Gfx.load(libName);
				is_sdl_gfx_loaded = true;
				break;
			} catch (Throwable) {
			}
		}
	}

	if (! is_sdl_gfx_loaded) {
		errors ~= "Failed to find the library SDL2 GFX.";
	}
//*/

	try {
		DerelictSDL2Mixer.load();
	} catch (Throwable) {
		errors ~= "Failed to find the library SDL2 Mixer.";
	}

	try {
		DerelictSDL2ttf.load();
	} catch (Throwable) {
		errors ~= "Failed to find the library SDL2 TTF.";
	}

	try {
		DerelictGL3.load();
	} catch (Throwable) {
		errors ~= "Failed to find the library OpenGL3.";
	}

	try {
		DerelictGLFW3.load();
	} catch (Throwable) {
		errors ~= "Failed to find the library GLFW3.";
	}

	chdir("../../..");

	foreach (error ; errors) {
		stderr.writeln(error);
	}
	if (errors.length > 0) {
		import std.array : join;
		throw new Exception(join(errors, "\r\n"));
	}
}

// helper to check and display for shader compiler errors
bool check_shader_compile_status(GLuint obj) {
    GLint status;
    glGetShaderiv(obj, GL_COMPILE_STATUS, &status);
    if(status == GL_FALSE) {
        GLint length;
        glGetShaderiv(obj, GL_INFO_LOG_LENGTH, &length);
//        std::vector<char> log(length);
//        glGetShaderInfoLog(obj, length, &length, &log[0]);
//        std::cerr << &log[0];
        return false;
    }
    return true;
}

// helper to check and display for shader linker error
bool check_program_link_status(GLuint obj) {
    GLint status;
    glGetProgramiv(obj, GL_LINK_STATUS, &status);
    if(status == GL_FALSE) {
        GLint length;
        glGetProgramiv(obj, GL_INFO_LOG_LENGTH, &length);
//        std::vector<char> log(length);
//        glGetProgramInfoLog(obj, length, &length, &log[0]);
//        std::cerr << &log[0];
        return false;
    }
    return true;
}

int main() {
	InitDerelict();

	int width = 640;
    int height = 480;

    if(glfwInit() == GL_FALSE) {
        stderr.writefln("failed to init GLFW"); stderr.flush();
        return 1;
    }

    // select opengl version
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

    // create a window
    GLFWwindow *window;
    if((window = glfwCreateWindow(width, height, "03texture", null, null)) == null) {
        stderr.writefln("failed to open window"); stderr.flush();
        glfwTerminate();
        return 1;
    }

	glfwMakeContextCurrent(window);

	// shader source code
	string vertex_source =
	q{
		#version 330
		layout(location = 0) in vec4 vposition;
		layout(location = 1) in vec2 vtexcoord;
		out vec2 ftexcoord;
		void main() {
		ftexcoord = vtexcoord;
			gl_Position = vposition;
		}
	};

	string fragment_source =
	q{
		#version 330
		uniform sampler2D tex; // texture uniform
		in vec2 ftexcoord;
		layout(location = 0) out vec4 FragColor;
		void main() {
		   FragColor = texture(tex, ftexcoord);
		}
	};

	// program and shader handles
    GLuint shader_program, vertex_shader, fragment_shader;

    // we need these to properly pass the strings
    char* source;
    int length;

    // create and compiler vertex shader
	stdout.writefln("glCreateShader ..."); stdout.flush();
    vertex_shader = glCreateShader(GL_VERTEX_SHADER);
	stdout.writefln("Main loop ..."); stdout.flush();
    source = cast(char*) vertex_source;
    length = cast(int) vertex_source.length;
    glShaderSource(vertex_shader, 1, &source, &length);
    glCompileShader(vertex_shader);
    if(! check_shader_compile_status(vertex_shader)) {
        glfwDestroyWindow(window);
        glfwTerminate();
        return 1;
    }

	stdout.writefln("Main loop ..."); stdout.flush();

	return 0;
}
