//
//  CSSpot.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSpot : NSObject <NSCoding>

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *time;
@property (nonatomic, readonly) float longitude;
@property (nonatomic, readonly) float latitude;
@property (copy, nonatomic, readonly) NSString *tagColor;

-(id) initWithName:(NSString *)name
              time:(NSString *)time
         longitude:(float)longitude
          latitude:(float)latitude
          tagColor:(NSString *)color;

@end
