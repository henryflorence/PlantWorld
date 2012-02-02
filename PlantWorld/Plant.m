//
//  Plant.m
//  PlantWorld
//
//  Created by henry florence on 15/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Plant.h"

@implementation Plant

- (id) initInSquare: (int)square withAdultSize: (int)initAdultSize withGenome: (int*)newGenome withPlants: (int*)neighbourPlants withAdjacency: (int*)adjacencyGrid {
    self = [super init];
    if (self == nil) return self;
    
    self->gridSquare = square;
    self->adultSize = initAdultSize;
    [self setGenome:newGenome];
    self->plants = neighbourPlants;
    self->adjacency = adjacencyGrid;
    self->currentSize = 1;
    
    return self;
}

-(float) executeTimeStep: (int)timeStep moistureShare:(int)moistureShare {
    
    int requires = [self calcMaintenance];
    //dormant - do nothing or ks and not enough moisture -> go dormant
    if( genome[timeStep] == 0 || (genome[timeStep] == 2 && moistureShare < requires)) return requires;
    //kpOn and not enought moisture -> die
    else if(genome[timeStep] == 1 && moistureShare < requires) return -1.0f;
    //kpOn or ks and can meet requirement -> grow 
    
    //plant is growing
    if( currentSize < adultSize ) {
        currentSize += 1.f / sqrt(currentSize) * (moistureShare - requires);
        if( currentSize > adultSize) currentSize = adultSize;
        return [self calcMaintenance];
    }
    //plant can reproduce
    
    return [self calcMaintenance];
}
-(float) calcMaintenance {
    return (0.5f + n1 * 0.01f + n2 * 0.02f) * currentSize;
}
-(int) sizeBiomass {
    return currentSize;
}
-(bool) isAdult {
    return currentSize == adultSize;
}
-(void) setGenome:(int *)newGenome {
    self.genome = newGenome;
    n1 = n2 = 0;
    for(int i=0; i < 12; i++) {
        if(genome[i] == 0) n1++;
        else if(genome[i] == 2) n2++;
    }
}
@end
