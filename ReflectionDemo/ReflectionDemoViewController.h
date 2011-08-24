//
//  ReflectionDemoViewController.h
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

#import <UIKit/UIKit.h>

@class ReflectionView;

@interface ReflectionDemoViewController : UIViewController
{
    ReflectionView *_reflectionView;
    UIImageView *_imageView;
    UILabel *_label;
    
    NSUInteger _imageIndex;
    NSArray *_imagePaths;
}

@property (nonatomic, retain) IBOutlet ReflectionView *reflectionView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;

@end
