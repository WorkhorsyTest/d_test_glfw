
/*
#include <GL/glew.h>

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
*/
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

struct Shader {
public:
    GLuint Program;
    // Constructor generates the shader on the fly
    this(const GLchar* vertexPath, const GLchar* fragmentPath, const GLchar* geometryPath = null) {
        // 1. Retrieve the vertex/fragment source code from filePath
        string vertexCode;
        string fragmentCode;
        string geometryCode;
        ifstream vShaderFile;
        ifstream fShaderFile;
        ifstream gShaderFile;
        // ensures ifstream objects can throw exceptions:
        vShaderFile.exceptions (ifstream.failbit | ifstream.badbit);
        fShaderFile.exceptions (ifstream.failbit | ifstream.badbit);
        gShaderFile.exceptions (ifstream.failbit | ifstream.badbit);
        try {
            // Open files
            vShaderFile.open(vertexPath);
            fShaderFile.open(fragmentPath);
            stringstream vShaderStream, fShaderStream;
            // Read file's buffer contents into streams
            vShaderStream << vShaderFile.rdbuf();
            fShaderStream << fShaderFile.rdbuf();		
            // close file handlers
            vShaderFile.close();
            fShaderFile.close();
            // Convert stream into string
            vertexCode = vShaderStream.str();
            fragmentCode = fShaderStream.str();			
			// If geometry shader path is present, also load a geometry shader
			if(geometryPath != null)
			{
                gShaderFile.open(geometryPath);
                stringstream gShaderStream;
				gShaderStream << gShaderFile.rdbuf();
				gShaderFile.close();
				geometryCode = gShaderStream.str();
			}
        } catch (ifstream.failure e) {
            cout << "ERROR.SHADER.FILE_NOT_SUCCESFULLY_READ" << endl;
        }
        const GLchar* vShaderCode = vertexCode.c_str();
        const GLchar * fShaderCode = fragmentCode.c_str();
        // 2. Compile shaders
        GLuint vertex, fragment;
        //GLint success;
        //GLchar infoLog[512];
        // Vertex Shader
        vertex = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertex, 1, &vShaderCode, NULL);
        glCompileShader(vertex);
        checkCompileErrors(vertex, "VERTEX");
        // Fragment Shader
        fragment = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragment, 1, &fShaderCode, NULL);
        glCompileShader(fragment);
		checkCompileErrors(fragment, "FRAGMENT");
		// If geometry shader is given, compile geometry shader
		GLuint geometry = 0;
		if(geometryPath != null) {
			const GLchar * gShaderCode = geometryCode.c_str();
			geometry = glCreateShader(GL_GEOMETRY_SHADER);
			glShaderSource(geometry, 1, &gShaderCode, NULL);
			glCompileShader(geometry);
			checkCompileErrors(geometry, "GEOMETRY");
		}
        // Shader Program
        this.Program = glCreateProgram();
        glAttachShader(this.Program, vertex);
        glAttachShader(this.Program, fragment);
		if(geometryPath != null)
			glAttachShader(this.Program, geometry);
        glLinkProgram(this.Program);
        checkCompileErrors(this.Program, "PROGRAM");
        // Delete the shaders as they're linked into our program now and no longer necessery
        glDeleteShader(vertex);
        glDeleteShader(fragment);
		if(geometryPath != null)
			glDeleteShader(geometry);

    }
    // Uses the current shader
    void Use() { glUseProgram(this.Program); }

private:
    void checkCompileErrors(GLuint shader, string type) {
		GLint success;
		GLchar[1024] infoLog;
		if(type != "PROGRAM") {
			glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
			if(! success) {
				glGetShaderInfoLog(shader, 1024, NULL, infoLog);
                cout << "| ERROR.SHADER-COMPILATION-ERROR of type: " << type << "|\n" << infoLog << "\n| -- --------------------------------------------------- -- |" << endl;
			}
		} else {
			glGetProgramiv(shader, GL_LINK_STATUS, &success);
			if(! success) {
				glGetProgramInfoLog(shader, 1024, NULL, infoLog);
                cout << "| ERROR.PROGRAM-LINKING-ERROR of type: " << type << "|\n" << infoLog << "\n| -- --------------------------------------------------- -- |" << endl;
			}
		}
	}
};


