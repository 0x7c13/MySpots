//
//  CSUtilities.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSUtilities.h"

@implementation CSUtilities


+ (void)initSetup
{
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        UITextAttributeTextColor: [UIColor darkGrayColor],
                                                        UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5],
                                                        UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -0.5)],
                                                        UITextAttributeFont: [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0],
                                                        } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0, -14.0)];
    
}

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
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (BOOL)isRunningOniOS7
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)currentDeviceIs4InchiPhone
{
    if(DEVICE_IS_4INCH_IPHONE) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    const size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"%02X%02X%02X",
            (int)(255 * components[MIN(0,totalComponents-2)]),
            (int)(255 * components[MIN(1,totalComponents-2)]),
            (int)(255 * components[MIN(2,totalComponents-2)])];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
