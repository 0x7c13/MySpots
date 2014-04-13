//
//  DataHandler.h
//  MySpots
//
//  Created by Jiaqi Liu on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "AFNetworking.h"
#import <Foundation/Foundation.h>

typedef enum {
    DataHandlerOptionSuccess,
    DataHandlerOptionFailure
}DataHandlerOption;

@interface DataHandler : NSObject

/*
+ (void)uploadSpot:(Spot *)spot
          progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten))progress
   completionBlock:(void (^)(DataHandlerOption option, NSURL *markerURL, NSError *error))completion;

+ (void)downloadMarkerByDownloadCode:(NSString *)downloadCode
                            progress:(void (^)(NSUInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     completionBlock:(void (^)(DataHandlerOption option, NSError *error))completion;

 */

@end
