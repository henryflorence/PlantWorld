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
- (void)alterSubdivision:(int)subdivision;
- (int)getSubdivision;
- (int*)getGenome;
- (void)setGenomeElement:(int)index value:(int)value;
@end

@interface PlantWorldFlipsideViewController : UIViewController {
    IBOutlet UILabel *noOfCells;
    IBOutlet UISlider *subdivisionSlider;
    IBOutlet UISegmentedControl *genome;
}

@property (weak, nonatomic) IBOutlet id <PlantWorldFlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) UISlider *subdivisionSlider;
@property (nonatomic, retain) UILabel *noOfCells;
@property (nonatomic, retain) UISegmentedControl *genome;

- (IBAction)done:(id)sender;
- (IBAction)setSubdivision:(id)sender;
- (IBAction)updateGenome:(id)sender;

@end
