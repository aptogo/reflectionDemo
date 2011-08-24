//
//  ReflectionDemoViewController.m
//  ReflectionDemo
//
//  Created by Robin Summerhill on 8/24/11.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "ReflectionView.h"

#import "ReflectionDemoViewController.h"

@interface ReflectionDemoViewController ()
- (void)displayImage:(NSUInteger)index;
@end

@implementation ReflectionDemoViewController

@synthesize reflectionView = _reflectionView;
@synthesize imageView = _imageView;
@synthesize label = _label;

// MARK: Lifecycle management

- (void)dealloc
{
    [self viewDidUnload];
    [super dealloc];
}

// MARK: View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Enumerate images in 'images' resource directory
    _imagePaths = [[[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:@"images"] retain];  
    _imageIndex = 0;
    
    [self displayImage:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_imagePaths release];
    _imagePaths = nil;
    
    self.reflectionView = nil;
    self.imageView = nil;
    self.label = nil;
}

// MARK: Overrides

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// MARK: IBActions

- (IBAction)backButtonTapped:(id)sender
{
    if (_imageIndex > 0)
    {
        _imageIndex -= 1;
        [self displayImage:_imageIndex];
    }
}

- (IBAction)nextButtonTapped:(id)sender
{
    if (_imageIndex < [_imagePaths count] - 1)
    {
        _imageIndex += 1;
        [self displayImage:_imageIndex];
    }
}

// MARK: Internal methods

- (void)displayImage:(NSUInteger)index
{
    if (index >= [_imagePaths count])
    {
        return;
    }
    
    self.imageView.image = [UIImage imageWithContentsOfFile:[_imagePaths objectAtIndex:index]];
    self.label.text = [[_imagePaths objectAtIndex:index] lastPathComponent];
    [self.reflectionView updateReflection];
}

@end
