//
//  SpotsManager.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <Foundation/Foundation.h>

@interface SpotsManager : NSObject

@property (nonatomic, readonly) NSMutableArray *spots;
@property (nonatomic) Spot *tempSpot;

+ (instancetype)sharedManager;

- (instancetype) init __attribute__((unavailable("init not available")));

- (void)addSpotWithText:(NSString *)hiddenText
        completionBlock:(void (^)())completion;

- (void)addSpotWithImages:(NSArray *)hiddenImages
          completionBlock:(void (^)())completion;

- (void)addSpotWithAudioData:(NSData *)hiddenAudioData
             completionBlock:(void (^)())completion;

- (void)removeSpotByName:(NSString *)name;

- (void)removeAllSpots;

- (BOOL)containsSpotByName:(NSString *)name;

- (Spot *)spotByName:(NSString *)name;

@end
