//
//  CSDataHandler.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSDataHandler.h"
#import "Reachability.h"

#define SPOTS_CAPACITY 20


@interface CSDataHandler() {
    BOOL _isConnecting;
}

@property (nonatomic, readwrite) BOOL spotsLoaded;
@property (strong, nonatomic) NSMutableArray *spots;

@end

@implementation CSDataHandler

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
        _spotsLoaded = NO;
        _isConnecting = NO;
        _spots = [[NSMutableArray alloc] initWithCapacity:SPOTS_CAPACITY];
    }
    return self;
}

- (void)connectToTheServerWithOption:(HEWebDataHandlerOption)option
{
    if (option == getWaypointsFromServer) {
        dispatch_async(kBgQueue, ^{
            NSError *error;
            NSData* data = [NSData dataWithContentsOfURL:
                            SpotsURL options:NSDataReadingUncached error:&error];
            if (!error) {
                [self performSelectorOnMainThread:@selector(getHEWaypoints:)
                                       withObject:data waitUntilDone:YES];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(connectionFailed)]) {
                        [self.delegate connectionFailed];
                    }
                    _isConnecting = NO;
                });
            }
        });
    }
    else if (option == getWaypointsFromDisk)
    {
        //...
    }
}

- (void)getHEWaypoints:(NSData *)responseData {
    
    //parse out the json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    if (!json) {
        NSLog(@"Got an error: %@", error);
        return;
    }
    
    //NSLog(@"%@", json);
    
    NSArray* latestWaypoints = json;
    
    for (NSDictionary *latestWaypoint in latestWaypoints) {
           
        NSInteger ID = [[latestWaypoint objectForKey:@"id"] integerValue];
        double lat = [[latestWaypoint objectForKey:@"lat"] doubleValue];
        double lon = [[latestWaypoint objectForKey:@"lon"] doubleValue];
        double altitude = [[latestWaypoint objectForKey:@"altitude"] doubleValue];
        double range = [[latestWaypoint objectForKey:@"range"] doubleValue];
        NSString *link = [NSString stringWithString:[latestWaypoint objectForKey:@"link"]];
        NSString *stadiumName = [NSString stringWithString:[latestWaypoint objectForKey:@"stadium_name"]];
        NSString *schoolName = [NSString stringWithString:[latestWaypoint objectForKey:@"school_name"]];
        NSString *imageURL = [NSString stringWithString:[latestWaypoint objectForKey:@"imageurl"]];
        NSString *city = [NSString stringWithString:[latestWaypoint objectForKey:@"city"]];
        NSString *state = [NSString stringWithString:[latestWaypoint objectForKey:@"state"]];
        NSString *wps = @"";


        CSSpot *newSpot = [[CSSpot alloc]initWithName:stadiumName longitude:lon latitude:lat tagColor:[UIColor grayColor]];
         
        [self.spots addObject:newSpot];
    }
    
    self.spotsLoaded = YES;

    if ([self.delegate respondsToSelector:@selector(spotsLoaded:)]) {
        [self.delegate spotsLoaded:self.spots];
    }

    _isConnecting = NO;
}


- (void)getSpots
{
    if (_isConnecting) return;
    
    if (self.spotsLoaded) {
        [self.delegate spotsLoaded:self.spots];
    }
    else {
        _isConnecting = YES;
        if ([CSDataHandler existNetworkConnection]) {
            [self connectToTheServerWithOption:getWaypointsFromServer];
        }
        else {
            if ([self.delegate respondsToSelector:@selector(connectionFailed)]) {
                [self.delegate connectionFailed];
            }
            _isConnecting = NO;
        }
    }
}


+ (BOOL)existNetworkConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    }
    return YES;
}


#pragma --- additional useful private methods

//
//- (NSString *)convertNSDictionaryToJSONString:(NSDictionary *)jsonDictionary
//{    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];
//    
//    if (!jsonData) {
//        NSLog(@"Got an error: %@", error);
//        return nil;
//    } else {
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        return jsonString;
//    }
//}




@end
