//
//  CSUtilities.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define DEVICE_IS_4INCH_IPHONE ([[UIScreen mainScreen] bounds].size.height == 568)

@interface CSUtilities : NSObject

+ (void)initSetup;
+ (BOOL)isRunningOniOS7; // check current system version == iOS7
+ (BOOL)currentDeviceIs4InchiPhone;
+ (void)addShadowToUIView: (UIView *)view;
+ (void)addShadowToUIImageView: (UIImageView *)view;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString *)hexStringFromColor:(UIColor *)color;

@end
