//
//  Spot.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSData+Encryption.h"
#import "NSString+Encryption.h"
#import "KeyGenerator.h"
#import "FileManager.h"
#import "Utilities.h"
#import "Spot.h"

@interface Spot ()

@end

@implementation Spot

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
{
    if ((self = [super init])) {
        
        _name = name;
        _latitude = latitude;
        _longitude = longitude;
        _createDate = [NSDate date];
        _key = [NSString randomAlphanumericStringWithLength:kLengthOfKey];
    
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"spotName"];
    [encoder encodeFloat:_latitude forKey:@"latitude"];
    [encoder encodeFloat:_longitude forKey:@"longitude"];
    [encoder encodeObject:_createDate forKey:@"createDate"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _name = [decoder decodeObjectForKey:@"spotName"];
        _latitude = [decoder decodeFloatForKey:@"latitude"];
        _longitude = [decoder decodeFloatForKey:@"longitude"];
        _createDate = [decoder decodeObjectForKey:@"createDate"];
    }
    return self;
}

@end
