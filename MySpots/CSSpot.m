//
//  CSSpot.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSSpot.h"

@interface CSSpot()

@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *time;
@property (nonatomic, readwrite) float longitude;
@property (nonatomic, readwrite) float latitude;
@property (copy, nonatomic, readwrite) NSString *tagColor;

@end

@implementation CSSpot

-(id) initWithName:(NSString *)name
              time:(NSString *)time
         longitude:(float)longitude
          latitude:(float)latitude
          tagColor:(NSString *)color
{
    if(self = [super init]) {
        _name = [NSString stringWithString:name];
        _time = [NSString stringWithString:time];
        _longitude = longitude;
        _latitude = latitude;
        _tagColor = [NSString stringWithString:color];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_time forKey:@"time"];
    [encoder encodeFloat:_longitude forKey:@"longitude"];
    [encoder encodeFloat:_longitude forKey:@"latitude"];
    [encoder encodeObject:_tagColor forKey:@"tagColor"];
}


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.time = [decoder decodeObjectForKey:@"time"];
        self.tagColor = [decoder decodeObjectForKey:@"tagColor"];
        self.longitude = [decoder decodeFloatForKey:@"longitude"];
        self.latitude = [decoder decodeFloatForKey:@"latitude"];
    }
    return self;
}


@end
