//
//  Spot.h
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Spot : NSObject <NSCoding>

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSDate *createDate;
@property (nonatomic, readonly) float longitude;
@property (nonatomic, readonly) float latitude;

- (instancetype) init __attribute__((unavailable("init not available")));

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude;

@end
