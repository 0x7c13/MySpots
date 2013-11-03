//
//  CSDataHandler.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSpot.h"
#import "CSUtilities.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define SpotsURL [NSURL URLWithString:@"http://edutechnologic.org/IMR_Heisman/GetLocations.aspx"]
//#define SpotsURL [NSURL URLWithString:@"http://coderhosting.com:8983/solr/collection1/select?q=id%3A100&wt=json"]

typedef enum {
    getWaypointsFromServer = 0,
    getWaypointsFromDisk
}HEWebDataHandlerOption;

@protocol CSDataHandlerDelegate;

@interface CSDataHandler : NSObject <NSURLConnectionDelegate>

@property (nonatomic, readonly) BOOL spotsLoaded;

@property (weak, nonatomic) id<CSDataHandlerDelegate>delegate;

// Singleton
+ (id)sharedInstance;
+ (BOOL)existNetworkConnection;


+ (NSMutableArray *)loadSpotsFromDisk;
+ (void)writeSpotsToDisk:(NSMutableArray *)spots;
+ (void)uploadSpotsToServer:(NSMutableArray *)spots;
- (void)updateWithNewSpot:(CSSpot *)newSpot;
- (void)deleteSpot:(CSSpot *)delSpot;
- (void)getSpots;

@end

@protocol CSDataHandlerDelegate <NSObject>

@optional

- (void)spotsLoaded:(NSMutableArray *)spots;

- (void)connectionFailed;

@end
