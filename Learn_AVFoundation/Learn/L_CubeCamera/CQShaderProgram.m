//
//  CQShaderProgram.m
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/7/8.
//

#import "CQShaderProgram.h"

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORDS,
    NUM_ATTRIBUTES
};


@interface CQShaderProgram ()
@property (nonatomic) GLuint shaderProgram;
@property (nonatomic) GLuint vertShader;
@property (nonatomic) GLuint fragShader;
@property (strong, nonatomic) NSMutableArray *attributes;
@property (strong, nonatomic) NSMutableArray *uniforms;
@end

@implementation CQShaderProgram

- (instancetype)initWithShaderName:(NSString *)name {
    self = [super init];
    if (self) {

        // Create shader program.
        _shaderProgram = glCreateProgram();

        NSString *vertShaderPath = [self pathForName:name type:@"vsh"];
        if (![self compileShader:&_vertShader type:GL_VERTEX_SHADER file:vertShaderPath]) {
            NSLog(@"Failed to compile vertex shader");
            self = nil;
            return self;
        }

        NSString *fragShaderPath = [self pathForName:name type:@"fsh"];
        if (![self compileShader:&_fragShader type:GL_FRAGMENT_SHADER file:fragShaderPath]) {
            NSLog(@"Failed to compile fragment shader");
            self = nil;
            return self;
        }

        // Attach vertex shader to program.
        glAttachShader(_shaderProgram, _vertShader);

        // Attach fragment shader to program.
        glAttachShader(_shaderProgram, _fragShader);
    }
    return self;
}

- (NSString *)pathForName:(NSString *)name type:(NSString *)type {
    return [[NSBundle mainBundle] pathForResource:name ofType:type];
}

- (void)addVertextAttribute:(GLKVertexAttrib)attribute named:(NSString *)name {
    glBindAttribLocation(_shaderProgram, attribute, [name UTF8String]);
}

- (GLuint)uniformIndex:(NSString *)uniform {
    return glGetUniformLocation(_shaderProgram, [uniform UTF8String]);
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }

    return YES;
}

- (BOOL)linkProgram {
    GLint status;
    glLinkProgram(_shaderProgram);

    glGetProgramiv(_shaderProgram, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    // Release vertex and fragment shaders.
    if (_vertShader) {
        glDetachShader(_shaderProgram, _vertShader);
        glDeleteShader(_vertShader);
    }

    if (_fragShader) {
        glDetachShader(_shaderProgram, _fragShader);
        glDeleteShader(_fragShader);
    }

    return YES;
}

- (void)useProgram {
    glUseProgram(_shaderProgram);
}


@end
