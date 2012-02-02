//
//  Shader.fsh
//  TestGL
//
//  Created by henry florence on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;
//uniform vec4 color;

void main()
{
    gl_FragColor = colorVarying;
}
