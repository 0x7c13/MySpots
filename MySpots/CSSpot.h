//
//  CSSpot.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSSpot : NSObject

@property (copy, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) float longitude;
@property (nonatomic, readonly) float latitude;
@property (nonatomic, readonly) UIColor *tagColor;

-(id) initWithName:(NSString *)name
         longitude:(float)longitude
          latitude:(float)latitude
          tagColor:(UIColor *)color;

@end
