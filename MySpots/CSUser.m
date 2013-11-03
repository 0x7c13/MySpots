//
//  CSUser.m
//  MySpots
//
//  Created by FlyinGeek on 11/3/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSUser.h"

@interface CSUser()

@property (copy, nonatomic) NSString *username;
@property (nonatomic, copy) NSString *password;

@end

@implementation CSUser


+ (id)sharedInstance
{
    
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    if (self = [super init]) {
        _isGuest = YES;
    }
    return self;
}

- (BOOL)checkUsername:(NSString *)username
             password:(NSString *)password
{
    //...
    return YES;
}

- (BOOL)loginWithUsername:(NSString *)username
                 password:(NSString *)password
{
    if([self checkUsername:username password:password]) {
        self.username = username;
        self.password =password;
        self.isGuest = NO;
        return YES;
    }else {
        return NO;
    }
}

- (NSString *)getUsername
{
    if (!self.isGuest) {
        return self.username;
    }
    else {
        return @"Unknown Username";
    }
}

@end
