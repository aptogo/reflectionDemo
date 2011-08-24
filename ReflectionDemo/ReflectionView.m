//
//  ReflectionView.m
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

#import <QuartzCore/QuartzCore.h>

#import "ReflectionView.h"

static const CGFloat kDefaultReflectionOffset   = 2.0f;
static const CGFloat kDefaultReflectionHeight   = 60.0f;
static const CGFloat kDefaultReflectionAlpha    = 0.5f;

// Shared background queue for generation of reflections
static dispatch_queue_t gReflectionQueue;

// Helper function prototypes
static CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh);

@interface ReflectionView ()
- (void)initSubviews;
- (UIImage *)reflectedImage;
@end

@implementation ReflectionView

@synthesize reflectionHeight = _reflectionHeight;
@synthesize reflectionOffset = _reflectionOffset;
@dynamic reflectionAlpha;

// Create background queue used for creation of reflection - called by runtime before first use of ReflectionView
+ (void)initialize
{
	static BOOL initialized = NO;
    
    // Check to prevent multiple initialization in case client calls this method directly
	if (!initialized)
	{
		initialized = YES;
		gReflectionQueue = dispatch_queue_create("uk.co.aptogo.reflection", NULL);
    }
}

// MARK: Lifetime management

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initSubviews];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSubviews];
}

- (void)initSubviews
{  
    _reflection = [[UIImageView alloc] initWithFrame:CGRectZero];
    _reflection.alpha = kDefaultReflectionAlpha;
    _reflectionHeight = kDefaultReflectionHeight;
    _reflectionOffset = kDefaultReflectionOffset;
    [self addSubview:_reflection]; 
}

- (void)dealloc {
    [_reflection release];
    [super dealloc];
}

// MARK: Public methods

// Call to regenerate the reflection after the visual appearance of the main view (or its subviews) has changed
- (void)updateReflection
{
    // Create reflection on background queue then update UI on main thread
    dispatch_async(gReflectionQueue, ^{
        UIImage *reflectedImage = [self reflectedImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _reflection.image = reflectedImage;
        });
    });
}

// MARK: Accessors

- (void)setReflectionHeight:(CGFloat)height
{
    _reflectionHeight = height;
    [self setNeedsLayout];
}

- (void)setReflectionOffset:(CGFloat)offset
{
    _reflectionOffset = offset;
    [self setNeedsLayout];
}

- (CGFloat)reflectionAlpha
{
    return _reflection.alpha;
}

- (void)setReflectionAlpha:(CGFloat)alpha
{
    _reflection.alpha = alpha;
}

// MARK: Overrides

// Overidden to resize and position the reflection subview below the main view
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Position reflection subview at bottom of this view. The reflection subview extends outside the bounds of this view
    // so ensure that 'clip to bounds' is set to NO in Interface Builder
    CGRect reflectionFrame = self.bounds;
    reflectionFrame.origin.y += reflectionFrame.size.height + _reflectionOffset;
    reflectionFrame.size.height = _reflectionHeight;
    _reflection.frame = reflectionFrame;
    
    [self updateReflection];
}

// MARK: Internals

// Creates an autoreleased reflected image of the contents of the main view
- (UIImage *)reflectedImage
{   
    // Calculate the size of the reflection in devices units - supports retina display
    BOOL retinaDisplay = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2;
    CGFloat displayScale = (retinaDisplay)? 2.0f : 1.0f;
    CGSize deviceReflectionSize = _reflection.bounds.size;
    deviceReflectionSize.width *= displayScale;
    deviceReflectionSize.height *= displayScale;
    
    // Create the bitmap context to draw into
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             deviceReflectionSize.width, 
                                             deviceReflectionSize.height, 
                                             8,         
                                             0, 
                                             colorSpace,
                                             // Optimal BGRA format for the device:
                                             (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
    
    if (!ctx)
    {
        return nil;
    }
    
    // Create a 1 pixel-wide gradient (will be stretched by CGContextClipToMask)
    CGImageRef gradientImage = CreateGradientImage(1, deviceReflectionSize.height);
    
	// Use the gradient image as a mask
    CGContextClipToMask(ctx, CGRectMake(0.0f, 0.0f, deviceReflectionSize.width, deviceReflectionSize.height), gradientImage);
    CGImageRelease(gradientImage);
    
    // Translate origin to position reflection correctly. Reflection will be flipped automatically because of differences between
    // Quartz2D coordinate system and CALayer coordinate system.
	CGContextTranslateCTM(ctx, 0.0, -self.bounds.size.height * displayScale + deviceReflectionSize.height);
    CGContextScaleCTM(ctx, displayScale, displayScale);

    // Render into the reflection context. Rendering is wrapped in a transparency layer otherwise sublayers
    // will be rendered individually using the gradient mask and hidden layers will show through
	CGContextBeginTransparencyLayer(ctx, NULL);
    [self.layer renderInContext:ctx];
    CGContextEndTransparencyLayer(ctx);
    
    // Create the reflection image from the context
	CGImageRef reflectionCGImage = CGBitmapContextCreateImage(ctx);
    UIImage *reflectionImage = [UIImage imageWithCGImage:reflectionCGImage];
	CGContextRelease(ctx);
	CGImageRelease(reflectionCGImage);

	return reflectionImage;
}

// MARK: Helper functions

// Creates a vertical grayscale gradient of the specified size and returns a CGImage
CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
    CGImageRef theCGImage = NULL;
    
    // Create a grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create the bitmap context to draw into
    CGContextRef gradientContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Define start and end color stops (alpha values required even though not used in the gradient)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    
    // Draw the gradient
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGContextDrawLinearGradient(gradientContext,
                                grayScaleGradient, 
                                gradientStartPoint, 
                                gradientEndPoint, 
                                kCGGradientDrawsAfterEndLocation);
    
    // Create the image from the context
    theCGImage = CGBitmapContextCreateImage(gradientContext);
    
    // Clean up
    CGGradientRelease(grayScaleGradient);
    CGContextRelease(gradientContext);
    CGColorSpaceRelease(colorSpace);
    
    // Return the CGImageRef containing the gradient (with refcount = 1)
    return theCGImage;
}

@end
