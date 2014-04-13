//
//  CLUtilities.m
//  CamLocker
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (void)addShadowToUIView: (UIView *)view
{
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowOffset:CGSizeMake(0.0f, 3.0f)];
    [view.layer setShadowOpacity:0.4];
    [view.layer setShadowRadius:4.0];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

+ (void)addShadowToUIImageView: (UIImageView *)view
{
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowOffset:CGSizeMake(0.0f, 1.5f)];
    [view.layer setShadowOpacity:0.4];
    [view.layer setShadowRadius:2.0];
    
    // improve performance
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToHeight:(float)i_height
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = i_height / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CAShapeLayer *)addDashedBorderToView:(UIView *)view withColor: (CGColorRef) color {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGSize frameSize = view.frame.size;
    
    CGRect shapeRect = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake( frameSize.width/2,frameSize.height/2)];
    
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:color];
    [shapeLayer setLineWidth:5.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:15.0];
    [shapeLayer setPath:path.CGPath];
    
    return shapeLayer;
}

+ (void)addBackgroundImageToView:(UIView *)view withImageName:(NSString *)name
{
    UIImageView *background = [[UIImageView alloc] initWithFrame:view.frame];
    background.image = [UIImage imageNamed:@"bg_2.jpg"];
    [view insertSubview:background atIndex:0];
}

+ (UIImage *)snapshotViewForView:(UIView *)view {
    
    CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rec = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)makeTransparentBarsForViewController:(UIViewController *)viewController {
    
    [viewController.navigationItem.leftBarButtonItem setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Chalkduster" size:17.0f], UITextAttributeFont,nil]
                                                         forState:UIControlStateNormal];
    
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    viewController.navigationController.navigationBar.shadowImage = [UIImage new];
    viewController.navigationController.navigationBar.translucent = YES;
    UIView *navigationBarBottomLine = [[UIView alloc] initWithFrame:CGRectMake(15, 64, 320-30, 1)];
    navigationBarBottomLine.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    [viewController.view addSubview:navigationBarBottomLine];
    
    [viewController.navigationController.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

}

@end
