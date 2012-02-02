//
//  PlantWorldFlipsideViewController.m
//  PlantWorld
//
//  Created by henry florence on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlantWorldFlipsideViewController.h"

@implementation PlantWorldFlipsideViewController

@synthesize delegate = _delegate;
@synthesize noOfCells;
@synthesize subdivisionSlider;
@synthesize genome;

-(IBAction)updateGenome:(id)sender {
    int clickedSegment = [genome selectedSegmentIndex];
    NSString *title = [genome titleForSegmentAtIndex:clickedSegment];
    int value = 1;
    
    if([title isEqualToString:@"1"]) { 
        title = @"s";
        value = 2;
    } else if([title isEqualToString:@"s"]) {
        title = @"0";
        value = 0;
    } else title = @"1";
    
    [genome setTitle:title forSegmentAtIndex:clickedSegment];
    
    [_delegate setGenomeElement:clickedSegment value:value];
}
- (void)setSubdivision:(id)sender {
    int value = (int)subdivisionSlider.value;
    noOfCells.text = [[NSString alloc] initWithFormat:@"%i",20 * (int)pow(4,value)];
    [_delegate alterSubdivision:value];
}
- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int value = [_delegate getSubdivision];
    subdivisionSlider.value = value;
    noOfCells.text = [[NSString alloc] initWithFormat:@"%i",20 * (int)pow(4,value)];
    
    int *initialGenome = [_delegate getGenome];
    for(int i=0; i<12; i++) {
        if(initialGenome[i] == 2) [genome setTitle:@"s" forSegmentAtIndex:i];
        else [genome setTitle:[NSString stringWithFormat:@"%i",initialGenome[i]] forSegmentAtIndex:i];
    }
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

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
