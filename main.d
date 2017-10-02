

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

	foreach (error ; errors) {
		stderr.writeln(error);
	}
	if (errors.length > 0) {
		import std.array : join;
		throw new Exception(join(errors, "\r\n"));
	}
}

/*
float width = 200, height = 200;
float bpp = 0;
float near = 10.0, far = 100000.0, fovy = 45.0;
float[3] position = [0,0,-40];
const float[9] triangle = [
	  0,  10, 0,  // top point
	-10, -10, 0,  // bottom left
	 10, -10, 0   // bottom right
];
float rotate_degrees  = 90;
float[3] rotate_axis = [0,1,0];

SDL_Surface* screen = null;
*/
public char* toSZ(S)(S value)
if(isSomeString!S) {
	import std.string : toStringz;
	return cast(char*)toStringz(value);
}

string GetSDLError() {
	import std.string : fromStringz;
	return cast(string) fromStringz(SDL_GetError());
}

bool IsSurfaceRGBA8888(const SDL_Surface* surface) {
	return (surface.format.Rmask == 0xFF000000 &&
			surface.format.Gmask == 0x00FF0000 &&
			surface.format.Bmask == 0x0000FF00 &&
			surface.format.Amask == 0x000000FF);
}

SDL_Surface* EnsureSurfaceRGBA8888(SDL_Surface* surface) {
	import std.string : format;

	// Just return if it is already RGBA8888
	if (IsSurfaceRGBA8888(surface)) {
		return surface;
	}

	// Convert the surface into a new one that is RGBA8888
	SDL_Surface* new_surface = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA8888, 0);
	if (new_surface == null) {
		throw new Exception("Failed to convert surface to RGBA8888 format: %s".format(GetSDLError()));
	}
	SDL_FreeSurface(surface);

	// Make sure the new surface is RGBA8888
	if (! IsSurfaceRGBA8888(new_surface)) {
		throw new Exception("Failed to convert surface to RGBA8888 format: %s".format(GetSDLError()));
	}
	return new_surface;
}

SDL_Surface* LoadSurface(const string file_name) {
	import std.file : exists;
	import std.string : format;

	string complete_name = file_name;
	if (! exists(complete_name)) {
		throw new Exception("File does not exist: %s".format(complete_name));
	}

	SDL_Surface* surface = IMG_Load(complete_name.toSZ);
	if (surface == null) {
		throw new Exception("Failed to load surface \"%s\": %s".format(file_name, GetSDLError()));
	}

	if (surface.format.BitsPerPixel < 32) {
		throw new Exception("Image has no alpha channel \"%s\"".format(file_name));
	}

	surface = EnsureSurfaceRGBA8888(surface);

	return surface;
}
/*
void render() {
	glClear(GL_COLOR_BUFFER_BIT);

	glLoadIdentity();

	glTranslatef(position[0], position[1], position[2]);

	{
		static Uint32 last = 0;
		static float angle = 0;

		Uint32 now = SDL_GetTicks();
		float delta = (now - last) / 1000.0f; // in seconds
		last = now;

		angle += rotate_degrees * delta;

		// c modulo operator only supports ints as arguments
		auto MOD(T)(T n, T d) { return (n - (d * cast(int) ( n / d ))); }
		angle = MOD( angle, 360 );

		glRotatef( angle, rotate_axis[0], rotate_axis[1], rotate_axis[2] );
	}

	glBegin(GL_TRIANGLES);
	for (int i=0; i<=6; i+=3) {
		glColor3f(i==0, i==3, i==6); // adding some color
		glVertex3fv(&triangle[i]);
	}
	glEnd();

	SDL_GL_SwapBuffers();
}
*/



extern (C) void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) nothrow {
	try {
		stderr.writefln("key:%s, scancode:%s, action:%s, mods:%s", key, scancode, action, mods); stderr.flush();
	} catch (Throwable) {
	}

	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
		glfwSetWindowShouldClose(window, true);
	}
}

extern (C) void error_callback(int error, const(char)* description) nothrow {
	try {
		stderr.writefln("error: %s", description); stderr.flush();
	} catch (Throwable) {
	}
}

int main() {
	stdout.writefln("InitDerelict ..."); stdout.flush();
	InitDerelict();

	// Initialize SDL
	if (SDL_Init(SDL_INIT_VIDEO) != 0) {
		stderr.writefln("Could not initialize SDL: %s", SDL_GetError());
		return 1;
	}

	stdout.writefln("glfwInit ..."); stdout.flush();
	if (! glfwInit()) {
		return 1;
	}

	stdout.writefln("glfwSetErrorCallback ..."); stdout.flush();
	glfwSetErrorCallback(&error_callback);

	stdout.writefln("window ..."); stdout.flush();
	/* Create a windowed mode window and its OpenGL context */
	GLFWwindow* window = glfwCreateWindow(640, 480, "Hello World", null, null);
	if (!window) {
			glfwTerminate();
			return 1;
	}

	glfwSetKeyCallback(window, &key_callback);

	/* Make the window's context current */
	glfwMakeContextCurrent(window);

	/* Loop until the user closes the window */
	while (! glfwWindowShouldClose(window)) {
			//stdout.writefln("loop ..."); stdout.flush();
			/* Render here */
			glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );
			glClear(GL_COLOR_BUFFER_BIT);

			glMatrixMode(GL_MODELVIEW); //Switch to the drawing perspective
	   glLoadIdentity(); //Reset the drawing perspective
	     glTranslatef(0.0f,0.0f,-35.0f); //Translate whole scene to -ve z-axis by -35 unit

	     GLuint text2D;
	     text2D = LoadTexture("cicb.tga"); //loading image for texture

	     glEnable(GL_TEXTURE_2D); //Enable texture
	     glBindTexture(GL_TEXTURE_2D,text2D);//Binding texture
	     glPushMatrix();
	     glBegin(GL_POLYGON); //Begin quadrilateral coordinates
	     glNormal3f(0.0f, 0.0f, 1.0f);//normal vector
	   glTexCoord2f(0.0f, 0.0f); //Texture co-ordinate origin or  lower left corner
	   glVertex3f(-10.0f,-11.0f,5.0f);
	   glTexCoord2f(1.0f, 0.0f); //Texture co-ordinate lower right corner
	   glVertex3f(10.0f,-11.0f,5.0f);
	   glTexCoord2f(1.0f, 1.0f);//Texture co-ordinate top right corner
	   glVertex3f(10.0f,-1.0f,-15.0f);
	   glTexCoord2f(0.0f, 1.0f);//Texture co-ordinate top left corner
	   glVertex3f(-10.0f,-1.0f,-15.0f);
	   glEnd(); //End quadrilateral coordinates

	   glPopMatrix();

	   glDisable(GL_TEXTURE_2D);



	     glEnable(GL_TEXTURE_2D);
	     glBindTexture(GL_TEXTURE_2D,text2D);
	     glPushMatrix();
	     glBegin(GL_POLYGON);
	     glNormal3f(0.0f, 0.0f, 1.0f);
	   	glTexCoord2f(0.0f, 0.0f);//Texture co-ordinate origin or lower left corner
	     glVertex3f(-10.0f,-1.0f,-15.0f);
	     glTexCoord2f(10.0f, 0.0f); //Texture co-ordinate for repeating image ten times form
	     //origin to lower right corner
	     glVertex3f(10.0f,-1.0f,-15.0f);
	     glTexCoord2f(10.0f, 10.0f);//repeat texture ten times form lower to top right corner.
	     glVertex3f(10.0f,15.0f,-15.0f);
	     glTexCoord2f(0.0f, 10.0f);//repeat texture ten time form top right to top left corner.
	     glVertex3f(-10.0f,15.0f,-15.0f);
	     glEnd();
	     glPopMatrix();
	     glDisable(GL_TEXTURE_2D); //Disable the texture

			/* Swap front and back buffers */
			glfwSwapBuffers(window);

			/* Poll for and process events */
			glfwPollEvents();
	}

	glfwTerminate();

/*
	// Initialize SDL
	if (SDL_Init(SDL_INIT_VIDEO) != 0) {
		fprintf(stderr, "Could not initialize SDL: %s\n", SDL_GetError());
		return 1;
	}

	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1 );

	screen = SDL_SetVideoMode(
		width, height, bpp,
		SDL_ANYFORMAT | SDL_OPENGL );

	glViewport(0, 0, width, height);

	glPolygonMode( GL_FRONT, GL_FILL );
	glPolygonMode( GL_BACK,  GL_LINE );

	glMatrixMode(GL_PROJECTION);
	gluPerspective(fovy,width/height,near,far);

	glMatrixMode(GL_MODELVIEW);

	// ===================
	// Texture 2
	// ===================
	GLuint texture2;
	glGenTextures(1, &texture2);
	glBindTexture(GL_TEXTURE_2D, texture2);
	// Set our texture parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	// Set texture filtering
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// Load, create texture and generate mipmaps
	SDL_Surface* surface = null;
	try {
		//LoadSurface("awesomeface.png");
	} catch (Throwable err) {
		//std::exception_ptr err = std::current_exception();
		stderr.writefln("!!! %s", err);
		return 1;
	}
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, surface.w, surface.h, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, surface.pixels);
	glGenerateMipmap(GL_TEXTURE_2D);
	SDL_FreeSurface(surface);
	glBindTexture(GL_TEXTURE_2D, 0);


	while (true) {
		SDL_Event event;
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_QUIT:
					SDL_Quit();
					break;
			}
		}

		render();
	}
*/
	return 0;
}
