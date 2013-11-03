//
//  CSDataHandler.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSDataHandler.h"
#import "Reachability.h"
#import "CSUser.h"

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
                [self performSelectorOnMainThread:@selector(getCSSpots:)
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
        //self.spots = [NSMutableArray arrayWithArray:[CSDataHandler loadSpotsFromDisk]];
    }
}

- (void)getCSSpots:(NSData *)responseData {
    
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
        
        double lat = [[latestWaypoint objectForKey:@"lat"] doubleValue];
        double lon = [[latestWaypoint objectForKey:@"lon"] doubleValue];

        NSString *stadiumName = [NSString stringWithString:[latestWaypoint objectForKey:@"stadium_name"]];

        NSString *tagColor;
        
        int rand = arc4random()%6;
        
        switch (rand) {
            case 0:
                tagColor = @"FF6666";
                break;
            case 1:
                tagColor = @"FFFF00";
                break;
            case 2:
                tagColor = @"CCCCCC";
                break;
            case 3:
                tagColor = @"66FF66";
                break;
            case 4:
                tagColor = @"FF6FCF";
                break;
            case 5:
                tagColor = @"66CCFF";
                break;
            default:
                break;
        }
        
        CSSpot *newSpot = [[CSSpot alloc]initWithName:stadiumName time:@"" longitude:lon latitude:lat tagColor:tagColor];
         
        [self.spots addObject:newSpot];
    }
    
    self.spotsLoaded = YES;

    if ([self.delegate respondsToSelector:@selector(spotsLoaded:)]) {
    
        [CSDataHandler writeSpotsToDisk:self.spots];
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

+ (void)writeSpotsToDisk:(NSMutableArray *)spots
{
    CSUser *currentUser = [CSUser sharedInstance];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:spots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[currentUser getUsername]];
}

+ (NSMutableArray *)loadSpotsFromDisk
{
    CSUser *currentUser = [CSUser sharedInstance];
    NSData *spotsData = [[NSUserDefaults standardUserDefaults] objectForKey:[currentUser getUsername]];
    NSMutableArray *spots = [NSKeyedUnarchiver unarchiveObjectWithData:spotsData];
    return spots;
}

- (void)updateWithNewSpot:(CSSpot *)newSpot
{
    CSUser *currentUser = [CSUser sharedInstance];
    [self.spots addObject:newSpot];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.spots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[currentUser getUsername]];
    
    [CSDataHandler uploadSpotsToServer:self.spots];
}

- (void)deleteSpot:(CSSpot *)delSpot
{
    [self.spots removeObject:delSpot];
    [CSDataHandler uploadSpotsToServer:self.spots];
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


+ (void)uploadSpotsToServer:(NSMutableArray *)spots
{
    CSUser *currentUser = [CSUser sharedInstance];
    
    NSError* error = nil;
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc]init];

    
    NSMutableArray *tagNames = [[NSMutableArray alloc]initWithCapacity:SPOTS_CAPACITY];
    NSMutableArray *tagColors = [[NSMutableArray alloc]initWithCapacity:SPOTS_CAPACITY];
    NSMutableArray *longitudes = [[NSMutableArray alloc]initWithCapacity:SPOTS_CAPACITY];
    NSMutableArray *latitudes = [[NSMutableArray alloc]initWithCapacity:SPOTS_CAPACITY];
    
    for (CSSpot *spot in spots) {
        [tagNames addObject:spot.name];
        [tagColors addObject:spot.tagColor];
        [longitudes addObject:[NSNumber numberWithFloat:spot.longitude]];
        [latitudes addObject:[NSNumber numberWithFloat:spot.latitude]];
    }
    
    
    [jsonDict setValue:[currentUser getUsername] forKey:@"id"];
    [jsonDict setValue:[currentUser getUsername] forKey:@"username"];
    [jsonDict setValue:[currentUser getPassword] forKey:@"password"];
    [jsonDict setValue:tagNames forKey:@"tagname"];
    [jsonDict setValue:tagColors forKey:@"tagcolor"];
    [jsonDict setValue:longitudes forKey:@"longitude"];
    [jsonDict setValue:latitudes forKey:@"latitude"];
    
    NSArray *aryOfJson = @[jsonDict];
    
    NSData* postData = [NSJSONSerialization dataWithJSONObject:aryOfJson options:kNilOptions error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://coderhosting.com:8983/solr/collection1/update?commit=true"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}



@end
