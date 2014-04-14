//
//  SpotsManager.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "TextSpot.h"
#import "ImageSpot.h"
#import "AudioSpot.h"
#import "SpotsManager.h"
#import "FileManager.h"
#import "KeyGenerator.h"
#import "NSData+Encryption.h"

#define kMySpotsObjects @"MySpotsObjects"

@interface SpotsManager ()

@end

@implementation SpotsManager

- (instancetype)init
{
    if (self = [super init]) {
        
        NSData *spotsData = [[NSUserDefaults standardUserDefaults] objectForKey:kMySpotsObjects];
        spotsData = [spotsData AES256DecryptWithKey:[KeyGenerator mainKeyForKey:[KeyGenerator mainKeyString]]];
        if (!(_spots = [NSKeyedUnarchiver unarchiveObjectWithData:spotsData])) {
            NSLog(@"No spots!");
            _spots = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)addSpot:(Spot *)spot withText:(NSString *)hiddenText completionBlock:(void (^)())completion
{
    if (spot == nil || [self containsSpotByName:spot.name]) {
        if (completion == nil) {
            return;
        }
        completion();
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.spots addObject:[[TextSpot alloc]initWithName:spot.name
                                                   latitude:spot.latitude
                                                  longitude:spot.longitude
                                                 hiddenText:hiddenText]];
        
        NSData *spotsData = [NSKeyedArchiver archivedDataWithRootObject:self.spots];
        spotsData = [spotsData AES256EncryptWithKey:[KeyGenerator mainKeyForKey:[KeyGenerator mainKeyString]]];
        [[NSUserDefaults standardUserDefaults] setObject:spotsData forKey:kMySpotsObjects];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion == nil) {
                return;
            }
            completion();
        });
    });
}

-(void)addSpot:(Spot *)spot withImages:(NSArray *)hiddenImages completionBlock:(void (^)())completion
{
    if (spot == nil || [self containsSpotByName:spot.name]) {
        if (completion == nil) {
            return;
        }
        completion();
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.spots addObject:[[ImageSpot alloc]initWithName:spot.name
                                                    latitude:spot.latitude
                                                   longitude:spot.longitude
                                                hiddenImages:hiddenImages]];
        
        NSData *spotsData = [NSKeyedArchiver archivedDataWithRootObject:self.spots];
        spotsData = [spotsData AES256EncryptWithKey:[KeyGenerator mainKeyForKey:[KeyGenerator mainKeyString]]];
        [[NSUserDefaults standardUserDefaults] setObject:spotsData forKey:kMySpotsObjects];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion == nil) {
                return;
            }
            completion();
        });
    });
}

-(void)addSpot:(Spot *)spot withAudioData:(NSData *)hiddenAudioData completionBlock:(void (^)())completion
{
    if (spot == nil || [self containsSpotByName:spot.name]) {
        if (completion == nil) {
            return;
        }
        completion();
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.spots addObject:[[AudioSpot alloc]initWithName:spot.name
                                                    latitude:spot.latitude
                                                   longitude:spot.longitude
                                                 hiddenAudio:hiddenAudioData]];
        
        NSData *spotsData = [NSKeyedArchiver archivedDataWithRootObject:self.spots];
        spotsData = [spotsData AES256EncryptWithKey:[KeyGenerator mainKeyForKey:[KeyGenerator mainKeyString]]];
        [[NSUserDefaults standardUserDefaults] setObject:spotsData forKey:kMySpotsObjects];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion == nil) {
                return;
            }
            completion();
        });
    });
}

-(void)removeSpotByName:(NSString *)name
{
    Spot *spotToBeDeleted;
    for (Spot *spot in self.spots) {
        if ([spot.name isEqualToString:name]) {
            spotToBeDeleted = spot;
            break;
        }
    }
    if (spotToBeDeleted) {
        if ([spotToBeDeleted isKindOfClass:[ImageSpot class]]) {
            [(ImageSpot *)spotToBeDeleted deleteContent];
        } else if ([spotToBeDeleted isKindOfClass:[TextSpot class]]) {
            [(TextSpot *)spotToBeDeleted deleteContent];
        } else if ([spotToBeDeleted isKindOfClass:[AudioSpot class]]) {
            [(AudioSpot *)spotToBeDeleted deleteContent];
        }
    }
    [self.spots removeObject:spotToBeDeleted];
    NSData *spotsData = [NSKeyedArchiver archivedDataWithRootObject:self.spots];
    spotsData = [spotsData AES256EncryptWithKey:[KeyGenerator mainKeyForKey:[KeyGenerator mainKeyString]]];
    [[NSUserDefaults standardUserDefaults] setObject:spotsData forKey:kMySpotsObjects];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (Spot *)spotByName:(NSString *)name
{
    if ([self containsSpotByName:name]) {
        for (Spot *spot in self.spots) {
            if ([spot.name isEqualToString:name]) {
                return spot;
            }
        }
    }
    return nil;
}

-(void)removeAllSpots
{
    for (Spot *spot in self.spots) {
        if ([spot isKindOfClass:[ImageSpot class]]) {
            [(ImageSpot *)spot deleteContent];
        } else if ([spot isKindOfClass:[TextSpot class]]) {
            [(TextSpot *)spot deleteContent];
        } else if ([spot isKindOfClass:[AudioSpot class]]) {
            [(AudioSpot *)spot deleteContent];
        }
    }
    [self.spots removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMySpotsObjects];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)containsSpotByName:(NSString *)name {
    for (Spot *spot in self.spots) {
        if ([spot.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

@end
