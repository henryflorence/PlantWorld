//
//  PlantWorldMainViewController.m
//  PlantWorld
//
//  Created by henry florence on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlantWorldMainViewController.h"

@implementation PlantWorldMainViewController

@synthesize gestureView;
@synthesize outputLabel;
@synthesize flipsidePopoverController = _flipsidePopoverController;

//OpenGL stuff
@synthesize context = _context;
@synthesize effect = _effect;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) setGenomeElement:(int)index value:(int)value {
    genome[index] = value;
}

-(int*) getGenome {
    return genome;
}
- (void) alterSubdivision:(int)value {
    if (value==subdivision) return;
    
    subdivision = value;
    [self tearDownGL];
    [self geomData];
    [self randomColours];
    [self findNeighbours];
    [self setupGL];
    //[self printNeighbours];
    //[self checkNeighbours];
}
- (int) getSubdivision {
    return subdivision;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    scaleFactor = .6f;
    subdivision = 0;
    timeStep = 0;
    totalMoisture = 544;
    cData = NULL;
    vData = NULL;
    nData = NULL;
    
    plants = [[NSMutableArray alloc] init];
    
    static int startGenome[] = { 0,1,2,0,1,2,0,1,2,0,1,2 };
    for(int i=0; i<12; i++) genome[i] = startGenome[i];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    UIPinchGestureRecognizer *pinchRecogniser = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(foundPinch:)];
    [self.view addGestureRecognizer:pinchRecogniser];
    
    //Taps
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer=[[UITapGestureRecognizer alloc] 
				   initWithTarget:self
				   action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired=1;
	tapRecognizer.numberOfTouchesRequired=1;
    [gestureView addGestureRecognizer:tapRecognizer];
    
    outputLabel.text=@"hiya!";
    
    [self geomData];
    [self findNeighbours];
    [self printNeighbours];
    [self checkNeighbours];
    [self randomColours];
    [self setupGL];
}
-(void) geomData {
    static GLfloat icosahedronVertices[] = {    
        -X, 0.0, Z, X, 0.0, Z, -X, 0.0, -Z, X, 0.0, -Z,    
        0.0, Z, X, 0.0, Z, -X, 0.0, -Z, X, 0.0, -Z, -X,    
        Z, X, 0.0, -Z, X, 0.0, Z, -X, 0.0, -Z, -X, 0.0 
    };
	static const GLubyte icosahedronFaces[] = {
        0,4,1, 0,9,4, 9,5,4, 4,5,8, 4,8,1,    
        8,10,1, 8,3,10, 5,3,8, 5,2,3, 2,7,3,    
        7,10,3, 7,6,10, 7,11,6, 11,0,6, 0,1,6, 
        6,1,10, 9,0,11, 9,11,2, 9,2,5, 7,2,11 
    };
    GLfloat *bData = malloc(180 * sizeof(GLfloat));
    
    // calc geometry data
    for(int i=0; i<60; i++) {
        bData[i*3] = icosahedronVertices[icosahedronFaces[i]*3];
        bData[i*3+1] = icosahedronVertices[icosahedronFaces[i]*3+1];
        bData[i*3+2] = icosahedronVertices[icosahedronFaces[i]*3+2];
    }
    
    if(vData != NULL) free(vData);
    if(subdivision == 0) {
        vData = bData;
        return;
    }
    vData = malloc(180 * pow(4, subdivision) * sizeof(GLfloat));
    
    //do subdivisions
    GLfloat *iData = bData;
    for(int j = 0; j < subdivision; j++) {
        for(int i = 0; i < 20 * pow(4, j); i++) [self subdivide:iData index:i * 9];
        free(iData);
        iData = vData;
        vData = malloc(180 * pow(4, subdivision) * sizeof(GLfloat));
    }
    free(vData);
    vData = iData;
}

-(void) findNeighbours {
    if(nData != NULL) free(nData);
    nData = malloc(60 * pow(4, subdivision) * sizeof(int));
    int foundCount;
    
    for(int i=0; i<20 * pow(4, subdivision); i++) {
        foundCount = 0;
        for(int j=0; j<20 * pow(4, subdivision) && foundCount < 3; j++) {
            if(i != j && checkNeighbour(&vData[i*9], &vData[j*9])) {
                nData[i*3 + foundCount] = j;
                foundCount++;
            }
        }
        if(foundCount != 3) NSLog(@"Error %i : %i",i,foundCount);
    }
}
bool checkNeighbour(GLfloat* t1, GLfloat* t2) {
    int foundPoints = 0;
    if(comparePoints(&t1[0],&t2[0]) || comparePoints(&t1[0],&t2[3]) || comparePoints(&t1[0],&t2[6])) foundPoints = 1; 
    if(comparePoints(&t1[3],&t2[0]) || comparePoints(&t1[3],&t2[3]) || comparePoints(&t1[3],&t2[6])) foundPoints++;
    if(comparePoints(&t1[6],&t2[0]) || comparePoints(&t1[6],&t2[3]) || comparePoints(&t1[6],&t2[6])) foundPoints++;
    if( foundPoints == 2) return true;
    return false;
}
bool comparePoints(GLfloat* p1, GLfloat* p2) {
    return fabs(p1[0]-p2[0]) < EPSILON && fabs(p1[1]-p2[1]) < EPSILON && fabs(p1[2]-p2[2]) < EPSILON;
}
-(void) printNeighbours {
    for(int i=0; i<20 * pow(4, subdivision); i++)
        NSLog(@"%i: %i %i %i",i, nData[i*3],nData[i*3+1],nData[i*3+2]);
}
-(void) checkNeighbours {
    if(nData == NULL) return;
    int foundCount, errorCount = 0;
    int t1, t2, t3;
    
    for(int i=0; i<20 * pow(4, subdivision); i++) {
        foundCount = 0;
        t1 = nData[i*3] * 3;
        t2 = nData[i*3+1] * 3;
        t3 = nData[i*3+2] * 3;
        
        if (nData[t1] == i || nData[t1+1] == i || nData[t1+2] == i) foundCount = 1;
        if (nData[t2] == i || nData[t2+1] == i || nData[t2+2] == i) foundCount++;
        if (nData[t3] == i || nData[t3+1] == i || nData[t3+2] == i) foundCount++;
        //if (checkNeighbour(&vData[i*9], &vData[nData[i*9]])) foundCount = 1;
        //if (checkNeighbour(&vData[i*9+3], &vData[nData[i*9+3]])) foundCount++;
        //if (checkNeighbour(&vData[i*9+6], &vData[nData[i*9+6]])) foundCount++;
        if(foundCount!=3) errorCount++;
    }
    NSLog(@"error count: %i",errorCount);
}
-(void) nextGen {
    float moisturePerCell = totalMoisture / 20.0f * pow(4, subdivision);
    // iterate across plants
    for (id plantNode in plants) {
        // allocate moisture to plants
        float moisturePerPlant = moisturePerCell / [plantNode numPlants];
        float moistureRequirement = 0.0f;
        int numPlants = 0;
        float germinationMoisture = 0.0f;
        
        PlantNode *curNode = [[PlantNode alloc] init];
        [curNode setNext:plantNode];
        
        // iterate through cell
        while ([curNode next] != NULL) {
            float requires = [[curNode plant] executeTimeStep:timeStep moistureShare:moisturePerPlant]; 
            
            //plant died
            if(requires < 0.0f) {
            
            } else {
                moistureRequirement += requires;
                numPlants++;
                
                //germination
                if((germinationMoisture = moisturePerCell - moistureRequirement) > 0.0f) {
                    
                }
            }    
            curNode = [curNode next];
        }
        
        [plantNode setNumPlants:numPlants];
        [plantNode setMoistureRequirement:moistureRequirement];
    }
    timeStep += 1;
}
-(void) subdivide:(GLfloat*)bData index:(int)index {
    GLfloat v12[3], v23[3], v31[3];
    GLfloat *v1, *v2, *v3;
    v1 = &bData[index];
    v2 = &bData[index+3];
    v3 = &bData[index+6];
    
    for(int i=0; i<3; i++) {
        v12[i] = v1[i]+v2[i];
        v23[i] = v2[i]+v3[i];
        v31[i] = v3[i]+v1[i];
    }
    
    normalise(v12);
    normalise(v23);
    normalise(v31);
    
    storeTriangle(&vData[index * 4], v1, v12, v31);
    storeTriangle(&vData[index * 4 + 9], v2, v23, v12);
    storeTriangle(&vData[index * 4 + 18], v3, v31, v23);
    storeTriangle(&vData[index * 4 + 27], v12, v23, v31);
}

void storeTriangle(GLfloat* row, GLfloat *t1, GLfloat *t2, GLfloat *t3) {
    for(int i=0; i<3; i++) {
        row[i] = t1[i];
        row[i+3] = t2[i];
        row[i+6] = t3[i];
    }
}
-(void) randomColours {
    if(cData != NULL) free(cData);
    
    cData = malloc(240 * pow(4, subdivision) * sizeof(GLubyte));
    for(int i=0; i<20 * pow(4, subdivision); i++) {
        cData[i*12] = cData[i*12+4] = cData[i*12+8] = (int)(random()%255);
        cData[i*12+1] = cData[i*12+5] = cData[i*12+9] = (int)(random()%255);
        cData[i*12+2] = cData[i*12+6] = cData[i*12+10] = (int)(random()%255);
        cData[i*12+3] = cData[i*12+7] = cData[i*12+11] = 1;
    }
}
void normalise(float v[3]) {
    GLfloat d = sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    if( d == 0.0f ) {
        //[NSException raise:@"Zero length vector" format:@"Zero length vector"];
        return;
    }
    v[0] /= d; v[1] /= d; v[2] /= d;
}
- (void)foundTap:(UITapGestureRecognizer *)recognizer {
    outputLabel.text=@"Tapped";
    
    [self randomColours];
}
void normcrossprod(float v1[3], float v2[3], float out[3]) {
    //GLint i, j;
    //GLfloat length;
    
    out[0] = v1[1]*v2[2] - v1[2]*v2[1];
    out[1] = v1[2]*v2[0] - v1[0]*v2[2];
    out[2] = v1[0]*v2[1] - v1[1]*v2[0];
    
    normalise(out);
}
-(void)foundPinch:(UIPinchGestureRecognizer *)recogniser {
    scaleFactor *= recogniser.scale;
    if(scaleFactor < 0.1) scaleFactor = 0.1;
    else if(scaleFactor > 10) scaleFactor = 10;
    
    outputLabel.text=[[NSString alloc] 
                      initWithFormat:@"Pinched, Scale:%1.2f, scaleFactor:%1.2f",
                      recogniser.scale,scaleFactor];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glGenBuffers(2, (GLuint*)&_glBuffers);
    
    glBindBuffer(GL_ARRAY_BUFFER, _glBuffers[0]);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vData);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glBindBuffer(GL_ARRAY_BUFFER, _glBuffers[1]);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, cData);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    NSLog(@"GLError: %i",glGetError());
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(3, (GLuint *)&_glBuffers);
    //glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    static float deg = 0.0;
    deg += 0.05;
    if (deg >= 2*M_PI) {
        deg-=2*M_PI;
    }
    
    glEnable(GL_DEPTH_TEST);
    
    static GLKMatrix4 modelview;
    modelview = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -5.0f * scaleFactor);
    modelview = GLKMatrix4Rotate(modelview, deg, 0.0f, 1.0f, 0.0f);
    
    self.effect.transform.modelviewMatrix = modelview;
    
    static GLKMatrix4 projection;
    GLfloat ratio = self.view.bounds.size.width/self.view.bounds.size.height;
    projection = GLKMatrix4MakePerspective(45.0f, ratio, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projection;
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelview), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projection, modelview);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{   
    [self.effect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT  | GL_DEPTH_BUFFER_BIT);
    
    glLoadIdentity();
    
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 60 * pow(4, subdivision));
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    //glBindAttribLocation(_program, ATTRIB_NORMAL, "normal");
    glBindAttribLocation(_program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    colorLocation = glGetAttribLocation(_program, "color");
    
    NSLog(@"Colour attribute location: %i", colorLocation);
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
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

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

/*#pragma mark GLKViewControllerDelegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    
    static float deg = 0.0;
    deg += 0.1;
    if (deg >= 2*M_PI) {
        deg-=2*M_PI;
    }
    
    //glEnable(GL_LIGHTING);
    
    glEnable(GL_DEPTH_TEST);
    
    static GLKMatrix4 modelview;
    modelview = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -5.0f * scaleFactor);
    modelview = GLKMatrix4Rotate(modelview, deg, 0.0f, 1.0f, 0.0f);
    
    // Correction for loaded model because in blender z-axis is facing upwards
    //modelview = GLKMatrix4Rotate(modelview, -M_PI/2.0f, 0.0f, 1.0f, 0.0f);
    //modelview = GLKMatrix4Rotate(modelview, -M_PI/2.0f, 1.0f, 0.0f, 0.0f);
    
    effect.transform.modelviewMatrix = modelview;
    
    static GLKMatrix4 projection;
    GLfloat ratio = self.view.bounds.size.width/self.view.bounds.size.height;
    projection = GLKMatrix4MakePerspective(45.0f, ratio, 0.1f, 100.0f);
    effect.transform.projectionMatrix = projection;
}

#pragma mark GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [effect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT  | GL_DEPTH_BUFFER_BIT);
    
    glLoadIdentity();
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //glEnableVertexAttribArray(GLKVertexAttribNormal);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vData);
    //glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_TRUE, 0, vData);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, cData);
    
    glDrawArrays(GL_TRIANGLES, 0, 60 * pow(4, subdivision));
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    //glDisableVertexAttribArray(GLKVertexAttribNormal);
    glDisableVertexAttribArray(GLKVertexAttribColor);
}*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(PlantWorldFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
