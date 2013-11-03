//
//  CSUser.h
//  MySpots
//
//  Created by FlyinGeek on 11/3/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUser : NSObject

@property (nonatomic) BOOL isGuest;

- (BOOL)loginWithUsername:(NSString *)username
                 password:(NSString *)password;

- (NSString *)getUsername;

+ (id)sharedInstance;

@end
