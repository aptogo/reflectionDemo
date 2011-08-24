//
//  ReflectionView.h
//  
//  A UIView subclass designed to be used as a container for subviews that dynamically generates
//  a reflection of its contents (including subviews). Call -updateReflection to regenerate the reflection
//  after modifying the visual appearance.
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

@interface ReflectionView : UIView {
    UIImageView *_reflection;
    CGFloat _reflectionHeight;
    CGFloat _reflectionOffset;
}

// The height of the reflection in display points
@property (nonatomic, assign) CGFloat reflectionHeight;
// The global alpha of the reflection
@property (nonatomic, assign) CGFloat reflectionAlpha;
// The offset between the bottom of this view and the top of the reflection in display points
@property (nonatomic, assign) CGFloat reflectionOffset;

// Call to regenerate the reflection after the visual appearance of the container view (or its subviews) has changed
- (void)updateReflection;

@end
