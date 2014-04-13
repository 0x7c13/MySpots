//
//  ImageSpot.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <Foundation/Foundation.h>

@interface ImageSpot : Spot <NSCoding>

@property (nonatomic, copy, readonly) NSMutableArray *hiddenImagePaths;
@property (nonatomic, copy, readonly) NSString *keyOfHiddenImages;

- (instancetype) init __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
                hiddenImages:(NSArray *)hiddenImages;

- (void)decryptHiddenImagesWithCompletionBlock:(void (^)(NSArray *images))completion;
- (void)deleteContent;

@end
