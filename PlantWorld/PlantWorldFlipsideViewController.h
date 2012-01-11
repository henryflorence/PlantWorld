//
//  PlantWorldFlipsideViewController.h
//  PlantWorld
//
//  Created by henry florence on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlantWorldFlipsideViewController;

@protocol PlantWorldFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(PlantWorldFlipsideViewController *)controller;
@end

@interface PlantWorldFlipsideViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <PlantWorldFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
