//
//  PlantWorldMainViewController.h
//  PlantWorld
//
//  Created by henry florence on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlantWorldFlipsideViewController.h"

@interface PlantWorldMainViewController : UIViewController <PlantWorldFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
