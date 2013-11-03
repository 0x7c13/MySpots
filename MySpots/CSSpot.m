//
//  CSSpot.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSSpot.h"

@implementation CSSpot

- (id)initWithName:(NSString *)name
         longitude:(float)longitude
          latitude:(float)latitude
          tagColor:(UIColor *)color
{
    if(self = [super init]) {
        _name = [NSString stringWithString:name];
        _longitude = longitude;
        _latitude = latitude;
        _tagColor = color;
    }
    
    return self;
}

@end
