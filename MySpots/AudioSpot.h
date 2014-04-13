//
//  AudioSpot.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/31/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Spot.h"
#import <Foundation/Foundation.h>

@interface AudioSpot : Spot <NSCoding>

@property (nonatomic, copy, readonly) NSString *hiddenAudioPath;
@property (nonatomic, copy, readonly) NSString *keyOfHiddenAudio;

- (instancetype) init __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
                 hiddenAudio:(NSData *)hiddenAudioData;

- (void)decryptHiddenAudioWithCompletionBlock:(void (^)(NSData *hiddenAudioData))completion;
- (void)deleteContent;

@end