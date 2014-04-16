//
//  ShareHandler.h
//  MySpots
//
//  Created by Jiaqi Liu on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "AFNetworking.h"
#import <Foundation/Foundation.h>

@class Spot;

typedef enum {
    ShareHandlerOptionSuccess,
    ShareHandlerOptionFailure
}ShareHandlerOption;

@interface ShareHandler : NSObject


+ (void)uploadSpot:(Spot *)spot
          progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten))progress
   completionBlock:(void (^)(ShareHandlerOption option, NSURL *downloadURL, NSError *error))completion;


+ (void)downloadSpotByDownloadCode:(NSString *)downloadCode
                          progress:(void (^)(NSUInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                   completionBlock:(void (^)(ShareHandlerOption option, NSError *error))completion;


@end
