//
//  KeyGenerator.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/24/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyGenerator : NSObject

+ (NSString *)mainKeyForKey:(NSString *)key;

+ (NSString *)hiddenKeyForKey:(NSString *)key;

+ (void)saveMainKeyStringToDisk:(NSString *)string;

+ (NSString *)mainKeyString;

+ (NSString *)OpenUDID;

@end
