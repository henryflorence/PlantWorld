//
//  Plant.h
//  PlantWorld
//
//  Created by henry florence on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plant : NSObject {
    int currentSize;
    int adultSize;
    int *genome;
    int n1;
    int n2;
    int location;
    int *plants;
    int *adjacency;
    int gridSquare;
}

-(void) setGenome:(int *)genome;
-(float) executeTimeStep: (int)timeStep moistureShare:(int)moistureShare;
-(float) calcMaintenance;
-(int) sizeBiomass;
@end
