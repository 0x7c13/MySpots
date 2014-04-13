//
//  TextSpot.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <Foundation/Foundation.h>

@interface TextSpot : Spot <NSCoding>

@property (nonatomic, copy, readonly) NSString *hiddenTextPath;
@property (nonatomic, copy, readonly) NSString *keyOfHiddenText;

- (instancetype) init __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
                  hiddenText:(NSString *)hiddenText;

- (void)decryptHiddenTextWithCompletionBlock:(void (^)(NSString *hiddenText))completion;
- (void)deleteContent;

@end
