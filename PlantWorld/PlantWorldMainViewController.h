//
//  PlantWorldMainViewController.h
//  PlantWorld
//
//  Created by henry florence on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlantWorldFlipsideViewController.h"
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Plant.h"

#define X .525731112119133606 
#define Z .850650808352039932
#define EPSILON 0.00000000001f
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface PlantNode : NSObject /* {
//@public
    int numPlants;
    Plant *plant;
    PlantNode *next;
} */
@property (assign) float moistureRequirement;
@property (assign) int numPlants;
@property (assign) Plant *plant;
@property (assign) PlantNode *next;

@end

@implementation PlantNode
@synthesize moistureRequirement;
@synthesize numPlants;
@synthesize plant;
@synthesize next;

@end

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];
GLint colorLocation;

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

void normalise(float v[3]);
void normcrossprod(float v1[3], float v2[3], float out[3]);
void storeTriangle(GLfloat*, GLfloat*, GLfloat*, GLfloat*); 
bool checkNeighbour(GLfloat*, GLfloat*);
bool comparePoints(GLfloat*, GLfloat*); 

@interface PlantWorldMainViewController : GLKViewController <PlantWorldFlipsideViewControllerDelegate, UIPopoverControllerDelegate> {
    IBOutlet UILabel *outputLabel;
    IBOutlet UIView *gestureView;
    
    //OpenGL Stuff
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _glBuffers[2];
    GLuint _colorBuffer;
    GLuint _normalBuffer;
@private
    //GLKBaseEffect *effect;
    float scaleFactor;
    GLfloat *vData;
    GLubyte *cData;
    int *nData;
    int subdivision;
    int timeStep;
    int totalMoisture;
    
    int genome[12];
    NSMutableArray *plants;
}

@property (nonatomic, retain) UIView *outputLabel;
@property (nonatomic, retain) UIView *gestureView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

///OpenGL stuff
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

/*#pragma mark GLKViewControllerDelegate
-(void)glkViewControllerUpdate:(GLKViewController *)controller;

#pragma mark GLKViewDelegate
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
*/

-(void) checkNeighbours;
-(void) findNeighbours;
-(void) printNeighbours;
-(void) geomData;
-(void) randomColours;
-(void) subdivide:(GLfloat*)bData index:(int)index;
-(void) alterSubdivision:(int)subdivision;
@end
